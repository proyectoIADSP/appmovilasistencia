import '../../../../core/network/json_parsers.dart';
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

String parseDateOnlyField(dynamic value) {
  if (value == null) {
    throw const FormatException('Campo "date" es nulo');
  }
  if (value is String) {
    return value.length >= 10 ? value.substring(0, 10) : value;
  }
  if (value is DateTime) {
    return formatDateOnly(value);
  }
  final asString = parseJsonString(value, field: 'date');
  return asString.length >= 10 ? asString.substring(0, 10) : asString;
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
      id: parseJsonInt(json['id'], field: 'id'),
      memberId: parseJsonInt(json['memberId'], field: 'memberId'),
      date: parseDateOnlyField(json['date']),
      status: parseAttendanceStatusValue(json['status']),
      notes: json['notes'] == null
          ? null
          : parseJsonString(json['notes'], field: 'notes'),
      registeredByUserId:
          parseJsonInt(json['registeredByUserId'], field: 'registeredByUserId'),
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
      memberId: parseJsonInt(json['memberId'], field: 'memberId'),
      totalPresent: parseJsonInt(json['totalPresent'], field: 'totalPresent'),
      totalLate: parseJsonInt(json['totalLate'], field: 'totalLate'),
      totalAbsent: parseJsonInt(json['totalAbsent'], field: 'totalAbsent'),
    );
  }

  MemberAttendanceStats toEntity() => MemberAttendanceStats(
        memberId: memberId,
        totalPresent: totalPresent,
        totalLate: totalLate,
        totalAbsent: totalAbsent,
      );
}
