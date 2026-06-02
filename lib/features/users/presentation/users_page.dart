import 'package:edukita/core/helper/pageable.dart';
import 'package:edukita/features/auth/domain/auth_session_cache.dart';
import 'package:edukita/features/teachers/data/teacher_model.dart';
import 'package:edukita/features/users/data/user_model.dart';
import 'package:edukita/features/users/domain/user_authorization.dart';
import 'package:edukita/features/users/domain/user_management_cubit.dart';
import 'package:edukita/features/users/presentation/authorization_helpers.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:edukita/widgets/app_action_guard.dart';
import 'package:edukita/widgets/app_dialog_title.dart';
import 'package:edukita/widgets/app_loading.dart';
import 'package:edukita/widgets/app_page_header.dart';
import 'package:edukita/widgets/app_table.dart';
import 'package:edukita/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key, this.initialTeacher});

  final Teacher? initialTeacher;

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  String _query = '';
  bool _openedInitialTeacher = false;
  int _tabIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_openedInitialTeacher || widget.initialTeacher == null) return;
    _openedInitialTeacher = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _showUserDialog(initialTeacher: widget.initialTeacher);
    });
  }

  Future<void> _showUserDialog({User? user, Teacher? initialTeacher}) async {
    final cubit = context.read<UserManagementCubit>();
    var state = cubit.state;
    if (state.loading || state.currentUserId.isEmpty) {
      await cubit.load();
      if (!mounted) return;
      state = cubit.state;
    }
    final creating = user == null;
    if (creating && !state.canCreateUsers) {
      AppToast.showFailed('You do not have permission to create users.');
      return;
    }
    if (!creating && !state.canUpdateUsers) {
      AppToast.showFailed('You do not have permission to update users.');
      return;
    }
    final session = await AuthSessionCache.instance.read();
    if (!mounted) return;

    await showGuardedDialog<void>(
      context: context,
      guardKey: 'user_form_${user?.id ?? initialTeacher?.id ?? 'new'}',
      builder: (context) {
        return _UserDialog(
          user: user,
          currentUserId: session?.userId ?? '',
          currentRole: state.currentRole,
          currentAllowedMenuCodes: state.currentAllowedMenuCodes,
          creatableRoles: state.creatableRoles,
          teachers: state.availableTeachers,
          initialTeacher: initialTeacher,
          initialExtraMenuCodes: user == null
              ? const <String>[]
              : state.extraAccessByUser[user.id] ?? const <String>[],
          onSave: (draft, extraMenuCodes) async {
            if (user == null) {
              await cubit.createUser(draft, extraMenuCodes);
            } else {
              await cubit.updateUser(draft, extraMenuCodes);
            }
          },
        );
      },
    );
  }

  Future<void> _toggleActive(User user) async {
    if (user.username == 'admin') return;
    final state = context.read<UserManagementCubit>().state;
    if (!state.canDeleteUsers) {
      AppToast.showFailed('You do not have permission to activate or deactivate users.');
      return;
    }
    final targetActive = !user.isActive;
    final confirmed = await showGuardedDialog<bool>(
      context: context,
      guardKey: 'toggle_user_${user.id}',
      builder: (context) {
        return AlertDialog(
          title: AppDialogTitle(targetActive ? 'Activate User' : 'Deactivate User'),
          content: Text(
            '${targetActive ? 'Activate' : 'Deactivate'} ${user.fullName}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(targetActive ? 'Activate' : 'Deactivate'),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) return;
    await context.read<UserManagementCubit>().setUserActive(user.id, targetActive);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<UserManagementCubit, UserManagementState>(
        builder: (context, state) {
          final users = _filteredUsers(state.users);
          final isAdmin = state.currentRole.isAdmin;
          if (!state.loading && !state.canViewUsers) {
            return const AccessDeniedPanel(
              message: 'You do not have permission to view user management.',
            );
          }
          return Column(
            children: [
              Padding(
                padding: AppPageHeaderStyle.pagePadding,
                child: AppPageHeader(
                  title: 'User Management',
                  subtitle: isAdmin
                      ? 'Manage users, role permissions, teacher links, and special access.'
                      : 'Manage app users, teacher links, and extra menu access.',
                  trailing: (!isAdmin || _tabIndex == 0) && state.canCreateUsers
                      ? FilledButton.icon(
                          onPressed: () => _showUserDialog(),
                          icon: const Icon(Icons.add),
                          label: const Text('Add User'),
                        )
                      : null,
                ),
              ),
              AppLoadingStrip(isLoading: state.loading),
              if (isAdmin)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: SegmentedButton<int>(
                      selected: {_tabIndex},
                      onSelectionChanged: (selected) {
                        setState(() => _tabIndex = selected.first);
                      },
                      segments: const [
                        ButtonSegment(
                          value: 0,
                          icon: Icon(Icons.people_alt_outlined),
                          label: Text('Users'),
                        ),
                        ButtonSegment(
                          value: 1,
                          icon: Icon(Icons.admin_panel_settings_outlined),
                          label: Text('Roles & Permissions'),
                        ),
                      ],
                    ),
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: state.error != null
                      ? Center(child: Text(state.error!))
                      : isAdmin && _tabIndex == 1
                          ? _RolePermissionsPanel(
                              rolePermissions: state.rolePermissions,
                              onSave: (role, permissions) => context
                                  .read<UserManagementCubit>()
                                  .saveRolePermissions(role, permissions),
                            )
                          : Column(
                              children: [
                                TextField(
                                  onChanged: (value) =>
                                      setState(() => _query = value),
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(Icons.search),
                                    hintText:
                                        'Search username, full name, or teacher',
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Expanded(child: _buildTable(users, state)),
                              ],
                            ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<User> _filteredUsers(List<User> users) {
    final normalized = _query.trim().toLowerCase();
    if (normalized.isEmpty) return users;
    return users.where((user) {
      return user.username.toLowerCase().contains(normalized) ||
          user.fullName.toLowerCase().contains(normalized) ||
          user.role.label.toLowerCase().contains(normalized) ||
          (user.teacherName ?? '').toLowerCase().contains(normalized);
    }).toList();
  }

  Widget _buildTable(List<User> users, UserManagementState state) {
    return AppTable<User>(
      data: users,
      pageable: Pageable(
        page: 0,
        size: users.length,
        totalPages: 1,
        totalItems: users.length,
      ),
      columns: [
        AppTableColumn(
          title: 'User',
          flex: 4,
          minWidth: 180,
          sortValue: (user) =>
              user.fullName.isEmpty ? 0 : user.fullName.codeUnitAt(0),
          cell: (user) => Text(
            '${user.fullName}\n@${user.username}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, height: 1.2),
          ),
        ),
        AppTableColumn(
          title: 'Role',
          flex: 2,
          minWidth: 110,
          cell: (user) => _pill(user.role.label),
        ),
        AppTableColumn(
          title: 'Teacher Link',
          flex: 3,
          minWidth: 160,
          cell: (user) => Text(
            user.teacherName ?? '-',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12),
          ),
        ),
        AppTableColumn(
          title: 'Status',
          flex: 2,
          minWidth: 100,
          cell: (user) => _pill(
            user.isActive ? 'Active' : 'Inactive',
            color: user.isActive ? AppColors.primaryDark : AppColors.errorDark,
          ),
        ),
        AppTableColumn(
          title: 'Extra Access',
          flex: 3,
          minWidth: 170,
          cell: (user) {
            final count = state.extraAccessByUser[user.id]?.length ?? 0;
            return Text(
              count == 0 ? '-' : '$count menu${count == 1 ? '' : 's'}',
              style: const TextStyle(fontSize: 12),
            );
          },
        ),
        AppTableColumn(
          title: 'Actions',
          flex: 2,
          minWidth: 120,
          cell: (user) {
            final canEdit = state.currentRole.canManage(user.role) ||
                state.currentRole.isAdmin;
            final canUpdate = canEdit && state.canUpdateUsers;
            final canDelete = canEdit && state.canDeleteUsers;
            final protectedAdmin = user.username == 'admin';
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Edit user',
                  onPressed: canUpdate ? () => _showUserDialog(user: user) : null,
                  constraints:
                      const BoxConstraints.tightFor(width: 28, height: 28),
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.edit, size: 16),
                ),
                IconButton(
                  tooltip: user.isActive ? 'Deactivate' : 'Activate',
                  onPressed: canDelete && !protectedAdmin
                      ? () => _toggleActive(user)
                      : null,
                  constraints:
                      const BoxConstraints.tightFor(width: 28, height: 28),
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    user.isActive
                        ? Icons.block_outlined
                        : Icons.check_circle_outline,
                    size: 16,
                    color: user.isActive
                        ? AppColors.error
                        : AppColors.primaryDark,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _pill(String label, {Color color = AppColors.textSecondary}) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _RolePermissionsPanel extends StatefulWidget {
  const _RolePermissionsPanel({
    required this.rolePermissions,
    required this.onSave,
  });

  final Map<AppUserRole, Map<String, AppMenuPermission>> rolePermissions;
  final Future<void> Function(
    AppUserRole role,
    Map<String, AppMenuPermission> permissions,
  ) onSave;

  @override
  State<_RolePermissionsPanel> createState() => _RolePermissionsPanelState();
}

class _RolePermissionsPanelState extends State<_RolePermissionsPanel> {
  AppUserRole _selectedRole = AppUserRole.staff;
  late Map<String, AppMenuPermission> _draft;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _draft = _permissionsFor(_selectedRole);
  }

  @override
  void didUpdateWidget(covariant _RolePermissionsPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rolePermissions != widget.rolePermissions) {
      _draft = _permissionsFor(_selectedRole);
    }
  }

  Map<String, AppMenuPermission> _permissionsFor(AppUserRole role) {
    final source = widget.rolePermissions[role] ??
        AppMenuAccessRegistry.defaultPermissionsForRole(role);
    return {
      for (final menu in AppMenuAccessRegistry.all)
        menu.code: source[menu.code] ?? AppMenuPermission.none(menu.code),
    };
  }

  void _changeRole(AppUserRole role) {
    setState(() {
      _selectedRole = role;
      _draft = _permissionsFor(role);
    });
  }

  void _toggle(
    AppMenuAccess menu,
    AppPermissionAction action,
    bool value,
  ) {
    final current = _draft[menu.code] ?? AppMenuPermission.none(menu.code);
    var next = switch (action) {
      AppPermissionAction.view => current.copyWith(
          canView: value,
          canCreate: value ? current.canCreate : false,
          canUpdate: value ? current.canUpdate : false,
          canDelete: value ? current.canDelete : false,
          canExport: value ? current.canExport : false,
          canApprove: value ? current.canApprove : false,
        ),
      AppPermissionAction.create => current.copyWith(canCreate: value),
      AppPermissionAction.update => current.copyWith(canUpdate: value),
      AppPermissionAction.delete => current.copyWith(canDelete: value),
      AppPermissionAction.export => current.copyWith(canExport: value),
      AppPermissionAction.approve => current.copyWith(canApprove: value),
    };
    if (action != AppPermissionAction.view && value) {
      next = next.copyWith(canView: true);
    }
    setState(() => _draft[menu.code] = next);
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await widget.onSave(_selectedRole, _draft);
      AppToast.showSuccess('${_selectedRole.label} permissions updated.');
    } catch (e) {
      AppToast.showFailed(e.toString().replaceFirst('Bad state: ', ''));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _permissionCheck(AppMenuAccess menu, AppPermissionAction action) {
    final permission = _draft[menu.code] ?? AppMenuPermission.none(menu.code);
    return SizedBox(
      width: double.infinity,
      child: Center(
        child: SizedBox(
          width: 32,
          height: 32,
          child: Checkbox(
            value: permission.allows(action),
            onChanged: (value) => _toggle(menu, action, value ?? false),
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Roles & Permissions',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Admin always has full access. Configure menu actions for Staff and Teacher roles.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 220,
                child: SegmentedButton<AppUserRole>(
                  selected: {_selectedRole},
                  onSelectionChanged: (selected) => _changeRole(selected.first),
                  segments: const [
                    ButtonSegment(
                      value: AppUserRole.staff,
                      label: SizedBox(
                        width: 74,
                        child: Text('Staff', textAlign: TextAlign.center),
                      ),
                    ),
                    ButtonSegment(
                      value: AppUserRole.teacher,
                      label: SizedBox(
                        width: 74,
                        child: Text('Teacher', textAlign: TextAlign.center),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: const Icon(Icons.save_outlined),
                label: Text(_saving ? 'Saving...' : 'Save'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: AppTable<AppMenuAccess>(
            data: AppMenuAccessRegistry.all,
            pageable: Pageable(
              page: 0,
              size: AppMenuAccessRegistry.all.length,
              totalPages: 1,
              totalItems: AppMenuAccessRegistry.all.length,
            ),
            emptyMessage: 'No menu available',
            columns: [
              AppTableColumn(
                title: 'Menu',
                flex: 3,
                minWidth: 220,
                cell: (menu) => Text(
                  menu.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              for (final action in AppPermissionAction.values)
                AppTableColumn(
                  title: action.label,
                  flex: 1,
                  minWidth: 92,
                  alignment: Alignment.center,
                  headerTextAlign: TextAlign.center,
                  cell: (menu) => _permissionCheck(menu, action),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _UserDialog extends StatefulWidget {
  const _UserDialog({
    required this.currentUserId,
    required this.currentRole,
    required this.currentAllowedMenuCodes,
    required this.creatableRoles,
    required this.teachers,
    required this.initialExtraMenuCodes,
    required this.onSave,
    this.user,
    this.initialTeacher,
  });

  final User? user;
  final Teacher? initialTeacher;
  final String currentUserId;
  final AppUserRole currentRole;
  final Set<String> currentAllowedMenuCodes;
  final List<AppUserRole> creatableRoles;
  final List<Teacher> teachers;
  final List<String> initialExtraMenuCodes;
  final Future<void> Function(User user, List<String> extraMenuCodes) onSave;

  @override
  State<_UserDialog> createState() => _UserDialogState();
}

class _UserDialogState extends State<_UserDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  late final TextEditingController _nickNameController;
  late final TextEditingController _fullNameController;
  late AppUserRole _role;
  String? _teacherId;
  late Set<String> _extraMenuCodes;
  bool _saving = false;

  bool get _editing => widget.user != null;

  @override
  void initState() {
    super.initState();
    final user = widget.user;
    _role = user?.role ??
        (widget.initialTeacher != null
            ? AppUserRole.teacher
            : widget.creatableRoles.isEmpty
                ? AppUserRole.teacher
                : widget.creatableRoles.first);
    _teacherId = user?.teacherId ?? widget.initialTeacher?.id;
    _usernameController = TextEditingController(text: user?.username ?? '');
    _passwordController = TextEditingController();
    _nickNameController = TextEditingController(
      text: user?.nickName ?? widget.initialTeacher?.nickName ?? '',
    );
    _fullNameController = TextEditingController(
      text: user?.fullName ?? widget.initialTeacher?.fullName ?? '',
    );
    _extraMenuCodes = Set<String>.of(widget.initialExtraMenuCodes);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _nickNameController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final existing = widget.user;
      final password = _passwordController.text.trim();
      final user = User(
        id: existing?.id,
        username: _usernameController.text.trim(),
        password: _editing && password.isEmpty ? existing!.password : password,
        nickName: _nickNameController.text.trim(),
        fullName: _fullNameController.text.trim(),
        role: _role,
        teacherId: _role.isTeacher ? _teacherId : null,
        isActive: existing?.isActive ?? true,
        createdBy: existing?.createdBy ?? widget.currentUserId,
      );
      await widget.onSave(user, _extraMenuCodes.toList());
      AppToast.showSuccess(_editing ? 'User updated.' : 'User created.');
      if (mounted) Navigator.pop(context);
    } catch (e) {
      AppToast.showFailed(e.toString().replaceFirst('Bad state: ', ''));
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final roleOptions = _editing
        ? [_role]
        : widget.creatableRoles.isEmpty
            ? [_role]
            : widget.creatableRoles;
    final teachers = _teacherOptions();
    final defaultRoleMenus = AppMenuAccessRegistry.defaultCodesForRole(_role);
    final extraMenus = AppMenuAccessRegistry.all.where((menu) {
      return !defaultRoleMenus.contains(menu.code) &&
          widget.currentAllowedMenuCodes.contains(menu.code);
    }).toList();

    return AlertDialog(
      title: AppDialogTitle(_editing ? 'Edit User' : 'Create User'),
      content: SizedBox(
        width: 620,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _usernameController,
                        enabled: !_editing,
                        decoration: const InputDecoration(labelText: 'Username'),
                        validator: _requiredMin('Username', 3),
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(32),
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z0-9._-]'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText:
                              _editing ? 'New Password' : 'Password',
                          hintText: _editing ? 'Leave empty to keep' : null,
                        ),
                        validator: (value) {
                          if (!_editing &&
                              (value == null || value.trim().isEmpty)) {
                            return 'Password is required';
                          }
                          if ((value?.trim().isNotEmpty ?? false) &&
                              value!.trim().length < 4) {
                            return 'Password must be at least 4 characters';
                          }
                          return null;
                        },
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(64),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _nickNameController,
                        decoration: const InputDecoration(labelText: 'Nickname'),
                        validator: _requiredMin('Nickname', 2),
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(40),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _fullNameController,
                        decoration: const InputDecoration(labelText: 'Full Name'),
                        validator: _requiredMin('Full name', 3),
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(80),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<AppUserRole>(
                        initialValue: _role,
                        decoration: const InputDecoration(labelText: 'Role'),
                        items: roleOptions
                            .map(
                              (role) => DropdownMenuItem(
                                value: role,
                                child: Text(role.label),
                              ),
                            )
                            .toList(),
                        onChanged: _editing
                            ? null
                            : (role) {
                                if (role == null) return;
                                setState(() {
                                  _role = role;
                                  if (!_role.isTeacher) _teacherId = null;
                                  _extraMenuCodes.clear();
                                });
                              },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _role.isTeacher ? _teacherId : null,
                        decoration: const InputDecoration(labelText: 'Teacher'),
                        items: teachers
                            .map(
                              (teacher) => DropdownMenuItem(
                                value: teacher.id,
                                child: Text(
                                  teacher.fullName,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: !_role.isTeacher
                            ? null
                            : (teacherId) =>
                                setState(() => _teacherId = teacherId),
                        validator: (_) {
                          if (_role.isTeacher && _teacherId == null) {
                            return 'Teacher is required';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Extra Menu Access',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                  ),
                ),
                const SizedBox(height: 8),
                if (extraMenus.isEmpty)
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'No extra menu access available for this role.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final menu in extraMenus)
                        FilterChip(
                          label: Text(menu.label),
                          selected: _extraMenuCodes.contains(menu.code),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _extraMenuCodes.add(menu.code);
                              } else {
                                _extraMenuCodes.remove(menu.code);
                              }
                            });
                          },
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: Text(_saving ? 'Saving...' : 'Save'),
        ),
      ],
    );
  }

  List<Teacher> _teacherOptions() {
    final teachers = List<Teacher>.of(widget.teachers);
    final user = widget.user;
    if (widget.initialTeacher != null &&
        !teachers.any((teacher) => teacher.id == widget.initialTeacher!.id)) {
      teachers.insert(0, widget.initialTeacher!);
    }
    final linkedTeacherId = user?.teacherId;
    if (linkedTeacherId != null &&
        !teachers.any((teacher) => teacher.id == linkedTeacherId)) {
      teachers.insert(
        0,
        Teacher(
          id: linkedTeacherId,
          fullName: user?.teacherName ?? 'Linked teacher',
        ),
      );
    }
    return teachers;
  }

  FormFieldValidator<String> _requiredMin(String label, int min) {
    return (value) {
      final trimmed = value?.trim() ?? '';
      if (trimmed.isEmpty) return '$label is required';
      if (trimmed.length < min) return '$label is too short';
      return null;
    };
  }
}
