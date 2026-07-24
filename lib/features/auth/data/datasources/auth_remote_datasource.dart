import '../../../../core/config/app_config.dart';
import '../../../../core/network/dio_client.dart';
import '../models/auth_models.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login(LoginRequestModel request);
  Future<AuthResponseModel> register(RegisterRequestModel request);
  Future<MeResponseModel> me();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._client);

  final DioClient _client;

  @override
  Future<AuthResponseModel> login(LoginRequestModel request) async {
    final response = await _client.post<Map<String, dynamic>>(
      '${AppConfig.apiPrefix}/auth/login',
      data: request.toJson(),
    );
    return AuthResponseModel.fromJson(response.data!);
  }

  @override
  Future<AuthResponseModel> register(RegisterRequestModel request) async {
    final response = await _client.post<Map<String, dynamic>>(
      '${AppConfig.apiPrefix}/auth/register',
      data: request.toJson(),
    );
    return AuthResponseModel.fromJson(response.data!);
  }

  @override
  Future<MeResponseModel> me() async {
    final response = await _client.get<Map<String, dynamic>>(
      '${AppConfig.apiPrefix}/auth/me',
    );
    return MeResponseModel.fromJson(response.data!);
  }
}
