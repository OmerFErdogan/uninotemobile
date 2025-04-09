/// Form doğrulama yardımcıları
class Validators {
  /// Genel zorunlu alan doğrulama
  static String? requiredField(String? value) {
    if (value == null || value.isEmpty) {
      return 'Bu alan boş bırakılamaz';
    }
    return null;
  }

  /// E-posta doğrulama
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'E-posta alanı boş olamaz';
    }
    
    // Basit e-posta doğrulama regex'i
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Geçerli bir e-posta adresi giriniz';
    }
    
    return null;
  }

  /// Şifre doğrulama
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre alanı boş olamaz';
    }
    
    // Herhangi bir şifre kabul edilebilir
    return null;
  }

  /// Kullanıcı adı doğrulama
  static String? username(String? value) {
    if (value == null || value.isEmpty) {
      return 'Kullanıcı adı alanı boş olamaz';
    }
    
    if (value.length < 3) {
      return 'Kullanıcı adı en az 3 karakter olmalıdır';
    }
    
    return null;
  }

  /// Ad doğrulama
  static String? firstName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ad alanı boş olamaz';
    }
    
    return null;
  }

  /// Soyad doğrulama
  static String? lastName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Soyad alanı boş olamaz';
    }
    
    return null;
  }

  /// Üniversite doğrulama
  static String? university(String? value) {
    if (value == null || value.isEmpty) {
      return 'Üniversite alanı boş olamaz';
    }
    
    return null;
  }

  /// Bölüm doğrulama
  static String? department(String? value) {
    if (value == null || value.isEmpty) {
      return 'Bölüm alanı boş olamaz';
    }
    
    return null;
  }

  /// Sınıf doğrulama
  static String? classYear(String? value) {
    if (value == null || value.isEmpty) {
      return 'Sınıf alanı boş olamaz';
    }
    
    return null;
  }

  /// Şifre eşleşme doğrulama
  static String? Function(String?) passwordMatch(String password) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return 'Şifre tekrar alanı boş olamaz';
      }
      
      if (value != password) {
        return 'Şifreler eşleşmiyor';
      }
      
      return null;
    };
  }

  /// Eski şifre doğrulama
  static String? oldPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Eski şifre alanı boş olamaz';
    }
    
    return null;
  }

  /// Yeni şifre doğrulama
  static String? newPassword(String? value) {
    // Password validator'ı kullan
    return password(value);
  }
}
