import 'package:metro_city_pulse/presentation/utils/localization_util.dart';
import 'package:metro_city_pulse/presentation/widgets/dialog/custom_date_range_picker.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:vvk_ui_kit/vvk_ui_kit.dart';

class ResponsiveDateRangeSelector extends ConsumerStatefulWidget {
  final bool isTablet;
  final Color? foregroundColor;
  final Color? borderColor;

  const ResponsiveDateRangeSelector({
    super.key,
    this.isTablet = false,
    this.foregroundColor,
    this.borderColor,
  });

  @override
  ConsumerState<ResponsiveDateRangeSelector> createState() =>
      _ResponsiveDateRangeSelectorState();
}

class _ResponsiveDateRangeSelectorState
    extends ConsumerState<ResponsiveDateRangeSelector> {
  PickerDateRange? _selectedRange;
  PickerDateRange? _tempRange;
  final DateRangePickerController _datePickerController =
      DateRangePickerController();
  String? _activeQuickOption;

  PickerDateRange _toPickerRange(DateTimeRange range) =>
      PickerDateRange(range.start, range.end);

  void _setQuickRange(String type) {
    final PickerDateRange range =
        _toPickerRange(DateTimeUtil.getDateRangeByType(type));
    setState(() {
      _tempRange = range;
      _datePickerController.selectedRange = range;
      _datePickerController.displayDate = range.startDate;
      _activeQuickOption = type;
    });
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs? args) {
    if (args != null && args.value is PickerDateRange) {
      final PickerDateRange range = args.value as PickerDateRange;
      setState(() {
        _tempRange = range;
        _activeQuickOption = _detectQuickOption(
          range,
        ); // auto-highlight if match
      });
    }
  }

  void _onReset() {
    setState(() {
      _tempRange = null;
      _selectedRange = null;
      _datePickerController.selectedRange = null;
      _activeQuickOption = null;
    });
  }

  String? _detectQuickOption(PickerDateRange range) {
    final quickOptions = [
      "today",
      "yesterday",
      "last_week",
      "last_month",
      "last_quarter",
    ];
    for (final String opt in quickOptions) {
      final qr = _toPickerRange(DateTimeUtil.getDateRangeByType(opt));
      if (_isSameRange(qr, range)) {
        return opt;
      }
    }
    return null;
  }

  bool _isSameRange(PickerDateRange a, PickerDateRange b) {
    return a.startDate!.year == b.startDate!.year &&
        a.startDate!.month == b.startDate!.month &&
        a.startDate!.day == b.startDate!.day &&
        a.endDate!.year == b.endDate!.year &&
        a.endDate!.month == b.endDate!.month &&
        a.endDate!.day == b.endDate!.day;
  }

  String _formatRange(PickerDateRange? range) {
    if (range == null || range.startDate == null || range.endDate == null) {
      return "";
    }
    final formatter = DateFormat("MMM d, yyyy");
    return "${formatter.format(range.startDate!)} - ${formatter.format(range.endDate!)}";
  }

  Future<void> _pickDateRange(bool isMobile) async {
    final colorScheme = Theme.of(context).colorScheme;
    Map<String, dynamic>? result;
    if (!isMobile) {
      // Desktop / Tablet -> dialog
      final renderBox = context.findRenderObject() as RenderBox;
      final position = renderBox.localToGlobal(Offset.zero);
      final screenSize = MediaQuery.sizeOf(context);
      const popupWidth = 440.0;
      const popupHeight = 560.0;
      const screenPadding = 8.0;

      final desiredDx = position.dx - 220;
      final dx = desiredDx.clamp(
        screenPadding,
        screenSize.width - popupWidth - screenPadding,
      );

      final desiredDy = position.dy + renderBox.size.height;
      final maxAllowedDy = screenSize.height - popupHeight - screenPadding;
      final dy = desiredDy <= maxAllowedDy
          ? desiredDy
          : (position.dy - popupHeight).clamp(screenPadding, maxAllowedDy);

      result = await DialogUtil.showAnchoredPopup<Map<String, dynamic>>(
        context,
        position: Offset(dx.toDouble(), dy.toDouble()),
        child: CustomDateRangePicker(),
      );
      // result = await showDialog<PickerDateRange>(
      //   context: context,
      //   builder: (context) => const CustomDateRangePicker(),
      // );
    } else {
      // Mobile -> bottom sheet
      result = await DialogUtil.showWidgetAsBottomSheet<Map<String, dynamic>>(
        context,
        scrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
        ),
        widget: Padding(
          padding: MediaQuery.viewInsetsOf(context), // avoid keyboard overlap
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                _buildCalendarOnly(),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _quickChip("today".tr(ref), "today"),
                      _quickChip("yesterday".tr(ref), "yesterday"),
                      _quickChip("last_week".tr(ref), "last_week"),
                      _quickChip("last_month".tr(ref), "last_month"),
                      _quickChip("last_quarter".tr(ref), "last_quarter"),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    UITextButton(
                      text: "reset".tr(ref).capitalizeAllFirstLetters(),
                      color: colorScheme.primary,
                      onPressed: () {
                        _onReset();
                        Navigator.pop(
                          context,
                          {"applied": true, "range": null},
                        );
                      },
                    ),
                    Row(
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.pop(
                            context,
                            {"applied": false},
                          ),
                          child: Text(
                            "cancel".tr(ref).capitalizeAllFirstLetters(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(
                            context,
                            {
                              "applied": true,
                              "range": _tempRange ?? _selectedRange,
                            },
                          ),
                          child: Text(
                            "apply".tr(ref).capitalizeAllFirstLetters(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // MobileDateRangePicker(),
              ],
            ),
          ),
        ),
      );
    }
    if (result?["applied"] == true) {
      setState(() {
        _selectedRange = result?["range"] as PickerDateRange?;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobileContext(context);
    final colorScheme = Theme.of(context).colorScheme;
    final hasSelectedRange =
        _selectedRange?.startDate != null && _selectedRange?.endDate != null;
    final fgColor = widget.foregroundColor ?? colorScheme.primary;
    return UICustomOutlinedButton(
      label: isMobile ? "" : _formatRange(_selectedRange),
      icon: Icons.calendar_today,
      labelIcon: Icons.keyboard_arrow_down,
      padding: hasSelectedRange
          ? const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0)
          : EdgeInsets.zero,
      onPressed: () => _pickDateRange(isMobile),
      foregroundColor: fgColor,
      borderColor: widget.borderColor,
    );
  }

  // Calendar only
  Widget _buildCalendarOnly({bool showActions = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    return SfDateRangePicker(
      controller: _datePickerController,
      onSelectionChanged: _onSelectionChanged,
      selectionMode: DateRangePickerSelectionMode.range,
      initialSelectedRange: _selectedRange,
      selectionColor: colorScheme.primary,
      rangeSelectionColor: colorScheme.primary.withValues(alpha: 0.2),
      todayHighlightColor: colorScheme.primary,
      backgroundColor: colorScheme.surface,
      headerStyle: DateRangePickerHeaderStyle(
        backgroundColor: colorScheme.surface,
        textAlign: TextAlign.left,
        textStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      monthCellStyle: DateRangePickerMonthCellStyle(
        textStyle: TextStyle(color: colorScheme.onSurface),
        todayTextStyle: TextStyle(
          color: colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
      showActionButtons: showActions,
    );
  }

  Widget _quickChip(String label, String type) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isActive = _activeQuickOption == type;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isActive,
        onSelected: (_) => _setQuickRange(type),
        selectedColor: colorScheme.primary.withValues(alpha: 0.2),
        labelStyle: TextStyle(
          color: isActive ? colorScheme.primary : colorScheme.onSurface,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
