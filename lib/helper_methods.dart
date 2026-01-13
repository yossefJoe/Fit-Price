import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:one_shot/app_const.dart';

class HelperMethods {
  static final _picker = ImagePicker();
      final dio = Dio();

  /// Pick image from gallery or camera
  static Future<File?> pickImage({required String sourceType}) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source:
            sourceType == 'camera' ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 80,
      );
      if (pickedFile != null) return File(pickedFile.path);
      return null;
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  /// Upload image to Cloudinary
  static Future<String?> uploadToCloudinary(File imageFile) async {
    try {
      final dio = Dio();
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'upload.jpg',
        ),
        'upload_preset': uploadPreset,
      });

      final response = await dio.post(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
        data: formData,
      );

      if (response.statusCode == 200) {
        return response.data['secure_url'];
      } else {
        print('Cloudinary upload failed: ${response.data}');
        return null;
      }
    } catch (e) {
      print('Error uploading to Cloudinary: $e');
      return null;
    }
  }

  /// ✅ Analyze product image using Gemini
  static Future<Map<String, dynamic>> analyzeProductImage(File imageFile) async {
          final dio = Dio();

    try {
      print('📷 Image loaded: ${await imageFile.length()} bytes');

      // 1️⃣ استخراج النص من الصورة باستخدام OCR
      final inputImage = InputImage.fromFile(imageFile);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final recognizedText = await textRecognizer.processImage(inputImage);
      await textRecognizer.close();

      // 2️⃣ تجهيز اسم المنتج (أول سطر مكتوب في الصورة)
      String productName = recognizedText.text.split('\n').firstOrNull?.trim() ?? '';
      if (productName.isEmpty) {
        return {"error": "لم يتم التعرف على اسم المنتج من الصورة"};
      }

      print('📝 Detected product name: $productName');

      // 3️⃣ إرسال طلب Serper
      var headers = {
        'X-API-KEY': 'df8bdda1f4188fb94aff125db696f396bca66718',
        'Content-Type': 'application/json'
      };
      var data = json.encode({"q": productName});

      print('📤 Sending request to Serper...');
      var response = await dio.request(
        'https://google.serper.dev/search',
        options: Options(
          method: 'POST',
          headers: headers,
        ),
        data: data,
      );

      if (response.statusCode == 200) {
        print('📥 Response received');
        final rawData = response.data as Map<String, dynamic>;
        final firstResult = rawData['organic']?[0] ?? {};

        final title = firstResult['title'] ?? 'غير متوفر';
        final snippet = firstResult['snippet'] ?? '';
        final link = firstResult['link'] ?? '';

        return {
          "title": title,
          // "category": snippet.split('.'),
          "condition": "جديد", // ممكن تحددي logic أفضل لو عندك AI
          "suggested_price_range": {"min": 100, "max": 200}, // placeholder
          "issues": [],
          "confidence_score": 0.85, // placeholder
          "link": link,
        };
      } else {
        return {"error": response.statusMessage ?? "حدث خطأ"};
      }
    } catch (e, stack) {
      print('❌ Error: $e\nStack: $stack');
      return {"error": e.toString()};
    }
  }
}