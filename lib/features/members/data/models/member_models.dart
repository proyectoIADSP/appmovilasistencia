import '../../../../core/network/json_parsers.dart';
import '../../domain/entities/member.dart';

class MemberDto {
  const MemberDto({
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

  factory MemberDto.fromJson(Map<String, dynamic> json) {
    return MemberDto(
      id: parseJsonInt(json['id'], field: 'id'),
      firstName: parseJsonString(json['firstName'], field: 'firstName'),
      lastName: parseJsonString(json['lastName'], field: 'lastName'),
      phoneNumber: parseJsonString(json['phoneNumber'], field: 'phoneNumber'),
      address: json['address'] == null
          ? null
          : parseJsonString(json['address'], field: 'address'),
      isActive: parseJsonBool(json['isActive'], fallback: true),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phoneNumber,
        'address': address,
        'isActive': isActive,
      };

  Member toEntity() => Member(
        id: id,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        address: address,
        isActive: isActive,
      );
}

class MemberRequestDto {
  const MemberRequestDto({
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    this.address,
  });

  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String? address;

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phoneNumber,
        if (address != null) 'address': address,
      };
}
