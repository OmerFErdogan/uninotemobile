import 'dart:convert';

/// API yanıtlarını uygun model tipine dönüştürmek için yardımcı sınıf
class ModelAdapter {
  /// Herhangi bir veriyi güvenli bir şekilde Map<String, dynamic> tipine dönüştürür
  /// Eğer veri zaten Map tipindeyse, olduğu gibi döndürür
  /// Değilse, boş bir Map döndürür
  static Map<String, dynamic> toMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    } else if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return {};
  }

  /// Herhangi bir veriyi güvenli bir şekilde List tipine dönüştürür
  /// Eğer veri zaten List tipindeyse, olduğu gibi döndürür
  /// Değilse, boş bir List döndürür
  static List<T> toList<T>(dynamic data, T Function(dynamic) fromJson) {
    if (data is List) {
      return data.map((item) => fromJson(item)).toList();
    }
    return [];
  }

  /// Herhangi bir veriyi güvenli bir şekilde String tipine dönüştürür
  /// Null değer için boş string döner
  static String toStr(dynamic value) {
    if (value == null) {
      return '';
    }
    return value.toString();
  }

  /// Herhangi bir veriyi güvenli bir şekilde int tipine dönüştürür
  /// Dönüştürülemezse, defaultValue değerini (varsayılan: 0) döndürür
  static int toInt(dynamic value, {int defaultValue = 0}) {
    if (value is int) {
      return value;
    }
    if (value is String) {
      return int.tryParse(value) ?? defaultValue;
    }
    if (value is double) {
      return value.toInt();
    }
    return defaultValue;
  }

  /// Herhangi bir veriyi güvenli bir şekilde double tipine dönüştürür
  /// Dönüştürülemezse, defaultValue değerini (varsayılan: 0.0) döndürür
  static double toDouble(dynamic value, {double defaultValue = 0.0}) {
    if (value is double) {
      return value;
    }
    if (value is int) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? defaultValue;
    }
    return defaultValue;
  }

  /// Herhangi bir veriyi güvenli bir şekilde bool tipine dönüştürür
  /// Dönüştürülemezse, defaultValue değerini (varsayılan: false) döndürür
  static bool toBool(dynamic value, {bool defaultValue = false}) {
    if (value is bool) {
      return value;
    }
    if (value is String) {
      return value.toLowerCase() == 'true';
    }
    if (value is int) {
      return value == 1;
    }
    return defaultValue;
  }

  /// API yanıtından token değerini güvenli bir şekilde çıkarır
  /// Birçok farklı API yanıt formatını destekler
  static String? extractToken(dynamic response) {
    try {
      print('Token çıkarılıyor, yanıt: $response');
      print('Yanıt tipi: ${response.runtimeType}');
      
      // Eğer yanıt bir String ise ve JSON içeriyorsa, önce JSON olarak parse et
      if (response is String && response.trim().startsWith('{')) {
        try {
          // JSON'u çözümlemeye çalış
          Map<String, dynamic> jsonResponse = json.decode(response);
          print('JSON olarak parse edildi: $jsonResponse');
          response = jsonResponse; // response'u JSON olarak ayarla
        } catch (e) {
          print('JSON parse hatası: $e');
          // Sorun varsa orijinal string'e devam et
        }
      }
      
      // Direkt token olarak string
      if (response is String) {
        if (response.startsWith('eyJ') || response.startsWith('Bearer ')) {
          return response.startsWith('Bearer ') ? response.substring(7) : response;
        }
        return response;
      }
      
      // Map içinde token anahtarı
      if (response is Map) {
        print('Map alan anahtar listesi: ${response.keys.toList()}');
        
        // Durum 1: { "token": "..." }
        if (response.containsKey('token')) {
          var token = response['token'];
          print('Token bulundu: $token');
          if (token is String) {
            return token;
          }
          return token?.toString();
        }
        
        // Durum 2: { "data": { "token": "..." } }
        if (response.containsKey('data')) {
          var data = response['data'];
          if (data is Map && data.containsKey('token')) {
            return data['token'].toString();
          }
        }
        
        // Durum 3: { "auth": { "token": "..." } }
        if (response.containsKey('auth')) {
          var auth = response['auth'];
          if (auth is Map && auth.containsKey('token')) {
            return auth['token'].toString();
          }
        }
        
        // Durum 4: { "result": { "token": "..." } }
        if (response.containsKey('result')) {
          var result = response['result'];
          if (result is Map && result.containsKey('token')) {
            return result['token'].toString();
          }
        }

        // Durum 5: { "access_token": "..." } 
        if (response.containsKey('access_token')) {
          return response['access_token'].toString();
        }
      }
      
      // Token bulunamadı
      return null;
    } catch (e) {
      print('Token çıkarılırken hata: $e');
      return null;
    }
  }
}
