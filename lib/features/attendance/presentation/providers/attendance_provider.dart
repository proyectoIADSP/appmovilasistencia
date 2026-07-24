import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/core_providers.dart';
import '../../../../core/error/failures.dart';
import '../../../members/domain/entities/member.dart';
import '../../../members/presentation/providers/members_provider.dart';
import '../../data/datasources/attendance_remote_datasource.dart';
import '../../data/repositories/attendance_repository_impl.dart';
import '../../domain/entities/attendance.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../../domain/usecases/attendance_usecases.dart';

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepositoryImpl(
    AttendanceRemoteDataSourceImpl(ref.watch(dioClientProvider)),
  );
});

final getSaturdaysUseCaseProvider = Provider(
  (ref) => GetSaturdaysUseCase(ref.watch(attendanceRepositoryProvider)),
);
final getAttendanceByDateUseCaseProvider = Provider(
  (ref) => GetAttendanceByDateUseCase(ref.watch(attendanceRepositoryProvider)),
);
final saveBulkAttendanceUseCaseProvider = Provider(
  (ref) => SaveBulkAttendanceUseCase(ref.watch(attendanceRepositoryProvider)),
);
final getAttendanceStatsUseCaseProvider = Provider(
  (ref) => GetAttendanceStatsUseCase(ref.watch(attendanceRepositoryProvider)),
);

class MemberAttendanceDraft {
  MemberAttendanceDraft({
    required this.member,
    this.status = AttendanceStatus.present,
    this.notes,
  });

  final Member member;
  AttendanceStatus status;
  String? notes;
}

class AttendanceSessionState {
  const AttendanceSessionState({
    required this.year,
    required this.month,
    this.saturdays = const [],
    this.selectedDate,
    this.drafts = const [],
    this.isLoadingSaturdays = false,
    this.isLoadingList = false,
    this.isSaving = false,
    this.errorMessage,
    this.successMessage,
  });

  final int year;
  final int month;
  final List<DateTime> saturdays;
  final DateTime? selectedDate;
  final List<MemberAttendanceDraft> drafts;
  final bool isLoadingSaturdays;
  final bool isLoadingList;
  final bool isSaving;
  final String? errorMessage;
  final String? successMessage;

  AttendanceSessionState copyWith({
    int? year,
    int? month,
    List<DateTime>? saturdays,
    DateTime? selectedDate,
    bool clearSelectedDate = false,
    List<MemberAttendanceDraft>? drafts,
    bool? isLoadingSaturdays,
    bool? isLoadingList,
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
  }) {
    return AttendanceSessionState(
      year: year ?? this.year,
      month: month ?? this.month,
      saturdays: saturdays ?? this.saturdays,
      selectedDate:
          clearSelectedDate ? null : (selectedDate ?? this.selectedDate),
      drafts: drafts ?? this.drafts,
      isLoadingSaturdays: isLoadingSaturdays ?? this.isLoadingSaturdays,
      isLoadingList: isLoadingList ?? this.isLoadingList,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }
}

class AttendanceSessionNotifier extends StateNotifier<AttendanceSessionState> {
  AttendanceSessionNotifier({
    required this._getSaturdays,
    required this._getByDate,
    required this._saveBulk,
    required this._ref,
  }) : super(AttendanceSessionState(
          year: DateTime.now().year,
          month: DateTime.now().month,
        )) {
    loadSaturdays();
  }

  final GetSaturdaysUseCase _getSaturdays;
  final GetAttendanceByDateUseCase _getByDate;
  final SaveBulkAttendanceUseCase _saveBulk;
  final Ref _ref;

  Future<void> setYearMonth(int year, int month) async {
    state = state.copyWith(
      year: year,
      month: month,
      clearSelectedDate: true,
      drafts: [],
      clearError: true,
      clearSuccess: true,
    );
    await loadSaturdays();
  }

