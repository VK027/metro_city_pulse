import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:metro_city_pulse/core/themes/app_theme.dart';
import 'package:metro_city_pulse/domain/entities/map_data_entity.dart';
import 'package:metro_city_pulse/presentation/utils/localization_util.dart';
import 'package:vvk_ui_kit/vvk_ui_kit.dart';

class AlertListItem extends ConsumerWidget {
  final MapDataEntity alert;
  final AppTheme theme;

  const AlertListItem({super.key, required this.alert, required this.theme});

  String _firstNonEmpty(List<String?> values, {String fallback = '--'}) {
    for (final String? v in values) {
      final String trimmed = v?.trim() ?? '';
      if (trimmed.isNotEmpty) return trimmed;
    }
    return fallback;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String title = _firstNonEmpty([alert.type], fallback: 'Alert');
    final String cameraLabel = _firstNonEmpty(
      [alert.cameraName, alert.vehicleNo, alert.id],
    );
    final String locationLabel = _firstNonEmpty(
      [alert.locationName, alert.locationAddress],
    );
    final String caseLabel = alert.status?.trim().isNotEmpty == true
        ? alert.status!.trim().capitalizeAllFirstLetters()
        : (alert.confidenceScore?.toString() ?? '--');
    final String formattedDate = DateTimeUtil.getFormatDayMonthYearHourMinSec(
      alert.isoTimestamp,
      format: 'MMM dd yyyy h:mm:ss a',
    );
    final Color textColor = theme.colors.text;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UIImage(
            alert.imageUrl ?? '',
            width: 120,
            height: 90,
            borderRadius: BorderRadius.circular(8),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UIText(
                  title,
                  size: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    text: '${'camera'.tr(ref).capitalizeAllFirstLetters()} : ',
                    style: TextStyle(color: textColor),
                    children: [
                      TextSpan(
                        text: cameraLabel,
                        style: TextStyle(
                          color: theme.colors.primaryColor,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                UIText(
                  '${'location'.tr(ref).capitalizeAllFirstLetters()}: $locationLabel',
                  color: textColor,
                ),
                const SizedBox(height: 4),
                UIText(
                  '${'cases'.tr(ref).capitalizeAllFirstLetters()}: $caseLabel',
                  color: textColor,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              UIText(
                formattedDate,
                size: 12,
                color: Colors.grey.shade600,
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 12),
              UIText(
                '${'id_required'.tr(ref).replaceAll('*', '').trim().toUpperCase()} : ${alert.id ?? '--'}',
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
