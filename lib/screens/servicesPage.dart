import 'package:flutter/material.dart';
import 'package:mv/widgets/contacts.dart';
import 'package:mv/widgets/styles.dart';

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

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
      maxLines: maxLines,
      maxLength: maxLength,
      validator: validator,
      decoration: InputDecoration(
        counterText: "",
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
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
          _buildServicesGrid(),
          _buildProcessSection(),
          _buildIndustriesSection(),
          _buildCTASection(context),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0d47a1), Color(0xFF1976d2)],
        ),
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: const Column(
            children: [
              Text('Our Services', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
              SizedBox(height: 16),
              Text('Comprehensive CNC machining solutions for all your manufacturing needs', style: TextStyle(fontSize: 20, color: Colors.white70), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServicesGrid() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      color: Colors.white,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              const Text('What We Offer', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF1a1a1a))),
              const SizedBox(height: 60),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 900;
                  return Wrap(
                    spacing: 32, runSpacing: 32, alignment: WrapAlignment.center,
                    children: [
                      _buildDetailedServiceCard(icon: Icons.settings, title: 'CNC Milling', description: 'Precision milling services for complex parts', features: ['3-axis and 5-axis capabilities', 'Tolerances to ±0.0005"', 'Parts up to 40" x 20" x 20"', 'Prototype to production'], width: isWide ? 550 : double.infinity),
                      _buildDetailedServiceCard(icon: Icons.rotate_right, title: 'CNC Turning', description: 'High-precision turning for cylindrical components', features: ['Live tooling capabilities', 'Multi-axis turning centers', 'Diameters up to 12"', 'Bar and chuck work'], width: isWide ? 550 : double.infinity),
                      _buildDetailedServiceCard(icon: Icons.science, title: 'Rapid Prototyping', description: 'Fast turnaround for prototype development', features: ['Quick quote within 24 hours', 'Single or low-volume runs', 'Design consultation available', 'Material recommendations'], width: isWide ? 550 : double.infinity),
                      _buildDetailedServiceCard(icon: Icons.factory, title: 'Production Manufacturing', description: 'Scalable production runs with consistent quality', features: ['Low to high volume capabilities', 'Quality control at every step', 'Just-in-time delivery options', 'Vendor managed inventory'], width: isWide ? 550 : double.infinity),
                      _buildDetailedServiceCard(icon: Icons.precision_manufacturing, title: 'Swiss Machining', description: 'Ultra-precise parts for medical and aerospace', features: ['Complex geometries', 'Tight tolerances', 'Small diameter work', 'High-volume capability'], width: isWide ? 550 : double.infinity),
                      _buildDetailedServiceCard(icon: Icons.build_circle, title: 'Assembly Services', description: 'Complete assembly and sub-assembly solutions', features: ['Mechanical assembly', 'Testing and validation', 'Packaging solutions', 'Quality documentation'], width: isWide ? 550 : double.infinity),
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

  Widget _buildDetailedServiceCard({required IconData icon, required String title, required String description, required List<String> features, double? width}) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFe0e0e0)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF0d47a1).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, size: 32, color: const Color(0xFF0d47a1))),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1a1a1a)))),
          ]),
          const SizedBox(height: 16),
          Text(description, style: const TextStyle(fontSize: 16, color: Color(0xFF666666), height: 1.5)),
          const SizedBox(height: 20),
          const Divider(color: Color(0xFFe0e0e0)),
          const SizedBox(height: 16),
          ...features.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [const Icon(Icons.check_circle, size: 18, color: Color(0xFF0d47a1)), const SizedBox(width: 8), Expanded(child: Text(f, style: const TextStyle(fontSize: 14, color: Color(0xFF333333))))]),
          )),
        ],
      ),
    );
  }

  Widget _buildProcessSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      color: const Color(0xFFf5f5f5),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              const Text('Our Process', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF1a1a1a))),
              const SizedBox(height: 16),
              const Text('From concept to delivery, we ensure quality at every step', style: TextStyle(fontSize: 18, color: Color(0xFF666666)), textAlign: TextAlign.center),
              const SizedBox(height: 60),
              LayoutBuilder(builder: (context, constraints) {
                final isWide = constraints.maxWidth > 768;
                if (isWide) {
                  return Row(children: [
                    Expanded(child: _buildProcessStep('1', 'Quote', 'Submit drawings for fast quote')),
                    const SizedBox(width: 24),
                    Expanded(child: _buildProcessStep('2', 'Program', 'CAD/CAM programming')),
                    const SizedBox(width: 24),
                    Expanded(child: _buildProcessStep('3', 'Machine', 'Precision manufacturing')),
                    const SizedBox(width: 24),
                    Expanded(child: _buildProcessStep('4', 'Inspect', 'Quality verification')),
                    const SizedBox(width: 24),
                    Expanded(child: _buildProcessStep('5', 'Deliver', 'On-time shipping')),
                  ]);
                } else {
                  return Column(children: [
                    _buildProcessStep('1', 'Quote', 'Submit drawings for fast quote'), const SizedBox(height: 24),
                    _buildProcessStep('2', 'Program', 'CAD/CAM programming'), const SizedBox(height: 24),
                    _buildProcessStep('3', 'Machine', 'Precision manufacturing'), const SizedBox(height: 24),
                    _buildProcessStep('4', 'Inspect', 'Quality verification'), const SizedBox(height: 24),
                    _buildProcessStep('5', 'Deliver', 'On-time shipping'),
                  ]);
                }
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProcessStep(String number, String title, String description) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(children: [
        Container(width: 48, height: 48, decoration: BoxDecoration(color: const Color(0xFF0d47a1), borderRadius: BorderRadius.circular(24)), child: Center(child: Text(number, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)))),
        const SizedBox(height: 16),
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1a1a1a))),
        const SizedBox(height: 8),
        Text(description, style: const TextStyle(fontSize: 14, color: Color(0xFF666666)), textAlign: TextAlign.center),
      ]),
    );
  }

  Widget _buildIndustriesSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      color: Colors.white,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              const Text('Industries We Serve', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF1a1a1a))),
              const SizedBox(height: 60),
              LayoutBuilder(builder: (context, constraints) {
                final columns = constraints.maxWidth > 768 ? 4 : 2;
                return GridView.count(
                  crossAxisCount: columns, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 24, mainAxisSpacing: 24, childAspectRatio: 1.5,
                  children: [
                    _buildIndustryCard(Icons.local_hospital, 'Medical'),
                    _buildIndustryCard(Icons.flight, 'Aerospace'),
                    _buildIndustryCard(Icons.directions_car, 'Automotive'),
                    _buildIndustryCard(Icons.military_tech, 'Defense'),
                    _buildIndustryCard(Icons.oil_barrel, 'Oil & Gas'),
                    _buildIndustryCard(Icons.electrical_services, 'Electronics'),
                    _buildIndustryCard(Icons.precision_manufacturing, 'Industrial'),
                    _buildIndustryCard(Icons.energy_savings_leaf, 'Energy'),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIndustryCard(IconData icon, String industry) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFFf5f5f5), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFe0e0e0))),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 40, color: const Color(0xFF0d47a1)),
        const SizedBox(height: 12),
        Text(industry, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1a1a1a))),
      ]),
    );
  }

  Widget _buildCTASection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      color: const Color(0xFF0d47a1),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(children: [
            const Text('Ready to Start Your Project?', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            const Text('Get a free quote within 24 hours', style: TextStyle(fontSize: 18, color: Colors.white70), textAlign: TextAlign.center),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => _showQuoteForm(context),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF0d47a1), padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
              child: const Text('Request a Quote', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ]),
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
          child: Column(children: [
            const Divider(color: Color(0xFF333333)),
            const SizedBox(height: 20),
            Text('© ${DateTime.now().year} ${CompanyContact.name}. All rights reserved.', style: const TextStyle(color: Color(0xFF999999), fontSize: 14), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text('${CompanyContact.fullAddress} | ${CompanyContact.phone}', style: const TextStyle(color: Color(0xFF666666), fontSize: 12), textAlign: TextAlign.center),
          ]),
        ),
      ),
    );
  }
}