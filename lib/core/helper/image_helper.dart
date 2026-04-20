import 'dart:io';
import 'package:flutter/material.dart';

ImageProvider getImageByLocalPath(String? path) {
  if (path == null || path.isEmpty) {
    return const AssetImage('assets/images/default_user.webp');
  }

  final file = File(path);

  if (file.existsSync()) {
    return FileImage(file);
  }

  return const AssetImage('assets/images/default_user.webp');
}
