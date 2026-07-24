import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../features/members/domain/entities/member.dart';

/// Guarda miembros desactivados en el dispositivo (el API solo lista activos).
class InactiveMembersStore {
  InactiveMembersStore({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  final FlutterSecureStorage _storage;
  static const _key = 'inactive_members_v1';

  Future<List<Member>> getAll() async {
    final raw = await _storage.read(key: _key);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => _fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveAll(List<Member> members) async {
    final payload = jsonEncode(members.map(_toMap).toList());
    await _storage.write(key: _key, value: payload);
  }

  Future<void> upsert(Member member) async {
    final current = await getAll();
    final next = [
      for (final m in current)
        if (m.id != member.id) m,
      member.copyWith(isActive: false),
    ];
    await saveAll(next);
  }

  Future<void> remove(int id) async {
    final current = await getAll();
    await saveAll(current.where((m) => m.id != id).toList());
  }

  Map<String, dynamic> _toMap(Member m) => {
        'id': m.id,
        'firstName': m.firstName,
        'lastName': m.lastName,
        'phoneNumber': m.phoneNumber,
        'address': m.address,
        'isActive': false,
      };

  Member _fromMap(Map<String, dynamic> json) => Member(
        id: json['id'] as int,
        firstName: json['firstName'] as String,
        lastName: json['lastName'] as String,
        phoneNumber: json['phoneNumber'] as String,
        address: json['address'] as String?,
        isActive: false,
      );
}
