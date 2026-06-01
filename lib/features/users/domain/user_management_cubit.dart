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
    this.currentRole = AppUserRole.teacher,
    this.currentUserId = '',
    this.currentAllowedMenuCodes = const {},
    this.loading = false,
    this.error,
  });

  final List<User> users;
  final List<Teacher> availableTeachers;
  final Map<String, List<String>> extraAccessByUser;
  final AppUserRole currentRole;
  final String currentUserId;
  final Set<String> currentAllowedMenuCodes;
  final bool loading;
  final String? error;

  List<AppUserRole> get creatableRoles => currentRole.creatableRoles();
  bool get canCreateUsers => creatableRoles.isNotEmpty;

  UserManagementState copyWith({
    List<User>? users,
    List<Teacher>? availableTeachers,
    Map<String, List<String>>? extraAccessByUser,
    AppUserRole? currentRole,
    String? currentUserId,
    Set<String>? currentAllowedMenuCodes,
    bool? loading,
    String? error,
  }) {
    return UserManagementState(
      users: users ?? this.users,
      availableTeachers: availableTeachers ?? this.availableTeachers,
      extraAccessByUser: extraAccessByUser ?? this.extraAccessByUser,
      currentRole: currentRole ?? this.currentRole,
      currentUserId: currentUserId ?? this.currentUserId,
      currentAllowedMenuCodes:
          currentAllowedMenuCodes ?? this.currentAllowedMenuCodes,
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
      final users = await _repository.getUsers();
      final availableTeachers = await _repository.getTeachersWithoutUsers();
      final extraAccess = <String, List<String>>{};
      for (final user in users) {
        extraAccess[user.id] = await _repository.getUserExtraMenuCodes(user.id);
      }
      final currentAllowed = currentUserId.isEmpty
          ? AppMenuAccessRegistry.defaultCodesForRole(currentRole)
          : await _repository.getAllowedMenuCodesForUser(currentUserId);

      emit(
        state.copyWith(
          users: users,
          availableTeachers: availableTeachers,
          extraAccessByUser: extraAccess,
          currentRole: currentRole,
          currentUserId: currentUserId,
          currentAllowedMenuCodes: currentAllowed,
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
}
