import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taxed/theme/app_text_styles.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.labelColor,
    this.keyboardType = TextInputType.text,
    this.suffixText,
    this.maxLength,
    this.inputFormatters,
  });

  final TextEditingController controller;
  final String hint;
  final Color labelColor;
  final TextInputType keyboardType;
  final String? suffixText;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      style: AppTextStyles.fira(size: 14, color: labelColor),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.fira(
          size: 14,
          color: labelColor.withValues(alpha: 0.5),
        ),
        suffixText: suffixText,
        suffixStyle: AppTextStyles.fira(size: 14, color: labelColor),
        filled: true,
        fillColor: Colors.white,
        counterText: maxLength != null ? '' : null,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
