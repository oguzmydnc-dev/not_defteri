import 'package:flutter/material.dart';

class GridBackground extends StatelessWidget {
  final Widget child;

  const GridBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GridPainter(
        color: Theme.of(context).dividerColor.withOpacity(0.15),
      ),
      child: child,
    );
  }
}

class _GridPainter extends CustomPainter {
  final Color color;

  _GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const step = 24.0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5;

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
