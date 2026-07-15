import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:metro_city_pulse/core/provider/theme/app_theme_provider.dart';
import 'package:metro_city_pulse/core/themes/app_theme.dart';
import 'package:metro_city_pulse/domain/entities/map_data_entity.dart';
import 'package:metro_city_pulse/domain/entities/map_marker_data.dart';
import 'package:metro_city_pulse/presentation/screens/alerts/provider/alerts_state_provider.dart';
import 'package:metro_city_pulse/presentation/screens/dashboard/component/responsive_date_range_selector.dart';
import 'package:metro_city_pulse/presentation/screens/maps/provider/map_state_provider.dart';
import 'package:metro_city_pulse/presentation/utils/localization_util.dart';
import 'package:video_player/video_player.dart';
import 'package:vvk_ui_kit/vvk_ui_kit.dart';

class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeStateProvider);
    final Responsive layout = Responsive.of(context);

    return Scaffold(
      appBar: null,
      body: layout.isMobile
          ? SafeArea(child: _LeftPanel(theme: theme, isMobileLayout: true))
          : Row(
              children: [
                Container(
                  width: layout.isTablet ? 300 : 360,
                  color: theme.colors.backgroundColor,
                  child: _LeftPanel(theme: theme),
                ),
                const Expanded(child: _RightPanel()),
              ],
            ),
    );
  }
}

