import 'package:flutter/material.dart';
import 'package:mv/widgets/contacts.dart';
import 'package:mv/widgets/responsive.dart';
import 'package:mv/widgets/quote_form.dart';

class CapabilitiesPage extends StatelessWidget {
  const CapabilitiesPage({super.key});



  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeroSection(context),
          _buildEquipmentSection(context),
          _buildMaterialsSection(context),
          _buildTolerancesSection(context),
          _buildCapacitySection(context),
          _buildCertificationsSection(context),
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
              Text('Our Capabilities', style: TextStyle(fontSize: r.displayHeading, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
              SizedBox(height: r.spacingM),
              Text(
                'State-of-the-art equipment and expertise to handle your most demanding projects',
                style: TextStyle(fontSize: r.heroSubHeading, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEquipmentSection(BuildContext context) {
    final r = Responsive.of(context);
    return Container(
      padding: r.sectionPadding,
      color: Colors.white,
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: r.maxContentWidth),
          child: Column(
            children: [
              Text('Our Equipment', style: TextStyle(fontSize: r.heading1, fontWeight: FontWeight.bold, color: const Color(0xFF1a1a1a))),
              SizedBox(height: r.spacingM),
              Text('Advanced CNC machines for precision manufacturing', style: TextStyle(fontSize: r.body + 2, color: const Color(0xFF666666))),
              SizedBox(height: r.spacingXXL),
              Wrap(
                spacing: r.cardSpacing,
                runSpacing: r.cardSpacing,
                alignment: WrapAlignment.center,
                children: [
                  _buildEquipmentCard(r, title: '5-Axis CNC Mills', specs: ['Travel: 40" x 20" x 20"', 'Spindle speed: 12,000 RPM', 'Tool capacity: 60 tools', 'Tolerance: ±0.0005"'], icon: Icons.view_in_ar),
                  _buildEquipmentCard(r, title: 'CNC Turning Centers', specs: ['Max diameter: 12"', 'Max length: 24"', 'Live tooling capable', 'Sub-spindle equipped'], icon: Icons.rotate_90_degrees_ccw),
                  _buildEquipmentCard(r, title: 'Swiss-Type Lathes', specs: ['Bar capacity: 1.25"', 'Live tooling: 12 positions', 'Sub-spindle capable', 'High-volume production'], icon: Icons.precision_manufacturing),
                  _buildEquipmentCard(r, title: 'Wire EDM', specs: ['Wire diameter: 0.004" - 0.012"', 'Tolerance: ±0.0002"', 'Surface finish: Ra 8', 'Hardened materials capable'], icon: Icons.bolt),
                  _buildEquipmentCard(r, title: 'CMM Inspection', specs: ['Measuring volume: 24" x 24" x 16"', 'Accuracy: 0.0001"', 'Contact and optical probing', 'Full dimensional reports'], icon: Icons.straighten),
                  _buildEquipmentCard(r, title: 'Surface Grinding', specs: ['Capacity: 24" x 12" x 12"', 'Tolerance: ±0.0002"', 'Surface finish: Ra 4', 'Magnetic and vacuum chucks'], icon: Icons.grid_on),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEquipmentCard(Responsive r, {required String title, required List<String> specs, required IconData icon}) {
    return Container(
      width: r.equipmentCardWidth,
      padding: EdgeInsets.all(r.isMobile ? 20 : 28),
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
              Icon(icon, size: r.iconLarge, color: const Color(0xFF0d47a1)),
              SizedBox(width: r.spacingS),
              Expanded(child: Text(title, style: TextStyle(fontSize: r.heading3, fontWeight: FontWeight.bold, color: const Color(0xFF1a1a1a)))),
            ],
          ),
          SizedBox(height: r.spacingM),
          ...specs.map((s) => Padding(
            padding: EdgeInsets.only(bottom: r.spacingS),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ', style: TextStyle(fontSize: r.body, color: const Color(0xFF0d47a1), fontWeight: FontWeight.bold)),
                Expanded(child: Text(s, style: TextStyle(fontSize: r.body, color: const Color(0xFF333333), height: 1.4))),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildMaterialsSection(BuildContext context) {
    final r = Responsive.of(context);
    return Container(
      padding: r.sectionPadding,
      color: const Color(0xFFf5f5f5),
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: r.maxContentWidth),
          child: Column(
            children: [
              Text('Materials We Machine', style: TextStyle(fontSize: r.heading1, fontWeight: FontWeight.bold, color: const Color(0xFF1a1a1a))),
              SizedBox(height: r.spacingXXL),
              Wrap(
                spacing: r.spacingL,
                runSpacing: r.spacingL,
                alignment: WrapAlignment.center,
                children: [
                  _buildMaterialCategory(r, 'Metals', ['Aluminum (all alloys)', 'Stainless Steel (300/400 series)', 'Steel (mild, tool, alloy)', 'Titanium (Grade 2, 5)', 'Brass & Bronze', 'Copper', 'Inconel & Hastelloy']),
                  _buildMaterialCategory(r, 'Plastics', ['PEEK', 'Delrin (Acetal)', 'Nylon', 'PTFE (Teflon)', 'Polycarbonate', 'UHMW', 'Ultem']),
                  _buildMaterialCategory(r, 'Specialty Materials', ['Carbon Fiber', 'G10/FR4', 'Ceramics', 'Graphite', 'Exotic alloys', 'Medical-grade materials']),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMaterialCategory(Responsive r, String title, List<String> materials) {
    return Container(
      width: r.equipmentCardWidth,
      padding: EdgeInsets.all(r.cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(r.cardRadius),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: r.heading2, fontWeight: FontWeight.bold, color: const Color(0xFF0d47a1))),
          SizedBox(height: r.spacingM),
          ...materials.map((m) => Padding(
            padding: EdgeInsets.only(bottom: r.spacingXS),
            child: Row(
              children: [
                Icon(Icons.check_circle, size: r.iconSmall + 2, color: const Color(0xFF0d47a1)),
                SizedBox(width: r.spacingXS),
                Expanded(child: Text(m, style: TextStyle(fontSize: r.body, color: const Color(0xFF333333)))),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildTolerancesSection(BuildContext context) {
    final r = Responsive.of(context);
    return Container(
      padding: r.sectionPadding,
      color: Colors.white,
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: r.maxContentWidth),
          child: Column(
            children: [
              Text('Precision & Tolerances', style: TextStyle(fontSize: r.heading1, fontWeight: FontWeight.bold, color: const Color(0xFF1a1a1a))),
              SizedBox(height: r.spacingXXL),
              r.isDesktop
                  ? Row(
                      children: [
                        Expanded(child: _buildToleranceCard(r, 'Linear Tolerances', '±0.0005"', 'Standard tight tolerance capability')),
                        SizedBox(width: r.cardSpacing),
                        Expanded(child: _buildToleranceCard(r, 'Angular Tolerances', '±0.25°', 'Precise angular measurements')),
                        SizedBox(width: r.cardSpacing),
                        Expanded(child: _buildToleranceCard(r, 'Surface Finish', 'Ra 4-8 µin', 'Excellent surface quality')),
                        SizedBox(width: r.cardSpacing),
                        Expanded(child: _buildToleranceCard(r, 'Roundness', '0.0002"', 'Exceptional circularity')),
                      ],
                    )
                  : r.isTablet
                      ? Wrap(
                          spacing: r.cardSpacing,
                          runSpacing: r.cardSpacing,
                          alignment: WrapAlignment.center,
                          children: [
                            SizedBox(width: 220, child: _buildToleranceCard(r, 'Linear Tolerances', '±0.0005"', 'Standard tight tolerance capability')),
                            SizedBox(width: 220, child: _buildToleranceCard(r, 'Angular Tolerances', '±0.25°', 'Precise angular measurements')),
                            SizedBox(width: 220, child: _buildToleranceCard(r, 'Surface Finish', 'Ra 4-8 µin', 'Excellent surface quality')),
                            SizedBox(width: 220, child: _buildToleranceCard(r, 'Roundness', '0.0002"', 'Exceptional circularity')),
                          ],
                        )
                      : Column(
                          children: [
                            _buildToleranceCard(r, 'Linear Tolerances', '±0.0005"', 'Standard tight tolerance capability'),
                            SizedBox(height: r.cardSpacing),
                            _buildToleranceCard(r, 'Angular Tolerances', '±0.25°', 'Precise angular measurements'),
                            SizedBox(height: r.cardSpacing),
                            _buildToleranceCard(r, 'Surface Finish', 'Ra 4-8 µin', 'Excellent surface quality'),
                            SizedBox(height: r.cardSpacing),
                            _buildToleranceCard(r, 'Roundness', '0.0002"', 'Exceptional circularity'),
                          ],
                        ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToleranceCard(Responsive r, String title, String value, String description) {
    return Container(
      padding: EdgeInsets.all(r.isMobile ? 16 : 24),
      decoration: BoxDecoration(color: const Color(0xFF0d47a1), borderRadius: BorderRadius.circular(r.cardRadius)),
      child: Column(
        children: [
          Text(title, style: TextStyle(fontSize: r.toleranceTitleFont, color: Colors.white70), textAlign: TextAlign.center),
          SizedBox(height: r.spacingS),
          Text(value, style: TextStyle(fontSize: r.toleranceStatFont, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
          SizedBox(height: r.spacingXS),
          Text(description, style: TextStyle(fontSize: r.caption + 1, color: Colors.white70), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildCapacitySection(BuildContext context) {
    final r = Responsive.of(context);
    return Container(
      padding: r.sectionPadding,
      color: const Color(0xFFf5f5f5),
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: r.maxContentWidth),
          child: Column(
            children: [
              Text('Production Capacity', style: TextStyle(fontSize: r.heading1, fontWeight: FontWeight.bold, color: const Color(0xFF1a1a1a))),
              SizedBox(height: r.spacingXXL),
              r.isDesktop
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildCapacityStat(r, 'Prototype', 'to Production', Icons.inventory),
                        _buildCapacityStat(r, '1-100,000+', 'Parts/Month', Icons.speed),
                        _buildCapacityStat(r, '24/7', 'Operations', Icons.access_time),
                        _buildCapacityStat(r, '15+', 'CNC Machines', Icons.precision_manufacturing),
                      ],
                    )
                  : Wrap(
                      spacing: r.spacingXL,
                      runSpacing: r.spacingXL,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildCapacityStat(r, 'Prototype', 'to Production', Icons.inventory),
                        _buildCapacityStat(r, '1-100,000+', 'Parts/Month', Icons.speed),
                        _buildCapacityStat(r, '24/7', 'Operations', Icons.access_time),
                        _buildCapacityStat(r, '15+', 'CNC Machines', Icons.precision_manufacturing),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCapacityStat(Responsive r, String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: r.iconHero, color: const Color(0xFF0d47a1)),
        SizedBox(height: r.spacingM),
        Text(value, style: TextStyle(fontSize: r.capacityStatFont, fontWeight: FontWeight.bold, color: const Color(0xFF1a1a1a)), textAlign: TextAlign.center),
        SizedBox(height: r.spacingXS),
        Text(label, style: TextStyle(fontSize: r.body, color: const Color(0xFF666666)), textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildCertificationsSection(BuildContext context) {
    final r = Responsive.of(context);
    return Container(
      padding: r.sectionPadding,
      color: Colors.white,
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: r.maxContentWidth),
          child: Column(
            children: [
              Text('Certifications & Quality', style: TextStyle(fontSize: r.heading1, fontWeight: FontWeight.bold, color: const Color(0xFF1a1a1a))),
              SizedBox(height: r.spacingXXL),
              GridView.count(
                crossAxisCount: r.certGridColumns,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: r.cardSpacing,
                mainAxisSpacing: r.cardSpacing,
                childAspectRatio: r.certGridAspectRatio,
                children: [
                  _buildCertCard(r, 'ISO 9001:2015', 'Quality Management'),
                  _buildCertCard(r, 'AS9100D', 'Aerospace Quality'),
                  _buildCertCard(r, 'ITAR Registered', 'Defense Compliance'),
                  _buildCertCard(r, 'ISO 13485', 'Medical Devices'),
                  _buildCertCard(r, 'PPAP Level 3', 'Automotive Standards'),
                  _buildCertCard(r, 'RoHS Compliant', 'Environmental Standards'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCertCard(Responsive r, String title, String description) {
    return Container(
      padding: EdgeInsets.all(r.isMobile ? 14 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(r.cardRadius),
        border: Border.all(color: const Color(0xFF0d47a1), width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.verified, size: r.iconLarge, color: const Color(0xFF0d47a1)),
          SizedBox(height: r.spacingS),
          Text(title, style: TextStyle(fontSize: r.heading3, fontWeight: FontWeight.bold, color: const Color(0xFF1a1a1a)), textAlign: TextAlign.center),
          SizedBox(height: r.spacingXS / 2),
          Text(description, style: TextStyle(fontSize: r.caption + 1, color: const Color(0xFF666666)), textAlign: TextAlign.center),
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
              Text('Put Our Capabilities to Work', style: TextStyle(fontSize: r.heading1, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
              SizedBox(height: r.spacingM),
              Text('Let us handle your most challenging manufacturing projects', style: TextStyle(fontSize: r.body + 2, color: Colors.white70), textAlign: TextAlign.center),
              SizedBox(height: r.spacingL),
              ElevatedButton(
                onPressed: () => showQuoteDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF0d47a1),
                  padding: r.primaryButtonPadding,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                child: Text('Get Started', style: TextStyle(fontSize: r.buttonText, fontWeight: FontWeight.bold)),
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