import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
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
/// content below the subtitle), now with optional background image or video:
///   PageHero.home(
///     title: 'Precision CNC Manufacturing',
///     subtitle: 'Your trusted partner …',
///     body: 'From prototype to production …',   // optional third line
///     actions: Row(children: […]),               // buttons etc.
///     backgroundImage: 'assets/images/home_hero_bg.webp', // optional
///     backgroundVideo: 'assets/videos/home_hero_bg.mp4',  // optional
///   )
///
/// If both [backgroundImage] and [backgroundVideo] are provided, the video
/// takes priority and the image is ignored. If neither is provided, the
/// original tri-colour gradient is used.
///
/// The caller is responsible for wrapping with FadeInSection when needed —
/// this widget has no opinion about animation.
class PageHero extends StatelessWidget {
  // ─── shared fields ───────────────────────────────────────────────────────
  final String title;
  final String subtitle;

  // ─── home-variant fields ─────────────────────────────────────────────────
  /// When true, uses the 3-colour diagonal gradient + dark scrim overlay
  /// (or the background image/video, if provided).
  final bool _isHome;

  /// Optional third line of body text rendered below [subtitle].
  final String? body;

  /// Optional widget row (buttons, chips, etc.) rendered below [body].
  final Widget? actions;

  /// Optional static background image asset path.
  final String? backgroundImage;

  /// Optional looping, muted background video asset path.
  /// Takes priority over [backgroundImage] if both are set.
  final String? backgroundVideo;

  /// Minimum hero height. Defaults to 70% of the viewport height so inner
  /// pages (Services/Capabilities/About/Gallery) visually match the Home
  /// hero's scale instead of shrink-wrapping to just the title/subtitle.
  /// Pass a smaller value (or null to disable) if you want the old
  /// content-sized behavior on a specific page.
  final double? minHeight;

  // ─── Standard constructor ─────────────────────────────────────────────────
  const PageHero({
    super.key,
    required this.title,
    required this.subtitle,
    this.backgroundImage,
    this.backgroundVideo,
    this.minHeight = double.infinity, // sentinel meaning "use default viewport ratio"
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
    this.backgroundImage,
    this.backgroundVideo,
    this.minHeight = double.infinity,
  }) : _isHome = true;

  double _resolvedMinHeight(BuildContext context) {
    if (minHeight == null) return 0;
    if (minHeight!.isFinite) return minHeight!;

    final size = MediaQuery.sizeOf(context);
    final width = size.width;

    // Smaller windows get a smaller share of the viewport height, since a
    // 70%-tall hero looks great on desktop but overwhelming on mobile/tablet.
    double ratio;
    if (width < 600) {
      ratio = 0.4; // mobile
    } else if (width < 1024) {
      ratio = 0.55; // tablet
    } else {
      ratio = 0.7; // desktop
    }

    // Clamp so it never gets too cramped (tiny phones) or absurdly tall
    // (very short/wide desktop windows).
    return (size.height * ratio).clamp(320.0, 800.0);
  }

  @override
  Widget build(BuildContext context) {
    return _isHome ? _buildHomeHero(context) : _buildPageHero(context);
  }

  // ── Inner-page hero (Services / Capabilities / About / Gallery) ───────────
  Widget _buildPageHero(BuildContext context) {
    final r = Responsive.of(context);
    final hasMedia = backgroundVideo != null || backgroundImage != null;

    return Container(
      constraints: BoxConstraints(minHeight: _resolvedMinHeight(context)),
      decoration: hasMedia
          ? null
          : const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0d47a1), Color(0xFF1976d2)],
              ),
            ),
      child: Stack(
        children: [
          // Background layer: video > image > (nothing, gradient already set)
          if (backgroundVideo != null)
            Positioned.fill(
              child: _HeroBackgroundVideo(assetPath: backgroundVideo!),
            )
          else if (backgroundImage != null)
            Positioned.fill(
              child: Image.asset(
                backgroundImage!,
                fit: BoxFit.cover,
              ),
            ),

          // Dark scrim overlay (only needed when there's media behind the text)
          if (hasMedia)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.3),
                      Colors.black.withValues(alpha: 0.15),
                    ],
                  ),
                ),
              ),
            ),

          // Content
          Padding(
            padding: r.heroPadding,
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
          ),
        ],
      ),
    );
  }

  // ── Home hero (diagonal gradient / image / video + dark scrim) ────────────
  Widget _buildHomeHero(BuildContext context) {
    final r = Responsive.of(context);
    return Container(
      constraints: BoxConstraints(minHeight: _resolvedMinHeight(context)),
      decoration: (backgroundVideo == null && backgroundImage == null)
          ? const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0d47a1), Color(0xFF1976d2), Color(0xFF42a5f5)],
              ),
            )
          : null,
      child: Stack(
        children: [
          // Background layer: video > image > (nothing, gradient already set)
          if (backgroundVideo != null)
            Positioned.fill(
              child: _HeroBackgroundVideo(assetPath: backgroundVideo!),
            )
          else if (backgroundImage != null)
            Positioned.fill(
              child: Image.asset(
                backgroundImage!,
                fit: BoxFit.cover,
              ),
            ),

          // Dark scrim overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(
                      alpha: (backgroundVideo != null || backgroundImage != null) ? 0.3 : 0.3,
                    ),
                    Colors.black.withValues(
                      alpha: (backgroundVideo != null || backgroundImage != null) ? 0.15 : 0.1,
                    ),
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
    if (!_ready) {
      // Solid fallback color while the video loads, so there's no flash of
      // empty/white space.
      return Container(color: const Color(0xFF0d47a1));
    }
    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: _controller.value.size.width,
        height: _controller.value.size.height,
        child: VideoPlayer(_controller),
      ),
    );
  }
}