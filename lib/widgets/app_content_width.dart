import 'package:flutter/material.dart';

class AppContentWidth extends StatelessWidget {
  const AppContentWidth({
    super.key,
    required this.child,
  });

  final Widget child;

  static const double maxWidth = 800;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
