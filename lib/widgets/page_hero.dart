import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:mv/widgets/responsive.dart';
import 'package:mv/widgets/animated_counter.dart';
import 'package:mv/widgets/navigation_bar.dart' show kNavBarHeight;
import 'package:mv/main.dart' show PageTransitionNotifier, HeroProximityNotifier;

/// Shared hero banner used on every page — Services, Capabilities, About and
/// Gallery via the default constructor, Home via [PageHero.home].
///
/// Design system (identical across both variants, only the scale and the
/// extra home-only content differ):
///
///   • Full-bleed background — looping muted video, a static image, or the
///     brand gradient as a fallback. The nav bar floats transparently on top
///     of it, so the media runs to the very top of the window; content is
///     inset by [kNavBarHeight] to clear it.
///   • A navy multiply tint plus a *directional* scrim (dense on the left
///     where the type sits, opening up towards the right) instead of a flat
///     black overlay. The shop footage is bright — near-white on the
///     Capabilities blueprint clip — and a flat 30% black is nowhere near
///     enough to keep white text legible over it.
///   • A very faint blueprint grid, masked so it fades out to the right.
///   • Left-aligned editorial content: eyebrow kicker → headline → subtitle
///     → (home only) body, actions and a trust strip.
///   • A bottom vignette and a thin brand-blue rule so the hero sits down
///     into the section beneath it instead of hard-cutting to white.
///
/// Standard usage (inner pages):
///   PageHero(
///     eyebrow: 'Services',
///     title: 'Our Services',
///     subtitle: 'Comprehensive CNC machining solutions…',
///     backgroundVideo: 'assets/videos/services_hero_bg.mp4',
///   )
///
/// Home-page variant:
///   PageHero.home(
///     eyebrow: 'MV Manufacturing LLC',
///     title: 'Precision CNC Manufacturing',
///     subtitle: 'Your trusted partner …',
///     body: 'From prototype to production …',
///     actions: Wrap(children: […]),
///     stats: const [HeroStat(value: '±0.0005"', label: 'Tolerance'), …],
///     backgroundVideo: 'assets/videos/home_hero_bg.mp4',
///   )
///
/// If both [backgroundImage] and [backgroundVideo] are provided, the video
/// takes priority and the image is ignored. If neither is provided, the
/// brand gradient is used.
///
/// Do NOT wrap this in an outer fade-in wrapper — the hero runs its own
/// staggered entrance, timed off [PageTransitionNotifier], so an enclosing
/// fade would just hide the stagger behind it.
class PageHero extends StatelessWidget {
  // ─── Palette ─────────────────────────────────────────────────────────────
  /// Deep navy the footage is tinted and scrimmed with. Cooler and darker
  /// than the brand blue so white type has room to breathe on top of it.
  static const Color navy = Color(0xFF04101F);
  static const Color accent = Color(0xFF64B5F6);

  // ─── shared fields ───────────────────────────────────────────────────────
  final String title;
  final String subtitle;

  /// Short uppercase kicker rendered above [title], preceded by a small blue
  /// rule. Defaults to the company name when omitted.
  final String? eyebrow;

  // ─── home-variant fields ─────────────────────────────────────────────────
  /// When true, uses the taller home layout with body copy, actions, a trust
  /// strip and a trust row.
  final bool _isHome;

  /// Optional third line of body text rendered below [subtitle].
  final String? body;

  /// Optional widget row (buttons, chips, etc.) rendered below [body].
  final Widget? actions;

  /// Optional short list of credibility stats rendered under a hairline rule
  /// at the bottom of the home hero.
  final List<HeroStat> stats;

  /// Optional static background image asset path.
  final String? backgroundImage;

  /// Optional list of image assets to run as a slow Ken Burns slideshow —
  /// each one drifts and zooms while cross-fading into the next. Use for a
  /// page whose subject *is* the photos (the Gallery), where one frozen
  /// image would undersell the range of work.
  ///
  /// Takes priority over [backgroundImage]; ignored if [backgroundVideo] is
  /// set. A single-entry list is treated as a still image (no animation).
  final List<String> backgroundImages;

  /// Optional looping, muted background video asset path.
  /// Takes priority over both image options if set.
  final String? backgroundVideo;

  /// Minimum hero height. Defaults to the full window height, so every hero
  /// fills the viewport on load. Pass a fixed value to override, or null to
  /// let the hero shrink-wrap its content.
  ///
  /// This is a *minimum*, never a fixed size — on a short window (or a phone
  /// in landscape) the home hero's copy, buttons and trust strip can add up
  /// to more than one screen, and the hero grows rather than clipping them.
  final double? minHeight;

  // ─── Standard constructor ─────────────────────────────────────────────────
  const PageHero({
    super.key,
    required this.title,
    required this.subtitle,
    this.eyebrow,
    this.backgroundImage,
    this.backgroundImages = const [],
    this.backgroundVideo,
    this.minHeight = double.infinity, // sentinel meaning "fill the window"
  })  : _isHome = false,
        body = null,
        actions = null,
        stats = const [];

  // ─── Home constructor ─────────────────────────────────────────────────────
  const PageHero.home({
    super.key,
    required this.title,
    required this.subtitle,
    this.eyebrow,
    this.body,
    this.actions,
    this.stats = const [],
    this.backgroundImage,
    this.backgroundImages = const [],
    this.backgroundVideo,
    this.minHeight = double.infinity,
  }) : _isHome = true;

