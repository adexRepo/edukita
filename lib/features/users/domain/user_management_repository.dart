import 'package:edukita/core/database/database_provider.dart';
import 'package:edukita/features/teachers/data/teacher_model.dart';
import 'package:edukita/features/auth/domain/password_service.dart';
import 'package:edukita/features/users/data/user_model.dart';
import 'package:edukita/features/users/domain/user_authorization.dart';
import 'package:sqflite_common/sqlite_api.dart';

class UserManagementRepository {
  UserManagementRepository(this._dbProvider);

  final DatabaseProvider _dbProvider;

  Future<List<User>> getUsers({bool includeAdmin = false}) async {
    final db = await _db();
    final whereClause = includeAdmin ? '' : "WHERE UPPER(u.role) != 'ADMIN'";
    final rows = await db.rawQuery('''
      SELECT u.*, teacher.full_name AS teacher_name
      FROM users u
      LEFT JOIN teachers teacher ON teacher.id = u.teacher_id
      $whereClause
      ORDER BY
        CASE UPPER(u.role)
          WHEN 'ADMIN' THEN 0
          WHEN 'STAFF' THEN 1
          WHEN 'TEACHER' THEN 2
          ELSE 9
        END,
        u.full_name ASC
    ''');
    return rows.map(User.fromMap).toList();
  }

  Future<List<Teacher>> getTeachersWithoutUsers({String? currentUserId}) async {
    final db = await _db();
    final args = <Object?>[];
    final currentUserJoinClause = currentUserId == null
        ? ''
        : 'AND linked_user.id != ?';
    if (currentUserId != null) args.add(currentUserId);
    final rows = await db.rawQuery('''
      SELECT teacher.*
      FROM teachers teacher
      LEFT JOIN users linked_user
        ON linked_user.teacher_id = teacher.id
       AND COALESCE(linked_user.is_active, 1) = 1
       $currentUserJoinClause
      WHERE linked_user.id IS NULL
      ORDER BY teacher.full_name ASC
    ''', args);
    return rows.map(Teacher.fromMap).toList();
  }

  Future<List<String>> getUserExtraMenuCodes(String userId) async {
    final db = await _db();
    final rows = await db.query(
      'user_menu_permission_overrides',
      columns: const ['menu_code'],
      where: 'user_id = ? AND can_view = 1',
      whereArgs: [userId],
      orderBy: 'menu_code ASC',
    );
    return rows.map((row) => row['menu_code'].toString()).toList();
  }

  Future<Map<String, List<String>>> getAllUserExtraMenuCodes() async {
    final db = await _db();
    final rows = await db.query(
      'user_menu_permission_overrides',
      columns: const ['user_id', 'menu_code'],
      where: 'can_view = 1',
      orderBy: 'user_id ASC, menu_code ASC',
    );
    final result = <String, List<String>>{};
    for (final row in rows) {
      final userId = row['user_id']?.toString();
      final menuCode = row['menu_code']?.toString();
      if (userId == null || userId.isEmpty || menuCode == null) continue;
      result.putIfAbsent(userId, () => <String>[]).add(menuCode);
    }
    return result;
  }

  Future<Set<String>> getAllowedMenuCodesForUser(String userId) async {
    final db = await _db();
    final userRows = await db.query(
      'users',
      where: 'id = ? AND COALESCE(is_active, 1) = 1',
      whereArgs: [userId],
      limit: 1,
    );
    if (userRows.isEmpty) return const <String>{};

    final role = AppUserRole.fromValue(userRows.first['role']?.toString());
    final roleCodes = await _roleMenuCodes(db, role);
    final extraCodes = await getUserExtraMenuCodes(userId);
    return {...roleCodes, ...extraCodes};
  }

