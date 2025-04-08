import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uninote/config/api_config.dart';

/// API ile iletişim kurmak için kullanılan servis
class ApiService {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;
  
  // ApiConfig'den base URL'i al
  final String _baseUrl = ApiConfig.baseUrl;

  ApiService({
    required Dio dio,
    required FlutterSecureStorage secureStorage,
  })  : _dio = dio,
        _secureStorage = secureStorage {
    _setupDio();
  }

  /// Dio istemcisini yapılandırır
  void _setupDio() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.connectTimeout = ApiConfig.connectTimeout; // ApiConfig'den al
    _dio.options.receiveTimeout = ApiConfig.receiveTimeout; // ApiConfig'den al
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    // Hata ayıklama için interceptor ekle
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
      logPrint: (obj) => print('DIO LOG: $obj'), // Daha açık ayrıntılar
    ));

    // JSON yanıtları otomatik olarak işlemek için interceptor ekle
    _dio.interceptors.add(
      InterceptorsWrapper(
        onResponse: (response, handler) {
          // Eğer yanıt string ve JSON formatındaysa, otomatik olarak parse et
          if (response.data is String && 
              (response.data.toString().trim().startsWith('{') || 
              response.data.toString().trim().startsWith('['))) {
            try {
              response.data = json.decode(response.data);
            } catch (e) {
              print('Otomatik JSON parse hatası: $e');
            }
          }
          return handler.next(response);
        },
      ),
    );

    // Kimlik doğrulama interceptor'ı ekle
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Güvenli depolamadan token'ı al
          final token = await _secureStorage.read(key: 'auth_token');
          print('API isteği gönderiliyor: ${options.uri}');
          print('Authorization token: $token');
          
          if (token != null && token.isNotEmpty) {
            // Token JWT formatında mı kontrol et (JWT genellikle "eyJ" ile başlar)
            if (token.startsWith('eyJ')) {
              options.headers['Authorization'] = 'Bearer $token';
              print('Bearer token eklendi');
            } else if (token.contains('"token"')) {
              // Token bir JSON string olabilir, JSON içinden çıkar
              try {
                final tokenData = json.decode(token);
                if (tokenData is Map && tokenData.containsKey('token')) {
                  final actualToken = tokenData['token'].toString();
                  options.headers['Authorization'] = 'Bearer $actualToken';
                  print('JSON içinden çıkarılan Bearer token eklendi');
                }
              } catch (e) {
                print('Token JSON parse hatası: $e, ham token kullanılıyor');
                options.headers['Authorization'] = 'Bearer $token';
              }
            } else {
              options.headers['Authorization'] = 'Bearer $token';
              print('Bilinmeyen formatta token eklendi');
            }
          } else {
            print('Token bulunamadı, Authorization header kullanılmayacak');
          }
          
          return handler.next(options);
        },
        onError: (DioException error, handler) {
          // 401 Unauthorized hatası durumunda token'ı temizle
          if (error.response?.statusCode == 401) {
            _secureStorage.delete(key: 'auth_token');
            // Burada oturum sona erdi bildirimi yapılabilir
          }
          return handler.next(error);
        },
      ),
    );
  }

  /// Yanıtı işleyip daha güvenli hale getiren yardımcı metod
  dynamic _processResponse(Response response) {
    if (response.data is String && response.data != null) {
      // String yanıt içine bakalım, JSON mı?
      if (response.data.toString().trim().startsWith('{') || 
          response.data.toString().trim().startsWith('[')) {
        try {
          return json.decode(response.data);
        } catch (e) {
          print('JSON parse hatası: $e, orijinal string döndürülüyor');
          return response.data;
        }
      }
    }
    return response.data;
  }

  /// GET isteği gönderir
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      
      // Yanıtı işle ve güvenli hale getir
      response.data = _processResponse(response);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// POST isteği gönderir
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      
      // Yanıtı işle ve güvenli hale getir
      response.data = _processResponse(response);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// PUT isteği gönderir
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      
      // Yanıtı işle ve güvenli hale getir
      response.data = _processResponse(response);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// DELETE isteği gönderir
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      
      // Yanıtı işle ve güvenli hale getir
      response.data = _processResponse(response);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
