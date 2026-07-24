import '../../domain/entities/attendance.dart';

DateTime parseDateOnly(String value) {
  final parts = value.split('-');
  return DateTime(
    int.parse(parts[0]),
    int.parse(parts[1]),
    int.parse(parts[2]),
  );
}

String formatDateOnly(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

class AttendanceRecordDto {
  const AttendanceRecordDto({
    required this.id,
    required this.memberId,
    required this.date,
    required this.status,
    this.notes,
    required this.registeredByUserId,
  });

  final int id;
  final int memberId;
  final String date;
  final int status;
  final String? notes;
  final int registeredByUserId;

  factory AttendanceRecordDto.fromJson(Map<String, dynamic> json) {
    return AttendanceRecordDto(
      id: json['id'] as int,
      memberId: json['memberId'] as int,
      date: json['date'] as String,
      status: json['status'] as int,
      notes: json['notes'] as String?,
      registeredByUserId: json['registeredByUserId'] as int,
    );
  }

  AttendanceRecord toEntity() => AttendanceRecord(
        id: id,
        memberId: memberId,
        date: parseDateOnly(date),
        status: AttendanceStatus.fromInt(status),
        notes: notes,
        registeredByUserId: registeredByUserId,
      );
}

class BulkAttendanceRequestDto {
  const BulkAttendanceRequestDto({
    required this.date,
    required this.records,
  });

  final String date;
  final List<BulkAttendanceItemDto> records;

  Map<String, dynamic> toJson() => {
        'date': date,
        'records': records.map((e) => e.toJson()).toList(),
      };
}

class BulkAttendanceItemDto {
  const BulkAttendanceItemDto({
    required this.memberId,
    required this.status,
    this.notes,
  });

  final int memberId;
  final int status;
  final String? notes;

  Map<String, dynamic> toJson() => {
        'memberId': memberId,
        'status': status,
        'notes': notes,
      };
}

class MemberAttendanceStatsDto {
  const MemberAttendanceStatsDto({
    required this.memberId,
    required this.totalPresent,
    required this.totalLate,
    required this.totalAbsent,
  });

  final int memberId;
  final int totalPresent;
  final int totalLate;
  final int totalAbsent;

  factory MemberAttendanceStatsDto.fromJson(Map<String, dynamic> json) {
    return MemberAttendanceStatsDto(
      memberId: json['memberId'] as int,
      totalPresent: json['totalPresent'] as int,
      totalLate: json['totalLate'] as int,
      totalAbsent: json['totalAbsent'] as int,
    );
  }

  MemberAttendanceStats toEntity() => MemberAttendanceStats(
        memberId: memberId,
        totalPresent: totalPresent,
        totalLate: totalLate,
        totalAbsent: totalAbsent,
      );
}
