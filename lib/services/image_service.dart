import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import 'api_service.dart';

class ImageService {
  // Upload ảnh lên server
  static Future<String?> uploadImage(File imageFile) async {
    try {
      print('📸 [ImageService] Uploading image...');
      print('📍 [ImageService] File path: ${imageFile.path}');
      print('📊 [ImageService] File size: ${await imageFile.length()} bytes');
      
      final token = await ApiService.getToken();
      
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/upload/image'),
      );
      
      // Thêm token vào header
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      
      // Thêm file
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
        ),
      );
      
      print('🌐 [ImageService] Sending request...');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      print('📡 [ImageService] Status: ${response.statusCode}');
      print('📦 [ImageService] Response: ${response.body}');
      
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        print('📦 [ImageService] Response data: ${json['data']}');
        if (json['success'] == true && json['data'] != null) {
          final imageUrl = json['data']['url'] ?? json['data']['imageUrl'];
          print('✅ [ImageService] Image uploaded successfully!');
          print('🔗 [ImageService] Image URL: $imageUrl');
          return imageUrl;
        }
      }
      
      print('❌ [ImageService] Upload failed');
      return null;
    } catch (e) {
      print('❌ [ImageService] Error uploading image: $e');
      print('Stack trace: ${StackTrace.current}');
      return null;
    }
  }

  // Upload nhiều ảnh
  static Future<List<String>> uploadMultipleImages(List<File> imageFiles) async {
    final List<String> urls = [];
    
    for (var file in imageFiles) {
      final url = await uploadImage(file);
      if (url != null) {
        urls.add(url);
      }
    }
    
    return urls;
  }

  // Xóa ảnh (nếu backend support)
  static Future<bool> deleteImage(String imageUrl) async {
    try {
      print('📸 [ImageService] Deleting image: $imageUrl');
      
      final response = await ApiService.delete(
        '/upload/image',
        auth: true,
      );
      
      return response['success'] == true;
    } catch (e) {
      print('❌ [ImageService] Error deleting image: $e');
      return false;
    }
  }
}
