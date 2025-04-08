import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uninote/models/note.dart';
import 'package:uninote/services/api_service.dart';
import 'package:uninote/utils/model_adapter.dart';

/// Not işlemlerini yöneten servis
class NoteService {
  final ApiService _apiService;
  final FlutterSecureStorage _secureStorage;

  NoteService({
    required ApiService apiService,
    FlutterSecureStorage? secureStorage,
  }) : _apiService = apiService,
       _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// Not oluşturur
  /// 
  /// [request] Not oluşturma bilgilerini içeren nesne
  /// 
  /// Başarılı olursa oluşturulan notu, başarısız olursa null döner
  Future<Note?> createNote(CreateNoteRequest request) async {
    try {
      print('Not oluşturma isteği gönderiliyor: ${request.toJson()}');
      
      // Önce token'in doğru şekilde ayarlandığından emin ol
      final token = await _checkAndFixToken();
      if (token == null) {
        print('Geçerli token bulunamadı. İşlem yapılamaz.');
        return null;
      }
      
      final response = await _apiService.post(
        '/notes',
        data: request.toJson(),
      );

      print('Not oluşturma yanıtı: ${response.statusCode}');
      print('Yanıt içeriği: ${response.data}');

      if (response.statusCode == 201) {
        return _parseNoteResponse(response.data);
      }
      return null;
    } on DioException catch (e) {
      print('Not oluşturma hatası: ${e.message}');
      print('Durum kodu: ${e.response?.statusCode}');
      print('Sunucu hata mesajı: ${e.response?.data}');
      
      // Yetkilendirme hatası (401) ise token'i temizle ve null dön
      if (e.response?.statusCode == 401) {
        await _handleAuthorizationError();
      }
      
      return null;
    }
  }

  /// Not günceller
  /// 
  /// [id] Güncellenecek notun ID'si
  /// [request] Not güncelleme bilgilerini içeren nesne
  /// 
  /// Başarılı olursa güncellenen notu, başarısız olursa null döner
  Future<Note?> updateNote(int id, UpdateNoteRequest request) async {
    try {
      final response = await _apiService.put(
        '/notes/$id',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        return _parseNoteResponse(response.data);
      }
      return null;
    } on DioException catch (e) {
      print('Not güncelleme hatası: ${e.message}');
      print('Durum kodu: ${e.response?.statusCode}');
      print('Sunucu hata mesajı: ${e.response?.data}');
      return null;
    }
  }

  /// Not siler
  /// 
  /// [id] Silinecek notun ID'si
  /// 
  /// Başarılı olursa true, başarısız olursa false döner
  Future<bool> deleteNote(int id) async {
    try {
      final response = await _apiService.delete('/notes/$id');

      return response.statusCode == 200;
    } on DioException catch (e) {
      print('Not silme hatası: ${e.message}');
      print('Durum kodu: ${e.response?.statusCode}');
      print('Sunucu hata mesajı: ${e.response?.data}');
      return false;
    }
  }

  /// Not detaylarını getirir
  /// 
  /// [id] Getirilecek notun ID'si
  /// 
  /// Başarılı olursa notu, başarısız olursa null döner
  Future<Note?> getNote(int id) async {
    try {
      final response = await _apiService.get('/notes/$id');

      if (response.statusCode == 200) {
        return _parseNoteResponse(response.data);
      }
      return null;
    } on DioException catch (e) {
      print('Not getirme hatası: ${e.message}');
      print('Durum kodu: ${e.response?.statusCode}');
      print('Sunucu hata mesajı: ${e.response?.data}');
      return null;
    }
  }

