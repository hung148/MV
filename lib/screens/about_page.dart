import 'package:flutter/material.dart';
import 'package:mv/widgets/fade_in_section.dart';
import 'package:mv/widgets/responsive.dart';
import 'package:mv/widgets/quote_form.dart';
import 'package:mv/widgets/footer.dart';
import 'package:mv/widgets/scroll_reveal.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FadeInSection(child: _buildHeroSection(context)),
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
              Text('About MV Manufacturing LLC', style: TextStyle(fontSize: r.displayHeading, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
              SizedBox(height: r.spacingM),
              Text('Building precision parts and lasting partnerships since 2025', style: TextStyle(fontSize: r.heroSubHeading, color: Colors.white70), textAlign: TextAlign.center),
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
              ScrollReveal(
                child: Text('Our Story', style: TextStyle(fontSize: r.heading1, fontWeight: FontWeight.bold, color: const Color(0xFF1a1a1a))),
              ),
              SizedBox(height: r.spacingL),
              ScrollReveal(
                delay: const Duration(milliseconds: 80),
                child: Text(
                  'Founded in 2025 by master machinist Minh Vu, MV Manufacturing LLC began in a modest 1,300 square foot facility with just one CNC machine and a vision for excellence. What started as a small job shop serving local manufacturers has grown into a full-service precision machining company trusted by aerospace, medical, and industrial clients nationwide.',
                  style: TextStyle(fontSize: r.bodyProse, color: const Color(0xFF333333), height: 1.8),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: r.spacingM),
              ScrollReveal(
                delay: const Duration(milliseconds: 160),
                child: Text(
                  'Today, we operate from our facility with two CNC machines, with Minh hands-on at every step. Our commitment to quality, innovation, and customer service remains as strong as it was on day one.',
                  style: TextStyle(fontSize: r.bodyProse, color: const Color(0xFF333333), height: 1.8),
                  textAlign: TextAlign.center,
                ),
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
              ScrollReveal(
                child: Text('Our Mission', style: TextStyle(fontSize: r.heading1, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              SizedBox(height: r.spacingL),
              ScrollReveal(
                delay: const Duration(milliseconds: 80),
                child: Container(
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
              ScrollReveal(
                child: Text('Our Core Values', style: TextStyle(fontSize: r.heading1, fontWeight: FontWeight.bold, color: const Color(0xFF1a1a1a))),
              ),
              SizedBox(height: r.spacingXXL),
              Wrap(
                spacing: r.spacingL,
                runSpacing: r.spacingL,
                alignment: WrapAlignment.center,
                children: [
                  ScrollReveal.row(index: 0, child: _buildValueCard(r, icon: Icons.stars, title: 'Quality First', description: 'We never compromise on quality. Every part is inspected to ensure it meets or exceeds specifications.')),
                  ScrollReveal.row(index: 1, child: _buildValueCard(r, icon: Icons.handshake, title: 'Integrity', description: 'Honest communication, fair pricing, and transparent processes build trust with our clients.')),
                  ScrollReveal.row(index: 2, child: _buildValueCard(r, icon: Icons.lightbulb, title: 'Innovation', description: 'Continuous investment in technology and training keeps us at the forefront of the industry.')),
                  ScrollReveal.row(index: 3, child: _buildValueCard(r, icon: Icons.people, title: 'Teamwork', description: 'Our skilled team works collaboratively to solve challenges and deliver exceptional results.')),
                  ScrollReveal.row(index: 4, child: _buildValueCard(r, icon: Icons.psychology, title: 'Customer Focus', description: 'Understanding and exceeding customer expectations drives everything we do.')),
                  ScrollReveal.row(index: 5, child: _buildValueCard(r, icon: Icons.trending_up, title: 'Continuous Improvement', description: 'We constantly refine our processes and capabilities to better serve our customers.')),
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
              ScrollReveal(
                child: Text('Leadership Team', style: TextStyle(fontSize: r.heading1, fontWeight: FontWeight.bold, color: const Color(0xFF1a1a1a))),
              ),
              SizedBox(height: r.spacingXXL),
              Wrap(
                spacing: r.spacingXL,
                runSpacing: r.spacingXL,
                alignment: WrapAlignment.center,
                children: [
                  ScrollReveal.row(index: 0, child: _buildTeamMember(r, name: 'Minh Vu', title: 'Founder & Owner', description: 'Master machinist and sole operator, personally handling every job from start to finish.')),
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
              ScrollReveal(
                child: Text('Our Journey', style: TextStyle(fontSize: r.heading1, fontWeight: FontWeight.bold, color: const Color(0xFF1a1a1a))),
              ),
              SizedBox(height: r.spacingXXL),
              ScrollReveal.column(index: 0, child: _buildTimelineItem(r, '2025', 'Founded', 'MV Manufacturing LLC established with 1 CNC machine in a 1,300 sq ft facility')),
              ScrollReveal.column(index: 1, child: _buildTimelineItem(r, '2026', 'Growing', 'Added a second CNC machine, continuing to build client relationships')),
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
          child: ScrollReveal(
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
      ),
    );
  }
}
