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

// Create the router configuration
final _router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return AppShell(currentRoute: state.uri.path, child: child);
      },
      routes: [
        GoRoute(path: '/', builder: (context, state) => const HomePageContent()),
        GoRoute(path: '/services', builder: (context, state) => const ServicesPage()),
        GoRoute(path: '/capabilities', builder: (context, state) => const CapabilitiesPage()),
        GoRoute(path: '/about', builder: (context, state) => const AboutPage()),
        GoRoute(path: '/gallery', builder: (context, state) => const GalleryPage()),
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

class AppShell extends StatelessWidget {
  final Widget child;
  final String currentRoute;

  const AppShell({super.key, required this.child, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _AppShellBody(currentRoute: currentRoute, child: child),
    );
  }
}

class _AppShellBody extends StatefulWidget {
  final Widget child;
  final String currentRoute;

  const _AppShellBody({required this.child, required this.currentRoute});

  @override
  State<_AppShellBody> createState() => _AppShellBodyState();
}

class _AppShellBodyState extends State<_AppShellBody> {
  final GlobalKey _navKey = GlobalKey();
  double _navHeight = 64;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureNav());
  }

  void _measureNav() {
    final box = _navKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null && mounted) {
      setState(() => _navHeight = box.size.height);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Page content scrolls underneath, padded so it starts below the nav
        Positioned.fill(
          top: _navHeight,
          child: widget.child,
        ),
        // Nav bar sits on top
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: KeyedSubtree(
            key: _navKey,
            child: CustomNavigationBar(
              currentRoute: widget.currentRoute,
              onNavigate: (route) {
                context.go(route);
                // Re-measure after navigation (menu may close)
                WidgetsBinding.instance.addPostFrameCallback((_) => _measureNav());
              },
            ),
          ),
        ),
      ],
    );
  }
}