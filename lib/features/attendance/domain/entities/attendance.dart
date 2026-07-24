import 'package:equatable/equatable.dart';

enum AttendanceStatus {
  present(1),
  late(2),
  absent(3);

  const AttendanceStatus(this.value);
  final int value;

  static AttendanceStatus fromInt(int value) {
    return AttendanceStatus.values.firstWhere(
      (s) => s.value == value,
      orElse: () => AttendanceStatus.absent,
    );
  }

  String get labelEs {
    switch (this) {
      case AttendanceStatus.present:
        return 'Presente';
      case AttendanceStatus.late:
        return 'Tarde';
      case AttendanceStatus.absent:
        return 'Ausente';
    }
  }
}

class AttendanceRecord extends Equatable {
  const AttendanceRecord({
    required this.id,
    required this.memberId,
    required this.date,
    required this.status,
    this.notes,
    required this.registeredByUserId,
  });

  final int id;
  final int memberId;
  final DateTime date;
  final AttendanceStatus status;
  final String? notes;
  final int registeredByUserId;

  @override
  List<Object?> get props =>
      [id, memberId, date, status, notes, registeredByUserId];
}

class AttendanceBulkItem extends Equatable {
  const AttendanceBulkItem({
    required this.memberId,
    required this.status,
    this.notes,
  });

  final int memberId;
  final AttendanceStatus status;
  final String? notes;

  @override
  List<Object?> get props => [memberId, status, notes];
}

class MemberAttendanceStats extends Equatable {
  const MemberAttendanceStats({
    required this.memberId,
    required this.totalPresent,
    required this.totalLate,
    required this.totalAbsent,
  });

  final int memberId;
  final int totalPresent;
  final int totalLate;
  final int totalAbsent;

  @override
  List<Object?> get props =>
      [memberId, totalPresent, totalLate, totalAbsent];
}
