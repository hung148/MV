import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:mv/firebase_options.dart';
import 'package:mv/screens/about_page.dart';
import 'package:mv/screens/capabilities_page.dart';
import 'package:mv/screens/gallery_page.dart';
import 'package:mv/screens/home_page.dart';
import 'package:mv/screens/services_page.dart';
import 'package:mv/utils/seo_helper.dart';
import 'package:mv/widgets/navigation_bar.dart';
import 'package:mv/widgets/page_hero.dart'
    show HeroHeightNotification, HeroMediaReadyNotification;
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:visibility_detector/visibility_detector.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  usePathUrlStrategy();
  // Fire visibility callbacks immediately. The package's default batches them
  // on a 500 ms timer, so anything keyed off visibility — every AnimatedCounter,
  // the hero slideshow's pause/resume — could sit idle for up to half a second
  // after it was already on screen. (This line's comment was here without the
  // line itself, which is why the counters felt slow to start.)
  VisibilityDetectorController.instance.updateInterval = Duration.zero;
  runApp(const MVWebsite());
}

// ─── Page transition notifier ─────────────────────────────────────────────────
// PageHero listens to this. When `ready` flips to true, the route's cross-fade
// is complete and the hero can start its staggered entrance — otherwise the
// stagger would play out behind a page that's still fading in.
//
// (AnimatedCounter does NOT use this; it triggers off VisibilityDetector when
// it scrolls into view.)
class PageTransitionNotifier extends InheritedNotifier<ValueNotifier<bool>> {
  const PageTransitionNotifier({
    super.key,
    required ValueNotifier<bool> notifier,
    required super.child,
  }) : super(notifier: notifier);

  /// true = page has fully faded in, sections may animate.
  static bool readyOf(BuildContext context) {
    final n = context
        .dependOnInheritedWidgetOfExactType<PageTransitionNotifier>()
        ?.notifier;
    return n?.value ?? true; // default true so first load always animates
  }
}

// ─── Sliver pages ─────────────────────────────────────────────────────────────
/// A page that hands the route its body as slivers instead of one tall widget.
///
/// The pages started life as a `Column` inside a `SingleChildScrollView`, which
/// builds and lays out **every** section before the first frame — on Home that
/// measured as one 87ms BUILD and one 64ms LAYOUT frame at load, for five
/// material cards, the filmstrip, the footer and a 30KB quote form that nobody
/// can see yet. A `Column` neither builds lazily nor culls.
///
/// A page implementing this returns slivers, and the sections that matter go
/// through a `SliverChildBuilderDelegate` so they are constructed as they
/// approach the viewport. Pages that have not been converted still work — the
/// route falls back to the old `SingleChildScrollView` for them.
abstract class SliverPage extends StatelessWidget {
  const SliverPage({super.key});

  List<Widget> buildSlivers(BuildContext context);

  /// Should never run: the route calls [buildSlivers] and puts the result
  /// straight into its own `CustomScrollView`, so a SliverPage is consumed
  /// rather than mounted.
  ///
  /// It is defensive because getting this wrong is *silent*. The first attempt
  /// at this mechanism type-tested the wrong widget, fell through to the
  /// box-scrolling branch, and ended up building this method's old
  /// `CustomScrollView` inside a `SingleChildScrollView` — a viewport with
  /// unbounded height. Debug would have thrown; in profile and release the
  /// assert is compiled out and it just lays out to nothing, so the page went
  /// blank with an empty console. `shrinkWrap` keeps that from happening
  /// silently again.
  @override
  Widget build(BuildContext context) {
    assert(
      false,
      '$runtimeType was built directly. The route should call buildSlivers(); '
      'see _FadeRouteContent._scroller.',
    );
    return CustomScrollView(shrinkWrap: true, slivers: buildSlivers(context));
  }
}

// ─── Hero proximity ───────────────────────────────────────────────────────────
/// Whether the hero is on screen *or about to be*.
///
/// The hero video subscribes to this to decide whether to play. Resuming a
/// paused video decoder costs a visible hitch, so reacting to the hero
/// actually becoming visible is too late — the stutter lands in the frames the
/// user is watching. AppShell already knows the scroll offset and the measured
/// hero height, so it can say "the hero is coming" while it is still a screen
/// below and let the decoder be up to speed by the time any of it shows.
///
/// The band is deliberately hysteretic rather than direction-sensing: playback
/// resumes once the offset is within `_kHeroPreroll` of the
/// hero's bottom edge and does not stop until it is a further
/// `_kHeroRelease` past it. Tracking scroll *direction* would
/// flip on every trackpad wobble; two thresholds cannot.
class HeroProximityNotifier extends InheritedNotifier<ValueNotifier<bool>> {
  const HeroProximityNotifier({
    super.key,
    required ValueNotifier<bool> notifier,
    required super.child,
  }) : super(notifier: notifier);

