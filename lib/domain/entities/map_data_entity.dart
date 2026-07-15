import 'package:json_annotation/json_annotation.dart';
import 'package:vvk_ui_kit/core.dart';

part 'map_data_entity.g.dart';

@JsonSerializable()
class MapDataEntity {
  String? id;
  String? type;
  String? cameraName;
  String? locationName;
  String? locationAddress;
  String? locationType;
  CoordinatesEntity? coordinates;
  String? date;
  String? time;
  String? isoTimestamp;
  int? confidenceScore;
  String? status;
  String? severity;
  bool? isLive;
  String? imageUrl;
  String? cameraUrl;
  String? vehicleNo;

  MapDataEntity({
    this.id,
    this.type,
    this.cameraName,
    this.locationName,
    this.locationAddress,
    this.locationType,
    this.coordinates,
    this.date,
    this.time,
    this.isoTimestamp,
    this.confidenceScore,
    this.status,
    this.severity,
    this.isLive,
    this.imageUrl,
    this.cameraUrl,
    this.vehicleNo,
  });

  factory MapDataEntity.fromJson(Map<String, dynamic> json) =>
      _$MapDataEntityFromJson(json);

  Map<String, dynamic> toJson() => _$MapDataEntityToJson(this);
}

@JsonSerializable()
class CoordinatesEntity implements JsonHelper {
  double? latitude;
  double? longitude;

  CoordinatesEntity({this.latitude, this.longitude});

  factory CoordinatesEntity.fromJson(Map<String, dynamic> json) =>
      _$CoordinatesEntityFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CoordinatesEntityToJson(this);
}
