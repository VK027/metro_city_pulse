import 'package:metro_city_pulse/core/main_initialisation.dart';
import 'package:metro_city_pulse/core/provider/language_provider.dart';
import 'package:metro_city_pulse/core/provider/theme/app_theme_provider.dart';
import 'package:metro_city_pulse/core/router/app_router_config.dart';
import 'package:metro_city_pulse/core/themes/app_theme_mode.dart';
import 'package:metro_city_pulse/core/themes/dark/app_theme_dark.dart';
import 'package:metro_city_pulse/presentation/utils/localization_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vvk_ui_kit/vvk_ui_kit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeStateProvider);
    final Locale? locale = ref.watch(languageProvider);
    final goRouter = ref.watch(goRouterProvider);

    return UIImageScope(
      svgBuilder: (context, params) {
        if (params.isAsset) {
          return SvgPicture.asset(
            params.source,
            width: params.width,
            height: params.height,
            fit: params.fit,
            colorFilter: params.colorFilter,
            placeholderBuilder: params.placeholder == null
                ? null
                : (_) => params.placeholder!(),
          );
        }
        return SvgPicture.network(
          params.source,
          width: params.width,
          height: params.height,
          fit: params.fit,
          colorFilter: params.colorFilter,
          placeholderBuilder: params.placeholder == null
              ? null
              : (_) => params.placeholder!(),
        );
      },
      child: MaterialApp.router(
        routerConfig: goRouter,
        title: 'app_title'.tr(ref),
        debugShowCheckedModeBanner: false,
        theme: theme.themeData,
        darkTheme: AppThemeDark().themeData,
        themeMode:
            theme.mode == AppThemeMode.dark ? ThemeMode.dark : ThemeMode.light,
        locale: locale,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: supportedLocales,
      ),
    );
  }
}

/// Dark mode extension
extension DarkMode on BuildContext {
  bool get isDarkMode =>
      MediaQuery.platformBrightnessOf(this) == Brightness.dark;
}
