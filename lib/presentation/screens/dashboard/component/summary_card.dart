import 'package:flutter/material.dart';
import 'package:metro_city_pulse/core/themes/app_theme.dart';
import 'package:vvk_ui_kit/vvk_ui_kit.dart';

class SummaryCard extends StatelessWidget {
  final AppTheme theme;
  final String title;
  final String value;
  final String icon;
  final Color backgroundColor;
  final double? changePercent;
  final String comparisonLabel;

  const SummaryCard({
    super.key,
    required this.theme,
    required this.title,
    required this.value,
    required this.icon,
    required this.backgroundColor,
    this.changePercent,
    this.comparisonLabel = '',
  });

  @override
  Widget build(BuildContext context) {
    final Color textColor = theme.colors.text;

    return UICard(
      color: theme.colors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UIText(
            title,
            maxLines: 1,
            textOverflow: TextOverflow.ellipsis,
            color: textColor.withValues(alpha: 0.65),
            size: 13,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.15,
            lineHeight: 1.2,
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UIText(
                      value,
                      maxLines: 1,
                      textOverflow: TextOverflow.ellipsis,
                      color: textColor,
                      size: 26,
                      fontWeight: FontWeight.w700,
                      lineHeight: 1,
                      letterSpacing: -0.5,
                    ),
                    if (changePercent != null && comparisonLabel.isNotEmpty)
                      _TrendSubtitle(
                        theme: theme,
                        changePercent: changePercent!,
                        comparisonLabel: comparisonLabel,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              RepaintBoundary(
                child: UIImage(
                  icon,
                  width: 30,
                  height: 30,
                  color: backgroundColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrendSubtitle extends StatelessWidget {
  final AppTheme theme;
  final double changePercent;
  final String comparisonLabel;

  const _TrendSubtitle({
    required this.theme,
    required this.changePercent,
    required this.comparisonLabel,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPositive = changePercent >= 0;
    final Color trendColor = isPositive
        ? const Color(0xFF198754)
        : const Color(0xFFDC3545);
    final String arrow = isPositive ? '↑' : '↓';
    final String percentText = '${changePercent.abs().toStringAsFixed(1)}%';
    final Color baseTextColor = theme.colors.text;

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: RichText(
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          children: [
            TextSpan(
              text: '$arrow $percentText ',
              style: TextStyle(
                color: trendColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
            TextSpan(
              text: comparisonLabel,
              style: TextStyle(
                color: baseTextColor.withValues(alpha: 0.5),
                fontSize: 12,
                fontWeight: FontWeight.w400,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
