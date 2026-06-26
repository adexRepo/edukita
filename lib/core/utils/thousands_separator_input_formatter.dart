import 'package:flutter/services.dart';

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  const ThousandsSeparatorInputFormatter();

  static String digitsOnly(String value) {
    return value.replaceAll(RegExp(r'[^0-9]'), '');
  }

  static String normalizedDigits(String value) {
    final digits = digitsOnly(value);
    if (digits.isEmpty) return '';
    final normalized = digits.replaceFirst(RegExp(r'^0+'), '');
    return normalized.isEmpty ? '0' : normalized;
  }

  static String format(String value) {
    final digits = normalizedDigits(value);
    if (digits.length <= 3) return digits;

    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      final remaining = digits.length - i;
      buffer.write(digits[i]);
      if (remaining > 1 && remaining % 3 == 1) {
        buffer.write('.');
      }
    }
    return buffer.toString();
  }

  static double? parseDouble(String value) {
    final digits = normalizedDigits(value);
    if (digits.isEmpty) return null;
    return double.tryParse(digits);
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final formatted = format(newValue.text);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