  /// Kullanıcının notlarını getirir
  /// 
  /// [limit] Sayfalama için limit (varsayılan: 10)
  /// [offset] Sayfalama için offset (varsayılan: 0)
  /// 
  /// Başarılı olursa notları, başarısız olursa boş liste döner
  Future<List<Note>> getUserNotes({int limit = 10, int offset = 0}) async {
    try {
      final response = await _apiService.get(
        '/notes/my',
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );

      if (response.statusCode == 200) {
        // Yanıt string ise önce JSON olarak parse et
        if (response.data is String) {
          try {
            // String yanıt null olabilir
            if (response.data == "null" || response.data == "null\n") {
              return [];
            }
            
            final jsonData = json.decode(response.data);
            if (jsonData is List) {
              return jsonData.map((item) => Note.fromJson(item)).toList();
            } else {
              print('Beklenmeyen JSON formatı: $jsonData');
              return [];
            }
          } catch (e) {
            print('JSON parse hatası: $e');
            return [];
          }
        } else if (response.data is List) {
          return (response.data as List)
              .map((item) => Note.fromJson(item))
              .toList();
        } else if (response.data == null) {
          return [];
        }
      }
      print('Notlar için beklenmeyen yanıt formatı: ${response.data?.runtimeType}');
      return [];
    } on DioException catch (e) {
      print('Kullanıcı notları getirme hatası: ${e.message}');
      print('Durum kodu: ${e.response?.statusCode}');
      print('Sunucu hata mesajı: ${e.response?.data}');
      return [];
    } catch (e) {
      print('Notları yükleme hatası: $e');
      return [];
    }
  }

  /// Herkese açık notları getirir
  /// 
  /// [limit] Sayfalama için limit (varsayılan: 10)
  /// [offset] Sayfalama için offset (varsayılan: 0)
  /// 
  /// Başarılı olursa notları, başarısız olursa boş liste döner
  Future<List<Note>> getPublicNotes({int limit = 10, int offset = 0}) async {
    try {
      final response = await _apiService.get(
        '/notes',
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );

      if (response.statusCode == 200) {
        // Yanıt string ise önce JSON olarak parse et
        if (response.data is String) {
          try {
            // String yanıt null olabilir
            if (response.data == "null" || response.data == "null\n") {
              return [];
            }
            
            final jsonData = json.decode(response.data);
            if (jsonData is List) {
              return jsonData.map((item) => Note.fromJson(item)).toList();
            } else {
              print('Beklenmeyen JSON formatı: $jsonData');
              return [];
            }
          } catch (e) {
            print('JSON parse hatası: $e');
            return [];
          }
        } else if (response.data is List) {
          return (response.data as List)
              .map((item) => Note.fromJson(item))
              .toList();
        } else if (response.data == null) {
          return [];
        }
      }
      return [];
    } on DioException catch (e) {
      print('Herkese açık notları getirme hatası: ${e.message}');
      print('Durum kodu: ${e.response?.statusCode}');
      print('Sunucu hata mesajı: ${e.response?.data}');
      return [];
    } catch (e) {
      print('Notları yükleme hatası: $e');
      return [];
    }
  }

  /// Notları arar
  /// 
  /// [query] Arama sorgusu
  /// [limit] Sayfalama için limit (varsayılan: 10)
  /// [offset] Sayfalama için offset (varsayılan: 0)
  /// 
  /// Başarılı olursa notları, başarısız olursa boş liste döner
  Future<List<Note>> searchNotes(String query, {int limit = 10, int offset = 0}) async {
    try {
      final response = await _apiService.get(
        '/notes/search',
        queryParameters: {
          'q': query,
          'limit': limit,
          'offset': offset,
        },
      );

      if (response.statusCode == 200) {
        // Yanıt string ise önce JSON olarak parse et
        if (response.data is String) {
          try {
            // String yanıt null olabilir
            if (response.data == "null" || response.data == "null\n") {
              return [];
            }
            
            final jsonData = json.decode(response.data);
            if (jsonData is List) {
              return jsonData.map((item) => Note.fromJson(item)).toList();
            } else {
              print('Beklenmeyen JSON formatı: $jsonData');
              return [];
            }
          } catch (e) {
            print('JSON parse hatası: $e');
            return [];
          }
        } else if (response.data is List) {
          return (response.data as List)
              .map((item) => Note.fromJson(item))
              .toList();
        } else if (response.data == null) {
          return [];
        }
      }
      return [];
    } on DioException catch (e) {
      print('Not arama hatası: ${e.message}');
      print('Durum kodu: ${e.response?.statusCode}');
      print('Sunucu hata mesajı: ${e.response?.data}');
      return [];
    } catch (e) {
      print('Notları yükleme hatası: $e');
      return [];
    }
  }

