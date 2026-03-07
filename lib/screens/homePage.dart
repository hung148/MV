import 'package:flutter/material.dart';
import 'package:mv/widgets/contacts.dart';
import 'package:mv/widgets/responsive.dart';
import 'package:mv/widgets/quote_form.dart';

// Renamed from HomePage to HomePageContent.
// No Scaffold or CustomNavigationBar — AppShell in main.dart handles both.
class HomePageContent extends StatelessWidget {
  const HomePageContent({super.key});



  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeroSection(context),
          _buildFeaturesSection(context),
          _buildServicesSection(context),
          _buildCapabilitiesSection(context),
          _buildWhyChooseUsSection(context),
          _buildStatsSection(context),
          _buildCTASection(context),
          _buildFooter(context),
        ],
      ),
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
                    'From prototype to production, we deliver excellence in every part',
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
                        onPressed: () {},
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
              Text(
                'Why MV Machine Shop?',
                style: TextStyle(fontSize: r.heading1, fontWeight: FontWeight.bold, color: const Color(0xFF1a1a1a)),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: r.spacingM),
              Text(
                'Industry-leading precision and reliability',
                style: TextStyle(fontSize: r.body + 2, color: const Color(0xFF666666)),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: r.spacingXXL),
              Wrap(
                spacing: r.spacingL,
                runSpacing: r.spacingL,
                alignment: WrapAlignment.center,
                children: [
                  _buildFeatureCard(r, icon: Icons.precision_manufacturing, title: 'Precision Engineering', description: 'Tolerances down to ±0.0005" with state-of-the-art CNC equipment'),
                  _buildFeatureCard(r, icon: Icons.speed, title: 'Fast Turnaround', description: 'Quick quotes within 24 hours and rapid production times'),
                  _buildFeatureCard(r, icon: Icons.verified, title: 'Quality Assured', description: 'ISO 9001 certified processes and rigorous inspection standards'),
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
              color: const Color(0xFF0d47a1).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(icon, size: r.iconHero, color: const Color(0xFF0d47a1)),
          ),
          SizedBox(height: r.spacingL),
          Text(title, style: TextStyle(fontSize: r.heading3, fontWeight: FontWeight.bold, color: const Color(0xFF1a1a1a)), textAlign: TextAlign.center),
          SizedBox(height: r.spacingS),
          Text(description, style: TextStyle(fontSize: r.body, color: const Color(0xFF666666), height: 1.5), textAlign: TextAlign.center),
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
              Text('Our Services', style: TextStyle(fontSize: r.heading1, fontWeight: FontWeight.bold, color: const Color(0xFF1a1a1a)), textAlign: TextAlign.center),
              SizedBox(height: r.spacingM),
              Text('Comprehensive machining solutions for every need', style: TextStyle(fontSize: r.body + 2, color: const Color(0xFF666666)), textAlign: TextAlign.center),
              SizedBox(height: r.spacingXXL),
              Wrap(
                spacing: r.cardSpacing,
                runSpacing: r.cardSpacing,
                alignment: WrapAlignment.center,
                children: [
                  _buildServiceCard(r, title: 'CNC Milling', description: '3-axis and 5-axis milling for complex geometries', imageIcon: Icons.settings),
                  _buildServiceCard(r, title: 'CNC Turning', description: 'High-precision turning for cylindrical components', imageIcon: Icons.rotate_right),
                  _buildServiceCard(r, title: 'Prototyping', description: 'Rapid prototyping from concept to finished part', imageIcon: Icons.science),
                  _buildServiceCard(r, title: 'Production Runs', description: 'Low to high volume manufacturing capabilities', imageIcon: Icons.factory),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard(Responsive r, {required String title, required String description, required IconData imageIcon}) {
    return Container(
      width: r.serviceCardWidth,
      padding: EdgeInsets.all(r.cardPadding - 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(r.cardRadius),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4))],
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
    return Container(
      padding: r.sectionPadding,
      color: Colors.white,
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: r.maxContentWidth),
          child: Column(
            children: [
              Text('Materials We Work With', style: TextStyle(fontSize: r.heading1, fontWeight: FontWeight.bold, color: const Color(0xFF1a1a1a)), textAlign: TextAlign.center),
              SizedBox(height: r.spacingXXL),
              GridView.count(
                crossAxisCount: r.materialGridColumns,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: r.spacingL,
                mainAxisSpacing: r.spacingL,
                childAspectRatio: r.materialChipAspectRatio,
                children: [
                  _buildMaterialChip(r, 'Aluminum'),
                  _buildMaterialChip(r, 'Stainless Steel'),
                  _buildMaterialChip(r, 'Titanium'),
                  _buildMaterialChip(r, 'Brass'),
                  _buildMaterialChip(r, 'Copper'),
                  _buildMaterialChip(r, 'Plastics'),
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
              Text('Experience & Expertise', style: TextStyle(fontSize: r.heading1, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
              SizedBox(height: r.spacingXXL),
              r.isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildExperiencePoint(r, icon: Icons.calendar_today, title: '25+ Years', description: 'Of industry experience and continuous improvement')),
                        SizedBox(width: r.spacingXL),
                        Expanded(child: _buildExperiencePoint(r, icon: Icons.people, title: 'Expert Team', description: 'Certified machinists and quality control specialists')),
                        SizedBox(width: r.spacingXL),
                        Expanded(child: _buildExperiencePoint(r, icon: Icons.build, title: 'Advanced Equipment', description: 'Latest CNC machines and measurement tools')),
                      ],
                    )
                  : Column(
                      children: [
                        _buildExperiencePoint(r, icon: Icons.calendar_today, title: '25+ Years', description: 'Of industry experience and continuous improvement'),
                        SizedBox(height: r.spacingXL),
                        _buildExperiencePoint(r, icon: Icons.people, title: 'Expert Team', description: 'Certified machinists and quality control specialists'),
                        SizedBox(height: r.spacingXL),
                        _buildExperiencePoint(r, icon: Icons.build, title: 'Advanced Equipment', description: 'Latest CNC machines and measurement tools'),
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
                    _buildStatItem(r, '10,000+', 'Parts Manufactured'),
                    _buildStatItem(r, '500+', 'Satisfied Clients'),
                    _buildStatItem(r, '99.8%', 'Quality Rate'),
                    _buildStatItem(r, '24hr', 'Quote Turnaround'),
                  ],
                )
              : Wrap(
                  spacing: r.spacingXL,
                  runSpacing: r.spacingXL,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildStatItem(r, '10,000+', 'Parts Manufactured'),
                    _buildStatItem(r, '500+', 'Satisfied Clients'),
                    _buildStatItem(r, '99.8%', 'Quality Rate'),
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
        Text(number, style: TextStyle(fontSize: r.statNumber, fontWeight: FontWeight.bold, color: const Color(0xFF0066cc))),
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
              Text('Contact us today for a free quote on your next project', style: TextStyle(fontSize: r.body + 2, color: const Color(0xFF666666)), textAlign: TextAlign.center),
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
    );
  }

  Widget _buildFooter(BuildContext context) {
    final r = Responsive.of(context);
    return Container(
      padding: EdgeInsets.symmetric(vertical: r.footerPaddingVertical, horizontal: 24),
      color: const Color(0xFF1a1a1a),
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: r.maxContentWidth),
          child: Column(
            children: [
              r.isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildFooterSection1(r)),
                        SizedBox(width: r.spacingXL),
                        Expanded(child: _buildFooterSection2(context, r)),
                        SizedBox(width: r.spacingXL),
                        Expanded(child: _buildFooterSection3(r)),
                      ],
                    )
                  : Column(
                      children: [
                        _buildFooterSection1(r),
                        SizedBox(height: r.spacingL),
                        _buildFooterSection2(context, r),
                        SizedBox(height: r.spacingL),
                        _buildFooterSection3(r),
                      ],
                    ),
              SizedBox(height: r.spacingXL),
              const Divider(color: Color(0xFF333333)),
              SizedBox(height: r.spacingM),
              Text(
                '© ${DateTime.now().year} ${CompanyContact.name}. All rights reserved.',
                style: TextStyle(color: const Color(0xFF999999), fontSize: r.caption),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooterSection1(Responsive r) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(CompanyContact.name, style: TextStyle(color: Colors.white, fontSize: r.body + 4, fontWeight: FontWeight.bold)),
        SizedBox(height: r.spacingXS),
        Text(CompanyContact.tagline, style: TextStyle(color: const Color(0xFF0066cc), fontSize: r.caption + 1, fontWeight: FontWeight.w500)),
        SizedBox(height: r.spacingM),
        Text('Precision CNC machining and manufacturing solutions for industries worldwide.', style: TextStyle(color: const Color(0xFF999999), fontSize: r.caption + 1, height: 1.5)),
      ],
    );
  }

  Widget _buildFooterSection2(BuildContext context, Responsive r) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Links', style: TextStyle(color: Colors.white, fontSize: r.body, fontWeight: FontWeight.bold)),
        SizedBox(height: r.spacingM),
        _buildFooterLink(context, r, 'Services', '/services'),
        _buildFooterLink(context, r, 'Capabilities', '/capabilities'),
        _buildFooterLink(context, r, 'About Us', '/about'),
        _buildFooterLink(context, r, 'Gallery', '/gallery'),
      ],
    );
  }

  Widget _buildFooterSection3(Responsive r) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Contact Info', style: TextStyle(color: Colors.white, fontSize: r.body, fontWeight: FontWeight.bold)),
        SizedBox(height: r.spacingM),
        _buildFooterInfo(r, Icons.location_on_outlined, CompanyContact.fullAddress),
        _buildFooterInfo(r, Icons.phone_outlined, CompanyContact.phone),
        _buildFooterInfo(r, Icons.email_outlined, CompanyContact.email),
        _buildFooterInfo(r, Icons.schedule_outlined, 'Mon-Fri: ${CompanyContact.operatingHours["Monday - Friday"]}'),
      ],
    );
  }

  Widget _buildFooterLink(BuildContext context, Responsive r, String text, String route) {
    return Padding(
      padding: EdgeInsets.only(bottom: r.spacingXS),
      child: InkWell(
        onTap: () => Navigator.of(context, rootNavigator: false).pushNamed(route),
        child: Text(text, style: TextStyle(color: const Color(0xFF999999), fontSize: r.caption + 1)),
      ),
    );
  }

  Widget _buildFooterInfo(Responsive r, IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: r.spacingXS),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF0066cc), size: r.iconSmall),
          SizedBox(width: r.spacingXS),
          Expanded(child: Text(text, style: TextStyle(color: const Color(0xFF999999), fontSize: r.caption + 1))),
        ],
      ),
    );
  }
}