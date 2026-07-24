import '../entities/attendance.dart';

abstract class AttendanceRepository {
  Future<List<DateTime>> getSaturdays(int year, int month);
  Future<List<AttendanceRecord>> getByDate(DateTime date);
  Future<List<AttendanceRecord>> saveBulk({
    required DateTime date,
    required List<AttendanceBulkItem> records,
  });
  Future<List<MemberAttendanceStats>> getStats(int year, int month);
}
