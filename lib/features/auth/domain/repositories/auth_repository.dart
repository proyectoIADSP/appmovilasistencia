import '../entities/user.dart';

abstract class AuthRepository {
  Future<AuthSession> login({
    required String email,
    required String password,
  });

  Future<AuthSession> register({
    required String fullName,
    required String email,
    required String password,
    required UserRole role,
  });

  Future<User> me();

  Future<AuthSession?> restoreSession();

  Future<void> logout();
}
