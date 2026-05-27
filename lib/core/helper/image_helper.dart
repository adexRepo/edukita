import 'dart:io';
import 'package:flutter/painting.dart';

ImageProvider getImageByLocalPath(
  String? path, {
  int? cacheWidth,
  int? cacheHeight,
}) {
  if (path == null || path.isEmpty) {
    return const AssetImage('assets/images/default_user.webp');
  }

  final file = File(path);

  if (file.existsSync()) {
    final image = FileImage(file);
    if (cacheWidth != null || cacheHeight != null) {
      return ResizeImage(
        image,
        width: cacheWidth,
        height: cacheHeight,
        policy: ResizeImagePolicy.fit,
      );
    }
    return image;
  }

  return const AssetImage('assets/images/default_user.webp');
}
