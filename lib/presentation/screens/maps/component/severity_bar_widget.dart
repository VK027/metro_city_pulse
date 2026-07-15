import 'package:flutter/material.dart';
import 'package:vvk_ui_kit/vvk_ui_kit.dart';

class SeverityBarWidget extends StatelessWidget {
  final Function(int) onSelected;
  final int selectedSeverityIndex;
  final List<Map<String, Object>> severities;
  final bool isMobile;
  final Function() onClose;

  const SeverityBarWidget({
    super.key,
    required this.onSelected,
    required this.selectedSeverityIndex,
    required this.severities,
    required this.isMobile,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isMobile ? 90 : kMinInteractiveDimension,
      decoration: BoxDecoration(
        color: const Color(0xFF535D60),
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: isMobile
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      buildSeverityText(),
                      (selectedSeverityIndex != -1)
                          ? UITextButton(
                              text: 'Clear',
                              color: Colors.white,
                              onPressed: () => onSelected(-1),
                              size: 12,
                            )
                          : closeIconButton(iconSize: 12.0),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Expanded(child: severityListWidget()),
                ],
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SeverityContainerWidget(
                  color: const Color(0xFF636F74),
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6.0),
                    bottomLeft: Radius.circular(6.0),
                  ),
                  child: buildSeverityText(),
                ),
                severityListWidget(),
                Visibility(
                  visible: selectedSeverityIndex != -1,
                  child: SeverityContainerWidget(
                    color: const Color(0xFF636F74),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(6.0),
                      bottomRight: Radius.circular(6.0),
                    ),
                    child: closeIconButton(),
                  ),
                ),
              ],
            ),
    );
  }

  Widget closeIconButton({double iconSize = 16.0}) {
    return IconButton(
      icon: Icon(Icons.close, color: Colors.white, size: iconSize),
      padding: EdgeInsets.zero,
      onPressed: () {
        if (isMobile && selectedSeverityIndex == -1) {
          onClose.call();
        } else {
          onSelected.call(-1);
        }
      },
      iconSize: iconSize,
      color: Colors.white,
      style: ButtonStyle(padding: WidgetStateProperty.all(EdgeInsets.zero)),
    );
  }

  Widget buildSeverityText() {
    return const UIText(
      'Severities',
      color: Colors.white,
      size: 14,
      fontWeight: FontWeight.w400,
    );
  }

  Widget severityListWidget() {
    final double itemHeight = isMobile ? 30.0 : kMinInteractiveDimension;
    final double dividerHeight = isMobile ? 18.0 : 24.0;

    return SizedBox(
      height: itemHeight,
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: severities.length,
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          final severity = severities[index];
          final isSelected = index == selectedSeverityIndex;
          final bool last = index == severities.length - 1;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => onSelected(index),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  height: itemHeight,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFB3B3B3)
                        : Colors.transparent,
                    borderRadius: last
                        ? const BorderRadius.only(
                            topRight: Radius.circular(6.0),
                            bottomRight: Radius.circular(6.0),
                          )
                        : BorderRadius.circular(6.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _SeverityDot(
                        size: isMobile ? 8 : 12,
                        color: severity['color'] as Color,
                      ),
                      const SizedBox(width: 6),
                      UIText(
                        '${severity['label']} – ${severity['count']}'.toUpperCase(),
                        size: isMobile ? 12 : 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                      ),
                    ],
                  ),
                ),
              ),
              if (!last)
                Container(
                  width: 1.5,
                  height: dividerHeight,
                  margin: EdgeInsets.symmetric(
                    vertical: (itemHeight - dividerHeight) / 2,
                  ),
                  color: const Color(0xFF23282B),
                ),
            ],
          );
        },
      ),
    );
  }
}

class SeverityContainerWidget extends StatelessWidget {
  final BorderRadius? borderRadius;
  final Color? color;
  final Widget? child;
  final EdgeInsetsGeometry? padding;

  const SeverityContainerWidget({
    super.key,
    this.borderRadius,
    this.color,
    this.child,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kMinInteractiveDimension,
      alignment: Alignment.center,
      padding: padding,
      decoration: BoxDecoration(color: color, borderRadius: borderRadius),
      child: child ?? const SizedBox.shrink(),
    );
  }
}

class _SeverityDot extends StatelessWidget {
  final Color color;
  final double size;

  const _SeverityDot({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
