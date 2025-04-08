import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uninote/models/user.dart';
import 'package:uninote/services/api_service.dart';
import 'package:uninote/utils/model_adapter.dart';
import 'package:uninote/config/api_config.dart';

/// Kimlik doğrulama işlemlerini yöneten servis
class AuthService {
  final ApiService _apiService;
  final FlutterSecureStorage _secureStorage;
  
  // Token anahtarı için sabit
  static const String _tokenKey = 'auth_token';

  AuthService({
    required ApiService apiService,
    required FlutterSecureStorage secureStorage,
  })  : _apiService = apiService,
        _secureStorage = secureStorage;

  /// Kullanıcının giriş yapıp yapmadığını kontrol eder
  Future<bool> isLoggedIn() async {
    try {
      final token = await _secureStorage.read(key: _tokenKey);
      return token != null && token.isNotEmpty;
    } catch (e) {
      print('Giriş durumu kontrolünde hata: $e');
      return false;
    }
  }

  /// Token'i güvenli depodan almak için yardımcı metod
  Future<String?> getToken() async {
    try {
      return await _secureStorage.read(key: _tokenKey);
    } catch (e) {
      print('Token okuma hatası: $e');
      return null;
    }
  }

  /// Kullanıcı kaydı yapar
  /// 
  /// [registerRequest] Kayıt bilgilerini içeren nesne
  /// 
  /// Başarılı kayıt durumunda true, başarısız durumunda false döner
  Future<bool> register(RegisterRequest registerRequest) async {
    try {
      print('Kayıt isteği gönderiliyor: ${registerRequest.toJson()}');
      
      final response = await _apiService.post(
        ApiConfig.register,
        data: registerRequest.toJson(),
      );

      print('Kayıt yanıtı: ${response.statusCode}');
      print('Yanıt içeriği: ${response.data}');

      return response.statusCode == 201;
    } on DioException catch (e) {
      _handleDioError('Kayıt', e);
      return false;
    } catch (e) {
      print('Beklenmeyen kayıt hatası: $e');
      return false;
    }
  }

  /// Kullanıcı girişi yapar
  /// 
  /// [loginRequest] Giriş bilgilerini içeren nesne
  /// 
  /// Başarılı giriş durumunda token döner, başarısız durumunda null döner
  Future<String?> login(LoginRequest loginRequest) async {
    try {
      print('Login isteği gönderiliyor: ${loginRequest.toJson()}');
      final response = await _apiService.post(
        ApiConfig.login,
        data: loginRequest.toJson(),
      );

      print('Login yanıt alındı. Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final token = _extractTokenFromResponse(response.data);
        
        if (token != null) {
          await _secureStorage.write(key: _tokenKey, value: token);
          return token;
        }
      }
      
      return null;
    } on DioException catch (e) {
      _handleDioError('Giriş', e);
      return null;
    } catch (e) {
      print('Beklenmeyen giriş hatası: $e');
      return null;
    }
  }

  /// Kullanıcı çıkışı yapar
  Future<void> logout() async {
    try {
      await _secureStorage.delete(key: _tokenKey);
    } catch (e) {
      print('Çıkış yaparken hata: $e');
    }
  }

  /// Kullanıcı profil bilgilerini getirir
  Future<User?> getProfile() async {
    try {
      final response = await _apiService.get(ApiConfig.profile);

      if (response.statusCode == 200) {
        // Yanıt string ise önce JSON olarak parse et
        if (response.data is String) {
          try {
            final jsonData = json.decode(response.data);
            return User.fromJson(jsonData);
          } catch (e) {
            print('Profil JSON parse hatası: $e');
            return null;
          }
        } else if (response.data is Map) {
          return User.fromJson(Map<String, dynamic>.from(response.data));
        }
      }
      return null;
    } on DioException catch (e) {
      _handleDioError('Profil getirme', e);
      return null;
    } catch (e) {
      print('Beklenmeyen profil getirme hatası: $e');
      return null;
    }
  }

  /// Kullanıcı profil bilgilerini günceller
  /// 
  /// [updateProfileRequest] Güncellenecek profil bilgilerini içeren nesne
  /// 
  /// Başarılı güncelleme durumunda true, başarısız durumunda false döner
  Future<bool> updateProfile(UpdateProfileRequest updateProfileRequest) async {
    try {
      final response = await _apiService.put(
        ApiConfig.profile,
        data: updateProfileRequest.toJson(),
      );

      return response.statusCode == 200;
    } on DioException catch (e) {
      _handleDioError('Profil güncelleme', e);
      return false;
    } catch (e) {
      print('Beklenmeyen profil güncelleme hatası: $e');
      return false;
    }
  }

  /// Kullanıcı şifresini değiştirir
  /// 
  /// [changePasswordRequest] Şifre değiştirme bilgilerini içeren nesne
  /// 
  /// Başarılı şifre değiştirme durumunda true, başarısız durumunda false döner
  Future<bool> changePassword(ChangePasswordRequest changePasswordRequest) async {
    try {
      final response = await _apiService.post(
        ApiConfig.changePassword,
        data: changePasswordRequest.toJson(),
      );

      return response.statusCode == 200;
    } on DioException catch (e) {
      _handleDioError('Şifre değiştirme', e);
      return false;
    } catch (e) {
      print('Beklenmeyen şifre değiştirme hatası: $e');
      return false;
    }
  }

  /// Sistemin API'ye bağlanabilirliğini kontrol eder
  Future<bool> checkConnection() async {
    try {
      final response = await _apiService.get('/ping');
      return response.statusCode == 200;
    } catch (e) {
      print('Bağlantı kontrolü hatası: $e');
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

  /// API yanıtından token'i çıkarmak için yardımcı metod
  String? _extractTokenFromResponse(dynamic data) {
    try {
      print('Yanıt veri tipi: ${data.runtimeType}');
      print('Yanıt içeriği: $data');
      
      // ModelAdapter'ı kullanarak token'i çıkar
      final token = ModelAdapter.extractToken(data);
      
      if (token != null) {
        print('Token başarıyla çıkarıldı: $token');
        return token;
      }
      
      // Eğer data bir string ise
      if (data is String) {
        // JSON olup olmadığını kontrol et
        if (data.trim().startsWith('{')) {
          try {
            final jsonData = json.decode(data);
            if (jsonData is Map && jsonData.containsKey('token')) {
              return jsonData['token'].toString();
            }
          } catch (e) {
            print('JSON parse hatası: $e');
          }
        } 
        // Direk token olabilir
        else if (data.startsWith('eyJ') || data.startsWith('Bearer ')) {
          return data.startsWith('Bearer ') ? data.substring(7) : data;
        }
        
        // Son çare: string token olarak kabul et
        return data;
      }
      
      // Eğer data bir map ise
      if (data is Map) {
        // Direkt token anahtarı kontrolü
        if (data.containsKey('token')) {
          return data['token'].toString();
        }
        
        // Nested token kontrolü
        for (final key in ['data', 'auth', 'result', 'user']) {
          if (data.containsKey(key) && data[key] is Map) {
            final innerMap = data[key] as Map;
            if (innerMap.containsKey('token')) {
              return innerMap['token'].toString();
            }
          }
        }
        
        // Alternatif token anahtarı kontrolü
        if (data.containsKey('access_token')) {
          return data['access_token'].toString();
        }
      }
      
      print('Token bulunamadı');
      return null;
    } catch (e) {
      print('Token çıkarma hatası: $e');
      return null;
    }
  }
}
