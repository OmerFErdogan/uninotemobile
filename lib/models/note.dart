import 'package:equatable/equatable.dart';

/// Not modelini temsil eden sınıf
class Note extends Equatable {
  final int? id;
  final String title;
  final String content;
  final int? userId;
  final List<String> tags;
  final bool isPublic;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? likeCount;
  final int? commentCount;
  final int? viewCount;

  const Note({
    this.id,
    required this.title,
    required this.content,
    this.userId,
    required this.tags,
    required this.isPublic,
    this.createdAt,
    this.updatedAt,
    this.likeCount = 0,
    this.commentCount = 0,
    this.viewCount = 0,
  });

  /// JSON'dan Note nesnesine dönüştürme
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as int?,
      title: json['title'] as String,
      content: json['content'] as String,
      userId: json['userId'] as int?,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      isPublic: json['isPublic'] as bool,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      likeCount: json['likeCount'] as int?,
      commentCount: json['commentCount'] as int?,
      viewCount: json['viewCount'] as int?,
    );
  }

  /// Note nesnesinden JSON'a dönüştürme
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'userId': userId,
      'tags': tags,
      'isPublic': isPublic,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'likeCount': likeCount,
      'commentCount': commentCount,
      'viewCount': viewCount,
    };
  }

  @override
  List<Object?> get props => [
        id,
        title,
        content,
        userId,
        tags,
        isPublic,
        createdAt,
        updatedAt,
        likeCount,
        commentCount,
        viewCount,
      ];

  /// Not bilgilerini güncellemek için kopyalama metodu
  Note copyWith({
    int? id,
    String? title,
    String? content,
    int? userId,
    List<String>? tags,
    bool? isPublic,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? likeCount,
    int? commentCount,
    int? viewCount,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      userId: userId ?? this.userId,
      tags: tags ?? this.tags,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      viewCount: viewCount ?? this.viewCount,
    );
  }
}

/// Not oluşturmak için kullanılacak istek modeli
class CreateNoteRequest {
  final String title;
  final String content;
  final List<String> tags;
  final bool isPublic;

  CreateNoteRequest({
    required this.title,
    required this.content,
    required this.tags,
    required this.isPublic,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'tags': tags,
      'isPublic': isPublic,
    };
  }
}

/// Not güncellemek için kullanılacak istek modeli
class UpdateNoteRequest {
  final String title;
  final String content;
  final List<String> tags;
  final bool isPublic;

  UpdateNoteRequest({
    required this.title,
    required this.content,
    required this.tags,
    required this.isPublic,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'tags': tags,
      'isPublic': isPublic,
    };
  }
}

/// Not yorumu modelini temsil eden sınıf
class NoteComment extends Equatable {
  final int? id;
  final int? noteId;
  final int? userId;
  final String? username;
  final String? fullName;
  final String content;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const NoteComment({
    this.id,
    this.noteId,
    this.userId,
    this.username,
    this.fullName,
    required this.content,
    this.createdAt,
    this.updatedAt,
  });

  /// JSON'dan NoteComment nesnesine dönüştürme
  factory NoteComment.fromJson(Map<String, dynamic> json) {
    return NoteComment(
      id: json['id'] as int?,
      noteId: json['contentId'] as int?,
      userId: json['userId'] as int?,
      username: json['username'] as String?,
      fullName: json['fullName'] as String?,
      content: json['content'] as String,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// NoteComment nesnesinden JSON'a dönüştürme
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contentId': noteId,
      'userId': userId,
      'username': username,
      'fullName': fullName,
      'content': content,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        noteId,
        userId,
        username,
        fullName,
        content,
        createdAt,
        updatedAt,
      ];
}

/// Not yorumu oluşturmak için kullanılacak istek modeli
class CreateNoteCommentRequest {
  final String content;

  CreateNoteCommentRequest({
    required this.content,
  });

  Map<String, dynamic> toJson() {
    return {
      'content': content,
    };
  }
}
