import 'package:flutter/material.dart';

/// Grid background for note lists.
class GridBackground extends StatelessWidget {
  final Widget? child;
  final Color? color;
  final double step;

  const GridBackground({
    super.key,
    this.child,
    this.color,
    this.step = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    final gridColor = color ?? Theme.of(context).dividerColor.withAlpha((0.25 * 255).round());
    return CustomPaint(
      painter: _GridPainter(color: gridColor, step: step),
      child: child,
    );
  }
}

class _GridPainter extends CustomPainter {
  final Color color;
  final double step;

  _GridPainter({required this.color, required this.step});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.8;

    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
