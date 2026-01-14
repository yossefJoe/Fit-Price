import 'dart:io';

import 'package:flutter/material.dart';
import 'package:one_shot/assets_manager.dart';
import 'package:one_shot/custom_gradient.dart';
import 'package:one_shot/result_card.dart';

import 'button.dart';
import 'helper_methods.dart';
import 'result_model.dart';

class ImageSearch extends StatefulWidget {
  const ImageSearch({Key? key}) : super(key: key);

  @override
  _ImageSearchState createState() => _ImageSearchState();
}

class _ImageSearchState extends State<ImageSearch> {
  bool _isLoading = false;
  File? _selectedImage;
  String? _errorMessage;
  List<ResultModel> _results = [];
  Future<void> _pickAndSearch(String source) async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _results = [];
      });

      File? selectedImage = await HelperMethods.pickImage(sourceType: source);
      if (selectedImage == null) {
        setState(() {
          _errorMessage = 'لم يتم اختيار صورة';
          _isLoading = false;
        });
        return;
      }

      setState(() => _selectedImage = selectedImage);

      String? uploadedUrl = await HelperMethods.uploadToCloudinary(
        selectedImage,
      );
      if (uploadedUrl == null) {
        setState(() {
          _errorMessage = 'حدث خطأ أثناء رفع الصورة';
          _isLoading = false;
        });
        return;
      }

      // البحث عن النتائج بالـ Image
      List<ResultModel> searchResults = await HelperMethods.searchByImage(
        selectedImage,
      );
      setState(() {
        _results = searchResults;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomGradient(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
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
                  child: Image.file(_selectedImage!, fit: BoxFit.fill),
                ),
              ),

            const SizedBox(height: 20),

            // أزرار اختيار الصورة
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TypeButton(text: 'كاميرا'),

                const SizedBox(width: 10),
                TypeButton(text: 'معرض'),
              ],
            ),

            const SizedBox(height: 30),

            // مؤشر التحميل
            if (_isLoading)
              Center(
                child: Column(
                  children: [
                    Image.asset(AssetsManager.loading),
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

            // عرض النتائج لكل عنصر في List<ResultModel>
            if (_results.isNotEmpty && !_isLoading)
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children:
                      _results.map((res) => ResultCard(result: res)).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
