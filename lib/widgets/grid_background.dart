import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

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
    final settings = context.watch<SettingsProvider>();
    final gridColor = color ?? Theme.of(context).dividerColor.withAlpha((0.25 * 255).round());

    // Validate image path before using as background
    final String? path = (settings.backgroundType == 'image' && (settings.backgroundPath?.isNotEmpty ?? false))
        ? settings.backgroundPath
        : null;

    Widget? backgroundImage;
    if (path != null) {
      if (path.startsWith('http://') || path.startsWith('https://')) {
        // Only use network image if the URL is valid (basic check)
        final uri = Uri.tryParse(path);
        if (uri != null && (uri.isScheme('http') || uri.isScheme('https'))) {
          backgroundImage = Image.network(
            path,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
          );
        }
      } else if (!kIsWeb) {
        // Only use file image if the file exists
        final file = File(path);
        if (file.existsSync()) {
          backgroundImage = Image.file(
            file,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
          );
        }
      }
    }

    // If a valid image is available, use it; otherwise, just show the grid
    return Stack(
      children: [
        if (backgroundImage != null) Positioned.fill(child: backgroundImage),
        CustomPaint(painter: _GridPainter(color: gridColor, step: step), child: child),
      ],
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
