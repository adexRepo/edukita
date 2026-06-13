import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

class PasswordService {
  PasswordService._();

  static const _prefix = 'pbkdf2_sha256';
  static const _iterations = 60000;
  static const _saltLength = 16;
  static const _keyLength = 32;

  static String hash(String password) {
    final random = Random.secure();
    final salt = List<int>.generate(_saltLength, (_) => random.nextInt(256));
    final digest = _derive(utf8.encode(password), salt, _iterations, _keyLength);
    return '$_prefix\$$_iterations\$${base64UrlEncode(salt)}\$${base64UrlEncode(digest)}';
  }

  static bool verify(String password, String storedValue) {
    if (!storedValue.startsWith('$_prefix\$')) {
      return _constantTimeEquals(utf8.encode(password), utf8.encode(storedValue));
    }

    final parts = storedValue.split(r'$');
    if (parts.length != 4) return false;
    final iterations = int.tryParse(parts[1]);
    if (iterations == null || iterations <= 0) return false;

    try {
      final salt = base64Url.decode(base64Url.normalize(parts[2]));
      final expected = base64Url.decode(base64Url.normalize(parts[3]));
      final actual = _derive(
        utf8.encode(password),
        salt,
        iterations,
        expected.length,
      );
      return _constantTimeEquals(actual, expected);
    } catch (_) {
      return false;
    }
  }

  static bool isHashed(String value) => value.startsWith('$_prefix\$');

  static List<int> _derive(
    List<int> password,
    List<int> salt,
    int iterations,
    int keyLength,
  ) {
    final hmac = Hmac(sha256, password);
    final result = <int>[];
    for (var block = 1; result.length < keyLength; block++) {
      final blockBytes = [
        ...salt,
        (block >> 24) & 0xff,
        (block >> 16) & 0xff,
        (block >> 8) & 0xff,
        block & 0xff,
      ];
      var u = hmac.convert(blockBytes).bytes;
      final t = List<int>.from(u);
      for (var index = 1; index < iterations; index++) {
        u = hmac.convert(u).bytes;
        for (var byte = 0; byte < t.length; byte++) {
          t[byte] ^= u[byte];
        }
      }
      result.addAll(t);
    }
    return result.sublist(0, keyLength);
  }

  static bool _constantTimeEquals(List<int> left, List<int> right) {
    if (left.length != right.length) return false;
    var difference = 0;
    for (var index = 0; index < left.length; index++) {
      difference |= left[index] ^ right[index];
    }
    return difference == 0;
  }
}
