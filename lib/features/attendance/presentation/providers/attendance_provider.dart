import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/core_providers.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/storage/inactive_members_store.dart';
import '../../../members/domain/entities/member.dart';
import '../../../members/domain/usecases/members_usecases.dart';
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
    this.isLocked = false,
  });

  final Member member;
  AttendanceStatus status;
  String? notes;

  /// Ya tiene asistencia registrada ese sábado: no se puede modificar.
  final bool isLocked;
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
    required this._getMembers,
  }) : super(AttendanceSessionState(
          year: DateTime.now().year,
          month: DateTime.now().month,
        )) {
    Future.microtask(loadSaturdays);
  }

  final GetSaturdaysUseCase _getSaturdays;
  final GetAttendanceByDateUseCase _getByDate;
  final SaveBulkAttendanceUseCase _saveBulk;
  final GetActiveMembersUseCase _getMembers;

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
      final members = await _getMembers();
      final existing = await _getByDate(date);
      final byMember = {for (final r in existing) r.memberId: r};

      final drafts = members
          .map(
            (m) {
              final existingRecord = byMember[m.id];
              return MemberAttendanceDraft(
                member: m,
                status: existingRecord?.status ?? AttendanceStatus.present,
                notes: existingRecord?.notes,
                isLocked: existingRecord != null,
              );
            },
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

  /// Retorna false si el miembro ya tiene asistencia bloqueada.
  bool updateStatus(int memberId, AttendanceStatus status) {
    final drafts = [...state.drafts];
    final index = drafts.indexWhere((d) => d.member.id == memberId);
    if (index < 0) return true;
    if (drafts[index].isLocked) return false;
    drafts[index].status = status;
    state = state.copyWith(drafts: drafts, clearSuccess: true);
    return true;
  }

  /// Retorna false si el miembro ya tiene asistencia bloqueada.
  bool updateNotes(int memberId, String? notes) {
    final drafts = [...state.drafts];
    final index = drafts.indexWhere((d) => d.member.id == memberId);
    if (index < 0) return true;
    if (drafts[index].isLocked) return false;
    drafts[index].notes = notes;
    state = state.copyWith(drafts: drafts, clearSuccess: true);
    return true;
  }

  Future<bool> save() async {
    final date = state.selectedDate;
    if (date == null) return false;

    final pending = state.drafts.where((d) => !d.isLocked).toList();
    if (pending.isEmpty) {
      state = state.copyWith(
        errorMessage:
            'Todos los miembros de este sábado ya tienen asistencia registrada. Solo se puede poner una vez.',
        clearSuccess: true,
      );
      return false;
    }

    state = state.copyWith(isSaving: true, clearError: true, clearSuccess: true);
    try {
      final records = pending
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
      // Recarga la fecha para marcar como bloqueados los recién guardados.
      await selectSaturday(date);
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
      getMembers: ref.watch(getActiveMembersUseCaseProvider),
    );
  },
);

enum StatsStatusFilter { present, late, absent }

class SaturdayAttendanceGroup {
  const SaturdayAttendanceGroup({
    required this.date,
    required this.records,
  });

  final DateTime date;
  final List<AttendanceRecord> records;

  List<AttendanceRecord> byStatus(AttendanceStatus status) =>
      records.where((r) => r.status == status).toList();
}

class StatsState {
  const StatsState({
    required this.year,
    required this.month,
    this.stats = const [],
    this.membersById = const {},
    this.saturdayGroups = const [],
    this.filter,
    this.isLoading = false,
    this.errorMessage,
  });

  final int year;
  final int month;
  final List<MemberAttendanceStats> stats;
  final Map<int, Member> membersById;
  final List<SaturdayAttendanceGroup> saturdayGroups;
  final StatsStatusFilter? filter;
  final bool isLoading;
  final String? errorMessage;

  int get totalPresent => _countStatus(AttendanceStatus.present);
  int get totalLate => _countStatus(AttendanceStatus.late);
  int get totalAbsent => _countStatus(AttendanceStatus.absent);

  /// Totales solo de sábados (coherente con el detalle por fecha).
  int _countStatus(AttendanceStatus status) {
    var count = 0;
    for (final group in saturdayGroups) {
      count += group.byStatus(status).length;
    }
    return count;
  }

