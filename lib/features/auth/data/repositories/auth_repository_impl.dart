import 'dart:convert';

import '../../../../core/error/error_mapper.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/auth_models.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required this._remote,
    required this._tokenStorage,
  });

  final AuthRemoteDataSource _remote;
  final TokenStorage _tokenStorage;

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    try {
      final model = await _remote.login(
        LoginRequestModel(email: email, password: password),
      );
      final session = model.toEntity();
      await _persistSession(session);
      return session;
    } catch (e) {
      throw ErrorMapper.failureFromException(e);
    }
  }

  @override
  Future<AuthSession> register({
    required String fullName,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    try {
      final model = await _remote.register(
        RegisterRequestModel(
          fullName: fullName,
          email: email,
          password: password,
          role: role.value,
        ),
      );
      // No persiste sesión: el admin puede registrar sin cerrar la suya.
      return model.toEntity();
    } catch (e) {
      throw ErrorMapper.failureFromException(e);
    }
  }

  @override
  Future<User> me() async {
    try {
      final model = await _remote.me();
      final user = model.toEntity();
      await _tokenStorage.saveUserJson(
        jsonEncode({
          'id': user.id,
          'email': user.email,
          'name': user.name,
          'role': user.role.value,
        }),
      );
      return user;
    } catch (e) {
      throw ErrorMapper.failureFromException(e);
    }
  }

  @override
  Future<AuthSession?> restoreSession() async {
    try {
      final token = await _tokenStorage.getToken();
      if (token == null || token.isEmpty) {
        return null;
      }
      // Valida token con /me (si falla, limpia sesión)
      final user = await me();
      return AuthSession(user: user, token: token);
    } catch (_) {
      await _tokenStorage.clearAll();
      return null;
    }
  }

  @override
  Future<void> logout() => _tokenStorage.clearAll();

  Future<void> _persistSession(AuthSession session) async {
    await _tokenStorage.saveToken(session.token);
    await _tokenStorage.saveUserJson(
      jsonEncode({
        'id': session.user.id,
        'email': session.user.email,
        'name': session.user.name,
        'role': session.user.role.value,
      }),
    );
  }
}
