import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:metro_city_pulse/core/provider/theme/app_theme_provider.dart';
import 'package:metro_city_pulse/core/themes/app_theme.dart';
import 'package:metro_city_pulse/domain/entities/map_marker_data.dart';
import 'package:metro_city_pulse/presentation/screens/dashboard/component/dashboard_app_bar.dart';
import 'package:metro_city_pulse/presentation/screens/dashboard/component/map_section.dart';
import 'package:metro_city_pulse/presentation/screens/dashboard/component/recent_alerts_section.dart';
import 'package:metro_city_pulse/presentation/screens/dashboard/component/summary_card.dart';
import 'package:metro_city_pulse/presentation/screens/dashboard/provider/dashboard_stats_provider.dart';
import 'package:metro_city_pulse/presentation/screens/home/provider/menu_state_provider.dart';
import 'package:metro_city_pulse/presentation/screens/maps/provider/map_state_provider.dart';
import 'package:metro_city_pulse/presentation/utils/localization_util.dart';
import 'package:vvk_ui_kit/vvk_ui_kit.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppTheme theme = ref.watch(appThemeStateProvider);
    final Responsive layout = Responsive.of(context);

    final List<StatTileData> stats = ref.watch(dashboardStatsProvider);
    final Map<String, int> casesCounts = ref.watch(
      remoteMarkersProvider.select(
        (v) => v.value?.casesCounts ?? const <String, int>{},
      ),
    );
    final tabBarProviderNotifier = ref.read(tabBarProvider.notifier);
    final TabBarType selectedTabItem = ref.watch(tabBarProvider);

    return Scaffold(
      backgroundColor: theme.colors.background,
      appBar: !layout.isMobile
          ? DashboardAppBar(
              title: 'stats'.tr(ref),
              theme: theme,
              userName: 'Viivek Kumar',
              onFilterSelect: () {},
              onLivePressed: () => resetDashboardToLive(ref),
              onClockPressed: () {},
              onDateRangePressed: () {},
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            if (layout.isMobileOrSmallerTablet)
              _TopBar(
                theme: theme,
                tabBarProviderNotifier: tabBarProviderNotifier,
                selectedTabItem: selectedTabItem,
                casesCounts: casesCounts,
                isMobileSmallerTablet: layout.isMobileOrSmallerTablet,
                isTablet: layout.isTablet,
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: layout.isMobile
                    ? _MobileContent(stats: stats, theme: theme)
                    : _DesktopContent(stats: stats, theme: theme),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends ConsumerWidget {
  final AppTheme theme;
  final StateController<TabBarType> tabBarProviderNotifier;
  final TabBarType selectedTabItem;
  final Map<String, int> casesCounts;
  final bool isMobileSmallerTablet;
  final bool isTablet;

  const _TopBar({
    required this.theme,
    required this.tabBarProviderNotifier,
    required this.selectedTabItem,
    required this.casesCounts,
    required this.isMobileSmallerTablet,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      color: theme.colors.surface,
      child: Row(
        children: [
          Flexible(
            child: buildTabBar(
              ref,
              tabBarProviderNotifier,
              selectedTabItem,
              isMobileSmallerTablet,
              isTablet,
              theme,
              casesCounts,
            ),
          ),
          const SizedBox(width: 8),
          buildDateRangeButton(isTablet, () {}),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _StatsGrid extends ConsumerWidget {
  static const double _tileHeight = 132;
  static const double _spacing = 10;

  final List<StatTileData> stats;
  final AppTheme theme;
  final int crossAxisCount;

  const _StatsGrid({
    required this.stats,
    required this.theme,
    required this.crossAxisCount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String comparisonLabel = 'vs_last_month'.tr(ref);
    final List<Widget> tiles = List<Widget>.generate(stats.length, (int i) {
      final StatTileData data = stats[i];
      return SummaryCard(
        theme: theme,
        title: data.labelKey.tr(ref).capitalizeAllFirstLetters(),
        value: data.value,
        icon: data.icon,
        backgroundColor: data.backgroundColor,
        changePercent: data.changePercent,
        comparisonLabel: comparisonLabel,
      );
    });

    if (crossAxisCount == 4) {
      return SizedBox(
        height: _tileHeight,
        child: Row(
          children: [
            for (int i = 0; i < tiles.length; i++) ...[
              if (i > 0) const SizedBox(width: _spacing),
              Expanded(child: tiles[i]),
            ],
          ],
        ),
      );
    }

    return Column(
      children: [
        for (int row = 0; row < tiles.length; row += crossAxisCount) ...[
          if (row > 0) const SizedBox(height: _spacing),
          SizedBox(
            height: _tileHeight,
            child: Row(
              children: [
                for (int col = 0; col < crossAxisCount; col++) ...[
                  if (col > 0) const SizedBox(width: _spacing),
                  Expanded(
                    child: row + col < tiles.length
                        ? tiles[row + col]
                        : const SizedBox.shrink(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _MobileContent extends StatelessWidget {
  final List<StatTileData> stats;
  final AppTheme theme;
  const _MobileContent({required this.stats, required this.theme});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _StatsGrid(stats: stats, theme: theme, crossAxisCount: 2),
          const SizedBox(height: 24),
          const MapSection(),
          const SizedBox(height: 16),
          RecentAlertsSection(theme: theme),
        ],
      ),
    );
  }
}

class _DesktopContent extends StatelessWidget {
  final List<StatTileData> stats;
  final AppTheme theme;
  const _DesktopContent({required this.stats, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _StatsGrid(stats: stats, theme: theme, crossAxisCount: 4),
        const SizedBox(height: 24),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Expanded(child: MapSection(fillAvailableHeight: true)),
              const SizedBox(width: 16),
              Expanded(
                child: RecentAlertsSection(theme: theme, fillAvailableHeight: true),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
