import 'package:flutter/material.dart';
import 'package:vvk_ui_kit/vvk_ui_kit.dart';

class MapInfoWindowWidget extends StatelessWidget {
  final String label;
  final String building;
  final String alertId;
  final String timestamp;
  final double infoWindowWidth;

  const MapInfoWindowWidget({
    super.key,
    required this.label,
    required this.building,
    required this.alertId,
    required this.timestamp,
    this.infoWindowWidth = 150.0,
  });

  @override
  Widget build(BuildContext context) {

    const Color cardBg = Color(0xFFDFDFDF);
    const Color accent = Color(0xFF0039A6);
    const Color bgGrey = Color(0xFF878585);

    return Material(
      elevation: 2.0,
      //color: Colors.transparent,
      type: MaterialType.transparency,
      borderRadius: BorderRadius.circular(6.0),
      child: SizedBox(
        width: infoWindowWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(6.0),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: UIText(
                      label,
                      size: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                      letterSpacing: 0.5
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 4),
            Container(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(6.0),
                border: Border.all(color: bgGrey),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  UIText(
                    building,
                    size: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87
                  ),
                  UIText(
                    alertId,
                    size: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.black87,
                  ),
                  UIText(
                    timestamp,
                    size: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.black87,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}