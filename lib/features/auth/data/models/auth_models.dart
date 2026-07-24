import '../../domain/entities/user.dart';

class AuthResponseModel {
  const AuthResponseModel({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.role,
    required this.token,
  });

  final int userId;
  final String fullName;
  final String email;
  final int role;
  final String token;

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      userId: json['userId'] as int,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      role: json['role'] as int,
      token: json['token'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'fullName': fullName,
        'email': email,
        'role': role,
        'token': token,
      };

  AuthSession toEntity() {
    return AuthSession(
      token: token,
      user: User(
        id: userId,
        email: email,
        name: fullName,
        role: UserRole.fromInt(role),
      ),
    );
  }
}

class MeResponseModel {
  const MeResponseModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
  });

  final int id;
  final String email;
  final String name;
  final int role;

  factory MeResponseModel.fromJson(Map<String, dynamic> json) {
    return MeResponseModel(
      id: json['id'] as int,
      email: json['email'] as String,
      name: json['name'] as String,
      role: json['role'] as int,
    );
  }

  User toEntity() {
    return User(
      id: id,
      email: email,
      name: name,
      role: UserRole.fromInt(role),
    );
  }
}

class LoginRequestModel {
  const LoginRequestModel({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };
}

class RegisterRequestModel {
  const RegisterRequestModel({
    required this.fullName,
    required this.email,
    required this.password,
    required this.role,
  });

  final String fullName;
  final String email;
  final String password;
  final int role;

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'email': email,
        'password': password,
        'role': role,
      };
}
