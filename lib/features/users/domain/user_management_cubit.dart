import 'package:edukita/features/auth/domain/auth_session_cache.dart';
import 'package:edukita/features/teachers/data/teacher_model.dart';
import 'package:edukita/features/users/data/user_model.dart';
import 'package:edukita/features/users/domain/user_authorization.dart';
import 'package:edukita/features/users/domain/user_management_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserManagementState {
  const UserManagementState({
    this.users = const [],
    this.availableTeachers = const [],
    this.extraAccessByUser = const {},
    this.rolePermissions = const {},
    this.currentRole = AppUserRole.teacher,
    this.currentUserId = '',
    this.currentAllowedMenuCodes = const {},
    this.currentPermissions = const {},
    this.loading = false,
    this.error,
  });

  final List<User> users;
  final List<Teacher> availableTeachers;
  final Map<String, List<String>> extraAccessByUser;
  final Map<AppUserRole, Map<String, AppMenuPermission>> rolePermissions;
  final AppUserRole currentRole;
  final String currentUserId;
  final Set<String> currentAllowedMenuCodes;
  final Map<String, AppMenuPermission> currentPermissions;
  final bool loading;
  final String? error;

  List<AppUserRole> get creatableRoles => currentRole.creatableRoles();
  bool get canViewUsers =>
      currentRole.isAdmin ||
      (currentPermissions[AppMenuAccessRegistry.users.code]?.canView ?? false);
  bool get canCreateUsers =>
      creatableRoles.isNotEmpty &&
      (currentRole.isAdmin ||
          (currentPermissions[AppMenuAccessRegistry.users.code]?.canCreate ??
              false));
  bool get canUpdateUsers =>
      currentRole.isAdmin ||
      (currentPermissions[AppMenuAccessRegistry.users.code]?.canUpdate ?? false);
  bool get canDeleteUsers =>
      currentRole.isAdmin ||
      (currentPermissions[AppMenuAccessRegistry.users.code]?.canDelete ?? false);

  UserManagementState copyWith({
    List<User>? users,
    List<Teacher>? availableTeachers,
    Map<String, List<String>>? extraAccessByUser,
    Map<AppUserRole, Map<String, AppMenuPermission>>? rolePermissions,
    AppUserRole? currentRole,
    String? currentUserId,
    Set<String>? currentAllowedMenuCodes,
    Map<String, AppMenuPermission>? currentPermissions,
    bool? loading,
    String? error,
  }) {
    return UserManagementState(
      users: users ?? this.users,
      availableTeachers: availableTeachers ?? this.availableTeachers,
      extraAccessByUser: extraAccessByUser ?? this.extraAccessByUser,
      rolePermissions: rolePermissions ?? this.rolePermissions,
      currentRole: currentRole ?? this.currentRole,
      currentUserId: currentUserId ?? this.currentUserId,
      currentAllowedMenuCodes:
          currentAllowedMenuCodes ?? this.currentAllowedMenuCodes,
      currentPermissions: currentPermissions ?? this.currentPermissions,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

class UserManagementCubit extends Cubit<UserManagementState> {
  UserManagementCubit(this._repository)
    : super(const UserManagementState());

  final UserManagementRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final session = await AuthSessionCache.instance.read();
      final currentRole = AppUserRole.fromValue(session?.role);
      final currentUserId = session?.userId ?? '';
      final scope = currentUserId.isEmpty || currentRole.isAdmin
          ? AppAuthorizationScope(
              role: currentRole.isAdmin ? AppUserRole.admin : currentRole,
              permissions:
                  AppMenuAccessRegistry.defaultPermissionsForRole(currentRole),
            )
          : await _repository.getAuthorizationScopeForUser(currentUserId);
      final canViewUsers = scope.canView(AppMenuAccessRegistry.users.code);
      final users = canViewUsers
          ? await _repository.getUsers(includeAdmin: currentRole.isAdmin)
          : const <User>[];
      final canManageTeacherLinks =
          scope.canCreate(AppMenuAccessRegistry.users.code) ||
          scope.canUpdate(AppMenuAccessRegistry.users.code);
      final availableTeachers = canViewUsers && canManageTeacherLinks
          ? await _repository.getTeachersWithoutUsers()
          : const <Teacher>[];
      final extraAccess = canViewUsers
          ? await _repository.getAllUserExtraMenuCodes()
          : const <String, List<String>>{};
      final rolePermissions = currentRole.isAdmin
          ? await _repository.getManageableRolePermissions()
          : const <AppUserRole, Map<String, AppMenuPermission>>{};
      final currentAllowed = scope.permissions.entries
          .where((entry) => entry.value.canView)
          .map((entry) => entry.key)
          .toSet();

      emit(
        state.copyWith(
          users: users,
          availableTeachers: availableTeachers,
          extraAccessByUser: extraAccess,
          rolePermissions: rolePermissions,
          currentRole: currentRole,
          currentUserId: currentUserId,
          currentAllowedMenuCodes: currentAllowed,
          currentPermissions: scope.permissions,
          loading: false,
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> createUser(User user, List<String> extraMenuCodes) async {
    await _repository.createUser(
      user: user,
      createdBy: state.currentUserId,
      extraMenuCodes: extraMenuCodes,
    );
    await load();
  }

  Future<void> updateUser(User user, List<String> extraMenuCodes) async {
    await _repository.updateUser(
      user: user,
      extraMenuCodes: extraMenuCodes,
      updatedBy: state.currentUserId,
    );
    await load();
  }

  Future<void> setUserActive(String userId, bool active) async {
    await _repository.setUserActive(userId, active);
    await load();
  }

  Future<void> saveRolePermissions(
    AppUserRole role,
    Map<String, AppMenuPermission> permissions,
  ) async {
    if (!state.currentRole.isAdmin) {
      throw StateError('Only admin can manage role permissions.');
    }
    await _repository.saveRolePermissions(
      role: role,
      permissions: permissions,
    );
    await load();
  }
}
