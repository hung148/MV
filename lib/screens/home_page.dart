import 'dart:math' as math;
import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:mv/widgets/responsive.dart';
import 'package:mv/widgets/quote_form.dart';
import 'package:mv/widgets/fade_in_section.dart';
import 'package:mv/widgets/page_hero.dart';
import 'package:go_router/go_router.dart';
import 'package:mv/widgets/footer.dart';
import 'package:mv/widgets/hover_lift.dart';
import 'package:mv/widgets/hover_card.dart';
import 'package:mv/screens/gallery_page.dart' show kGalleryImages, openGalleryLightbox;

class HomePageContent extends StatelessWidget {
  const HomePageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHero(context),
        _buildFeaturesSection(context),
        _buildServicesSection(context),
        _buildCapabilitiesSection(context),
        _buildGalleryPreviewSection(context),
        _buildWhyChooseUsSection(context),
        _buildStatsSection(context),
        _buildCTASection(context),
        const AppFooter(),
      ],
    );
  }

  Widget _buildHero(BuildContext context) {
    final r = Responsive.of(context);
    return FadeInSection(
      child: PageHero.home(
        title: 'Precision CNC Manufacturing',
        subtitle: 'Your trusted partner for high-quality machining solutions',
        backgroundVideo: 'assets/videos/home_hero_bg.mp4',
        body: 'From prototype to production — owner-operated, personally inspected, every part.',
        actions: Wrap(
          spacing: r.spacingM,
          runSpacing: r.spacingM,
          alignment: WrapAlignment.center,
          children: [
            HoverLift(
              liftPx: 3,
              addShadow: true,
              borderRadius: 4,
              child: ElevatedButton(
                onPressed: () => context.go('/capabilities'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF0d47a1),
                  padding: r.primaryButtonPadding,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  elevation: 4,
                ),
                child: Text(
                  'View Our Capabilities',
                  style: TextStyle(fontSize: r.buttonText, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            HoverLift(
              liftPx: 3,
              addShadow: true,
              borderRadius: 4,
              child: OutlinedButton(
                onPressed: () => showQuoteDialog(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white, width: 2),
                  padding: r.primaryButtonPadding,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                child: Text(
                  'Get a Quote',
                  style: TextStyle(fontSize: r.buttonText, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesSection(BuildContext context) {
    final r = Responsive.of(context);
    return Container(
      padding: r.sectionPadding,
      color: Colors.white,
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: r.maxContentWidth),
          child: Column(
            children: [
              Text(
                'Why MV Manufacturing LLC?',
                style: TextStyle(fontSize: r.heading1, fontWeight: FontWeight.bold, color: const Color(0xFF1a1a1a)),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: r.spacingM),
              Text(
                'Precision machining with a personal touch — every job handled by the owner',
                style: TextStyle(fontSize: r.body + 2, color: const Color(0xFF666666)),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: r.spacingXXL),
              Wrap(
                spacing: r.spacingL,
                runSpacing: r.spacingL,
                alignment: WrapAlignment.center,
                children: [
                  _buildFeatureCard(r, icon: Icons.precision_manufacturing, title: 'Precision Engineering', description: 'Tolerances down to ±0.0005\" with state-of-the-art CNC equipment'),
                  _buildFeatureCard(r, icon: Icons.speed, title: 'Fast Turnaround', description: 'Quick quotes within 24 hours and rapid production times to keep your project moving'),
                  _buildFeatureCard(r, icon: Icons.person, title: 'Owner-Operated', description: 'Minh personally oversees every job — no handoffs, no shortcuts, just consistent quality'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(Responsive r, {required IconData icon, required String title, required String description}) {
    return HoverCard(
      width: r.featureCardWidth,
      padding: EdgeInsets.all(r.cardPadding),
      baseDecoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(r.cardRadius),
        border: Border.all(color: const Color(0xFFe0e0e0)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(r.spacingM),
            decoration: BoxDecoration(
              color: const Color(0xFF0d47a1).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(icon, size: r.iconLarge, color: const Color(0xFF0d47a1)),
          ),
          SizedBox(height: r.spacingM),
          Text(title, style: TextStyle(fontSize: r.heading3, fontWeight: FontWeight.bold, color: const Color(0xFF1a1a1a)), textAlign: TextAlign.center),
          SizedBox(height: r.spacingS),
          Text(description, style: TextStyle(fontSize: r.body, color: const Color(0xFF666666), height: 1.6), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildServicesSection(BuildContext context) {
    final r = Responsive.of(context);
    return Container(
      padding: r.sectionPadding,
      color: const Color(0xFFf5f5f5),
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: r.maxContentWidth),
          child: Column(
            children: [
              Text('What We Do', style: TextStyle(fontSize: r.heading1, fontWeight: FontWeight.bold, color: const Color(0xFF1a1a1a)), textAlign: TextAlign.center),
              SizedBox(height: r.spacingM),
              Text('Full-service CNC machining from prototype to production run', style: TextStyle(fontSize: r.body + 2, color: const Color(0xFF666666)), textAlign: TextAlign.center),
              SizedBox(height: r.spacingXXL),
              Wrap(
                spacing: r.cardSpacing,
                runSpacing: r.cardSpacing,
                alignment: WrapAlignment.center,
                children: [
                  _buildServiceCard(r, imageIcon: Icons.settings, title: 'CNC Milling', description: '3-axis milling for complex parts and tight tolerances'),
                  _buildServiceCard(r, imageIcon: Icons.science, title: 'Rapid Prototyping', description: 'Fast single-piece and low-volume prototype runs'),
                  _buildServiceCard(r, imageIcon: Icons.factory, title: 'Production Runs', description: 'Consistent quality on repeat orders up to 1,000+ parts/month'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard(Responsive r, {required IconData imageIcon, required String title, required String description}) {
    return HoverCard(
      width: r.serviceCardWidth,
      padding: EdgeInsets.all(r.cardPadding),
      baseDecoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(r.cardRadius),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(imageIcon, size: r.iconHero + 8, color: const Color(0xFF0d47a1)),
          SizedBox(height: r.spacingM),
          Text(title, style: TextStyle(fontSize: r.heading3, fontWeight: FontWeight.bold, color: const Color(0xFF1a1a1a)), textAlign: TextAlign.center),
          SizedBox(height: r.spacingXS),
          Text(description, style: TextStyle(fontSize: r.caption + 1, color: const Color(0xFF666666), height: 1.4), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildCapabilitiesSection(BuildContext context) {
    final r = Responsive.of(context);

    const materials = [
      _MaterialItem(name: 'Aluminum',       image: 'assets/images/home_images/aluminum.webp'),
      _MaterialItem(name: 'Stainless Steel', image: 'assets/images/home_images/stainless_steel.webp'),
      _MaterialItem(name: 'Titanium',       image: 'assets/images/home_images/titanium_metal.webp'),
      _MaterialItem(name: 'Brass',          image: 'assets/images/home_images/brass_metal.webp'),
      _MaterialItem(name: 'Copper',         image: 'assets/images/home_images/copper_metal_surface.webp'),
      _MaterialItem(name: 'Plastics',       image: 'assets/images/home_images/plastic_meterial.webp'),
    ];

    return Container(
      padding: r.sectionPadding,
      color: Colors.white,
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: r.maxContentWidth),
          child: Column(
            children: [
              Text(
                'Materials We Work With',
                style: TextStyle(fontSize: r.heading1, fontWeight: FontWeight.bold, color: const Color(0xFF1a1a1a)),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: r.spacingXXL),
              Wrap(
                spacing: r.spacingL,
                runSpacing: r.spacingL,
                alignment: WrapAlignment.center,
                children: [
                  for (final material in materials)
                    _buildMaterialCard(r, material),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMaterialCard(Responsive r, _MaterialItem material) {
    return HoverLift(
      liftPx: 6,
      addShadow: true,
      borderRadius: r.cardRadius,
      child: SizedBox(
        width: r.materialCardWidth,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(r.cardRadius),
          child: Stack(
            children: [
              AspectRatio(
                aspectRatio: 4 / 3,
                child: Image.asset(
                  material.image,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.6),
                      ],
                      stops: const [0.5, 1.0],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Text(
                    material.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGalleryPreviewSection(BuildContext context) {
    final r = Responsive.of(context);
    return Container(
      padding: r.sectionPadding,
      color: const Color(0xFFf5f5f5),
      child: Column(
        children: [
          Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: r.maxContentWidth),
              child: Column(
                children: [
                  Text(
                    'From Our Shop Floor',
                    style: TextStyle(fontSize: r.heading1, fontWeight: FontWeight.bold, color: const Color(0xFF1a1a1a)),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: r.spacingM),
                  Text(
                    'A look at recent parts and projects — scroll to browse',
                    style: TextStyle(fontSize: r.body + 2, color: const Color(0xFF666666)),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: r.spacingXXL),
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: r.maxContentWidth),
              child: _GalleryFilmstrip(images: kGalleryImages, r: r),
            ),
          ),
          SizedBox(height: r.spacingXXL),
          HoverLift(
            liftPx: 3,
            addShadow: true,
            borderRadius: 4,
            child: OutlinedButton(
              onPressed: () => context.go('/gallery'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF0d47a1),
                side: const BorderSide(color: Color(0xFF0d47a1), width: 2),
                padding: r.primaryButtonPadding,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('View Full Gallery', style: TextStyle(fontSize: r.buttonText, fontWeight: FontWeight.bold)),
                  SizedBox(width: r.spacingXS),
                  const Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhyChooseUsSection(BuildContext context) {
    final r = Responsive.of(context);
    return Container(
      padding: r.sectionPadding,
      color: const Color(0xFF0d47a1),
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: r.maxContentWidth),
          child: Column(
            children: [
              Text('Experience & Expertise', style: TextStyle(fontSize: r.heading1, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
              SizedBox(height: r.spacingXXL),
              r.isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildExperiencePoint(r, icon: Icons.calendar_today, title: '9+ Years', description: 'Minh has been machining professionally since before opening MV Manufacturing')),
                        SizedBox(width: r.spacingXL),
                        Expanded(child: _buildExperiencePoint(r, icon: Icons.person, title: 'Owner-Operated', description: 'Every part personally handled by Minh Vu — you deal directly with the machinist')),
                        SizedBox(width: r.spacingXL),
                        Expanded(child: _buildExperiencePoint(r, icon: Icons.build, title: '2 CNC Machines', description: 'Dedicated CNC turning and milling equipment for precision work')),
                      ],
                    )
                  : Column(
                      children: [
                        _buildExperiencePoint(r, icon: Icons.calendar_today, title: '9+ Years', description: 'Minh has been machining professionally since before opening MV Manufacturing'),
                        SizedBox(height: r.spacingXL),
                        _buildExperiencePoint(r, icon: Icons.person, title: 'Owner-Operated', description: 'Every part personally handled by Minh Vu — you deal directly with the machinist'),
                        SizedBox(height: r.spacingXL),
                        _buildExperiencePoint(r, icon: Icons.build, title: '2 CNC Machines', description: 'Dedicated CNC turning and milling equipment for precision work'),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExperiencePoint(Responsive r, {required IconData icon, required String title, required String description}) {
    return Column(
      children: [
        Icon(icon, size: r.iconHero, color: Colors.white),
        SizedBox(height: r.spacingM),
        Text(title, style: TextStyle(fontSize: r.heading2, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
        SizedBox(height: r.spacingXS),
        Text(description, style: TextStyle(fontSize: r.body, color: const Color(0xFFE3F2FD), height: 1.5), textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    final r = Responsive.of(context);
    return Container(
      padding: EdgeInsets.symmetric(vertical: r.spacingXXL, horizontal: 24),
      color: const Color(0xFF1a1a1a),
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: r.maxContentWidth),
          child: r.isDesktop
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(r, '2', 'CNC Machines'),
                    _buildStatItem(r, '1,000+', 'Parts/Month Capacity'),
                    _buildStatItem(r, '24hr', 'Quote Turnaround'),
                  ],
                )
              : Wrap(
                  spacing: r.spacingXL,
                  runSpacing: r.spacingXL,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildStatItem(r, '2', 'CNC Machines'),
                    _buildStatItem(r, '1,000+', 'Parts/Month Capacity'),
                    _buildStatItem(r, '24hr', 'Quote Turnaround'),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildStatItem(Responsive r, String number, String label) {
    return Column(
      children: [
        AnimatedCounter(
          end: number,
          style: TextStyle(fontSize: r.statNumber, fontWeight: FontWeight.bold, color: const Color(0xFF0066cc)),
        ),
        SizedBox(height: r.spacingXS),
        Text(label, style: TextStyle(fontSize: r.body, color: const Color(0xFFcccccc)), textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildCTASection(BuildContext context) {
    final r = Responsive.of(context);
    return Container(
      padding: r.sectionPadding,
      color: Colors.white,
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: r.maxNarrowWidth),
          child: Column(
            children: [
              Text('Ready to Get Started?', style: TextStyle(fontSize: r.heading1, fontWeight: FontWeight.bold, color: const Color(0xFF1a1a1a)), textAlign: TextAlign.center),
              SizedBox(height: r.spacingM),
              Text('Send us your drawings and get a quote within 24 hours', style: TextStyle(fontSize: r.body + 2, color: const Color(0xFF666666)), textAlign: TextAlign.center),
              SizedBox(height: r.spacingXL),
              HoverLift(
                liftPx: 3,
                addShadow: true,
                borderRadius: 4,
                child: ElevatedButton(
                  onPressed: () => showQuoteDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0d47a1),
                    foregroundColor: Colors.white,
                    padding: r.ctaButtonPadding,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    elevation: 2,
                  ),
                  child: Text('Request a Quote', style: TextStyle(fontSize: r.buttonTextLarge, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Material item model ──────────────────────────────────────────────────────

class _MaterialItem {
  final String name;
  final String image;
  const _MaterialItem({required this.name, required this.image});
}

// ─── Gallery filmstrip with focal-point scaling ───────────────────────────────
//
// A horizontally scrolling row of gallery thumbnails where whichever tile is
// closest to the horizontal center of the viewport grows larger, and tiles
// shrink smoothly as they slide away toward either edge. Pure scroll-driven
// animation — no snapping, no controller jumps; the user just scrolls
// (trackpad, scrollbar, or touch drag) and tiles continuously rescale as
// their distance from center changes.
//
// While the pointer is over this widget, it flips a JS-visible flag
// (window.__galleryFilmstripHovered) that index.html's wheel listener
// checks before calling preventDefault() on horizontal scroll — so the
// browser's native "swipe to go back" gesture is only suppressed while
// the cursor is actually over the filmstrip, not page-wide.
@JS('window.__galleryFilmstripHovered')
external set _filmstripHovered(bool value);

class _GalleryFilmstrip extends StatefulWidget {
  final List<String> images;
  final Responsive r;

  const _GalleryFilmstrip({required this.images, required this.r});

  @override
  State<_GalleryFilmstrip> createState() => _GalleryFilmstripState();
}

class _GalleryFilmstripState extends State<_GalleryFilmstrip> {
  late final ScrollController _controller;
  double? _lastViewportWidth;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    // Repaint every tile's scale as the user scrolls.
    _controller.addListener(_onScroll);
    // Start with the row already settled (first frame may have offset 0,
    // which is correct — leftmost tile centered/near-center on first paint).
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  void _onScroll() => setState(() {});

  /// Called from build() whenever the measured viewport width changes
  /// (window resize). Flutter's ScrollPosition reconciles its internal
  /// viewportDimension and clamps `pixels` to the new scroll extents on its
  /// own schedule, which can land a frame after LayoutBuilder already
  /// rebuilt with the new width — so the tile-scale math momentarily reads
  /// a stale offset until something else (e.g. a manual scroll) forces a
  /// repaint. Scheduling an explicit post-frame rebuild closes that gap.
  void _scheduleResettle() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onScroll);
    _controller.dispose();
    // Safety net: if this widget is removed while the pointer was still
    // over it (e.g. navigating away mid-hover), make sure the flag doesn't
    // stay stuck "true" and suppress back-swipe page-wide afterwards.
    _setHovered(false);
    super.dispose();
  }

  void _setHovered(bool value) {
    try {
      _filmstripHovered = value;
    } catch (_) {
      // Swallow on non-web platforms / before JS interop is ready — this
      // is a purely cosmetic browser-gesture fix, never load-bearing.
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.r;
    final baseSize = r.galleryPreviewTileSize;
    // How much bigger the centered tile gets, and how far the falloff
    // reaches before tiles settle at their smallest scale.
    final maxScale = r.isMobile ? 1.15 : 1.25;
    final minScale = 0.85;
    final falloff = baseSize * 1.6;
    // Reserve enough row height for the largest possible tile so growth
    // never clips; tiles are bottom-aligned so they grow upward in place.
    final rowHeight = baseSize * maxScale;
    // Fixed visual gap between tiles, independent of scale — kept small so
    // it doesn't look like a gap blew open next to the (smaller) neighbors
    // of a scaled-up center tile.
    final gap = r.cardSpacing * 0.5;
    // Each tile's slot is sized for the LARGEST it could ever get (plus the
    // gap) so a scaled-up tile's painted bounds never spill into the next
    // slot. The unscaled image stays baseSize; only the reserved horizontal
    // space — and the gap multiplier above — are tuned to keep this tight.
    final slotWidth = baseSize * maxScale + gap;

    return MouseRegion(
      onEnter: (_) => _setHovered(true),
      onExit: (_) => _setHovered(false),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final viewportWidth = constraints.maxWidth;
          // Leading inset added before item 0 so the first/last tiles can
          // reach the viewport's center line when scrolled all the way in.
          // (This term cancels out of the centering math below — it shifts
          // both tileCenter and the comparison point by the same amount —
          // so it only affects scroll *range*, not which tile currently
          // reads as centered for a given scroll offset.)
          final leadingInset = viewportWidth / 2 - slotWidth / 2;

          if (_lastViewportWidth != null && _lastViewportWidth != viewportWidth) {
            // Viewport just changed size (window resize). Force one more
            // rebuild next frame so we repaint with whatever offset the
            // scroll position settles on, instead of the stale one
            // computed mid-resize.
            _scheduleResettle();
          }
          _lastViewportWidth = viewportWidth;

          return SizedBox(
            height: rowHeight,
            child: ListView.builder(
              controller: _controller,
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: leadingInset),
              itemCount: widget.images.length,
              itemBuilder: (context, index) {
                // This tile's center, in the same coordinate space as the
                // scroll offset (i.e. including the leading inset), minus
                // the current scroll offset, minus the viewport's center —
                // gives the signed distance (px) from the viewport center.
                final tileCenter = leadingInset + index * slotWidth + slotWidth / 2;
                final scrollOffset = _controller.hasClients ? _controller.offset : 0.0;
                final distanceFromCenter = (tileCenter - scrollOffset - viewportWidth / 2).abs();

                final t = (distanceFromCenter / falloff).clamp(0.0, 1.0);
                // Smooth ease (cosine) rather than linear falloff so the
                // grow/shrink reads as a gentle wave, not a sharp tent.
                final eased = (1 + math.cos(math.pi * t)) / 2;
                final scale = minScale + (maxScale - minScale) * eased;

                return SizedBox(
                  width: slotWidth,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Transform.scale(
                      scale: scale,
                      alignment: Alignment.bottomCenter,
                      child: _GalleryFilmstripTile(
                        image: widget.images[index],
                        index: index,
                        images: widget.images,
                        size: baseSize,
                        radius: r.cardRadius,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _GalleryFilmstripTile extends StatelessWidget {
  final String image;
  final int index;
  final List<String> images;
  final double size;
  final double radius;

  const _GalleryFilmstripTile({
    required this.image,
    required this.index,
    required this.images,
    required this.size,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return HoverLift(
      liftPx: 6,
      addShadow: true,
      borderRadius: radius,
      child: GestureDetector(
        onTap: () => openGalleryLightbox(context, images, index),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: Image.asset(
            image,
            width: size,
            height: size,
            fit: BoxFit.cover,
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              if (wasSynchronouslyLoaded || frame != null) return child;
              return Container(
                width: size,
                height: size,
                color: const Color(0xFFe0e0e0),
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0066cc)),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}