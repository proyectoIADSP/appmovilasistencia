import '../../../../core/error/error_mapper.dart';
import '../../domain/entities/member.dart';
import '../../domain/repositories/members_repository.dart';
import '../datasources/members_remote_datasource.dart';
import '../models/member_models.dart';

class MembersRepositoryImpl implements MembersRepository {
  MembersRepositoryImpl(this._remote);

  final MembersRemoteDataSource _remote;

  @override
  Future<List<Member>> getActiveMembers() async {
    try {
      final list = await _remote.getActiveMembers();
      return list.map((e) => e.toEntity()).toList();
    } catch (e) {
      throw ErrorMapper.failureFromException(e);
    }
  }

  @override
  Future<Member> getMember(int id) async {
    try {
      final dto = await _remote.getMember(id);
      return dto.toEntity();
    } catch (e) {
      throw ErrorMapper.failureFromException(e);
    }
  }

  @override
  Future<Member> createMember({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    String? address,
  }) async {
    try {
      final dto = await _remote.createMember(
        MemberRequestDto(
          firstName: firstName,
          lastName: lastName,
          phoneNumber: phoneNumber,
          address: address,
        ),
      );
      return dto.toEntity();
    } catch (e) {
      throw ErrorMapper.failureFromException(e);
    }
  }

  @override
  Future<Member> updateMember({
    required int id,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    String? address,
  }) async {
    try {
      final dto = await _remote.updateMember(
        id,
        MemberRequestDto(
          firstName: firstName,
          lastName: lastName,
          phoneNumber: phoneNumber,
          address: address,
        ),
      );
      return dto.toEntity();
    } catch (e) {
      throw ErrorMapper.failureFromException(e);
    }
  }

  @override
  Future<void> deactivateMember(int id) async {
    try {
      await _remote.deactivateMember(id);
    } catch (e) {
      throw ErrorMapper.failureFromException(e);
    }
  }

  @override
  Future<Member> activateMember(int id) async {
    try {
      final dto = await _remote.activateMember(id);
      return dto.toEntity();
    } catch (e) {
      throw ErrorMapper.failureFromException(e);
    }
  }
}
