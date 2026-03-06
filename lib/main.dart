import 'package:flutter/material.dart';
import 'package:mv/screens/aboutPage.dart';
import 'package:mv/screens/capabilitiesPage.dart';
import 'package:mv/screens/galleryPage.dart';
import 'package:mv/screens/homePage.dart';
import 'package:mv/screens/servicesPage.dart';
import 'package:mv/widgets/navigation_bar.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';

void main() {
  usePathUrlStrategy();
  runApp(const MVWebsite());
}

// Create the router configuration
final _router = GoRouter(
  initialLocation: '/',
  routes: [
    // This "ShellRoute" keeps the AppShell (Navbar) on screen
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
      routerConfig: _router, // Use the router here
      title: 'MV Machine Shop',
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
      body: Column(
        children: [
          CustomNavigationBar(
            currentRoute: currentRoute,
            onNavigate: (route) => context.go(route), // Use context.go()
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}