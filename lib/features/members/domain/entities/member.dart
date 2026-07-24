import 'package:equatable/equatable.dart';

class Member extends Equatable {
  const Member({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    this.address,
    required this.isActive,
  });

  final int id;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String? address;
  final bool isActive;

  String get fullName => '$firstName $lastName';

  Member copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? address,
    bool? isActive,
  }) {
    return Member(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props =>
      [id, firstName, lastName, phoneNumber, address, isActive];
}
