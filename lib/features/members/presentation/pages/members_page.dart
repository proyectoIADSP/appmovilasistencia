import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_ui.dart';
import '../../domain/entities/member.dart';
import '../providers/members_provider.dart';

class MembersPage extends ConsumerStatefulWidget {
  const MembersPage({super.key});

  static Future<void> openForm(
    BuildContext context,
    WidgetRef ref, {
    Member? member,
  }) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => MemberFormPage(member: member),
      ),
    );
    if (changed == true) {
      await ref.read(membersListProvider.notifier).load();
    }
  }

  @override
  ConsumerState<MembersPage> createState() => _MembersPageState();
}

class _MembersPageState extends ConsumerState<MembersPage> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Member> _filtered(List<Member> members) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return members;
    return members.where((m) {
      return m.fullName.toLowerCase().contains(q) ||
          m.phoneNumber.contains(q) ||
          (m.address?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(membersListProvider);

    if (state.isLoading && state.members.isEmpty) {
      return const AppLoadingView(message: 'Cargando miembros…');
    }
    if (state.errorMessage != null && state.members.isEmpty) {
      return AppErrorView(
        message: state.errorMessage!,
        onRetry: () => ref.read(membersListProvider.notifier).load(),
      );
    }
    if (state.members.isEmpty) {
      return AppEmptyView(
        icon: Icons.groups_2_outlined,
        title: 'Sin miembros activos',
        subtitle: 'Agrega el primer miembro del padrón con el botón Nuevo.',
        action: FilledButton.icon(
          onPressed: () => MembersPage.openForm(context, ref),
          icon: const Icon(Icons.person_add_alt_1_rounded),
          label: const Text('Crear miembro'),
        ),
      );
    }

    final filtered = _filtered(state.members);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: AppSearchField(
            controller: _searchController,
            hintText: 'Buscar por nombre o celular…',
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            color: AppColors.navy,
            onRefresh: () => ref.read(membersListProvider.notifier).load(),
            child: filtered.isEmpty
                ? ListView(
                    children: const [
                      SizedBox(height: 80),
                      AppEmptyView(
                        icon: Icons.search_off_rounded,
                        title: 'Sin resultados',
                        subtitle: 'Prueba con otro nombre o número.',
                      ),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                    itemCount: filtered.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: SectionHeader(
                            title: _query.trim().isEmpty
                                ? '${filtered.length} miembros'
                                : '${filtered.length} de ${state.members.length}',
                            subtitle: 'Toca un miembro para editarlo',
                          ),
                        );
                      }
                      final member = filtered[index - 1];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Material(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusMd),
                          child: InkWell(
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusMd),
                            onTap: () => MembersPage.openForm(
                              context,
                              ref,
                              member: member,
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusMd,
                                ),
                                border: Border.all(color: AppColors.outline),
                              ),
                              child: Row(
                                children: [
                                  MemberAvatar(name: member.firstName),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          member.fullName,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.phone_rounded,
                                              size: 14,
                                              color: AppColors.textSecondary,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              member.phoneNumber,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    color: AppColors
                                                        .textSecondary,
                                                  ),
                                            ),
                                          ],
                                        ),
                                        if (member.address != null &&
                                            member.address!
                                                .trim()
                                                .isNotEmpty) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            member.address!,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color: AppColors.goldMuted,
                                      borderRadius: BorderRadius.circular(
                                        AppSpacing.radiusSm,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.chevron_right_rounded,
                                      color: AppColors.navy,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}

class MemberFormPage extends ConsumerStatefulWidget {
  const MemberFormPage({super.key, this.member});

  final Member? member;

  @override
  ConsumerState<MemberFormPage> createState() => _MemberFormPageState();
}

class _MemberFormPageState extends ConsumerState<MemberFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _phone;
  late final TextEditingController _address;
  bool _saving = false;
  String? _error;

  bool get _isEdit => widget.member != null;

  @override
  void initState() {
    super.initState();
    final m = widget.member;
    _firstName = TextEditingController(text: m?.firstName ?? '');
    _lastName = TextEditingController(text: m?.lastName ?? '');
    _phone = TextEditingController(text: m?.phoneNumber ?? '');
    _address = TextEditingController(text: m?.address ?? '');
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final address = _address.text.trim();
      if (_isEdit) {
        await ref.read(updateMemberUseCaseProvider)(
          id: widget.member!.id,
          firstName: _firstName.text.trim(),
          lastName: _lastName.text.trim(),
          phoneNumber: _phone.text.trim(),
          address: address.isEmpty ? null : address,
        );
      } else {
        await ref.read(createMemberUseCaseProvider)(
          firstName: _firstName.text.trim(),
          lastName: _lastName.text.trim(),
          phoneNumber: _phone.text.trim(),
          address: address.isEmpty ? null : address,
        );
      }
      if (mounted) Navigator.of(context).pop(true);
    } on Failure catch (e) {
      setState(() {
        _saving = false;
        _error = e.message;
      });
    } catch (e) {
      setState(() {
        _saving = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _deactivate() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Desactivar miembro'),
        content: Text(
          '¿Deseas desactivar a ${widget.member!.fullName}? '
          'No se eliminará permanentemente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.absent),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Desactivar'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(deactivateMemberUseCaseProvider)(widget.member!.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Miembro desactivado')),
        );
        Navigator.of(context).pop(true);
      }
    } on Failure catch (e) {
      setState(() {
        _saving = false;
        _error = e.message;
      });
    } catch (e) {
      setState(() {
        _saving = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Editar miembro' : 'Nuevo miembro'),
        actions: [
          if (_isEdit)
            IconButton(
              tooltip: 'Desactivar',
              onPressed: _saving ? null : _deactivate,
              icon: const Icon(Icons.person_off_outlined),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_isEdit) ...[
                Center(
                  child: MemberAvatar(
                    name: widget.member!.firstName,
                    size: 72,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
              TextFormField(
                controller: _firstName,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Ingresa el nombre' : null,
              ),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: _lastName,
                decoration: const InputDecoration(
                  labelText: 'Apellido',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Ingresa el apellido'
                    : null,
              ),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: _phone,
                decoration: const InputDecoration(
                  labelText: 'Celular (9 dígitos)',
                  prefixIcon: Icon(Icons.phone_rounded),
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(9),
                ],
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Ingresa el celular';
                  if (v.length != 9) {
                    return 'El celular debe tener exactamente 9 dígitos';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: _address,
                decoration: const InputDecoration(
                  labelText: 'Dirección (opcional)',
                  prefixIcon: Icon(Icons.home_outlined),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: AppSpacing.lg),
                AppMessageBanner(message: _error!),
              ],
              const SizedBox(height: AppSpacing.xl),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      )
                    : Text(_isEdit ? 'Guardar cambios' : 'Crear miembro'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
