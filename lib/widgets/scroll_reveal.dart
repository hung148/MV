import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:visibility_detector/visibility_detector.dart';

enum RevealDirection { leftToRight, vertical }

/// Wraps any widget so it fades + slides in when it scrolls into view.
///
/// Three ways to use it:
///   ScrollReveal(child: _buildText())
///   ScrollReveal.row(index: i, child: _buildCard())
///   ScrollReveal.column(index: i, child: _buildItem())
///
/// To stagger children inside a section with varying speeds, use
/// ScrollReveal.column on each child individually and pass a custom
/// [duration] to make lower items animate slower (or faster):
///
///   Column(children: [
///     ScrollReveal.column(index: 0, child: _title()),              // fast
///     ScrollReveal.column(index: 1, duration: 500ms, child: _body()),  // medium
///     ScrollReveal.column(index: 2, duration: 700ms, child: _cta()),   // slow
///   ])
class ScrollReveal extends StatefulWidget {
  final Widget child;
  final RevealDirection direction;
  final Duration delay;
  final Duration duration;
  final double visibilityThreshold;
  final bool replayOnScroll;

  const ScrollReveal({
    super.key,
    required this.child,
    this.direction = RevealDirection.vertical,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 350),
    this.visibilityThreshold = 0.15,
    this.replayOnScroll = true,
  });

  /// For cards/items placed side-by-side in a row (Wrap or Row).
  /// Slides left → right, staggered by [index].
  factory ScrollReveal.row({
    Key? key,
    required int index,
    required Widget child,
    Duration baseDuration = const Duration(milliseconds: 350),
    Duration? duration, // override per-item duration (defaults to baseDuration)
    Duration staggerStep = const Duration(milliseconds: 60),
    bool replayOnScroll = true,
  }) {
    return ScrollReveal(
      key: key,
      direction: RevealDirection.leftToRight,
      delay: staggerStep * index,
      duration: duration ?? baseDuration,
      replayOnScroll: replayOnScroll,
      child: child,
    );
  }

  /// For items stacked vertically (a Column of rows/blocks).
  /// Slides up when scrolling down, slides down when scrolling back up,
  /// staggered top → bottom by [index].
  ///
  /// Pass a custom [duration] to vary animation speed per item independently
  /// of the stagger delay — e.g. make lower items animate in more slowly:
  ///   ScrollReveal.column(index: 0, duration: Duration(milliseconds: 300), child: title)
  ///   ScrollReveal.column(index: 1, duration: Duration(milliseconds: 500), child: body)
  ///   ScrollReveal.column(index: 2, duration: Duration(milliseconds: 700), child: cta)
  factory ScrollReveal.column({
    Key? key,
    required int index,
    required Widget child,
    Duration baseDuration = const Duration(milliseconds: 350),
    Duration? duration, // override per-item duration (defaults to baseDuration)
    Duration staggerStep = const Duration(milliseconds: 60),
    bool replayOnScroll = true,
  }) {
    return ScrollReveal(
      key: key,
      direction: RevealDirection.vertical,
      delay: staggerStep * index,
      duration: duration ?? baseDuration,
      replayOnScroll: replayOnScroll,
      child: child,
    );
  }

  @override
  State<ScrollReveal> createState() => _ScrollRevealState();
}

class _ScrollRevealState extends State<ScrollReveal>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  Animation<Offset>? _slide;

  bool _hasAnimated = false;
  bool _disposed = false;
  int _visibilityGeneration = 0;
  late final Key _visibilityKey;

  static const Duration _hideDuration = Duration(milliseconds: 180);

  @override
  void initState() {
    super.initState();
    _visibilityKey = UniqueKey();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeMetrics() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_disposed) return;
      VisibilityDetectorController.instance.notifyNow();
    });
  }

  Offset _beginOffsetFor(BuildContext context) {
    switch (widget.direction) {
      case RevealDirection.leftToRight:
        return const Offset(-0.10, 0);
      case RevealDirection.vertical:
        final scrollingDown = _isScrollingDown(context);
        return scrollingDown ? const Offset(0, 0.06) : const Offset(0, -0.06);
    }
  }

  bool _isScrollingDown(BuildContext context) {
    final position = Scrollable.maybeOf(context)?.position;
    final direction = position?.userScrollDirection;
    if (direction == ScrollDirection.forward) return false;
    return true;
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    if (_disposed) return;

    final isVisible = info.visibleFraction >= widget.visibilityThreshold;

    if (isVisible) {
      if (_hasAnimated) return;

      _hasAnimated = true;
      _visibilityGeneration++;
      final generationAtSchedule = _visibilityGeneration;
      final begin = _beginOffsetFor(context);
      Future.delayed(widget.delay, () {
        if (_disposed || !mounted) return;
        if (generationAtSchedule != _visibilityGeneration) return;
        _slide = Tween<Offset>(begin: begin, end: Offset.zero).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOut),
        );
        _controller.duration = widget.duration;
        _controller.forward(from: 0);
      });
    } else {
      if (!widget.replayOnScroll) return;
      if (!_hasAnimated) return;

      _hasAnimated = false;
      _visibilityGeneration++;
      _controller.duration = _hideDuration;
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: _visibilityKey,
      onVisibilityChanged: _onVisibilityChanged,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final slide = _slide;
          return FadeTransition(
            opacity: _opacity,
            child: slide == null
                ? child
                : SlideTransition(position: slide, child: child),
          );
        },
        child: widget.child,
      ),
    );
  }
}