import 'package:edukita/core/router/service_locator.dart';
import 'package:edukita/features/auth/domain/auth_session_cache.dart';
import 'package:edukita/features/users/domain/user_authorization.dart';
import 'package:edukita/features/users/domain/user_management_repository.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:flutter/material.dart';

Future<AppAuthorizationScope> loadCurrentAuthorizationScope() async {
  final session = await AuthSessionCache.instance.read();
  if (session == null) {
    return AppAuthorizationScope(
      role: AppUserRole.teacher,
      permissions: const {},
    );
  }
  if (session.isAdmin) {
    return AppAuthorizationScope(
      role: AppUserRole.admin,
      permissions: AppMenuAccessRegistry.defaultPermissionsForRole(
        AppUserRole.admin,
      ),
    );
  }
  return getIt<UserManagementRepository>().getAuthorizationScopeForUser(
    session.userId,
  );
}

class AccessDeniedPanel extends StatelessWidget {
  const AccessDeniedPanel({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
