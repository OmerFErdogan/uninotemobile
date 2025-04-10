import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:uninote/models/invite.dart';
import 'package:uninote/models/note.dart';
import 'package:uninote/models/pdf.dart';
import 'package:uninote/services/api_service.dart';
import 'package:uninote/config/api_config.dart';

/// Davet bağlantıları için servis sınıfı
class InviteService {
  final ApiService _apiService;

  InviteService({
    required ApiService apiService,
  }) : _apiService = apiService;

  /// Not için davet bağlantısı oluşturma
  /// 
  /// [noteId] Not ID'si
  /// [expiresAt] Opsiyonel. Bağlantının sona erme tarihi
  Future<Invite?> createNoteInvite(int noteId, {DateTime? expiresAt}) async {
    try {
      final request = CreateInviteRequest(expiresAt: expiresAt);
      final requestJson = request.toJson();
      
      // Debug bilgisi için isteyi yazdır
      print('Gönderilen istek verileri: $requestJson');
      
      final response = await _apiService.post(
        '${ApiConfig.notesBase}/$noteId/invites',
        data: requestJson,
      );

      print('Sunucu yanıtı: ${response.statusCode}');
      print('Yanıt içeriği: ${response.data}');

      if (response.statusCode == 201) {
        if (response.data is String) {
          final jsonData = json.decode(response.data);
          return Invite.fromJson(jsonData);
        } else if (response.data is Map) {
          return Invite.fromJson(Map<String, dynamic>.from(response.data));
        }
      }
      
      return null;
    } on DioException catch (e) {
      _handleDioError('Not davet bağlantısı oluşturma', e);
      return null;
    } catch (e) {
      print('Beklenmeyen not davet bağlantısı oluşturma hatası: $e');
      return null;
    }
  }

  /// PDF için davet bağlantısı oluşturma
  /// 
  /// [pdfId] PDF ID'si
  /// [expiresAt] Opsiyonel. Bağlantının sona erme tarihi
  Future<Invite?> createPdfInvite(int pdfId, {DateTime? expiresAt}) async {
    try {
      final request = CreateInviteRequest(expiresAt: expiresAt);
      final requestJson = request.toJson();
      
      // Debug bilgisi için isteyi yazdır
      print('Gönderilen istek verileri: $requestJson');
      
      final response = await _apiService.post(
        '${ApiConfig.pdfsBase}/$pdfId/invites',
        data: requestJson,
      );

      print('Sunucu yanıtı: ${response.statusCode}');
      print('Yanıt içeriği: ${response.data}');

      if (response.statusCode == 201) {
        if (response.data is String) {
          final jsonData = json.decode(response.data);
          return Invite.fromJson(jsonData);
        } else if (response.data is Map) {
          return Invite.fromJson(Map<String, dynamic>.from(response.data));
        }
      }
      
      return null;
    } on DioException catch (e) {
      _handleDioError('PDF davet bağlantısı oluşturma', e);
      return null;
    } catch (e) {
      print('Beklenmeyen PDF davet bağlantısı oluşturma hatası: $e');
      return null;
    }
  }

