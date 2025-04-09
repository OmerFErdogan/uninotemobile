import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/pdf.dart';
import '../config/api_config.dart';

class PDFService {
  final Dio _dio;

  PDFService(this._dio);

  // PDF yükleme
  Future<PDF> uploadPDF({
    required File file,
    required String title,
    required String description,
    required List<String> tags,
    required bool isPublic,
  }) async {
    try {
      debugPrint('PDF yükleme başlıyor...');
      debugPrint('File path: ${file.path}');
      debugPrint('Title: $title');
      debugPrint('Description: $description');
      debugPrint('Tags: $tags');
      debugPrint('IsPublic: $isPublic');
      
      // Form verilerini oluştur
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
        'title': title,
        'description': description,
        'tags': jsonEncode(tags),
        'isPublic': isPublic.toString(),
      });

      debugPrint('FormData oluşturuldu, API isteği yapılıyor...');
      debugPrint('URL: ${ApiConfig.baseUrl}${ApiConfig.pdfs}');
      
      final response = await _dio.post(
        '${ApiConfig.baseUrl}${ApiConfig.pdfs}',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
          followRedirects: false,
          validateStatus: (status) {
            return status! < 500;
          }
        ),
      );

      debugPrint('API yanıtı alındı. Status code: ${response.statusCode}');
      if (response.statusCode == 201 || response.statusCode == 200) {
        debugPrint('PDF başarıyla yüklendi. Yanıt: ${response.data}');
        return PDF.fromJson(response.data);
      } else {
        debugPrint('PDF yüklenirken hata: ${response.statusCode} - ${response.data}');
        throw Exception('PDF yüklenirken bir hata oluştu: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('PDF yükleme hatası: $e');
      rethrow;
    }
  }

  // PDF güncelleme
  Future<PDF> updatePDF({
    required int id,
    required String title,
    required String description,
    required List<String> tags,
    required bool isPublic,
  }) async {
    try {
      final response = await _dio.put(
        '${ApiConfig.baseUrl}${ApiConfig.pdfs}/$id',
        data: {
          'title': title,
          'description': description,
          'tags': tags,
          'isPublic': isPublic,
        },
      );

      if (response.statusCode == 200) {
        return PDF.fromJson(response.data);
      } else {
        throw Exception('PDF güncellenirken bir hata oluştu');
      }
    } catch (e) {
      debugPrint('PDF güncelleme hatası: $e');
      rethrow;
    }
  }

  // PDF silme
  Future<void> deletePDF(int id) async {
    try {
      final response = await _dio.delete(
        '${ApiConfig.baseUrl}${ApiConfig.pdfs}/$id',
      );

      if (response.statusCode != 200) {
        throw Exception('PDF silinirken bir hata oluştu');
      }
    } catch (e) {
      debugPrint('PDF silme hatası: $e');
      rethrow;
    }
  }

  // PDF getirme
  Future<PDF> getPDF(int id) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.baseUrl}${ApiConfig.pdfs}/$id',
      );

      if (response.statusCode == 200) {
        return PDF.fromJson(response.data);
      } else {
        throw Exception('PDF getirilirken bir hata oluştu');
      }
    } catch (e) {
      debugPrint('PDF getirme hatası: $e');
      rethrow;
    }
  }
  
  // PDF içeriğini getirme (dosya indirme)
  Future<String?> getPDFContent(int id) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.baseUrl}${ApiConfig.pdfs}/$id/content',
        options: Options(
          responseType: ResponseType.bytes,
        ),
      );

      if (response.statusCode == 200) {
        // Geçici dosya oluştur
        final tempDir = await Directory.systemTemp.createTemp('pdf_');
        final file = File('${tempDir.path}/document.pdf');
        
        // Dosyayı yaz
        await file.writeAsBytes(response.data);
        
        return file.path;
      } else {
        throw Exception('PDF içeriği getirilirken bir hata oluştu');
      }
    } catch (e) {
      debugPrint('PDF içeriği getirme hatası: $e');
      rethrow;
    }
  }

  // Kullanıcının PDF'lerini getirme
  Future<List<PDF>> getMyPDFs({int limit = 10, int offset = 0}) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.baseUrl}${ApiConfig.pdfs}/my',
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );

      if (response.statusCode == 200) {
        // Sunucu null döndürebilir, bu durumda boş liste döndür
        if (response.data == null || response.data == "null") {
          debugPrint('Sunucu boş PDF listesi döndürdü (null)');
          return [];
        }
        
        // Sunucu string olarak döndürebilir, json parse et
        if (response.data is String) {
          try {
            response.data = jsonDecode(response.data);
          } catch (e) {
            debugPrint('JSON parse hatası: $e, boş liste döndürülüyor');
            return [];
          }
        }
        
        if (response.data is List) {
          List<dynamic> data = response.data;
          return data.map((item) => PDF.fromJson(item)).toList();
        } else {
          debugPrint('Beklenmeyen veri formatı: ${response.data.runtimeType}');
          return [];
        }
      } else {
        throw Exception('PDF\'ler getirilirken bir hata oluştu');
      }
    } catch (e) {
      debugPrint('PDF\'leri getirme hatası: $e');
      // Hata durumunda boş liste döndür
      return [];
    }
  }

  // Herkese açık PDF'leri getirme
  Future<List<PDF>> getPublicPDFs({int limit = 10, int offset = 0}) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.baseUrl}${ApiConfig.pdfs}',
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );

      if (response.statusCode == 200) {
        // Sunucu null döndürebilir, bu durumda boş liste döndür
        if (response.data == null || response.data == "null") {
          debugPrint('Sunucu boş PDF listesi döndürdü (null)');
          return [];
        }
        
        // Sunucu string olarak döndürebilir, json parse et
        if (response.data is String) {
          try {
            response.data = jsonDecode(response.data);
          } catch (e) {
            debugPrint('JSON parse hatası: $e, boş liste döndürülüyor');
            return [];
          }
        }
        
        if (response.data is List) {
          List<dynamic> data = response.data;
          return data.map((item) => PDF.fromJson(item)).toList();
        } else {
          debugPrint('Beklenmeyen veri formatı: ${response.data.runtimeType}');
          return [];
        }
      } else {
        throw Exception('PDF\'ler getirilirken bir hata oluştu');
      }
    } catch (e) {
      debugPrint('PDF\'leri getirme hatası: $e');
      // Hata durumunda boş liste döndür
      return [];
    }
  }

  // PDF arama
  Future<List<PDF>> searchPDFs(String query, {int limit = 10, int offset = 0}) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.baseUrl}${ApiConfig.pdfs}/search',
        queryParameters: {
          'q': query,
          'limit': limit,
          'offset': offset,
        },
      );

      if (response.statusCode == 200) {
        // Sunucu null döndürebilir, bu durumda boş liste döndür
        if (response.data == null || response.data == "null") {
          debugPrint('Sunucu boş PDF listesi döndürdü (null)');
          return [];
        }
        
        // Sunucu string olarak döndürebilir, json parse et
        if (response.data is String) {
          try {
            response.data = jsonDecode(response.data);
          } catch (e) {
            debugPrint('JSON parse hatası: $e, boş liste döndürülüyor');
            return [];
          }
        }
        
        if (response.data is List) {
          List<dynamic> data = response.data;
          return data.map((item) => PDF.fromJson(item)).toList();
        } else {
          debugPrint('Beklenmeyen veri formatı: ${response.data.runtimeType}');
          return [];
        }
      } else {
        throw Exception('PDF\'ler aranırken bir hata oluştu');
      }
    } catch (e) {
      debugPrint('PDF arama hatası: $e');
      // Hata durumunda boş liste döndür
      return [];
    }
  }

  // Etikete göre PDF getirme
  Future<List<PDF>> getPDFsByTag(String tag, {int limit = 10, int offset = 0}) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.baseUrl}${ApiConfig.pdfs}/tag/$tag',
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );

      if (response.statusCode == 200) {
        // Sunucu null döndürebilir, bu durumda boş liste döndür
        if (response.data == null || response.data == "null") {
          debugPrint('Sunucu boş PDF listesi döndürdü (null)');
          return [];
        }
        
        // Sunucu string olarak döndürebilir, json parse et
        if (response.data is String) {
          try {
            response.data = jsonDecode(response.data);
          } catch (e) {
            debugPrint('JSON parse hatası: $e, boş liste döndürülüyor');
            return [];
          }
        }
        
        if (response.data is List) {
          List<dynamic> data = response.data;
          return data.map((item) => PDF.fromJson(item)).toList();
        } else {
          debugPrint('Beklenmeyen veri formatı: ${response.data.runtimeType}');
          return [];
        }
      } else {
        throw Exception('Etikete göre PDF\'ler getirilirken bir hata oluştu');
      }
    } catch (e) {
      debugPrint('Etikete göre PDF getirme hatası: $e');
      // Hata durumunda boş liste döndür
      return [];
    }
  }

  // PDF'e yorum ekleme
  Future<PDFComment> addCommentToPDF(int pdfId, String content, {int? pageNumber}) async {
    try {
      final response = await _dio.post(
        '${ApiConfig.baseUrl}${ApiConfig.pdfs}/$pdfId/comments',
        data: {
          'content': content,
          'pageNumber': pageNumber,
        },
      );

      if (response.statusCode == 201) {
        return PDFComment.fromJson(response.data);
      } else {
        throw Exception('PDF\'e yorum eklerken bir hata oluştu');
      }
    } catch (e) {
      debugPrint('PDF yorum ekleme hatası: $e');
      rethrow;
    }
  }

  // PDF yorumlarını getirme
  Future<List<PDFComment>> getPDFComments(int pdfId, {int limit = 10, int offset = 0}) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.baseUrl}${ApiConfig.pdfs}/$pdfId/comments',
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );

      if (response.statusCode == 200) {
        // Sunucu null döndürebilir, bu durumda boş liste döndür
        if (response.data == null || response.data == "null") {
          debugPrint('Sunucu boş yorum listesi döndürdü (null)');
          return [];
        }
        
        // Sunucu string olarak döndürebilir, json parse et
        if (response.data is String) {
          try {
            response.data = jsonDecode(response.data);
          } catch (e) {
            debugPrint('JSON parse hatası: $e, boş liste döndürülüyor');
            return [];
          }
        }
        
        if (response.data is List) {
          List<dynamic> data = response.data;
          return data.map((item) => PDFComment.fromJson(item)).toList();
        } else {
          debugPrint('Beklenmeyen veri formatı: ${response.data.runtimeType}');
          return [];
        }
      } else {
        throw Exception('PDF yorumları getirilirken bir hata oluştu');
      }
    } catch (e) {
      debugPrint('PDF yorumları getirme hatası: $e');
      // Hata durumunda boş liste döndür
      return [];
    }
  }
  
  // PDF'e işaretleme ekleme
  Future<PDFAnnotation> addAnnotationToPDF({
    required int pdfId,
    required int pageNumber,
    String? content,
    required double x,
    required double y,
    required double width,
    required double height,
    required String type,
    required String color,
  }) async {
    try {
      final response = await _dio.post(
        '${ApiConfig.baseUrl}${ApiConfig.pdfs}/$pdfId/annotations',
        data: {
          'pageNumber': pageNumber,
          'content': content,
          'x': x,
          'y': y,
          'width': width,
          'height': height,
          'type': type,
          'color': color,
        },
      );

      if (response.statusCode == 201) {
        return PDFAnnotation.fromJson(response.data);
      } else {
        throw Exception('PDF\'e işaretleme eklerken bir hata oluştu');
      }
    } catch (e) {
      debugPrint('PDF işaretleme ekleme hatası: $e');
      rethrow;
    }
  }

  // PDF işaretlemelerini getirme
  Future<List<PDFAnnotation>> getPDFAnnotations(int pdfId) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.baseUrl}${ApiConfig.pdfs}/$pdfId/annotations',
      );

      if (response.statusCode == 200) {
        // Sunucu null döndürebilir, bu durumda boş liste döndür
        if (response.data == null || response.data == "null") {
          debugPrint('Sunucu boş işaretleme listesi döndürdü (null)');
          return [];
        }
        
        // Sunucu string olarak döndürebilir, json parse et
        if (response.data is String) {
          try {
            response.data = jsonDecode(response.data);
          } catch (e) {
            debugPrint('JSON parse hatası: $e, boş liste döndürülüyor');
            return [];
          }
        }
        
        if (response.data is List) {
          List<dynamic> data = response.data;
          return data.map((item) => PDFAnnotation.fromJson(item)).toList();
        } else {
          debugPrint('Beklenmeyen veri formatı: ${response.data.runtimeType}');
          return [];
        }
      } else {
        throw Exception('PDF işaretlemeleri getirilirken bir hata oluştu');
      }
    } catch (e) {
      debugPrint('PDF işaretlemeleri getirme hatası: $e');
      // Hata durumunda boş liste döndür
      return [];
    }
  }

  // PDF beğenme
  Future<void> likePDF(int pdfId) async {
    try {
      final response = await _dio.post(
        '${ApiConfig.baseUrl}${ApiConfig.pdfs}/$pdfId/like',
      );

      if (response.statusCode != 200) {
        throw Exception('PDF beğenilirken bir hata oluştu');
      }
    } catch (e) {
      debugPrint('PDF beğenme hatası: $e');
      rethrow;
    }
  }

  // PDF beğenisini kaldırma
  Future<void> unlikePDF(int pdfId) async {
    try {
      final response = await _dio.delete(
        '${ApiConfig.baseUrl}${ApiConfig.pdfs}/$pdfId/like',
      );

      if (response.statusCode != 200) {
        throw Exception('PDF beğenisi kaldırılırken bir hata oluştu');
      }
    } catch (e) {
      debugPrint('PDF beğenisi kaldırma hatası: $e');
      rethrow;
    }
  }

  // Beğenilen PDF'leri getirme
  Future<List<PDF>> getLikedPDFs({int limit = 10, int offset = 0}) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.baseUrl}${ApiConfig.pdfs}/liked',
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );

      if (response.statusCode == 200) {
        // Sunucu null döndürebilir, bu durumda boş liste döndür
        if (response.data == null || response.data == "null") {
          debugPrint('Sunucu boş PDF listesi döndürdü (null)');
          return [];
        }
        
        // Sunucu string olarak döndürebilir, json parse et
        if (response.data is String) {
          try {
            response.data = jsonDecode(response.data);
          } catch (e) {
            debugPrint('JSON parse hatası: $e, boş liste döndürülüyor');
            return [];
          }
        }
        
        if (response.data is List) {
          List<dynamic> data = response.data;
          return data.map((item) => PDF.fromJson(item)).toList();
        } else {
          debugPrint('Beklenmeyen veri formatı: ${response.data.runtimeType}');
          return [];
        }
      } else {
        throw Exception('Beğenilen PDF\'ler getirilirken bir hata oluştu');
      }
    } catch (e) {
      debugPrint('Beğenilen PDF\'leri getirme hatası: $e');
      // Hata durumunda boş liste döndür
      return [];
    }
  }

  // PDF için davet bağlantısı oluşturma
  Future<Map<String, dynamic>> createPDFInvite(int pdfId, {DateTime? expiresAt}) async {
    try {
      final response = await _dio.post(
        '${ApiConfig.baseUrl}${ApiConfig.pdfs}/$pdfId/invites',
        data: expiresAt != null ? {'expiresAt': expiresAt.toIso8601String()} : null,
      );

      if (response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception('PDF davet bağlantısı oluşturulurken bir hata oluştu');
      }
    } catch (e) {
      debugPrint('PDF davet bağlantısı oluşturma hatası: $e');
      rethrow;
    }
  }

  // PDF için davet bağlantılarını getirme
  Future<List<Map<String, dynamic>>> getPDFInvites(int pdfId) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.baseUrl}${ApiConfig.pdfs}/$pdfId/invites',
      );

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('PDF davet bağlantıları getirilirken bir hata oluştu');
      }
    } catch (e) {
      debugPrint('PDF davet bağlantıları getirme hatası: $e');
      rethrow;
    }
  }

  // Davet bağlantısı ile PDF getirme
  Future<PDF> getPDFByInvite(String token) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.baseUrl}${ApiConfig.pdfs}/invite/$token',
      );

      if (response.statusCode == 200) {
        return PDF.fromJson(response.data);
      } else {
        throw Exception('Davet bağlantısı ile PDF getirilirken bir hata oluştu');
      }
    } catch (e) {
      debugPrint('Davet bağlantısı ile PDF getirme hatası: $e');
      rethrow;
    }
  }

  // PDF görüntüleme kaydı oluşturma
  Future<void> viewPDF(int pdfId) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.baseUrl}${ApiConfig.pdfs}/$pdfId/view',
      );

      if (response.statusCode != 200) {
        throw Exception('PDF görüntüleme kaydı oluşturulurken bir hata oluştu');
      }
    } catch (e) {
      debugPrint('PDF görüntüleme kaydı oluşturma hatası: $e');
      // Bu hatayı sessizce göz ardı et - kullanıcı deneyimini etkilememeli
    }
  }
}