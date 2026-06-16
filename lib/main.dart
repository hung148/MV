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

// ─── Router ───────────────────────────────────────────────────────────────────
final _router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return AppShell(currentRoute: state.uri.path, child: child);
      },
      routes: [
        GoRoute(path: '/',             builder: (_, __) => const HomePageContent()),
        GoRoute(path: '/services',     builder: (_, __) => const ServicesPage()),
        GoRoute(path: '/capabilities', builder: (_, __) => const CapabilitiesPage()),
        GoRoute(path: '/about',        builder: (_, __) => const AboutPage()),
        GoRoute(path: '/gallery',      builder: (_, __) => const GalleryPage()),
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
// GoRouter rebuilds this on every navigation — keep it stateless.
// All animation state lives in _PageSwitcherState via the GlobalKey.
final _pageSwitcherKey = GlobalKey<_PageSwitcherState>();

class AppShell extends StatelessWidget {
  final Widget child;
  final String currentRoute;

  const AppShell({super.key, required this.child, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pageSwitcherKey.currentState?.setPage(child, currentRoute);
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0d47a1),
      body: _PageSwitcher(
        key: _pageSwitcherKey,
        initialChild: child,
        initialRoute: currentRoute,
      ),
    );
  }
}

// ─── _PageSwitcher ────────────────────────────────────────────────────────────
class _PageSwitcher extends StatefulWidget {
  final Widget initialChild;
  final String initialRoute;

  const _PageSwitcher({
    super.key,
    required this.initialChild,
    required this.initialRoute,
  });

  @override
  State<_PageSwitcher> createState() => _PageSwitcherState();
}

class _PageSwitcherState extends State<_PageSwitcher>
    with SingleTickerProviderStateMixin {
  static const double _navHeight = 70;
  // How long the page fades in/out
  static const Duration _fadeDuration = Duration(milliseconds: 250);

  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  final ScrollController _scroll = ScrollController();

  late Widget _visibleChild;
  late String _visibleRoute;
  Widget? _pendingChild;
  String? _pendingRoute;
  bool _busy = false;

  // Sections listen to this — false means "hold", true means "go"
  final ValueNotifier<bool> _sectionsReady = ValueNotifier(true);

  @override
  void initState() {
    super.initState();
    _visibleChild = widget.initialChild;
    _visibleRoute = widget.initialRoute;

    _ctrl = AnimationController(
      vsync: this,
      duration: _fadeDuration,
      value: 1.0,
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  void setPage(Widget child, String route) {
    if (route == _visibleRoute) return;

    if (_busy) {
      _pendingChild = child;
      _pendingRoute = route;
      return;
    }

    _runTransition(child, route);
  }

  void _runTransition(Widget child, String route) {
    _busy = true;
    _pendingChild = null;
    _pendingRoute = null;

    // Tell sections to hold — new page is about to mount but shouldn't animate yet
    _sectionsReady.value = false;

    // 1. Fade OUT old page
    _ctrl.reverse().then((_) {
      if (!mounted) return;

      // 2. Swap page content (still invisible), reset scroll
      setState(() {
        _visibleChild = child;
        _visibleRoute = route;
      });
      _scroll.jumpTo(0);

      // 3. Fade IN new page
      _ctrl.forward().then((_) {
        if (!mounted) return;

        // 4. Page is fully visible — release sections to stagger in
        _sectionsReady.value = true;
        _busy = false;

        if (_pendingChild != null) {
          _runTransition(_pendingChild!, _pendingRoute!);
        }
      });
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    _sectionsReady.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          top: _navHeight,
          child: FadeTransition(
            opacity: _fade,
            // Provide the readiness signal to all descendant FadeInSections
            child: PageTransitionNotifier(
              notifier: _sectionsReady,
              child: SingleChildScrollView(
                key: ValueKey(_visibleRoute),
                controller: _scroll,
                child: _visibleChild,
              ),
            ),
          ),
        ),
        Positioned(
          top: 0, left: 0, right: 0,
          child: CustomNavigationBar(
            currentRoute: _visibleRoute,
            onNavigate: (route) => context.go(route),
          ),
        ),
      ],
    );
  }
}