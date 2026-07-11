import 'package:metro_city_pulse/core/provider/theme/app_theme_provider.dart';
import 'package:metro_city_pulse/presentation/screens/login/provider/auth_provider.dart';
import 'package:metro_city_pulse/presentation/screens/login/provider/login_providers.dart';
import 'package:metro_city_pulse/presentation/utils/localization_util.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vvk_ui_kit/vvk_ui_kit.dart';

class ForgotPasswordScreen extends ConsumerWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final email = ref.watch(emailProvider);
    final emailError = ref.watch(emailErrorProvider);
    final isLoading = ref.watch(loadingProvider);
    final theme = ref.watch(appThemeStateProvider);

    return Scaffold(
      backgroundColor: theme.colors.background,
      appBar: UIAppBar(
        title: "forgot_password".tr(ref).capitalizeAllFirstLetters(),
        showBackButton: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UITextFormField(
              label: "email".tr(ref).capitalizeAllFirstLetters(),
              hintText: "enter_your_email".tr(ref).capitalizeAllFirstLetters(),
              keyboardType: TextInputType.emailAddress,
              errorText: emailError,
              validator: (value) => value == null || value.isEmpty
                  ? "email_required".tr(ref).capitalizeAllFirstLetters()
                  : !value.contains('@')
                  ? "enter_valid_email".tr(ref).capitalizeAllFirstLetters()
                  : null,
              onChanged: (value) =>
                  ref.read(emailProvider.notifier).state = value,
            ),
            const SizedBox(height: 24),
            isLoading
                ? const UILoadingIndicator()
                : UIElevatedButton(
                    text: "send_reset_email".tr(ref).capitalizeAllFirstLetters(),
                    onPressed: () async {
                      if (!isValidEmail(email)) {
                        ref.read(emailErrorProvider.notifier).state =
                            "invalid_email".tr(ref).capitalizeAllFirstLetters();
                        return;
                      }

                      ref.read(emailErrorProvider.notifier).state = null;
                      ref.read(loadingProvider.notifier).state = true;

                      final result = await sendPasswordReset(ref, email);

                      ref.read(loadingProvider.notifier).state = false;

                      if (result == null) {
                        if (!context.mounted) return;
                        UISnackbar.showDefault(
                          context: context,
                          message: "reset_email_sent_successfully"
                              .tr(ref)
                              .capitalizeAllFirstLetters(),
                          type: UISnackbarType.success,
                        );
                        if (!context.mounted) return;
                        Navigator.pop(context);
                      } else {
                        if (!context.mounted) return;
                        showErrorDialog(
                          context,
                          "reset_failed".tr(ref).capitalizeAllFirstLetters(),
                          result,
                          okLabel: "ok".tr(ref).toUpperCase(),
                        );
                      }
                    },
                  ),
          ],
        ),
      ),
    );
  }
}

Future<String?> sendPasswordReset(WidgetRef ref, String email) async {
  try {
    await ref.read(authProvider).sendPasswordResetEmail(email: email);
    return null;
  } on FirebaseAuthException catch (e) {
    return e.message;
  }
}
