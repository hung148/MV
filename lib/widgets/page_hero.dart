import 'package:flutter/material.dart';
import 'package:mv/widgets/responsive.dart';

/// Shared hero banner used on every inner page (Services, Capabilities, About,
/// Gallery) and — via the [home] variant — on the Home page.
///
/// Standard usage (inner pages):
///   PageHero(
///     title: 'Our Services',
///     subtitle: 'Comprehensive CNC machining solutions for all your needs',
///   )
///
/// Home-page variant (diagonal tri-colour gradient + dark overlay + extra
/// content below the subtitle):
///   PageHero.home(
///     title: 'Precision CNC Manufacturing',
///     subtitle: 'Your trusted partner …',
///     body: 'From prototype to production …',   // optional third line
///     actions: Row(children: […]),               // buttons etc.
///   )
///
/// The caller is responsible for wrapping with FadeInSection when needed —
/// this widget has no opinion about animation.
class PageHero extends StatelessWidget {
  // ─── shared fields ───────────────────────────────────────────────────────
  final String title;
  final String subtitle;

  // ─── home-variant fields ─────────────────────────────────────────────────
  /// When true, uses the 3-colour diagonal gradient + dark scrim overlay.
  final bool _isHome;

  /// Optional third line of body text rendered below [subtitle].
  final String? body;

  /// Optional widget row (buttons, chips, etc.) rendered below [body].
  final Widget? actions;

  // ─── Standard constructor ─────────────────────────────────────────────────
  const PageHero({
    super.key,
    required this.title,
    required this.subtitle,
  })  : _isHome = false,
        body = null,
        actions = null;

  // ─── Home constructor ─────────────────────────────────────────────────────
  const PageHero.home({
    super.key,
    required this.title,
    required this.subtitle,
    this.body,
    this.actions,
  }) : _isHome = true;

  @override
  Widget build(BuildContext context) {
    return _isHome ? _buildHomeHero(context) : _buildPageHero(context);
  }

  // ── Inner-page hero (Services / Capabilities / About / Gallery) ───────────
  Widget _buildPageHero(BuildContext context) {
    final r = Responsive.of(context);
    return Container(
      padding: r.heroPadding,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0d47a1), Color(0xFF1976d2)],
        ),
      ),
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: r.maxContentWidth),
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: r.displayHeading,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: r.spacingM),
              Text(
                subtitle,
                style: TextStyle(fontSize: r.heroSubHeading, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Home hero (diagonal gradient + dark scrim + extra content) ────────────
  Widget _buildHomeHero(BuildContext context) {
    final r = Responsive.of(context);
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0d47a1), Color(0xFF1976d2), Color(0xFF42a5f5)],
        ),
      ),
      child: Stack(
        children: [
          // Dark scrim overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: 0.1),
                  ],
                ),
              ),
            ),
          ),
          // Content
          Center(
            child: Container(
              padding: r.heroPadding,
              constraints: BoxConstraints(maxWidth: r.maxContentWidth),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: r.displayHeading,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: r.spacingL),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: r.bodyLarge,
                      fontWeight: FontWeight.w300,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (body != null) ...[
                    SizedBox(height: r.spacingM),
                    Text(
                      body!,
                      style: TextStyle(color: const Color(0xFFE3F2FD), fontSize: r.body + 2),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  if (actions != null) ...[
                    SizedBox(height: r.spacingXL),
                    actions!,
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}