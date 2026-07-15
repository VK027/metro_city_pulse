import 'package:metro_city_pulse/core/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:vvk_ui_kit/vvk_ui_kit.dart';

class MapZoomControlWidget extends StatelessWidget {
  final VoidCallback? onLocationPressed;
  final VoidCallback? onZoomInPressed;
  final VoidCallback? onZoomOutPressed;
  final VoidCallback? onResetPressed;
  final VoidCallback? onExclamationPressed;

  const MapZoomControlWidget({
    super.key,
    required this.theme,
    this.onLocationPressed,
    this.onZoomInPressed,
    this.onZoomOutPressed,
    this.onResetPressed,
    this.onExclamationPressed,
  });

  final AppTheme theme;

  ShapeBorder _controlShape(BorderRadius borderRadius) {
    return RoundedRectangleBorder(
      borderRadius: borderRadius,
      side: BorderSide(
        color: theme.colors.lightGray.withValues(alpha: 0.35),
      ),
    );
  }

  Widget _buildControlButton({
    required String heroTag,
    required String iconAsset,
    required VoidCallback? onPressed,
    required ShapeBorder shape,
  }) {
    return FloatingActionButton(
      mini: true,
      backgroundColor: theme.colors.surface,
      foregroundColor: theme.colors.primaryColor,
      elevation: 2,
      heroTag: heroTag,
      onPressed: onPressed,
      shape: shape,
      child: UIImage(
        iconAsset,
        width: 24,
        height: 24,
        color: theme.colors.primaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobileContext(context);

    return Column(
      children: [
        if (isMobile) ...[
          _buildControlButton(
            heroTag: 'exclamation_all',
            iconAsset: theme.assets.exclamationIcon,
            onPressed: onExclamationPressed,
            shape: _controlShape(BorderRadius.circular(8)),
          ),
          const SizedBox(height: 6),
          _buildControlButton(
            heroTag: 'reset_all',
            iconAsset: theme.assets.resetIcon,
            onPressed: onResetPressed,
            shape: _controlShape(BorderRadius.circular(8)),
          ),
          const SizedBox(height: 6),
        ],
        _buildControlButton(
          heroTag: 'center_location',
          iconAsset: theme.assets.locationIcon,
          onPressed: onLocationPressed,
          shape: _controlShape(BorderRadius.circular(8)),
        ),
        const SizedBox(height: 8),
        if (!isMobile) ...[
          _buildControlButton(
            heroTag: 'zoom_in',
            iconAsset: theme.assets.zoomInIcon,
            onPressed: onZoomInPressed,
            shape: _controlShape(
              const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
          ),
          _buildControlButton(
            heroTag: 'zoom_out',
            iconAsset: theme.assets.zoomOutIcon,
            onPressed: onZoomOutPressed,
            shape: _controlShape(
              const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
