import 'package:metro_city_pulse/core/provider/language_provider.dart';
import 'package:metro_city_pulse/core/provider/theme/app_theme_provider.dart';
import 'package:metro_city_pulse/core/themes/app_theme.dart';
import 'package:metro_city_pulse/core/themes/app_theme_mode.dart';
import 'package:metro_city_pulse/presentation/utils/localization_util.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vvk_ui_kit/vvk_ui_kit.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(languageProvider)!;
    final themeMode = ref.watch(appThemeStateProvider);

    return Scaffold(
      appBar: UIAppBar(
        title: "settings".tr(ref).capitalizeAllFirstLetters(),
        showBackButton: true,
        backgroundColor: themeMode.colors.appBarBackgroundColor,
        titleColor: Colors.white,
        iconColor: Colors.white,
        toolbarHeight: kToolbarHeight,
        centerTitle: true,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: isWide
                ? Column(
                    children: [
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(child: _buildLocaleCard(ref, locale)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildThemeCard(ref, themeMode)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _saveButton(ref),
                    ],
                  )
                : ListView(
                    shrinkWrap: true,
                    children: [
                      _buildLocaleCard(ref, locale),
                      const SizedBox(height: 16),
                      _buildThemeCard(ref, themeMode),
                      const SizedBox(height: 16),
                      _saveButton(ref),
                    ],
                  ),
          );
        },
      ),
    );
  }

  Widget _buildLocaleCard(WidgetRef ref, Locale locale) {
    return UICard(
      borderRadius: 16,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UIText(
            "language".tr(ref).capitalizeAllFirstLetters(),
            size: 18,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 8),
          RadioGroup<Locale>(
            groupValue: locale,
            onChanged: (Locale? val) {
              ref
                  .read(languageProvider.notifier)
                  .changeLocale(val!.languageCode);
            },
            child: Column(
              children: <Widget>[
                RadioListTile<Locale>(
                  title: UIText("english".tr(ref)),
                  value: supportedLocales[0],
                ),
                RadioListTile<Locale>(
                  title: UIText("spanish".tr(ref)),
                  value: supportedLocales[1],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeCard(WidgetRef ref, AppTheme themeMode) {
    return UICard(
      borderRadius: 16,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UIText(
            "theme".tr(ref).capitalizeAllFirstLetters(),
            size: 18,
            fontWeight: FontWeight.bold,
          ),
          SwitchListTile(
            title: UIText("dark_mode".tr(ref).capitalizeAllFirstLetters()),
            value: themeMode.mode == AppThemeMode.dark,
            onChanged: (val) {
              ref.read(appThemeStateProvider.notifier).toggle(val);
            },
          ),
        ],
      ),
    );
  }

  Widget _saveButton(WidgetRef ref) {
    return UIElevatedButton(
      onPressed: () async {
        // Persist changes using Riverpod notifiers
        // await ref.read(localeProvider.notifier).setLocale(_tempLocale);
        // await ref.read(themeProvider.notifier).setTheme(_tempTheme);
        UISnackbar.showDefault(
          context: ref.context,
          message: "settings_saved".tr(ref).capitalizeAllFirstLetters(),
          type: UISnackbarType.success,
        );
      },
      text: "save".tr(ref).capitalizeAllFirstLetters(),
    );
  }

  // bool get _hasChanges {
  //   final currentLocale = ref.read(localeProvider);
  //   final currentTheme = ref.read(themeProvider);
  //   return _tempLocale != currentLocale || _tempTheme != currentTheme;
  // }
}
