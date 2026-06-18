import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// Direction the widget slides in from when revealed.
///
/// - [leftToRight]: slides in from the left. Use for items arranged in a
///   horizontal row (cards in a Wrap/Row) — pair with [ScrollReveal.row]
///   so a row cascades left-to-right as it comes into view.
/// - [vertical]: slides in from above or below depending on the actual
///   scroll direction at the moment it comes into view — scrolling down
///   reveals it sliding up into place; scrolling up reveals it sliding
///   down into place. Use for stacked/column content and text blocks via
///   [ScrollReveal.column] or the default [ScrollReveal] constructor.
enum RevealDirection { leftToRight, vertical }

/// Wraps any widget so it fades + slides in when it scrolls into view.
///
/// Three ways to use it:
///   ScrollReveal(child: _buildText())                         // text / single block, vertical, scroll-direction-aware
///   ScrollReveal.row(index: i, child: _buildCard())            // cards side-by-side: cascades left -> right
///   ScrollReveal.column(index: i, child: _buildItem())         // items stacked vertically: scroll-direction-aware, staggered top -> bottom
class ScrollReveal extends StatefulWidget {
  final Widget child;
  final RevealDirection direction;
  final Duration delay;
  final Duration duration;

  /// Fraction of the widget that must be visible before animating (0.0–1.0).
  final double visibilityThreshold;

  /// If true (default), the reveal resets and replays every time the widget
  /// scrolls back into view — including when scrolling back UP past it.
  /// If false, it only ever plays once.
  final bool replayOnScroll;

  const ScrollReveal({
    super.key,
    required this.child,
    this.direction = RevealDirection.vertical,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 150),
    this.visibilityThreshold = 0.15,
    this.replayOnScroll = true,
  });

  /// For cards/items placed side-by-side in a row (Wrap or Row).
  /// Always slides left -> right, staggered by [index] so the row cascades
  /// in one consistent visual sweep instead of each card racing independently.
  factory ScrollReveal.row({
    Key? key,
    required int index,
    required Widget child,
    Duration baseDuration = const Duration(milliseconds: 350),
    Duration staggerStep = const Duration(milliseconds: 60),
    bool replayOnScroll = true,
  }) {
    return ScrollReveal(
      key: key,
      direction: RevealDirection.leftToRight,
      delay: staggerStep * index,
      duration: baseDuration,
      replayOnScroll: replayOnScroll,
      child: child,
    );
  }

  /// For items stacked vertically (a Column of rows/blocks).
  /// Slides up when scrolling down, slides down when scrolling back up,
  /// staggered top -> bottom by [index].
  factory ScrollReveal.column({
    Key? key,
    required int index,
    required Widget child,
    Duration baseDuration = const Duration(milliseconds: 350),
    Duration staggerStep = const Duration(milliseconds: 60),
    bool replayOnScroll = true,
  }) {
    return ScrollReveal(
      key: key,
      direction: RevealDirection.vertical,
      delay: staggerStep * index,
      duration: baseDuration,
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

  // Bumped every time the widget enters/leaves view, so a stale delayed
  // callback from a previous visibility event can detect it's no longer
  // current and bail out instead of firing forward() after the widget has
  // since left view again.
  int _visibilityGeneration = 0;

  // Unique key per instance for VisibilityDetector
  late final Key _visibilityKey;

  // How long the reverse-out animation takes when the widget scrolls out
  // of view. Short and fixed so it stays quick regardless of how the
  // entrance duration is configured for this instance.
  static const Duration _hideDuration = Duration(milliseconds: 180);

  @override
  void initState() {
    super.initState();
    _visibilityKey = UniqueKey();

    _controller = AnimationController(vsync: this, duration: widget.duration);
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    // VisibilityDetector only rechecks on its own periodic timer or after
    // scroll events — a browser/window resize doesn't trigger either, so a
    // card that lands in (or out of) view purely because of a resize can
    // stay stuck until the next scroll. Observing metrics changes lets us
    // force an immediate recheck via VisibilityDetectorController.notifyNow().
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeMetrics() {
    // Defer to after the resize-triggered relayout has actually happened —
    // didChangeMetrics can fire before the new size is reflected in the
    // render tree on web.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_disposed) return;
      // notifyNow() is global — it synchronously fires onVisibilityChanged
      // for every VisibilityDetector currently registered in the app, not
      // just this one. If a route change or rebuild disposes some of those
      // widgets in the same frame, notifyNow() can still try to invoke
      // their callbacks. Each widget's own _onVisibilityChanged guards
      // against that with its own _disposed check (see below); this check
      // here only protects against the case where this widget itself was
      // disposed before the deferred frame ran.
      VisibilityDetectorController.instance.notifyNow();
    });
  }

  /// Determines the slide start offset for this reveal.
  /// - leftToRight: always slides in from the left.
  /// - vertical: slides from below if the user is scrolling down, from
  ///   above if scrolling up (so the motion always matches travel direction).
  Offset _beginOffsetFor(BuildContext context) {
    switch (widget.direction) {
      case RevealDirection.leftToRight:
        return const Offset(-0.10, 0);
      case RevealDirection.vertical:
        final scrollingDown = _isScrollingDown(context);
        // Scrolling down -> content should rise UP into place, so it starts
        // below its final position (positive Y).
        // Scrolling up -> content should drop DOWN into place, so it starts
        // above its final position (negative Y).
        return scrollingDown ? const Offset(0, 0.06) : const Offset(0, -0.06);
    }
  }

  bool _isScrollingDown(BuildContext context) {
    final position = Scrollable.maybeOf(context)?.position;
    final direction = position?.userScrollDirection;
    // ScrollDirection.reverse means content moves up on screen, i.e. the
    // user is scrolling DOWN the page. ScrollDirection.forward is scrolling
    // UP the page. If idle (e.g. programmatic jump) default to "down".
    if (direction == ScrollDirection.forward) return false;
    return true;
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    // VisibilityDetector can still invoke this after the widget has been
    // disposed — notifyNow() fires synchronously for every registered
    // detector, and a route change or rebuild can dispose this widget in
    // the same frame that triggered the notify. Bail out immediately so we
    // never touch _controller once it's gone.
    if (_disposed) return;

    final isVisible = info.visibleFraction >= widget.visibilityThreshold;

    if (isVisible) {
      if (_hasAnimated) return; // already played/playing — nothing to do until it leaves view

      _hasAnimated = true;
      _visibilityGeneration++;
      final generationAtSchedule = _visibilityGeneration;
      // Capture direction now (at the moment it became visible), not later
      // when the delay elapses, so fast scroll-then-stop doesn't flip it.
      final begin = _beginOffsetFor(context);
      Future.delayed(widget.delay, () {
        if (_disposed || !mounted) return;
        if (generationAtSchedule != _visibilityGeneration) return; // left view before delay elapsed
        _slide = Tween<Offset>(begin: begin, end: Offset.zero).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOut),
        );
        _controller.duration = widget.duration;
        _controller.forward(from: 0);
      });
    } else {
      if (!widget.replayOnScroll) return; // one-shot mode never resets
      if (!_hasAnimated) return; // wasn't shown yet, nothing to reset

      _hasAnimated = false;
      _visibilityGeneration++; // invalidate any pending delayed forward()
      // Ease back out instead of snapping instantly to 0. A hard snap means
      // scrolling slightly past the widget and immediately back makes it
      // pop out, then forces the full entrance delay+duration to play again
      // from scratch — which reads as a stall. Reversing gently lets a quick
      // overshoot-and-correct settle smoothly, while still being quick
      // enough not to linger when you're scrolling away for good.
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