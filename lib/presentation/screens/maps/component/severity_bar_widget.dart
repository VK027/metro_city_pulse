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
      decoration: BoxDecoration(color: Color(0xFF535D60), borderRadius: BorderRadius.circular(6.0)),
      child: isMobile
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
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
                  Flexible(
                    fit: FlexFit.tight,
                    flex: 1,
                    child: severityListWidget(),
                  ),
                ],
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SeverityContainerWidget(
                  color: Color(0xFF636F74),
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(6.0), bottomLeft: Radius.circular(6.0)),
                  child: buildSeverityText(),
                ),
                severityListWidget(),
                Visibility(
                  visible: selectedSeverityIndex != -1,
                  child: SeverityContainerWidget(
                    color: Color(0xFF636F74),
                    borderRadius: BorderRadius.only(topRight: Radius.circular(6.0), bottomRight: Radius.circular(6.0)),
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
    return UIText(
      "Severities",
      color: Colors.white,
      size: 14,
      fontWeight: FontWeight.w400,
    );
  }

  Widget severityListWidget() {
    double dividerHeight = isMobile ? 18 : 24;
    return ListView.builder(
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      itemCount: severities.length,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        final severity = severities[index];
        final isSelected = index == selectedSeverityIndex;
        final bool last = index == severities.length - 1;
        return GestureDetector(
          onTap: () => onSelected(index),
          behavior: HitTestBehavior.opaque,
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.0),
                decoration: isSelected
                    ? BoxDecoration(
                        color: isSelected
                            ? Color(0xFFB3B3B3)
                            : Colors.transparent,
                        //borderRadius: BorderRadius.circular(6.0),
                        borderRadius: last
                            ? BorderRadius.only(
                                topRight: Radius.circular(6.0),
                                bottomRight: Radius.circular(6.0),
                              )
                            : BorderRadius.circular(6.0),
                        //border: Border.all(color: Colors.white, width: 2),
                      )
                    : BoxDecoration(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _SeverityDot(
                      size: isMobile ? 8 : 12,
                      color: severity["color"] as Color,
                    ),
                    SizedBox(width: 6),
                    UIText(
                      "${severity['label']} – ${severity['count']}"
                          .toUpperCase(),
                      size: isMobile ? 12 : 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                    ),
                  ],
                ),
              ),
              if (!last)
                Container(
                  //margin: EdgeInsets.symmetric(horizontal: 18),
                  width: 1.5,
                  height: dividerHeight,
                  color: Color(0xFF23282B),
                ),
            ],
          ),
        );
      },
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
      child: child ?? SizedBox.shrink(),
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
