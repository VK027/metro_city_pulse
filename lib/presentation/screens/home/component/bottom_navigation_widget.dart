import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:metro_city_pulse/core/themes/app_theme.dart';
import 'package:metro_city_pulse/presentation/utils/localization_util.dart';
import 'package:vvk_ui_kit/vvk_ui_kit.dart';

class BottomNavigationWidget extends ConsumerWidget {
  static const double _iconSize = 20.0;

  final AppTheme theme;
  final int? currentIndex;
  final ValueChanged<int>? onTap;

  const BottomNavigationWidget({
    super.key,
    required this.theme,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Color selectedColor = theme.colors.selectedColor;
    final Color unselectedColor = theme.colors.unSelectedColor;
    final int activeIndex = currentIndex ?? -1;

    // Build once per rebuild; the same icon path with a different color tint.
    Widget icon(String path, int index) {
      return UIImage(
        path,
        color: index == activeIndex ? selectedColor : unselectedColor,
        width: _iconSize,
        height: _iconSize,
      );
    }

    return BottomNavigationBar(
      backgroundColor: theme.colors.background,
      selectedItemColor: selectedColor,
      unselectedItemColor: unselectedColor,
      iconSize: _iconSize,
      elevation: 8.0,
      selectedFontSize: _iconSize - 8,
      unselectedFontSize: _iconSize - 10,
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(
          icon: icon(theme.assets.dashboardIcon, 0),
          label: 'dashboard'.tr(ref).capitalizeAllFirstLetters(),
        ),
        BottomNavigationBarItem(
          icon: icon(theme.assets.statsIcon, 1),
          label: 'stats'.tr(ref).capitalizeAllFirstLetters(),
        ),
        BottomNavigationBarItem(
          icon: icon(theme.assets.alertsIcon, 2),
          label: 'alerts'.tr(ref).capitalizeAllFirstLetters(),
        ),
        BottomNavigationBarItem(
          icon: icon(theme.assets.chatbotIcon, 3),
          label: 'chat_ai'.tr(ref).capitalizeAllFirstLetters(),
        ),
      ],
      currentIndex: activeIndex < 0 ? 0 : activeIndex,
      onTap: onTap,
      showUnselectedLabels: true,
      showSelectedLabels: true,
      selectedLabelStyle: TextStyle(
        color: selectedColor,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: TextStyle(
        color: unselectedColor,
        fontWeight: FontWeight.normal,
      ),
    );
  }
}
