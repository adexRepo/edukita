import 'package:edukita/core/localization/localization_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppFormValidation {
  AppFormValidation._();

  static const mobilePlaceholder = '0812345678912';
  static const mobileMinLength = 11;
  static const mobileMaxLength = 13;

  static List<TextInputFormatter> get mobileInputFormatters => [
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(mobileMaxLength),
  ];

  static String? requiredText(
    BuildContext context,
    String? value,
    String label, {
    int minLength = 1,
    int maxLength = 80,
  }) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return context.l10n.fieldRequiredMessage(label);
    if (text.length < minLength) {
      return context.l10n.fieldMinimumCharacters(label, minLength);
    }
    if (text.length > maxLength) {
      return context.l10n.fieldMaximumCharacters(label, maxLength);
    }
    return null;
  }

  static String? optionalText(
    BuildContext context,
    String? value,
    String label, {
    int maxLength = 80,
  }) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    if (text.length > maxLength) {
      return context.l10n.fieldMaximumCharacters(label, maxLength);
    }
    return null;
  }

  static String? requiredMobile(BuildContext context, String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return context.l10n.mobileNumberRequired;
    if (!RegExp(r'^\d{11,13}$').hasMatch(text)) {
      return context.l10n.mobileNumberLengthInvalid;
    }
    return null;
  }

  static String? optionalMobile(BuildContext context, String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    if (!RegExp(r'^\d{11,13}$').hasMatch(text)) {
      return context.l10n.mobileNumberLengthInvalid;
    }
    return null;
  }

  static String? requiredEmail(BuildContext context, String? value) {
    final textError = requiredText(
      context,
      value,
      context.l10n.email,
      maxLength: 120,
    );
    if (textError != null) return textError;
    return _validateEmail(context, value!.trim());
  }

  static String? optionalEmail(BuildContext context, String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    final textError = optionalText(
      context,
      text,
      context.l10n.email,
      maxLength: 120,
    );
    if (textError != null) return textError;
    return _validateEmail(context, text);
  }

  static String? _validateEmail(BuildContext context, String value) {
    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailPattern.hasMatch(value)) {
      return context.l10n.emailFormatInvalid;
    }
    return null;
  }
}
