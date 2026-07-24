import '../entities/attendance.dart';
import '../repositories/attendance_repository.dart';

class GetSaturdaysUseCase {
  const GetSaturdaysUseCase(this._repository);
  final AttendanceRepository _repository;
  Future<List<DateTime>> call(int year, int month) =>
      _repository.getSaturdays(year, month);
}

class GetAttendanceByDateUseCase {
  const GetAttendanceByDateUseCase(this._repository);
  final AttendanceRepository _repository;
  Future<List<AttendanceRecord>> call(DateTime date) =>
      _repository.getByDate(date);
}

class SaveBulkAttendanceUseCase {
  const SaveBulkAttendanceUseCase(this._repository);
  final AttendanceRepository _repository;

  Future<List<AttendanceRecord>> call({
    required DateTime date,
    required List<AttendanceBulkItem> records,
  }) {
    return _repository.saveBulk(date: date, records: records);
  }
}

class GetAttendanceStatsUseCase {
  const GetAttendanceStatsUseCase(this._repository);
  final AttendanceRepository _repository;
  Future<List<MemberAttendanceStats>> call(int year, int month) =>
      _repository.getStats(year, month);
}