  /// Etikete göre notları getirir
  /// 
  /// [tag] Etiket
  /// [limit] Sayfalama için limit (varsayılan: 10)
  /// [offset] Sayfalama için offset (varsayılan: 0)
  /// 
  /// Başarılı olursa notları, başarısız olursa boş liste döner
  Future<List<Note>> getNotesByTag(String tag, {int limit = 10, int offset = 0}) async {
    try {
      final response = await _apiService.get(
        '/notes/tag/$tag',
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );

      if (response.statusCode == 200) {
        // Yanıt string ise önce JSON olarak parse et
        if (response.data is String) {
          try {
            // String yanıt null olabilir
            if (response.data == "null" || response.data == "null\n") {
              return [];
            }
            
            final jsonData = json.decode(response.data);
            if (jsonData is List) {
              return jsonData.map((item) => Note.fromJson(item)).toList();
            } else {
              print('Beklenmeyen JSON formatı: $jsonData');
              return [];
            }
          } catch (e) {
            print('JSON parse hatası: $e');
            return [];
          }
        } else if (response.data is List) {
          return (response.data as List)
              .map((item) => Note.fromJson(item))
              .toList();
        } else if (response.data == null) {
          return [];
        }
      }
      return [];
    } on DioException catch (e) {
      print('Etikete göre not getirme hatası: ${e.message}');
      print('Durum kodu: ${e.response?.statusCode}');
      print('Sunucu hata mesajı: ${e.response?.data}');
      return [];
    } catch (e) {
      print('Notları yükleme hatası: $e');
      return [];
    }
  }

  /// Nota yorum ekler
  /// 
  /// [noteId] Yorum eklenecek notun ID'si
  /// [request] Yorum ekleme bilgilerini içeren nesne
  /// 
  /// Başarılı olursa eklenen yorumu, başarısız olursa null döner
  Future<NoteComment?> addComment(int noteId, CreateNoteCommentRequest request) async {
    try {
      final response = await _apiService.post(
        '/notes/$noteId/comments',
        data: request.toJson(),
      );

      if (response.statusCode == 201) {
        return _parseNoteCommentResponse(response.data);
      }
      return null;
    } on DioException catch (e) {
      print('Not yorumu ekleme hatası: ${e.message}');
      print('Durum kodu: ${e.response?.statusCode}');
      print('Sunucu hata mesajı: ${e.response?.data}');
      return null;
    }
  }

  /// Notun yorumlarını getirir
  /// 
  /// [noteId] Yorumları getirilecek notun ID'si
  /// [limit] Sayfalama için limit (varsayılan: 10)
  /// [offset] Sayfalama için offset (varsayılan: 0)
  /// 
  /// Başarılı olursa yorumları, başarısız olursa boş liste döner
  Future<List<NoteComment>> getComments(int noteId, {int limit = 10, int offset = 0}) async {
    try {
      final response = await _apiService.get(
        '/notes/$noteId/comments',
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );

      if (response.statusCode == 200) {
        // Yanıt string ise önce JSON olarak parse et
        if (response.data is String) {
          try {
            // String yanıt null olabilir
            if (response.data == "null" || response.data == "null\n") {
              return [];
            }
            
            final jsonData = json.decode(response.data);
            if (jsonData is List) {
              return jsonData.map((item) => NoteComment.fromJson(item)).toList();
            } else {
              print('Beklenmeyen JSON formatı: $jsonData');
              return [];
            }
          } catch (e) {
            print('JSON parse hatası: $e');
            return [];
          }
        } else if (response.data is List) {
          return (response.data as List)
              .map((item) => NoteComment.fromJson(item))
              .toList();
        } else if (response.data == null) {
          return [];
        }
      }
      return [];
    } on DioException catch (e) {
      print('Not yorumlarını getirme hatası: ${e.message}');
      print('Durum kodu: ${e.response?.statusCode}');
      print('Sunucu hata mesajı: ${e.response?.data}');
      return [];
    } catch (e) {
      print('Yorumları yükleme hatası: $e');
      return [];
    }
  }

