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

    // If user selected a custom image, attempt to render it behind the grid.
    if (settings.backgroundType == 'image' && (settings.backgroundPath?.isNotEmpty ?? false)) {
      final path = settings.backgroundPath!;

      Widget imageWidget() {
        if (path.startsWith('http://') || path.startsWith('https://')) {
          return Image.network(
            path,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(child: CircularProgressIndicator());
            },
            errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.broken_image, size: 48)),
          );
        }

        if (!kIsWeb) {
          final file = File(path);
          if (file.existsSync()) {
            return Image.file(
              file,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.broken_image, size: 48)),
            );
          }
        }

        // Fallback attempt: try network; will display errorBuilder if invalid.
        return Image.network(
          path,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
          errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.broken_image, size: 48)),
        );
      }

      return Stack(
        children: [
          Positioned.fill(child: imageWidget()),
          CustomPaint(painter: _GridPainter(color: gridColor, step: step), child: child),
        ],
      );
    }

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
