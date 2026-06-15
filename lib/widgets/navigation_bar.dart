import 'package:flutter/material.dart';
import 'package:mv/widgets/contacts.dart';
import 'package:mv/widgets/styles.dart';
import 'package:mv/widgets/quote_form.dart';

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

class _CustomNavigationBarState extends State<CustomNavigationBar> 
  with SingleTickerProviderStateMixin {
  bool _isMobileMenuOpen = false;
  late AnimationController _controller; // Controller for the menu icon

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleMobileMenu() {
    setState(() {
      _isMobileMenuOpen = !_isMobileMenuOpen;
      if (_isMobileMenuOpen) {
        _controller.forward(); // Plays menu -> close
      } else {
        _controller.reverse(); // Plays close -> menu
      }
    });
  }

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
    return Container(
      height: 80, // Fixed height to match AppShell padding
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildLogo(),
          const SizedBox(width: 20),
          // FIXED OVERFLOW: Wrapped links in Flexible + FittedBox
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileNav() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      key: const ValueKey('mobile'), // Key needed for AnimatedSwitcher
      children: [
        Container(
          height: 70, 
          padding: const EdgeInsets.only(right: 16, top: 0, bottom: 0, left: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLogo(),
              IconButton(
                // 2. Use AnimatedIcon for the button switch
                icon: AnimatedIcon(
                  icon: AnimatedIcons.menu_close,
                  progress: _controller,
                  color: Colors.white,
                  size: 28,
                ),
                onPressed: _toggleMobileMenu,
              ),
            ],
          ),
        ),
        // 3. Use AnimatedSize for smooth expansion of the menu
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: _isMobileMenuOpen
              ? Container(
                  width: double.infinity,
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
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }

  void _handleMobileTap(String route) {
    _navigateTo(route);
     _toggleMobileMenu(); // Close the menu smoothly
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

  // 4. Enhanced Hover Animation for the CTA Button
  bool _isCtaHovered = false;

  Widget _buildContactButton() {
    return MouseRegion(
      onEnter: (_) => setState(() => _isCtaHovered = true),
      onExit: (_) => setState(() => _isCtaHovered = false),
      child: AnimatedScale(
        scale: _isCtaHovered ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: ElevatedButton(
          onPressed: () => showQuoteDialog(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0066cc),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            elevation: _isCtaHovered ? 8 : 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('GET A QUOTE', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
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
    // 1. Close any open Dialogs using the root navigator
    // This is the most common cause of PopScope GlobalKey crashes on Web
    final nav = Navigator.of(context, rootNavigator: true);
    if (nav.canPop()) {
      nav.pop();
    }

    // 2. Close mobile menu if it's open
    if (_isMobileMenuOpen) {
      _toggleMobileMenu();
    }

    // 3. Navigate
    widget.onNavigate(route);
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