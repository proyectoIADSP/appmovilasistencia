import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_ui.dart';
import '../../../../core/widgets/attendance_status_ui.dart';
import '../../domain/entities/attendance.dart';
import '../providers/attendance_provider.dart';

class AttendancePage extends ConsumerStatefulWidget {
  const AttendancePage({super.key});

  @override
  ConsumerState<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends ConsumerState<AttendancePage> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<MemberAttendanceDraft> _filtered(List<MemberAttendanceDraft> drafts) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return drafts;
    return drafts.where((d) {
      final m = d.member;
      return m.fullName.toLowerCase().contains(q) ||
          m.phoneNumber.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(attendanceSessionProvider);
    final notifier = ref.read(attendanceSessionProvider.notifier);
    final dateFormat = DateFormat('dd/MM');

    ref.listen(attendanceSessionProvider, (prev, next) {
      if (next.successMessage != null &&
          next.successMessage != prev?.successMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            backgroundColor: AppColors.present,
          ),
        );
      }
      if (next.errorMessage != null &&
          next.errorMessage != prev?.errorMessage &&
          _isOnceOnlyError(next.errorMessage!)) {
        _showRuleAlert(context, next.errorMessage!);
      }
    });

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: MonthYearSelector(
            year: state.year,
            month: state.month,
            onChanged: notifier.setYearMonth,
          ),
        ),
        if (state.isLoadingSaturdays)
          const LinearProgressIndicator(
            minHeight: 2,
            color: AppColors.gold,
            backgroundColor: AppColors.outline,
          )
        else
          SizedBox(
            height: 86,
            child: state.saturdays.isEmpty
                ? const Center(
                    child: Text(
                      'No hay sábados en este mes',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: state.saturdays.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final date = state.saturdays[index];
                      final selected = state.selectedDate != null &&
                          _sameDay(state.selectedDate!, date);
                      return _SaturdayChip(
                        label: 'Sáb ${date.day}',
                        sublabel: dateFormat.format(date),
                        selected: selected,
                        onTap: () {
                          _searchController.clear();
                          setState(() => _query = '');
                          notifier.selectSaturday(date);
                        },
                      );
                    },
                  ),
          ),
        if (state.errorMessage != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: AppMessageBanner(message: state.errorMessage!),
          ),
        Expanded(child: _buildList(context, state)),
        if (state.selectedDate != null)
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.outline)),
              ),
              child: FilledButton.icon(
                onPressed: state.isSaving || state.isLoadingList
                    ? null
                    : () => notifier.save(),
                icon: state.isSaving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save_rounded),
                label: Text(
                  state.isSaving ? 'Guardando…' : 'Guardar lista',
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildList(BuildContext context, AttendanceSessionState state) {
    if (state.selectedDate == null) {
      return const AppEmptyView(
        icon: Icons.event_available_rounded,
        title: 'Elige un sábado',
        subtitle: 'Selecciona una fecha para pasar la lista de asistencia.',
      );
    }
    if (state.isLoadingList) {
      return const AppLoadingView(message: 'Preparando lista…');
    }
    if (state.drafts.isEmpty) {
      return const AppEmptyView(
        icon: Icons.group_off_outlined,
        title: 'No hay miembros activos',
        subtitle: 'Primero registra miembros en el padrón.',
      );
    }

    final notifier = ref.read(attendanceSessionProvider.notifier);
    final filtered = _filtered(state.drafts);
    final present = state.drafts
        .where((d) => d.status == AttendanceStatus.present)
        .length;
    final lateCount =
        state.drafts.where((d) => d.status == AttendanceStatus.late).length;
    final absent =
        state.drafts.where((d) => d.status == AttendanceStatus.absent).length;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: filtered.length + 2,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              children: [
                Row(
                  children: [
                    StatPill(
                      label: 'Presentes',
                      value: present,
                      color: AppColors.present,
                      background: AppColors.presentBg,
                    ),
                    const SizedBox(width: 8),
                    StatPill(
                      label: 'Tarde',
                      value: lateCount,
                      color: AppColors.late,
                      background: AppColors.lateBg,
                    ),
                    const SizedBox(width: 8),
                    StatPill(
                      label: 'Ausentes',
                      value: absent,
                      color: AppColors.absent,
                      background: AppColors.absentBg,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AppSearchField(
                  controller: _searchController,
                  hintText: 'Buscar miembro en la lista…',
                  onChanged: (v) => setState(() => _query = v),
                ),
              ],
            ),
          );
        }

        if (index == 1) {
          if (filtered.isEmpty) {
            return const Padding(
              padding: EdgeInsets.only(top: 24),
              child: AppEmptyView(
                icon: Icons.search_off_rounded,
                title: 'Sin resultados',
                subtitle: 'No hay miembros que coincidan con la búsqueda.',
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SectionHeader(
              title: _query.trim().isEmpty
                  ? '${filtered.length} en lista'
                  : '${filtered.length} encontrados',
              subtitle:
                  'La asistencia ya registrada no se puede modificar',
            ),
          );
        }

        if (filtered.isEmpty) return const SizedBox.shrink();

        final draft = filtered[index - 2];
        final locked = draft.isLocked;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: locked ? const Color(0xFFF7F8FA) : Colors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(
                color: locked
                    ? AppColors.gold.withValues(alpha: 0.45)
                    : AppColors.outline,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    MemberAvatar(name: draft.member.firstName, size: 40),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            draft.member.fullName,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          if (locked)
                            const Text(
                              'Ya registrada · no editable',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (locked)
                      const Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Icon(
                          Icons.lock_rounded,
                          size: 18,
                          color: AppColors.gold,
                        ),
                      ),
                    AttendanceStatusBadge(status: draft.status),
                  ],
                ),
                const SizedBox(height: 12),
                AttendanceStatusSelector(
                  value: draft.status,
                  onChanged: (s) {
                    final ok =
                        notifier.updateStatus(draft.member.id, s);
                    if (!ok) {
                      _showRuleAlert(
                        context,
                        'Solo se puede poner la asistencia una vez.\n\n'
                        'Si este miembro ya tiene asistencia en este sábado, '
                        'no se puede modificar.',
                      );
                    }
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  key: ValueKey('notes-${draft.member.id}-$locked'),
                  initialValue: draft.notes ?? '',
                  enabled: !locked,
                  readOnly: locked,
                  onTap: locked
                      ? () => _showRuleAlert(
                            context,
                            'Solo se puede poner la asistencia una vez.\n\n'
                            'Si este miembro ya tiene asistencia en este sábado, '
                            'no se puede modificar.',
                          )
                      : null,
                  decoration: InputDecoration(
                    labelText: locked
                        ? 'Notas (bloqueado)'
                        : 'Notas (opcional)',
                    isDense: true,
                    prefixIcon: Icon(
                      locked
                          ? Icons.lock_outline_rounded
                          : Icons.notes_rounded,
                      size: 20,
                    ),
                  ),
                  onChanged: locked
                      ? null
                      : (v) => notifier.updateNotes(draft.member.id, v),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showRuleAlert(BuildContext context, String message) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.lock_rounded, color: AppColors.gold),
        title: const Text('No permitido'),
        content: Text(message),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  bool _isOnceOnlyError(String message) {
    final m = message.toLowerCase();
    return m.contains('una vez') ||
        m.contains('ya fue registrada') ||
        m.contains('no se puede modificar') ||
        m.contains('ya tienen asistencia') ||
        m.contains('solo se registra los sábados') ||
        m.contains('solo se registra los sabados');
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _SaturdayChip extends StatelessWidget {
  const _SaturdayChip({
    required this.label,
    required this.sublabel,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String sublabel;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.navy : Colors.white,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Container(
          width: 108,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: selected ? AppColors.navy : AppColors.outline,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                sublabel,
                style: TextStyle(
                  color: selected
                      ? AppColors.goldSoft
                      : AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
