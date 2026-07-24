import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/core_providers.dart';
import '../../../../core/error/failures.dart';
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
    load();
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
