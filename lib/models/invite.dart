import 'package:equatable/equatable.dart';

/// Davet bağlantısı modelini temsil eden sınıf
class Invite extends Equatable {
  final int? id;
  final int contentId;
  final String type;  // 'note' veya 'pdf'
  final String token;
  final DateTime expiresAt;
  final bool isActive;
  final DateTime createdAt;

  const Invite({
    this.id,
    required this.contentId,
    required this.type,
    required this.token,
    required this.expiresAt,
    required this.isActive,
    required this.createdAt,
  });

  /// JSON'dan Invite nesnesine dönüştürme
  factory Invite.fromJson(Map<String, dynamic> json) {
    return Invite(
      id: json['id'] as int?,
      contentId: json['contentId'] as int,
      type: json['type'] as String,
      token: json['token'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Invite nesnesinden JSON'a dönüştürme
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contentId': contentId,
      'type': type,
      'token': token,
      'expiresAt': expiresAt.toIso8601String(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    contentId,
    type,
    token,
    expiresAt,
    isActive,
    createdAt,
  ];

  /// Davet bağlantısının süresinin dolup dolmadığını kontrol eder
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Davet bağlantısının geçerli olup olmadığını kontrol eder
  bool get isValid => isActive && !isExpired;

  /// Davet bağlantısı için tam URL
  String getFullUrl(String baseUrl) {
    return '$baseUrl/${type}s/invite/$token';
  }
}

/// Davet bağlantısı oluşturmak için kullanılacak istek modeli
class CreateInviteRequest {
  final DateTime? expiresAt;

  CreateInviteRequest({
    this.expiresAt,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (expiresAt != null) {
      // expiresAt değerini RFC 3339 formatında string olarak gönder
      // Örnek: "2025-04-24T00:00:00Z"
      String formattedDate = expiresAt!.toUtc().toIso8601String();
      // Eğer Z ile bitmiyorsa, milisaniyeleri temizle ve Z ekle
      if (!formattedDate.endsWith('Z')) {
        formattedDate = '${formattedDate.split('.')[0]}Z';
      }
      data['expiresAt'] = formattedDate;
    }
    return data;
  }
}

/// Davet bağlantı doğrulama yanıtı
class InviteValidationResponse {
  final bool valid;
  final int? contentId;
  final String? type;
  final DateTime? expiresAt;

  InviteValidationResponse({
    required this.valid,
    this.contentId,
    this.type,
    this.expiresAt,
  });

  factory InviteValidationResponse.fromJson(Map<String, dynamic> json) {
    // API dökümantarına göre dönen yapı için alternatif alanlar kontrol edilir
    
    // Önce valid alanını kontrol et
    bool isValid = false;
    if (json.containsKey('valid')) {
      isValid = json['valid'] as bool;
    } else if (json.containsKey('isValid')) {
      isValid = json['isValid'] as bool;
    } else if (json.containsKey('isActive')) {
      // Eğer valid yoksa ama isActive varsa, onu kullan
      isValid = json['isActive'] as bool;
    }
    
    // Content ID'yi kontrol et
    int? cId;
    if (json.containsKey('contentId')) {
      cId = json['contentId'] as int?;
    } else if (json.containsKey('id')) {
      cId = json['id'] as int?;
    }
    
    // Type'i kontrol et
    String? contentType;
    if (json.containsKey('type')) {
      contentType = json['type'] as String?;
    } else if (json.containsKey('contentType')) {
      contentType = json['contentType'] as String?;
    }
    
    // ExpiresAt'i kontrol et
    DateTime? expires;
    if (json.containsKey('expiresAt')) {
      expires = json['expiresAt'] != null 
          ? DateTime.parse(json['expiresAt'] as String) 
          : null;
    }
    
    return InviteValidationResponse(
      valid: isValid,
      contentId: cId,
      type: contentType,
      expiresAt: expires,
    );
  }
}
