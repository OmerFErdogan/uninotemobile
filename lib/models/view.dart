import 'package:equatable/equatable.dart';

/// İçerik görüntüleme kaydını temsil eden sınıf
class View extends Equatable {
  final int? id;
  final int? userId;
  final String? username;
  final String? firstName;
  final String? lastName;
  final int contentId;
  final String type; // 'note' veya 'pdf'
  final DateTime viewedAt;

  const View({
    this.id,
    this.userId,
    this.username,
    this.firstName,
    this.lastName,
    required this.contentId,
    required this.type,
    required this.viewedAt,
  });

  /// JSON'dan View nesnesine dönüştürme
  factory View.fromJson(Map<String, dynamic> json) {
    return View(
      id: json['id'] as int?,
      userId: json['userId'] as int?,
      username: json['username'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      contentId: json['contentId'] as int,
      type: json['type'] as String,
      viewedAt: json['viewedAt'] != null
          ? DateTime.parse(json['viewedAt'] as String)
          : DateTime.now(),
    );
  }

  /// View nesnesinden JSON'a dönüştürme
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
      
  /// Görüntüleyen kullanıcının tam adını döndürür
  String? get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (firstName != null) {
      return firstName;
    } else if (lastName != null) {
      return lastName;
    }
    return username;
  }
}

/// Görüntüleme listesi yanıtını temsil eden sınıf
class ViewsResponse {
  final List<View> views;
  final Pagination pagination;

  ViewsResponse({
    required this.views,
    required this.pagination,
  });

  factory ViewsResponse.fromJson(Map<String, dynamic> json) {
    return ViewsResponse(
      views: (json['views'] as List)
          .map((view) => View.fromJson(view as Map<String, dynamic>))
          .toList(),
      pagination: Pagination.fromJson(json['pagination'] as Map<String, dynamic>),
    );
  }
}

/// Sayfalama bilgilerini temsil eden sınıf
class Pagination {
  final int limit;
  final int offset;

  Pagination({
    required this.limit,
    required this.offset,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      limit: json['limit'] as int,
      offset: json['offset'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'limit': limit,
      'offset': offset,
    };
  }
}

/// Görüntüleme durumu kontrolü yanıtını temsil eden sınıf
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