import 'package:flutter/material.dart';
import 'package:mv/widgets/contacts.dart';
import 'package:mv/widgets/styles.dart';

class CustomNavigationBar extends StatefulWidget {
  final String currentRoute;
  final void Function(String route) onNavigate;

  const CustomNavigationBar({
    super.key,
    required this.currentRoute,
    required this.onNavigate,
  });

  @override
  State<CustomNavigationBar> createState() => _CustomNavigationBarState();
}

class _CustomNavigationBarState extends State<CustomNavigationBar> {
  bool _isMobileMenuOpen = false;

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a1a),
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
    return Row(
      children: [
        _buildLogo(),
        const SizedBox(width: 16),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _NavBarLink(title: 'Home', route: '/', currentRoute: widget.currentRoute, onTap: _navigateTo),
              _NavBarLink(title: 'Services', route: '/services', currentRoute: widget.currentRoute, onTap: _navigateTo),
              _NavBarLink(title: 'Capabilities', route: '/capabilities', currentRoute: widget.currentRoute, onTap: _navigateTo),
              _NavBarLink(title: 'About Us', route: '/about', currentRoute: widget.currentRoute, onTap: _navigateTo),
              _NavBarLink(title: 'Gallery', route: '/gallery', currentRoute: widget.currentRoute, onTap: _navigateTo),
              const SizedBox(width: 24),
              _buildContactButton(),
              const SizedBox(width: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileNav() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 16, top: 0, bottom: 0, left: 0),
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
        children: [
          Image.asset(
            'assets/logo/MV-Manufacturing.png',
            width: 100,
            height: 60,
            fit: BoxFit.fill,
          ),
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

  // Delegates to AppShell's _navigateTo
  void _navigateTo(String route) {
    widget.onNavigate(route);
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
                Text('Request a Quote', style: ShopStyles.heading),
                const SizedBox(height: 8),
                Text(
                  'Submit your requirements or contact us directly at ${CompanyContact.phone}',
                  style: ShopStyles.body,
                ),
                const Divider(height: 40),
                _buildTextField('Full Name', Icons.person_outline),
                const SizedBox(height: 16),
                _buildTextField('Email Address', Icons.email_outlined),
                const SizedBox(height: 16),
                _buildTextField('Project Details', Icons.description_outlined, maxLines: 3),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ShopStyles.primaryButton,
                    child: const Text('Send Inquiry'),
                  ),
                ),
                const SizedBox(height: 24),
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
      overlayColor: WidgetStateProperty.all(Colors.transparent),
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
            color: (isActive || _isHovered) ? Colors.white : ShopStyles.textSecondary,
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