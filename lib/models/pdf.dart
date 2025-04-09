import 'dart:convert';

class PDF {
  final int? id;
  final String title;
  final String description;
  final int userId;
  final List<String> tags;
  final bool isPublic;
  final String? filePath;
  final int? fileSize;
  final int? viewCount;
  final int? likeCount;
  final int? commentCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  PDF({
    this.id,
    required this.title,
    required this.description,
    required this.userId,
    required this.tags,
    required this.isPublic,
    this.filePath,
    this.fileSize,
    this.viewCount = 0,
    this.likeCount = 0,
    this.commentCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PDF.fromJson(Map<String, dynamic> json) {
    return PDF(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      userId: json['userId'],
      tags: List<String>.from(json['tags']),
      isPublic: json['isPublic'],
      filePath: json['filePath'],
      fileSize: json['fileSize'],
      viewCount: json['viewCount'],
      likeCount: json['likeCount'],
      commentCount: json['commentCount'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'userId': userId,
      'tags': tags,
      'isPublic': isPublic,
      'filePath': filePath,
      'fileSize': fileSize,
      'viewCount': viewCount,
      'likeCount': likeCount,
      'commentCount': commentCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  PDF copyWith({
    int? id,
    String? title,
    String? description,
    int? userId,
    List<String>? tags,
    bool? isPublic,
    String? filePath,
    int? fileSize,
    int? viewCount,
    int? likeCount,
    int? commentCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PDF(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      userId: userId ?? this.userId,
      tags: tags ?? this.tags,
      isPublic: isPublic ?? this.isPublic,
      filePath: filePath ?? this.filePath,
      fileSize: fileSize ?? this.fileSize,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// PDF yorum (comment) modeli
class PDFComment {
  final int? id;
  final int pdfId;
  final int userId;
  final String? username;
  final String? fullName;
  final String content;
  final int? pageNumber;
  final DateTime createdAt;
  final DateTime? updatedAt;

  PDFComment({
    this.id,
    required this.pdfId,
    required this.userId,
    this.username,
    this.fullName,
    required this.content,
    this.pageNumber,
    required this.createdAt,
    this.updatedAt,
  });

  factory PDFComment.fromJson(Map<String, dynamic> json) {
    return PDFComment(
      id: json['id'],
      pdfId: json['contentId'] ?? json['pdfId'],
      userId: json['userId'],
      username: json['username'],
      fullName: json['fullName'],
      content: json['content'],
      pageNumber: json['pageNumber'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pdfId': pdfId,
      'userId': userId,
      'content': content,
      'pageNumber': pageNumber,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

// PDF işaretleme (annotation) modeli
class PDFAnnotation {
  final int? id;
  final int pdfId;
  final int userId;
  final int pageNumber;
  final String? content;
  final double x;
  final double y;
  final double width;
  final double height;
  final String type; // highlight, underline, note vb.
  final String color;
  final DateTime createdAt;

  PDFAnnotation({
    this.id,
    required this.pdfId,
    required this.userId,
    required this.pageNumber,
    this.content,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.type,
    required this.color,
    required this.createdAt,
  });

  factory PDFAnnotation.fromJson(Map<String, dynamic> json) {
    return PDFAnnotation(
      id: json['id'],
      pdfId: json['pdfId'],
      userId: json['userId'],
      pageNumber: json['pageNumber'],
      content: json['content'],
      x: json['x'].toDouble(),
      y: json['y'].toDouble(),
      width: json['width'].toDouble(),
      height: json['height'].toDouble(),
      type: json['type'],
      color: json['color'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pdfId': pdfId,
      'userId': userId,
      'pageNumber': pageNumber,
      'content': content,
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      'type': type,
      'color': color,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}