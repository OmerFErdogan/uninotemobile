import 'package:equatable/equatable.dart';

/// İçerik görüntüleme kaydı modelini temsil eden sınıf
class ContentView extends Equatable {
  final int? id;
  final int? userId;
  final String? username;
  final String? firstName;
  final String? lastName;
  final int contentId;
  final String type; // 'note' veya 'pdf'
  final DateTime viewedAt;

  const ContentView({
    this.id,
    this.userId,
    this.username,
    this.firstName,
    this.lastName,
    required this.contentId,
    required this.type,
    required this.viewedAt,
  });

  /// JSON'dan ContentView nesnesine dönüştürme
  factory ContentView.fromJson(Map<String, dynamic> json) {
    return ContentView(
      id: json['id'] as int?,
      userId: json['userId'] as int?,
      username: json['username'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      contentId: json['contentId'] as int,
      type: json['type'] as String,
      viewedAt: DateTime.parse(json['viewedAt'] as String),
    );
  }

  /// ContentView nesnesinden JSON'a dönüştürme
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'contentId': contentId,
      'type': type,
      'viewedAt': viewedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    username,
    firstName,
    lastName,
    contentId,
    type,
    viewedAt,
  ];

  /// Kullanıcının tam adını döndürür
  String? get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return null;
  }
}

/// Görüntüleme kontrolü yanıtı
class ViewCheckResponse {
  final bool viewed;

  ViewCheckResponse({
    required this.viewed,
  });

  factory ViewCheckResponse.fromJson(Map<String, dynamic> json) {
    return ViewCheckResponse(
      viewed: json['viewed'] as bool,
    );
  }
}

/// Görüntüleme listesi yanıtı
class ViewListResponse {
  final List<ContentView> views;
  final Map<String, dynamic> pagination;

  ViewListResponse({
    required this.views,
    required this.pagination,
  });

  factory ViewListResponse.fromJson(Map<String, dynamic> json) {
    return ViewListResponse(
      views: (json['views'] as List)
          .map((item) => ContentView.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      pagination: Map<String, dynamic>.from(json['pagination']),
    );
  }
}
