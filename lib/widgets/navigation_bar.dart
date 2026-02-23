import 'dart:ui' as html;

import 'package:flutter/material.dart';
import 'package:mv/widgets/contacts.dart';
import 'package:mv/widgets/styles.dart';

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
      width: double.infinity,
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      constraints: const BoxConstraints(maxWidth: 1400),
      margin: const EdgeInsets.symmetric(horizontal: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo/Brand - wrapped in Flexible to prevent overflow
          Flexible(
            flex: 0,
            child: _buildLogo(),
          ),

          // Add some spacing
          const SizedBox(width: 16),

          // Navigation Links - wrapped in Flexible and Expanded to handle overflow
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                _NavBarLink(title: 'Home', route: '/', currentRoute: widget.currentRoute, onTap: _navigateTo),
                _NavBarLink(title: 'Services', route: '/services', currentRoute: widget.currentRoute, onTap: _navigateTo),
                _NavBarLink(title: 'Capabilities', route: '/capabilities', currentRoute: widget.currentRoute, onTap: _navigateTo),
                _NavBarLink(title: 'About Us', route: '/about', currentRoute: widget.currentRoute, onTap: _navigateTo),
                _NavBarLink(title: 'Gallery', route: '/gallery', currentRoute: widget.currentRoute, onTap: _navigateTo),
                const SizedBox(width: 24),
                _buildContactButton(),
              ],
            ),
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
                 _MobileNavBarLink(title: 'Home', route: '/', currentRoute: widget.currentRoute, onTap: _handleMobileTap),
                _MobileNavBarLink(title: 'Services', route: '/services', currentRoute: widget.currentRoute, onTap: _handleMobileTap),
                _MobileNavBarLink(title: 'Capabilities', route: '/capabilities', currentRoute: widget.currentRoute, onTap: _handleMobileTap),
                _MobileNavBarLink(title: 'About Us', route: '/about', currentRoute: widget.currentRoute, onTap: _handleMobileTap),
                _MobileNavBarLink(title: 'Gallery', route: '/gallery', currentRoute: widget.currentRoute, onTap: _handleMobileTap),
                
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(width: double.infinity, child: _buildContactButton()),
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _handleMobileTap(String route) {
    _navigateTo(route);
    setState(() => _isMobileMenuOpen = false);
  }

  Widget _buildLogo() {
    return InkWell(
      onTap: () => _navigateTo('/'),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
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
                CompanyContact.name,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                CompanyContact.tagline,
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
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 4),
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
          style: ShopStyles.navLink.copyWith(
            color: isActive ? ShopStyles.textMain : ShopStyles.textSecondary,
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
          color: isActive ? Colors.white.withValues(alpha: 0.05) : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: isActive ? ShopStyles.primaryBlue : Colors.transparent,
              width: 4,
            ),
          ),
        ),
        child: Text(
          title,
          style: ShopStyles.navLink.copyWith(
            color: isActive ? Colors.white : ShopStyles.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildContactButton() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: ElevatedButton(
          onPressed: _showQuoteForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0066cc),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            elevation: 4,
            shadowColor: Colors.black.withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ).copyWith(
            // Adds a slight color change on hover automatically
            overlayColor: WidgetStateProperty.resolveWith<Color?>(
              (states) {
                if (states.contains(WidgetState.hovered)) return Colors.blue.shade700;
                return null;
              },
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'GET A QUOTE',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward_rounded, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateTo(String route) {
    // Prevent navigating to the same page we are already on
    if (widget.currentRoute == route) return;

    // Use pushReplacementNamed so the user can't hit "back" 
    // and see the exact same navbar state on a duplicate page.
    Navigator.pushNamed(context, route);
  }

  void _showQuoteForm() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(32),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text('Request a Quote', style: ShopStyles.heading),
                const SizedBox(height: 8),
                Text(
                  'Submit your requirements or contact us directly at ${CompanyContact.phone}',
                  style: ShopStyles.body,
                ),
                
                const Divider(height: 40),

                // Form Fields
                _buildTextField('Full Name', Icons.person_outline),
                const SizedBox(height: 16),
                _buildTextField('Email Address', Icons.email_outlined),
                const SizedBox(height: 16),
                _buildTextField('Project Details', Icons.description_outlined, maxLines: 3),
                
                const SizedBox(height: 24),
                
                // Action Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ShopStyles.primaryButton,
                    child: const Text('Send Inquiry'),
                  ),
                ),

                const SizedBox(height: 24),

                // Detailed Shop Info at bottom of dialog
                const Text(
                  'Shop Location & Hours:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(CompanyContact.fullAddress, style: ShopStyles.body),
                Text('Mon-Fri: ${CompanyContact.operatingHours["Monday - Friday"]}', style: ShopStyles.body),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, {int maxLines = 1}) {
    return TextFormField(
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF0066cc), width: 2),
        ),
      ),
    );
  }
}

class _NavBarLink extends StatefulWidget {
  final String title;
  final String route;
  final String currentRoute;
  final Function(String) onTap;

  const _NavBarLink({required this.title, required this.route, required this.currentRoute, required this.onTap});

  @override
  State<_NavBarLink> createState() => _NavBarLinkState();
}

class _NavBarLinkState extends State<_NavBarLink> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isActive = widget.currentRoute == widget.route;

    return InkWell(
      onTap: () => widget.onTap(widget.route),
      onHover: (hovering) => setState(() => _isHovered = hovering),
      overlayColor: WidgetStateProperty.all(Colors.transparent), // Remove default splash
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? ShopStyles.primaryBlue : (_isHovered ? Colors.white24 : Colors.transparent),
              width: 3,
            ),
          ),
        ),
        child: Text(
          widget.title,
          style: ShopStyles.navLink.copyWith(
            // Logic: If active or hovered, text is white. Otherwise, it's grey.
            color: (isActive || _isHovered) ? Colors.white : ShopStyles.textSecondary,
            // Add a subtle shadow glow when hovered
            shadows: _isHovered && !isActive
                ? [Shadow(color: Colors.white.withValues(alpha: 0.3), blurRadius: 8)]
                : null,
          ),
        ),
      ),
    );
  }
}

class _MobileNavBarLink extends StatefulWidget {
  final String title;
  final String route;
  final String currentRoute;
  final Function(String) onTap;

  const _MobileNavBarLink({required this.title, required this.route, required this.currentRoute, required this.onTap});

  @override
  State<_MobileNavBarLink> createState() => _MobileNavBarLinkState();
}

class _MobileNavBarLinkState extends State<_MobileNavBarLink> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isActive = widget.currentRoute == widget.route;

    return InkWell(
      onTap: () => widget.onTap(widget.route),
      onHover: (value) => setState(() => _isHovered = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          // HIGHLIGHT LOGIC:
          // 1. If active: Solid light highlight
          // 2. If hovering: Faint highlight
          // 3. Otherwise: Transparent
          color: isActive 
              ? Colors.white.withValues(alpha: 0.12) 
              : (_isHovered ? Colors.white.withValues(alpha: 0.05) : Colors.transparent),
          border: Border(
            left: BorderSide(
              color: isActive ? ShopStyles.primaryBlue : Colors.transparent,
              width: 4,
            ),
          ),
        ),
        child: Text(
          widget.title,
          style: ShopStyles.navLink.copyWith(
            color: (isActive || _isHovered) ? Colors.white : ShopStyles.textSecondary,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}