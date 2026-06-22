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
          padding: const EdgeInsets.symmetric(horizontal: 24),
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
  static const double _navHeight = 70;
  bool _isMobileMenuOpen = false;
  final GlobalKey<CustomNavigationBarState> _navBarKey = GlobalKey();

  void _onMobileMenuChanged(bool isOpen) {
    if (mounted) {
      setState(() => _isMobileMenuOpen = isOpen);
    }
  }

  void _closeMobileMenu() {
    _navBarKey.currentState?.closeMobileMenu();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0d47a1),
      body: Stack(
        children: [
          // Page content sits below the nav bar.
          Positioned.fill(
            top: _navHeight,
            child: widget.child,
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
            ),
          ),
        ],
      ),
    );
  }
}