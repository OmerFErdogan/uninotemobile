import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:uninote/models/view.dart';
import 'package:uninote/services/api_service.dart';
import 'package:uninote/config/api_config.dart';

/// Görüntüleme takip servisi
class ViewService {
  final ApiService _apiService;

  ViewService({
    required ApiService apiService,
  }) : _apiService = apiService;

  /// Not görüntüleme kaydı oluşturma
  /// 
  /// [noteId] Not ID'si
  Future<bool> viewNote(int noteId) async {
    try {
      final response = await _apiService.get(
        '${ApiConfig.notesBase}/$noteId/view',
      );

      return response.statusCode == 200;
    } on DioException catch (e) {
      _handleDioError('Not görüntüleme', e);
      return false;
    } catch (e) {
      print('Beklenmeyen not görüntüleme hatası: $e');
      return false;
    }
  }

  /// PDF görüntüleme kaydı oluşturma
  /// 
  /// [pdfId] PDF ID'si
  Future<bool> viewPdf(int pdfId) async {
    try {
      final response = await _apiService.get(
        '${ApiConfig.pdfsBase}/$pdfId/view',
      );

      return response.statusCode == 200;
    } on DioException catch (e) {
      _handleDioError('PDF görüntüleme', e);
      return false;
    } catch (e) {
      print('Beklenmeyen PDF görüntüleme hatası: $e');
      return false;
    }
  }

  /// İçerik görüntüleme kayıtlarını getirme
  /// 
  /// [type] İçerik türü ('note' veya 'pdf')
  /// [contentId] İçerik ID'si
  /// [limit] Sayfa başına kayıt sayısı (varsayılan: 10)
  /// [offset] Atlanacak kayıt sayısı (varsayılan: 0)
  Future<ViewListResponse?> getContentViews(
    String type,
    int contentId, {
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final response = await _apiService.get(
        '/views/content/$type/$contentId',
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );

      if (response.statusCode == 200) {
        if (response.data is String) {
          final jsonData = json.decode(response.data);
          return ViewListResponse.fromJson(jsonData);
        } else if (response.data is Map) {
          return ViewListResponse.fromJson(Map<String, dynamic>.from(response.data));
        }
      }
      
      return null;
    } on DioException catch (e) {
      _handleDioError('İçerik görüntüleme kayıtlarını getirme', e);
      return null;
    } catch (e) {
      print('Beklenmeyen içerik görüntüleme kayıtlarını getirme hatası: $e');
      return null;
    }
  }

  /// Kullanıcı görüntüleme kayıtlarını getirme
  /// 
  /// [limit] Sayfa başına kayıt sayısı (varsayılan: 10)
  /// [offset] Atlanacak kayıt sayısı (varsayılan: 0)
  Future<ViewListResponse?> getUserViews({
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final response = await _apiService.get(
        '/views/user',
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );

      if (response.statusCode == 200) {
        if (response.data is String) {
          final jsonData = json.decode(response.data);
          return ViewListResponse.fromJson(jsonData);
        } else if (response.data is Map) {
          return ViewListResponse.fromJson(Map<String, dynamic>.from(response.data));
        }
      }
      
      return null;
    } on DioException catch (e) {
      _handleDioError('Kullanıcı görüntüleme kayıtlarını getirme', e);
      return null;
    } catch (e) {
      print('Beklenmeyen kullanıcı görüntüleme kayıtlarını getirme hatası: $e');
      return null;
    }
  }

  /// Görüntüleme durumu kontrolü
  /// 
  /// [type] İçerik türü ('note' veya 'pdf')
  /// [contentId] İçerik ID'si
  Future<bool> checkViewStatus(String type, int contentId) async {
    try {
      final response = await _apiService.get(
        '/views/check',
        queryParameters: {
          'type': type,
          'contentId': contentId,
        },
      );

      if (response.statusCode == 200) {
        if (response.data is String) {
          final jsonData = json.decode(response.data);
          return ViewCheckResponse.fromJson(jsonData).viewed;
        } else if (response.data is Map) {
          return ViewCheckResponse.fromJson(Map<String, dynamic>.from(response.data)).viewed;
        }
      }
      
      return false;
    } on DioException catch (e) {
      _handleDioError('Görüntüleme durumu kontrolü', e);
      return false;
    } catch (e) {
      print('Beklenmeyen görüntüleme durumu kontrolü hatası: $e');
      return false;
    }
  }

  /// Dio hatalarını işlemek için yardımcı metod
  void _handleDioError(String operation, DioException e) {
    print('$operation hatası: ${e.message}');
    
    if (e.response != null) {
      print('Durum kodu: ${e.response?.statusCode}');
      print('Sunucu hata mesajı: ${e.response?.data}');
    }
    
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      print('Zaman aşımı hatası: İstek tamamlanamadı, sunucu yanıt vermiyor.');
    } else if (e.type == DioExceptionType.connectionError) {
      print('Bağlantı hatası: Sunucuya ulaşılamıyor, internet bağlantınızı kontrol edin.');
    }
  }
}
