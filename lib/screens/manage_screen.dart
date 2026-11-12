import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../db/database_helper.dart';

class ManageScreen extends StatefulWidget {
  const ManageScreen({super.key});

  @override
  State<ManageScreen> createState() => _ManageScreenState();
}

class _ManageScreenState extends State<ManageScreen> {
  List<String> _shelves = [];
  List<String> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final shelves = await DatabaseHelper.instance.getShelves();
    final categories = await DatabaseHelper.instance.getCategories();
    setState(() {
      _shelves = shelves;
      _categories = categories;
      _isLoading = false;
    });
  }

  void _showAddDialog(bool isShelf) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isShelf ? 'افزودن قفسه جدید' : 'افزودن دسته‌بندی جدید'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: isShelf ? 'مثلاً قفسه پذیرایی' : 'مثلاً رمان',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('انصراف'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                if (isShelf) {
                  await DatabaseHelper.instance.addShelf(controller.text);
                } else {
                  await DatabaseHelper.instance.addCategory(controller.text);
                }
                if (mounted) Navigator.pop(context);
                _loadData();
              }
            },
            child: const Text('افزودن'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مدیریت قفسه‌ها و دسته‌ها')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // بخش قفسه‌ها
                _buildSectionHeader('قفسه‌ها', Icons.storage, () => _showAddDialog(true)),
                ..._shelves.map((shelf) => _buildListItem(shelf, true)),
                const Divider(height: 32),
                
                // بخش دسته‌بندی‌ها
                _buildSectionHeader('دسته‌بندی‌ها', Icons.category, () => _showAddDialog(false)),
                ..._categories.map((cat) => _buildListItem(cat, false)),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, VoidCallback onAdd) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryGreen),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.add_circle, color: AppTheme.accentGold),
            onPressed: onAdd,
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(String name, bool isShelf) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(name),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () async {
            if (isShelf) {
              await DatabaseHelper.instance.deleteShelf(name);
            } else {
              await DatabaseHelper.instance.deleteCategory(name);
            }
            _loadData();
          },
        ),
      ),
    );
  }
}