  /// Notu beğenir
  /// 
  /// [noteId] Beğenilecek notun ID'si
  /// 
  /// Başarılı olursa true, başarısız olursa false döner
  Future<bool> likeNote(int noteId) async {
    try {
      final response = await _apiService.post('/notes/$noteId/like');

      return response.statusCode == 200;
    } on DioException catch (e) {
      print('Not beğenme hatası: ${e.message}');
      print('Durum kodu: ${e.response?.statusCode}');
      print('Sunucu hata mesajı: ${e.response?.data}');
      return false;
    }
  }

  /// Not beğenisini kaldırır
  /// 
  /// [noteId] Beğenisi kaldırılacak notun ID'si
  /// 
  /// Başarılı olursa true, başarısız olursa false döner
  Future<bool> unlikeNote(int noteId) async {
    try {
      final response = await _apiService.delete('/notes/$noteId/like');

      return response.statusCode == 200;
    } on DioException catch (e) {
      print('Not beğenisini kaldırma hatası: ${e.message}');
      print('Durum kodu: ${e.response?.statusCode}');
      print('Sunucu hata mesajı: ${e.response?.data}');
      return false;
    }
  }

  /// Beğenilen notları getirir
  /// 
  /// [limit] Sayfalama için limit (varsayılan: 10)
  /// [offset] Sayfalama için offset (varsayılan: 0)
  /// 
  /// Başarılı olursa notları, başarısız olursa boş liste döner
  Future<List<Note>> getLikedNotes({int limit = 10, int offset = 0}) async {
    try {
      final response = await _apiService.get(
        '/notes/liked',
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );

      if (response.statusCode == 200) {
        // Yanıt string ise önce JSON olarak parse et
        if (response.data is String) {
          try {
            // String yanıt null olabilir
            if (response.data == "null" || response.data == "null\n") {
              return [];
            }
            
            final jsonData = json.decode(response.data);
            if (jsonData is List) {
              return jsonData.map((item) => Note.fromJson(item)).toList();
            } else {
              print('Beklenmeyen JSON formatı: $jsonData');
              return [];
            }
          } catch (e) {
            print('JSON parse hatası: $e');
            return [];
          }
        } else if (response.data is List) {
          return (response.data as List)
              .map((item) => Note.fromJson(item))
              .toList();
        } else if (response.data == null) {
          return [];
        }
      }
      return [];
    } on DioException catch (e) {
      print('Beğenilen notları getirme hatası: ${e.message}');
      print('Durum kodu: ${e.response?.statusCode}');
      print('Sunucu hata mesajı: ${e.response?.data}');
      return [];
    } catch (e) {
      print('Notları yükleme hatası: $e');
      return [];
    }
  }

