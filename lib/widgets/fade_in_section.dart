import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:mv/main.dart'; // for PageTransitionNotifier

/// Wraps any widget so it fades + slides up after the page transition completes.
/// Stagger multiple sections by passing increasing [delay] values.
///
/// Usage:
///   FadeInSection(child: _buildHero())
///   FadeInSection(delay: Duration(milliseconds: 100), child: _buildNext())
class FadeInSection extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const FadeInSection({
    super.key,
    required this.child,
    this.delay = Duration.zero,
  });

  @override
  State<FadeInSection> createState() => _FadeInSectionState();
}

class _FadeInSectionState extends State<FadeInSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  // Whether we have already subscribed to the notifier this mount cycle
  ValueNotifier<bool>? _notifier;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Re-subscribe whenever the inherited notifier instance changes
    // (e.g. after a page swap gives us a fresh notifier).
    final newNotifier = context
        .dependOnInheritedWidgetOfExactType<PageTransitionNotifier>()
        ?.notifier;

    if (newNotifier == _notifier) return; // same notifier, nothing to do

    // Unsubscribe from old notifier
    _notifier?.removeListener(_onReadyChanged);
    _notifier = newNotifier;
    _notifier?.addListener(_onReadyChanged);

    // Immediately evaluate current state
    _onReadyChanged();
  }

  void _onReadyChanged() {
    final ready = _notifier?.value ?? true;
    if (ready) {
      // Page fade-in just finished — reset and play our animation after delay.
      // Capture the notifier reference so the delayed callback can verify that
      // a new transition hasn't started by the time it fires, preventing a
      // stale forward() from causing a visible content pop mid-transition.
      _controller.reset();
      final notifierAtSchedule = _notifier;
      Future.delayed(widget.delay, () {
        if (!mounted) return;
        if (notifierAtSchedule?.value != true) return;
        _controller.forward();
      });
    } else {
      // New transition starting — snap back to hidden so we're ready.
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _notifier?.removeListener(_onReadyChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}


/// Animates a number counting up from 0 to [end].
/// Use inside the stats section.
///
/// By default, the count-up replays every time the widget scrolls into
/// view (including scrolling back up past it) — same behavior as
/// ScrollReveal's replayOnScroll. Pass [replayOnScroll]: false to only
/// ever count up once, the first time it becomes visible.
///
/// Set [useKShorthand] to true (the default) to render values >= 1000 as
/// "1k"-style shorthand (e.g. "1,000+" → counts to "1k+"). Pass false to
/// keep the full comma-formatted number (e.g. "1,000+" → "1,000+").
class AnimatedCounter extends StatefulWidget {
  final String end; // e.g. "24hr", "2", "1,000+"
  final TextStyle style;
  final double visibilityThreshold;
  final bool replayOnScroll;
  final bool useKShorthand;

  const AnimatedCounter({
    super.key,
    required this.end,
    required this.style,
    this.visibilityThreshold = 0.3,
    this.replayOnScroll = true,
    this.useKShorthand = true,
  });

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _controller;
  late final Key _visibilityKey;

  bool _hasAnimated = false;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _visibilityKey = UniqueKey();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    // VisibilityDetector doesn't recheck on window/browser resize on its
    // own — only on scroll or its own periodic timer — so without this a
    // counter that lands in/out of view purely from a resize can get stuck
    // until the next scroll. Force an immediate recheck after each resize.
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeMetrics() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_disposed) return;
      // notifyNow() is global — it synchronously fires onVisibilityChanged
      // for every VisibilityDetector currently registered in the app, not
      // just this one. If a route change disposes other counters in the
      // same frame, their own _onVisibilityChanged still guards itself
      // with _disposed below.
      VisibilityDetectorController.instance.notifyNow();
    });
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    // notifyNow() can invoke this after the widget is already disposed
    // (see didChangeMetrics above) — bail out before touching _controller.
    if (_disposed) return;

    final isVisible = info.visibleFraction >= widget.visibilityThreshold;

    if (isVisible) {
      if (_hasAnimated) return; // already counted up / counting — leave it
      _hasAnimated = true;
      _controller.forward(from: 0);
    } else {
      if (!widget.replayOnScroll) return; // one-shot mode never resets
      if (!_hasAnimated) return; // never started, nothing to reset
      _hasAnimated = false;
      _controller.value = 0; // snap back to 0, ready to recount next time
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
    // Regex: optional non-digit prefix (e.g. "±"), then the number, then suffix.
    // Example: "±0.0005\"" → prefix="±", numStr="0.0005", suffix="\""
    final match = RegExp(r'^([^\d]*)(\d[\d,.]*)(.*)$').firstMatch(widget.end);
    if (match == null) return Text(widget.end, style: widget.style);

    final prefix = match.group(1) ?? '';
    final numStr = match.group(2)!.replaceAll(',', '');
    final suffix = match.group(3) ?? '';
    final num = double.tryParse(numStr) ?? 0;

    // Preserve the source's decimal places so "0.0005" counts through
    // 0.0000 → 0.0001 → … → 0.0005 instead of snapping to 0.
    final decimalPlaces = numStr.contains('.')
        ? numStr.split('.').last.length
        : 0;

    return VisibilityDetector(
      key: _visibilityKey,
      onVisibilityChanged: _onVisibilityChanged,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final value = num * _controller.value;
          final display = !widget.useKShorthand
            ? (decimalPlaces > 0 ? value.toStringAsFixed(decimalPlaces) : value.round().toString())
            : value >= 1000000
                ? '${(value / 1000000).toStringAsFixed(value % 1000000 == 0 ? 0 : 1)}M'
                : value >= 1000
                    ? '${(value / 1000).toStringAsFixed(value % 1000 == 0 ? 0 : 1)}k'
                    : value.round().toString();

          // For integers >= 1000 with useKShorthand=false, add commas so
          // "1,000+" displays as "1,000+" rather than "1000+".
          final formatted = (!widget.useKShorthand &&
              decimalPlaces == 0 &&
              display.length > 3 &&
              int.tryParse(display) != null)
              ? _addCommas(display)
              : display;

          return Text('$prefix$formatted$suffix', style: widget.style);
        },
      ),
    );
  }

  static String _addCommas(String digits) {
    final chars = digits.runes.toList();
    final buf = StringBuffer();
    for (var i = 0; i < chars.length; i++) {
      if (i > 0 && (chars.length - i) % 3 == 0) buf.write(',');
      buf.write(String.fromCharCode(chars[i]));
    }
    return buf.toString();
  }
}