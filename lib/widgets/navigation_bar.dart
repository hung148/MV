import 'package:flutter/material.dart';

class CustomNavigationBar extends StatefulWidget {
  final String currentRoute;

  const CustomNavigationBar({
    super.key,
    required this.currentRoute,
  });

  @override
  State<CustomNavigationBar> createState() => _CustomNavigationBarState();
}

class _CustomNavigationBarState extends State<CustomNavigationBar> {
  bool _isMobileMenuOpen = false;

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a1a), // Dark professional color
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: isDesktop ? _buildDesktopNav() : _buildMobileNav(),
    );
  }

  Widget _buildDesktopNav() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 0),
      constraints: const BoxConstraints(maxWidth: 1400),
      margin: const EdgeInsets.symmetric(horizontal: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo/Brand
          _buildLogo(),

          // Navigation Links
          Row(
            children: [
              _buildNavLink('Home', '/'),
              const SizedBox(width: 32),
              _buildNavLink('Services', '/services'),
              const SizedBox(width: 32),
              _buildNavLink('Capabilities', '/capabilities'),
              const SizedBox(width: 32),
              _buildNavLink('About Us', '/about'),
              const SizedBox(width: 32),
              _buildNavLink('Gallery', '/gallery'),
              const SizedBox(width: 40),
              _buildContactButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileNav() {
    return Column(
      children: [
        // Mobile Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLogo(),
              IconButton(
                icon: Icon(
                  _isMobileMenuOpen ? Icons.close : Icons.menu,
                  color: Colors.white,
                  size: 28,
                ),
                onPressed: () {
                  setState(() {
                    _isMobileMenuOpen = !_isMobileMenuOpen;
                  });
                },
              ),
            ],
          ),
        ),

        // Mobile Menu Dropdown
        if (_isMobileMenuOpen)
          Container(
            color: const Color(0xFF2a2a2a),
            child: Column(
              children: [
                _buildMobileNavLink('Home', '/'),
                _buildMobileNavLink('Services', '/services'),
                _buildMobileNavLink('Capabilities', '/capabilities'),
                _buildMobileNavLink('About Us', '/about'),
                _buildMobileNavLink('Gallery', '/gallery'),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildContactButton(),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildLogo() {
    return InkWell(
      onTap: () => _navigateTo('/'),
      child: Row(
        children: [
          // You can replace this with an actual logo image
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF0066cc),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Center(
              child: Text(
                'MV',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'MV Machine Shop',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'CNC & Precision Manufacturing',
                style: TextStyle(
                  color: Color(0xFF999999),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavLink(String title, String route) {
    final isActive = widget.currentRoute == route;

    return InkWell(
      onTap: () => _navigateTo(route),
      onHover: (hovering) {
        // You can add hover state if needed
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? const Color(0xFF0066cc) : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFFcccccc),
            fontSize: 15,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  Widget _buildMobileNavLink(String title, String route) {
    final isActive = widget.currentRoute == route;

    return InkWell(
      onTap: () {
        _navigateTo(route);
        setState(() {
          _isMobileMenuOpen = false;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF333333) : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: isActive ? const Color(0xFF0066cc) : Colors.transparent,
              width: 4,
            ),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFFcccccc),
            fontSize: 16,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildContactButton() {
    return ElevatedButton(
      onPressed: () {
        // Scroll to contact section or open contact dialog
        _showContactDialog();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0066cc),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        elevation: 0,
      ),
      child: const Text(
        'Get a Quote',
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _navigateTo(String route) {
    // For now, just print. You'll implement actual navigation later
    print('Navigate to: $route');
    
    // When you set up routing, you'll use:
    // Navigator.pushNamed(context, route);
    // or for web:
    // html.window.history.pushState(null, '', route);
  }

  void _showContactDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Us'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Phone: (555) 123-4567'),
            SizedBox(height: 8),
            Text('Email: info@mvmachineshop.com'),
            SizedBox(height: 8),
            Text('Hours: Mon-Fri 8AM-5PM'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}