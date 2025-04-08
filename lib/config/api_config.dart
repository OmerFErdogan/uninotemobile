/// API yapılandırma sınıfı
/// API bağlantı bilgilerini merkezi olarak yönetir
class ApiConfig {
  // Ana API URL'si - farklı ortamlar için değiştirilebilir
  static const String baseUrl = 'http://localhost:8080/api/v1';
  
  // API zaman aşımı değerleri
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // API endpoint'leri
  static const String register = '/register';
  static const String login = '/login';
  static const String profile = '/profile';
  static const String changePassword = '/change-password';
  static const String notes = '/notes';
  static const String pdfs = '/pdfs';

  // Hata kodları ve mesajları
  static Map<int, String> errorMessages = {
    400: 'Geçersiz istek formatı veya parametreler',
    401: 'Kimlik doğrulama başarısız',
    403: 'Bu işlemi gerçekleştirmek için yetkiniz yok',
    404: 'İstenen kaynak bulunamadı',
    500: 'Sunucu hatası, lütfen daha sonra tekrar deneyin',
  };
  
  // Bağlantı hatası mesajları
  static const String connectionError = 'Sunucuya bağlanılamıyor. Lütfen internet bağlantınızı kontrol edin.';
  static const String timeoutError = 'İstek zaman aşımına uğradı. Lütfen daha sonra tekrar deneyin.';
  static const String serverError = 'Sunucu hatası. Lütfen daha sonra tekrar deneyin.';
  
  // Hata durumunda kullanıcıya gösterilecek mesajı döndürür
  static String getErrorMessage(int? statusCode, String? defaultMessage) {
    if (statusCode == null) {
      return defaultMessage ?? connectionError;
    }
    
    return errorMessages[statusCode] ?? defaultMessage ?? 'Bilinmeyen bir hata oluştu';
  }
}
