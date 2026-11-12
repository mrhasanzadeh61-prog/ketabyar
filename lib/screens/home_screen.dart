import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../db/database_helper.dart';
import '../models/book.dart';
import 'book_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Book> _allBooks = [];
  List<Book> _filteredBooks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBooks();
    _searchController.addListener(_filterBooks);
  }

  Future<void> _loadBooks() async {
    setState(() => _isLoading = true);
    final books = await DatabaseHelper.instance.readAllBooks();
    setState(() {
      _allBooks = books;
      _filteredBooks = books;
      _isLoading = false;
    });
  }

  void _filterBooks() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredBooks = _allBooks;
      } else {
        _filteredBooks = _allBooks.where((book) {
          return book.title.toLowerCase().contains(query) ||
                 book.author.toLowerCase().contains(query) ||
                 book.publisher.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('کتاب‌یار', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // آمار
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text('${_allBooks.length}', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    const Text('کل کتاب‌ها', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  ],
                ),
                Column(
                  children: [
                    Text('${_allBooks.map((b) => b.author).where((a) => a.isNotEmpty).toSet().length}', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    const Text('نویسندگان', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  ],
                ),
                Column(
                  children: [
                    Text('${_allBooks.map((b) => b.category).toSet().length}', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    const Text('دسته‌ها', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  ],
                ),
              ],
            ),
          ),
          
          // جستجو
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'جستجوی کتاب...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.primaryGreen),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),

          // لیست کتاب‌ها
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredBooks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.menu_book, size: 80, color: AppTheme.primaryGreen.withOpacity(0.3)),
                            const SizedBox(height: 16),
                            Text(
                              _allBooks.isEmpty ? 'هنوز کتابی اضافه نکردی!' : 'کتابی با این مشخصات پیدا نشد.',
                              style: const TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredBooks.length,
                        itemBuilder: (context, index) {
                          final book = _filteredBooks[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: InkWell(
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => BookDetailScreen(book: book)),
                                );
                                if (result == true) _loadBooks();
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 60,
                                      height: 85,
                                      decoration: BoxDecoration(
                                        color: AppTheme.backgroundCream,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: AppTheme.accentGold.withOpacity(0.5)),
                                      ),
                                      child: const Icon(Icons.book, size: 30, color: AppTheme.primaryGreen),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(book.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)),
                                          const SizedBox(height: 4),
                                          Text(book.author, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: AppTheme.accentGold.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(book.category, style: const TextStyle(fontSize: 11, color: AppTheme.accentGold)),
                                              ),
                                              const Spacer(),
                                              Row(
                                                children: List.generate(5, (index) {
                                                  return Icon(
                                                    index < book.rating ? Icons.star : Icons.star_border,
                                                    size: 14,
                                                    color: AppTheme.accentGold,
                                                  );
                                                }),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
