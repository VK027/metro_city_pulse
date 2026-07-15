import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:metro_city_pulse/presentation/utils/localization_util.dart';
import 'package:vvk_ui_kit/vvk_ui_kit.dart';

// Email and Password state
final emailProvider = StateProvider<String>((ref) => '');
final passwordProvider = StateProvider<String>((ref) => '');

// Password visibility toggle
final passwordVisibleProvider = StateProvider<bool>((ref) => false);

// Validation state
final emailErrorProvider = StateProvider<String?>((ref) => null);
final passwordErrorProvider = StateProvider<String?>((ref) => null);
final loadingProvider = StateProvider<bool>((ref) => false);

// signup state obsur
final signupPasswordVisibleProvider = StateProvider<bool>((ref) => false);

// Validator function (can be moved to utils later)
bool isValidEmail(String email) {
  return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
}

bool validateInputs(WidgetRef ref) {
  final email = ref.read(emailProvider);
  final password = ref.read(passwordProvider);

  bool isValid = true;

  if (!isValidEmail(email)) {
    ref.read(emailErrorProvider.notifier).state = "invalid_email"
        .tr(ref)
        .capitalizeAllFirstLetters();
    isValid = false;
  } else {
    ref.read(emailErrorProvider.notifier).state = null;
  }

  if (password.length < 6) {
    ref.read(passwordErrorProvider.notifier).state = "min_6_characters"
        .tr(ref)
        .capitalizeAllFirstLetters();
    isValid = false;
  } else {
    ref.read(passwordErrorProvider.notifier).state = null;
  }

  return isValid;
}

void showErrorDialog(
  BuildContext context,
  String title,
  String message, {
  String okLabel = "OK",
}) {
  UIAlertDialog.show(
    context,
    title: title,
    message: message,
    confirmLabel: okLabel,
  );
}
