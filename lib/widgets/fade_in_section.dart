import 'package:flutter/material.dart';
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
class AnimatedCounter extends StatefulWidget {
  final String end; // e.g. "24hr", "2", "1,000+"
  final TextStyle style;

  const AnimatedCounter({super.key, required this.end, required this.style});

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final match = RegExp(r'^(\d[\d,.]*)(.*)$').firstMatch(widget.end);
    if (match == null) return Text(widget.end, style: widget.style);

    final numStr = match.group(1)!.replaceAll(',', '');
    final suffix = match.group(2) ?? '';
    final num = double.tryParse(numStr) ?? 0;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final value = (num * _controller.value).round();
        final display = value >= 1000
            ? '${(value / 1000).toStringAsFixed(value % 1000 == 0 ? 0 : 1)}k'
            : value.toString();
        return Text('$display$suffix', style: widget.style);
      },
    );
  }
}