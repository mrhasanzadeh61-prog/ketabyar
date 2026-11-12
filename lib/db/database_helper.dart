import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/book.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('ketabyar.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2, // نسخه رو به 2 ارتقا دادیم برای جدول‌های جدید
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // جدول کتاب‌ها
    await db.execute('''
      CREATE TABLE books (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        author TEXT,
        publisher TEXT,
        year TEXT,
        category TEXT,
        description TEXT,
        coverPath TEXT,
        location TEXT,
        status TEXT,
        rating INTEGER,
        tags TEXT
      )
    ''');

    // جدول جدید: قفسه‌ها
    await db.execute('''
      CREATE TABLE shelves (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');

    // جدول جدید: دسته‌بندی‌ها
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');

    // چند تا دسته‌بندی پیش‌فرض اضافه می‌کنیم
    final defaultCategories = ['عمومی', 'مذهبی', 'ادبیات', 'تاریخی', 'علمی', 'کودک و نوجوان', 'فلسفه'];
    for (var cat in defaultCategories) {
      await db.insert('categories', {'name': cat});
    }
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE shelves (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE categories (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL
        )
      ''');
      final defaultCategories = ['عمومی', 'مذهبی', 'ادبیات', 'تاریخی', 'علمی', 'کودک و نوجوان', 'فلسفه'];
      for (var cat in defaultCategories) {
        await db.insert('categories', {'name': cat});
      }
    }
  }

  // --- توابع کتاب (همون‌های قبلی) ---
  Future<Book> create(Book book) async {
    final db = await instance.database;
    final id = await db.insert('books', book.toMap());
    return Book.fromMap({...book.toMap(), 'id': id});
  }

  Future<Book> readBook(int id) async {
    final db = await instance.database;
    final maps = await db.query('books', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Book.fromMap(maps.first);
    }
    throw Exception('Book not found');
  }

  Future<List<Book>> readAllBooks() async {
    final db = await instance.database;
    final result = await db.query('books', orderBy: 'id DESC');
    return result.map((json) => Book.fromMap(json)).toList();
  }

  Future<int> update(Book book) async {
    final db = await instance.database;
    return db.update('books', book.toMap(), where: 'id = ?', whereArgs: [book.id]);
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete('books', where: 'id = ?', whereArgs: [id]);
  }

  // --- توابع جدید برای قفسه‌ها ---
  Future<int> addShelf(String name) async {
    final db = await instance.database;
    return db.insert('shelves', {'name': name});
  }

  Future<List<String>> getShelves() async {
    final db = await instance.database;
    final result = await db.query('shelves');
    return result.map((e) => e['name'] as String).toList();
  }

  Future<int> deleteShelf(String name) async {
    final db = await instance.database;
    return db.delete('shelves', where: 'name = ?', whereArgs: [name]);
  }

  // --- توابع جدید برای دسته‌بندی‌ها ---
  Future<int> addCategory(String name) async {
    final db = await instance.database;
    return db.insert('categories', {'name': name});
  }

  Future<List<String>> getCategories() async {
    final db = await instance.database;
    final result = await db.query('categories');
    return result.map((e) => e['name'] as String).toList();
  }

  Future<int> deleteCategory(String name) async {
    final db = await instance.database;
    return db.delete('categories', where: 'name = ?', whereArgs: [name]);
  }
}
