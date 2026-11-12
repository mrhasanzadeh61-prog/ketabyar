import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import '../models/book.dart';
import '../theme/app_theme.dart';
import '../db/database_helper.dart';

class AddBookScreen extends StatefulWidget {
  final Book? book;
  const AddBookScreen({super.key, this.book});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _publisherController = TextEditingController();
  final _yearController = TextEditingController();
  final _locationController = TextEditingController();
  final _tagsController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _category = 'عمومی';
  String _status = 'نخوانده';
  int _rating = 0;
  bool _isLoading = false;

  // عکس
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;

  // اسکنر
  bool _isScanning = false;
  bool _isFetchingInfo = false;

  @override
  void initState() {
    super.initState();
    if (widget.book != null) {
      _titleController.text = widget.book!.title;
      _authorController.text = widget.book!.author;
      _publisherController.text = widget.book!.publisher;
      _yearController.text = widget.book!.year;
      _locationController.text = widget.book!.location;
      _tagsController.text = widget.book!.tags;
      _descriptionController.text = widget.book!.description;
      _category = widget.book!.category;
      _status = widget.book!.status;
      _rating = widget.book!.rating;
      
      if (widget.book!.coverPath.isNotEmpty) {
        _imageFile = File(widget.book!.coverPath);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _publisherController.dispose();
    _yearController.dispose();
    _locationController.dispose();
    _tagsController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() => _imageFile = File(pickedFile.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطا: $e')));
      }
    }
  }

  // تابع اسکن بارکد
  Future<void> _startScanning() async {
    setState(() => _isScanning = true);
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BarcodeScannerScreen()),
    );
    
    setState(() => _isScanning = false);

    if (result != null && result is String) {
      // نتیجه اسکن (شماره ISBN)
      _fetchBookInfo(result);
    }
  }

  // تابع دریافت اطلاعات از Open Library
  Future<void> _fetchBookInfo(String isbn) async {
    setState(() => _isFetchingInfo = true);
    try {
      final url = Uri.parse('https://openlibrary.org/api/books?bibkeys=ISBN:$isbn&format=json&jscmd=data');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final key = 'ISBN:$isbn';
        
        if (data.containsKey(key)) {
          final bookData = data[key];
          setState(() {
            _titleController.text = bookData['title'] ?? '';
            if (bookData['authors'] != null && bookData['authors'].isNotEmpty) {
              _authorController.text = bookData['authors'][0]['name'] ?? '';
            }
            if (bookData['publishers'] != null && bookData['publishers'].isNotEmpty) {
              _publisherController.text = bookData['publishers'][0]['name'] ?? '';
            }
            if (bookData['publish_date'] != null) {
              _yearController.text = bookData['publish_date'].toString();
            }
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('اطلاعات کتاب با موفقیت دریافت شد!')),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('کتابی با این ISBN پیدا نشد. دستی وارد کنید.')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا در دریافت اطلاعات (احتمالاً اینترنت قطع است): $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isFetchingInfo = false);
    }
  }

  Future<void> _saveBook() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final newBook = Book(
      id: widget.book?.id,
      title: _titleController.text,
      author: _authorController.text,
      publisher: _publisherController.text,
      year: _yearController.text,
      category: _category,
      description: _descriptionController.text,
      coverPath: _imageFile?.path ?? '',
      location: _locationController.text,
      status: _status,
      rating: _rating,
      tags: _tagsController.text,
    );

    try {
      if (widget.book == null) {
        await DatabaseHelper.instance.create(newBook);
      } else {
        await DatabaseHelper.instance.update(newBook);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('کتاب ذخیره شد!')));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطا: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book == null ? 'ثبت کتاب جدید' : 'ویرایش کتاب'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => _pickImage(ImageSource.gallery),
                      child: Container(
                        width: 120,
                        height: 160,
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundCream,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.accentGold),
                        ),
                        child: _imageFile != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(_imageFile!, fit: BoxFit.cover),
                              )
                            : const Icon(Icons.add_a_photo, size: 40, color: AppTheme.primaryGreen),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton.icon(
                          onPressed: () => _pickImage(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt, color: AppTheme.primaryGreen),
                          label: const Text('دوربین'),
                        ),
                        const SizedBox(width: 16),
                        TextButton.icon(
                          onPressed: _isScanning ? null : _startScanning,
                          icon: _isScanning 
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.qr_code_scanner, color: AppTheme.primaryGreen),
                          label: const Text('اسکن بارکد'),
                        ),
                      ],
                    ),
                    if (_isFetchingInfo)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text('در حال دریافت اطلاعات از اینترنت...', style: TextStyle(color: AppTheme.accentGold)),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              _buildTextField(_titleController, 'عنوان کتاب *', Icons.book, isRequired: true),
              const SizedBox(height: 12),
              _buildTextField(_authorController, 'مؤلف', Icons.person),
              const SizedBox(height: 12),
              _buildTextField(_publisherController, 'ناشر', Icons.business),
              const SizedBox(height: 12),
              _buildTextField(_yearController, 'سال چاپ', Icons.date_range, keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              _buildTextField(_locationController, 'محل نگهداری', Icons.shelves),
              const SizedBox(height: 12),
              
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(labelText: 'دسته‌بندی', border: OutlineInputBorder(), prefixIcon: Icon(Icons.category)),
                items: ['عمومی', 'مذهبی', 'ادبیات', 'تاریخی', 'علمی', 'کودک و نوجوان', 'فلسفه'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (val) { if (val != null) setState(() => _category = val); },
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(labelText: 'وضعیت مطالعه', border: OutlineInputBorder(), prefixIcon: Icon(Icons.read_more)),
                items: ['نخوانده', 'در حال خواندن', 'خوانده‌شده'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (val) { if (val != null) setState(() => _status = val); },
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  const Text('امتیاز: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  ...List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(index < _rating ? Icons.star : Icons.star_border, color: AppTheme.accentGold),
                      onPressed: () => setState(() => _rating = index + 1),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 12),
              
              _buildTextField(_tagsController, 'برچسب‌ها', Icons.label),
              const SizedBox(height: 12),
              _buildTextField(_descriptionController, 'توضیحات', Icons.description, maxLines: 3),
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isLoading ? null : _saveBook,
                  icon: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.check),
                  label: Text(_isLoading ? 'در حال ذخیره...' : 'ذخیره کتاب', style: const TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isRequired = false, TextInputType? keyboardType, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon), border: const OutlineInputBorder(), alignLabelWithHint: true),
      validator: isRequired ? (value) { if (value == null || value.isEmpty) return 'این فیلد الزامی است'; return null; } : null,
    );
  }
}

// صفحه اسکنر بارکد
class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  final MobileScannerController controller = MobileScannerController();
  bool _isScanned = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('اسکن بارکد کتاب')),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              if (_isScanned) return;
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  _isScanned = true;
                  Navigator.pop(context, barcode.rawValue);
                  break;
                }
              }
            },
          ),
          // راهنما
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 250,
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Text(
              'بارکد ISBN پشت جلد کتاب را داخل کادر قرار دهید',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}