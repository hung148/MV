import 'package:flutter/material.dart';
import 'package:mv/widgets/contacts.dart';
import 'package:mv/widgets/styles.dart';

// Renamed from HomePage to HomePageContent.
// No Scaffold or CustomNavigationBar — AppShell in main.dart handles both.
class HomePageContent extends StatelessWidget {
  const HomePageContent({super.key});

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
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Request a Quote', style: ShopStyles.heading),
                  const SizedBox(height: 8),
                  Text(
                    'Submit your requirements or contact us directly at ${CompanyContact.phone}',
                    style: ShopStyles.body,
                  ),
                  const Divider(height: 40),
                  _buildTextField(
                    'Full Name',
                    Icons.person_outline,
                    maxLength: 50,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter your name';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    'Email Address',
                    Icons.email_outlined,
                    maxLength: 100,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter your email';
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    'Project Details',
                    Icons.description_outlined,
                    maxLines: 4,
                    maxLength: 1000,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please describe your project';
                      if (value.length < 10) return 'Please provide more details (min 10 chars)';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Inquiry sent successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );
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

  Widget _buildTextField(
    String label,
    IconData icon, {
    int maxLines = 1,
    String? Function(String?)? validator,
    int? maxLength,
  }) {
    return TextFormField(
      maxLines: maxLines,
      maxLength: maxLength,
      validator: validator,
      decoration: InputDecoration(
        counterText: "",
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF0066cc), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Just the scrollable content — no Scaffold, no navbar
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeroSection(context),
          _buildFeaturesSection(),
          _buildServicesSection(),
          _buildCapabilitiesSection(),
          _buildWhyChooseUsSection(),
          _buildStatsSection(),
          _buildCTASection(context),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      height: 700,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0d47a1),
            Color(0xFF1976d2),
            Color(0xFF42a5f5),
          ],
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
              padding: const EdgeInsets.symmetric(horizontal: 24),
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Precision CNC Manufacturing',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Your trusted partner for high-quality machining solutions',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w300),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'From prototype to production, we deliver excellence in every part',
                    style: TextStyle(color: Color(0xFFE3F2FD), fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF0d47a1),
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          elevation: 4,
                        ),
                        child: const Text(
                          'View Our Capabilities',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () => _showQuoteForm(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white, width: 2),
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                        child: const Text(
                          'Get a Quote',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

  Widget _buildFeaturesSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      color: Colors.white,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              const Text(
                'Why MV Machine Shop?',
                style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Color(0xFF1a1a1a)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Industry-leading precision and reliability',
                style: TextStyle(fontSize: 18, color: Color(0xFF666666)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 900;
                  return Wrap(
                    spacing: 32,
                    runSpacing: 32,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildFeatureCard(
                        icon: Icons.precision_manufacturing,
                        title: 'Precision Engineering',
                        description: 'Tolerances down to ±0.0005" with state-of-the-art CNC equipment',
                        width: isWide ? 350 : double.infinity,
                      ),
                      _buildFeatureCard(
                        icon: Icons.speed,
                        title: 'Fast Turnaround',
                        description: 'Quick quotes within 24 hours and rapid production times',
                        width: isWide ? 350 : double.infinity,
                      ),
                      _buildFeatureCard(
                        icon: Icons.verified,
                        title: 'Quality Assured',
                        description: 'ISO 9001 certified processes and rigorous inspection standards',
                        width: isWide ? 350 : double.infinity,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({required IconData icon, required String title, required String description, double? width}) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFe0e0e0)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0d47a1).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(icon, size: 48, color: const Color(0xFF0d47a1)),
          ),
          const SizedBox(height: 24),
          Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1a1a1a)), textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Text(description, style: const TextStyle(fontSize: 16, color: Color(0xFF666666), height: 1.5), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildServicesSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      color: const Color(0xFFf5f5f5),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              const Text('Our Services', style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Color(0xFF1a1a1a)), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              const Text('Comprehensive machining solutions for every need', style: TextStyle(fontSize: 18, color: Color(0xFF666666)), textAlign: TextAlign.center),
              const SizedBox(height: 60),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 768;
                  return Wrap(
                    spacing: 24,
                    runSpacing: 24,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildServiceCard(title: 'CNC Milling', description: '3-axis and 5-axis milling for complex geometries', imageIcon: Icons.settings, width: isWide ? 280 : double.infinity),
                      _buildServiceCard(title: 'CNC Turning', description: 'High-precision turning for cylindrical components', imageIcon: Icons.rotate_right, width: isWide ? 280 : double.infinity),
                      _buildServiceCard(title: 'Prototyping', description: 'Rapid prototyping from concept to finished part', imageIcon: Icons.science, width: isWide ? 280 : double.infinity),
                      _buildServiceCard(title: 'Production Runs', description: 'Low to high volume manufacturing capabilities', imageIcon: Icons.factory, width: isWide ? 280 : double.infinity),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard({required String title, required String description, required IconData imageIcon, double? width}) {
    return Container(
      width: width,
      height: 220,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(imageIcon, size: 56, color: const Color(0xFF0d47a1)),
          const SizedBox(height: 20),
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1a1a1a)), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(description, style: const TextStyle(fontSize: 14, color: Color(0xFF666666), height: 1.4), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildCapabilitiesSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      color: Colors.white,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              const Text('Materials We Work With', style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Color(0xFF1a1a1a)), textAlign: TextAlign.center),
              const SizedBox(height: 60),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth > 768 ? 3 : 2;
                  return GridView.count(
                    crossAxisCount: columns,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 24,
                    childAspectRatio: 2.5,
                    children: [
                      _buildMaterialChip('Aluminum'),
                      _buildMaterialChip('Stainless Steel'),
                      _buildMaterialChip('Titanium'),
                      _buildMaterialChip('Brass'),
                      _buildMaterialChip('Copper'),
                      _buildMaterialChip('Plastics'),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMaterialChip(String material) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFf5f5f5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFe0e0e0)),
      ),
      child: Center(child: Text(material, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1a1a1a)))),
    );
  }

  Widget _buildWhyChooseUsSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      color: const Color(0xFF0d47a1),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              const Text('Experience & Expertise', style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
              const SizedBox(height: 60),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 768;
                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildExperiencePoint(icon: Icons.calendar_today, title: '25+ Years', description: 'Of industry experience and continuous improvement')),
                        const SizedBox(width: 48),
                        Expanded(child: _buildExperiencePoint(icon: Icons.people, title: 'Expert Team', description: 'Certified machinists and quality control specialists')),
                        const SizedBox(width: 48),
                        Expanded(child: _buildExperiencePoint(icon: Icons.build, title: 'Advanced Equipment', description: 'Latest CNC machines and measurement tools')),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        _buildExperiencePoint(icon: Icons.calendar_today, title: '25+ Years', description: 'Of industry experience and continuous improvement'),
                        const SizedBox(height: 40),
                        _buildExperiencePoint(icon: Icons.people, title: 'Expert Team', description: 'Certified machinists and quality control specialists'),
                        const SizedBox(height: 40),
                        _buildExperiencePoint(icon: Icons.build, title: 'Advanced Equipment', description: 'Latest CNC machines and measurement tools'),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExperiencePoint({required IconData icon, required String title, required String description}) {
    return Column(
      children: [
        Icon(icon, size: 48, color: Colors.white),
        const SizedBox(height: 16),
        Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(description, style: const TextStyle(fontSize: 16, color: Color(0xFFE3F2FD), height: 1.5), textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      color: const Color(0xFF1a1a1a),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 768;
              if (isWide) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('10,000+', 'Parts Manufactured'),
                    _buildStatItem('500+', 'Satisfied Clients'),
                    _buildStatItem('99.8%', 'Quality Rate'),
                    _buildStatItem('24hr', 'Quote Turnaround'),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _buildStatItem('10,000+', 'Parts Manufactured'),
                    const SizedBox(height: 32),
                    _buildStatItem('500+', 'Satisfied Clients'),
                    const SizedBox(height: 32),
                    _buildStatItem('99.8%', 'Quality Rate'),
                    const SizedBox(height: 32),
                    _buildStatItem('24hr', 'Quote Turnaround'),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String number, String label) {
    return Column(
      children: [
        Text(number, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Color(0xFF0066cc))),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 16, color: Color(0xFFcccccc)), textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildCTASection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      color: Colors.white,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              const Text('Ready to Get Started?', style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Color(0xFF1a1a1a)), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              const Text('Contact us today for a free quote on your next project', style: TextStyle(fontSize: 18, color: Color(0xFF666666)), textAlign: TextAlign.center),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => _showQuoteForm(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0d47a1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  elevation: 2,
                ),
                child: const Text('Request a Quote', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      color: const Color(0xFF1a1a1a),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 768;
                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildFooterSection1()),
                        const SizedBox(width: 48),
                        Expanded(child: _buildFooterSection2(context)),
                        const SizedBox(width: 48),
                        Expanded(child: _buildFooterSection3()),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        _buildFooterSection1(),
                        const SizedBox(height: 32),
                        _buildFooterSection2(context),
                        const SizedBox(height: 32),
                        _buildFooterSection3(),
                      ],
                    );
                  }
                },
              ),
              const SizedBox(height: 40),
              const Divider(color: Color(0xFF333333)),
              const SizedBox(height: 20),
              Text(
                '© ${DateTime.now().year} ${CompanyContact.name}. All rights reserved.',
                style: const TextStyle(color: Color(0xFF999999), fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooterSection1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(CompanyContact.name, style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text(CompanyContact.tagline, style: TextStyle(color: Color(0xFF0066cc), fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 16),
        const Text('Precision CNC machining and manufacturing solutions for industries worldwide.', style: TextStyle(color: Color(0xFF999999), fontSize: 14, height: 1.5)),
      ],
    );
  }

  Widget _buildFooterSection2(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Links', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildFooterLink(context, 'Services', '/services'),
        _buildFooterLink(context, 'Capabilities', '/capabilities'),
        _buildFooterLink(context, 'About Us', '/about'),
        _buildFooterLink(context, 'Gallery', '/gallery'),
      ],
    );
  }

  Widget _buildFooterSection3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Contact Info', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildFooterInfo(Icons.location_on_outlined, CompanyContact.fullAddress),
        _buildFooterInfo(Icons.phone_outlined, CompanyContact.phone),
        _buildFooterInfo(Icons.email_outlined, CompanyContact.email),
        _buildFooterInfo(Icons.schedule_outlined, 'Mon-Fri: ${CompanyContact.operatingHours["Monday - Friday"]}'),
      ],
    );
  }

  Widget _buildFooterLink(BuildContext context, String text, String route) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => Navigator.of(context, rootNavigator: false).pushNamed(route),
        child: Text(text, style: const TextStyle(color: Color(0xFF999999), fontSize: 14)),
      ),
    );
  }

  Widget _buildFooterInfo(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF0066cc), size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(color: Color(0xFF999999), fontSize: 14))),
        ],
      ),
    );
  }
}