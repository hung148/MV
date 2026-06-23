import 'package:flutter/material.dart';

/// Wraps any button (or button-like widget) so it lifts slightly and gains
/// a drop-shadow on mouse hover. On touch devices MouseRegion simply never
/// reports a hover, so this is a no-op there — tap behavior is untouched
/// either way.
///
/// Usage:
///   HoverLift(child: ElevatedButton(...))
///
/// For buttons whose own `style` already drives elevation (e.g.
/// ElevatedButton.styleFrom(elevation: ...)), that still works underneath —
/// HoverLift just adds a translateY lift on top. Pass [addShadow]: true for
/// buttons with no built-in elevation (TextButton, OutlinedButton, custom
/// Containers) to get a growing drop-shadow instead.
///
/// IMPORTANT for [addShadow]: pass [borderRadius] matching the button's own
/// `shape: RoundedRectangleBorder(borderRadius: ...)` (or the equivalent
/// default — e.g. Material 3's OutlinedButton/ElevatedButton/TextButton
/// default to a 4px corner radius unless overridden), so the shadow's
/// rounded corners line up with the button's actual corners instead of
/// showing a mismatched silhouette behind it.
class HoverLift extends StatefulWidget {
  final Widget child;

  /// How far (in logical pixels) the child rises on hover.
  final double liftPx;

  /// Extra scale applied on hover, on top of the lift. 1.0 = no scale change.
  final double hoverScale;

  final Duration duration;
  final Curve curve;

  /// If true, wraps the child in its own shadow that grows on hover.
  final bool addShadow;
  final Color shadowColor;

  /// Corner radius of the shadow silhouette. Must match the wrapped
  /// button/card's own corner radius — see class doc above.
  final double borderRadius;

  const HoverLift({
    super.key,
    required this.child,
    this.liftPx = 3,
    this.hoverScale = 1.0,
    this.duration = const Duration(milliseconds: 200),
    this.curve = Curves.easeOut,
    this.addShadow = false,
    this.shadowColor = Colors.black,
    this.borderRadius = 4,
  });

  @override
  State<HoverLift> createState() => _HoverLiftState();
}

class _HoverLiftState extends State<HoverLift> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    Widget content = widget.child;

    if (widget.addShadow) {
      content = TweenAnimationBuilder<double>(
        duration: widget.duration,
        curve: widget.curve,
        tween: Tween<double>(begin: 0, end: _isHovered ? 1 : 0),
        builder: (context, t, child) {
          return DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              boxShadow: [
                BoxShadow(
                  color: widget.shadowColor.withValues(alpha: 0.25 * t),
                  blurRadius: 16 * t,
                  offset: Offset(0, 8 * t),
                ),
              ],
            ),
            child: child,
          );
        },
        child: content,
      );
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: TweenAnimationBuilder<double>(
        duration: widget.duration,
        curve: widget.curve,
        tween: Tween<double>(begin: 0, end: _isHovered ? 1 : 0),
        builder: (context, t, child) {
          return Transform.translate(
            offset: Offset(0, -widget.liftPx * t),
            child: Transform.scale(
              scale: 1.0 + (widget.hoverScale - 1.0) * t,
              child: child,
            ),
          );
        },
        child: content,
      ),
    );
  }
}