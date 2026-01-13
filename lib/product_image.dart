import 'package:flutter/material.dart';
import 'dart:io';
import 'package:one_shot/helper_methods.dart';

class ProductImage extends StatefulWidget {
  const ProductImage({Key? key}) : super(key: key);

  @override
  State<ProductImage> createState() => _ProductImageState();
}

class _ProductImageState extends State<ProductImage> {
  String _title = '';
  String _category = '';
  String _condition = '';
  String _priceRange = '';
  List<String> _issues = [];
  double _confidence = 0.0;
  bool _isLoading = false;
  File? _selectedImage;
  String? _errorMessage;

  

  Future<void> _analyzeImage(String sourceType) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _title = '';
      _category = '';
      _condition = '';
      _priceRange = '';
      _issues = [];
      _confidence = 0.0;
    });

    try {
      // 1️⃣ اختر الصورة
      final image = await HelperMethods.pickImage(sourceType: sourceType);

      if (image == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'لم يتم اختيار صورة';
        });
        return;
      }

      setState(() => _selectedImage = image);

      // 2️⃣ حلّل الصورة مباشرة بـ Gemini (بدون رفع!)
      final result = await HelperMethods.analyzeProductImage(image);

      // 3️⃣ تحقق من وجود خطأ
      if (result.containsKey('error')) {
        setState(() {
          _isLoading = false;
          _errorMessage = result['error'];
        });
        return;
      }

      // 4️⃣ استخرج البيانات
      setState(() {
        _title = result['title'] ?? 'غير متوفر';
        _category = result['category'] ?? 'غير متوفر';
        _condition = result['condition'] ?? 'غير متوفر';

        final priceMin = result['suggested_price_range']?['min'] ?? 0;
        final priceMax = result['suggested_price_range']?['max'] ?? 0;
        _priceRange = '\$$priceMin - \$$priceMax';

        _issues =
            (result['issues'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [];

        _confidence = (result['confidence_score'] ?? 0.0).toDouble();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'حدث خطأ: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تحليل المنتج'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // عرض الصورة
            if (_selectedImage != null)
              Container(
                height: 300,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.file(_selectedImage!, fit: BoxFit.cover),
                ),
              ),

            const SizedBox(height: 20),

            // الأزرار
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        _isLoading ? null : () => _analyzeImage('camera'),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('كاميرا'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        _isLoading ? null : () => _analyzeImage('gallery'),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('معرض'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // مؤشر التحميل
            if (_isLoading)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'جاري تحليل الصورة...',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),

            // رسالة الخطأ
            if (_errorMessage != null && !_isLoading)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // النتائج
            if (_title.isNotEmpty && !_isLoading)
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // العنوان
                      const Text(
                        'نتائج التحليل',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(height: 24),

                      _buildInfoRow(
                        icon: Icons.title,
                        label: 'العنوان',
                        value: _title,
                      ),

                      _buildInfoRow(
                        icon: Icons.category,
                        label: 'الفئة',
                        value: _category,
                      ),

                      _buildInfoRow(
                        icon: Icons.check_circle_outline,
                        label: 'الحالة',
                        value: _condition,
                      ),

                      _buildInfoRow(
                        icon: Icons.attach_money,
                        label: 'السعر المقترح',
                        value: _priceRange,
                      ),

                      // المشاكل
                      if (_issues.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(
                              Icons.warning_amber,
                              color: Colors.orange.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'المشاكل المكتشفة:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ..._issues.map(
                          (issue) => Padding(
                            padding: const EdgeInsets.only(left: 28, top: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '• ',
                                  style: TextStyle(fontSize: 16),
                                ),
                                Expanded(
                                  child: Text(
                                    issue,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      // مستوى الثقة
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.analytics_outlined, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'مستوى الثقة: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${(_confidence * 100).toStringAsFixed(0)}%',
                            style: TextStyle(
                              color:
                                  _confidence > 0.7
                                      ? Colors.green
                                      : Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blue.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 15, color: Colors.black87),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
