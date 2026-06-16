import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mv/firebase_options.dart';
import 'package:mv/screens/about_page.dart';
import 'package:mv/screens/capabilities_page.dart';
import 'package:mv/screens/gallery_page.dart';
import 'package:mv/screens/home_page.dart';
import 'package:mv/screens/services_page.dart';
import 'package:mv/widgets/navigation_bar.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  usePathUrlStrategy();
  runApp(const MVWebsite());
}

// ─── Page transition notifier ─────────────────────────────────────────────────
// FadeInSection listens to this. When `ready` flips to true, sections know the
// page fade-in is complete and they can start their stagger animations.
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
// Wraps the page content, drives PageTransitionNotifier off the route
// transition's own AnimationController (provided by GoRouter/Navigator),
// instead of a separate hand-rolled controller. This is what makes the
// fade reliable — GoRouter guarantees this animation always runs to
// completion for every push/replace.
class _FadeRouteContent extends StatefulWidget {
  final Widget child;
  // Drives this page's own fade-IN (second half of the shared timeline).
  final Animation<double> inOpacity;
  // Drives this page's fade-OUT while the NEXT page is pushed on top of it
  // (first half of the shared timeline, from the next page's perspective).
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
    // Reset scroll position for the new page.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.jumpTo(0);
    });
    widget.inOpacity.addStatusListener(_onStatusChanged);
    // If we mounted already-completed (e.g. first route), fire after a small
    // buffer so section animations never overlap the tail of the page fade.
    if (widget.inOpacity.status == AnimationStatus.completed) {
      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted) _sectionsReady.value = true;
      });
    }
  }

  void _onStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      // Buffer prevents section anims from firing exactly as the page fade ends,
      // which causes a visible content pop / stutter on Flutter web.
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
    // Two stacked FadeTransitions instead of a manual Opacity widget.
    // FadeTransition uses RenderAnimatedOpacity under the hood, which Flutter
    // can composite as a cached layer rather than repainting the whole
    // subtree's raster content every animation tick — this is what removes
    // the stutter that a plain Opacity (driven via AnimatedBuilder) caused
    // on heavier pages.
    //
    // outOpacity drives this page fading OUT (1→0) when a new page is being
    // pushed on top of it. inOpacity drives this page fading IN (0→1) when
    // it is the incoming page. Exactly one of the two is ever animating at
    // a time (see _fadePage below), so nesting them is equivalent to
    // multiplying — but each gets its own compositing layer instead of
    // forcing a shared repaint path.
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

/// Builds a [CustomTransitionPage] that fades [child] in/out sequentially:
/// the outgoing page fully disappears (first half of the transition) before
/// the incoming page fades in (second half). Both halves run off the same
/// underlying animation clock via [Interval], so they can never drift out
/// of sync with each other.
CustomTransitionPage<void> _fadePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    transitionDuration: const Duration(milliseconds: 400),
    reverseTransitionDuration: const Duration(milliseconds: 400),
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, pageChild) {
      // First half of this page's own forward-push: fade IN, from 0.5→1.0
      // of the shared clock so it starts only after the previous page (whose
      // outOpacity is driven by this same `animation` instance, used as ITS
      // secondaryAnimation) has finished disappearing.
      //
      // Curves.linear here (not easeOut) — easing curves that start with a
      // steep slope (easeOut ramps fast off zero) make the very first
      // frames of the fade-in jump in opacity quickly, which can make a
      // hitch in that first frame more visually obvious. Linear keeps the
      // opening of the fade gentle.
      final fadeIn = CurvedAnimation(
        parent: animation,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      );
      // When this page is the OLD one and a new page is pushed on top of it,
      // `secondaryAnimation` runs 0.0→1.0. Fade OUT during the first half
      // only, then hold fully transparent for the second half while the
      // new page fades in on top.
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
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return AppShell(currentRoute: state.uri.path, child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => _fadePage(state, const HomePageContent()),
        ),
        GoRoute(
          path: '/services',
          pageBuilder: (context, state) => _fadePage(state, const ServicesPage()),
        ),
        GoRoute(
          path: '/capabilities',
          pageBuilder: (context, state) => _fadePage(state, const CapabilitiesPage()),
        ),
        GoRoute(
          path: '/about',
          pageBuilder: (context, state) => _fadePage(state, const AboutPage()),
        ),
        GoRoute(
          path: '/gallery',
          pageBuilder: (context, state) => _fadePage(state, const GalleryPage()),
        ),
      ],
    ),
  ],
);

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
// Persistent nav bar + page body. GoRouter now owns the page transition
// animation (via CustomTransitionPage above), so this widget stays simple:
// no GlobalKey, no manual AnimationController, no post-frame callback races.
class AppShell extends StatelessWidget {
  final Widget child;
  final String currentRoute;

  const AppShell({super.key, required this.child, required this.currentRoute});

  static const double _navHeight = 70;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0d47a1),
      body: Stack(
        children: [
          Positioned.fill(
            top: _navHeight,
            child: child,
          ),
          Positioned(
            top: 0, left: 0, right: 0,
            child: CustomNavigationBar(
              currentRoute: currentRoute,
              onNavigate: (route) => context.go(route),
            ),
          ),
        ],
      ),
    );
  }
}