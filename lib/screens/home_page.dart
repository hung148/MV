import 'package:flutter/material.dart';
import 'package:mv/widgets/responsive.dart';
import 'package:mv/widgets/quote_form.dart';
import 'package:mv/widgets/fade_in_section.dart';
import 'package:mv/widgets/scroll_reveal.dart';
import 'package:go_router/go_router.dart';
import 'package:mv/widgets/footer.dart';

class HomePageContent extends StatelessWidget {
  const HomePageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeroSection(context),
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

  Widget _buildHeroSection(BuildContext context) {
    final r = Responsive.of(context);
    return Container(
      height: r.heroHeight,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0d47a1), Color(0xFF1976d2), Color(0xFF42a5f5)],
        ),
      ),
      child: Stack(
        children: [
          Container(
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
          Center(
            child: FadeInSection(
              child: Container(
                padding: r.pagePadding,
                constraints: BoxConstraints(maxWidth: r.maxContentWidth),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Precision CNC Manufacturing',
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
                      'Your trusted partner for high-quality machining solutions',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: r.bodyLarge,
                        fontWeight: FontWeight.w300,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: r.spacingM),
                    Text(
                      'From prototype to production — owner-operated, personally inspected, every part.',
                      style: TextStyle(color: const Color(0xFFE3F2FD), fontSize: r.body + 2),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: r.spacingXL),
                    Wrap(
                      spacing: r.spacingM,
                      runSpacing: r.spacingM,
                      alignment: WrapAlignment.center,
                      children: [
                        ElevatedButton(
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
                        OutlinedButton(
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
                      ],
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
                delay: const Duration(milliseconds: 80),
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
                  ScrollReveal.row(index: 0, child: _buildFeatureCard(r, icon: Icons.precision_manufacturing, title: 'Precision Engineering', description: 'Tolerances down to ±0.0005" with state-of-the-art CNC equipment')),
                  ScrollReveal.row(index: 1, child: _buildFeatureCard(r, icon: Icons.speed, title: 'Fast Turnaround', description: 'Quick quotes within 24 hours and rapid production times to keep your project moving')),
                  ScrollReveal.row(index: 2, child: _buildFeatureCard(r, icon: Icons.person, title: 'Owner-Operated', description: 'Minh personally oversees every job — no handoffs, no shortcuts, just consistent quality')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(Responsive r, {required IconData icon, required String title, required String description}) {
    return Container(
      width: r.featureCardWidth,
      padding: EdgeInsets.all(r.cardPadding),
      decoration: BoxDecoration(
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
                delay: const Duration(milliseconds: 80),
                child: Text('Full-service CNC machining from prototype to production run', style: TextStyle(fontSize: r.body + 2, color: const Color(0xFF666666)), textAlign: TextAlign.center),
              ),
              SizedBox(height: r.spacingXXL),
              Wrap(
                spacing: r.cardSpacing,
                runSpacing: r.cardSpacing,
                alignment: WrapAlignment.center,
                children: [
                  ScrollReveal.row(index: 0, child: _buildServiceCard(r, imageIcon: Icons.settings, title: 'CNC Milling', description: '3-axis milling for complex parts and tight tolerances')),
                  ScrollReveal.row(index: 1, child: _buildServiceCard(r, imageIcon: Icons.science, title: 'Rapid Prototyping', description: 'Fast single-piece and low-volume prototype runs')),
                  ScrollReveal.row(index: 2, child: _buildServiceCard(r, imageIcon: Icons.factory, title: 'Production Runs', description: 'Consistent quality on repeat orders up to 1,000+ parts/month')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard(Responsive r, {required IconData imageIcon, required String title, required String description}) {
    return Container(
      width: r.serviceCardWidth,
      height: r.serviceCardHeight,
      padding: EdgeInsets.all(r.cardPadding),
      decoration: BoxDecoration(
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
    final materials = ['Aluminum', 'Stainless Steel', 'Titanium', 'Brass', 'Copper', 'Plastics'];
    return Container(
      padding: r.sectionPadding,
      color: Colors.white,
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: r.maxContentWidth),
          child: Column(
            children: [
              ScrollReveal(
                child: Text('Materials We Work With', style: TextStyle(fontSize: r.heading1, fontWeight: FontWeight.bold, color: const Color(0xFF1a1a1a)), textAlign: TextAlign.center),
              ),
              SizedBox(height: r.spacingXXL),
              GridView.count(
                crossAxisCount: r.materialGridColumns,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: r.spacingL,
                mainAxisSpacing: r.spacingL,
                childAspectRatio: r.materialChipAspectRatio,
                children: [
                  for (var i = 0; i < materials.length; i++)
                    ScrollReveal.row(index: i, child: _buildMaterialChip(r, materials[i])),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMaterialChip(Responsive r, String material) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: r.spacingM, horizontal: r.spacingL),
      decoration: BoxDecoration(
        color: const Color(0xFFf5f5f5),
        borderRadius: BorderRadius.circular(r.cardRadius),
        border: Border.all(color: const Color(0xFFe0e0e0)),
      ),
      child: Center(
        child: Text(material, style: TextStyle(fontSize: r.body + 2, fontWeight: FontWeight.w600, color: const Color(0xFF1a1a1a))),
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
                        Expanded(child: ScrollReveal.row(index: 0, child: _buildExperiencePoint(r, icon: Icons.calendar_today, title: '3+ Years', description: 'Minh has been machining professionally since before opening MV Manufacturing'))),
                        SizedBox(width: r.spacingXL),
                        Expanded(child: ScrollReveal.row(index: 1, child: _buildExperiencePoint(r, icon: Icons.person, title: 'Owner-Operated', description: 'Every part personally handled by Minh Vu — you deal directly with the machinist'))),
                        SizedBox(width: r.spacingXL),
                        Expanded(child: ScrollReveal.row(index: 2, child: _buildExperiencePoint(r, icon: Icons.build, title: '2 CNC Machines', description: 'Dedicated CNC turning and milling equipment for precision work'))),
                      ],
                    )
                  : Column(
                      children: [
                        ScrollReveal.column(index: 0, child: _buildExperiencePoint(r, icon: Icons.calendar_today, title: '3+ Years', description: 'Minh has been machining professionally since before opening MV Manufacturing')),
                        SizedBox(height: r.spacingXL),
                        ScrollReveal.column(index: 1, child: _buildExperiencePoint(r, icon: Icons.person, title: 'Owner-Operated', description: 'Every part personally handled by Minh Vu — you deal directly with the machinist')),
                        SizedBox(height: r.spacingXL),
                        ScrollReveal.column(index: 2, child: _buildExperiencePoint(r, icon: Icons.build, title: '2 CNC Machines', description: 'Dedicated CNC turning and milling equipment for precision work')),
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
                ElevatedButton(
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
