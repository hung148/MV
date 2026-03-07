import 'package:flutter/material.dart';
import 'package:mv/widgets/contacts.dart';
import 'package:mv/widgets/responsive.dart';
import 'package:mv/widgets/quote_form.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});



  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeroSection(context),
          _buildStorySection(context),
          _buildMissionSection(context),
          _buildValuesSection(context),
          _buildTeamSection(context),
          _buildTimelineSection(context),
          _buildCTASection(context),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
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
              Text('About MV Machine Shop', style: TextStyle(fontSize: r.displayHeading, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
              SizedBox(height: r.spacingM),
              Text('Building precision parts and lasting partnerships since 1999', style: TextStyle(fontSize: r.heroSubHeading, color: Colors.white70), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStorySection(BuildContext context) {
    final r = Responsive.of(context);
    return Container(
      padding: r.sectionPadding,
      color: Colors.white,
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: r.maxProseWidth),
          child: Column(
            children: [
              Text('Our Story', style: TextStyle(fontSize: r.heading1, fontWeight: FontWeight.bold, color: const Color(0xFF1a1a1a))),
              SizedBox(height: r.spacingL),
              Text(
                'Founded in 1999 by master machinist Michael Vasquez, MV Machine Shop began in a modest 2,000 square foot facility with just three CNC machines and a vision for excellence. What started as a small job shop serving local manufacturers has grown into a full-service precision machining company trusted by aerospace, medical, and industrial clients nationwide.',
                style: TextStyle(fontSize: r.bodyProse, color: const Color(0xFF333333), height: 1.8),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: r.spacingM),
              Text(
                'Today, we operate from a 25,000 square foot facility housing state-of-the-art CNC equipment and employ over 50 skilled professionals. Our commitment to quality, innovation, and customer service remains as strong as it was on day one.',
                style: TextStyle(fontSize: r.bodyProse, color: const Color(0xFF333333), height: 1.8),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMissionSection(BuildContext context) {
    final r = Responsive.of(context);
    return Container(
      padding: r.sectionPadding,
      color: const Color(0xFF0d47a1),
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: r.maxMissionWidth),
          child: Column(
            children: [
              Text('Our Mission', style: TextStyle(fontSize: r.heading1, fontWeight: FontWeight.bold, color: Colors.white)),
              SizedBox(height: r.spacingL),
              Container(
                padding: EdgeInsets.all(r.isMobile ? 24 : 40),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(r.cardRadius),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 2),
                ),
                child: Text(
                  'To deliver precision machined components that exceed expectations through advanced technology, skilled craftsmanship, and unwavering commitment to quality. We strive to be more than a supplier—we aim to be a trusted manufacturing partner that helps our clients succeed.',
                  style: TextStyle(fontSize: r.missionQuoteFont, color: Colors.white, height: 1.8, fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildValuesSection(BuildContext context) {
    final r = Responsive.of(context);
    return Container(
      padding: r.sectionPadding,
      color: const Color(0xFFf5f5f5),
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: r.maxContentWidth),
          child: Column(
            children: [
              Text('Our Core Values', style: TextStyle(fontSize: r.heading1, fontWeight: FontWeight.bold, color: const Color(0xFF1a1a1a))),
              SizedBox(height: r.spacingXXL),
              Wrap(
                spacing: r.spacingL,
                runSpacing: r.spacingL,
                alignment: WrapAlignment.center,
                children: [
                  _buildValueCard(r, icon: Icons.stars, title: 'Quality First', description: 'We never compromise on quality. Every part is inspected to ensure it meets or exceeds specifications.'),
                  _buildValueCard(r, icon: Icons.handshake, title: 'Integrity', description: 'Honest communication, fair pricing, and transparent processes build trust with our clients.'),
                  _buildValueCard(r, icon: Icons.lightbulb, title: 'Innovation', description: 'Continuous investment in technology and training keeps us at the forefront of the industry.'),
                  _buildValueCard(r, icon: Icons.people, title: 'Teamwork', description: 'Our skilled team works collaboratively to solve challenges and deliver exceptional results.'),
                  _buildValueCard(r, icon: Icons.psychology, title: 'Customer Focus', description: 'Understanding and exceeding customer expectations drives everything we do.'),
                  _buildValueCard(r, icon: Icons.trending_up, title: 'Continuous Improvement', description: 'We constantly refine our processes and capabilities to better serve our customers.'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildValueCard(Responsive r, {required IconData icon, required String title, required String description}) {
    return Container(
      width: r.valueCardWidth,
      padding: EdgeInsets.all(r.cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(r.cardRadius),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(r.spacingM),
            decoration: BoxDecoration(color: const Color(0xFF0d47a1).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(50)),
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

  Widget _buildTeamSection(BuildContext context) {
    final r = Responsive.of(context);
    return Container(
      padding: r.sectionPadding,
      color: Colors.white,
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: r.maxContentWidth),
          child: Column(
            children: [
              Text('Leadership Team', style: TextStyle(fontSize: r.heading1, fontWeight: FontWeight.bold, color: const Color(0xFF1a1a1a))),
              SizedBox(height: r.spacingXXL),
              Wrap(
                spacing: r.spacingXL,
                runSpacing: r.spacingXL,
                alignment: WrapAlignment.center,
                children: [
                  _buildTeamMember(r, name: 'Michael Vasquez', title: 'Founder & CEO', description: 'Master machinist with 35+ years of experience. Leads strategic vision and client relationships.'),
                  _buildTeamMember(r, name: 'Sarah Chen', title: 'VP of Operations', description: 'Aerospace engineer overseeing production, quality control, and continuous improvement initiatives.'),
                  _buildTeamMember(r, name: 'Robert Martinez', title: 'Director of Engineering', description: 'CAD/CAM expert managing programming team and technical customer support.'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamMember(Responsive r, {required String name, required String title, required String description}) {
    return SizedBox(
      width: r.teamCardWidth,
      child: Column(
        children: [
          Container(
            width: r.teamAvatarSize,
            height: r.teamAvatarSize,
            decoration: BoxDecoration(
              color: const Color(0xFF0d47a1).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(r.teamAvatarSize / 2),
            ),
            child: Center(child: Icon(Icons.person, size: r.teamAvatarIcon, color: const Color(0xFF0d47a1))),
          ),
          SizedBox(height: r.spacingM),
          Text(name, style: TextStyle(fontSize: r.heading3, fontWeight: FontWeight.bold, color: const Color(0xFF1a1a1a)), textAlign: TextAlign.center),
          SizedBox(height: r.spacingXS),
          Text(title, style: TextStyle(fontSize: r.body, color: const Color(0xFF0d47a1), fontWeight: FontWeight.w600), textAlign: TextAlign.center),
          SizedBox(height: r.spacingS),
          Text(description, style: TextStyle(fontSize: r.body, color: const Color(0xFF666666), height: 1.5), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildTimelineSection(BuildContext context) {
    final r = Responsive.of(context);
    return Container(
      padding: r.sectionPadding,
      color: const Color(0xFFf5f5f5),
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: r.maxProseWidth),
          child: Column(
            children: [
              Text('Our Journey', style: TextStyle(fontSize: r.heading1, fontWeight: FontWeight.bold, color: const Color(0xFF1a1a1a))),
              SizedBox(height: r.spacingXXL),
              _buildTimelineItem(r, '1999', 'Founded', 'MV Machine Shop established with 3 CNC machines'),
              _buildTimelineItem(r, '2005', 'ISO 9001', 'Achieved ISO 9001 certification'),
              _buildTimelineItem(r, '2010', 'Facility Expansion', 'Moved to 15,000 sq ft facility'),
              _buildTimelineItem(r, '2015', 'AS9100 Certified', 'Entered aerospace market with AS9100D'),
              _buildTimelineItem(r, '2020', 'Major Growth', 'Expanded to 25,000 sq ft, added 5-axis capabilities'),
              _buildTimelineItem(r, '2024', 'Medical Certification', 'Achieved ISO 13485 for medical device manufacturing'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineItem(Responsive r, String year, String title, String description) {
    return Padding(
      padding: EdgeInsets.only(bottom: r.timelineItemSpacing),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: r.timelineYearWidth,
            child: Text(year, style: TextStyle(fontSize: r.timelineYearFont, fontWeight: FontWeight.bold, color: const Color(0xFF0d47a1))),
          ),
          SizedBox(width: r.spacingM),
          Container(width: 3, height: r.timelineBarHeight, color: const Color(0xFF0d47a1).withValues(alpha: 0.3)),
          SizedBox(width: r.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: r.heading3, fontWeight: FontWeight.bold, color: const Color(0xFF1a1a1a))),
                SizedBox(height: r.spacingXS),
                Text(description, style: TextStyle(fontSize: r.body, color: const Color(0xFF666666), height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCTASection(BuildContext context) {
    final r = Responsive.of(context);
    return Container(
      padding: r.sectionPadding,
      color: const Color(0xFF0d47a1),
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: r.maxNarrowWidth),
          child: Column(
            children: [
              Text('Join Our Growing List of Partners', style: TextStyle(fontSize: r.heading1, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
              SizedBox(height: r.spacingM),
              Text('Experience the MV Machine Shop difference', style: TextStyle(fontSize: r.body + 2, color: Colors.white70), textAlign: TextAlign.center),
              SizedBox(height: r.spacingL),
              ElevatedButton(
                onPressed: () => showQuoteDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF0d47a1),
                  padding: r.primaryButtonPadding,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                child: Text('Contact Us Today', style: TextStyle(fontSize: r.buttonText, fontWeight: FontWeight.bold)),
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
              const Divider(color: Color(0xFF333333)),
              SizedBox(height: r.spacingM),
              Text('© ${DateTime.now().year} ${CompanyContact.name}. All rights reserved.', style: TextStyle(color: const Color(0xFF999999), fontSize: r.caption + 1), textAlign: TextAlign.center),
              SizedBox(height: r.spacingXS),
              Text('${CompanyContact.fullAddress} | ${CompanyContact.phone}', style: TextStyle(color: const Color(0xFF666666), fontSize: r.caption), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}