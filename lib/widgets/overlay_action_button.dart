// widgets/overlay_action_button.dart
// Small circular action button used in overlays/sidebars.
//
// Purpose:
// - Appear with a staggered slide+fade animation based on `order`.
// - Invoke `onTap` when pressed.
// - Optionally adapt behavior for selection mode (disabled/hidden behavior).
//
// API notes:
// - `order`: integer used to stagger entrance animation.
// - `selectionMode`: when true, the button becomes visually de-emphasized
//   and taps are ignored to avoid accidental actions during multi-select.

import 'package:flutter/material.dart';

class OverlayActionButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final int order;
  final VoidCallback onTap;
  final bool selectionMode; // If true, button is disabled/de-emphasized

  const OverlayActionButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.order,
    this.color = Colors.white,
    this.selectionMode = false,
  });

  @override
  State<OverlayActionButton> createState() => _OverlayActionButtonState();
}

class _OverlayActionButtonState extends State<OverlayActionButton> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    // Staggered entrance: delay based on order so multiple buttons animate nicely
    Future.delayed(Duration(milliseconds: 60 * widget.order), () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    // When in selection mode we reduce opacity and ignore taps.
    final bool disabled = widget.selectionMode;

    return AnimatedSlide(
      offset: _visible ? Offset.zero : const Offset(0.5, 0),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: _visible ? (disabled ? 0.6 : 1.0) : 0,
        duration: const Duration(milliseconds: 200),
        child: GestureDetector(
          onTap: disabled ? null : widget.onTap,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.black.withAlpha((0.6 * 255).round()),
              shape: BoxShape.circle,
            ),
            child: Icon(
              widget.icon,
              color: widget.color,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}
