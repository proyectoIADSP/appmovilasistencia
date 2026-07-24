import '../../../../core/config/app_config.dart';
import '../../../../core/network/dio_client.dart';
import '../models/member_models.dart';

abstract class MembersRemoteDataSource {
  Future<List<MemberDto>> getActiveMembers();
  Future<MemberDto> getMember(int id);
  Future<MemberDto> createMember(MemberRequestDto request);
  Future<MemberDto> updateMember(int id, MemberRequestDto request);
  Future<void> deactivateMember(int id);
  Future<MemberDto> activateMember(int id);
}

class MembersRemoteDataSourceImpl implements MembersRemoteDataSource {
  MembersRemoteDataSourceImpl(this._client);

  final DioClient _client;

  String get _base => '${AppConfig.apiPrefix}/members';

  @override
  Future<List<MemberDto>> getActiveMembers() async {
    final response = await _client.get<List<dynamic>>(_base);
    final list = response.data ?? [];
    return list
        .map((e) => MemberDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<MemberDto> getMember(int id) async {
    final response =
        await _client.get<Map<String, dynamic>>('$_base/$id');
    return MemberDto.fromJson(response.data!);
  }

  @override
  Future<MemberDto> createMember(MemberRequestDto request) async {
    final response = await _client.post<Map<String, dynamic>>(
      _base,
      data: request.toJson(),
    );
    return MemberDto.fromJson(response.data!);
  }

  @override
  Future<MemberDto> updateMember(int id, MemberRequestDto request) async {
    final response = await _client.put<Map<String, dynamic>>(
      '$_base/$id',
      data: request.toJson(),
    );
    return MemberDto.fromJson(response.data!);
  }

  @override
  Future<void> deactivateMember(int id) async {
    await _client.delete('$_base/$id');
  }

  @override
  Future<MemberDto> activateMember(int id) async {
    final response = await _client.post<Map<String, dynamic>>(
      '$_base/$id/activate',
    );
    return MemberDto.fromJson(response.data!);
  }
}