  /// Defaults to true so a hero with no shell above it simply plays.
  static ValueListenable<bool>? of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<HeroProximityNotifier>()
      ?.notifier;
}

// ─── Fade page wrapper ──────────────────────────────────────────────────────
class _FadeRouteContent extends StatefulWidget {
  /// The page as the framework hands it to `transitionsBuilder` — wrapped by
  /// `ModalRoute` in a `RepaintBoundary` and a `Builder`. Used for the ordinary
  /// box-scrolling path.
  final Widget child;

  /// The page widget as *written in the route*, unwrapped.
  ///
  /// Needed because [child] above is a framework wrapper, so `child is
  /// SliverPage` is always false — which is exactly the bug that made the
  /// first version of this silently blank the page. Type-test this one.
  final Widget page;

  final Animation<double> inOpacity;
  final Animation<double> outOpacity;

  const _FadeRouteContent({
    required this.child,
    required this.page,
    required this.inOpacity,
    required this.outOpacity,
  });

  @override
  State<_FadeRouteContent> createState() => _FadeRouteContentState();
}

class _FadeRouteContentState extends State<_FadeRouteContent> {
  final ValueNotifier<bool> _sectionsReady = ValueNotifier(false);
  final ScrollController _scroll = ScrollController();

  // ── Holding the entrance until the page can afford it ──────────────────
  // A cold load does its heaviest work in exactly the second the hero wants
  // to animate: images decode for the first time, shaders compile, the video
  // decoder spins up. Playing the reveal into that contention is what made
  // the first load look rough. So once the route has faded in, the entrance
  // waits for two things — the hero's media to report ready, and one frame
  // to actually complete inside its budget — and then plays.
  //
  // The wait is capped. If the page is still busy at [_kMaxHold] the reveal
  // plays anyway: a hero frozen while a slow connection finishes loading is
  // worse than a few dropped frames, and a gate with no cap is a bug waiting
  // for the one page that never sends the signal.

  /// Longest the hero may sit still waiting for the page to settle.
  static const _kMaxHold = Duration(milliseconds: 500);

  /// A frame at or under this counts as "the page is keeping up". Slightly
  /// over one 60Hz frame (16.7ms), so ordinary jitter doesn't fail the test.
  static const _kFrameBudget = Duration(milliseconds: 24);

  bool _mediaReady = false;
  bool _waitingForFrame = false;
  Timer? _holdTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.jumpTo(0);
    });
    widget.inOpacity.addStatusListener(_onStatusChanged);
    if (widget.inOpacity.status == AnimationStatus.completed) {
      _armEntrance();
    }
  }

  void _onStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _armEntrance();
    } else if (status == AnimationStatus.forward) {
      _cancelHold();
      _mediaReady = false;
      _sectionsReady.value = false;
    }
  }

  bool _onMediaReady(HeroMediaReadyNotification n) {
    _mediaReady = true;
    return true; // nothing above this cares
  }

  /// Start waiting for a good moment to reveal.
  void _armEntrance() {
    if (_sectionsReady.value || _holdTimer != null) return;
    _holdTimer = Timer(_kMaxHold, _releaseEntrance);
    if (!_waitingForFrame) {
      _waitingForFrame = true;
      SchedulerBinding.instance.addTimingsCallback(_onFrameTimings);
    }
  }

  /// Frames only arrive here while something is actually painting, so this is
  /// a fast path, never the guarantee — [_holdTimer] is the guarantee.
  void _onFrameTimings(List<FrameTiming> timings) {
    if (!_mediaReady || _sectionsReady.value) return;
    for (final t in timings) {
      if (t.totalSpan <= _kFrameBudget) {
        // Off the frame callback: releasing here would set state in the
        // middle of the framework reporting timings.
        scheduleMicrotask(_releaseEntrance);
        return;
      }
    }
  }

  void _releaseEntrance() {
    if (!mounted) return;
    _cancelHold();
    _sectionsReady.value = true;
  }

  void _cancelHold() {
    _holdTimer?.cancel();
    _holdTimer = null;
    if (_waitingForFrame) {
      _waitingForFrame = false;
      SchedulerBinding.instance.removeTimingsCallback(_onFrameTimings);
    }
  }

  @override
  void dispose() {
    _cancelHold();
    widget.inOpacity.removeStatusListener(_onStatusChanged);
    _sectionsReady.dispose();
    _scroll.dispose();
    super.dispose();
  }

  /// The route's scroll view.
  ///
  /// A [SliverPage] gets a `CustomScrollView`, so its sections build lazily.
  /// Anything else keeps the original `SingleChildScrollView` — the whole page
  /// in one box, wrapped in a `RepaintBoundary`.
  Widget _scroller(BuildContext context) {
    final page = widget.page;
    if (page is SliverPage) {
      return CustomScrollView(
        controller: _scroll,
        slivers: page.buildSlivers(context),
      );
    }
    return SingleChildScrollView(
      controller: _scroll,
      child: RepaintBoundary(child: widget.child),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: widget.outOpacity,
      child: FadeTransition(
        opacity: widget.inOpacity,
        child: PageTransitionNotifier(
          notifier: _sectionsReady,
          child: NotificationListener<HeroMediaReadyNotification>(
            onNotification: _onMediaReady,
            child: _scroller(context),
          ),
        ),
      ),
    );
  }
}

