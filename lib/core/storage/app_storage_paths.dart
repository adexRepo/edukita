import 'dart:io' as io;

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path/path.dart' as p;

class AppStoragePaths {
  AppStoragePaths._();

  static const String appFolderName = 'Edukita';

  static Future<String> databaseDirectory() {
    return resolveDirectory(dotenv.env['DB_PATH'], 'database');
  }

  static Future<String> storageDirectory() {
    return resolveDirectory(dotenv.env['STORAGE_PATH'], 'storage');
  }

  static Future<String> resolveDirectory(
    String? configuredPath,
    String fallbackRelativePath,
  ) async {
    if (kIsWeb) return fallbackRelativePath;

    final raw = configuredPath?.trim();
    final path = raw == null || raw.isEmpty ? fallbackRelativePath : raw;
    final resolved = p.isAbsolute(path) ? path : p.join(await appDataRoot(), path);
    final directory = io.Directory(resolved);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory.path;
  }

  static Future<String> appDataRoot() async {
    if (kIsWeb) return '.';

    final envRoot = dotenv.env['APP_DATA_PATH']?.trim();
    if (envRoot != null && envRoot.isNotEmpty) {
      final resolved = p.isAbsolute(envRoot)
          ? envRoot
          : p.join(io.Directory.current.path, envRoot);
      final directory = io.Directory(resolved);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      return directory.path;
    }

    final platformRoot =
        io.Platform.environment['LOCALAPPDATA'] ??
        io.Platform.environment['APPDATA'] ??
        io.Platform.environment['HOME'] ??
        io.Directory.current.path;
    final directory = io.Directory(p.join(platformRoot, appFolderName));
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory.path;
  }
}
