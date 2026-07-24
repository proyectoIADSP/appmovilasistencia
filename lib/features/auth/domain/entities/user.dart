import 'package:equatable/equatable.dart';

enum UserRole {
  deacon(1),
  administrator(2);

  const UserRole(this.value);
  final int value;

  static UserRole fromInt(int value) {
    return UserRole.values.firstWhere(
      (r) => r.value == value,
      orElse: () => UserRole.deacon,
    );
  }

  String get labelEs {
    switch (this) {
      case UserRole.deacon:
        return 'Diácono';
      case UserRole.administrator:
        return 'Administrador';
    }
  }
}

class User extends Equatable {
  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
  });

  final int id;
  final String email;
  final String name;
  final UserRole role;

  bool get isAdmin => role == UserRole.administrator;

  @override
  List<Object?> get props => [id, email, name, role];
}

class AuthSession extends Equatable {
  const AuthSession({
    required this.user,
    required this.token,
  });

  final User user;
  final String token;

  @override
  List<Object?> get props => [user, token];
}
