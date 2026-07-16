import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:taxed/theme/app_colors.dart';

class ModeToggle extends StatelessWidget {
  const ModeToggle({
    super.key,
    required this.isNightMode,
    required this.onChanged,
  });

  final bool isNightMode;
  final ValueChanged<bool> onChanged;

  static const _trackWidth = 200.0;
  static const _trackHeight = 56.0;
  static const _thumbSize = 48.0;
  static const _padding = 4.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: const Key('mode_toggle'),
      onTap: () => onChanged(!isNightMode),
      child: SizedBox(
        width: _trackWidth,
        height: _trackHeight,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.buttonFill,
            borderRadius: BorderRadius.circular(_trackHeight / 2),
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            alignment:
                isNightMode ? Alignment.centerRight : Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.all(_padding),
              child: Container(
                width: _thumbSize,
                height: _thumbSize,
                decoration: BoxDecoration(
                  color: isNightMode ? AppColors.navy : AppColors.accentOrange,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SvgPicture.asset(
                    isNightMode
                        ? 'assets/icons/moon.svg'
                        : 'assets/icons/sun.svg',
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(
                      isNightMode ? AppColors.accentOrange : Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