  /// Not için davet bağlantısı oluşturur
  /// 
  /// [noteId] Davet bağlantısı oluşturulacak notun ID'si
  /// [expiresAt] Davet bağlantısının geçerlilik süresi (isteğe bağlı)
  /// 
  /// Başarılı olursa davet bağlantısını, başarısız olursa null döner
  Future<Map<String, dynamic>?> createInvite(int noteId, {DateTime? expiresAt}) async {
    try {
      final Map<String, dynamic> data = {};
      if (expiresAt != null) {
        data['expiresAt'] = expiresAt.toIso8601String();
      }

      final response = await _apiService.post(
        '/notes/$noteId/invites',
        data: data,
      );

      if (response.statusCode == 201) {
        // Yanıt string ise önce JSON olarak parse et
        if (response.data is String) {
          try {
            return json.decode(response.data);
          } catch (e) {
            print('JSON parse hatası: $e');
            return null;
          }
        } else if (response.data is Map) {
          return Map<String, dynamic>.from(response.data);
        }
      }
      return null;
    } on DioException catch (e) {
      print('Not davet bağlantısı oluşturma hatası: ${e.message}');
      print('Durum kodu: ${e.response?.statusCode}');
      print('Sunucu hata mesajı: ${e.response?.data}');
      return null;
    }
  }

  /// Not görüntüleme kaydı oluşturur (isteğe bağlı)
  /// 
  /// [noteId] Görüntülenecek notun ID'si
  /// 
  /// Başarılı olursa true, başarısız olursa false döner
  Future<bool> viewNote(int noteId) async {
    try {
      final response = await _apiService.get('/notes/$noteId/view');

      return response.statusCode == 200;
    } on DioException catch (e) {
      print('Not görüntüleme hatası: ${e.message}');
      print('Durum kodu: ${e.response?.statusCode}');
      print('Sunucu hata mesajı: ${e.response?.data}');
      return false;
    }
  }

  /// Note yanıtını parse eder
  Note? _parseNoteResponse(dynamic data) {
    try {
      // Eğer veri bir string ise, JSON olarak parse et
      if (data is String) {
        try {
          data = json.decode(data);
        } catch (e) {
          print('JSON parse hatası: $e');
          return null;
        }
      }
      
      if (data is Map) {
        return Note.fromJson(Map<String, dynamic>.from(data));
      }
      
      print('Beklenmeyen veri formatı: ${data.runtimeType}');
      return null;
    } catch (e) {
      print('Not parse hatası: $e');
      return null;
    }
  }
  
  /// NoteComment yanıtını parse eder
  NoteComment? _parseNoteCommentResponse(dynamic data) {
    try {
      // Eğer veri bir string ise, JSON olarak parse et
      if (data is String) {
        try {
          data = json.decode(data);
        } catch (e) {
          print('JSON parse hatası: $e');
          return null;
        }
      }
      
      if (data is Map) {
        return NoteComment.fromJson(Map<String, dynamic>.from(data));
      }
      
      print('Beklenmeyen veri formatı: ${data.runtimeType}');
      return null;
    } catch (e) {
      print('Yorum parse hatası: $e');
      return null;
    }
  }
  
  /// Token'in geçerli olup olmadığını kontrol eder ve gerekirse token'ı düzeltir
  Future<String?> _checkAndFixToken() async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      print('Mevcut token: $token');
      
      if (token == null || token.isEmpty) {
        print('Token bulunamadı');
        return null;
      }
      
      // Token bir JSON string mi?
      if (token.startsWith('{') && token.contains('"token"')) {
        try {
          final tokenData = json.decode(token);
          if (tokenData is Map && tokenData.containsKey('token')) {
            final actualToken = tokenData['token'].toString();
            print('Token JSON içinden düzeltildi: $actualToken');
            await _secureStorage.write(key: 'auth_token', value: actualToken);
            return actualToken;
          }
        } catch (e) {
          print('Token JSON parse hatası: $e');
        }
      }
      
      return token;
    } catch (e) {
      print('Token kontrol hatası: $e');
      return null;
    }
  }
  
  /// Yetkilendirme hatası durumunda token'ı temizler
  Future<void> _handleAuthorizationError() async {
    print('Yetkilendirme hatası, token temizleniyor');
    await _secureStorage.delete(key: 'auth_token');
  }
}
