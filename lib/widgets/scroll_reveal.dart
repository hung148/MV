import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// Direction the widget slides in from when revealed.
enum RevealDirection { up, left, right }

/// Wraps any widget so it fades + slides in when it scrolls into view.
///
/// Usage:
///   ScrollReveal(child: _buildCard())
///   ScrollReveal(direction: RevealDirection.left, child: _buildCard())
///   ScrollReveal(direction: RevealDirection.right, delay: Duration(milliseconds: 100), child: _buildCard())
///
/// For cards in a Wrap, pass [index] to auto-stagger and auto-alternate
/// left/right directions:
///   ScrollReveal.card(index: i, child: _buildCard())
class ScrollReveal extends StatefulWidget {
  final Widget child;
  final RevealDirection direction;
  final Duration delay;
  final Duration duration;

  /// Fraction of the widget that must be visible before animating (0.0–1.0).
  final double visibilityThreshold;

  const ScrollReveal({
    super.key,
    required this.child,
    this.direction = RevealDirection.up,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 550),
    this.visibilityThreshold = 0.15,
  });

  /// Convenience constructor for cards in a Wrap.
  /// Automatically alternates left/right and staggers delay by index.
  factory ScrollReveal.card({
    Key? key,
    required int index,
    required Widget child,
    Duration baseDuration = const Duration(milliseconds: 550),
  }) {
    return ScrollReveal(
      key: key,
      direction: index.isEven ? RevealDirection.left : RevealDirection.right,
      delay: Duration(milliseconds: 80 * index),
      duration: baseDuration,
      child: child,
    );
  }

  @override
  State<ScrollReveal> createState() => _ScrollRevealState();
}

class _ScrollRevealState extends State<ScrollReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  bool _hasAnimated = false;

  // Unique key per instance for VisibilityDetector
  late final Key _visibilityKey;

  @override
  void initState() {
    super.initState();
    _visibilityKey = UniqueKey();

    _controller = AnimationController(vsync: this, duration: widget.duration);

    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    final begin = _offsetFor(widget.direction);
    _slide = Tween<Offset>(begin: begin, end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  static Offset _offsetFor(RevealDirection dir) {
    switch (dir) {
      case RevealDirection.up:
        return const Offset(0, 0.08);
      case RevealDirection.left:
        return const Offset(-0.12, 0);
      case RevealDirection.right:
        return const Offset(0.12, 0);
    }
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    if (_hasAnimated) return;
    if (info.visibleFraction >= widget.visibilityThreshold) {
      _hasAnimated = true;
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: _visibilityKey,
      onVisibilityChanged: _onVisibilityChanged,
      child: FadeTransition(
        opacity: _opacity,
        child: SlideTransition(
          position: _slide,
          child: widget.child,
        ),
      ),
    );
  }
}