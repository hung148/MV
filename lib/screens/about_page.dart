import 'package:flutter/material.dart';
import 'package:mv/widgets/fade_in_section.dart';
import 'package:mv/widgets/page_hero.dart';
import 'package:mv/widgets/responsive.dart';
import 'package:mv/widgets/quote_form.dart';
import 'package:mv/widgets/footer.dart';
import 'package:mv/widgets/hover_lift.dart';
import 'package:mv/widgets/hover_card.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FadeInSection(
          child: PageHero(
            title: 'About MV Manufacturing LLC',
            subtitle: 'Family-owned craftsmanship, dependable quality, and personalized CNC machining services.',
          ),
        ),
        _buildStorySection(context),
        _buildMissionSection(context),
        _buildValuesSection(context),
        _buildTeamSection(context),
        _buildTimelineSection(context),
        _buildCTASection(context),
        const AppFooter(),
      ],
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
                'Founded in 2025 by machinist Minh Vu, MV Manufacturing LLC was built on a simple goal: deliver precision CNC machining with honest communication, dependable service, and exceptional craftsmanship. Operating from a 1,300-square-foot shop, every project is personally overseen from start to finish.',
                style: TextStyle(fontSize: r.bodyProse, color: const Color(0xFF333333), height: 1.8),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: r.spacingM),
              Text(
                'Whether producing prototypes, custom components, or small production runs, we focus on precision, consistent quality, and reliable turnaround times. Every part is carefully machined and inspected before it leaves our shop, ensuring our customers receive products they can trust.',
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
                  _buildValueCard(r, icon: Icons.trending_up, title: 'Continuous Improvement', description: 'We constantly improve our equipment, processes, and skills to better serve our customers.'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildValueCard(Responsive r, {required IconData icon, required String title, required String description}) {
    return HoverCard(
      width: r.valueCardWidth,
      padding: EdgeInsets.all(r.cardPadding),
      baseDecoration: BoxDecoration(
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
                  _buildTeamMember(r, name: 'Minh Vu', title: 'Founder & Owner', description: 'Minh founded MV Manufacturing LLC with a passion for precision machining and quality craftsmanship. He personally manages every stage of production—from programming and machining to final inspection—ensuring every customer receives consistent quality and direct communication.'),
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
              _buildTimelineItem(r, '2025', 'Company Founded', 'Started MV Manufacturing LLC with one CNC machine and a commitment to precision machining and dependable customer service.'),
              _buildTimelineItem(r, '2026', 'Expanded Capabilities', 'Added a second CNC machine to increase production capacity'),
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
              Text('Ready to Start Your Project?', style: TextStyle(fontSize: r.heading1, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
              SizedBox(height: r.spacingM),
              Text('Whether you need prototypes, custom components, or production machining, we are ready to help bring your ideas to life', style: TextStyle(fontSize: r.body + 2, color: Colors.white70), textAlign: TextAlign.center),
              SizedBox(height: r.spacingL),
              HoverLift(
                liftPx: 3,
                addShadow: true,
                borderRadius: 4,
                child: ElevatedButton(
                  onPressed: () => showQuoteDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF0d47a1),
                    padding: r.primaryButtonPadding,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  child: Text('Contact Us Today', style: TextStyle(fontSize: r.buttonText, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}