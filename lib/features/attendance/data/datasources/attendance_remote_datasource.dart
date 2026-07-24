import '../../../../core/config/app_config.dart';
import '../../../../core/network/dio_client.dart';
import '../models/attendance_models.dart';

abstract class AttendanceRemoteDataSource {
  Future<List<String>> getSaturdays(int year, int month);
  Future<List<AttendanceRecordDto>> getByDate(String date);
  Future<List<AttendanceRecordDto>> saveBulk(BulkAttendanceRequestDto request);
  Future<List<MemberAttendanceStatsDto>> getStats(int year, int month);
}

class AttendanceRemoteDataSourceImpl implements AttendanceRemoteDataSource {
  AttendanceRemoteDataSourceImpl(this._client);

  final DioClient _client;

  String get _base => '${AppConfig.apiPrefix}/attendance';

  @override
  Future<List<String>> getSaturdays(int year, int month) async {
    final response =
        await _client.get<List<dynamic>>('$_base/saturdays/$year/$month');
    return (response.data ?? []).map((e) => e.toString()).toList();
  }

  @override
  Future<List<AttendanceRecordDto>> getByDate(String date) async {
    final response =
        await _client.get<List<dynamic>>('$_base/by-date/$date');
    return (response.data ?? [])
        .map((e) => AttendanceRecordDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<AttendanceRecordDto>> saveBulk(
    BulkAttendanceRequestDto request,
  ) async {
    final response = await _client.post<List<dynamic>>(
      '$_base/bulk',
      data: request.toJson(),
    );
    return (response.data ?? [])
        .map((e) => AttendanceRecordDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<MemberAttendanceStatsDto>> getStats(int year, int month) async {
    final response =
        await _client.get<List<dynamic>>('$_base/stats/$year/$month');
    return (response.data ?? [])
        .map(
          (e) => MemberAttendanceStatsDto.fromJson(e as Map<String, dynamic>),
        )
        .toList();
  }
}
