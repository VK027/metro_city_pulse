import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:metro_city_pulse/core/provider/theme/app_theme_provider.dart';
import 'package:metro_city_pulse/core/themes/app_assets.dart';
import 'package:metro_city_pulse/core/themes/app_colors.dart';
import 'package:metro_city_pulse/presentation/utils/localization_util.dart';
import 'package:metro_city_pulse/presentation/utils/navigation_util.dart';
import 'package:vvk_ui_kit/vvk_ui_kit.dart' hide NavigationUtil;

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeStateProvider);
    final AppColors colors = theme.colors;
    final Responsive layout = Responsive.of(context);

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isWide = constraints.maxWidth > 600;
          final double fieldWidth = isWide
              ? constraints.maxWidth / 2 - 30
              : double.infinity;
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                flex: 1,
                child: TopPortion(colors: colors, assets: theme.assets),
              ),
              const SizedBox(height: 16),
              Expanded(
                flex: 2,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Wrap(
                        spacing: 20,
                        runSpacing: 20,
                        direction: Axis.horizontal,
                        children: [
                          SizedBox(
                            width: fieldWidth,
                            child: UISingleValueDropdown(
                              label: 'department_required'.tr(ref),
                              value:
                                  'police_department'.tr(ref).capitalizeAllFirstLetters(),
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: UISingleValueDropdown(
                              label: 'country'.tr(ref).capitalizeAllFirstLetters(),
                              value: 'india'.tr(ref).capitalizeAllFirstLetters(),
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: UISingleValueDropdown(
                              label: 'city'.tr(ref).capitalizeAllFirstLetters(),
                              value: 'bengaluru'.tr(ref).capitalizeAllFirstLetters(),
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: UISingleValueDropdown(
                              label: 'designation'.tr(ref).capitalizeAllFirstLetters(),
                              value: 'inspector'.tr(ref).capitalizeAllFirstLetters(),
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: UIReadOnlyField(
                              label: 'id_required'.tr(ref).toUpperCase(),
                              value: 'BPD123456',
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: UIReadOnlyField(
                              label: 'phone_number_required'
                                  .tr(ref)
                                  .capitalizeAllFirstLetters(),
                              value: '99XX XXX XXX',
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: UIReadOnlyField(
                              label: 'official_email_required'
                                  .tr(ref)
                                  .capitalizeAllFirstLetters(),
                              value: 'viivek.k@account.com',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _ProfileActionsBar(isMobile: layout.isMobile),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProfileActionsBar extends ConsumerWidget {
  final bool isMobile;
  const _ProfileActionsBar({required this.isMobile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Widget save = ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
      ),
      child: Text('save_changes'.tr(ref).capitalizeAllFirstLetters()),
    );
    final Widget cancel = OutlinedButton(
      onPressed: () => NavigationUtil.pop(context),
      style: OutlinedButton.styleFrom(
        backgroundColor: colorScheme.primary.withValues(alpha: 0.12),
        foregroundColor: colorScheme.primary,
        side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.45)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
      ),
      child: Text('cancel'.tr(ref).capitalizeAllFirstLetters()),
    );

    if (isMobile) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          save,
          const SizedBox(height: 16),
          cancel,
        ],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        save,
        const SizedBox(width: 16),
        cancel,
      ],
    );
  }
}

class TopPortion extends StatelessWidget {
  final AppColors colors;
  final AppAssets assets;

  const TopPortion({super.key, required this.colors, required this.assets});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      alignment: Alignment.topCenter,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 80),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [colors.gradientColor1, colors.gradientColor2],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor:
                          Theme.of(context).scaffoldBackgroundColor,
                      child: Icon(
                        Icons.person,
                        size: 100,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const UIText(
                    'Viivek Kumar',
                    size: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(width: 8),
                  UIImage(
                    assets.editSquare,
                    width: 24,
                    height: 24,
                    color: colors.white,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
