import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taxed/theme/app_colors.dart';

class HomeActionButton extends StatelessWidget {
  const HomeActionButton({
    super.key,
    required this.iconAsset,
    required this.label,
    required this.onTap,
    this.buttonColor = AppColors.buttonFill,
    this.labelColor = AppColors.navy,
  });

  final String iconAsset;
  final String label;
  final VoidCallback onTap;
  final Color buttonColor;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: buttonColor,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                iconAsset,
                width: 28,
                height: 28,
                colorFilter: const ColorFilter.mode(
                  AppColors.accentOrange,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: GoogleFonts.firaCode(
                  fontSize: 18,
                  color: labelColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
