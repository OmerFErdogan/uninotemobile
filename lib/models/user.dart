import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int? id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String university;
  final String department;
  final String classYear;
  final DateTime? createdAt;

  const User({
    this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.university,
    required this.department,
    required this.classYear,
    this.createdAt,
  });

  /// JSON'dan User nesnesine dönüştürme
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int?,
      username: json['username'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      university: json['university'] as String,
      department: json['department'] as String,
      classYear: json['class'] as String,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  /// User nesnesinden JSON'a dönüştürme
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'university': university,
      'department': department,
      'class': classYear,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        username,
        email,
        firstName,
        lastName,
        university,
        department,
        classYear,
        createdAt,
      ];

  /// Kullanıcının tam adını döndürür
  String get fullName => '$firstName $lastName';

  /// Kullanıcı bilgilerini güncellemek için kopyalama metodu
  User copyWith({
    int? id,
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    String? university,
    String? department,
    String? classYear,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      university: university ?? this.university,
      department: department ?? this.department,
      classYear: classYear ?? this.classYear,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Kayıt olmak için kullanılacak model
class RegisterRequest {
  final String username;
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String university;
  final String department;
  final String classYear;

  RegisterRequest({
    required this.username,
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.university,
    required this.department,
    required this.classYear,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      'university': university,
      'department': department,
      'class': classYear,
    };
  }
}

/// Giriş yapmak için kullanılacak model
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

/// Profil güncellemek için kullanılacak model
class UpdateProfileRequest {
  final String firstName;
  final String lastName;
  final String university;
  final String department;
  final String classYear;

  UpdateProfileRequest({
    required this.firstName,
    required this.lastName,
    required this.university,
    required this.department,
    required this.classYear,
  });

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'university': university,
      'department': department,
      'class': classYear,
    };
  }
}

/// Şifre değiştirmek için kullanılacak model
class ChangePasswordRequest {
  final String oldPassword;
  final String newPassword;

  ChangePasswordRequest({
    required this.oldPassword,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'oldPassword': oldPassword,
      'newPassword': newPassword,
    };
  }
}
