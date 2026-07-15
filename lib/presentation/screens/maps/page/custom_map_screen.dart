import 'package:metro_city_pulse/core/provider/theme/app_theme_provider.dart';
import 'package:metro_city_pulse/domain/entities/map_marker_data.dart'
    show FilterType, MapMarkerData, TabBarType;
import 'package:metro_city_pulse/presentation/screens/dashboard/component/dashboard_app_bar.dart';
import 'package:metro_city_pulse/presentation/screens/home/provider/menu_state_provider.dart';
import 'package:metro_city_pulse/presentation/screens/maps/component/map_info_window_widget.dart';
import 'package:metro_city_pulse/presentation/screens/maps/component/map_tab_bar_widget.dart';
import 'package:metro_city_pulse/presentation/screens/maps/component/map_zoom_control_widget.dart';
import 'package:metro_city_pulse/presentation/screens/maps/component/severity_bar_widget.dart';
import 'package:metro_city_pulse/presentation/screens/maps/provider/map_state_provider.dart';
import 'package:metro_city_pulse/presentation/utils/localization_util.dart';
import 'package:metro_city_pulse/presentation/utils/map_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
//import 'package:google_maps_cluster_manager_2/google_maps_cluster_manager_2.dart' as cm;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vvk_ui_kit/vvk_ui_kit.dart';

class CustomMapScreen extends ConsumerStatefulWidget {
  const CustomMapScreen({super.key});

  @override
  ConsumerState<CustomMapScreen> createState() => _NewCustomMapScreenState();
}

class _NewCustomMapScreenState extends ConsumerState<CustomMapScreen> {
  /// Right-side gutter on mobile so the severity bar does not sit under FABs.
  static const double _kMobileFabReserveWidth = 56;

  GoogleMapController? _mapController;
  LatLng? _selectedMarkerLatLng;
  MapMarkerData? _selectedMarker;
  bool _showCustomInfo = false;
  bool _showFilterOptions = false;
  Size? mapSize;
  LatLngBounds? mapBounds;
  bool _showSeverityLegend = true;

  //cm.ClusterManager<MapMarkerData>? _clusterManager;