/// LEFT PANEL (Alerts List + Filters)
class _LeftPanel extends ConsumerWidget {
  final AppTheme theme;
  final bool isMobileLayout;
  const _LeftPanel({required this.theme, this.isMobileLayout = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double confidenceScore = ref.watch(confidenceProvider);
    final List<MapDataEntity> alerts = ref.watch(filteredAlertsProvider);

    // Reconcile selectedAlert with the current filtered list. Doing this in a
    // dedicated listener keeps the build pure and avoids the
    // `addPostFrameCallback in build` pattern.
    ref.listen<List<MapDataEntity>>(filteredAlertsProvider, (previous, next) {
      final MapDataEntity? currentSelected = ref.read(selectedAlertProvider);
      if (next.isEmpty) {
        if (currentSelected != null) {
          ref.read(selectedAlertProvider.notifier).state = null;
        }
        return;
      }
      final bool hasSelection = currentSelected != null &&
          next.any((a) => a.id == currentSelected.id);
      if (!hasSelection) {
        ref.read(selectedAlertProvider.notifier).state = next.first;
      }
    });

    final MapDataEntity? selectedAlert = ref.watch(selectedAlertProvider);
    final Map<String, int> apiTabCounts = ref.watch(
      remoteMarkersProvider.select(
        (value) => value.value?.casesCounts ?? const <String, int>{},
      ),
    );
    final TabBarType selectedTab = ref.watch(selectedAlertTabProvider);
    final StateController<TabBarType> selectedTabNotifier =
        ref.read(selectedAlertTabProvider.notifier);

    final List<UISegmentTabItem> tabs = [
      UISegmentTabItem(
        label: 'new'.tr(ref).capitalizeAllFirstLetters(),
        value: '${apiTabCounts['new'] ?? 0}',
        isActive: selectedTab == TabBarType.newTab,
      ),
      UISegmentTabItem(
        label: 'dispatch'.tr(ref).capitalizeAllFirstLetters(),
        value: '${apiTabCounts['dispatch'] ?? 0}',
        isActive: selectedTab == TabBarType.dispatch,
      ),
      UISegmentTabItem(
        label: 'cases'.tr(ref).capitalizeAllFirstLetters(),
        value: '${apiTabCounts['cases'] ?? 0}',
        isActive: selectedTab == TabBarType.cases,
      ),
    ];
    void onTabPressed(int index) {
      switch (index) {
        case 0:
          selectedTabNotifier.state = TabBarType.newTab;
          break;
        case 1:
          selectedTabNotifier.state = TabBarType.dispatch;
          break;
        case 2:
          selectedTabNotifier.state = TabBarType.cases;
          break;
      }
    }

    return Container(
      color: theme.colors.backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: isMobileLayout ? 8 : 16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobileLayout ? 10 : 8),
            child: isMobileLayout
                ? Row(
                    children: [
                      Expanded(
                        child: UISegmentedTabBar(
                          isWide: false,
                          tabs: tabs,
                          onTabPressed: onTabPressed,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const ResponsiveDateRangeSelector(),
                    ],
                  )
                : Center(
                    child: UISegmentedTabBar(
                      isWide: true,
                      tabs: tabs,
                      onTabPressed: onTabPressed,
                    ),
                  ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _AlertsFilterBlock(
              isMobile: isMobileLayout,
              confidenceScore: confidenceScore,
            ),
          ),
          const Divider(),
          Expanded(
            child: RepaintBoundary(
              child: _AlertList(
                alerts: alerts,
                selectedAlertId: selectedAlert?.id,
                theme: theme,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertsFilterBlock extends ConsumerWidget {
  final bool isMobile;
  final double confidenceScore;
  const _AlertsFilterBlock({
    required this.isMobile,
    required this.confidenceScore,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData themeData = Theme.of(context);

    final Widget confidenceRow = Row(
      children: [
        Expanded(
          child: UIText(
            'confidence_score'.tr(ref).capitalizeAllFirstLetters(),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: themeData.colorScheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: UIText(
            '>= ${confidenceScore.toInt()}',
            color: themeData.colorScheme.primary,
            fontWeight: FontWeight.w600,
            size: 12,
          ),
        ),
      ],
    );

    final Widget slider = UISlider(
      value: confidenceScore,
      min: 0,
      max: 100,
      divisions: 100,
      label: '${confidenceScore.toInt()}',
      onChanged: (value) {
        ref.read(confidenceProvider.notifier).state = value;
      },
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [confidenceRow, slider],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: UIText(
                'select_date_range'.tr(ref).capitalizeAllFirstLetters(),
              ),
            ),
            const ResponsiveDateRangeSelector(),
          ],
        ),
        const SizedBox(height: 8),
        const Divider(),
        const SizedBox(height: 12),
        confidenceRow,
        slider,
      ],
    );
  }
}

class _AlertList extends ConsumerWidget {
  final List<MapDataEntity> alerts;
  final String? selectedAlertId;
  final AppTheme theme;

  const _AlertList({
    required this.alerts,
    required this.selectedAlertId,
    required this.theme,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ClipRect(
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 8),
        primary: false,
        itemCount: alerts.length,
        cacheExtent: 250,
        addAutomaticKeepAlives: false,
        addRepaintBoundaries: true,
        itemBuilder: (context, index) {
          final MapDataEntity alert = alerts[index];
          final bool isSelected = selectedAlertId == alert.id;
          final String title = alert.type?.trim().isNotEmpty == true
              ? alert.type!.trim()
              : 'Alert';
          final String camera = alert.cameraName?.trim().isNotEmpty == true
              ? alert.cameraName!.trim()
              : (alert.vehicleNo?.trim().isNotEmpty == true
                  ? alert.vehicleNo!.trim()
                  : '--');
          final String location =
              alert.locationName?.trim().isNotEmpty == true
                  ? alert.locationName!.trim()
                  : (alert.locationAddress?.trim().isNotEmpty == true
                      ? alert.locationAddress!.trim()
                      : '--');
          final DateTime reportedAt = _parseReportedTime(alert.isoTimestamp);
          return ListTile(
            leading: const CircleAvatar(child: Icon(Icons.camera_alt)),
            title: UIText(title, fontWeight: FontWeight.bold),
            selected: isSelected,
            selectedTileColor:
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
            subtitle: UIText(
              '${'camera'.tr(ref).capitalizeAllFirstLetters()}: $camera\n'
              '${'location'.tr(ref).capitalizeAllFirstLetters()}: $location',
            ),
            isThreeLine: true,
            trailing: UIText(
              '${reportedAt.month}/${reportedAt.day}/${reportedAt.year}\n'
              '${reportedAt.hour}:${reportedAt.minute.toString().padLeft(2, '0')}',
              size: 12,
              textAlign: TextAlign.right,
            ),
            onTap: () {
              ref.read(selectedAlertProvider.notifier).state = alert;
            },
          );
        },
      ),
    );
  }
}

/// RIGHT PANEL (Video + Actions + Details)
class _RightPanel extends ConsumerStatefulWidget {
  const _RightPanel();

  @override
  ConsumerState<_RightPanel> createState() => _RightPanelState();
}

class _RightPanelState extends ConsumerState<_RightPanel> {
  VideoPlayerController? _controller;
  String? _activeVideoUrl;
  bool _isVideoInitializing = false;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  String? _normalizedUrl(String? value) {
    final String trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }

  void _syncVideoController(String? videoUrl) {
    if (_activeVideoUrl == videoUrl) return;

    _activeVideoUrl = videoUrl;
    final VideoPlayerController? previousController = _controller;
    _controller = null;
    previousController?.dispose();

    if (videoUrl == null) {
      if (mounted) {
        setState(() => _isVideoInitializing = false);
      }
      return;
    }

    final VideoPlayerController controller =
        VideoPlayerController.networkUrl(Uri.parse(videoUrl));
    _controller = controller;
    if (mounted) {
      setState(() => _isVideoInitializing = true);
    }

    controller.initialize().then((_) {
      if (!mounted || _controller != controller) return;
      controller
        ..setLooping(true)
        ..play();
      setState(() => _isVideoInitializing = false);
    }).catchError((_) {
      if (!mounted || _controller != controller) return;
      setState(() => _isVideoInitializing = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final MapDataEntity? selectedAlert = ref.watch(selectedAlertProvider);
    final String? videoUrl = _normalizedUrl(selectedAlert?.cameraUrl);
    final String? imageUrl = _normalizedUrl(selectedAlert?.imageUrl);
    _syncVideoController(videoUrl);

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 320),
              color: Colors.black,
              width: double.infinity,
              child:
                  videoUrl != null && _controller?.value.isInitialized == true
                      ? AspectRatio(
                          aspectRatio: _controller!.value.aspectRatio,
                          child: VideoPlayer(_controller!),
                        )
                      : imageUrl != null
                          ? UIImage(
                              imageUrl,
                              isAsset: false,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              fallback: _NoEvidencePlaceholder(),
                            )
                          : SizedBox(
                              height: 220,
                              child: Center(
                                child: videoUrl != null && _isVideoInitializing
                                    ? const UILoadingIndicator()
                                    : const UIText(
                                        'No evidence available',
                                        color: Colors.white70,
                                      ),
                              ),
                            ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              UIElevatedIconButton(
                icon: Icons.work,
                label: 'create_case'.tr(ref).capitalizeAllFirstLetters(),
                foregroundColor: Colors.white,
                backgroundColor: Theme.of(context).colorScheme.primary,
                onPressed: () {},
              ),
              UIElevatedIconButton(
                icon: Icons.feedback,
                label: 'feedback'.tr(ref).capitalizeAllFirstLetters(),
                foregroundColor: Colors.white,
                backgroundColor: Theme.of(context).colorScheme.primary,
                onPressed: () {},
              ),
              UIElevatedIconButton(
                icon: Icons.sos,
                label: 'sos'.tr(ref).toUpperCase(),
                foregroundColor: Colors.white,
                backgroundColor: Colors.red,
                onPressed: () {},
              ),
              UICustomOutlinedButton(
                icon: Icons.close,
                label: 'ignore'.tr(ref).capitalizeAllFirstLetters(),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (selectedAlert != null) ...[
            UICard(
              borderRadius: 12,
              child: ListTile(
                leading: const Icon(Icons.security, size: 36),
                title: UIText(
                  selectedAlert.type?.trim().isNotEmpty == true
                      ? selectedAlert.type!.trim()
                      : 'Alert',
                ),
                subtitle: UIText(
                  selectedAlert.isoTimestamp ??
                      _parseReportedTime(selectedAlert.isoTimestamp)
                          .toIso8601String(),
                ),
                trailing: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: UIText(
                    '${'confidence'.tr(ref).capitalizeAllFirstLetters()} '
                    '${selectedAlert.confidenceScore ?? 0}%',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _AlertDetailsPanel(alert: selectedAlert, ref: ref),
            ),
          ] else
            UIText(
              'select_alert_to_view_details'.tr(ref).capitalizeAllFirstLetters(),
              color: Colors.grey,
            ),
        ],
      ),
    );
  }
}

class _AlertDetailsPanel extends StatelessWidget {
  final MapDataEntity alert;
  final WidgetRef ref;

  const _AlertDetailsPanel({required this.alert, required this.ref});

  String _value(String? value) {
    final String trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? '--' : trimmed;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final List<MapEntry<String, String>> details = <MapEntry<String, String>>[
      MapEntry('ID', _value(alert.id)),
      MapEntry('type'.tr(ref).capitalizeAllFirstLetters(), _value(alert.type)),
      MapEntry('camera'.tr(ref).capitalizeAllFirstLetters(), _value(alert.cameraName)),
      MapEntry('location'.tr(ref).capitalizeAllFirstLetters(), _value(alert.locationName)),
      MapEntry('Address', _value(alert.locationAddress)),
      MapEntry('Location Type', _value(alert.locationType)),
      MapEntry(
        'Latitude',
        alert.coordinates?.latitude?.toStringAsFixed(6) ?? '--',
      ),
      MapEntry(
        'Longitude',
        alert.coordinates?.longitude?.toStringAsFixed(6) ?? '--',
      ),
      MapEntry('Date', _value(alert.date)),
      MapEntry('Time', _value(alert.time)),
      MapEntry('Timestamp', _value(alert.isoTimestamp)),
      MapEntry(
        'confidence'.tr(ref).capitalizeAllFirstLetters(),
        '${alert.confidenceScore ?? 0}%',
      ),
      MapEntry('Status', _value(alert.status).capitalizeAllFirstLetters()),
      MapEntry('Severity', _value(alert.severity)),
      MapEntry('Live', alert.isLive == true ? 'Yes' : 'No'),
      MapEntry('Vehicle No', _value(alert.vehicleNo)),
    ];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: themeData.colorScheme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: themeData.colorScheme.primary.withValues(alpha: 0.12),
        ),
      ),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: details.length,
        separatorBuilder: (context, index) => const Divider(height: 20),
        itemBuilder: (context, index) {
          final MapEntry<String, String> entry = details[index];
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 130,
                child: UIText(
                  entry.key,
                  fontWeight: FontWeight.w600,
                  color: themeData.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              Expanded(
                child: UIText(
                  entry.value,
                  color: themeData.colorScheme.onSurface,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

DateTime _parseReportedTime(String? value) {
  if (value == null || value.trim().isEmpty) {
    return DateTime.now();
  }
  return DateTime.tryParse(value.trim()) ?? DateTime.now();
}

/// Lightweight placeholder shown when both the live evidence stream and the
/// fallback image fail to load. Replaces the previous 74KB JPG that was
/// shipped only to be displayed as a "no image" state.
class _NoEvidencePlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.videocam_off_outlined, color: Colors.white54, size: 48),
          SizedBox(height: 8),
          UIText(
            'No evidence available',
            color: Colors.white70,
          ),
        ],
      ),
    );
  }
}