  Future<void> loadSaturdays() async {
    state = state.copyWith(isLoadingSaturdays: true, clearError: true);
    try {
      final saturdays = await _getSaturdays(state.year, state.month);
      state = state.copyWith(
        saturdays: saturdays,
        isLoadingSaturdays: false,
      );
    } on Failure catch (e) {
      state = state.copyWith(
        isLoadingSaturdays: false,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingSaturdays: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> selectSaturday(DateTime date) async {
    state = state.copyWith(
      selectedDate: date,
      isLoadingList: true,
      clearError: true,
      clearSuccess: true,
    );
    try {
      await _ref.read(membersListProvider.notifier).load();
      final members = _ref.read(membersListProvider).members;
      final existing = await _getByDate(date);
      final byMember = {for (final r in existing) r.memberId: r};

      final drafts = members
          .map(
            (m) => MemberAttendanceDraft(
              member: m,
              status: byMember[m.id]?.status ?? AttendanceStatus.present,
              notes: byMember[m.id]?.notes,
            ),
          )
          .toList();

      state = state.copyWith(
        drafts: drafts,
        isLoadingList: false,
      );
    } on Failure catch (e) {
      state = state.copyWith(isLoadingList: false, errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(isLoadingList: false, errorMessage: e.toString());
    }
  }

  void updateStatus(int memberId, AttendanceStatus status) {
    final drafts = [...state.drafts];
    final index = drafts.indexWhere((d) => d.member.id == memberId);
    if (index < 0) return;
    drafts[index].status = status;
    state = state.copyWith(drafts: drafts, clearSuccess: true);
  }

  void updateNotes(int memberId, String? notes) {
    final drafts = [...state.drafts];
    final index = drafts.indexWhere((d) => d.member.id == memberId);
    if (index < 0) return;
    drafts[index].notes = notes;
    state = state.copyWith(drafts: drafts, clearSuccess: true);
  }

  Future<bool> save() async {
    final date = state.selectedDate;
    if (date == null) return false;
    state = state.copyWith(isSaving: true, clearError: true, clearSuccess: true);
    try {
      final records = state.drafts
          .map(
            (d) => AttendanceBulkItem(
              memberId: d.member.id,
              status: d.status,
              notes: (d.notes == null || d.notes!.trim().isEmpty)
                  ? null
                  : d.notes!.trim(),
            ),
          )
          .toList();
      await _saveBulk(date: date, records: records);
      state = state.copyWith(
        isSaving: false,
        successMessage: 'Lista guardada correctamente',
      );
      return true;
    } on Failure catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: e.toString());
      return false;
    }
  }
}

final attendanceSessionProvider =
    StateNotifierProvider<AttendanceSessionNotifier, AttendanceSessionState>(
  (ref) {
    return AttendanceSessionNotifier(
      getSaturdays: ref.watch(getSaturdaysUseCaseProvider),
      getByDate: ref.watch(getAttendanceByDateUseCaseProvider),
      saveBulk: ref.watch(saveBulkAttendanceUseCaseProvider),
      ref: ref,
    );
  },
);

class StatsState {
  const StatsState({
    required this.year,
    required this.month,
    this.stats = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  final int year;
  final int month;
  final List<MemberAttendanceStats> stats;
  final bool isLoading;
  final String? errorMessage;

  StatsState copyWith({
    int? year,
    int? month,
    List<MemberAttendanceStats>? stats,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return StatsState(
      year: year ?? this.year,
      month: month ?? this.month,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class StatsNotifier extends StateNotifier<StatsState> {
  StatsNotifier(this._getStats, this._ref)
      : super(StatsState(
          year: DateTime.now().year,
          month: DateTime.now().month,
        )) {
    load();
  }

  final GetAttendanceStatsUseCase _getStats;
  final Ref _ref;

  Future<void> setYearMonth(int year, int month) async {
    state = state.copyWith(year: year, month: month);
    await load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _ref.read(membersListProvider.notifier).load();
      final stats = await _getStats(state.year, state.month);
      state = state.copyWith(stats: stats, isLoading: false);
    } on Failure catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

final statsProvider =
    StateNotifierProvider<StatsNotifier, StatsState>((ref) {
  return StatsNotifier(
    ref.watch(getAttendanceStatsUseCaseProvider),
    ref,
  );
});
