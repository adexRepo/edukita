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
