import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:metro_city_pulse/core/provider/theme/app_theme_provider.dart';
import 'package:metro_city_pulse/core/themes/app_theme.dart';
import 'package:metro_city_pulse/presentation/screens/alerts/page/alerts_screen.dart';
import 'package:metro_city_pulse/presentation/screens/dashboard/component/dashboard_app_bar.dart';
import 'package:metro_city_pulse/presentation/screens/dashboard/page/dashboard_screen.dart';
import 'package:metro_city_pulse/presentation/screens/home/component/bottom_navigation_widget.dart';
import 'package:metro_city_pulse/presentation/screens/home/component/side_menu.dart';
import 'package:metro_city_pulse/presentation/screens/home/provider/menu_state_provider.dart';
import 'package:metro_city_pulse/presentation/screens/maps/page/custom_map_screen.dart';
import 'package:metro_city_pulse/presentation/screens/maps/provider/map_state_provider.dart';
import 'package:metro_city_pulse/presentation/screens/profile/page/profile_screen.dart';
import 'package:metro_city_pulse/presentation/screens/settings/page/settings_screen.dart';
import 'package:metro_city_pulse/presentation/utils/localization_util.dart';
import 'package:metro_city_pulse/presentation/utils/map_utils.dart';
import 'package:metro_city_pulse/presentation/utils/navigation_util.dart';
import 'package:vvk_ui_kit/vvk_ui_kit.dart' hide NavigationUtil;

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppTheme theme = ref.watch(appThemeStateProvider);
    final Responsive layout = Responsive.of(context);

    final int currentIndex = ref.watch(bottomNavIndexProvider) ?? 0;
    final bottomNavProvider = ref.read(bottomNavIndexProvider.notifier);

    final MenuItemType selectedMenuItem = ref.watch(menuProvider);
    final menuNotifier = ref.read(menuProvider.notifier);

    _syncMarkerIconSize(layout.size.width, ref);

    return ResponsiveProvider(
      child: Scaffold(
      drawer: layout.isMobile
          ? _buildDrawer(context, ref, theme, selectedMenuItem)
          : null,
      bottomNavigationBar: layout.isMobile
          ? BottomNavigationWidget(
              theme: theme,
              currentIndex: currentIndex,
              onTap: (index) {
                bottomNavProvider.state = index;
                _updateMenuViaIndex(index, menuNotifier);
              },
            )
          : null,
      body: SafeArea(
        child: Builder(
          builder: (scaffoldContext) => Column(
            children: [
              if (layout.isMobile)
                _buildAppBar(scaffoldContext, theme, ref),
              Expanded(
                child: Row(
                  children: [
                    if (!layout.isMobile)
                      RepaintBoundary(
                        child: SideMenu(
                          ref: ref,
                          theme: theme,
                          selectedItem: selectedMenuItem,
                          onMenuSelected: (menuType) =>
                              _onMenuSelectedWithNavUpdate(
                                context,
                                ref,
                                menuType,
                              ),
                          onTimeSelected: (int interval) {
                            ref
                                .read(remoteMarkersProvider.notifier)
                                .setPollingInterval(interval);
                          },
                        ),
                      ),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: _buildScreenContent(selectedMenuItem),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }

  Widget _buildDrawer(
    BuildContext context,
    WidgetRef ref,
    AppTheme theme,
    MenuItemType selectedMenu,
  ) {
    return SafeArea(
      child: Drawer(
        child: SideMenu(
          ref: ref,
          theme: theme,
          selectedItem: selectedMenu,
          onMenuSelected: (menuType) =>
              _onMenuSelectedWithNavUpdate(context, ref, menuType),
        ),
      ),
    );
  }

  Widget _buildAppBar(
    BuildContext context,
    AppTheme theme,
    WidgetRef ref,
  ) {
    final MenuItemType selectedMenu = ref.watch(menuProvider);
    final bool showMapControls = selectedMenu == MenuItemType.dashboard;

    return DashboardAppBar(
      title: _appBarTitleForMenu(ref, selectedMenu),
      theme: theme,
      onMenuPressed: () => Scaffold.of(context).openDrawer(),
      userName: 'Viivek Kumar',
      onLogoutPressed: () => _logoutFunction(context, ref),
      onFilterSelect: showMapControls ? () {} : null,
      onLivePressed: showMapControls
          ? () => resetDashboardToLive(ref)
          : () => ref.read(remoteMarkersProvider.notifier).refresh(),
      onClockPressed: () {},
      onDateRangePressed: () {},
    );
  }

  Widget _buildScreenContent(MenuItemType selectedMenu) {
    switch (selectedMenu) {
      case MenuItemType.dashboard:
        return const CustomMapScreen();
      case MenuItemType.stats:
        return const DashboardScreen();
      case MenuItemType.alerts:
        return const AlertsScreen();
      case MenuItemType.profile:
        return const ProfileScreen();
      case MenuItemType.settings:
        return const SettingsScreen();
      default:
        return const CustomMapScreen();
    }
  }

  void _updateMenuViaIndex(int index, final menuNotifier) {
    const Map<int, MenuItemType> menuMapping = {
      0: MenuItemType.dashboard,
      1: MenuItemType.stats,
      2: MenuItemType.alerts,
      3: MenuItemType.chat,
    };
    menuNotifier.state = menuMapping[index] ?? MenuItemType.dashboard;
  }

  void _onMenuSelectedWithNavUpdate(
    BuildContext context,
    WidgetRef ref,
    MenuItemType menuType,
  ) {
    final menuNotifier = ref.read(menuProvider.notifier);
    final bottomNavProvider = ref.read(bottomNavIndexProvider.notifier);

    switch (menuType) {
      case MenuItemType.dashboard:
        menuNotifier.state = MenuItemType.dashboard;
        bottomNavProvider.state = 0;
        break;
      case MenuItemType.stats:
        menuNotifier.state = MenuItemType.stats;
        bottomNavProvider.state = 1;
        break;
      case MenuItemType.alerts:
        menuNotifier.state = MenuItemType.alerts;
        bottomNavProvider.state = 2;
        break;
      case MenuItemType.chat:
        menuNotifier.state = MenuItemType.chat;
        bottomNavProvider.state = 3;
        break;
      case MenuItemType.profile:
        NavigationUtil.push(context, '/profile');
        break;
      case MenuItemType.settings:
        NavigationUtil.push(context, '/settings');
        break;
      case MenuItemType.logout:
        _logoutFunction(context, ref);
        break;
    }
  }

  String _appBarTitleForMenu(WidgetRef ref, MenuItemType menu) {
    switch (menu) {
      case MenuItemType.stats:
        return 'stats'.tr(ref);
      case MenuItemType.alerts:
        return 'alerts'.tr(ref);
      case MenuItemType.chat:
        return 'chat_ai'.tr(ref);
      default:
        return 'dashboard'.tr(ref);
    }
  }

  void _logoutFunction(BuildContext context, WidgetRef ref) {
    UISnackbar.showDefault(
      context: context,
      message: 'logging_out'.tr(ref).capitalizeAllFirstLetters(),
    );
    NavigationUtil.clearDataAndMoveToLogin(context, ref, 'side_menu');
  }
}

/// Updates the marker icon size based on the cached width without listening
/// to MediaQuery (callers already have it). The post-frame callback prevents
/// a "modify state during build" warning.
void _syncMarkerIconSize(double screenWidth, WidgetRef ref) {
  final double markerSize = MapUtils.markerSizeForScreenWidth(screenWidth);
  if (ref.read(markerIconSizeProvider) != markerSize) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Guard against the provider being disposed between scheduling and
      // running the callback.
      if (ref.read(markerIconSizeProvider) != markerSize) {
        ref.read(markerIconSizeProvider.notifier).state = markerSize;
      }
    });
  }
}