  /// Not için davet bağlantılarını getirme
  /// 
  /// [noteId] Not ID'si
  Future<List<Invite>> getNoteInvites(int noteId) async {
    try {
      final response = await _apiService.get(
        '${ApiConfig.notesBase}/$noteId/invites',
      );

      if (response.statusCode == 200) {
        if (response.data is String) {
          final jsonData = json.decode(response.data) as List;
          return jsonData
              .map((item) => Invite.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        } else if (response.data is List) {
          return (response.data as List)
              .map((item) => Invite.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        }
      }
      
      return [];
    } on DioException catch (e) {
      _handleDioError('Not davet bağlantılarını getirme', e);
      return [];
    } catch (e) {
      print('Beklenmeyen not davet bağlantılarını getirme hatası: $e');
      return [];
    }
  }

  /// PDF için davet bağlantılarını getirme
  /// 
  /// [pdfId] PDF ID'si
  Future<List<Invite>> getPdfInvites(int pdfId) async {
    try {
      final response = await _apiService.get(
        '${ApiConfig.pdfsBase}/$pdfId/invites',
      );

      if (response.statusCode == 200) {
        if (response.data is String) {
          final jsonData = json.decode(response.data) as List;
          return jsonData
              .map((item) => Invite.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        } else if (response.data is List) {
          return (response.data as List)
              .map((item) => Invite.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        }
      }
      
      return [];
    } on DioException catch (e) {
      _handleDioError('PDF davet bağlantılarını getirme', e);
      return [];
    } catch (e) {
      print('Beklenmeyen PDF davet bağlantılarını getirme hatası: $e');
      return [];
    }
  }

  /// Davet bağlantısını devre dışı bırakma
  /// 
  /// [inviteId] Davet bağlantısı ID'si
  Future<bool> deactivateInvite(int inviteId) async {
    try {
      final response = await _apiService.delete(
        '${ApiConfig.invitesBase}/$inviteId',
      );

      return response.statusCode == 200;
    } on DioException catch (e) {
      _handleDioError('Davet bağlantısını devre dışı bırakma', e);
      return false;
    } catch (e) {
      print('Beklenmeyen davet bağlantısını devre dışı bırakma hatası: $e');
      return false;
    }
  }

  /// Davet bağlantısını doğrulama
  /// 
  /// [token] Davet bağlantısı token'ı
  Future<InviteValidationResponse?> validateInvite(String token) async {
    try {
      // API dokümanlarına göre düzeltilmiş endpoint - /validate/ önekini kaldırdık
      final response = await _apiService.get(
        '${ApiConfig.invitesBase}/$token',
      );
      
      // Debug bilgisi - yanıtın yapısını gör
      if (response.data != null) {
        if (response.data is String) {
          try {
            print('Yanıt JSON parse edilmeye çalışılıyor: ${response.data}');
          } catch (e) {
            print('JSON parse hatası: $e');
          }
        } else if (response.data is Map) {
          print('Yanıt Map olarak alındı: ${response.data.keys}');
        }
      }

      print('Token doğrulama yanıtı: ${response.statusCode}');
      print('Yanıt içeriği: ${response.data}');
      
      if (response.statusCode == 200) {
        if (response.data is String) {
          final jsonData = json.decode(response.data);
          return InviteValidationResponse.fromJson(jsonData);
        } else if (response.data is Map) {
          return InviteValidationResponse.fromJson(Map<String, dynamic>.from(response.data));
        }
      }
      
      return null;
    } on DioException catch (e) {
      _handleDioError('Davet bağlantısını doğrulama', e);
      return null;
    } catch (e) {
      print('Beklenmeyen davet bağlantısını doğrulama hatası: $e');
      return null;
    }
  }

  /// Davet bağlantısı ile not getirme
  /// 
  /// [token] Davet bağlantısı token'ı
  Future<Note?> getNoteByInvite(String token) async {
    try {
      // Bu endpoint API dokümanında `GET /api/v1/notes/invite/{token}` olarak tanımlanmış,
      // bu nedenle doğru formatta kullanıyoruz
      
      // Özel headers ekleyelim, belki backend bu headers'ları bekliyor olabilir
      final Options options = Options(
        headers: {
          'X-Invite-Token': token,  // Özel bir header ekleyelim
          'Accept': 'application/json',
        },
      );
      
      print('Davet token ile not getirme isteği gönderiliyor. Token: $token');
      final response = await _apiService.get(
        '${ApiConfig.notesBase}/invite/$token',
        options: options,
      );

      print('Davet token ile not getirme yanıtı: ${response.statusCode}');
      print('Yanıt içeriği: ${response.data}');
      
      // Debug bilgisi - yanıtın yapısını gör
      if (response.data != null) {
        if (response.data is String) {
          try {
            print('Not yanıtı JSON parse edilmeye çalışılıyor');
          } catch (e) {
            print('JSON parse hatası: $e');
          }
        } else if (response.data is Map) {
          print('Not yanıtı Map olarak alındı: ${response.data.keys}');
        }
      }
      
      if (response.statusCode == 200) {
        if (response.data is String) {
          final jsonData = json.decode(response.data);
          return Note.fromJson(jsonData);
        } else if (response.data is Map) {
          return Note.fromJson(Map<String, dynamic>.from(response.data));
        }
      }
      
      return null;
    } on DioException catch (e) {
      _handleDioError('Davet bağlantısı ile not getirme', e);
      return null;
    } catch (e) {
      print('Beklenmeyen davet bağlantısı ile not getirme hatası: $e');
      return null;
    }
  }

  /// Davet bağlantısı ile PDF getirme
  /// 
  /// [token] Davet bağlantısı token'ı
  Future<PDF?> getPdfByInvite(String token) async {
    try {
      // Bu endpoint API dokümanında `GET /api/v1/pdfs/invite/{token}` olarak tanımlanmış,
      // bu nedenle doğru formatta kullanıyoruz
      
      // Özel headers ekleyelim, belki backend bu headers'ları bekliyor olabilir
      final Options options = Options(
        headers: {
          'X-Invite-Token': token,  // Özel bir header ekleyelim
          'Accept': 'application/json',
        },
      );
      
      print('Davet token ile PDF getirme isteği gönderiliyor. Token: $token');
      final response = await _apiService.get(
        '${ApiConfig.pdfsBase}/invite/$token',
        options: options,
      );

      print('Davet token ile PDF getirme yanıtı: ${response.statusCode}');
      print('Yanıt içeriği: ${response.data}');
      
      // Debug bilgisi - yanıtın yapısını gör
      if (response.data != null) {
        if (response.data is String) {
          try {
            print('PDF yanıtı JSON parse edilmeye çalışılıyor');
          } catch (e) {
            print('JSON parse hatası: $e');
          }
        } else if (response.data is Map) {
          print('PDF yanıtı Map olarak alındı: ${response.data.keys}');
        }
      }
      
      if (response.statusCode == 200) {
        if (response.data is String) {
          final jsonData = json.decode(response.data);
          return PDF.fromJson(jsonData);
        } else if (response.data is Map) {
          return PDF.fromJson(Map<String, dynamic>.from(response.data));
        }
      }
      
      return null;
    } on DioException catch (e) {
      _handleDioError('Davet bağlantısı ile PDF getirme', e);
      return null;
    } catch (e) {
      print('Beklenmeyen davet bağlantısı ile PDF getirme hatası: $e');
      return null;
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
