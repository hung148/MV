import 'package:flutter/material.dart';
import 'package:mv/widgets/contacts.dart';
import 'package:mv/widgets/styles.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  void _showQuoteForm(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(32),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Request a Quote', style: ShopStyles.heading),
                  const SizedBox(height: 8),
                  Text('Submit your requirements or contact us directly at ${CompanyContact.phone}', style: ShopStyles.body),
                  const Divider(height: 40),
                  _buildTextField('Full Name', Icons.person_outline, maxLength: 50, validator: (v) => (v == null || v.isEmpty) ? 'Please enter your name' : null),
                  const SizedBox(height: 16),
                  _buildTextField('Email Address', Icons.email_outlined, maxLength: 100, validator: (v) {
                    if (v == null || v.isEmpty) return 'Please enter your email';
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) return 'Please enter a valid email address';
                    return null;
                  }),
                  const SizedBox(height: 16),
                  _buildTextField('Project Details', Icons.description_outlined, maxLines: 4, maxLength: 1000, validator: (v) {
                    if (v == null || v.isEmpty) return 'Please describe your project';
                    if (v.length < 10) return 'Please provide more details (min 10 chars)';
                    return null;
                  }),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Inquiry sent successfully!'), backgroundColor: Colors.green));
                        }
                      },
                      style: ShopStyles.primaryButton,
                      child: const Text('Send Inquiry'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, {int maxLines = 1, String? Function(String?)? validator, int? maxLength}) {
    return TextFormField(
      maxLines: maxLines, maxLength: maxLength, validator: validator,
      decoration: InputDecoration(
        counterText: "", labelText: label, prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF0066cc), width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.red, width: 1)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // No Scaffold or CustomNavigationBar — AppShell handles both
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeroSection(),
          _buildStorySection(),
          _buildMissionSection(),
          _buildValuesSection(),
          _buildTeamSection(),
          _buildTimelineSection(),
          _buildCTASection(context),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 24),
      decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF0d47a1), Color(0xFF1976d2)])),
      child: Center(child: Container(constraints: const BoxConstraints(maxWidth: 1200), child: const Column(children: [
        Text('About MV Machine Shop', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
        SizedBox(height: 16),
        Text('Building precision parts and lasting partnerships since 1999', style: TextStyle(fontSize: 20, color: Colors.white70), textAlign: TextAlign.center),
      ]))),
    );
  }

  Widget _buildStorySection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      color: Colors.white,
      child: Center(child: Container(constraints: const BoxConstraints(maxWidth: 900), child: const Column(children: [
        Text('Our Story', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF1a1a1a))),
        SizedBox(height: 32),
        Text('Founded in 1999 by master machinist Michael Vasquez, MV Machine Shop began in a modest 2,000 square foot facility with just three CNC machines and a vision for excellence. What started as a small job shop serving local manufacturers has grown into a full-service precision machining company trusted by aerospace, medical, and industrial clients nationwide.', style: TextStyle(fontSize: 18, color: Color(0xFF333333), height: 1.8), textAlign: TextAlign.center),
        SizedBox(height: 24),
        Text('Today, we operate from a 25,000 square foot facility housing state-of-the-art CNC equipment and employ over 50 skilled professionals. Our commitment to quality, innovation, and customer service remains as strong as it was on day one.', style: TextStyle(fontSize: 18, color: Color(0xFF333333), height: 1.8), textAlign: TextAlign.center),
      ]))),
    );
  }

  Widget _buildMissionSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      color: const Color(0xFF0d47a1),
      child: Center(child: Container(constraints: const BoxConstraints(maxWidth: 1000), child: Column(children: [
        const Text('Our Mission', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 2)),
          child: const Text('To deliver precision machined components that exceed expectations through advanced technology, skilled craftsmanship, and unwavering commitment to quality. We strive to be more than a supplier—we aim to be a trusted manufacturing partner that helps our clients succeed.', style: TextStyle(fontSize: 20, color: Colors.white, height: 1.8, fontStyle: FontStyle.italic), textAlign: TextAlign.center),
        ),
      ]))),
    );
  }

  Widget _buildValuesSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      color: const Color(0xFFf5f5f5),
      child: Center(child: Container(constraints: const BoxConstraints(maxWidth: 1200), child: Column(children: [
        const Text('Our Core Values', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF1a1a1a))),
        const SizedBox(height: 60),
        LayoutBuilder(builder: (context, constraints) {
          final isWide = constraints.maxWidth > 900;
          return Wrap(spacing: 32, runSpacing: 32, alignment: WrapAlignment.center, children: [
            _buildValueCard(icon: Icons.stars, title: 'Quality First', description: 'We never compromise on quality. Every part is inspected to ensure it meets or exceeds specifications.', width: isWide ? 350 : double.infinity),
            _buildValueCard(icon: Icons.handshake, title: 'Integrity', description: 'Honest communication, fair pricing, and transparent processes build trust with our clients.', width: isWide ? 350 : double.infinity),
            _buildValueCard(icon: Icons.lightbulb, title: 'Innovation', description: 'Continuous investment in technology and training keeps us at the forefront of the industry.', width: isWide ? 350 : double.infinity),
            _buildValueCard(icon: Icons.people, title: 'Teamwork', description: 'Our skilled team works collaboratively to solve challenges and deliver exceptional results.', width: isWide ? 350 : double.infinity),
            _buildValueCard(icon: Icons.psychology, title: 'Customer Focus', description: 'Understanding and exceeding customer expectations drives everything we do.', width: isWide ? 350 : double.infinity),
            _buildValueCard(icon: Icons.trending_up, title: 'Continuous Improvement', description: 'We constantly refine our processes and capabilities to better serve our customers.', width: isWide ? 350 : double.infinity),
          ]);
        }),
      ]))),
    );
  }

  Widget _buildValueCard({required IconData icon, required String title, required String description, double? width}) {
    return Container(
      width: width, padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(children: [
        Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF0d47a1).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(50)), child: Icon(icon, size: 40, color: const Color(0xFF0d47a1))),
        const SizedBox(height: 20),
        Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1a1a1a)), textAlign: TextAlign.center),
        const SizedBox(height: 12),
        Text(description, style: const TextStyle(fontSize: 15, color: Color(0xFF666666), height: 1.6), textAlign: TextAlign.center),
      ]),
    );
  }

  Widget _buildTeamSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      color: Colors.white,
      child: Center(child: Container(constraints: const BoxConstraints(maxWidth: 1200), child: Column(children: [
        const Text('Leadership Team', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF1a1a1a))),
        const SizedBox(height: 60),
        LayoutBuilder(builder: (context, constraints) {
          final isWide = constraints.maxWidth > 768;
          return Wrap(spacing: 40, runSpacing: 40, alignment: WrapAlignment.center, children: [
            _buildTeamMember(name: 'Michael Vasquez', title: 'Founder & CEO', description: 'Master machinist with 35+ years of experience. Leads strategic vision and client relationships.', width: isWide ? 350 : double.infinity),
            _buildTeamMember(name: 'Sarah Chen', title: 'VP of Operations', description: 'Aerospace engineer overseeing production, quality control, and continuous improvement initiatives.', width: isWide ? 350 : double.infinity),
            _buildTeamMember(name: 'Robert Martinez', title: 'Director of Engineering', description: 'CAD/CAM expert managing programming team and technical customer support.', width: isWide ? 350 : double.infinity),
          ]);
        }),
      ]))),
    );
  }

  Widget _buildTeamMember({required String name, required String title, required String description, double? width}) {
    return SizedBox(
      width: width,
      child: Column(children: [
        Container(width: 120, height: 120, decoration: BoxDecoration(color: const Color(0xFF0d47a1).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(60)), child: const Center(child: Icon(Icons.person, size: 60, color: Color(0xFF0d47a1)))),
        const SizedBox(height: 20),
        Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1a1a1a)), textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(fontSize: 16, color: Color(0xFF0d47a1), fontWeight: FontWeight.w600), textAlign: TextAlign.center),
        const SizedBox(height: 12),
        Text(description, style: const TextStyle(fontSize: 15, color: Color(0xFF666666), height: 1.5), textAlign: TextAlign.center),
      ]),
    );
  }

  Widget _buildTimelineSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      color: const Color(0xFFf5f5f5),
      child: Center(child: Container(constraints: const BoxConstraints(maxWidth: 900), child: Column(children: [
        const Text('Our Journey', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF1a1a1a))),
        const SizedBox(height: 60),
        _buildTimelineItem('1999', 'Founded', 'MV Machine Shop established with 3 CNC machines'),
        _buildTimelineItem('2005', 'ISO 9001', 'Achieved ISO 9001 certification'),
        _buildTimelineItem('2010', 'Facility Expansion', 'Moved to 15,000 sq ft facility'),
        _buildTimelineItem('2015', 'AS9100 Certified', 'Entered aerospace market with AS9100D'),
        _buildTimelineItem('2020', 'Major Growth', 'Expanded to 25,000 sq ft, added 5-axis capabilities'),
        _buildTimelineItem('2024', 'Medical Certification', 'Achieved ISO 13485 for medical device manufacturing'),
      ]))),
    );
  }

  Widget _buildTimelineItem(String year, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 80, child: Text(year, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0d47a1)))),
        const SizedBox(width: 24),
        Container(width: 3, height: 80, color: const Color(0xFF0d47a1).withValues(alpha: 0.3)),
        const SizedBox(width: 24),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1a1a1a))),
          const SizedBox(height: 8),
          Text(description, style: const TextStyle(fontSize: 16, color: Color(0xFF666666), height: 1.5)),
        ])),
      ]),
    );
  }

  Widget _buildCTASection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      color: const Color(0xFF0d47a1),
      child: Center(child: Container(constraints: const BoxConstraints(maxWidth: 800), child: Column(children: [
        const Text('Join Our Growing List of Partners', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
        const SizedBox(height: 16),
        const Text('Experience the MV Machine Shop difference', style: TextStyle(fontSize: 18, color: Colors.white70), textAlign: TextAlign.center),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () => _showQuoteForm(context),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF0d47a1), padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
          child: const Text('Contact Us Today', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ]))),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      color: const Color(0xFF1a1a1a),
      child: Center(child: Container(constraints: const BoxConstraints(maxWidth: 1200), child: Column(children: [
        const Divider(color: Color(0xFF333333)),
        const SizedBox(height: 20),
        Text('© ${DateTime.now().year} ${CompanyContact.name}. All rights reserved.', style: const TextStyle(color: Color(0xFF999999), fontSize: 14), textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text('${CompanyContact.fullAddress} | ${CompanyContact.phone}', style: const TextStyle(color: Color(0xFF666666), fontSize: 12), textAlign: TextAlign.center),
      ]))),
    );
  }
}