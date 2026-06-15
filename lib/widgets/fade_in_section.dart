import 'package:flutter/material.dart';

/// Wraps any widget so it fades + slides up when it first becomes visible.
/// Usage:
///   FadeInSection(child: _buildMySection())
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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Start after optional delay
    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
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
  final String end;   // e.g. "24hr", "2", "1,000+"
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
    // Extract leading number if present, keep suffix
    final match = RegExp(r'^(\d[\d,.]*)(.*)$').firstMatch(widget.end);
    if (match == null) {
      // No number to animate (e.g. "Prototype")
      return Text(widget.end, style: widget.style);
    }
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