  Future<AppAuthorizationScope> getAuthorizationScopeForUser(
    String userId,
  ) async {
    final db = await _db();
    final userRows = await db.query(
      'users',
      where: 'id = ? AND COALESCE(is_active, 1) = 1',
      whereArgs: [userId],
      limit: 1,
    );
    if (userRows.isEmpty) {
      return AppAuthorizationScope(
        role: AppUserRole.teacher,
        permissions: const {},
      );
    }

    final user = userRows.first;
    final role = AppUserRole.fromValue(user['role']?.toString());
    final permissions = await _rolePermissions(db, role);
    final overrideRows = await db.query(
      'user_menu_permission_overrides',
      where: 'user_id = ? AND can_view = 1',
      whereArgs: [userId],
    );
    for (final row in overrideRows) {
      final permission = _permissionFromRow(row);
      permissions[permission.menuCode] = _mergePermission(
        permissions[permission.menuCode],
        permission,
      );
    }

    return AppAuthorizationScope(
      role: role,
      teacherId: user['teacher_id']?.toString(),
      permissions: permissions,
    );
  }

  Future<Set<String>> getDefaultMenuCodesForRole(AppUserRole role) async {
    final db = await _db();
    return _roleMenuCodes(db, role);
  }

  Future<Map<AppUserRole, Map<String, AppMenuPermission>>>
      getManageableRolePermissions() async {
    final db = await _db();
    final result = <AppUserRole, Map<String, AppMenuPermission>>{};
    for (final role in const [AppUserRole.staff, AppUserRole.teacher]) {
      result[role] = await _rolePermissions(db, role);
    }
    return result;
  }

  Future<void> saveRolePermissions({
    required AppUserRole role,
    required Map<String, AppMenuPermission> permissions,
  }) async {
    if (role.isAdmin) {
      throw StateError('Admin permission cannot be restricted.');
    }
    final db = await _db();
    await db.transaction((txn) async {
      await txn.delete(
        'role_menu_permissions',
        where: 'role = ?',
        whereArgs: [role.value],
      );
      final now = DateTime.now().toIso8601String();
      for (final menu in AppMenuAccessRegistry.all) {
        final permission =
            permissions[menu.code] ?? AppMenuPermission.none(menu.code);
        await txn.insert('role_menu_permissions', {
          'id': '${role.value}:${menu.code}',
          'role': role.value,
          'menu_code': menu.code,
          'can_view': permission.canView ? 1 : 0,
          'can_create': permission.canCreate ? 1 : 0,
          'can_update': permission.canUpdate ? 1 : 0,
          'can_delete': permission.canDelete ? 1 : 0,
          'can_export': permission.canExport ? 1 : 0,
          'can_approve': permission.canApprove ? 1 : 0,
          'created_at': now,
          'updated_at': now,
        });
      }
    });
  }

  Future<User> createUser({
    required User user,
    required String createdBy,
    required List<String> extraMenuCodes,
  }) async {
    final db = await _db();
    return db.transaction((txn) async {
      await _validateUser(txn, user);
      final record = user.copyWith(
        createdBy: createdBy,
        password: PasswordService.hash(user.password),
        mustChangePassword: true,
      );
      await txn.insert('users', record.toMap());
      await _replaceUserExtraMenus(txn, record.id, extraMenuCodes, createdBy);
      return record;
    });
  }

  Future<void> updateUser({
    required User user,
    required List<String> extraMenuCodes,
    required String updatedBy,
  }) async {
    final db = await _db();
    await db.transaction((txn) async {
      await _validateUser(txn, user, editingUserId: user.id);
      final existing = await txn.query(
        'users',
        columns: const ['password', 'must_change_password', 'password_changed_at'],
        where: 'id = ?',
        whereArgs: [user.id],
        limit: 1,
      );
      if (existing.isEmpty) {
        throw StateError('User not found.');
      }
      final current = existing.first;
      final passwordChanged = user.password != current['password'];
      final record = user.copyWith(
        password: passwordChanged
            ? PasswordService.hash(user.password)
            : current['password']?.toString(),
        mustChangePassword: passwordChanged
            ? true
            : (current['must_change_password'] as num?)?.toInt() != 0,
        passwordChangedAt: current['password_changed_at']?.toString(),
      );
      await txn.update(
        'users',
        record.toMap(),
        where: 'id = ?',
        whereArgs: [user.id],
      );
      await _replaceUserExtraMenus(txn, user.id, extraMenuCodes, updatedBy);
    });
  }

