import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mv/firebase_options.dart';
import 'package:mv/screens/about_page.dart';
import 'package:mv/screens/capabilities_page.dart';
import 'package:mv/screens/gallery_page.dart';
import 'package:mv/screens/home_page.dart';
import 'package:mv/screens/services_page.dart';
import 'package:mv/utils/seo_helper.dart';
import 'package:mv/widgets/navigation_bar.dart';
import 'package:mv/widgets/page_hero.dart' show HeroHeightNotification;
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

// ─── Fade page wrapper ──────────────────────────────────────────────────────
class _FadeRouteContent extends StatefulWidget {
  final Widget child;
  final Animation<double> inOpacity;
  final Animation<double> outOpacity;

  const _FadeRouteContent({
    required this.child,
    required this.inOpacity,
    required this.outOpacity,
  });

  @override
  State<_FadeRouteContent> createState() => _FadeRouteContentState();
}

class _FadeRouteContentState extends State<_FadeRouteContent> {
  final ValueNotifier<bool> _sectionsReady = ValueNotifier(false);
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.jumpTo(0);
    });
    widget.inOpacity.addStatusListener(_onStatusChanged);
    if (widget.inOpacity.status == AnimationStatus.completed) {
      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted) _sectionsReady.value = true;
      });
    }
  }

  void _onStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted) _sectionsReady.value = true;
      });
    } else if (status == AnimationStatus.forward) {
      _sectionsReady.value = false;
    }
  }

  @override
  void dispose() {
    widget.inOpacity.removeStatusListener(_onStatusChanged);
    _sectionsReady.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: widget.outOpacity,
      child: FadeTransition(
        opacity: widget.inOpacity,
        child: PageTransitionNotifier(
          notifier: _sectionsReady,
          child: SingleChildScrollView(
            controller: _scroll,
            child: RepaintBoundary(child: widget.child),
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
                child: widget.child,
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