  bool get _hasMedia =>
      backgroundVideo != null ||
      backgroundImage != null ||
      backgroundImages.isNotEmpty;

  double _resolvedMinHeight(BuildContext context) {
    if (minHeight == null) return 0;
    if (minHeight!.isFinite) return minHeight!;

    // Full window height on every page. The nav bar floats *over* the hero
    // rather than above it, so the window height is the hero height — no
    // need to subtract kNavBarHeight here (the hero's own top padding
    // already insets the content to clear the bar).
    //
    // A floor keeps it sane if the window is very short — a 300px-tall
    // browser window shouldn't produce a 300px hero with clipped copy.
    return MediaQuery.sizeOf(context).height.clamp(520.0, double.infinity);
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final horizontal = r.isMobile
        ? 20.0
        : r.isTablet
            ? 32.0
            : 56.0;

    return _ReportHeight(
      announceMediaReady: backgroundVideo == null,
      child: Container(
        constraints: BoxConstraints(minHeight: _resolvedMinHeight(context)),
        // Gradient fallback when no media is supplied (About, Gallery).
        decoration: _hasMedia
            ? const BoxDecoration(color: navy)
            : const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF06254D), Color(0xFF0d47a1), Color(0xFF1976d2)],
                ),
              ),
        child: Stack(
          // The content layer is the one non-positioned child, so it decides
          // the hero's height when the copy is taller than the minimum. When
          // the minimum wins instead, this centres it in the leftover space
          // rather than pinning it to the top (the Stack's default).
          alignment: Alignment.center,
          children: [
            // ── Layer 1: background media — video > slideshow > still ──────
            if (backgroundVideo != null)
              Positioned.fill(child: _HeroBackgroundVideo(assetPath: backgroundVideo!))
            else if (backgroundImages.isNotEmpty)
              Positioned.fill(child: _HeroSlideshow(assetPaths: backgroundImages))
            else if (backgroundImage != null)
              Positioned.fill(child: Image.asset(backgroundImage!, fit: BoxFit.cover)),

            // ── Layer 2: uniform navy knock-down of the footage ─────────────
            // Only over real media; the gradient fallback is already dark.
            // Kept light on purpose — this layer dims the whole frame
            // including the open right-hand side, so it's the most expensive
            // one in terms of how much of the video you actually see. The
            // heavy lifting for legibility is Layer 3, which only darkens
            // where the type sits.
            if (_hasMedia)
              Positioned.fill(
                child: IgnorePointer(
                  child: ColoredBox(color: navy.withValues(alpha: 0.18)),
                ),
              ),

            // ── Layer 3: directional scrim (dense left → open right) ────────
            // The shape matters more than the amount: it stays dense across
            // the text column (out to stop 0.55, which is where the widest
            // subtitle line ends) and then falls off hard, so the right half
            // of the frame is left almost clear. That's what lets the video
            // read as bright while the type still measures ~7.5:1 against
            // white — checked against real frames of both hero clips.
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: const Alignment(-1.0, -0.35),
                      end: const Alignment(1.0, 0.35),
                      stops: const [0.0, 0.28, 0.55, 0.78, 1.0],
                      colors: [
                        navy.withValues(alpha: _hasMedia ? 0.86 : 0.45),
                        navy.withValues(alpha: _hasMedia ? 0.78 : 0.34),
                        navy.withValues(alpha: _hasMedia ? 0.52 : 0.18),
                        navy.withValues(alpha: _hasMedia ? 0.10 : 0.06),
                        navy.withValues(alpha: _hasMedia ? 0.00 : 0.00),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Layer 4: vertical vignette — a little at the top so the
            // transparent nav has something to sit on, more at the bottom so
            // the hero grounds into the next section.
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.34, 0.58, 1.0],
                      colors: [
                        navy.withValues(alpha: 0.24),
                        navy.withValues(alpha: 0.0),
                        navy.withValues(alpha: 0.0),
                        navy.withValues(alpha: 0.46),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Layer 5: blueprint grid, faded out to the right ─────────────
            // The fade is baked into the painter's own Paint shaders rather
            // than applied with a ShaderMask. A ShaderMask means a
            // `saveLayer` — a full-screen offscreen render pass — every time
            // this layer paints, which is a real cost on first load and a
            // visible hitch every time the hero is scrolled back into view
            // and its cached raster has to be rebuilt. Fading the strokes
            // themselves costs nothing extra: it is the same gradient, just
            // multiplied into the line colour instead of into a copy of the
            // whole screen.
            Positioned.fill(
              child: IgnorePointer(
                child: RepaintBoundary(
                  child: CustomPaint(painter: _BlueprintGridPainter()),
                ),
              ),
            ),

            // ── Layer 6: content ────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(
                horizontal,
                kNavBarHeight + (r.isMobile ? 36 : 48),
                horizontal,
                _isHome ? (r.isMobile ? 56 : 72) : (r.isMobile ? 36 : 52),
              ),
              // Centre the max-width column, then left-align the copy inside
              // it — so the headline starts on the same left edge as every
              // section below, instead of hugging the window on a wide screen.
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: r.maxContentWidth),
                  // The headline carries a 24px-blur Shadow at display size,
                  // which is expensive to rasterize. Once the entrance has
                  // played, the whole column is static — cache it rather than
                  // redrawing it for every scroll frame.
                  child: RepaintBoundary(
                    child: SizedBox(
                      width: double.infinity,
                      child: _HeroContent(
                        isHome: _isHome,
                        eyebrow: eyebrow ?? 'MV Manufacturing LLC',
                        title: title,
                        subtitle: subtitle,
                        body: body,
                        actions: actions,
                        stats: stats,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── One revealed piece ──────────────────────────────────────────────────────
/// One piece of the hero's entrance — a word, or a whole block like the
/// buttons — sliding up into place out of nothing.
///
/// **Why this is a widget and not a builder callback.** An earlier version
/// drew every word inside one `AnimatedBuilder` wrapped around the whole
/// `Wrap`, rebuilding each `Text` 60×/sec and re-rasterizing the headline's
/// 24px-blur shadow every frame, at display type size, over a playing video.
/// That is what made the entrance look like it was stuttering. Here the piece
/// is built **once** and only its opacity and offset change:
///
///   * [FadeTransition] drives the render object directly — it marks it for
///     repaint, it does not rebuild the subtree;
///   * the [AnimatedBuilder] is passed its `child`, so the same rule holds for
///     the transform: one `Transform` widget per frame, and nothing below it;
///   * `parent.drive(...)` composes interval and curve without a
///     [CurvedAnimation], so nothing needs disposing when the timings change;
///   * the [RepaintBoundary] lets the rasterized piece (shadow included) be
///     cached and merely re-composited as it moves.
///
/// The travel [dy] is in logical pixels rather than a fraction of the child's
/// height, because the same reveal is used for the headline and for things as
/// short as the eyebrow rule — a proportional throw would be a 40px sweep on
/// one and an invisible 8px twitch on the other.
class _SlideUp extends StatefulWidget {
  final Animation<double> parent;

  /// Where this piece's run starts and how long it lasts, as fractions of
  /// [parent]'s 0→1 range.
  final double begin;
  final double run;

  /// How far below its resting place the piece starts, in logical pixels.
  final double dy;

  /// Give this piece its own cached layer while it moves.
  ///
  /// Worth it only for something genuinely expensive to redraw — the headline,
  /// which is display-size type with a 24px-blur shadow. It is *not* worth it
  /// per word of body copy: a hero's worth of words would mean two dozen
  /// simultaneous layers for the compositor to juggle, which costs more than
  /// simply repainting a short unshadowed run of text.
  final bool cache;

  final Widget child;

  const _SlideUp({
    required this.parent,
    required this.begin,
    required this.run,
    required this.dy,
    required this.cache,
    required this.child,
  });

  @override
  State<_SlideUp> createState() => _SlideUpState();
}

class _SlideUpState extends State<_SlideUp> {
  late Animation<double> _fade;
  late Animation<double> _rise;
  late double _end;

  /// True once this piece's slot in the timeline has passed.
  ///
  /// The entrance plays for about three seconds and then never again, but the
  /// widgets driving it would otherwise stay in the tree for the life of the
  /// page — a fade layer, a transform and (where [cache] is set) a
  /// RepaintBoundary around every single word. Once settled the piece rebuilds
  /// as its bare child, so everything the user scrolls afterwards is a plain
  /// static subtree. It watches rather than latches because [parent] is reset
  /// to zero on route re-entry, and the entrance has to be able to play again.
  bool _settled = false;

  @override
  void initState() {
    super.initState();
    _wire();
    // Assigned directly, not through _onTick: setState during initState marks
    // an element dirty while it is still building. Matters because the hero
    // can be rebuilt after its entrance has already finished, in which case
    // this piece must mount straight into its settled form.
    _settled = widget.parent.value >= _end;
    widget.parent.addListener(_onTick);
  }

  @override
  void didUpdateWidget(_SlideUp old) {
    super.didUpdateWidget(old);
    if (old.parent != widget.parent) {
      old.parent.removeListener(_onTick);
      widget.parent.addListener(_onTick);
    }
    if (old.parent != widget.parent ||
        old.begin != widget.begin ||
        old.run != widget.run ||
        old.dy != widget.dy) {
      _wire();
      // Direct assignment again — a rebuild is already under way here, so
      // setState would be marking a dirty element mid-build.
      _settled = widget.parent.value >= _end;
    }
  }

  @override
  void dispose() {
    widget.parent.removeListener(_onTick);
    super.dispose();
  }

  void _onTick() {
    final settled = widget.parent.value >= _end;
    if (settled != _settled && mounted) {
      setState(() => _settled = settled);
    }
  }

  void _wire() {
    // Clamped so the interval can never collapse to zero width — Interval
    // divides by (end - begin).
    final b = widget.begin.clamp(0.0, 1.0 - widget.run);
    _end = (b + widget.run).clamp(0.0, 1.0);

    _fade = widget.parent.drive(
      CurveTween(curve: Interval(b, _end, curve: Curves.easeOutCubic)),
    );

    // Opacity leads the movement: easeOutQuart leaves the piece drifting the
    // last few pixels for most of its run, so it is fully legible while it
    // settles instead of arriving and then fading in.
    _rise = widget.parent.drive(
      Tween<double>(begin: widget.dy, end: 0)
          .chain(CurveTween(curve: Interval(b, _end, curve: Curves.easeOutQuart))),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_settled) return widget.child;

    final moving = AnimatedBuilder(
      animation: _rise,
      child: widget.cache ? RepaintBoundary(child: widget.child) : widget.child,
      builder: (context, built) => Transform.translate(
        offset: Offset(0, _rise.value),
        child: built,
      ),
    );

    return FadeTransition(opacity: _fade, child: moving);
  }
}

/// Dispatched once per hero when its background media is on screen — the
/// video has initialised, or (for a hero with no video) the first frame has
/// been laid out.
///
/// `_FadeRouteContent` in main.dart holds the entrance animation until this
/// arrives, so the reveal is not competing with a video decoder spinning up.
/// It is capped there, so a hero that never sends one costs a fixed wait, not
/// a stuck animation.
class HeroMediaReadyNotification extends Notification {
  const HeroMediaReadyNotification();
}

/// Dispatched by [PageHero] whenever its laid-out height changes.
///
/// AppShell listens for this so it can fade the nav bar from transparent to
/// solid exactly as the hero's bottom edge slides up under the bar. Measuring
/// beats guessing from the viewport size: the hero height is a *minimum*, so
/// on a short window (or a phone in landscape) the real hero can be taller
/// than one screen — and a guessed threshold would darken the bar while it
/// was still sitting over the hero.
class HeroHeightNotification extends Notification {
  final double height;
  const HeroHeightNotification(this.height);
}

/// Measures its child after layout and dispatches [HeroHeightNotification]
/// when the height changes. Cheap: the post-frame callback is only scheduled
/// on rebuild, and the hero rebuilds only when its dependencies change.
class _ReportHeight extends StatefulWidget {
  final Widget child;

  /// Send [HeroMediaReadyNotification] after the first layout.
  ///
  /// Set for heroes with no video — a still, a slideshow, or the plain
  /// gradient — where being laid out *is* being ready. A video hero passes
  /// false and lets [_HeroBackgroundVideo] announce itself once its decoder
  /// is up, which is the whole point of the signal.
  final bool announceMediaReady;

  const _ReportHeight({
    required this.child,
    required this.announceMediaReady,
  });

  @override
  State<_ReportHeight> createState() => _ReportHeightState();
}

class _ReportHeightState extends State<_ReportHeight> {
  double? _reported;
  bool _announced = false;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (widget.announceMediaReady && !_announced) {
        _announced = true;
        const HeroMediaReadyNotification().dispatch(context);
      }

      final h = context.size?.height;
      if (h == null || h == _reported) return;
      _reported = h;
      HeroHeightNotification(h).dispatch(context);
    });
    return widget.child;
  }
}

/// One credibility stat in the home hero's trust strip.
class HeroStat {
  final String value;
  final String label;
  const HeroStat({required this.value, required this.label});
}

// ─── Content column, with a short staggered entrance ─────────────────────────
class _HeroContent extends StatefulWidget {
  final bool isHome;
  final String eyebrow;
  final String title;
  final String subtitle;
  final String? body;
  final Widget? actions;
  final List<HeroStat> stats;

  const _HeroContent({
    required this.isHome,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.body,
    required this.actions,
    required this.stats,
  });

  @override
  State<_HeroContent> createState() => _HeroContentState();
}

class _HeroContentState extends State<_HeroContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  // ── Entrance timeline ──────────────────────────────────────────────────
  // The whole hero enters as ONE strict top-to-bottom sequence: eyebrow →
  // headline (word by word) → subtitle (word by word) → body (word by word)
  // → buttons → trust strip. Nothing below starts before the thing above it
  // has begun its last piece, so the eye is always led downwards.
  //
  // Everything here is wall-clock milliseconds, converted to fractions of
  // [_c] at the point of use. Raw fractions were unreadable once the chain
  // got this long, and the controller's own duration is then just a ruler.

  /// [_c]'s full length. Long enough to hold the sequence below with slack;
  /// a wordier page is squeezed to fit rather than clipped (see `build`).
  static const int _kTimelineMs = 4200;

  /// Pause between one element's last piece and the next element's first.
  static const _kElementGapMs = 150.0;

  /// Headline: a deliberate word-by-word reveal, the slowest thing here.
  static const _kTitleStepMs = 190.0;
  static const _kTitleRunMs = 1100.0;
  static const _kTitleRiseDy = 44.0;

  /// Subtitle and body: the same treatment, quicker — these are long lines,
  /// and the headline's gap across ten words would outlast anyone's patience.
  static const _kProseStepMs = 62.0;
  static const _kProseRunMs = 750.0;
  static const _kProseRiseDy = 22.0;

  /// Whole-block items (the eyebrow rule, the buttons) and the trust strip's
  /// rule + one step per stat.
  static const _kBlockRunMs = 750.0;
  static const _kStatStepMs = 100.0;
  static const _kBlockRiseDy = 24.0;

  /// The page-transition notifier we're currently subscribed to. The hero
  /// holds its entrance until the route's cross-fade has finished — otherwise
  /// the stagger would play out behind a page that's still fading in and the
  /// reveal would be invisible.
  ValueNotifier<bool>? _notifier;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _kTimelineMs),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final next = context
        .dependOnInheritedWidgetOfExactType<PageTransitionNotifier>()
        ?.notifier;
    if (next == _notifier) return;
    _notifier?.removeListener(_onReadyChanged);
    _notifier = next;
    _notifier?.addListener(_onReadyChanged);
    _onReadyChanged();
  }

  void _onReadyChanged() {
    if (!mounted) return;
    if (_notifier?.value ?? true) {
      _c.forward(from: 0);
    } else {
      _c.reset();
    }
  }

  @override
  void dispose() {
    _notifier?.removeListener(_onReadyChanged);
    _c.dispose();
    super.dispose();
  }

  /// Width of one space in [style], measured rather than guessed.
  ///
  /// Splitting the headline into one [Text] per word throws the spaces away,
  /// so the [Wrap] has to put them back at exactly the width the font would
  /// have used. Painting a lone ' ' is no help — layout trims trailing
  /// whitespace — so take the difference between 'a a' and 'aa'.
  double _spaceWidth(TextStyle style) {
    final scaler = MediaQuery.textScalerOf(context);
    double widthOf(String s) {
      final tp = TextPainter(
        text: TextSpan(text: s, style: style),
        textDirection: TextDirection.ltr,
        textScaler: scaler,
      )..layout();
      return tp.width;
    }

    final w = widthOf('a a') - widthOf('aa');
    return w > 0 ? w : (style.fontSize ?? 16) * 0.26;
  }

  /// Splits a line into the words the reveal animates, one at a time.
  static List<String> _splitWords(String text) =>
      text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();

  /// A line of text revealed word by word.
  ///
  /// A [Wrap] of per-word [Text]s rather than one [Text]: each word needs its
  /// own opacity and transform, and Wrap still breaks the line where the width
  /// runs out. A word too long for its line is handed the full width and wraps
  /// inside its own Text, so nothing overflows.
  ///
  /// [beginMs], [stepMs] and [runMs] are positions on the shared timeline;
  /// [toFraction] converts them to [_c]'s 0→1 range (it also carries the
  /// squeeze factor `build` applies to wordy pages).
  Widget _words(
    List<String> words,
    TextStyle style, {
    required double beginMs,
    required double stepMs,
    required double runMs,
    required double dy,
    required bool cache,
    required double Function(double ms) toFraction,
  }) {
    final run = toFraction(runMs);
    return Wrap(
      spacing: _spaceWidth(style),
      children: [
        for (var i = 0; i < words.length; i++)
          _SlideUp(
            parent: _c,
            begin: toFraction(beginMs + i * stepMs),
            run: run,
            dy: dy,
            cache: cache,
            child: Text(words[i], style: style),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final home = widget.isHome;

    // Measured line length: capping the subtitle keeps it from running the
    // full width of a wide desktop window.
    final proseWidth = r.isDesktop ? 580.0 : double.infinity;

    final titleWords = _splitWords(widget.title);
    final subtitleWords = _splitWords(widget.subtitle);
    final bodyWords = widget.body == null
        ? const <String>[]
        : _splitWords(widget.body!);

    // ── Book the sequence ────────────────────────────────────────────────
    // `book` places an element's first piece at the cursor and leaves the
    // cursor one gap past its *last* piece — so the next element starts as
    // this one is still settling, but never before it has begun. That is what
    // keeps the reveal reading strictly top-to-bottom without the whole
    // column taking half a minute.
    var cursorMs = 0.0;
    var endMs = 0.0;

    double book(int pieces, double stepMs, double runMs) {
      final start = cursorMs;
      final lastPieceMs = start + (pieces > 1 ? (pieces - 1) * stepMs : 0.0);
      if (lastPieceMs + runMs > endMs) endMs = lastPieceMs + runMs;
      cursorMs = lastPieceMs + _kElementGapMs;
      return start;
    }

    final eyebrowAt = book(1, 0, _kBlockRunMs);
    final titleAt = book(titleWords.length, _kTitleStepMs, _kTitleRunMs);
    final subtitleAt = book(subtitleWords.length, _kProseStepMs, _kProseRunMs);
    final bodyAt = bodyWords.isEmpty
        ? 0.0
        : book(bodyWords.length, _kProseStepMs, _kProseRunMs);
    final actionsAt =
        widget.actions == null ? 0.0 : book(1, 0, _kBlockRunMs);
    // The trust strip books one extra piece for its own hairline rule, which
    // draws in just ahead of the first stat.
    final statsAt = widget.stats.isEmpty
        ? 0.0
        : book(widget.stats.length + 1, _kStatStepMs, _kBlockRunMs);

    // A page wordy enough to overrun the controller is squeezed to fit, so
    // the tail settles gracefully instead of clamping and popping into place.
    final squeeze = endMs > _kTimelineMs ? _kTimelineMs / endMs : 1.0;
    double toFraction(double ms) => (ms * squeeze) / _kTimelineMs;

    /// One whole element, revealed as a single block.
    Widget block(double atMs, Widget child) => _SlideUp(
          parent: _c,
          begin: toFraction(atMs),
          run: toFraction(_kBlockRunMs),
          dy: _kBlockRiseDy,
          cache: false,
          child: child,
        );

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Eyebrow
        block(
          eyebrowAt,
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: r.isMobile ? 26 : 34,
                height: 2,
                decoration: BoxDecoration(
                  color: PageHero.accent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(width: r.isMobile ? 10 : 14),
              Flexible(
                child: Text(
                  widget.eyebrow.toUpperCase(),
                  style: TextStyle(
                    color: const Color(0xFFA8CDF2),
                    fontSize: r.isMobile ? 11 : 12.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: r.isMobile ? 2.0 : 2.6,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: r.isMobile ? 16 : 22),

        // Headline — one word at a time.
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: r.isDesktop ? 760 : double.infinity),
          child: _words(
            titleWords,
            TextStyle(
              color: Colors.white,
              // Inner-page titles sit a little under the home headline, but
              // not by much — they now occupy a full screen too, so the old
              // page-header scale looked lost in the space.
              fontSize: home ? r.displayHeading : r.displayHeading * 0.9,
              fontWeight: FontWeight.w800,
              height: 1.05,
              letterSpacing: r.isMobile ? -0.6 : -1.2,
              shadows: const [
                Shadow(color: Color(0x66000000), blurRadius: 24, offset: Offset(0, 2)),
              ],
            ),
            beginMs: titleAt,
            stepMs: _kTitleStepMs,
            runMs: _kTitleRunMs,
            dy: _kTitleRiseDy,
            // The only text worth its own cached layer: display size, with a
            // 24px-blur Shadow that is expensive to redraw per frame.
            cache: true,
            toFraction: toFraction,
          ),
        ),
        SizedBox(height: r.isMobile ? 14 : 20),

        // Subtitle — word by word, quicker than the headline.
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: proseWidth),
          child: _words(
            subtitleWords,
            TextStyle(
              color: Colors.white.withValues(alpha: 0.88),
              fontSize: home ? r.bodyLarge : r.heroSubHeading,
              fontWeight: FontWeight.w300,
              height: 1.55,
            ),
            beginMs: subtitleAt,
            stepMs: _kProseStepMs,
            runMs: _kProseRunMs,
            dy: _kProseRiseDy,
            cache: false,
            toFraction: toFraction,
          ),
        ),

        // Body copy (home only)
        if (bodyWords.isNotEmpty) ...[
          SizedBox(height: r.isMobile ? 12 : 14),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: proseWidth),
            child: _words(
              bodyWords,
              TextStyle(
                color: const Color(0xFFB9D6F2),
                fontSize: r.body + 1,
                height: 1.6,
              ),
              beginMs: bodyAt,
              stepMs: _kProseStepMs,
              runMs: _kProseRunMs,
              dy: _kProseRiseDy,
              cache: false,
              toFraction: toFraction,
            ),
          ),
        ],

        // Actions
        if (widget.actions != null) ...[
          SizedBox(height: r.isMobile ? 28 : 36),
          block(actionsAt, widget.actions!),
        ],

        // Trust strip: the rule, then one stat at a time. Each counter waits
        // out its own step before it starts ticking — see [countDelay].
        if (widget.stats.isNotEmpty) ...[
          SizedBox(height: r.isMobile ? 32 : 40),
          _TrustStrip(
            stats: widget.stats,
            reveal: (i, child) => _SlideUp(
              parent: _c,
              begin: toFraction(statsAt + i * _kStatStepMs),
              run: toFraction(_kBlockRunMs),
              dy: _kBlockRiseDy,
              cache: false,
              child: child,
            ),
            countDelay: (i) => Duration(
              milliseconds:
                  ((statsAt + (i + 1) * _kStatStepMs) * squeeze).round(),
            ),
          ),
        ],
      ],
    );
  }
}