  List<MemberAttendanceStats> get rankedByFilter {
    final list = [...stats];
    switch (filter) {
      case StatsStatusFilter.present:
        list.sort((a, b) => b.totalPresent.compareTo(a.totalPresent));
        return list.where((s) => s.totalPresent > 0).toList();
      case StatsStatusFilter.late:
        list.sort((a, b) => b.totalLate.compareTo(a.totalLate));
        return list.where((s) => s.totalLate > 0).toList();
      case StatsStatusFilter.absent:
        list.sort((a, b) => b.totalAbsent.compareTo(a.totalAbsent));
        return list.where((s) => s.totalAbsent > 0).toList();
      case null:
        list.sort((a, b) {
          final aTotal = a.totalPresent + a.totalLate + a.totalAbsent;
          final bTotal = b.totalPresent + b.totalLate + b.totalAbsent;
          final aRate = aTotal == 0 ? 0.0 : a.totalPresent / aTotal;
          final bRate = bTotal == 0 ? 0.0 : b.totalPresent / bTotal;
          return bRate.compareTo(aRate);
        });
        return list;
    }
  }

  StatsState copyWith({
    int? year,
    int? month,
    List<MemberAttendanceStats>? stats,
    Map<int, Member>? membersById,
    List<SaturdayAttendanceGroup>? saturdayGroups,
    StatsStatusFilter? filter,
    bool clearFilter = false,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return StatsState(
      year: year ?? this.year,
      month: month ?? this.month,
      stats: stats ?? this.stats,
      membersById: membersById ?? this.membersById,
      saturdayGroups: saturdayGroups ?? this.saturdayGroups,
      filter: clearFilter ? null : (filter ?? this.filter),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class StatsNotifier extends StateNotifier<StatsState> {
  StatsNotifier({
    required this._getStats,
    required this._getMembers,
    required this._getSaturdays,
    required this._getByDate,
    required this._inactiveStore,
  }) : super(StatsState(
          year: DateTime.now().year,
          month: DateTime.now().month,
        )) {
    Future.microtask(load);
  }

  final GetAttendanceStatsUseCase _getStats;
  final GetAllMembersUseCase _getMembers;
  final GetSaturdaysUseCase _getSaturdays;
  final GetAttendanceByDateUseCase _getByDate;
  final InactiveMembersStore _inactiveStore;

  Future<void> setYearMonth(int year, int month) async {
    state = state.copyWith(year: year, month: month, clearFilter: true);
    await load();
  }

  void setFilter(StatsStatusFilter? filter) {
    if (state.filter == filter) {
      state = state.copyWith(clearFilter: true);
    } else {
      state = state.copyWith(filter: filter);
    }
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final year = state.year;
      final month = state.month;

      final base = await Future.wait([
        _getStats(year, month),
        _getMembers(),
        _getSaturdays(year, month),
      ]);

      final stats = base[0] as List<MemberAttendanceStats>;
      final members = base[1] as List<Member>;
      final saturdays = base[2] as List<DateTime>;

      // Respaldo local: nombres de miembros desactivados en este dispositivo,
      // para que no aparezcan como "Miembro #id" mientras el backend
      // no exponga el listado de inactivos.
      final localInactive = await _inactiveStore.getAll();

      final recordsByDate = await Future.wait(
        saturdays.map((date) => _getByDate(date)),
      );

      final groups = <SaturdayAttendanceGroup>[];
      for (var i = 0; i < saturdays.length; i++) {
        groups.add(
          SaturdayAttendanceGroup(
            date: saturdays[i],
            records: recordsByDate[i],
          ),
        );
      }

      // El backend/activos tienen prioridad; el respaldo local rellena huecos.
      final membersById = <int, Member>{
        for (final m in localInactive) m.id: m,
        for (final m in members) m.id: m,
      };

      state = state.copyWith(
        stats: stats,
        membersById: membersById,
        saturdayGroups: groups,
        isLoading: false,
      );
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
    getStats: ref.watch(getAttendanceStatsUseCaseProvider),
    getMembers: ref.watch(getAllMembersUseCaseProvider),
    getSaturdays: ref.watch(getSaturdaysUseCaseProvider),
    getByDate: ref.watch(getAttendanceByDateUseCaseProvider),
    inactiveStore: ref.watch(inactiveMembersStoreProvider),
  );
});
