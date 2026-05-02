import 'package:flutter/services.dart';

class AppFormValidation {
  AppFormValidation._();

  static const mobilePlaceholder = '0812345678912';
  static const mobileLength = 13;

  static List<TextInputFormatter> get mobileInputFormatters => [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(mobileLength),
      ];

  static String? requiredText(
    String? value,
    String label, {
    int minLength = 1,
    int maxLength = 80,
  }) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return '$label is required';
    if (text.length < minLength) {
      return '$label must be at least $minLength characters';
    }
    if (text.length > maxLength) {
      return '$label must be at most $maxLength characters';
    }
    return null;
  }

  static String? optionalText(
    String? value,
    String label, {
    int maxLength = 80,
  }) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    if (text.length > maxLength) {
      return '$label must be at most $maxLength characters';
    }
    return null;
  }

  static String? requiredMobile(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Mobile no is required';
    if (!RegExp(r'^\d{13}$').hasMatch(text)) {
      return 'Mobile no must be exactly 13 digits';
    }
    return null;
  }

  static String? optionalMobile(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    if (!RegExp(r'^\d{13}$').hasMatch(text)) {
      return 'Mobile no must be exactly 13 digits';
    }
    return null;
  }

  static String? requiredEmail(String? value) {
    final textError = requiredText(value, 'Email', maxLength: 120);
    if (textError != null) return textError;
    return _validateEmail(value!.trim());
  }

  static String? optionalEmail(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    final textError = optionalText(text, 'Email', maxLength: 120);
    if (textError != null) return textError;
    return _validateEmail(text);
  }

  static String? _validateEmail(String value) {
    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailPattern.hasMatch(value)) {
      return 'Email format is invalid';
    }
    return null;
  }
}
