import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:metro_city_pulse/core/provider/theme/app_theme_provider.dart';
import 'package:metro_city_pulse/presentation/utils/localization_util.dart';
import 'package:vvk_ui_kit/vvk_ui_kit.dart';

class MapSection extends ConsumerWidget {
  final bool fillAvailableHeight;

  const MapSection({super.key, this.fillAvailableHeight = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Subscribe ONLY to the primary color used in the header so unrelated
    // theme changes (e.g. mode toggles touching gradients) don't force a
    // rebuild of this section.
    final Color primaryColor = ref.watch(
      appThemeStateProvider.select((t) => t.colors.primaryColor),
    );

    final Widget placeholder = UIEmptyState(
      icon: Icons.map_outlined,
      message: 'mapFeatureComingSoon'.tr(ref),
      iconSize: 64,
      textSize: 20,
    );

    return UICard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          UICardTopContainer(
            title: 'map_overview'.tr(ref).capitalizeAllFirstLetters(),
            isViewAll: false,
            color: primaryColor,
            iconData: Icons.location_on_outlined,
          ),
          if (fillAvailableHeight)
            Expanded(child: Center(child: placeholder))
          else
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
              child: placeholder,
            ),
        ],
      ),
    );
  }
}
