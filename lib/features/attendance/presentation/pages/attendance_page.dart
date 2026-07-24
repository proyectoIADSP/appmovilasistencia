import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/attendance.dart';
import '../providers/attendance_provider.dart';

class AttendancePage extends ConsumerWidget {
  const AttendancePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(attendanceSessionProvider);
    final notifier = ref.read(attendanceSessionProvider.notifier);
    final dateFormat = DateFormat('dd/MM/yyyy');

    ref.listen(attendanceSessionProvider, (prev, next) {
      if (next.successMessage != null &&
          next.successMessage != prev?.successMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.successMessage!)),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Asistencia')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    key: ValueKey('att-month-${state.year}-${state.month}'),
                    initialValue: state.month,
                    decoration: const InputDecoration(labelText: 'Mes'),
                    items: List.generate(12, (i) {
                      final month = i + 1;
                      return DropdownMenuItem(
                        value: month,
                        child: Text(_monthName(month)),
                      );
                    }),
                    onChanged: (m) {
                      if (m != null) notifier.setYearMonth(state.year, m);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    key: ValueKey('att-year-${state.year}-${state.month}'),
                    initialValue: state.year,
                    decoration: const InputDecoration(labelText: 'Año'),
                    items: List.generate(5, (i) {
                      final year = DateTime.now().year - 2 + i;
                      return DropdownMenuItem(
                        value: year,
                        child: Text('$year'),
                      );
                    }),
                    onChanged: (y) {
                      if (y != null) notifier.setYearMonth(y, state.month);
                    },
                  ),
                ),
              ],
            ),
          ),
          if (state.isLoadingSaturdays)
            const LinearProgressIndicator()
          else
            SizedBox(
              height: 52,
              child: state.saturdays.isEmpty
                  ? const Center(child: Text('No hay sábados en este mes'))
                  : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: state.saturdays.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final date = state.saturdays[index];
                        final selected = state.selectedDate != null &&
                            _sameDay(state.selectedDate!, date);
                        return ChoiceChip(
                          label: Text(dateFormat.format(date)),
                          selected: selected,
                          onSelected: (_) => notifier.selectSaturday(date),
                        );
                      },
                    ),
            ),
          if (state.errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                state.errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          Expanded(child: _buildList(context, ref, state)),
          if (state.selectedDate != null)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton(
                  onPressed: state.isSaving || state.isLoadingList
                      ? null
                      : () => notifier.save(),
                  child: state.isSaving
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Guardar lista'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    WidgetRef ref,
    AttendanceSessionState state,
  ) {
    if (state.selectedDate == null) {
      return const Center(
        child: Text('Selecciona un sábado para pasar lista'),
      );
    }
    if (state.isLoadingList) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.drafts.isEmpty) {
      return const Center(child: Text('No hay miembros activos'));
    }

    final notifier = ref.read(attendanceSessionProvider.notifier);

    return ListView.separated(
      itemCount: state.drafts.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final draft = state.drafts[index];
        return ExpansionTile(
          title: Text(draft.member.fullName),
          subtitle: Text(draft.status.labelEs),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SegmentedButton<AttendanceStatus>(
                    segments: AttendanceStatus.values
                        .map(
                          (s) => ButtonSegment(
                            value: s,
                            label: Text(s.labelEs),
                          ),
                        )
                        .toList(),
                    selected: {draft.status},
                    onSelectionChanged: (set) {
                      notifier.updateStatus(draft.member.id, set.first);
                    },
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: draft.notes ?? '',
                    decoration: const InputDecoration(
                      labelText: 'Notas (opcional)',
                      isDense: true,
                    ),
                    onChanged: (v) =>
                        notifier.updateNotes(draft.member.id, v),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _monthName(int month) {
    const names = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    return names[month - 1];
  }
}
