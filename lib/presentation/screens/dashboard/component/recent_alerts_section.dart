import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:metro_city_pulse/core/themes/app_theme.dart';
import 'package:metro_city_pulse/presentation/screens/dashboard/component/alert_list_item.dart';
import 'package:metro_city_pulse/presentation/screens/dashboard/provider/dashboard_stats_provider.dart';
import 'package:metro_city_pulse/presentation/screens/home/provider/menu_state_provider.dart';
import 'package:metro_city_pulse/presentation/utils/localization_util.dart';
import 'package:vvk_ui_kit/vvk_ui_kit.dart';

class RecentAlertsSection extends ConsumerWidget {
  final AppTheme theme;
  final bool fillAvailableHeight;

  const RecentAlertsSection({
    super.key,
    required this.theme,
    this.fillAvailableHeight = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List alerts = ref.watch(recentMapAlertsProvider);
    final double alertsHeight = MediaQuery.sizeOf(context).height * 0.42;

    final Widget alertsList = alerts.isEmpty
        ? Center(
            child: UIText(
              'select_alert_to_view_details'.tr(ref),
              color: Colors.grey.shade600,
              textAlign: TextAlign.center,
            ),
          )
        : ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: alerts.length,
            // Avoid laying out off-screen items at startup; lets the first
            // frame paint sooner on big lists.
            cacheExtent: 250,
            addAutomaticKeepAlives: false,
            addRepaintBoundaries: true,
            itemBuilder: (context, index) {
              return AlertListItem(alert: alerts[index], theme: theme);
            },
            separatorBuilder: (_, _) => Divider(
              thickness: 0.5,
              height: 0.5,
              color: Colors.grey.shade400,
            ),
          );

    return UICard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              ref.read(menuProvider.notifier).state = MenuItemType.alerts;
              ref.read(bottomNavIndexProvider.notifier).state = 1;
            },
            child: UICardTopContainer(
              title: 'recentAlerts'.tr(ref).capitalizeAllFirstLetters(),
              isViewAll: true,
              viewAllLabel: 'viewAll'.tr(ref),
              color: theme.colors.primaryColor,
              iconData: Icons.refresh,
            ),
          ),
          if (fillAvailableHeight)
            Expanded(child: RepaintBoundary(child: alertsList))
          else
            SizedBox(
              height: alertsHeight.clamp(280, 520),
              child: RepaintBoundary(child: alertsList),
            ),
        ],
      ),
    );
  }
}
