import 'dart:io';
import 'package:flutter/material.dart';
import '../models/book.dart';
import '../theme/app_theme.dart';
import 'add_book_screen.dart';

class BookDetailScreen extends StatelessWidget {
  final Book book;
  const BookDetailScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('جزئیات کتاب'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddBookScreen(book: book)),
              );
              if (result == true && context.mounted) {
                Navigator.pop(context, true); // برگشت و رفرش لیست
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // عکس جلد و عنوان
            Center(
              child: Column(
                children: [
                  Container(
                    width: 150,
                    height: 200,
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundCream,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.accentGold),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: book.coverPath.isNotEmpty && File(book.coverPath).existsSync()
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(File(book.coverPath), fit: BoxFit.cover),
                          )
                        : const Icon(Icons.book, size: 60, color: AppTheme.primaryGreen),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    book.title,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    book.author,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const Divider(height: 32),
            
            // اطلاعات
            _buildInfoRow('دسته‌بندی', book.category),
            _buildInfoRow('ناشر', book.publisher),
            _buildInfoRow('سال چاپ', book.year),
            _buildInfoRow('محل نگهداری', book.location),
            _buildInfoRow('وضعیت', book.status),
            _buildInfoRow('امتیاز', '${book.rating} از ۵'),
            _buildInfoRow('برچسب‌ها', book.tags),
            
            const Divider(height: 32),
            const Text('توضیحات:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text(
              book.description.isEmpty ? 'توضیحی ثبت نشده است.' : book.description,
              style: const TextStyle(fontSize: 15, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
