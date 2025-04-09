import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  final Dio _dio;

  StorageService(this._dio);

  Future<String> uploadFile(File file, String path) async {
    try {
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
      });

      final response = await _dio.post(path, data: formData);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data['filePath'] ?? '';
      } else {
        throw Exception('Dosya yüklenirken bir hata oluştu');
      }
    } catch (e) {
      debugPrint('Dosya yükleme hatası: $e');
      rethrow;
    }
  }

  Future<void> deleteFile(String path) async {
    try {
      final response = await _dio.delete(path);
      
      if (response.statusCode != 200) {
        throw Exception('Dosya silinirken bir hata oluştu');
      }
    } catch (e) {
      debugPrint('Dosya silme hatası: $e');
      rethrow;
    }
  }

  // PDF dosyasını indirme
  Future<File> downloadFile(String url, String savePath) async {
    try {
      final response = await _dio.get(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
        ),
      );

      final file = File(savePath);
      final raf = file.openSync(mode: FileMode.write);
      raf.writeFromSync(response.data);
      await raf.close();

      return file;
    } catch (e) {
      debugPrint('Dosya indirme hatası: $e');
      rethrow;
    }
  }
}