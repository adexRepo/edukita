import 'package:edukita/features/users/domain/user_authorization.dart';
import 'package:uuid/uuid.dart';

class User {
  User({
    String? id,
    required this.username,
    required this.password,
    required this.nickName,
    required this.fullName,
    this.role = AppUserRole.staff,
    this.teacherId,
    this.teacherName,
    this.isActive = true,
    this.mustChangePassword = true,
    this.passwordChangedAt,
    this.createdBy,
  }) : id = id ?? const Uuid().v4();

  final String id;
  final String username;
  final String password;
  final String nickName;
  final String fullName;
  final AppUserRole role;
  final String? teacherId;
  final String? teacherName;
  final bool isActive;
  final bool mustChangePassword;
  final String? passwordChangedAt;
  final String? createdBy;

  User copyWith({
    String? id,
    String? username,
    String? password,
    String? nickName,
    String? fullName,
    AppUserRole? role,
    String? teacherId,
    String? teacherName,
    bool? isActive,
    bool? mustChangePassword,
    String? passwordChangedAt,
    String? createdBy,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      nickName: nickName ?? this.nickName,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      teacherId: teacherId ?? this.teacherId,
      teacherName: teacherName ?? this.teacherName,
      isActive: isActive ?? this.isActive,
      mustChangePassword: mustChangePassword ?? this.mustChangePassword,
      passwordChangedAt: passwordChangedAt ?? this.passwordChangedAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  factory User.fromMap(Map<String, Object?> map) {
    return User(
      id: map['id'] as String?,
      username: map['username'] as String,
      password: map['password'] as String,
      nickName: map['nick_name'] as String,
      fullName: map['full_name'] as String,
      role: AppUserRole.fromValue(map['role']?.toString()),
      teacherId: map['teacher_id'] as String?,
      teacherName: map['teacher_name'] as String?,
      isActive: (map['is_active'] as num?)?.toInt() != 0,
      mustChangePassword:
          (map['must_change_password'] as num?)?.toInt() != 0,
      passwordChangedAt: map['password_changed_at'] as String?,
      createdBy: map['created_by'] as String?,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'nick_name': nickName,
      'full_name': fullName,
      'role': role.value,
      'teacher_id': teacherId,
      'is_active': isActive ? 1 : 0,
      'must_change_password': mustChangePassword ? 1 : 0,
      'password_changed_at': passwordChangedAt,
      'created_by': createdBy,
    };
  }

  factory User.sample() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return User(
      username: 'guest$timestamp',
      password: 'guest',
      nickName: 'Guest',
      fullName: 'Guest User',
      role: AppUserRole.staff,
    );
  }
}
