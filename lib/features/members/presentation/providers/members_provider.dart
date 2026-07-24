import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/core_providers.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/storage/inactive_members_store.dart';
import '../../data/datasources/members_remote_datasource.dart';
import '../../data/repositories/members_repository_impl.dart';
import '../../domain/entities/member.dart';
import '../../domain/repositories/members_repository.dart';
import '../../domain/usecases/members_usecases.dart';

final membersRepositoryProvider = Provider<MembersRepository>((ref) {
  return MembersRepositoryImpl(
    MembersRemoteDataSourceImpl(ref.watch(dioClientProvider)),
  );
});

final getActiveMembersUseCaseProvider = Provider(
  (ref) => GetActiveMembersUseCase(ref.watch(membersRepositoryProvider)),
);
final getInactiveMembersUseCaseProvider = Provider(
  (ref) => GetInactiveMembersUseCase(ref.watch(membersRepositoryProvider)),
);
final getAllMembersUseCaseProvider = Provider(
  (ref) => GetAllMembersUseCase(ref.watch(membersRepositoryProvider)),
);
final getMemberUseCaseProvider = Provider(
  (ref) => GetMemberUseCase(ref.watch(membersRepositoryProvider)),
);
final createMemberUseCaseProvider = Provider(
  (ref) => CreateMemberUseCase(ref.watch(membersRepositoryProvider)),
);
final updateMemberUseCaseProvider = Provider(
  (ref) => UpdateMemberUseCase(ref.watch(membersRepositoryProvider)),
);
final deactivateMemberUseCaseProvider = Provider(
  (ref) => DeactivateMemberUseCase(ref.watch(membersRepositoryProvider)),
);
final activateMemberUseCaseProvider = Provider(
  (ref) => ActivateMemberUseCase(ref.watch(membersRepositoryProvider)),
);

class MembersListState {
  const MembersListState({
    this.members = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  final List<Member> members;
  final bool isLoading;
  final String? errorMessage;

  MembersListState copyWith({
    List<Member>? members,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MembersListState(
      members: members ?? this.members,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class MembersListNotifier extends StateNotifier<MembersListState> {
  MembersListNotifier(this._getActiveMembers)
      : super(const MembersListState()) {
    Future.microtask(load);
  }

  final GetActiveMembersUseCase _getActiveMembers;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final members = await _getActiveMembers();
      state = MembersListState(members: members);
    } on Failure catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

final membersListProvider =
    StateNotifierProvider<MembersListNotifier, MembersListState>((ref) {
  return MembersListNotifier(ref.watch(getActiveMembersUseCaseProvider));
});

/// Cache simple de miembros activos para stats / attendance.
final membersCacheProvider = Provider<Map<int, Member>>((ref) {
  final list = ref.watch(membersListProvider).members;
  return {for (final m in list) m.id: m};
});

class InactiveMembersState {
  const InactiveMembersState({
    this.members = const [],
    this.isLoading = false,
    this.errorMessage,
    this.actionMessage,
  });

  final List<Member> members;
  final bool isLoading;
  final String? errorMessage;
  final String? actionMessage;

  InactiveMembersState copyWith({
    List<Member>? members,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    String? actionMessage,
    bool clearAction = false,
  }) {
    return InactiveMembersState(
      members: members ?? this.members,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      actionMessage:
          clearAction ? null : (actionMessage ?? this.actionMessage),
    );
  }
}

class InactiveMembersNotifier extends StateNotifier<InactiveMembersState> {
  InactiveMembersNotifier({
    required this._store,
    required this._getInactiveMembers,
    required this._activateMember,
  }) : super(const InactiveMembersState()) {
    Future.microtask(load);
  }

  final InactiveMembersStore _store;
  final GetInactiveMembersUseCase _getInactiveMembers;
  final ActivateMemberUseCase _activateMember;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      try {
        // Backend es la fuente de verdad ahora que existe /members/inactive.
        final backend = await _getInactiveMembers();
        final members = backend
            .map((m) => m.copyWith(isActive: false))
            .toList()
          ..sort((a, b) => a.fullName.toLowerCase().compareTo(
                b.fullName.toLowerCase(),
              ));
        await _store.saveAll(members);
        state = InactiveMembersState(members: members);
        return;
      } catch (_) {
        // Sin red / endpoint caído: usamos el respaldo local.
      }

      final local = await _store.getAll();
      state = InactiveMembersState(members: local);
    } on Failure catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> rememberDeactivated(Member member) async {
    await _store.upsert(member.copyWith(isActive: false));
    await load();
  }

  Future<bool> activate(int memberId) async {
    state = state.copyWith(isLoading: true, clearError: true, clearAction: true);
    try {
      await _activateMember(memberId);
      await _store.remove(memberId);
      await load();
      state = state.copyWith(
        isLoading: false,
        actionMessage: 'Miembro reactivado correctamente',
      );
      return true;
    } on Failure catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }
}

final inactiveMembersProvider =
    StateNotifierProvider<InactiveMembersNotifier, InactiveMembersState>((ref) {
  return InactiveMembersNotifier(
    store: ref.watch(inactiveMembersStoreProvider),
    getInactiveMembers: ref.watch(getInactiveMembersUseCaseProvider),
    activateMember: ref.watch(activateMemberUseCaseProvider),
  );
});
