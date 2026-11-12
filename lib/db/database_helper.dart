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
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
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
  }

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
}