enum AppUserRole {
  admin('ADMIN', 'Admin', 0),
  staff('STAFF', 'Staff', 1),
  teacher('TEACHER', 'Teacher', 2);

  const AppUserRole(this.value, this.label, this.level);

  final String value;
  final String label;
  final int level;

  bool get isAdmin => this == AppUserRole.admin;
  bool get isStaff => this == AppUserRole.staff;
  bool get isTeacher => this == AppUserRole.teacher;

  List<AppUserRole> creatableRoles() {
    return switch (this) {
      AppUserRole.admin => const [AppUserRole.staff, AppUserRole.teacher],
      AppUserRole.staff => const [AppUserRole.teacher],
      AppUserRole.teacher => const [],
    };
  }

  bool canManage(AppUserRole target) {
    if (isAdmin) return true;
    return level < target.level;
  }

  static AppUserRole fromValue(String? value) {
    final normalized = value?.trim().toUpperCase();
    for (final role in AppUserRole.values) {
      if (role.value == normalized || role.name.toUpperCase() == normalized) {
        return role;
      }
    }
    if (normalized == 'USER') return AppUserRole.staff;
    return AppUserRole.teacher;
  }
}

enum AppPermissionAction {
  view('can_view', 'View'),
  create('can_create', 'Create'),
  update('can_update', 'Update'),
  delete('can_delete', 'Delete'),
  export('can_export', 'Export'),
  approve('can_approve', 'Approve');

  const AppPermissionAction(this.column, this.label);

  final String column;
  final String label;
}

class AppMenuPermission {
  const AppMenuPermission({
    required this.menuCode,
    required this.canView,
    required this.canCreate,
    required this.canUpdate,
    required this.canDelete,
    required this.canExport,
    required this.canApprove,
  });

  final String menuCode;
  final bool canView;
  final bool canCreate;
  final bool canUpdate;
  final bool canDelete;
  final bool canExport;
  final bool canApprove;

  bool allows(AppPermissionAction action) {
    return switch (action) {
      AppPermissionAction.view => canView,
      AppPermissionAction.create => canCreate,
      AppPermissionAction.update => canUpdate,
      AppPermissionAction.delete => canDelete,
      AppPermissionAction.export => canExport,
      AppPermissionAction.approve => canApprove,
    };
  }

  AppMenuPermission copyWith({
    bool? canView,
    bool? canCreate,
    bool? canUpdate,
    bool? canDelete,
    bool? canExport,
    bool? canApprove,
  }) {
    return AppMenuPermission(
      menuCode: menuCode,
      canView: canView ?? this.canView,
      canCreate: canCreate ?? this.canCreate,
      canUpdate: canUpdate ?? this.canUpdate,
      canDelete: canDelete ?? this.canDelete,
      canExport: canExport ?? this.canExport,
      canApprove: canApprove ?? this.canApprove,
    );
  }

  static AppMenuPermission none(String menuCode) {
    return AppMenuPermission(
      menuCode: menuCode,
      canView: false,
      canCreate: false,
      canUpdate: false,
      canDelete: false,
      canExport: false,
      canApprove: false,
    );
  }

  static AppMenuPermission viewOnly(String menuCode) {
    return AppMenuPermission.none(menuCode).copyWith(canView: true);
  }

  static AppMenuPermission manage(String menuCode) {
    return AppMenuPermission(
      menuCode: menuCode,
      canView: true,
      canCreate: true,
      canUpdate: true,
      canDelete: true,
      canExport: true,
      canApprove: true,
    );
  }
}

class AppAuthorizationScope {
  const AppAuthorizationScope({
    required this.role,
    required this.permissions,
    this.teacherId,
  });

  final AppUserRole role;
  final String? teacherId;
  final Map<String, AppMenuPermission> permissions;

  bool get isAdmin => role.isAdmin;
  bool get isStaff => role.isStaff;
  bool get isTeacher => role.isTeacher;

  bool can(String menuCode, AppPermissionAction action) {
    if (isAdmin) return true;
    return permissions[menuCode]?.allows(action) ?? false;
  }

