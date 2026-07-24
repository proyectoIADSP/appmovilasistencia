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
      id: json['id'] as int,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      phoneNumber: json['phoneNumber'] as String,
      address: json['address'] as String?,
      isActive: json['isActive'] as bool? ?? true,
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