// ─── Ken Burns slideshow background ──────────────────────────────────────────
/// Cross-fades through [assetPaths], drifting and slowly zooming each frame so
/// the background reads as a moving album rather than a static photo.
///
/// Only ever two images are mounted at once (the outgoing and the incoming
/// one), and only the *next* one is precached — so pointing this at a 40-image
/// gallery costs the same as pointing it at three.
class _HeroSlideshow extends StatefulWidget {
  final List<String> assetPaths;

  const _HeroSlideshow({required this.assetPaths});

  @override
  State<_HeroSlideshow> createState() => _HeroSlideshowState();
}

class _HeroSlideshowState extends State<_HeroSlideshow>
    with SingleTickerProviderStateMixin {
  /// How long each image holds the frame, cross-fade included.
  static const Duration _slideDuration = Duration(milliseconds: 7000);

  /// Portion of a slide's cycle spent cross-fading in (~1.6s of the 7s).
  static const double _fadeFraction = 0.23;

  /// Zoom range for one slide's life. Deliberately small — a big zoom on a
  /// full-window background reads as a wobble, not a drift.
  static const double _scaleFrom = 1.05;
  static const double _scaleTo = 1.18;

  /// Each slide scales about a different corner, which is what turns a plain
  /// zoom into a pan. Cycled so consecutive images never drift the same way.
  static const List<Alignment> _origins = [
    Alignment.topLeft,
    Alignment.bottomRight,
    Alignment.topRight,
    Alignment.bottomLeft,
    Alignment.center,
  ];

  late final AnimationController _c;
  late final Key _visibilityKey;
  int _index = 0;
  bool _animating = false;

  /// Cross-fade alpha for the incoming and outgoing image.
  ///
  /// These are handed to [Image.asset]'s `opacity` rather than wrapping each
  /// image in an [Opacity] widget. Same result on screen, very different cost:
  /// `Opacity` needs a `saveLayer` — an offscreen buffer the size of the
  /// window, twice over during a hand-off — whereas `Image`'s own parameter
  /// folds the alpha into the paint it was already making.
  ///
  /// A plain [Interval] with no curve is exactly the old
  /// `(t / _fadeFraction).clamp(0, 1)`.
  late final Animation<double> _fadeIn;
  late final Animation<double> _fadeOut;

  @override
  void initState() {
    super.initState();
    _visibilityKey = UniqueKey();
    _c = AnimationController(vsync: this, duration: _slideDuration);
    _fadeIn = _c.drive(
      CurveTween(curve: const Interval(0.0, _fadeFraction)),
    );
    _fadeOut = _c.drive(
      Tween<double>(begin: 1.0, end: 0.0)
          .chain(CurveTween(curve: const Interval(0.0, _fadeFraction))),
    );
    if (widget.assetPaths.length > 1) {
      _c.addStatusListener(_onCycleEnd);
      _animating = true;
      _c.forward();
    }
  }

  /// Stop advancing once the hero has scrolled off screen. On the Gallery
  /// page in particular there are dozens of photos below the fold, and
  /// repainting two full-window images at 60fps behind them the whole time
  /// is wasted work (and battery) for something nobody can see.
  void _onVisibilityChanged(VisibilityInfo info) {
    if (!mounted || widget.assetPaths.length < 2) return;
    final shouldRun = info.visibleFraction > 0.05;
    if (shouldRun == _animating) return;
    _animating = shouldRun;
    if (shouldRun) {
      _c.forward(); // resumes from where it paused
    } else {
      _c.stop();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _precacheAhead();
  }

  @override
  void dispose() {
    _c.removeStatusListener(_onCycleEnd);
    _c.dispose();
    super.dispose();
  }

  void _onCycleEnd(AnimationStatus status) {
    if (status != AnimationStatus.completed || !mounted) return;
    setState(() => _index = (_index + 1) % widget.assetPaths.length);
    _precacheAhead();
    if (_animating) _c.forward(from: 0);
  }

  /// Warm the image that's about to fade in, so the cross-fade never reveals
  /// an undecoded frame.
  void _precacheAhead() {
    final paths = widget.assetPaths;
    if (paths.isEmpty) return;
    final next = (_index + 1) % paths.length;
    precacheImage(AssetImage(paths[next]), context);
  }

  Widget _kenBurns(int i, double progress, Animation<double> opacity) {
    final scale = _scaleFrom + (_scaleTo - _scaleFrom) * progress;
    return Transform.scale(
      scale: scale,
      alignment: _origins[i % _origins.length],
      child: Image.asset(
        widget.assetPaths[i],
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        opacity: opacity,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final paths = widget.assetPaths;
    if (paths.isEmpty) return const SizedBox.expand();
    if (paths.length == 1) {
      return Image.asset(paths.first, fit: BoxFit.cover);
    }

    final prev = (_index - 1 + paths.length) % paths.length;

    // ClipRect matters here: Transform.scale paints outside its own box, and
    // the hero's Stack won't clip a descendant's paint overflow on its own —
    // without this the zoomed image bleeds over the section below the hero.
    return VisibilityDetector(
      key: _visibilityKey,
      onVisibilityChanged: _onVisibilityChanged,
      child: ClipRect(
        child: RepaintBoundary(
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, _) {
              final t = _c.value;
              final fade = (t / _fadeFraction).clamp(0.0, 1.0);
              return Stack(
                fit: StackFit.expand,
                children: [
                  // Outgoing image: keeps drifting past the end of its own
                  // range during the hand-off, so it doesn't visibly freeze
                  // or snap back while it fades out.
                  if (fade < 1.0)
                    _kenBurns(prev, 1.0 + 0.18 * fade, _fadeOut),
                  // Incoming image.
                  _kenBurns(_index, t, _fadeIn),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ─── Trust strip ─────────────────────────────────────────────────────────────
class _TrustStrip extends StatelessWidget {
  final List<HeroStat> stats;

  /// Wraps one piece of the strip in its slot of the hero's entrance
  /// sequence. Index 0 is the hairline rule, index `i + 1` is stat `i`, so
  /// the strip draws its own line in just ahead of the first number.
  ///
  /// The timeline lives in `_HeroContentState`; passing it in as a callback
  /// keeps every entrance offset on the page in one place instead of
  /// scattering fractions across the widgets that happen to use them.
  final Widget Function(int piece, Widget child) reveal;

  /// How long stat [i]'s [AnimatedCounter] waits before it starts ticking.
  ///
  /// VisibilityDetector reports from layout geometry, not opacity, so a
  /// counter inside a not-yet-revealed piece already reads as visible and
  /// would otherwise count down while still fully transparent.
  ///
  /// The wait is only as long as its own slot's *start*, not until it is
  /// fully opaque: the count runs for 2.6s, far longer than the reveal, so
  /// beginning as the stat rises into view reads fine — waiting for the fade
  /// to finish just made it feel late.
  final Duration Function(int i) countDelay;

  const _TrustStrip({
    required this.stats,
    required this.reveal,
    required this.countDelay,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: r.isDesktop ? 640 : double.infinity),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          reveal(
            0,
            Container(height: 1, color: Colors.white.withValues(alpha: 0.16)),
          ),
          SizedBox(height: r.isMobile ? 14 : 18),
          Wrap(
            spacing: r.isMobile ? 26 : 46,
            runSpacing: 16,
            children: [
              for (var i = 0; i < stats.length; i++)
                reveal(
                  i + 1,
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedCounter(
                        end: stats[i].value,
                        startDelay: countDelay(i),
                        // These values include a decimal tolerance
                        // (±0.0005"), and the "1k" shorthand path rounds
                        // anything under 1000 to a whole number — which would
                        // render that stat as a flat "0". For the integers
                        // here the two paths agree, so plain formatting is
                        // right for the whole strip.
                        useKShorthand: false,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: r.isMobile ? 18 : 21,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        stats[i].label.toUpperCase(),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.62),
                          fontSize: r.isMobile ? 10 : 11.5,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Blueprint grid ──────────────────────────────────────────────────────────
/// Faint engineering grid: minor lines every 46px, brighter major lines every
/// fifth. Painted rather than tiled with an image so it stays crisp at any
/// device pixel ratio and adds no asset weight.
class _BlueprintGridPainter extends CustomPainter {
  static const double _cell = 46;
  static const int _majorEvery = 5;

  /// The diagonal falloff that used to be a [ShaderMask] over this layer:
  /// full strength at the top-left, ~24% by 0.6 of the way across, gone at
  /// the right edge. Applied per-stroke now — see the layer comment in
  /// [PageHero] for why.
  static const _fadeBegin = Alignment(-1.0, -0.35);
  static const _fadeEnd = Alignment(1.0, 0.35);
  static const _fadeStops = [0.0, 0.6, 1.0];
  static const _fadeAlpha = [1.0, 0.239, 0.0]; // was white / white24 / clear

  /// [color] faded across [rect] on the diagonal above.
  static Shader _fade(Color color, Rect rect) => LinearGradient(
        begin: _fadeBegin,
        end: _fadeEnd,
        stops: _fadeStops,
        colors: [
          for (final a in _fadeAlpha)
            color.withValues(alpha: (color.a * a).clamp(0.0, 1.0)),
        ],
      ).createShader(rect);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final minor = Paint()
      ..shader = _fade(Colors.white.withValues(alpha: 0.055), rect)
      ..strokeWidth = 1;
    final major = Paint()
      ..shader = _fade(const Color(0xFF78BEFF).withValues(alpha: 0.10), rect)
      ..strokeWidth = 1;

    var i = 0;
    for (double x = 0; x <= size.width; x += _cell, i++) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        i % _majorEvery == 0 ? major : minor,
      );
    }
    i = 0;
    for (double y = 0; y <= size.height; y += _cell, i++) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        i % _majorEvery == 0 ? major : minor,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BlueprintGridPainter oldDelegate) => false;
}

/// Internal stateful widget that owns the [VideoPlayerController] lifecycle
/// for a looping, muted, autoplaying background video.
class _HeroBackgroundVideo extends StatefulWidget {
  final String assetPath;

  const _HeroBackgroundVideo({required this.assetPath});

  @override
  State<_HeroBackgroundVideo> createState() => _HeroBackgroundVideoState();
}

class _HeroBackgroundVideoState extends State<_HeroBackgroundVideo> {
  late final VideoPlayerController _controller;
  bool _disposed = false;
  bool _ready = false;

  /// Whether the hero is on screen *or close enough that it soon will be*.
  ///
  /// A playing video decodes a frame and re-uploads a texture on *every* frame
  /// the compositor draws, seen or not — left running it charges that against
  /// every scroll frame for the whole visit. But resuming a paused decoder
  /// costs a visible hitch, so waiting until the hero is actually visible puts
  /// that hitch exactly where the user is looking.
  ///
  /// So this does not come from a [VisibilityDetector]. It comes from
  /// [HeroProximityNotifier], which AppShell drives from the scroll offset and
  /// the measured hero height: it goes true while the hero is still a screen
  /// below, giving the decoder time to be up to speed before any of it shows.
  /// The hysteresis that stops this thrashing at the boundary lives there.
  bool _nearHero = true;
  ValueListenable<bool>? _proximity;


  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.assetPath)
      ..setLooping(true)
      ..setVolume(0)
      ..initialize().then((_) {
        if (_disposed) return;
        setState(() => _ready = true);
        // Guard on proximity: on a short window the hero can already be
        // scrolled well past by the time the asset finishes loading.
        if (_nearHero) _controller.play();
        // Release the entrance animation: the decoder is up, so the reveal
        // is no longer competing with it for frames.
        if (mounted) const HeroMediaReadyNotification().dispatch(context);
      });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final next = HeroProximityNotifier.of(context);
    if (next == _proximity) return;
    _proximity?.removeListener(_onProximityChanged);
    _proximity = next;
    _proximity?.addListener(_onProximityChanged);
    _onProximityChanged();
  }

  void _onProximityChanged() {
    final near = _proximity?.value ?? true;
    if (near == _nearHero) return;
    _nearHero = near;
    if (_disposed || !_ready) return;
    if (near) {
      _controller.play();
    } else {
      _controller.pause();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _proximity?.removeListener(_onProximityChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ── Do not restructure this tree once the video is up ─────────────────
    // An earlier version dropped the [AnimatedOpacity] after the fade-in
    // finished, on the theory that an opacity wrapper over a platform view is
    // never quite free. It stopped playback a couple of seconds into every
    // load: changing the widget *type* at this position unmounts everything
    // below it, and on the web `VideoPlayer` is an `HtmlElementView` whose
    // underlying <video> element does not survive being torn out of the DOM
    // and re-inserted. Whatever this wrapper costs, it is cheaper than that.
    //
    // The parent Container already paints navy underneath, so no solid
    // placeholder is needed — the video just fades up over it.
    return AnimatedOpacity(
      opacity: _ready ? 1 : 0,
      duration: const Duration(milliseconds: 450),
      child: !_ready
          ? const SizedBox.expand()
          // Isolated in its own layer: platform views have their mutators
          // re-applied whenever the surrounding layer repaints, and the
          // boundary keeps that from being driven by everything else painting
          // around it.
          : RepaintBoundary(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller.value.size.width,
                  height: _controller.value.size.height,
                  child: VideoPlayer(_controller),
                ),
              ),
            ),
    );
  }
}
