import 'package:metro_city_pulse/core/provider/theme/app_theme_provider.dart';
import 'package:metro_city_pulse/core/themes/app_theme.dart';
import 'package:metro_city_pulse/presentation/screens/login/provider/login_providers.dart';
import 'package:metro_city_pulse/presentation/utils/localization_util.dart';
import 'package:metro_city_pulse/presentation/utils/navigation_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vvk_ui_kit/vvk_ui_kit.dart' hide NavigationUtil;

class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final theme = ref.watch(appThemeStateProvider);
    final Responsive layout = Responsive.of(context);
    final mobileHexagonHeight =
        (layout.size.height * 0.32).clamp(180.0, 250.0);

    return Scaffold(
      backgroundColor: theme.colors.background,
      body: SafeArea(
        child: !layout.isMobile
            ? Row(
                children: [
                  Expanded(flex: 4, child: buildHexagonSection(context, theme)),
                  buildFormSection(context, theme, formKey, ref),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: mobileHexagonHeight,
                    child: buildHexagonSection(context, theme),
                  ),
                  buildFormSection(
                    context,
                    theme,
                    formKey,
                    ref,
                    shouldExpand: true,
                  ),
                ],
              ),
      ),
    );
  }

  Widget buildHexagonSection(BuildContext context, AppTheme theme) {
    return Container(
      color: theme.colors.backgroundColor,
      alignment: Alignment.center,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final shortestSide = constraints.biggest.shortestSide;
          final logoSize = Responsive.isMobileContext(context)
              ? (shortestSide * 0.5).clamp(120.0, 210.0)
              : (shortestSide * 0.5).clamp(210.0, 550.0);

          return UIHexagon(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: Center(
              child: UIImage(
                theme.assets.policeDepartmentLogo,
                width: logoSize,
                height: Responsive.isMobileContext(context) ? logoSize : 280,
                fit: BoxFit.contain,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildBottomActionSection(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: UITextButton(
                text: 'create_account'.tr(ref).capitalizeAllFirstLetters(),
                onPressed: () {
                  NavigationUtil.push(context, '/signup');
                },
              ),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: UITextButton(
                text: 'forgot_password'.tr(ref).capitalizeAllFirstLetters(),
                onPressed: () {
                  NavigationUtil.push(context, '/forgotPassword');
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFormSection(
    BuildContext context,
    AppTheme theme,
    GlobalKey<FormState> formKey,
    WidgetRef ref, {
    bool shouldExpand = true,
  }) {
    final formSection = Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.isMobileContext(context) ? 22.0 : 60.0,
      ),
      child: SingleChildScrollView(
        //padding: EdgeInsets.symmetric(horizontal: 16.0),
        padding: const EdgeInsets.symmetric(vertical: 50),
        child: Form(
          key: formKey,
          child: _LoginFormBody(
            onLoginPressed: onLoginPressed,
            bottomActionSection: buildBottomActionSection(context, ref),
          ),
        ),
      ),
    );

    if (!shouldExpand) {
      return formSection;
    }

    return Expanded(flex: 5, child: formSection);
  }

  Future<void> onLoginPressed(WidgetRef ref, BuildContext context) async {
    final email = ref.read(emailProvider);
    final password = ref.read(passwordProvider);

    bool isValid = true;

    if (!isValidEmail(email)) {
      ref.read(emailErrorProvider.notifier).state = 'invalid_email_format'
          .tr(ref)
          .capitalizeAllFirstLetters();
      isValid = false;
    } else {
      ref.read(emailErrorProvider.notifier).state = null;
    }

    if (password.length < 6) {
      ref.read(passwordErrorProvider.notifier).state = 'password_min_6'
          .tr(ref)
          .capitalizeAllFirstLetters();
      isValid = false;
    } else {
      ref.read(passwordErrorProvider.notifier).state = null;
    }

    // if (_formKey.currentState!.validate()) {
    //
    // }
    if (isValid) {
      //await loginWithEmailAndPassword(ref, email, password);
      //final loginStatus = ref.read(loginStatusProvider);

      //TODO: Temporary login navigation
      NavigationUtil.pushReplace(context, '/home');

      // if (loginStatus == "success") {
      // if (true) {
      //   if (!context.mounted) return;
      //   ScaffoldMessenger.of(
      //     context,
      //   ).showSnackBar(const SnackBar(content: Text("Login successful")));
      //   NavigationUtil.pushReplace(context, '/home');
      // } else {
      //   // Show error dialog
      //   if (!context.mounted) return;
      //   showDialog(
      //     context: context,
      //     builder: (context) => AlertDialog(
      //       title: const Text("Login Failed"),
      //       content: Text(loginStatus ?? "Unknown error"),
      //       actions: [
      //         TextButton(
      //           onPressed: () => Navigator.pop(context),
      //           child: const Text("OK"),
      //         ),
      //       ],
      //     ),
      //   );
      // }
    }
  }
}

class _LoginFormBody extends ConsumerWidget {
  final Future<void> Function(WidgetRef ref, BuildContext context)
  onLoginPressed;
  final Widget bottomActionSection;

  const _LoginFormBody({
    required this.onLoginPressed,
    required this.bottomActionSection,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeStateProvider);
    final emailError = ref.watch(emailErrorProvider);
    final passwordError = ref.watch(passwordErrorProvider);
    final isPasswordVisible = ref.watch(passwordVisibleProvider);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Align(
          alignment: Alignment.center,
          child: UIText(
            'login_with_account'.tr(ref).capitalizeAllFirstLetters(),
            size: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.center,
          child: UIRichText(
            text: 'by_logging_in_agree'.tr(ref),
            textAlign: TextAlign.center,
            size: 14,
            fontWeight: FontWeight.w400,
            children: [
              {
                'title': ' ${'terms'.tr(ref).capitalizeAllFirstLetters()}',
                'color': theme.colors.primaryColor,
                'clickable': true,
              },
              {'title': ' ${'and'.tr(ref)} ', 'clickable': false},
              {
                'title': 'privacy_policy'.tr(ref).capitalizeAllFirstLetters(),
                'color': theme.colors.primaryColor,
                'clickable': true,
              },
            ],
            onChildTap: (index) {},
          ),
        ),
        const SizedBox(height: 22),
        UIElevatedButton(
          text: 'sso_log_in'.tr(ref).capitalizeAllFirstLetters(),
          onPressed: () {
            NavigationUtil.pushReplace(context, '/home');
          },
        ),
        const SizedBox(height: 16),
        UICenteredTextDivider(child: UIText('or'.tr(ref).toUpperCase(), size: 12)),
        const SizedBox(height: 24),
        UITextFormField(
          label: 'email_address'.tr(ref).capitalizeAllFirstLetters(),
          hintText: 'enter_your_email'.tr(ref).capitalizeAllFirstLetters(),
          errorText: emailError,
          keyboardType: TextInputType.emailAddress,
          validator: (value) => value == null || value.isEmpty
              ? 'email_required'.tr(ref).capitalizeAllFirstLetters()
              : !value.contains('@')
              ? 'enter_valid_email'.tr(ref).capitalizeAllFirstLetters()
              : null,
          onChanged: (value) => ref.read(emailProvider.notifier).state = value,
        ),
        const SizedBox(height: 24),
        UITextFormField(
          label: 'password'.tr(ref).capitalizeAllFirstLetters(),
          hintText: 'password'.tr(ref).capitalizeAllFirstLetters(),
          isPassword: true,
          obscureText: !isPasswordVisible,
          errorText: passwordError,
          validator: (value) => value == null || value.length < 6
              ? 'password_min_6'.tr(ref).capitalizeAllFirstLetters()
              : null,
          onChanged: (value) =>
              ref.read(passwordProvider.notifier).state = value,
          onToggleObscure: () {
            ref.read(passwordVisibleProvider.notifier).state =
                !isPasswordVisible;
          },
        ),
        const SizedBox(height: 24),
        UIElevatedButton(
          text: 'log_in'.tr(ref).capitalizeAllFirstLetters(),
          onPressed: () async {
            await onLoginPressed(ref, context);
          },
        ),
        const SizedBox(height: 16),
        bottomActionSection,
      ],
    );
  }
}
