import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../members/presentation/providers/members_provider.dart';
import '../providers/attendance_provider.dart';

class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(statsProvider);
    final notifier = ref.read(statsProvider.notifier);
    final members = ref.watch(membersCacheProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas'),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: () => notifier.load(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    key: ValueKey('stats-month-${state.year}-${state.month}'),
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
                    key: ValueKey('stats-year-${state.year}-${state.month}'),
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
          if (state.isLoading) const LinearProgressIndicator(),
          if (state.errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                state.errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          Expanded(
            child: state.stats.isEmpty && !state.isLoading
                ? const Center(child: Text('Sin estadísticas para este mes'))
                : ListView.separated(
                    itemCount: state.stats.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final s = state.stats[index];
                      final name =
                          members[s.memberId]?.fullName ?? 'Miembro #${s.memberId}';
                      return ListTile(
                        title: Text(name),
                        subtitle: Text(
                          'Presentes: ${s.totalPresent} · '
                          'Tarde: ${s.totalLate} · '
                          'Ausentes: ${s.totalAbsent}',
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${s.totalPresent}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const Text('P', style: TextStyle(fontSize: 11)),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

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
