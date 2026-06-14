import 'dart:convert';
import 'dart:io' as io;

import 'package:edukita/core/storage/app_storage_paths.dart';
import 'package:path/path.dart' as p;

class AuthSessionCache {
  AuthSessionCache._();

  static final AuthSessionCache instance = AuthSessionCache._();
  static const Duration sessionTtl = Duration(minutes: 2);

  Future<AuthSession?> read() async {
    final file = await _sessionFile();
    if (!await file.exists()) return null;

    try {
      final raw = await file.readAsString();
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final session = AuthSession.fromJson(data);
      if (session.expiresAt.isBefore(DateTime.now())) {
        await clear();
        return null;
      }
      return session;
    } catch (_) {
      await clear();
      return null;
    }
  }

  Future<void> save({
    required String userId,
    required String username,
    required String role,
    String? fullName,
    String? nickName,
    String? teacherId,
    bool mustChangePassword = false,
  }) async {
    final file = await _sessionFile();
    await file.parent.create(recursive: true);
    final session = AuthSession(
      userId: userId,
      username: username,
      role: role,
      fullName: fullName,
      nickName: nickName,
      teacherId: teacherId,
      mustChangePassword: mustChangePassword,
      expiresAt: DateTime.now().add(sessionTtl),
    );
    await file.writeAsString(jsonEncode(session.toJson()), flush: true);
  }

  Future<void> clear() async {
    final file = await _sessionFile();
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<io.File> _sessionFile() async {
    final root = await AppStoragePaths.appDataRoot();
    return io.File(p.join(root, 'cache', 'auth_session.json'));
  }
}

class AuthSession {
  const AuthSession({
    required this.userId,
    required this.username,
    required this.role,
    required this.expiresAt,
    this.fullName,
    this.nickName,
    this.teacherId,
    this.mustChangePassword = false,
  });

  final String userId;
  final String username;
  final String role;
  final String? fullName;
  final String? nickName;
  final String? teacherId;
  final bool mustChangePassword;
  final DateTime expiresAt;

  bool get isAdmin => role.toUpperCase() == 'ADMIN' || username == 'admin';
  bool get isStaff => role.toUpperCase() == 'STAFF';
  bool get isTeacher => role.toUpperCase() == 'TEACHER';

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      userId: json['user_id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      role: json['role']?.toString() ?? 'user',
      fullName: json['full_name']?.toString(),
      nickName: json['nick_name']?.toString(),
      teacherId: json['teacher_id']?.toString(),
      mustChangePassword: json['must_change_password'] == true,
      expiresAt:
          DateTime.tryParse(json['expires_at']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, Object?> toJson() {
    return {
      'user_id': userId,
      'username': username,
      'role': role,
      'full_name': fullName,
      'nick_name': nickName,
      'teacher_id': teacherId,
      'must_change_password': mustChangePassword,
      'expires_at': expiresAt.toIso8601String(),
    };
  }
}
