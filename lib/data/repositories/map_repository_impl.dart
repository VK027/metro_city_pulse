import 'dart:convert';

import 'package:metro_city_pulse/data/repositories/base/base_api_repository.dart';
import 'package:metro_city_pulse/domain/entities/map_data_entity.dart';
import 'package:metro_city_pulse/domain/repositories/map_repository.dart';
import 'package:flutter/services.dart';

class MapRepositoryImp extends BaseApiRepository implements MapRepository {
  List<MapDataEntity>? _cachedMapData;

  @override
  Future<List<MapDataEntity>> getMapDataList() async {
    if (_cachedMapData != null) {
      return _cachedMapData!;
    }

    // TODO: implement getMapDataList with api
    final String responseBody = await rootBundle.loadString(
      'assets/json/maps_sample_data.json',
    );
    final parsedList =
        (await jsonDecode(responseBody) as List).cast<Map<String, dynamic>>();

    _cachedMapData =
        parsedList.map<MapDataEntity>((json) => MapDataEntity.fromJson(json)).toList();

    return _cachedMapData!;
  }
}