CustomTransitionPage<void> _fadePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    transitionDuration: const Duration(milliseconds: 400),
    reverseTransitionDuration: const Duration(milliseconds: 400),
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, pageChild) {
      final fadeIn = CurvedAnimation(
        parent: animation,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      );
      final fadeOut = CurvedAnimation(
        parent: secondaryAnimation,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      );
      final outOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(fadeOut);

      return _FadeRouteContent(
        inOpacity: fadeIn,
        outOpacity: outOpacity,
        // `child` is the framework's wrapped page; `page` is the widget this
        // route was written with. The sliver test needs the unwrapped one.
        page: child,
        child: pageChild,
      );
    },
  );
}

// ─── Router ───────────────────────────────────────────────────────────────────
final _router = GoRouter(
  initialLocation: '/',
  errorBuilder: (context, state) => AppShell(
    currentRoute: state.uri.path,
    child: _NotFoundPage(error: state.error),
  ),
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return AppShell(currentRoute: state.uri.path, child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) {
            SeoHelper.update(
              title: 'CNC Precision Machining in Santa Clara, CA | MV Manufacturing LLC',
              description: 'Owner-operated CNC milling and precision machining in Santa Clara, CA. '
                  'Fast 24-hour quotes, tolerances to ±0.0005", aerospace and medical parts welcome.',
              canonicalPath: '/',
            );
            return _fadePage(state, const HomePageContent());
          },
        ),
        GoRoute(
          path: '/services',
          pageBuilder: (context, state) {
            SeoHelper.update(
              title: 'CNC Machining Services — Milling, Prototyping & Production | MV Manufacturing LLC',
              description: 'CNC milling, rapid prototyping, and production runs for aerospace, medical, '
                  'and industrial clients. Personal attention on every job by owner Minh Vu.',
              canonicalPath: '/services',
            );
            return _fadePage(state, const ServicesPage());
          },
        ),
        GoRoute(
          path: '/capabilities',
          pageBuilder: (context, state) {
            SeoHelper.update(
              title: 'CNC Capabilities — Tolerances, Materials & Equipment | MV Manufacturing LLC',
              description: 'Precision CNC capabilities: tolerances to ±0.0005", aluminum, stainless steel, '
                  'brass, copper, and plastics. Located in Santa Clara, CA.',
              canonicalPath: '/capabilities',
            );
            return _fadePage(state, const CapabilitiesPage());
          },
        ),
        GoRoute(
          path: '/about',
          pageBuilder: (context, state) {
            SeoHelper.update(
              title: 'About MV Manufacturing LLC — Owner-Operated CNC Shop in Santa Clara',
              description: 'Founded in 2025 by master machinist Minh Vu. Every part personally inspected. '
                  'Serving aerospace, medical, and industrial clients from Santa Clara, CA.',
              canonicalPath: '/about',
            );
            return _fadePage(state, const AboutPage());
          },
        ),
        GoRoute(
          path: '/gallery',
          pageBuilder: (context, state) {
            SeoHelper.update(
              title: 'Machined Parts Gallery | MV Manufacturing LLC',
              description: 'Photos of precision CNC machined components produced at MV Manufacturing LLC — '
                  'aluminum and stainless steel parts for aerospace, medical, and industrial use.',
              canonicalPath: '/gallery',
            );
            return _fadePage(state, const GalleryPage());
          },
        ),
      ],
    ),
  ],
);

