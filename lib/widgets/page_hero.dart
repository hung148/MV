import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:mv/widgets/responsive.dart';
import 'package:mv/widgets/animated_counter.dart';
import 'package:mv/widgets/navigation_bar.dart' show kNavBarHeight;
import 'package:mv/main.dart' show PageTransitionNotifier;

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
  /// strip and a scroll cue.
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
            Positioned.fill(
              child: IgnorePointer(
                child: ShaderMask(
                  blendMode: BlendMode.dstIn,
                  shaderCallback: (rect) => const LinearGradient(
                    begin: Alignment(-1.0, -0.35),
                    end: Alignment(1.0, 0.35),
                    colors: [Colors.white, Colors.white24, Colors.transparent],
                    stops: [0.0, 0.6, 1.0],
                  ).createShader(rect),
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

            // ── Layer 7: scroll cue ─────────────────────────────────────────
            // Shown on every page now that every hero fills the window: with
            // no sliver of the next section visible, the cue is the only thing
            // telling a visitor there's more below. Skipped on mobile, where
            // scrolling is instinctive and the space is tighter.
            if (!r.isMobile)
              Positioned(
                left: horizontal,
                right: horizontal,
                bottom: 22,
                child: IgnorePointer(
                  // Same centre-then-left-align trick as the content column, so
                  // the cue lines up under the headline on a wide screen.
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: r.maxContentWidth),
                      child: const Align(
                        alignment: Alignment.centerLeft,
                        child: _ScrollCue(),
                      ),
                    ),
                  ),
                ),
              ),

            // ── Layer 8: brand rule along the bottom edge ───────────────────
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: IgnorePointer(
                child: Container(
                  height: 3,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1976d2), accent, Color(0x1F42A5F5)],
                      stops: [0.0, 0.38, 1.0],
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
  const _ReportHeight({required this.child});

  @override
  State<_ReportHeight> createState() => _ReportHeightState();
}

class _ReportHeightState extends State<_ReportHeight> {
  double? _reported;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
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
      duration: const Duration(milliseconds: 1100),
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

  /// Fade + rise, staggered by [order]: each item starts ~100 ms after the
  /// previous one and runs for ~550 ms.
  ///
  /// The interval is evaluated by hand against [_c] rather than wrapping it
  /// in a CurvedAnimation, because this runs inside build() — a new
  /// CurvedAnimation per build would add a listener to [_c] every frame the
  /// hero rebuilds and never drop it.
  /// Where item [order] starts within [_c]'s 0→1 range.
  static double _staggerBegin(int order) => (order * 0.09).clamp(0.0, 0.5);

  /// How long a counter at stagger position [order] should wait before it
  /// starts counting.
  ///
  /// VisibilityDetector reports from layout geometry, so a counter inside a
  /// not-yet-faded-in stagger step already reads as visible; without this it
  /// would start counting while still at opacity 0.
  ///
  /// The wait is only as long as its stagger step's *start* — not until the
  /// row is fully opaque. The count runs for 2.6s, far longer than the 550ms
  /// fade, so it's still plainly visible if it begins as the row rises into
  /// view; waiting for the fade to finish just made it feel late.
  Duration _countDelayFor(int order) {
    final ms = _staggerBegin(order) * _c.duration!.inMilliseconds;
    return Duration(milliseconds: ms.round());
  }

