import '../entities/member.dart';
import '../repositories/members_repository.dart';

class GetActiveMembersUseCase {
  const GetActiveMembersUseCase(this._repository);
  final MembersRepository _repository;
  Future<List<Member>> call() => _repository.getActiveMembers();
}

class GetInactiveMembersUseCase {
  const GetInactiveMembersUseCase(this._repository);
  final MembersRepository _repository;
  Future<List<Member>> call() => _repository.getInactiveMembers();
}

class GetAllMembersUseCase {
  const GetAllMembersUseCase(this._repository);
  final MembersRepository _repository;
  Future<List<Member>> call() => _repository.getAllMembers();
}

class GetMemberUseCase {
  const GetMemberUseCase(this._repository);
  final MembersRepository _repository;
  Future<Member> call(int id) => _repository.getMember(id);
}

class CreateMemberUseCase {
  const CreateMemberUseCase(this._repository);
  final MembersRepository _repository;

  Future<Member> call({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    String? address,
  }) {
    return _repository.createMember(
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      address: address,
    );
  }
}

class UpdateMemberUseCase {
  const UpdateMemberUseCase(this._repository);
  final MembersRepository _repository;

  Future<Member> call({
    required int id,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    String? address,
  }) {
    return _repository.updateMember(
      id: id,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      address: address,
    );
  }
}

class DeactivateMemberUseCase {
  const DeactivateMemberUseCase(this._repository);
  final MembersRepository _repository;
  Future<void> call(int id) => _repository.deactivateMember(id);
}

class ActivateMemberUseCase {
  const ActivateMemberUseCase(this._repository);
  final MembersRepository _repository;
  Future<Member> call(int id) => _repository.activateMember(id);
}
