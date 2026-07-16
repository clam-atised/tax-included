import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taxed/theme/app_colors.dart';

class InsertAddRowButton extends StatelessWidget {
  const InsertAddRowButton({
    super.key,
    required this.label,
    required this.onTap,
    required this.labelColor,
  });

  final String label;
  final VoidCallback onTap;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: AppColors.accentOrange,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.firaCode(
                fontSize: 14,
                color: labelColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
