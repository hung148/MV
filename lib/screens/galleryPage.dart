import 'package:flutter/material.dart';
import 'package:mv/widgets/navigation_bar.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Aerospace',
    'Medical',
    'Automotive',
    'Industrial',
    'Prototypes',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, 
        children: [
          const CustomNavigationBar(currentRoute: '/gallery'),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeroSection(),
                  _buildFilterSection(),
                  _buildGalleryGrid(),
                  _buildCapabilitiesHighlight(),
                  _buildCTASection(),
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF0d47a1),
            const Color(0xFF1976d2),
          ],
        ),
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              const Text(
                'Our Work',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Showcasing precision machined components across industries',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      color: Colors.white,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              const Text(
                'Filter by Industry',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1a1a1a),
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: _categories.map((category) {
                  final isSelected = _selectedCategory == category;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
                          fontSize: 15,
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

  Widget _buildGalleryGrid() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      color: const Color(0xFFf5f5f5),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth > 900 
                  ? 3 
                  : constraints.maxWidth > 600 
                      ? 2 
                      : 1;
              
              return GridView.count(
                crossAxisCount: columns,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
                childAspectRatio: 0.9,
                children: [
                  _buildGalleryItem(
                    'Aerospace Bracket',
                    'Titanium Grade 5',
                    'Complex 5-axis milling with tight tolerances',
                    Icons.flight,
                  ),
                  _buildGalleryItem(
                    'Medical Device Housing',
                    'Stainless Steel 316L',
                    'FDA compliant, precision turning and milling',
                    Icons.local_hospital,
                  ),
                  _buildGalleryItem(
                    'Automotive Manifold',
                    'Aluminum 6061-T6',
                    'High-volume production, CNC milled',
                    Icons.directions_car,
                  ),
                  _buildGalleryItem(
                    'Industrial Gear',
                    'Tool Steel',
                    'Heat treated, precision ground',
                    Icons.settings,
                  ),
                  _buildGalleryItem(
                    'Connector Prototype',
                    'Brass C360',
                    'Rapid prototype for design validation',
                    Icons.cable,
                  ),
                  _buildGalleryItem(
                    'Valve Body',
                    'Stainless Steel 304',
                    'Swiss machined with tight concentricity',
                    Icons.water_drop,
                  ),
                  _buildGalleryItem(
                    'Actuator Housing',
                    'Aluminum 7075',
                    'Aerospace grade, anodized finish',
                    Icons.straighten,
                  ),
                  _buildGalleryItem(
                    'Surgical Instrument',
                    'Titanium Grade 23',
                    'Medical grade, mirror finish',
                    Icons.medical_services,
                  ),
                  _buildGalleryItem(
                    'Engine Component',
                    'Inconel 718',
                    'High-temp application, complex geometry',
                    Icons.local_fire_department,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildGalleryItem(
    String title,
    String material,
    String description,
    IconData icon,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Placeholder
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF0d47a1).withValues(alpha: 0.7),
                  const Color(0xFF1976d2).withValues(alpha: 0.5),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Center(
              child: Icon(
                icon,
                size: 80,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1a1a1a),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.category,
                        size: 14,
                        color: Color(0xFF0d47a1),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          material,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF0d47a1),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                        height: 1.4,
                      ),
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

  Widget _buildCapabilitiesHighlight() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      color: Colors.white,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              const Text(
                'What We Can Do For You',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1a1a1a),
                ),
              ),
              const SizedBox(height: 60),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 768;
                  if (isWide) {
                    return Row(
                      children: [
                        Expanded(child: _buildCapabilityCard('Materials', '50+', 'metals, plastics, and composites')),
                        const SizedBox(width: 24),
                        Expanded(child: _buildCapabilityCard('Tolerances', '±0.0005"', 'precision machining')),
                        const SizedBox(width: 24),
                        Expanded(child: _buildCapabilityCard('Finishes', 'Any Spec', 'surface treatments available')),
                        const SizedBox(width: 24),
                        Expanded(child: _buildCapabilityCard('Volume', '1-100k+', 'parts per run')),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        _buildCapabilityCard('Materials', '50+', 'metals, plastics, and composites'),
                        const SizedBox(height: 20),
                        _buildCapabilityCard('Tolerances', '±0.0005"', 'precision machining'),
                        const SizedBox(height: 20),
                        _buildCapabilityCard('Finishes', 'Any Spec', 'surface treatments available'),
                        const SizedBox(height: 20),
                        _buildCapabilityCard('Volume', '1-100k+', 'parts per run'),
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

  Widget _buildCapabilityCard(String label, String value, String description) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFFf5f5f5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFe0e0e0)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0d47a1),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF666666),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCTASection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      color: const Color(0xFF0d47a1),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              const Text(
                'Ready to See Your Project Here?',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Let\'s bring your designs to life with precision manufacturing',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF0d47a1),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: const Text(
                  'Start Your Project',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      color: const Color(0xFF1a1a1a),
      child: const Center(
        child: Text(
          '© 2024 MV Machine Shop. All rights reserved.',
          style: TextStyle(color: Color(0xFF999999), fontSize: 14),
        ),
      ),
    );
  }
}