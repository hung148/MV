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
      backgroundColor: const Color(0xFF0d47a1),
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
  // Use a fixed base height for the header or measure only the "closed" state
  // Typically 64-80px is standard for navbars. 
  final double _baseNavHeight = 70; 
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(_AppShellBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    // FIX: Reset scroll position to top whenever the route changes
    if (oldWidget.currentRoute != widget.currentRoute) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Page content
        Positioned.fill(
          // Use a fixed top value so the content doesn't "jump" when menu opens
          top: _baseNavHeight, 
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            // Use layoutBuilder to ensure old pages are properly disposed
            layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
              return Stack(
                children: <Widget>[
                  ...previousChildren,
                  if (currentChild != null) currentChild,
                ],
              );
            },
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            child: KeyedSubtree(
              // We add 'page_' prefix to ensure this key is distinct from other keys
              key: ValueKey('page_${widget.currentRoute}'),
              child: SingleChildScrollView(
                controller: _scrollController,
                child: widget.child,
              ),
            ),
          ),
        ),
        // Nav bar sits on top and its menu will OVERLAY the content
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: CustomNavigationBar(
            currentRoute: widget.currentRoute,
            onNavigate: (route) {
              context.go(route);
            },
          ),
        ),
      ],
    );
  }
}
