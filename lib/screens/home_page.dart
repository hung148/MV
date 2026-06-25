import 'package:flutter/material.dart';
import 'package:mv/widgets/responsive.dart';
import 'package:mv/widgets/quote_form.dart';
import 'package:mv/widgets/fade_in_section.dart';
import 'package:mv/widgets/page_hero.dart';
import 'package:mv/widgets/scroll_reveal.dart';
import 'package:go_router/go_router.dart';
import 'package:mv/widgets/footer.dart';
import 'package:mv/widgets/hover_lift.dart';
import 'package:mv/widgets/hover_card.dart';

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
              ScrollReveal(
                child: Text(
                  'Why MV Manufacturing LLC?',
                  style: TextStyle(fontSize: r.heading1, fontWeight: FontWeight.bold, color: const Color(0xFF1a1a1a)),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: r.spacingM),
              ScrollReveal(
                child: Text(
                  'Precision machining with a personal touch — every job handled by the owner',
                  style: TextStyle(fontSize: r.body + 2, color: const Color(0xFF666666)),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: r.spacingXXL),
              Wrap(
                spacing: r.spacingL,
                runSpacing: r.spacingL,
                alignment: WrapAlignment.center,
                children: [
                  ScrollReveal.row(index: 0, staggerGroup: 'home_features', child: _buildFeatureCard(r, icon: Icons.precision_manufacturing, title: 'Precision Engineering', description: 'Tolerances down to ±0.0005" with state-of-the-art CNC equipment')),
                  ScrollReveal.row(index: 1, staggerGroup: 'home_features', child: _buildFeatureCard(r, icon: Icons.speed, title: 'Fast Turnaround', description: 'Quick quotes within 24 hours and rapid production times to keep your project moving')),
                  ScrollReveal.row(index: 2, staggerGroup: 'home_features', child: _buildFeatureCard(r, icon: Icons.person, title: 'Owner-Operated', description: 'Minh personally oversees every job — no handoffs, no shortcuts, just consistent quality')),
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
              ScrollReveal(
                child: Text('What We Do', style: TextStyle(fontSize: r.heading1, fontWeight: FontWeight.bold, color: const Color(0xFF1a1a1a)), textAlign: TextAlign.center),
              ),
              SizedBox(height: r.spacingM),
              ScrollReveal(
                child: Text('Full-service CNC machining from prototype to production run', style: TextStyle(fontSize: r.body + 2, color: const Color(0xFF666666)), textAlign: TextAlign.center),
              ),
              SizedBox(height: r.spacingXXL),
              Wrap(
                spacing: r.cardSpacing,
                runSpacing: r.cardSpacing,
                alignment: WrapAlignment.center,
                children: [
                  ScrollReveal.row(index: 0, staggerGroup: 'home_services', child: _buildServiceCard(r, imageIcon: Icons.settings, title: 'CNC Milling', description: '3-axis milling for complex parts and tight tolerances')),
                  ScrollReveal.row(index: 1, staggerGroup: 'home_services', child: _buildServiceCard(r, imageIcon: Icons.science, title: 'Rapid Prototyping', description: 'Fast single-piece and low-volume prototype runs')),
                  ScrollReveal.row(index: 2, staggerGroup: 'home_services', child: _buildServiceCard(r, imageIcon: Icons.factory, title: 'Production Runs', description: 'Consistent quality on repeat orders up to 1,000+ parts/month')),
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
              ScrollReveal(
                child: Text(
                  'Materials We Work With',
                  style: TextStyle(fontSize: r.heading1, fontWeight: FontWeight.bold, color: const Color(0xFF1a1a1a)),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: r.spacingXXL),
              Wrap(
                spacing: r.spacingL,
                runSpacing: r.spacingL,
                alignment: WrapAlignment.center,
                children: [
                  for (var i = 0; i < materials.length; i++)
                    ScrollReveal.row(
                      index: i % r.materialGridColumns,
                      child: _buildMaterialCard(r, materials[i]),
                    ),
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
            // Image
            AspectRatio(
              aspectRatio: 4 / 3,
              child: Image.asset(
                material.image,
                fit: BoxFit.cover,
              ),
            ),
            // Dark gradient overlay at bottom
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
            // Material name at bottom
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
              ScrollReveal(
                child: Text('Experience & Expertise', style: TextStyle(fontSize: r.heading1, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
              ),
              SizedBox(height: r.spacingXXL),
              r.isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: ScrollReveal.row(index: 0, staggerGroup: 'home_experience', child: _buildExperiencePoint(r, icon: Icons.calendar_today, title: '3+ Years', description: 'Minh has been machining professionally since before opening MV Manufacturing'))),
                        SizedBox(width: r.spacingXL),
                        Expanded(child: ScrollReveal.row(index: 1, staggerGroup: 'home_experience', child: _buildExperiencePoint(r, icon: Icons.person, title: 'Owner-Operated', description: 'Every part personally handled by Minh Vu — you deal directly with the machinist'))),
                        SizedBox(width: r.spacingXL),
                        Expanded(child: ScrollReveal.row(index: 2, staggerGroup: 'home_experience', child: _buildExperiencePoint(r, icon: Icons.build, title: '2 CNC Machines', description: 'Dedicated CNC turning and milling equipment for precision work'))),
                      ],
                    )
                  : Column(
                      children: [
                        ScrollReveal.column(index: 0, staggerGroup: 'home_experience', child: _buildExperiencePoint(r, icon: Icons.calendar_today, title: '3+ Years', description: 'Minh has been machining professionally since before opening MV Manufacturing')),
                        SizedBox(height: r.spacingXL),
                        ScrollReveal.column(index: 1, staggerGroup: 'home_experience', child: _buildExperiencePoint(r, icon: Icons.person, title: 'Owner-Operated', description: 'Every part personally handled by Minh Vu — you deal directly with the machinist')),
                        SizedBox(height: r.spacingXL),
                        ScrollReveal.column(index: 2, staggerGroup: 'home_experience', child: _buildExperiencePoint(r, icon: Icons.build, title: '2 CNC Machines', description: 'Dedicated CNC turning and milling equipment for precision work')),
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
          child: ScrollReveal(
            visibilityThreshold: 0.3,
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
          child: ScrollReveal(
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