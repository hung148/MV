import 'package:flutter/material.dart';
import 'package:mv/widgets/contacts.dart';
import 'package:mv/widgets/responsive.dart';
import 'package:mv/widgets/quote_form.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  String _selectedCategory = 'All';

  final List<String> _categories = ['All', 'Aerospace', 'Medical', 'Automotive', 'Industrial', 'Prototypes'];



  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeroSection(context),
          _buildFilterSection(context),
          _buildGalleryGrid(context),
          _buildCapabilitiesHighlight(context),
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
                'Our Work',
                style: TextStyle(fontSize: r.displayHeading, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: r.spacingM),
              Text(
                'Showcasing precision machined components across industries',
                style: TextStyle(fontSize: r.heroSubHeading, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context) {
    final r = Responsive.of(context);
    return Container(
      padding: r.filterSectionPadding,
      color: Colors.white,
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: r.maxContentWidth),
          child: Column(
            children: [
              Text(
                'Filter by Industry',
                style: TextStyle(fontSize: r.body + 2, fontWeight: FontWeight.w600, color: const Color(0xFF1a1a1a)),
              ),
              SizedBox(height: r.spacingM),
              Wrap(
                spacing: r.spacingS,
                runSpacing: r.spacingS,
                alignment: WrapAlignment.center,
                children: _categories.map((category) {
                  final isSelected = _selectedCategory == category;
                  return InkWell(
                    onTap: () => setState(() => _selectedCategory = category),
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      padding: r.filterChipPadding,
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF0d47a1) : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF0d47a1) : const Color(0xFFe0e0e0),
                          width: 2,
                        ),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          fontSize: r.body,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : const Color(0xFF666666),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGalleryGrid(BuildContext context) {
    final r = Responsive.of(context);
    return Container(
      padding: r.filterSectionPadding,
      color: const Color(0xFFf5f5f5),
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: r.maxContentWidth),
          child: GridView.count(
            crossAxisCount: r.galleryGridColumns,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: r.cardSpacing,
            mainAxisSpacing: r.cardSpacing,
            childAspectRatio: r.galleryItemAspectRatio,
            children: [
              _buildGalleryItem(r, 'Aerospace Bracket', 'Titanium Grade 5', 'Complex 5-axis milling with tight tolerances', Icons.flight),
              _buildGalleryItem(r, 'Medical Device Housing', 'Stainless Steel 316L', 'FDA compliant, precision turning and milling', Icons.local_hospital),
              _buildGalleryItem(r, 'Automotive Manifold', 'Aluminum 6061-T6', 'High-volume production, CNC milled', Icons.directions_car),
              _buildGalleryItem(r, 'Industrial Gear', 'Tool Steel', 'Heat treated, precision ground', Icons.settings),
              _buildGalleryItem(r, 'Connector Prototype', 'Brass C360', 'Rapid prototype for design validation', Icons.cable),
              _buildGalleryItem(r, 'Valve Body', 'Stainless Steel 304', 'Swiss machined with tight concentricity', Icons.water_drop),
              _buildGalleryItem(r, 'Actuator Housing', 'Aluminum 7075', 'Aerospace grade, anodized finish', Icons.straighten),
              _buildGalleryItem(r, 'Surgical Instrument', 'Titanium Grade 23', 'Medical grade, mirror finish', Icons.medical_services),
              _buildGalleryItem(r, 'Engine Component', 'Inconel 718', 'High-temp application, complex geometry', Icons.local_fire_department),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGalleryItem(Responsive r, String title, String material, String description, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(r.cardRadius),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: r.galleryImageHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF0d47a1).withValues(alpha: 0.7),
                  const Color(0xFF1976d2).withValues(alpha: 0.5),
                ],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(r.cardRadius),
                topRight: Radius.circular(r.cardRadius),
              ),
            ),
            child: Center(child: Icon(icon, size: r.galleryImageIcon, color: Colors.white.withValues(alpha: 0.8))),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(r.isMobile ? 14 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: r.heading3, fontWeight: FontWeight.bold, color: const Color(0xFF1a1a1a)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: r.spacingXS),
                  Row(
                    children: [
                      Icon(Icons.category, size: r.iconSmall - 2, color: const Color(0xFF0d47a1)),
                      SizedBox(width: r.spacingXS - 2),
                      Expanded(
                        child: Text(
                          material,
                          style: TextStyle(fontSize: r.caption + 1, color: const Color(0xFF0d47a1), fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: r.spacingXS),
                  Expanded(
                    child: Text(
                      description,
                      style: TextStyle(fontSize: r.caption + 1, color: const Color(0xFF666666), height: 1.4),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCapabilitiesHighlight(BuildContext context) {
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
                'What We Can Do For You',
                style: TextStyle(fontSize: r.heading1, fontWeight: FontWeight.bold, color: const Color(0xFF1a1a1a)),
              ),
              SizedBox(height: r.spacingXXL),
              r.isDesktop
                  ? Row(
                      children: [
                        Expanded(child: _buildCapabilityCard(r, 'Materials', '50+', 'metals, plastics, and composites')),
                        SizedBox(width: r.cardSpacing),
                        Expanded(child: _buildCapabilityCard(r, 'Tolerances', '±0.0005"', 'precision machining')),
                        SizedBox(width: r.cardSpacing),
                        Expanded(child: _buildCapabilityCard(r, 'Finishes', 'Any Spec', 'surface treatments available')),
                        SizedBox(width: r.cardSpacing),
                        Expanded(child: _buildCapabilityCard(r, 'Volume', '1-100k+', 'parts per run')),
                      ],
                    )
                  : r.isTablet
                      ? Wrap(
                          spacing: r.cardSpacing,
                          runSpacing: r.cardSpacing,
                          alignment: WrapAlignment.center,
                          children: [
                            SizedBox(width: 220, child: _buildCapabilityCard(r, 'Materials', '50+', 'metals, plastics, and composites')),
                            SizedBox(width: 220, child: _buildCapabilityCard(r, 'Tolerances', '±0.0005"', 'precision machining')),
                            SizedBox(width: 220, child: _buildCapabilityCard(r, 'Finishes', 'Any Spec', 'surface treatments available')),
                            SizedBox(width: 220, child: _buildCapabilityCard(r, 'Volume', '1-100k+', 'parts per run')),
                          ],
                        )
                      : Column(
                          children: [
                            _buildCapabilityCard(r, 'Materials', '50+', 'metals, plastics, and composites'),
                            SizedBox(height: r.spacingM),
                            _buildCapabilityCard(r, 'Tolerances', '±0.0005"', 'precision machining'),
                            SizedBox(height: r.spacingM),
                            _buildCapabilityCard(r, 'Finishes', 'Any Spec', 'surface treatments available'),
                            SizedBox(height: r.spacingM),
                            _buildCapabilityCard(r, 'Volume', '1-100k+', 'parts per run'),
                          ],
                        ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCapabilityCard(Responsive r, String label, String value, String description) {
    return Container(
      padding: EdgeInsets.all(r.isMobile ? 20 : 28),
      decoration: BoxDecoration(
        color: const Color(0xFFf5f5f5),
        borderRadius: BorderRadius.circular(r.cardRadius),
        border: Border.all(color: const Color(0xFFe0e0e0)),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: r.capabilityLabelFont, color: const Color(0xFF666666), fontWeight: FontWeight.w600, letterSpacing: 1)),
          SizedBox(height: r.spacingS),
          Text(value, style: TextStyle(fontSize: r.capabilityStatFont, fontWeight: FontWeight.bold, color: const Color(0xFF0d47a1))),
          SizedBox(height: r.spacingXS),
          Text(description, style: TextStyle(fontSize: r.capabilityLabelFont, color: const Color(0xFF666666)), textAlign: TextAlign.center),
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
              Text(
                'Ready to See Your Project Here?',
                style: TextStyle(fontSize: r.heading1, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: r.spacingM),
              Text(
                "Let's bring your designs to life with precision manufacturing",
                style: TextStyle(fontSize: r.body + 2, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: r.spacingL),
              ElevatedButton(
                onPressed: () => showQuoteDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF0d47a1),
                  padding: r.primaryButtonPadding,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                child: Text('Start Your Project', style: TextStyle(fontSize: r.buttonText, fontWeight: FontWeight.bold)),
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