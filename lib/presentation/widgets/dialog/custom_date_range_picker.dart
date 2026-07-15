import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:metro_city_pulse/presentation/utils/localization_util.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:vvk_ui_kit/vvk_ui_kit.dart';

class CustomDateRangePicker extends ConsumerStatefulWidget {
  const CustomDateRangePicker({super.key});

  @override
  ConsumerState<CustomDateRangePicker> createState() =>
      _CustomDateRangePickerState();
}

class _CustomDateRangePickerState extends ConsumerState<CustomDateRangePicker> {
  PickerDateRange? _selectedRange;
  String? _activeQuickOption;
  int _pickerResetVersion = 0;
  final DateRangePickerController _datePickerController =
      DateRangePickerController();

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    if (args.value is PickerDateRange) {
      setState(() {
        _selectedRange = args.value;
      });
    }
  }

  void _setQuickRange(String type) {
    final normalizedType = type.toLowerCase().replaceAll(' ', '_');
    final now = DateTime.now();
    DateTime start;
    DateTime end;

    switch (normalizedType) {
      case "today":
        start = end = now;
        break;
      case "yesterday":
        start = end = now.subtract(const Duration(days: 1));
        break;
      case "last_week":
        start = now.subtract(Duration(days: now.weekday + 6));
        end = start.add(const Duration(days: 6));
        break;
      case "last_month":
        start = DateTime(now.year, now.month - 1, 1);
        end = DateTime(now.year, now.month, 0);
        break;
      case "last_quarter":
        final currentQuarter = ((now.month - 1) ~/ 3) + 1;
        final startMonth = (currentQuarter - 2) * 3 + 1;
        start = DateTime(now.year, startMonth, 1);
        end = DateTime(now.year, startMonth + 3, 0);
        break;
      default:
        return;
    }

    setState(() {
      _selectedRange = PickerDateRange(start, end);
      _datePickerController.selectedRange = _selectedRange;
      _datePickerController.displayDate = start;
      _activeQuickOption = normalizedType;
    });
  }

  void _resetSelection() {
    setState(() {
      _selectedRange = null;
      _activeQuickOption = null;
      _pickerResetVersion++;
      _datePickerController.selectedDate = null;
      _datePickerController.selectedDates = null;
      _datePickerController.selectedRange = null;
      _datePickerController.selectedRanges = null;
      _datePickerController.displayDate = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.sizeOf(context);
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: screenWidth > 600 ? 480 : screenWidth * 0.9, //520
      height: screenHeight > 600 ? 380 : screenHeight * 0.6, //430
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Left shortcuts
          SizedBox(
            width: 130,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _quickOption(context, "today".tr(ref), "today"),
                _quickOption(context, "yesterday".tr(ref), "yesterday"),
                _quickOption(context, "last_week".tr(ref), "last_week"),
                _quickOption(context, "last_month".tr(ref), "last_month"),
                _quickOption(context, "last_quarter".tr(ref), "last_quarter"),
                const Spacer(),
                Align(
                  alignment: Alignment.centerLeft,
                  child: UITextButton(
                    text: "reset".tr(ref).capitalizeAllFirstLetters(),
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                    onPressed: () {
                      _resetSelection();
                      Navigator.pop(
                        context,
                        {"applied": true, "range": null},
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          const VerticalDivider(width: 1),

          // Calendar + Buttons
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(6),
                    child: SfDateRangePicker(
                      controller: _datePickerController,
                      onSelectionChanged: _onSelectionChanged,
                      selectionMode: DateRangePickerSelectionMode.range,
                      selectionColor: colorScheme.primary,
                      rangeSelectionColor: colorScheme.primary.withValues(
                        alpha: 0.2,
                      ),
                      todayHighlightColor: colorScheme.primary,
                      showActionButtons: false,
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
                      initialSelectedRange: _selectedRange,
                      key: ValueKey(
                        "${_selectedRange?.startDate.toString() ?? "empty"}-$_pickerResetVersion",
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(
                        context,
                        {"applied": false},
                      ),
                      child: Text("cancel".tr(ref).capitalizeAllFirstLetters()),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(
                        context,
                        {"applied": true, "range": _selectedRange},
                      ),
                      child: Text("apply".tr(ref).capitalizeAllFirstLetters()),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickOption(BuildContext context, String label, String type) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isActive = _activeQuickOption == type;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => _setQuickRange(type),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isActive
              ? colorScheme.primary.withValues(alpha: 0.14)
              : Colors.transparent,
          border: Border.all(
            color: isActive
                ? colorScheme.primary.withValues(alpha: 0.55)
                : Colors.transparent,
          ),
        ),
        child: UIText(
          label,
          size: 14,
          fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          color: isActive ? colorScheme.primary : colorScheme.onSurface,
        ),
      ),
    );
  }
}
