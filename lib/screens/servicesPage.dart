import 'package:flutter/material.dart';
import 'package:mv/widgets/contacts.dart';
import 'package:mv/widgets/responsive.dart';
import 'package:mv/widgets/quote_form.dart';

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});



  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeroSection(context),
          _buildServicesGrid(context),
          _buildProcessSection(context),
          _buildIndustriesSection(context),
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
              Text(
                'Our Services',
                style: TextStyle(fontSize: r.displayHeading, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: r.spacingM),
              Text(
                'Comprehensive CNC machining solutions for all your manufacturing needs',
                style: TextStyle(fontSize: r.heroSubHeading, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServicesGrid(BuildContext context) {
    final r = Responsive.of(context);
    return Container(
      padding: r.sectionPadding,
      color: Colors.white,
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: r.maxContentWidth),
          child: Column(
            children: [
              Text('What We Offer', style: TextStyle(fontSize: r.heading1, fontWeight: FontWeight.bold, color: const Color(0xFF1a1a1a))),
              SizedBox(height: r.spacingXXL),
              Wrap(
                spacing: r.spacingL,
                runSpacing: r.spacingL,
                alignment: WrapAlignment.center,
                children: [
                  _buildDetailedServiceCard(r, icon: Icons.settings, title: 'CNC Milling', description: 'Precision milling services for complex parts', features: ['3-axis and 5-axis capabilities', 'Tolerances to ±0.0005"', 'Parts up to 40" x 20" x 20"', 'Prototype to production']),
                  _buildDetailedServiceCard(r, icon: Icons.rotate_right, title: 'CNC Turning', description: 'High-precision turning for cylindrical components', features: ['Live tooling capabilities', 'Multi-axis turning centers', 'Diameters up to 12"', 'Bar and chuck work']),
                  _buildDetailedServiceCard(r, icon: Icons.science, title: 'Rapid Prototyping', description: 'Fast turnaround for prototype development', features: ['Quick quote within 24 hours', 'Single or low-volume runs', 'Design consultation available', 'Material recommendations']),
                  _buildDetailedServiceCard(r, icon: Icons.factory, title: 'Production Manufacturing', description: 'Scalable production runs with consistent quality', features: ['Low to high volume capabilities', 'Quality control at every step', 'Just-in-time delivery options', 'Vendor managed inventory']),
                  _buildDetailedServiceCard(r, icon: Icons.precision_manufacturing, title: 'Swiss Machining', description: 'Ultra-precise parts for medical and aerospace', features: ['Complex geometries', 'Tight tolerances', 'Small diameter work', 'High-volume capability']),
                  _buildDetailedServiceCard(r, icon: Icons.build_circle, title: 'Assembly Services', description: 'Complete assembly and sub-assembly solutions', features: ['Mechanical assembly', 'Testing and validation', 'Packaging solutions', 'Quality documentation']),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailedServiceCard(Responsive r, {required IconData icon, required String title, required String description, required List<String> features}) {
    return Container(
      width: r.detailedServiceCardWidth,
      padding: EdgeInsets.all(r.cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(r.cardRadius),
        border: Border.all(color: const Color(0xFFe0e0e0)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(r.spacingS),
                decoration: BoxDecoration(color: const Color(0xFF0d47a1).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(r.cardRadius)),
                child: Icon(icon, size: r.iconLarge, color: const Color(0xFF0d47a1)),
              ),
              SizedBox(width: r.spacingM),
              Expanded(
                child: Text(title, style: TextStyle(fontSize: r.heading2, fontWeight: FontWeight.bold, color: const Color(0xFF1a1a1a))),
              ),
            ],
          ),
          SizedBox(height: r.spacingM),
          Text(description, style: TextStyle(fontSize: r.body, color: const Color(0xFF666666), height: 1.5)),
          SizedBox(height: r.spacingM),
          const Divider(color: Color(0xFFe0e0e0)),
          SizedBox(height: r.spacingM),
          ...features.map((f) => Padding(
            padding: EdgeInsets.only(bottom: r.spacingXS),
            child: Row(
              children: [
                Icon(Icons.check_circle, size: r.iconSmall + 2, color: const Color(0xFF0d47a1)),
                SizedBox(width: r.spacingXS),
                Expanded(child: Text(f, style: TextStyle(fontSize: r.caption + 1, color: const Color(0xFF333333)))),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildProcessSection(BuildContext context) {
    final r = Responsive.of(context);
    return Container(
      padding: r.sectionPadding,
      color: const Color(0xFFf5f5f5),
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: r.maxContentWidth),
          child: Column(
            children: [
              Text('Our Process', style: TextStyle(fontSize: r.heading1, fontWeight: FontWeight.bold, color: const Color(0xFF1a1a1a))),
              SizedBox(height: r.spacingM),
              Text('From concept to delivery, we ensure quality at every step', style: TextStyle(fontSize: r.body + 2, color: const Color(0xFF666666)), textAlign: TextAlign.center),
              SizedBox(height: r.spacingXXL),
              r.isDesktop
                  ? Row(
                      children: [
                        Expanded(child: _buildProcessStep(r, '1', 'Quote', 'Submit drawings for fast quote')),
                        SizedBox(width: r.cardSpacing),
                        Expanded(child: _buildProcessStep(r, '2', 'Program', 'CAD/CAM programming')),
                        SizedBox(width: r.cardSpacing),
                        Expanded(child: _buildProcessStep(r, '3', 'Machine', 'Precision manufacturing')),
                        SizedBox(width: r.cardSpacing),
                        Expanded(child: _buildProcessStep(r, '4', 'Inspect', 'Quality verification')),
                        SizedBox(width: r.cardSpacing),
                        Expanded(child: _buildProcessStep(r, '5', 'Deliver', 'On-time shipping')),
                      ],
                    )
                  : r.isTablet
                      ? Wrap(
                          spacing: r.cardSpacing,
                          runSpacing: r.cardSpacing,
                          alignment: WrapAlignment.center,
                          children: [
                            SizedBox(width: 180, child: _buildProcessStep(r, '1', 'Quote', 'Submit drawings for fast quote')),
                            SizedBox(width: 180, child: _buildProcessStep(r, '2', 'Program', 'CAD/CAM programming')),
                            SizedBox(width: 180, child: _buildProcessStep(r, '3', 'Machine', 'Precision manufacturing')),
                            SizedBox(width: 180, child: _buildProcessStep(r, '4', 'Inspect', 'Quality verification')),
                            SizedBox(width: 180, child: _buildProcessStep(r, '5', 'Deliver', 'On-time shipping')),
                          ],
                        )
                      : Column(
                          children: [
                            _buildProcessStep(r, '1', 'Quote', 'Submit drawings for fast quote'),
                            SizedBox(height: r.cardSpacing),
                            _buildProcessStep(r, '2', 'Program', 'CAD/CAM programming'),
                            SizedBox(height: r.cardSpacing),
                            _buildProcessStep(r, '3', 'Machine', 'Precision manufacturing'),
                            SizedBox(height: r.cardSpacing),
                            _buildProcessStep(r, '4', 'Inspect', 'Quality verification'),
                            SizedBox(height: r.cardSpacing),
                            _buildProcessStep(r, '5', 'Deliver', 'On-time shipping'),
                          ],
                        ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProcessStep(Responsive r, String number, String title, String description) {
    return Container(
      padding: EdgeInsets.all(r.processStepPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(r.cardRadius),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Container(
            width: r.processNumberSize,
            height: r.processNumberSize,
            decoration: BoxDecoration(color: const Color(0xFF0d47a1), borderRadius: BorderRadius.circular(r.processNumberSize / 2)),
            child: Center(child: Text(number, style: TextStyle(fontSize: r.processNumberFont, fontWeight: FontWeight.bold, color: Colors.white))),
          ),
          SizedBox(height: r.spacingM),
          Text(title, style: TextStyle(fontSize: r.heading3, fontWeight: FontWeight.bold, color: const Color(0xFF1a1a1a))),
          SizedBox(height: r.spacingXS),
          Text(description, style: TextStyle(fontSize: r.caption + 1, color: const Color(0xFF666666)), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildIndustriesSection(BuildContext context) {
    final r = Responsive.of(context);
    return Container(
      padding: r.sectionPadding,
      color: Colors.white,
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: r.maxContentWidth),
          child: Column(
            children: [
              Text('Industries We Serve', style: TextStyle(fontSize: r.heading1, fontWeight: FontWeight.bold, color: const Color(0xFF1a1a1a))),
              SizedBox(height: r.spacingXXL),
              GridView.count(
                crossAxisCount: r.industryGridColumns,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: r.cardSpacing,
                mainAxisSpacing: r.cardSpacing,
                childAspectRatio: r.industryGridAspectRatio,
                children: [
                  _buildIndustryCard(r, Icons.local_hospital, 'Medical'),
                  _buildIndustryCard(r, Icons.flight, 'Aerospace'),
                  _buildIndustryCard(r, Icons.directions_car, 'Automotive'),
                  _buildIndustryCard(r, Icons.military_tech, 'Defense'),
                  _buildIndustryCard(r, Icons.oil_barrel, 'Oil & Gas'),
                  _buildIndustryCard(r, Icons.electrical_services, 'Electronics'),
                  _buildIndustryCard(r, Icons.precision_manufacturing, 'Industrial'),
                  _buildIndustryCard(r, Icons.energy_savings_leaf, 'Energy'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIndustryCard(Responsive r, IconData icon, String industry) {
    return Container(
      padding: EdgeInsets.all(r.spacingM),
      decoration: BoxDecoration(
        color: const Color(0xFFf5f5f5),
        borderRadius: BorderRadius.circular(r.cardRadius),
        border: Border.all(color: const Color(0xFFe0e0e0)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: r.iconLarge, color: const Color(0xFF0d47a1)),
          SizedBox(height: r.spacingS),
          Text(industry, style: TextStyle(fontSize: r.body, fontWeight: FontWeight.w600, color: const Color(0xFF1a1a1a))),
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
              Text('Get a free quote within 24 hours', style: TextStyle(fontSize: r.body + 2, color: Colors.white70), textAlign: TextAlign.center),
              SizedBox(height: r.spacingL),
              ElevatedButton(
                onPressed: () => showQuoteDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF0d47a1),
                  padding: r.primaryButtonPadding,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                child: Text('Request a Quote', style: TextStyle(fontSize: r.buttonText, fontWeight: FontWeight.bold)),
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
              Text(
                '© ${DateTime.now().year} ${CompanyContact.name}. All rights reserved.',
                style: TextStyle(color: const Color(0xFF999999), fontSize: r.caption + 1),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: r.spacingXS),
              Text(
                '${CompanyContact.fullAddress} | ${CompanyContact.phone}',
                style: TextStyle(color: const Color(0xFF666666), fontSize: r.caption),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}