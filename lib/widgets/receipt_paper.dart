import 'package:flutter/material.dart';

class ReceiptPaperClipper extends CustomClipper<Path> {
  const ReceiptPaperClipper({
    this.toothWidth = 14,
    this.toothHeight = 10,
  });

  final double toothWidth;
  final double toothHeight;

  @override
  Path getClip(Size size) {
    final path = Path()..moveTo(0, toothHeight);

    for (var x = 0.0; x < size.width; x += toothWidth) {
      final mid = x + toothWidth / 2;
      final end = x + toothWidth;
      path.lineTo(mid, 0);
      path.lineTo(end, toothHeight);
    }

    path
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(covariant ReceiptPaperClipper oldClipper) =>
      toothWidth != oldClipper.toothWidth ||
      toothHeight != oldClipper.toothHeight;
}

class DashedLine extends StatelessWidget {
  const DashedLine({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const dashWidth = 6.0;
        const dashSpace = 4.0;
        final dashCount =
            (constraints.maxWidth / (dashWidth + dashSpace)).floor();

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
        );
      },
    );
  }
}

class DoubleReceiptDivider extends StatelessWidget {
  const DoubleReceiptDivider({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(height: 1, color: color),
        const SizedBox(height: 4),
        DashedLine(color: color.withValues(alpha: 0.4)),
      ],
    );
  }
}
