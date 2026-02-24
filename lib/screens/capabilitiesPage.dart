import 'package:flutter/material.dart';
import 'package:mv/widgets/contacts.dart';
import 'package:mv/widgets/navigation_bar.dart';
import 'package:mv/widgets/styles.dart';

class CapabilitiesPage extends StatelessWidget {
  const CapabilitiesPage({super.key});

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
            child: Form( // 1. Bọc toàn bộ vào Form
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

                  // Trường Họ Tên - Max 50 ký tự
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

                  // Trường Email - Max 100 ký tự + Kiểm tra định dạng email
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

                  // Trường Nội dung - Max 1000 ký tự
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
                        // 2. Kiểm tra tính hợp lệ trước khi gửi
                        if (formKey.currentState!.validate()) {
                          // Nếu OK -> Đóng và thông báo
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
                  // ... (Phần thông tin liên hệ bên dưới giữ nguyên)
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
    String? Function(String?)? validator, // Thêm validator
    int? maxLength,                        // Thêm maxLength
  }) {
    return TextFormField(
      maxLines: maxLines,
      maxLength: maxLength, // Gán giới hạn độ dài
      validator: validator, // Gán logic kiểm tra
      decoration: InputDecoration(
        counterText: "", // Ẩn bộ đếm 0/50 bên dưới cho đẹp
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, 
        children: [
          const CustomNavigationBar(currentRoute: '/capabilities'),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeroSection(),
                  _buildEquipmentSection(),
                  _buildMaterialsSection(),
                  _buildTolerancesSection(),
                  _buildCapacitySection(),
                  _buildCertificationsSection(),
                  _buildCTASection(context),
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
                'Our Capabilities',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'State-of-the-art equipment and expertise to handle your most demanding projects',
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

  Widget _buildEquipmentSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      color: Colors.white,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              const Text(
                'Our Equipment',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1a1a1a),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Advanced CNC machines for precision manufacturing',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF666666),
                ),
              ),
              const SizedBox(height: 60),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 900;
                  return Wrap(
                    spacing: 24,
                    runSpacing: 24,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildEquipmentCard(
                        title: '5-Axis CNC Mills',
                        specs: [
                          'Travel: 40" x 20" x 20"',
                          'Spindle speed: 12,000 RPM',
                          'Tool capacity: 60 tools',
                          'Tolerance: ±0.0005"',
                        ],
                        icon: Icons.view_in_ar,
                        width: isWide ? 360 : double.infinity,
                      ),
                      _buildEquipmentCard(
                        title: 'CNC Turning Centers',
                        specs: [
                          'Max diameter: 12"',
                          'Max length: 24"',
                          'Live tooling capable',
                          'Sub-spindle equipped',
                        ],
                        icon: Icons.rotate_90_degrees_ccw,
                        width: isWide ? 360 : double.infinity,
                      ),
                      _buildEquipmentCard(
                        title: 'Swiss-Type Lathes',
                        specs: [
                          'Bar capacity: 1.25"',
                          'Live tooling: 12 positions',
                          'Sub-spindle capable',
                          'High-volume production',
                        ],
                        icon: Icons.precision_manufacturing,
                        width: isWide ? 360 : double.infinity,
                      ),
                      _buildEquipmentCard(
                        title: 'Wire EDM',
                        specs: [
                          'Wire diameter: 0.004" - 0.012"',
                          'Tolerance: ±0.0002"',
                          'Surface finish: Ra 8',
                          'Hardened materials capable',
                        ],
                        icon: Icons.bolt,
                        width: isWide ? 360 : double.infinity,
                      ),
                      _buildEquipmentCard(
                        title: 'CMM Inspection',
                        specs: [
                          'Measuring volume: 24" x 24" x 16"',
                          'Accuracy: 0.0001"',
                          'Contact and optical probing',
                          'Full dimensional reports',
                        ],
                        icon: Icons.straighten,
                        width: isWide ? 360 : double.infinity,
                      ),
                      _buildEquipmentCard(
                        title: 'Surface Grinding',
                        specs: [
                          'Capacity: 24" x 12" x 12"',
                          'Tolerance: ±0.0002"',
                          'Surface finish: Ra 4',
                          'Magnetic and vacuum chucks',
                        ],
                        icon: Icons.grid_on,
                        width: isWide ? 360 : double.infinity,
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

  Widget _buildEquipmentCard({
    required String title,
    required List<String> specs,
    required IconData icon,
    double? width,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFe0e0e0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 36, color: const Color(0xFF0d47a1)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1a1a1a),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...specs.map((spec) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '• ',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF0d47a1),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        spec,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF333333),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildMaterialsSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      color: const Color(0xFFf5f5f5),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              const Text(
                'Materials We Machine',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1a1a1a),
                ),
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
                      _buildMaterialCategory(
                        'Metals',
                        [
                          'Aluminum (all alloys)',
                          'Stainless Steel (300/400 series)',
                          'Steel (mild, tool, alloy)',
                          'Titanium (Grade 2, 5)',
                          'Brass & Bronze',
                          'Copper',
                          'Inconel & Hastelloy',
                        ],
                        width: isWide ? 360 : double.infinity,
                      ),
                      _buildMaterialCategory(
                        'Plastics',
                        [
                          'PEEK',
                          'Delrin (Acetal)',
                          'Nylon',
                          'PTFE (Teflon)',
                          'Polycarbonate',
                          'UHMW',
                          'Ultem',
                        ],
                        width: isWide ? 360 : double.infinity,
                      ),
                      _buildMaterialCategory(
                        'Specialty Materials',
                        [
                          'Carbon Fiber',
                          'G10/FR4',
                          'Ceramics',
                          'Graphite',
                          'Exotic alloys',
                          'Medical-grade materials',
                        ],
                        width: isWide ? 360 : double.infinity,
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

  Widget _buildMaterialCategory(String title, List<String> materials, {double? width}) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0d47a1),
            ),
          ),
          const SizedBox(height: 20),
          ...materials.map((material) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, size: 18, color: Color(0xFF0d47a1)),
                    const SizedBox(width: 8),
                    Text(
                      material,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildTolerancesSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      color: Colors.white,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              const Text(
                'Precision & Tolerances',
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
                        Expanded(child: _buildToleranceCard('Linear Tolerances', '±0.0005"', 'Standard tight tolerance capability')),
                        const SizedBox(width: 24),
                        Expanded(child: _buildToleranceCard('Angular Tolerances', '±0.25°', 'Precise angular measurements')),
                        const SizedBox(width: 24),
                        Expanded(child: _buildToleranceCard('Surface Finish', 'Ra 4-8 µin', 'Excellent surface quality')),
                        const SizedBox(width: 24),
                        Expanded(child: _buildToleranceCard('Roundness', '0.0002"', 'Exceptional circularity')),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        _buildToleranceCard('Linear Tolerances', '±0.0005"', 'Standard tight tolerance capability'),
                        const SizedBox(height: 16),
                        _buildToleranceCard('Angular Tolerances', '±0.25°', 'Precise angular measurements'),
                        const SizedBox(height: 16),
                        _buildToleranceCard('Surface Finish', 'Ra 4-8 µin', 'Excellent surface quality'),
                        const SizedBox(height: 16),
                        _buildToleranceCard('Roundness', '0.0002"', 'Exceptional circularity'),
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

  Widget _buildToleranceCard(String title, String value, String description) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0d47a1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCapacitySection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      color: const Color(0xFFf5f5f5),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              const Text(
                'Production Capacity',
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
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildCapacityStat('Prototype', 'to Production', Icons.inventory),
                        _buildCapacityStat('1-100,000+', 'Parts/Month', Icons.speed),
                        _buildCapacityStat('24/7', 'Operations', Icons.access_time),
                        _buildCapacityStat('15+', 'CNC Machines', Icons.precision_manufacturing),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        _buildCapacityStat('Prototype', 'to Production', Icons.inventory),
                        const SizedBox(height: 32),
                        _buildCapacityStat('1-100,000+', 'Parts/Month', Icons.speed),
                        const SizedBox(height: 32),
                        _buildCapacityStat('24/7', 'Operations', Icons.access_time),
                        const SizedBox(height: 32),
                        _buildCapacityStat('15+', 'CNC Machines', Icons.precision_manufacturing),
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

  Widget _buildCapacityStat(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 48, color: const Color(0xFF0d47a1)),
        const SizedBox(height: 16),
        Text(
          value,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1a1a1a),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF666666),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCertificationsSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      color: Colors.white,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              const Text(
                'Certifications & Quality',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1a1a1a),
                ),
              ),
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
                    childAspectRatio: 1.8,
                    children: [
                      _buildCertCard('ISO 9001:2015', 'Quality Management'),
                      _buildCertCard('AS9100D', 'Aerospace Quality'),
                      _buildCertCard('ITAR Registered', 'Defense Compliance'),
                      _buildCertCard('ISO 13485', 'Medical Devices'),
                      _buildCertCard('PPAP Level 3', 'Automotive Standards'),
                      _buildCertCard('RoHS Compliant', 'Environmental Standards'),
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

  Widget _buildCertCard(String title, String description) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF0d47a1), width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.verified, size: 36, color: Color(0xFF0d47a1)),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1a1a1a),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
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

  Widget _buildCTASection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      color: const Color(0xFF0d47a1),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              const Text(
                'Put Our Capabilities to Work',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Let us handle your most challenging manufacturing projects',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => _showQuoteForm(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF0d47a1),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: const Text(
                  'Get Started',
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
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              const Divider(color: Color(0xFF333333)),
              const SizedBox(height: 20),
              Text(
                '© ${DateTime.now().year} ${CompanyContact.name}. All rights reserved.',
                style: const TextStyle(
                  color: Color(0xFF999999),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '${CompanyContact.fullAddress} | ${CompanyContact.phone}',
                style: const TextStyle(
                  color: Color(0xFF666666),
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}