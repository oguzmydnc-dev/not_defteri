import 'package:flutter/material.dart';

/// -------------------- Fade Animation --------------------
Widget fadeIn({
  required Widget child,
  Duration duration = const Duration(milliseconds: 300),
  Curve curve = Curves.easeOut,
  bool visible = true,
}) {
  return AnimatedOpacity(
    opacity: visible ? 1 : 0,
    duration: duration,
    curve: curve,
    child: child,
  );
}

/// -------------------- Scale Animation --------------------
Widget scaleAnimation({
  required Widget child,
  Duration duration = const Duration(milliseconds: 250),
  Curve curve = Curves.easeOutCubic,
  bool visible = true,
}) {
  return AnimatedScale(
    scale: visible ? 1 : 0.8,
    duration: duration,
    curve: curve,
    child: child,
  );
}

/// -------------------- Slide Animation --------------------
Widget slideAnimation({
  required Widget child,
  required Offset beginOffset,
  Duration duration = const Duration(milliseconds: 250),
  Curve curve = Curves.easeOutCubic,
  bool visible = true,
}) {
  return AnimatedSlide(
    offset: visible ? Offset.zero : beginOffset,
    duration: duration,
    curve: curve,
    child: child,
  );
}

/// -------------------- Fade + Slide Combo --------------------
Widget fadeSlide({
  required Widget child,
  required Offset beginOffset,
  Duration duration = const Duration(milliseconds: 300),
  Curve curve = Curves.easeOutCubic,
  bool visible = true,
}) {
  return slideAnimation(
    child: fadeIn(child: child, duration: duration, curve: curve, visible: visible),
    beginOffset: beginOffset,
    duration: duration,
    curve: curve,
    visible: visible,
  );
}
