import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/widgets/circular_app_logo.dart';
import '../../../attendance/presentation/pages/attendance_page.dart';
import '../../../attendance/presentation/pages/stats_page.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../members/presentation/pages/members_page.dart';

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authNotifierProvider);
    final user = auth.user;
    final isAdmin = user?.isAdmin ?? false;

    final pages = <Widget>[
      const MembersPage(),
      const AttendancePage(),
      const StatsPage(),
    ];

    return Scaffold(
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                ),
                accountName: Text(user?.name ?? 'Usuario'),
                accountEmail: Text(
                  '${AppStrings.appName}\n${user?.email ?? ''} · ${user?.role.labelEs ?? ''}',
                ),
                currentAccountPicture: const CircularAppLogo(
                  size: 72,
                  showBorder: false,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.people),
                title: const Text('Miembros'),
                selected: _index == 0,
                onTap: () {
                  setState(() => _index = 0);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.checklist),
                title: const Text('Asistencia'),
                selected: _index == 1,
                onTap: () {
                  setState(() => _index = 1);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.bar_chart),
                title: const Text('Estadísticas'),
                selected: _index == 2,
                onTap: () {
                  setState(() => _index = 2);
                  Navigator.pop(context);
                },
              ),
              if (isAdmin)
                ListTile(
                  leading: const Icon(Icons.person_add_alt),
                  title: const Text('Registrar usuario'),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/register-user');
                  },
                ),
              const Spacer(),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Cerrar sesión'),
                onTap: () async {
                  Navigator.pop(context);
                  await ref.read(authNotifierProvider.notifier).logout();
                  if (context.mounted) context.go('/login');
                },
              ),
            ],
          ),
        ),
      ),
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Miembros',
          ),
          NavigationDestination(
            icon: Icon(Icons.checklist_outlined),
            selectedIcon: Icon(Icons.checklist),
            label: 'Asistencia',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Estadísticas',
          ),
        ],
      ),
    );
  }
}
