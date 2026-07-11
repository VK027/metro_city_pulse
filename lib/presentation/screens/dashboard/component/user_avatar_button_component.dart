import 'package:metro_city_pulse/core/themes/app_theme.dart';
import 'package:metro_city_pulse/presentation/utils/localization_util.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vvk_ui_kit/vvk_ui_kit.dart';

class UserAvatarButtonComponent extends StatelessWidget {
  final AppTheme theme;
  final WidgetRef ref;
  final String profilePic;
  final String userName;
  final double size;
  final bool isEditRequired;
  final bool isSideMenu;
  final Function(int) onActionSelected;

  const UserAvatarButtonComponent({
    super.key,
    required this.ref,
    required this.theme,
    required this.onActionSelected,
    required this.profilePic,
    required this.userName,
    this.size = 40.0,
    this.isEditRequired = false,
    this.isSideMenu = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = theme.colors;
    final assets = theme.assets;
    final items = _getActionsList(ref, assets);
    final double menuSize = 40;
    return PopupMenuButton<int>(
      offset: isSideMenu ? const Offset(55, 10) : const Offset(5, 10),
      elevation: 1,
      color: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      position: PopupMenuPosition.under,
      constraints: const BoxConstraints(maxWidth: 230),
      onSelected: (value) {
        onActionSelected.call(value);
      },
      tooltip: 'Profile Menu',
      itemBuilder: (BuildContext context) {
        final List<PopupMenuItem<int>> itemViews = [];
        for (int i = 0; i < items.length; i++) {
          final item = items[i];
          itemViews.add(
            PopupMenuItem<int>(
              value: item['id'],
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: menuSize,
              child: Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(vertical: 8),
                height: menuSize,
                decoration: BoxDecoration(
                  border: i < items.length - 1
                      ? Border(bottom: BorderSide(color: colors.lightGray.withValues(alpha: 0.3)))
                      : null,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    UIImage(
                      item["image"],
                      color: colors.text,
                      height: 20,
                      width: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: UIText(
                        item["label"],
                        size: 14,
                        fontWeight: FontWeight.w500,
                        color: colors.text,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return itemViews;
      },
      child: UIAvatarWithEdit(
        image: profilePic.isNotEmpty
            ? UIImage(
                profilePic,
                isAsset: false,
                height: size,
                width: size,
                fit: BoxFit.fill,
              )
            : null,
        displayName: userName,
        size: size,
        showEditOverlay: isEditRequired,
        gradientColors: [
          colors.tempGradientColor1,
          colors.gradientColor2,
        ],
        initialsColor: colors.white,
        borderColor: colors.white.withValues(alpha: 0.3),
      ),
    );
  }

  List<Map<String, dynamic>> _getActionsList(WidgetRef ref, final assets) {
    final items = [
      {
        "id": 0,
        "label": "profile".tr(ref).capitalizeAllFirstLetters(),
        "image": assets.userProfileIcon,
      },
      {
        "id": 1,
        "label": "settings".tr(ref).capitalizeAllFirstLetters(),
        "image": assets.settingIcon,
      },
      {
        "id": 2,
        "label": "logout".tr(ref).capitalizeAllFirstLetters(),
        "image": assets.powerOff,
      },
    ];
    return items;
  }
}