  @override
  void dispose() {
    _mapController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(appThemeStateProvider);

    final remoteMarkersResult = ref.watch(remoteMarkersProvider);
    final remoteMarkersResultNotifier = ref.read(
      remoteMarkersProvider.notifier,
    );
    final FilterType selectedFilter = ref.watch(selectedFilterProvider);
    final int? selectedSeverityIndex = ref.watch(selectedSeverityProvider);

    final tabBarProviderNotifier = ref.read(tabBarProvider.notifier);
    final TabBarType selectedTabItem = ref.watch(tabBarProvider);

    final Responsive layout = Responsive.of(context);
    final bool isMobileSmallerTablet = layout.isMobileOrSmallerTablet;
    final bool isTablet = layout.isTablet;
    final bool isMobile = layout.isMobile;

    ref.listen<int>(mapLiveResetTriggerProvider, (previous, next) {
      if (previous != next) {
        MapUtils.resetCameraPosition(_mapController);
      }
    });

    return Scaffold(
      backgroundColor: theme.colors.surface,
      appBar: !isMobile
          ? DashboardAppBar(
              title: 'dashboard'.tr(ref),
              theme: theme,
              userName: 'Viivek Kumar',
              onFilterSelect: _showFilterSheet,
              onLivePressed: _resetFilters,
              onClockPressed: () {},
              onDateRangePressed: () {
                // showDialog(
                //   context: context,
                //   builder: (context) => const CustomDateRangePicker(),
                // );
              },
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            if (isMobileSmallerTablet)
              _buildTopBar(
                context,
                tabBarProviderNotifier,
                selectedTabItem,
                theme,
                remoteMarkersResultNotifier.casesCounts,
                isMobileSmallerTablet,
                isTablet,
                isMobile,
              ),
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  RepaintBoundary(
                    child: _buildMap(
                      remoteMarkersResult,
                      selectedFilter,
                      selectedTabItem,
                      selectedSeverityIndex,
                    ),
                  ),
                  if (_showCustomInfo &&
                      _selectedMarker != null &&
                      _selectedMarkerLatLng != null)
                    _buildInfoWindow(context),
                  if (!isMobile) ...[
                    _buildFilterBar(theme, selectedFilter),
                  ],
                  _buildSeverityBar(
                    selectedSeverityIndex,
                    remoteMarkersResultNotifier.severityCounts,
                    isMobile,
                  ),
                  _buildZoomControls(theme, isMobile),
                  if (_showFilterOptions && !isMobile)
                    _buildSidePanel(remoteMarkersResult, selectedFilter),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet() {
    //TODO: show a bottom sheet to popular filter options
    // like traffic, public works, airport, park
  }

  void _resetFilters() {
    setState(() {
      _showCustomInfo = false;
      _showFilterOptions = false;
    });
    resetDashboardToLive(ref);
  }

  Widget _buildTopBar(
    BuildContext context,
    StateController<TabBarType> tabBarProviderNotifier,
    TabBarType selectedTabItem,
    dynamic theme,
    Map<String, int> casesCounts,
    bool isMobileSmallerTablet,
    bool isTablet,
    bool isMobile,
  ) {
    final double gap = isMobile ? 8 : 4;
    return Container(
      width: double.infinity,
      color: theme.colors.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
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
          SizedBox(width: gap),
          buildDateRangeButton(isTablet, () {}),
          SizedBox(width: gap),
          //         Row(
          //             children: [
          //               const Text("Auto-refresh"),
          //               Switch(
          //                 value: autoRefresh,
          //                 onChanged: (value) {
          //                   //ref.read(autoRefreshProvider.notifier).toggle(value, onTick: () {
          //                   //ref.read(remoteMarkersProvider.notifier).refresh(silent: true);
          //                   //});
          //                   ref.read(autoRefreshProvider.notifier).state = value;
          //                 },
          //               ),
          //             ],
          //           ),
          //           IconButton(
          //             icon: const Icon(Icons.refresh),
          //             onPressed: () => ref.read(mapPollingProvider.notifier).fetchData(),
          //             tooltip: 'Refresh',
          //           ),
        ],
      ),
    );
  }

  Widget _buildMap(
    AsyncValue<RemoteMarkersResult> remoteMarkersResult,
    FilterType selectedFilter,
    TabBarType selectedTabItem,
    int? selectedSeverityIndex,
  ) {
    return remoteMarkersResult.when(
      data: (remoteMarkersResult) {
        final Set<Marker> googleMarkers = _filterMarkers(
          remoteMarkersResult.markers,
          selectedFilter,
          selectedTabItem,
          selectedSeverityIndex,
        );
        return LayoutBuilder(
          builder: (context, constraints) {
            mapSize = Size(constraints.maxWidth, constraints.maxHeight);
            return ClipRRect(
              //absorbing: true,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
              ),
              child: GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: MapUtils.initialCameraPosition,
                markers: googleMarkers,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                // Removes location button
                zoomControlsEnabled: false,
                // Removes + and - buttons
                onMapCreated: (controller) async {
                  _mapController = controller;
                  //_clusterManager?.setMapId(controller.mapId);
                  mapBounds = await _mapController?.getVisibleRegion();
                  if (_showCustomInfo) {
                    setState(() {});
                  }
                },
                onCameraIdle: () async {
                  mapBounds = await _mapController?.getVisibleRegion();
                  //_clusterManager?.updateMap;
                  if (_showCustomInfo) {
                    setState(() {});
                  }
                },
                //onCameraMove: _clusterManager?.onCameraMove,
                mapToolbarEnabled: false, // Removes bottom-right toolbar
                compassEnabled: false, // Removes compass
                rotateGesturesEnabled: false, // Optional: Disable rotation
                tiltGesturesEnabled: false, // Optional: Disable tilt
                zoomGesturesEnabled: true, // Or allow pinch zoom
                scrollGesturesEnabled: true, // Disable panning
                liteModeEnabled: !kIsWeb,
                onTap: (LatLng pos) => setState(() => _showCustomInfo = false),
              ),
            );
          },
        );
      },
      loading: () => const UILoadingIndicator(),
      error: (e, st) => _buildErrorWidget(e),
    );
  }

  Set<Marker> _filterMarkers(
    List<MapMarkerData> markers,
    FilterType filterSelected,
    TabBarType tab,
    int? severityIndex,
  ) {
    return markers
        .where((MapMarkerData m) {
          final matchesFilter =
              filterSelected == FilterType.all ||
              m.filterType == filterSelected;
          final matchesTab = m.tabType == tab;
          final matchesSeverity =
              severityIndex == null ||
              severityIndex == -1 ||
              m.severity.toUpperCase() ==
                  MapUtils.getSeverityByIndex(severityIndex);
          return matchesFilter && matchesTab && matchesSeverity;
        })
        .map(
          (MapMarkerData mapMarkerData) => Marker(
            markerId: MarkerId(mapMarkerData.id),
            position: mapMarkerData.position,
            icon: mapMarkerData.icon,
            onTap: () => setState(() {
              _selectedMarkerLatLng = mapMarkerData.position;
              _selectedMarker = mapMarkerData;
              _showCustomInfo = true;
            }),
          ),
        )
        .toSet();
  }

  Widget _buildInfoWindow(BuildContext context) {
    final markerSize = ref.watch(markerIconSizeProvider);
    final Offset? offset = MapUtils.getOffsetForLatLng(
      _mapController,
      mapBounds,
      mapSize,
      _selectedMarkerLatLng,
      markerSize: markerSize,
    );
    if (offset == null) return const SizedBox.shrink();
    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: MapInfoWindowWidget(
        label: _selectedMarker!.title,
        building: 'Building C',
        alertId: 'Alert ID: 5678',
        timestamp: '05/10/2025  10:09',
      ),
    );

    // Builder(
    //   builder: (ctx) {
    //     final offset = _getOffsetForLatLng(context, _selectedMarkerLatLng);
    //     if (offset == null) return SizedBox.shrink();
    //     return Positioned(
    //       left: offset.dx,
    //       top: offset.dy,
    //       child: MapInfoWindowWidget(
    //         label: _selectedMarker!.title,
    //         building: 'Building C',
    //         alertId: 'Alert ID: 5678',
    //         timestamp: '05/10/2025  10:09',
    //       ),
    //     );
    //   },
    // ),
  }

  Widget _buildFilterBar(dynamic theme, FilterType selectedFilter) {
    return Positioned(
      top: 10,
      right: 0,
      // left: isWide ? 24 : 12,
      // right: isWide ? null : 12,
      child: MapTabBarWidget(
        theme: theme,
        selectedFilter: selectedFilter,
        onPressed: (filter) {
          ref.read(selectedFilterProvider.notifier).setFilter(filter);
          setState(() => _showFilterOptions = (filter != FilterType.all));
        },
        onFilterSelected: (_) {},
      ),
    );
  }

  Widget _buildSeverityBar(
    int? selectedSeverityIndex,
    Map<String, int> casesCounts,
    bool isMobile,
  ) {
    return (_showSeverityLegend)
        ? Positioned(
            bottom: isMobile ? 8 : 18,
            left: isMobile ? 8 : null,
            right: isMobile ? _kMobileFabReserveWidth : null,
            child: SeverityBarWidget(
              onSelected: (index) =>
                  ref.read(selectedSeverityProvider.notifier).state = index,
              selectedSeverityIndex: selectedSeverityIndex ?? -1,
              severities: MapUtils.getSeveritiesList(casesCounts),
              isMobile: isMobile,
              onClose: () {
                setState(() {
                  _showSeverityLegend = false;
                });
              },
            ),
          )
        : const SizedBox.shrink();
  }

  Widget _buildZoomControls(dynamic theme, bool isMobile) {
    return Positioned(
      right: 10,
      bottom: !isMobile ? kBottomNavigationBarHeight : 8,
      child: MapZoomControlWidget(
        theme: theme,
        onLocationPressed: () => MapUtils.goToCurrentLocation(_mapController),
        onZoomInPressed: () => MapUtils.zoomIn(_mapController),
        onZoomOutPressed: () => MapUtils.zoomOut(_mapController),
        onResetPressed: _resetFilters,
        onExclamationPressed: () {
          //TODO: show Severity dialog in mobile layout
          setState(() {
            _showSeverityLegend = true;
          });
        },
      ),
    );
  }

  Widget _buildSidePanel(
    AsyncValue<RemoteMarkersResult> remoteMarkersResult,
    FilterType selectedFilter,
  ) {
    return Positioned(
      top: kToolbarHeight + 14,
      right: 24,
      bottom:
          40.0 * 3 +
          kBottomNavigationBarHeight +
          8.0, //(small Fab button height + spacing) * 3
      width: 416,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              UIText(
                'details'.tr(ref).capitalizeAllFirstLetters(),
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: remoteMarkersResult.when(
                  data: (markers) =>
                      _buildMarkerList(markers.markers, selectedFilter),
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMarkerList(
    List<MapMarkerData> markers,
    FilterType selectedFilter,
  ) {
    final theme = ref.watch(appThemeStateProvider);
    final filtered = markers.where(
      (m) => selectedFilter == FilterType.all || m.filterType == selectedFilter,
    );
    //TODO: Add Filters UI Implementation
    return ListView(
      children: filtered.map((m) {
        final isSelected = _selectedMarker?.id == m.id;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.symmetric(vertical: 3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: isSelected
                ? theme.colors.primaryColor.withValues(alpha: 0.14)
                : Colors.transparent,
            border: Border.all(
              color: isSelected
                  ? theme.colors.primaryColor.withValues(alpha: 0.45)
                  : Colors.transparent,
            ),
          ),
          child: ListTile(
            dense: true,
            leading: Icon(
              Icons.location_on,
              color: isSelected ? theme.colors.primaryColor : theme.colors.gray,
            ),
            title: UIText(
              m.title,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
            subtitle: UIText(
              '${m.filterType.toString().split('.').last} — S${m.severity}',
              color: isSelected
                  ? theme.colors.primaryColor
                  : theme.colors.darkGray,
            ),
            onTap: () {
              setState(() {
                _selectedMarker = m;
                _selectedMarkerLatLng = m.position;
                _showCustomInfo = true;
              });
              _mapController?.animateCamera(
                CameraUpdate.newLatLngZoom(m.position, 15),
              );
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildErrorWidget(Object e) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          UIText('failed_to_load_markers'.tr(ref).capitalizeAllFirstLetters()),
          const SizedBox(height: 8),
          UIElevatedButton(
            onPressed: _resetFilters,
            isFullWidth: false,
            child: UIText('retry'.tr(ref).capitalizeAllFirstLetters()),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: UIText(
              e.toString(),
              size: 12.0,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
