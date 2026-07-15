import 'package:metro_city_pulse/core/provider/language_provider.dart';
import 'package:metro_city_pulse/core/provider/theme/app_theme_provider.dart';
import 'package:metro_city_pulse/core/themes/app_theme.dart';
import 'package:metro_city_pulse/core/themes/app_theme_mode.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vvk_ui_kit/vvk_ui_kit.dart';

class AppBarActionButtons extends ConsumerWidget {
  static const double _kControlHeight = 36;
  static const double _kControlGap = 8;

  final AppTheme theme;

  const AppBarActionButtons({super.key, required this.theme});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = Responsive.isMobileContext(context);
    final isDark = theme.mode == AppThemeMode.dark;
    final locale = ref.watch(languageProvider);
    final langCode = (locale?.languageCode ?? 'en').toUpperCase();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _LanguageSelectorButton(
          theme: theme,
          langCode: langCode,
          isMobile: isMobile,
          height: _kControlHeight,
          onLanguageChanged: (code) {
            ref.read(languageProvider.notifier).changeLocale(code);
          },
        ),
        const SizedBox(width: _kControlGap),
        _ActionIconButton(
          theme: theme,
          icon: isDark
              ? Icons.light_mode_rounded
              : Icons.dark_mode_rounded,
          tooltip: isDark ? 'Light Mode' : 'Dark Mode',
          size: _kControlHeight,
          onPressed: () {
            ref.read(appThemeStateProvider.notifier).toggle(!isDark);
          },
        ),
      ],
    );
  }

}

class _LanguageSelectorButton extends StatelessWidget {
  final AppTheme theme;
  final String langCode;
  final bool isMobile;
  final double height;
  final ValueChanged<String> onLanguageChanged;

  const _LanguageSelectorButton({
    required this.theme,
    required this.langCode,
    required this.isMobile,
    required this.height,
    required this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 40),
      elevation: 2,
      color: theme.colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      tooltip: 'Change Language',
      onSelected: onLanguageChanged,
      itemBuilder: (context) => [
        _buildLanguageItem('en', 'English'),
        _buildLanguageItem('es', 'Español'),
      ],
      child: Container(
        height: height,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: theme.colors.background,
          borderRadius: BorderRadius.circular(height / 2),
          border: Border.all(color: theme.colors.lightGray.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.language_rounded,
              size: 18,
              color: theme.colors.text,
            ),
            const SizedBox(width: 4),
            UIText(
              langCode,
              size: 12,
              fontWeight: FontWeight.w600,
              color: theme.colors.text,
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildLanguageItem(String code, String label) {
    final isSelected = langCode == code.toUpperCase();
    return PopupMenuItem<String>(
      value: code,
      height: 40,
      child: Row(
        children: [
          Icon(
            isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
            size: 18,
            color: isSelected ? theme.colors.primaryColor : theme.colors.gray,
          ),
          const SizedBox(width: 8),
          UIText(
            label,
            size: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: theme.colors.text,
          ),
        ],
      ),
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  final AppTheme theme;
  final IconData icon;
  final String tooltip;
  final double size;
  final VoidCallback onPressed;

  const _ActionIconButton({
    required this.theme,
    required this.icon,
    required this.tooltip,
    required this.size,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(size / 2),
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: theme.colors.background,
            shape: BoxShape.circle,
            border: Border.all(color: theme.colors.lightGray.withValues(alpha: 0.4)),
          ),
          child: Icon(
            icon,
            size: 18,
            color: theme.colors.text,
          ),
        ),
      ),
    );
  }
}
