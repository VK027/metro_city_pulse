import 'package:metro_city_pulse/core/provider/theme/app_theme_provider.dart';
import 'package:metro_city_pulse/presentation/screens/login/provider/auth_provider.dart';
import 'package:metro_city_pulse/presentation/screens/login/provider/login_providers.dart';
import 'package:metro_city_pulse/presentation/utils/localization_util.dart';
import 'package:metro_city_pulse/presentation/utils/navigation_util.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vvk_ui_kit/vvk_ui_kit.dart' hide NavigationUtil;

class SignupScreen extends ConsumerWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final email = ref.watch(emailProvider);
    final password = ref.watch(passwordProvider);
    final emailError = ref.watch(emailErrorProvider);
    final passwordError = ref.watch(passwordErrorProvider);
    final isLoading = ref.watch(loadingProvider);
    final theme = ref.watch(appThemeStateProvider);

    return Scaffold(
      backgroundColor: theme.colors.background,
      appBar: UIAppBar(
        title: "create_account".tr(ref).capitalizeAllFirstLetters(),
        showBackButton: true,
        backgroundColor: theme.colors.appBarBackgroundColor,
        titleColor: Colors.white,
        iconColor: Colors.white,
        toolbarHeight: kToolbarHeight,
        centerTitle: true,
        fontSize: 18,
        fontWeight: FontWeight.w600,
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
            const SizedBox(height: 16),
            UITextFormField(
              label: "password".tr(ref).capitalizeAllFirstLetters(),
              hintText: "enter_password".tr(ref).capitalizeAllFirstLetters(),
              isPassword: true,
              obscureText: !ref.watch(signupPasswordVisibleProvider),
              errorText: passwordError,
              validator: (value) => value == null || value.length < 6
                  ? "min_6_characters".tr(ref).capitalizeAllFirstLetters()
                  : null,
              onChanged: (value) =>
                  ref.read(passwordProvider.notifier).state = value,
              onToggleObscure: () {
                ref.read(signupPasswordVisibleProvider.notifier).state = !ref
                    .read(signupPasswordVisibleProvider);
              },
            ),

            const SizedBox(height: 24),
            isLoading
                ? const UILoadingIndicator()
                : Center(
                    child: SizedBox(
                      child: UIElevatedButton(
                        text: "sign_up".tr(ref).capitalizeAllFirstLetters(),
                        isFullWidth: true,
                        onPressed: () async {
                          final valid = validateInputs(ref);
                          if (!valid) return;

                          ref.read(loadingProvider.notifier).state = true;

                          final result = await createAccount(
                            ref,
                            email,
                            password,
                          );

                          ref.read(loadingProvider.notifier).state = false;

                          if (result == null) {
                            if (!context.mounted) return;
                            UISnackbar.showDefault(
                              context: context,
                              message:
                                  "account_created".tr(ref).capitalizeAllFirstLetters(),
                              type: UISnackbarType.success,
                            );
                            NavigationUtil.pushReplace(context, '/home');
                          } else {
                            if (!context.mounted) return;
                            showErrorDialog(
                              context,
                              "sign_up_failed".tr(ref).capitalizeAllFirstLetters(),
                              result,
                              okLabel: "ok".tr(ref).toUpperCase(),
                            );
                          }
                        },
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

Future<String?> createAccount(
  WidgetRef ref,
  String email,
  String password,
) async {
  try {
    await ref
        .read(authProvider)
        .createUserWithEmailAndPassword(email: email, password: password);
    return null; // success
  } on FirebaseAuthException catch (e) {
    return e.message;
  }
}
