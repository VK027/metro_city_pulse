import 'package:metro_city_pulse/core/themes/app_assets.dart';
import 'package:metro_city_pulse/domain/entities/map_data_entity.dart';
import 'package:metro_city_pulse/domain/entities/map_marker_data.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:vvk_ui_kit/vvk_ui_kit.dart';


const double markerWidthMobile = 40;
const double markerWidthTablet = 48;
const double markerWidthDesktop = 55;
const double infoWindowWidth = 180;

class MapUtils {
  static final Map<String, Map<FilterType, BitmapDescriptor>> _iconCache = {};

  static double markerSizeForScreenWidth(double width) {
    if (width <= mobileWidth) return markerWidthMobile;
    if (width >= desktopWidth) return markerWidthDesktop;
    return markerWidthTablet;
  }

  static Size markerSizeFromWidth(double width) {
    final size = markerSizeForScreenWidth(width);
    return Size(size, size);
  }
  static List<Map<String, Object>> getSeveritiesList(
    Map<String, int> casesCounts,
  ) {
    return [
      {"label": "S1", "count": casesCounts['S1'] ?? 0, "color": Colors.red},
      {"label": "S2", "count": casesCounts['S2'] ?? 0, "color": Colors.orange},
      {"label": "S3", "count": casesCounts['S3'] ?? 0, "color": Colors.yellow},
      {"label": "S4", "count": casesCounts['S4'] ?? 0, "color": Colors.green},
      {"label": "S5", "count": casesCounts['S5'] ?? 0, "color": Colors.cyan},
    ];
  }

  static String getSeverityByIndex(int index) {
    if (index == -1) return '';
    return 'S${index + 1}'.toUpperCase();
  }

  // static String getSeverityByIndex(int selectedSeverityIndex) {
  //   switch (selectedSeverityIndex) {
  //     case -1: return '';
  //     case 0: return 'S1';
  //     case 1: return 'S2';
  //     case 2: return 'S3';
  //     case 3: return 'S4';
  //     case 4: return 'S5';
  //     default: return '';
  //   }
  // }

  static FilterType getFilterType(MapDataEntity entity) {
    final String? type = entity.locationType?.trim().toLowerCase();
    switch (type) {
      case 'traffic':
        return FilterType.traffic;
      case 'public works':
      case 'public_works':
      case 'public-works':
        return FilterType.publicWorks;
      case 'airport':
        return FilterType.airport;
      case 'park':
        return FilterType.park;
      default:
        return FilterType.all;
    }
  }

  static TabBarType getCaseType(String status) {
    switch (status) {
      case 'new':
        return TabBarType.newTab;
      case 'dispatch':
        return TabBarType.dispatch;
      case 'cases':
        return TabBarType.cases;
      default:
        return TabBarType.newTab;
    }
  }

  static Future<Map<FilterType, BitmapDescriptor>> loadIcons(
    AppAssets assets, {
    required Size markerSize,
  }) async {
    final String cacheKey = '${markerSize.width}x${markerSize.height}';
    if (_iconCache.containsKey(cacheKey)) {
      return _iconCache[cacheKey]!;
    }

    final icons = {
      FilterType.traffic: await BitmapDescriptor.asset(
        ImageConfiguration(size: markerSize),
        assets.vehicleIcon,
      ),
      FilterType.publicWorks: await BitmapDescriptor.asset(
        ImageConfiguration(size: markerSize),
        assets.publicGroupIcon,
      ),
      FilterType.airport: await BitmapDescriptor.asset(
        ImageConfiguration(size: markerSize),
        assets.theftIcon,
      ),
      FilterType.park: await BitmapDescriptor.asset(
        ImageConfiguration(size: markerSize),
        assets.publicGroupIcon,
      ),
    };

    _iconCache[cacheKey] = icons;
    return icons;
  }

  static const initialCameraPosition = CameraPosition(
    target: LatLng(12.9716, 77.5946), // Bengaluru
    zoom: 12,
  );

  static Future<void> zoomIn(GoogleMapController? controller) async {
    if (controller != null) controller.animateCamera(CameraUpdate.zoomIn());
  }

  static Future<void> zoomOut(GoogleMapController? controller) async {
    if (controller != null) controller.animateCamera(CameraUpdate.zoomOut());
  }

  static Offset? getOffsetForLatLng(
    GoogleMapController? controller,
    LatLngBounds? mapBounds,
    Size? mapSize,
    LatLng? markerLatLng, {
    double markerSize = markerWidthMobile,
  }) {
    if (markerLatLng == null ||
        controller == null ||
        mapBounds == null ||
        mapSize == null) {
      return null;
    }
    LatLng sw = mapBounds.southwest;
    LatLng ne = mapBounds.northeast;
    double dx =
        ((markerLatLng.longitude - sw.longitude) /
            (ne.longitude - sw.longitude)) *
        mapSize.width;
    double dy =
        ((ne.latitude - markerLatLng.latitude) / (ne.latitude - sw.latitude)) *
        mapSize.height;
    bool showLeft = dx + infoWindowWidth > mapSize.width;
    double offsetX = showLeft
        ? dx - infoWindowWidth + markerSize / 2.1
        : dx + markerSize / 2.1;
    double offsetY = dy - markerSize * 2;
    return Offset(offsetX, offsetY);
  }

  static Future<void> resetCameraPosition(
    GoogleMapController? controller,
  ) async {
    if (controller != null) {
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(initialCameraPosition),
      );
    }
  }

  static Future<void> goToCurrentLocation(
    GoogleMapController? controller,
  ) async {
    await resetCameraPosition(controller);
    // Position position = await Geolocator.getCurrentPosition(
    //     desiredAccuracy: LocationAccuracy.high);
    // final controller = await _controller.future;
    // controller.animateCamera(
    //   CameraUpdate.(
    //     CameraPosition(
    //       target: LatLng(position.latitude, position.longitude),
    //       zoom: 16,
    //     ),
    //   ),
    // );
  }
}
