import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:one_shot/app_const.dart';

import 'result_model.dart';

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

  /// 🔹 Text search
  static Future<List<ResultModel>> searchByText(String query) async {
    try {
      final dio = Dio();
      final headers = {
        'X-API-KEY': myApiKey,
        'Content-Type': 'application/json',
      };
      final data = json.encode({"q": query, "gl": "eg", "hl": "ar", "type": "search"});

      final response = await dio.post(
        'https://google.serper.dev/search',
        options: Options(headers: headers),
        data: data,
      );

      if (response.statusCode == 200) {
        final rawData = response.data as Map<String, dynamic>;
        final List results = rawData['organic'] ?? [];
        return results.map((e) => ResultModel.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error searching text: $e');
      return [];
    }
  }

  /// 🔹 Image search
  static Future<List<ResultModel>> searchByImage(File imageFile) async {
    try {
      final uploadedUrl = await uploadToCloudinary(imageFile);
      if (uploadedUrl == null) return [];

      final dio = Dio();
      final headers = {
        'X-API-KEY': myApiKey,
        'Content-Type': 'application/json',
      };
      final data = json.encode({
        "url": uploadedUrl,
            "location": "Egypt",
        "gl": "eg",
        "hl": "ar",
        "type": "lens",
        "num": 10,
        "page": 1,
      });

      final response = await dio.post(
        'https://google.serper.dev/search',
        options: Options(headers: headers),
        data: data,
      );

      if (response.statusCode == 200) {
        final rawData = response.data as Map<String, dynamic>;
        final List results = rawData['organic'] ?? [];
        return results.map((e) => ResultModel.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error searching image: $e');
      return [];
    }
  }
}
