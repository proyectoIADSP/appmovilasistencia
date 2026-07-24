import '../entities/member.dart';

abstract class MembersRepository {
  Future<List<Member>> getActiveMembers();
  Future<Member> getMember(int id);
  Future<Member> createMember({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    String? address,
  });
  Future<Member> updateMember({
    required int id,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    String? address,
  });
  Future<void> deactivateMember(int id);
  Future<Member> activateMember(int id);
}
