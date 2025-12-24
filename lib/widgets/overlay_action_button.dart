// widgets/overlay_action_button.dart
import 'package:flutter/material.dart';

class OverlayActionButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final int order;
  final VoidCallback onTap;

  const OverlayActionButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.order,
    this.color = Colors.white,
  });

  @override
  State<OverlayActionButton> createState() => _OverlayActionButtonState();
}

class _OverlayActionButtonState extends State<OverlayActionButton> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 60 * widget.order), () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: _visible ? Offset.zero : const Offset(0.5, 0),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: _visible ? 1 : 0,
        duration: const Duration(milliseconds: 200),
        child: GestureDetector(
          onTap: widget.onTap,
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