  Future<void> setUserActive(String userId, bool active) async {
    final db = await _db();
    await db.update(
      'users',
      {
        'is_active': active ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ? AND username != ?',
      whereArgs: [userId, 'admin'],
    );
  }

  Future<Database> _db() async {
    final db = await _dbProvider.database;
    return db;
  }

  Future<Set<String>> _roleMenuCodes(Database db, AppUserRole role) async {
    final rows = await db.query(
      'role_menu_permissions',
      columns: const ['menu_code', 'can_view'],
      where: 'role = ?',
      whereArgs: [role.value],
    );
    if (rows.isEmpty) {
      return AppMenuAccessRegistry.defaultCodesForRole(role);
    }
    return rows
        .where((row) => _flag(row['can_view']))
        .map((row) => row['menu_code'].toString())
        .toSet();
  }

  Future<Map<String, AppMenuPermission>> _rolePermissions(
    Database db,
    AppUserRole role,
  ) async {
    final rows = await db.query(
      'role_menu_permissions',
      where: 'role = ?',
      whereArgs: [role.value],
    );
    if (rows.isEmpty) {
      return AppMenuAccessRegistry.defaultPermissionsForRole(role);
    }
    return {
      for (final row in rows)
        _permissionFromRow(row).menuCode: _permissionFromRow(row),
    };
  }

  AppMenuPermission _permissionFromRow(Map<String, Object?> row) {
    final menuCode = row['menu_code']?.toString() ?? '';
    return AppMenuPermission(
      menuCode: menuCode,
      canView: _flag(row['can_view']),
      canCreate: _flag(row['can_create']),
      canUpdate: _flag(row['can_update']),
      canDelete: _flag(row['can_delete']),
      canExport: _flag(row['can_export']),
      canApprove: _flag(row['can_approve']),
    );
  }

  AppMenuPermission _mergePermission(
    AppMenuPermission? base,
    AppMenuPermission extra,
  ) {
    final current = base ?? AppMenuPermission.none(extra.menuCode);
    return current.copyWith(
      canView: current.canView || extra.canView,
      canCreate: current.canCreate || extra.canCreate,
      canUpdate: current.canUpdate || extra.canUpdate,
      canDelete: current.canDelete || extra.canDelete,
      canExport: current.canExport || extra.canExport,
      canApprove: current.canApprove || extra.canApprove,
    );
  }

  bool _flag(Object? value) => (value as num?)?.toInt() == 1;

  Future<void> _validateUser(
    DatabaseExecutor txn,
    User user, {
    String? editingUserId,
  }) async {
    if (user.role.isTeacher && user.teacherId == null) {
      throw StateError('Teacher user must be linked to a teacher profile.');
    }
    if (!user.role.isTeacher && user.teacherId != null) {
      throw StateError('Only teacher users can be linked to teacher profiles.');
    }

    final usernameRows = await txn.query(
      'users',
      where: editingUserId == null ? 'username = ?' : 'username = ? AND id != ?',
      whereArgs: editingUserId == null
          ? [user.username]
          : [user.username, editingUserId],
      limit: 1,
    );
    if (usernameRows.isNotEmpty) {
      throw StateError('Username already exists.');
    }

    if (user.teacherId != null) {
      final teacherRows = await txn.query(
        'users',
        where: editingUserId == null
            ? 'teacher_id = ? AND COALESCE(is_active, 1) = 1'
            : 'teacher_id = ? AND id != ? AND COALESCE(is_active, 1) = 1',
        whereArgs: editingUserId == null
            ? [user.teacherId]
            : [user.teacherId, editingUserId],
        limit: 1,
      );
      if (teacherRows.isNotEmpty) {
        throw StateError('This teacher already has an active app user.');
      }
    }
  }

  Future<void> _replaceUserExtraMenus(
    DatabaseExecutor txn,
    String userId,
    List<String> menuCodes,
    String changedBy,
  ) async {
    await txn.delete(
      'user_menu_permission_overrides',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    final now = DateTime.now().toIso8601String();
    for (final code in menuCodes.toSet()) {
      await txn.insert('user_menu_permission_overrides', {
        'id': '$userId:$code',
        'user_id': userId,
        'menu_code': code,
        'can_view': 1,
        'created_by': changedBy,
        'created_at': now,
        'updated_at': now,
      });
    }
  }
}