  Widget _stagger(int order, Widget child) {
    final begin = _staggerBegin(order);
    final interval = Interval(
      begin,
      (begin + 0.5).clamp(0.0, 1.0),
      curve: Curves.easeOutCubic,
    );
    return AnimatedBuilder(
      animation: _c,
      child: child,
      builder: (context, built) {
        final t = interval.transform(_c.value);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, 18 * (1 - t)),
            child: built,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final home = widget.isHome;

    // Measured line length: capping the subtitle keeps it from running the
    // full width of a wide desktop window.
    final proseWidth = r.isDesktop ? 580.0 : double.infinity;

    var order = 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Eyebrow
        _stagger(
          order++,
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

        // Headline
        _stagger(
          order++,
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: r.isDesktop ? 760 : double.infinity),
            child: Text(
              widget.title,
              style: TextStyle(
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
            ),
          ),
        ),
        SizedBox(height: r.isMobile ? 14 : 20),

        // Subtitle
        _stagger(
          order++,
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: proseWidth),
            child: Text(
              widget.subtitle,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.88),
                fontSize: home ? r.bodyLarge : r.heroSubHeading,
                fontWeight: FontWeight.w300,
                height: 1.55,
              ),
            ),
          ),
        ),

        // Body copy (home only)
        if (widget.body != null) ...[
          SizedBox(height: r.isMobile ? 12 : 14),
          _stagger(
            order++,
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: proseWidth),
              child: Text(
                widget.body!,
                style: TextStyle(
                  color: const Color(0xFFB9D6F2),
                  fontSize: r.body + 1,
                  height: 1.6,
                ),
              ),
            ),
          ),
        ],

        // Actions
        if (widget.actions != null) ...[
          SizedBox(height: r.isMobile ? 28 : 36),
          _stagger(order++, widget.actions!),
        ],

        // Trust strip. Its counters have to wait out their own stagger step
        // before they start ticking — see [_countDelayFor].
        if (widget.stats.isNotEmpty) ...[
          SizedBox(height: r.isMobile ? 32 : 40),
          _stagger(
            order,
            _TrustStrip(
              stats: widget.stats,
              countDelay: _countDelayFor(order++),
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

  @override
  void initState() {
    super.initState();
    _visibilityKey = UniqueKey();
    _c = AnimationController(vsync: this, duration: _slideDuration);
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

  Widget _kenBurns(int i, double progress) {
    final scale = _scaleFrom + (_scaleTo - _scaleFrom) * progress;
    return Transform.scale(
      scale: scale,
      alignment: _origins[i % _origins.length],
      child: Image.asset(
        widget.assetPaths[i],
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
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
                    Opacity(
                      opacity: 1 - fade,
                      child: _kenBurns(prev, 1.0 + 0.18 * fade),
                    ),
                  // Incoming image.
                  Opacity(
                    opacity: fade,
                    child: _kenBurns(_index, t),
                  ),
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

  /// Passed through to each [AnimatedCounter] so the numbers start ticking
  /// when the strip becomes readable, not while it's still faded out.
  final Duration countDelay;

  const _TrustStrip({required this.stats, required this.countDelay});

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: r.isDesktop ? 640 : double.infinity),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 1, color: Colors.white.withValues(alpha: 0.16)),
          SizedBox(height: r.isMobile ? 14 : 18),
          Wrap(
            spacing: r.isMobile ? 26 : 46,
            runSpacing: 16,
            children: [
              for (final s in stats)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedCounter(
                      end: s.value,
                      startDelay: countDelay,
                      // These values include a decimal tolerance
                      // (±0.0005"), and the "1k" shorthand path rounds
                      // anything under 1000 to a whole number — which would
                      // render that stat as a flat "0". For the integers here
                      // the two paths agree, so plain formatting is right for
                      // the whole strip.
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
                      s.label.toUpperCase(),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.62),
                        fontSize: r.isMobile ? 10 : 11.5,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.4,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Scroll cue ──────────────────────────────────────────────────────────────
/// A thin fading bar plus a "SCROLL" label at the bottom-left of the home
/// hero. Loops a gentle vertical drift so it reads as an invitation rather
/// than a static label.
class _ScrollCue extends StatefulWidget {
  const _ScrollCue();

  @override
  State<_ScrollCue> createState() => _ScrollCueState();
}

class _ScrollCueState extends State<_ScrollCue>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _c,
          builder: (context, _) => Transform.translate(
            offset: Offset(0, 4 * Curves.easeInOut.transform(_c.value)),
            child: Container(
              width: 1,
              height: 26,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.7),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'SCROLL',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.55),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.0,
          ),
        ),
      ],
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

  @override
  void paint(Canvas canvas, Size size) {
    final minor = Paint()
      ..color = Colors.white.withValues(alpha: 0.055)
      ..strokeWidth = 1;
    final major = Paint()
      ..color = const Color(0xFF78BEFF).withValues(alpha: 0.10)
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

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.assetPath)
      ..setLooping(true)
      ..setVolume(0)
      ..initialize().then((_) {
        if (_disposed) return;
        setState(() => _ready = true);
        _controller.play();
      });
  }

  @override
  void dispose() {
    _disposed = true;
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The parent Container already paints navy underneath, so instead of a
    // solid placeholder the video simply fades in once it's ready — no flash
    // of white, and no jump in brightness when playback starts.
    return AnimatedOpacity(
      opacity: _ready ? 1 : 0,
      duration: const Duration(milliseconds: 450),
      child: !_ready
          ? const SizedBox.expand()
          : FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: VideoPlayer(_controller),
              ),
            ),
    );
  }
}
