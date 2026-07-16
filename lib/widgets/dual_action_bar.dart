import 'package:flutter/material.dart';
import 'package:taxed/theme/app_colors.dart';
import 'package:taxed/theme/app_text_styles.dart';
import 'package:taxed/widgets/app_content_width.dart';

class DualActionBarAction {
  const DualActionBarAction({
    required this.label,
    required this.onTap,
    this.key,
  });

  final String label;
  final VoidCallback onTap;
  final Key? key;
}

class DualActionBar extends StatelessWidget {
  const DualActionBar({
    super.key,
    required this.left,
    required this.right,
  });

  final DualActionBarAction left;
  final DualActionBarAction right;

  @override
  Widget build(BuildContext context) {
    return AppContentWidth(
      child: Row(
        children: [
          Expanded(child: _ActionButton(action: left, color: AppColors.navy)),
          Expanded(
            child: _ActionButton(action: right, color: AppColors.accentOrange),
          ),
        ],
      ),
    );
  }
}

class TripleActionBar extends StatelessWidget {
  const TripleActionBar({
    super.key,
    required this.left,
    required this.middle,
    required this.right,
  });

  final DualActionBarAction left;
  final DualActionBarAction middle;
  final DualActionBarAction right;

  @override
  Widget build(BuildContext context) {
    return AppContentWidth(
      child: Row(
        children: [
          Expanded(child: _ActionButton(action: left, color: AppColors.navy)),
          Expanded(
            child: _ActionButton(
              action: middle,
              color: Colors.white,
              labelColor: const Color(0xFF333333),
            ),
          ),
          Expanded(
            child: _ActionButton(
              action: right,
              color: AppColors.accentOrange,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.action,
    required this.color,
    this.labelColor = Colors.white,
  });

  final DualActionBarAction action;
  final Color color;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      child: InkWell(
        key: action.key,
        onTap: action.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Text(
            action.label,
            textAlign: TextAlign.center,
            style: AppTextStyles.fira(size: 16, color: labelColor),
          ),
        ),
      ),
    );
  }
}
