import 'package:flutter/material.dart';

/// Wraps any card-like Container content so its shadow grows (and it lifts
/// slightly) on mouse hover — the "card elevation" hover pattern used
/// across feature/service/equipment/value/team cards site-wide.
///
/// Drop this INSIDE the card's outer Container, replacing the BoxDecoration
/// you'd normally put directly on that Container:
///
///   HoverCard(
///     borderRadius: r.cardRadius,
///     baseDecoration: BoxDecoration(
///       color: Colors.white,
///       borderRadius: BorderRadius.circular(r.cardRadius),
///       border: Border.all(color: const Color(0xFFe0e0e0)),
///       boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
///     ),
///     padding: EdgeInsets.all(r.cardPadding),
///     width: r.featureCardWidth,
///     child: Column(...),
///   )
///
/// This keeps each call site's existing color/border/radius/padding/width
/// exactly as-is, just swaps the static decoration for one that animates.
class HoverCard extends StatefulWidget {
  final Widget child;

  /// The card's resting-state decoration (color, border, radius, base shadow).
  /// HoverCard reads [BoxDecoration.borderRadius]/[color]/[border] from this
  /// and only animates the shadow + lift on top of it.
  final BoxDecoration baseDecoration;

  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;

  /// How far (in logical pixels) the card rises on hover.
  final double liftPx;

  /// Shadow strength on hover — higher blur/alpha = more pronounced "popping
  /// off the page" effect.
  final double hoverBlur;
  final double hoverAlpha;
  final double hoverShadowOffsetY;

  final Duration duration;
  final Curve curve;

  const HoverCard({
    super.key,
    required this.child,
    required this.baseDecoration,
    this.padding,
    this.width,
    this.height,
    this.liftPx = 6,
    this.hoverBlur = 24,
    this.hoverAlpha = 0.14,
    this.hoverShadowOffsetY = 14,
    this.duration = const Duration(milliseconds: 220),
    this.curve = Curves.easeOut,
  });

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final baseShadows = widget.baseDecoration.boxShadow ?? const <BoxShadow>[];

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: TweenAnimationBuilder<double>(
        duration: widget.duration,
        curve: widget.curve,
        tween: Tween<double>(begin: 0, end: _isHovered ? 1 : 0),
        builder: (context, t, child) {
          final hoverShadow = BoxShadow(
            color: Colors.black.withValues(alpha: widget.hoverAlpha * t),
            blurRadius: widget.hoverBlur * t,
            offset: Offset(0, widget.hoverShadowOffsetY * t),
          );

          return Transform.translate(
            offset: Offset(0, -widget.liftPx * t),
            child: Container(
              width: widget.width,
              height: widget.height,
              padding: widget.padding,
              decoration: widget.baseDecoration.copyWith(
                boxShadow: [...baseShadows, hoverShadow],
              ),
              child: child,
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}