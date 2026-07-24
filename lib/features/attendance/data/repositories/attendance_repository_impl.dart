import '../../../../core/error/error_mapper.dart';
import '../../domain/entities/attendance.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../datasources/attendance_remote_datasource.dart';
import '../models/attendance_models.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  AttendanceRepositoryImpl(this._remote);

  final AttendanceRemoteDataSource _remote;

  @override
  Future<List<DateTime>> getSaturdays(int year, int month) async {
    try {
      final dates = await _remote.getSaturdays(year, month);
      return dates.map(parseDateOnly).toList();
    } catch (e) {
      throw ErrorMapper.failureFromException(e);
    }
  }

  @override
  Future<List<AttendanceRecord>> getByDate(DateTime date) async {
    try {
      final list = await _remote.getByDate(formatDateOnly(date));
      return list.map((e) => e.toEntity()).toList();
    } catch (e) {
      throw ErrorMapper.failureFromException(e);
    }
  }

  @override
  Future<List<AttendanceRecord>> saveBulk({
    required DateTime date,
    required List<AttendanceBulkItem> records,
  }) async {
    try {
      final request = BulkAttendanceRequestDto(
        date: formatDateOnly(date),
        records: records
            .map(
              (r) => BulkAttendanceItemDto(
                memberId: r.memberId,
                status: r.status.value,
                notes: r.notes,
              ),
            )
            .toList(),
      );
      final list = await _remote.saveBulk(request);
      return list.map((e) => e.toEntity()).toList();
    } catch (e) {
      throw ErrorMapper.failureFromException(e);
    }
  }

  @override
  Future<List<MemberAttendanceStats>> getStats(int year, int month) async {
    try {
      final list = await _remote.getStats(year, month);
      return list.map((e) => e.toEntity()).toList();
    } catch (e) {
      throw ErrorMapper.failureFromException(e);
    }
  }
}
