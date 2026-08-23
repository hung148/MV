import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

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

  /// Waits this long after becoming visible before starting to count.
  ///
  /// Needed where the counter sits inside something with its own entrance
  /// animation — the hero's trust strip, for instance. Visibility is measured
  /// from layout geometry, so a counter that's still at opacity 0 partway
  /// through a fade-in already counts as visible, and without a delay it
  /// would run most of its count before anyone could see it.
  final Duration startDelay;

  /// How long the whole count takes.
  ///
  /// Paired with the ease-out curve below, so a longer duration doesn't just
  /// slow everything evenly — it stretches the settling tail, where the
  /// deceleration actually reads.
  final Duration duration;

  const AnimatedCounter({
    super.key,
    required this.end,
    required this.style,
    this.visibilityThreshold = 0.3,
    this.replayOnScroll = true,
    this.useKShorthand = true,
    this.startDelay = Duration.zero,
    this.duration = const Duration(milliseconds: 2600),
  });

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _controller;

  /// The count-up is deliberately not linear: it sprints through most of the
  /// range and then eases into the final digits, which is what makes a
  /// counter feel like it's *settling* on a number rather than sliding to
  /// one. A cubic ease-out is ~half way there in the first fifth of the run
  /// and spends the rest landing.
  ///
  /// Cubic rather than something sharper (quart, expo): the stats on this
  /// site include small values like "2" and "24hr", and a steeper curve hits
  /// their final digit so early that the counter looks frozen for most of its
  /// duration. The way to make the slowdown more pronounced is a longer
  /// [AnimatedCounter.duration], not a steeper curve — that stretches the
  /// tail, where the deceleration reads, instead of flattening it into a
  /// dead zone.
  late final CurvedAnimation _progress;

  late final Key _visibilityKey;

  bool _hasAnimated = false;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _visibilityKey = UniqueKey();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _progress = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    // VisibilityDetector doesn't recheck on window/browser resize on its
    // own — only on scroll or its own periodic timer — so without this a
    // counter that lands in/out of view purely from a resize can get stuck
    // until the next scroll. Force an immediate recheck after each resize.
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didUpdateWidget(covariant AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration != oldWidget.duration) {
      _controller.duration = widget.duration;
    }
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
      if (widget.startDelay == Duration.zero) {
        _controller.forward(from: 0);
      } else {
        Future.delayed(widget.startDelay, () {
          if (_disposed || !mounted) return;
          // Scrolled back out during the delay — _hasAnimated was reset, so
          // don't start a count nobody asked for; the next scroll-in will.
          if (!_hasAnimated) return;
          _controller.forward(from: 0);
        });
      }
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
    // The CurvedAnimation holds a listener on the controller; drop it before
    // the controller goes.
    _progress.dispose();
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
        animation: _progress,
        builder: (context, _) {
          final value = num * _progress.value;
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
