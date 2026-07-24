import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_ui.dart';
import '../../../../core/widgets/attendance_donut_chart.dart';
import '../../../../core/widgets/attendance_status_ui.dart';
import '../../domain/entities/attendance.dart';
import '../providers/attendance_provider.dart';

class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(statsProvider);
    final notifier = ref.read(statsProvider.notifier);
    final dateFormat = DateFormat('dd/MM/yyyy');

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
        if (state.isLoading)
          const LinearProgressIndicator(
            minHeight: 2,
            color: AppColors.gold,
            backgroundColor: AppColors.outline,
          ),
        if (state.errorMessage != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: AppMessageBanner(message: state.errorMessage!),
          ),
        Expanded(
          child: state.stats.isEmpty &&
                  state.saturdayGroups.isEmpty &&
                  !state.isLoading
              ? const AppEmptyView(
                  icon: Icons.insights_outlined,
                  title: 'Sin estadísticas',
                  subtitle:
                      'Aún no hay registros de asistencia para este mes.',
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    SectionHeader(
                      title: 'Resumen del mes',
                      subtitle: state.filter == null
                          ? 'Toca un filtro para ver detalle por sábado'
                          : _filterHint(state.filter!),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        StatPill(
                          label: 'Presentes',
                          value: state.totalPresent,
                          color: AppColors.present,
                          background: AppColors.presentBg,
                          selected: state.filter == StatsStatusFilter.present,
                          onTap: () => notifier
                              .setFilter(StatsStatusFilter.present),
                        ),
                        const SizedBox(width: 8),
                        StatPill(
                          label: 'Tarde',
                          value: state.totalLate,
                          color: AppColors.late,
                          background: AppColors.lateBg,
                          selected: state.filter == StatsStatusFilter.late,
                          onTap: () =>
                              notifier.setFilter(StatsStatusFilter.late),
                        ),
                        const SizedBox(width: 8),
                        StatPill(
                          label: 'Ausentes',
                          value: state.totalAbsent,
                          color: AppColors.absent,
                          background: AppColors.absentBg,
                          selected: state.filter == StatsStatusFilter.absent,
                          onTap: () =>
                              notifier.setFilter(StatsStatusFilter.absent),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => _showChartSheet(context, state),
                      icon: const Icon(Icons.pie_chart_rounded),
                      label: const Text('Ver gráfico de porcentajes'),
                    ),
                    const SizedBox(height: 16),
                    if (state.filter == null) ...[
                      SectionHeader(
                        title: 'Ranking del mes',
                        subtitle: 'Ordenado por % de asistencia',
                      ),
                      const SizedBox(height: 10),
                      ...state.rankedByFilter.map(
                        (s) => _MemberMonthCard(
                          stats: s,
                          memberName: state.membersById[s.memberId]?.fullName ??
                              'Miembro #${s.memberId}',
                          firstName:
                              state.membersById[s.memberId]?.firstName ?? '?',
                        ),
                      ),
                    ] else ...[
                      SectionHeader(
                        title: _filterTitle(state.filter!),
                        subtitle: 'Detalle por cada sábado del mes',
                      ),
                      const SizedBox(height: 10),
                      ..._buildSaturdaySections(state, dateFormat),
                    ],
                  ],
                ),
        ),
      ],
    );
  }

  String _filterHint(StatsStatusFilter filter) {
    switch (filter) {
      case StatsStatusFilter.present:
        return 'Mostrando quienes llegaron a tiempo / presentes';
      case StatsStatusFilter.late:
        return 'Mostrando quienes llegaron tarde';
      case StatsStatusFilter.absent:
        return 'Mostrando quienes faltaron';
    }
  }

  String _filterTitle(StatsStatusFilter filter) {
    switch (filter) {
      case StatsStatusFilter.present:
        return 'Presentes por sábado';
      case StatsStatusFilter.late:
        return 'Tardanzas por sábado';
      case StatsStatusFilter.absent:
        return 'Ausencias por sábado';
    }
  }

  AttendanceStatus _toStatus(StatsStatusFilter filter) {
    switch (filter) {
      case StatsStatusFilter.present:
        return AttendanceStatus.present;
      case StatsStatusFilter.late:
        return AttendanceStatus.late;
      case StatsStatusFilter.absent:
        return AttendanceStatus.absent;
    }
  }

  List<Widget> _buildSaturdaySections(
    StatsState state,
    DateFormat dateFormat,
  ) {
    final status = _toStatus(state.filter!);
    final widgets = <Widget>[];

    for (final group in state.saturdayGroups) {
      final records = group.byStatus(status);
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.outline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.navy,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Sáb ${dateFormat.format(group.date)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${records.length} persona${records.length == 1 ? '' : 's'}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (records.isEmpty)
                  const Text(
                    'Nadie en este estado ese sábado.',
                    style: TextStyle(color: AppColors.textSecondary),
                  )
                else
                  ...records.map((r) {
                    final member = state.membersById[r.memberId];
                    final name =
                        member?.fullName ?? 'Miembro #${r.memberId}';
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          MemberAvatar(
                            name: member?.firstName ?? name,
                            size: 36,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                if (r.notes != null &&
                                    r.notes!.trim().isNotEmpty)
                                  Text(
                                    r.notes!,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          AttendanceStatusBadge(status: r.status),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
        ),
      );
    }

    if (widgets.isEmpty) {
      widgets.add(
        const AppEmptyView(
          icon: Icons.event_busy_rounded,
          title: 'Sin sábados',
          subtitle: 'No hay sábados registrados este mes.',
        ),
      );
    }
    return widgets;
  }

  void _showChartSheet(BuildContext context, StatsState state) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            16,
            24,
            24 + MediaQuery.paddingOf(ctx).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outline,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Porcentajes del mes',
                style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Presentes, tardanzas y ausencias',
                style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 20),
              AttendanceDonutChart(
                present: state.totalPresent,
                late: state.totalLate,
                absent: state.totalAbsent,
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

class _MemberMonthCard extends StatelessWidget {
  const _MemberMonthCard({
    required this.stats,
    required this.memberName,
    required this.firstName,
  });

  final MemberAttendanceStats stats;
  final String memberName;
  final String firstName;

  @override
  Widget build(BuildContext context) {
    final sessions =
        stats.totalPresent + stats.totalLate + stats.totalAbsent;
    final rate = sessions == 0 ? 0.0 : stats.totalPresent / sessions;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                MemberAvatar(name: firstName, size: 40),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        memberName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      Text(
                        'Asistencia ${(rate * 100).round()}%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: rate,
                minHeight: 7,
                backgroundColor: AppColors.outline,
                color: AppColors.gold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                StatPill(
                  label: 'P',
                  value: stats.totalPresent,
                  color: AppColors.present,
                  background: AppColors.presentBg,
                ),
                const SizedBox(width: 8),
                StatPill(
                  label: 'T',
                  value: stats.totalLate,
                  color: AppColors.late,
                  background: AppColors.lateBg,
                ),
                const SizedBox(width: 8),
                StatPill(
                  label: 'A',
                  value: stats.totalAbsent,
                  color: AppColors.absent,
                  background: AppColors.absentBg,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
