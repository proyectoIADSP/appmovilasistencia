import '../entities/member.dart';

abstract class MembersRepository {
  Future<List<Member>> getActiveMembers();

  /// Miembros inactivos desde el backend.
  /// Lanza [Failure] si el endpoint no existe todavía.
  Future<List<Member>> getInactiveMembers();

  /// Activos + inactivos combinados (para resolver nombres en estadísticas).
  /// Si el backend no expone inactivos, devuelve solo los activos.
  Future<List<Member>> getAllMembers();

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