// ─── 404 page ──────────────────────────────────────────────────────────────────
// Rendered for any URL that doesn't match a route above. Kept inline to avoid
// a new file for a single screen; matches the site's blue gradient identity.
class _NotFoundPage extends StatelessWidget {
  final Exception? error;
  const _NotFoundPage({this.error});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0d47a1), Color(0xFF1976d2), Color(0xFF42a5f5)],
        ),
      ),
      child: Center(
        child: Padding(
          // Top inset clears the transparent nav bar floating above.
          padding: const EdgeInsets.fromLTRB(24, kNavBarHeight, 24, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '404',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 96,
                  fontWeight: FontWeight.bold,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Page Not Found',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "The page you're looking for doesn't exist or has moved.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFFE3F2FD), fontSize: 16),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => context.go('/'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF0d47a1),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  elevation: 4,
                ),
                child: const Text(
                  'Back to Home',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MVWebsite extends StatelessWidget {
  const MVWebsite({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      title: 'MV Manufacturing LLC',
      debugShowCheckedModeBanner: false,
    );
  }
}

// ─── AppShell ─────────────────────────────────────────────────────────────────
class AppShell extends StatefulWidget {
  final Widget child;
  final String currentRoute;

  const AppShell({super.key, required this.child, required this.currentRoute});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  static const double _navHeight = kNavBarHeight;

  /// Distance over which the bar eases from transparent to solid, ending at
  /// the moment the hero's bottom edge reaches the underside of the bar. So
  /// the bar stays see-through for the whole hero, darkens over the last
  /// [_fadeDistance] of it, and is fully solid the instant the hero is gone —
  /// reversing exactly the same way on the way back up.
  static const double _fadeDistance = 160;

  bool _isMobileMenuOpen = false;

  /// 0 = fully transparent over the hero, 1 = solid. Held in a notifier
  /// rather than State so a scroll frame repaints only the bar's decoration
  /// instead of rebuilding the shell (and re-running this build) 60× a second.
  final ValueNotifier<double> _solidity = ValueNotifier<double>(0);

  /// Drives [HeroProximityNotifier] — see there for why this is a band and
  /// not a visibility test.
  final ValueNotifier<bool> _heroNear = ValueNotifier<bool>(true);

  /// How far *past* the hero's bottom edge playback is kept alive, and how
  /// much further again before it is allowed to stop. The gap between them is
  /// the hysteresis; scrolling back up crosses the lower threshold first, so
  /// the decoder is already running before the hero edge comes into view.
  ///
  /// The preroll is deliberately large — more than a screen. Resuming a video
  /// on the web costs several frames before it is delivering pictures again,
  /// and 900px (the first attempt) is only about a third of a second into a
  /// fast flick: not enough, and Tom could still see the hiccup. At 2000px the
  /// stall happens while the hero is comfortably off screen.
  static const double _kHeroPreroll = 2000;
  static const double _kHeroRelease = 700;

  /// How long the page must stay beyond the release threshold before playback
  /// actually stops.
  ///
  /// Distance alone still pauses on a scroll that merely *passes* through the
  /// lower page — and every one of those pauses buys a hitch on the way back.
  /// Requiring the reader to settle down there means that during ordinary
  /// browsing the video is essentially never paused, and the saving is banked
  /// only when someone parks far below the hero, where they are least likely
  /// to snap straight back to it.
  static const Duration _kHeroDwell = Duration(milliseconds: 2500);
  Timer? _heroFarTimer;

  /// Height of the current page's hero, as measured and reported by
  /// [PageHero]. Null until the first frame — and on a page with no hero at
  /// all (the 404), which is why the fallback below is the viewport height.
  double? _heroHeight;

  /// Last vertical scroll offset, kept so the solidity can be recomputed when
  /// the hero height arrives (or changes on resize) without waiting for the
  /// next scroll event.
  double _offset = 0;

  /// Viewport height, refreshed each build — used as the hero-height fallback.
  double _viewport = 0;

  final GlobalKey<CustomNavigationBarState> _navBarKey = GlobalKey();

  @override
  void dispose() {
    _solidity.dispose();
    _heroFarTimer?.cancel();
    _heroNear.dispose();
    super.dispose();
  }

  void _onMobileMenuChanged(bool isOpen) {
    if (mounted) {
      setState(() => _isMobileMenuOpen = isOpen);
    }
  }

  void _closeMobileMenu() {
    _navBarKey.currentState?.closeMobileMenu();
  }

  /// Listens to whichever SingleChildScrollView the current route built (they
  /// live inside _FadeRouteContent), rather than owning a ScrollController
  /// here — that way a route change can never leave a stale controller
  /// attached.
  bool _onScroll(ScrollNotification n) {
    if (n.metrics.axis != Axis.vertical) return false;
    _offset = n.metrics.pixels;
    _updateSolidity();
    return false;
  }

  bool _onHeroHeight(HeroHeightNotification n) {
    if (n.height == _heroHeight) return true;
    _heroHeight = n.height;
    _updateSolidity();
    return true; // the shell is the only interested party — stop it here
  }

  void _updateSolidity() {
    final hero = _heroHeight ?? _viewport;

    // Hero proximity, on the same scroll signal. Two thresholds, so the state
    // only changes when the offset leaves the band entirely — in between, it
    // holds whatever it was. Coming back is immediate; leaving has to be held
    // for [_kHeroDwell] first.
    if (_offset < hero + _kHeroPreroll) {
      _heroFarTimer?.cancel();
      _heroFarTimer = null;
      _heroNear.value = true;
    } else if (_offset > hero + _kHeroPreroll + _kHeroRelease) {
      if (_heroNear.value && _heroFarTimer == null) {
        _heroFarTimer = Timer(_kHeroDwell, () {
          _heroFarTimer = null;
          if (mounted) _heroNear.value = false;
        });
      }
    }

    // The hero's bottom edge is level with the underside of the bar once the
    // page has scrolled (heroHeight - navHeight) — that's where the bar must
    // be fully solid.
    final end = hero - _navHeight;
    if (end <= 0) {
      _solidity.value = 1; // no hero worth speaking of — just stay solid
      return;
    }

    // Start the fade [_fadeDistance] earlier, but never above the top of the
    // page: on a hero shorter than the fade distance the bar would otherwise
    // begin life partly darkened.
    final start = (end - _fadeDistance).clamp(0.0, end);
    _solidity.value = ((_offset - start) / (end - start)).clamp(0.0, 1.0);
  }

  @override
  void didUpdateWidget(covariant AppShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Every route jumps its scroll offset back to 0 on entry, so the bar has
    // to return to transparent too — otherwise navigating away from a
    // scrolled page leaves a solid bar sitting on the new page's hero. The
    // measured height is dropped as well, since the incoming page's hero
    // hasn't reported yet.
    if (oldWidget.currentRoute != widget.currentRoute) {
      _offset = 0;
      _heroHeight = null;
      _solidity.value = 0;
      _heroFarTimer?.cancel();
      _heroFarTimer = null;
      _heroNear.value = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    _viewport = MediaQuery.sizeOf(context).height;
    return Scaffold(
      backgroundColor: const Color(0xFF04101F),
      body: Stack(
        children: [
          // Page content runs edge-to-edge *underneath* the nav bar, so the
          // hero's video/gradient reaches the very top of the window.
          // PageHero insets its own content by kNavBarHeight to clear the bar.
          Positioned.fill(
            child: NotificationListener<HeroHeightNotification>(
              onNotification: _onHeroHeight,
              child: NotificationListener<ScrollNotification>(
                onNotification: _onScroll,
                child: HeroProximityNotifier(
                  notifier: _heroNear,
                  child: widget.child,
                ),
              ),
            ),
          ),
          // Tap-outside overlay at AppShell level — covers the page content
          // area (y = 70 to bottom) so taps anywhere on the page close the
          // mobile menu. Painted BEFORE the nav bar so the nav bar (and its
          // drawer of links) sits ON TOP of it — otherwise this opaque overlay
          // would swallow taps on the links and the menu would close instead
          // of navigating.
          if (_isMobileMenuOpen)
            Positioned(
              top: _navHeight,
              left: 0,
              right: 0,
              bottom: 0,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _closeMobileMenu,
                child: Container(color: Colors.transparent),
              ),
            ),
          // Nav bar pinned to top — rendered LAST so it (and the mobile drawer)
          // receive taps above the tap-outside overlay.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CustomNavigationBar(
              key: _navBarKey,
              currentRoute: widget.currentRoute,
              onNavigate: (route) => context.go(route),
              onMobileMenuChanged: _onMobileMenuChanged,
              solidity: _solidity,
            ),
          ),
        ],
      ),
    );
  }
}