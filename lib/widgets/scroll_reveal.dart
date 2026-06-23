import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// Fades + slides a widget in the moment it enters the viewport.
/// Animates once — stays visible after that, never hides again.
///
/// Call VisibilityDetectorController.instance.updateInterval = Duration.zero
/// once at app startup (in main()) for instant response.
class ScrollReveal extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double visibilityThreshold;

  const ScrollReveal({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.visibilityThreshold = 0.1,
  });

  // Factories keep identical signatures so all call sites compile unchanged.
  factory ScrollReveal.row({
    Key? key,
    required int index,
    required Widget child,
    Duration? duration,
    Duration baseDuration = const Duration(milliseconds: 500),
    Duration staggerStep = Duration.zero,
    bool replayOnScroll = false,
    String? staggerGroup,
  }) =>
      ScrollReveal(key: key, duration: duration ?? baseDuration, child: child,);

  factory ScrollReveal.column({
    Key? key,
    required int index,
    required Widget child,
    Duration? duration,
    Duration baseDuration = const Duration(milliseconds: 500),
    Duration staggerStep = Duration.zero,
    bool replayOnScroll = false,
    String? staggerGroup,
  }) =>
      ScrollReveal(key: key, duration: duration ?? baseDuration, child: child,);

  @override
  State<ScrollReveal> createState() => _ScrollRevealState();
}

class _ScrollRevealState extends State<ScrollReveal>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;
  late final Key _visKey;

  bool _revealed = false;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _visKey = UniqueKey();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeMetrics() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_disposed) return;
      VisibilityDetectorController.instance.notifyNow();
    });
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    if (_disposed || _revealed) return;
    if (info.visibleFraction >= widget.visibilityThreshold) {
      _revealed = true;
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: _visKey,
      onVisibilityChanged: _onVisibilityChanged,
      child: FadeTransition(
        opacity: _opacity,
        child: SlideTransition(position: _slide, child: widget.child),
      ),
    );
  }
}