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

  @override
  List<Object?> get props =>
      [id, firstName, lastName, phoneNumber, address, isActive];
}
