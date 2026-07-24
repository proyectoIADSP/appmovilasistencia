import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/circular_app_logo.dart';
import '../../../attendance/presentation/pages/attendance_page.dart';
import '../../../attendance/presentation/pages/stats_page.dart';
import '../../../attendance/presentation/providers/attendance_provider.dart';
import '../../../auth/presentation/pages/admin_users_page.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../members/presentation/pages/members_page.dart';
import '../../../members/presentation/providers/members_provider.dart';

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

    final titles = [
      'Miembros',
      'Asistencia',
      'Estadísticas',
      if (isAdmin) 'Usuarios',
    ];
    final subtitles = [
      'Padrón activo de la iglesia',
      'Pasa lista los sábados',
      'Resumen mensual por miembro',
      if (isAdmin) 'Registrar diáconos y administradores',
    ];

    final pages = <Widget>[
      const MembersPage(),
      const AttendancePage(),
      const StatsPage(),
      if (isAdmin) const AdminUsersPage(),
    ];

    // Si deja de ser admin y estaba en la pestaña extra, vuelve a miembros.
    if (_index >= pages.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _index = 0);
      });
    }
    final safeIndex = _index.clamp(0, pages.length - 1);

    return Scaffold(
      drawer: _AppDrawer(
        userName: user?.name ?? 'Usuario',
        userEmail: user?.email ?? '',
        roleLabel: user?.role.labelEs ?? '',
        isAdmin: isAdmin,
        selectedIndex: safeIndex,
        onSelect: (i) => setState(() => _index = i),
        onLogout: () async {
          await ref.read(authNotifierProvider.notifier).logout();
          if (context.mounted) context.go('/login');
        },
      ),
      appBar: AppBar(
        toolbarHeight: 72,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titles[safeIndex]),
            const SizedBox(height: 2),
            Text(
              subtitles[safeIndex],
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.navyDeep, AppColors.navy, AppColors.navySoft],
            ),
          ),
        ),
        actions: [
          if (safeIndex == 0 || safeIndex == 2)
            IconButton(
              tooltip: 'Actualizar',
              onPressed: () {
                if (safeIndex == 0) {
                  ref.read(membersListProvider.notifier).load();
                } else {
                  ref.read(statsProvider.notifier).load();
                }
              },
              icon: const Icon(Icons.refresh_rounded),
            ),
        ],
      ),
      body: IndexedStack(index: safeIndex, children: pages),
      floatingActionButton: safeIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () => MembersPage.openForm(context, ref),
              icon: const Icon(Icons.person_add_alt_1_rounded),
              label: const Text('Nuevo'),
            )
          : null,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.outline)),
          color: Colors.white,
        ),
        child: NavigationBar(
          selectedIndex: safeIndex,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.people_outline_rounded),
              selectedIcon: Icon(Icons.people_rounded),
              label: 'Miembros',
            ),
            const NavigationDestination(
              icon: Icon(Icons.fact_check_outlined),
              selectedIcon: Icon(Icons.fact_check_rounded),
              label: 'Asistencia',
            ),
            const NavigationDestination(
              icon: Icon(Icons.insights_outlined),
              selectedIcon: Icon(Icons.insights_rounded),
              label: 'Estadísticas',
            ),
            if (isAdmin)
              const NavigationDestination(
                icon: Icon(Icons.manage_accounts_outlined),
                selectedIcon: Icon(Icons.manage_accounts_rounded),
                label: 'Usuarios',
              ),
          ],
        ),
      ),
    );
  }
}

class _AppDrawer extends StatelessWidget {
  const _AppDrawer({
    required this.userName,
    required this.userEmail,
    required this.roleLabel,
    required this.isAdmin,
    required this.selectedIndex,
    required this.onSelect,
    required this.onLogout,
  });

  final String userName;
  final String userEmail;
  final String roleLabel;
  final bool isAdmin;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final Future<void> Function() onLogout;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              margin: const EdgeInsets.all(AppSpacing.lg),
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.navyDeep, AppColors.navy],
                ),
              ),
              child: Column(
                children: [
                  const CircularAppLogo(size: 78),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    AppStrings.appName,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.goldSoft,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    userName,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$userEmail · $roleLabel',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                        ),
                  ),
                ],
              ),
            ),
            _DrawerItem(
              icon: Icons.people_rounded,
              label: 'Miembros',
              selected: selectedIndex == 0,
              onTap: () {
                onSelect(0);
                Navigator.pop(context);
              },
            ),
            _DrawerItem(
              icon: Icons.fact_check_rounded,
              label: 'Asistencia',
              selected: selectedIndex == 1,
              onTap: () {
                onSelect(1);
                Navigator.pop(context);
              },
            ),
            _DrawerItem(
              icon: Icons.insights_rounded,
              label: 'Estadísticas',
              selected: selectedIndex == 2,
              onTap: () {
                onSelect(2);
                Navigator.pop(context);
              },
            ),
            if (isAdmin)
              _DrawerItem(
                icon: Icons.manage_accounts_rounded,
                label: 'Usuarios',
                selected: selectedIndex == 3,
                onTap: () {
                  onSelect(3);
                  Navigator.pop(context);
                },
              ),
            const Spacer(),
            const Divider(indent: 16, endIndent: 16),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                leading:
                    const Icon(Icons.logout_rounded, color: AppColors.absent),
                title: const Text(
                  'Cerrar sesión',
                  style: TextStyle(
                    color: AppColors.absent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await onLogout();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        selected: selected,
        selectedTileColor: AppColors.goldMuted,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        leading: Icon(
          icon,
          color: selected ? AppColors.navy : AppColors.textSecondary,
        ),
        title: Text(
          label,
          style: TextStyle(
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            color: selected ? AppColors.navy : AppColors.textPrimary,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
