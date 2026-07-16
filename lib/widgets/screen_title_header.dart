import 'package:flutter/material.dart';
import 'package:taxed/theme/app_text_styles.dart';

class ScreenTitleHeader extends StatelessWidget {
  const ScreenTitleHeader({
    super.key,
    required this.title,
    required this.labelColor,
  });

  final String title;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.only(top: 16, right: 24),
        child: Text(
          title,
          style: AppTextStyles.fira(
            size: 28,
            color: labelColor,
            weight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
