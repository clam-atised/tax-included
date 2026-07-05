import 'package:flutter/material.dart';
import 'package:taxed/theme/app_colors.dart';
import 'package:taxed/theme/app_text_styles.dart';
import 'package:taxed/utils/input_formatters.dart';
import 'package:taxed/utils/input_limits.dart';

final _formatter = MaxIntFormatter();

class SplitCountField extends StatefulWidget {
  const SplitCountField({
    super.key,
    required this.splitCount,
    required this.onSplitCountChanged,
    required this.labelColor,
  });

  final int splitCount;
  final ValueChanged<int> onSplitCountChanged;
  final Color labelColor;

  @override
  State<SplitCountField> createState() => _SplitCountFieldState();
}

class _SplitCountFieldState extends State<SplitCountField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.splitCount.toString());
  }

  @override
  void didUpdateWidget(SplitCountField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.splitCount != widget.splitCount &&
        _controller.text != widget.splitCount.toString()) {
      _controller.text = widget.splitCount.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateCount(int value) {
    final clamped = value.clamp(InputLimits.minSplitCount, InputLimits.maxSplitCount);
    _controller.text = clamped.toString();
    widget.onSplitCountChanged(clamped);
  }

  void _onTextChanged(String text) {
    final clamped = _formatter.clampParsed(text);
    if (text.isNotEmpty && text != clamped.toString()) {
      _controller.value = TextEditingValue(
        text: clamped.toString(),
        selection: TextSelection.collapsed(offset: clamped.toString().length),
      );
    }
    widget.onSplitCountChanged(clamped);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.only(left: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: TextField(
              key: const Key('split_count_input'),
              controller: _controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: AppTextStyles.fira(size: 14, color: widget.labelColor),
              inputFormatters: [
                MaxIntFormatter(
                  min: InputLimits.minSplitCount,
                  max: InputLimits.maxSplitCount,
                ),
              ],
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: _onTextChanged,
            ),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: widget.splitCount.clamp(
                InputLimits.minSplitCount,
                InputLimits.maxSplitCount,
              ),
              isDense: true,
              icon: const Icon(
                Icons.arrow_drop_down,
                color: AppColors.accentOrange,
              ),
              items: List.generate(
                InputLimits.maxSplitCount + 1,
                (index) => DropdownMenuItem(
                  value: index,
                  child: Text('$index'),
                ),
              ),
              onChanged: (value) {
                if (value != null) _updateCount(value);
              },
            ),
          ),
        ],
      ),
    );
  }
}