  bool canView(String menuCode) => can(menuCode, AppPermissionAction.view);
  bool canCreate(String menuCode) => can(menuCode, AppPermissionAction.create);
  bool canUpdate(String menuCode) => can(menuCode, AppPermissionAction.update);
  bool canDelete(String menuCode) => can(menuCode, AppPermissionAction.delete);

  bool ownsTeacherData(String? targetTeacherId) {
    if (!isTeacher) return true;
    return teacherId != null &&
        targetTeacherId != null &&
        teacherId == targetTeacherId;
  }
}

class AppMenuAccess {
  const AppMenuAccess({
    required this.code,
    required this.label,
    required this.route,
  });

  final String code;
  final String label;
  final String route;
}

class AppMenuAccessRegistry {
  AppMenuAccessRegistry._();

  static const dashboard = AppMenuAccess(
    code: 'dashboard',
    label: 'Dashboard',
    route: '/dashboard',
  );
  static const students = AppMenuAccess(
    code: 'students',
    label: 'Students',
    route: '/students',
  );
  static const teachers = AppMenuAccess(
    code: 'teachers',
    label: 'Teachers',
    route: '/teachers',
  );
  static const parameters = AppMenuAccess(
    code: 'parameters',
    label: 'Parameter',
    route: '/parameters',
  );
  static const schedules = AppMenuAccess(
    code: 'schedules',
    label: 'Schedule',
    route: '/schedules',
  );
  static const teachingActivities = AppMenuAccess(
    code: 'teaching_activities',
    label: 'Teaching Activity',
    route: '/teaching-activities',
  );
  static const assistancePrograms = AppMenuAccess(
    code: 'assistance_programs',
    label: 'Assistance Programs',
    route: '/assistance-programs',
  );
  static const reports = AppMenuAccess(
    code: 'reports',
    label: 'Reports',
    route: '/reports',
  );
  static const users = AppMenuAccess(
    code: 'users',
    label: 'User Management',
    route: '/users',
  );

  static const all = <AppMenuAccess>[
    dashboard,
    students,
    teachers,
    parameters,
    schedules,
    teachingActivities,
    assistancePrograms,
    reports,
    users,
  ];

  static const defaultRoleMenuCodes = <AppUserRole, Set<String>>{
    AppUserRole.admin: {
      'dashboard',
      'students',
      'teachers',
      'parameters',
      'schedules',
      'teaching_activities',
      'assistance_programs',
      'reports',
      'users',
    },
    AppUserRole.staff: {
      'dashboard',
      'students',
      'teachers',
      'parameters',
      'schedules',
      'teaching_activities',
      'assistance_programs',
      'reports',
      'users',
    },
    AppUserRole.teacher: {
      'dashboard',
      'schedules',
      'teaching_activities',
    },
  };

  static Map<String, AppMenuPermission> defaultPermissionsForRole(
    AppUserRole role,
  ) {
    final result = <String, AppMenuPermission>{};
    for (final menu in all) {
      final canView = defaultCodesForRole(role).contains(menu.code);
      if (!canView) continue;
      result[menu.code] = switch (role) {
        AppUserRole.admin => AppMenuPermission.manage(menu.code),
        AppUserRole.staff => _staffPermission(menu.code),
        AppUserRole.teacher => _teacherPermission(menu.code),
      };
    }
    return result;
  }

  static AppMenuPermission _staffPermission(String menuCode) {
    if (menuCode == users.code) {
      return AppMenuPermission.viewOnly(menuCode).copyWith(
        canCreate: true,
        canUpdate: true,
      );
    }
    if (menuCode == reports.code) {
      return AppMenuPermission.viewOnly(menuCode).copyWith(canExport: true);
    }
    return AppMenuPermission.manage(menuCode);
  }

  static AppMenuPermission _teacherPermission(String menuCode) {
    if (menuCode == teachingActivities.code) {
      return AppMenuPermission.viewOnly(menuCode).copyWith(
        canCreate: true,
        canUpdate: true,
      );
    }
    return AppMenuPermission.viewOnly(menuCode);
  }

  static Set<String> defaultCodesForRole(AppUserRole role) {
    return Set<String>.of(defaultRoleMenuCodes[role] ?? const <String>{});
  }

  static AppMenuAccess? byRoute(String route) {
    for (final menu in all) {
      if (route.startsWith(menu.route)) return menu;
    }
    return null;
  }
}
