import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTextStyles {
  static TextStyle fira({
    required double size,
    required Color color,
    FontWeight? weight,
  }) {
    return GoogleFonts.firaCode(
      fontSize: size,
      color: color,
      fontWeight: weight,
    );
  }
}
