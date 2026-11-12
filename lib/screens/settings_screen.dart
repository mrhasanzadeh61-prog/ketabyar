import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../theme/app_theme.dart';
import '../db/database_helper.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _backupDatabase(BuildContext context) async {
    try {
      final dbPath = await getDatabasesPath();
      final dbFile = File(p.join(dbPath, 'ketabyar.db'));

      if (!await dbFile.exists()) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('دیتابیسی برای پشتیبان‌گیری پیدا نشد!')),
          );
        }
        return;
      }

      final directory = await getDownloadsDirectory();
      if (directory == null) return;

      final backupPath = p.join(directory.path, 'ketabyar_backup_${DateTime.now().millisecondsSinceEpoch}.db');
      await dbFile.copy(backupPath);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('پشتیبان با موفقیت ذخیره شد:\n$backupPath')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا در پشتیبان‌گیری: $e')),
        );
      }
    }
  }

  Future<void> _restoreDatabase(BuildContext context) async {
    // فعلاً بازیابی رو غیرفعال می‌کنیم تا بعداً با روش دیگه پیاده‌سازی کنیم
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('بازیابی در نسخه بعدی اضافه می‌شود.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تنظیمات')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.backup, color: AppTheme.primaryGreen),
              title: const Text('پشتیبان‌گیری از کتابخانه'),
              subtitle: const Text('ذخیره اطلاعات در پوشه Downloads'),
              trailing: const Icon(Icons.chevron_left),
              onTap: () => _backupDatabase(context),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.restore, color: AppTheme.primaryGreen),
              title: const Text('بازیابی از فایل پشتیبان'),
              subtitle: const Text('به زودی...'),
              trailing: const Icon(Icons.chevron_left),
              onTap: () => _restoreDatabase(context),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline, color: AppTheme.primaryGreen),
              title: const Text('درباره کتاب‌یار'),
              subtitle: const Text('نسخه ۱.۰.۰'),
              trailing: const Icon(Icons.chevron_left),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}
