import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

  // Store keys to measure the position of each nav item
  final Map<String, GlobalKey> _linkKeys = {
    '/': GlobalKey(),
    '/services': GlobalKey(),
    '/capabilities': GlobalKey(),
    '/about': GlobalKey(),
    '/gallery': GlobalKey(),
  };

  // Desktop properties
  double _indicatorLeft = 0;
  double _indicatorWidth = 0;

  // Mobile properties
  double _mobileIndicatorTop = 0;
  double _mobileIndicatorHeight = 0;

  bool _isFirstLoad = true;

  // 1. Add a variable to track the last known width to detect layout flips
  double? _lastWidth;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    // initialize keys for routes you use
    for (final r in ['/', '/services', '/capabilities', '/about', '/gallery']) {
      _linkKeys[r] = GlobalKey();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _updateIndicator());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CustomNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentRoute != widget.currentRoute) {
      // When switching pages, we want the animation
      _isFirstLoad = false; 
      WidgetsBinding.instance.addPostFrameCallback((_) => _updateIndicator());
    }
  }

   @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    final currentWidth = MediaQuery.of(context).size.width;
    
    // Check if we crossed the desktop/mobile breakpoint (1024)
    if (_lastWidth != null) {
      bool wasDesktop = _lastWidth! >= 1024;
      bool isDesktop = currentWidth >= 1024;
      
      if (wasDesktop != isDesktop) {
        // If we switched layouts, treat it as a "first load" 
        // so the bar snaps into place instead of sliding from a weird position
        _isFirstLoad = true;
      }
    }
    _lastWidth = currentWidth;

    // Trigger re-measurement after the layout has finished changing
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateIndicator());
  }

  // 2. Enhance _updateIndicator to be more resilient
  void _updateIndicator() {
    if (!mounted) return;

    final key = _linkKeys[widget.currentRoute];
    if (key == null || key.currentContext == null) {
      // If we are on mobile and the menu isn't open, we can't measure
      if (!_isMobileMenuOpen && MediaQuery.of(context).size.width < 1024) return;
      
      Future.delayed(const Duration(milliseconds: 50), _updateIndicator);
      return;
    }

    final RenderObject? renderObject = key.currentContext!.findRenderObject();
    final RenderStack? stackBox = key.currentContext!.findAncestorRenderObjectOfType<RenderStack>();

    if (renderObject is RenderBox && stackBox != null) {
      final position = renderObject.localToGlobal(Offset.zero, ancestor: stackBox);
      
      setState(() {
        _indicatorLeft = position.dx;
        _indicatorWidth = renderObject.size.width;
        _mobileIndicatorTop = position.dy;
        _mobileIndicatorHeight = renderObject.size.height;
      });
    }
  }

  void _toggleMobileMenu() {
    setState(() {
      _isMobileMenuOpen = !_isMobileMenuOpen;
      if (_isMobileMenuOpen) {
        _controller.forward();
        // Give the menu a moment to build before calculating position
        WidgetsBinding.instance.addPostFrameCallback((_) => _updateIndicator());
      } else {
        _controller.reverse();
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
      height: 70, // Fixed height to match AppShell padding
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
              child: SizedBox(
                width: 750, 
                child: Stack(
                  alignment: Alignment.bottomLeft,
                  children: [
                    // 1. Navigation Links 
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _NavBarLink(key: _linkKeys['/'], title: 'Home', route: '/', currentRoute: widget.currentRoute, onTap: _navigateTo),
                        _NavBarLink(key: _linkKeys['/services'], title: 'Services', route: '/services', currentRoute: widget.currentRoute, onTap: _navigateTo),
                        _NavBarLink(key: _linkKeys['/capabilities'], title: 'Capabilities', route: '/capabilities', currentRoute: widget.currentRoute, onTap: _navigateTo),
                        _NavBarLink(key: _linkKeys['/about'], title: 'About Us', route: '/about', currentRoute: widget.currentRoute, onTap: _navigateTo),
                        _NavBarLink(key: _linkKeys['/gallery'], title: 'Gallery', route: '/gallery', currentRoute: widget.currentRoute, onTap: _navigateTo),
                        const SizedBox(width: 24),
                        _buildContactButton(),
                      ],
                    ),
                    
                    // 2. Sliding Indicator
                    AnimatedPositioned(
                      // If width is 0, keep it invisible. 
                      // If it's the first load, use 0 duration to snap into place.
                      duration: _indicatorWidth == 0 || _isFirstLoad 
                          ? Duration.zero 
                          : const Duration(milliseconds: 350),
                      curve: Curves.easeOutCubic,
                      left: _indicatorLeft,
                      bottom: 0, // Adjusted for typical text baseline
                      child: Opacity(
                        // Hide the bar until it has a measured width
                        opacity: _indicatorWidth == 0 ? 0 : 1,
                        child: AnimatedContainer(
                          duration: _indicatorWidth == 0 || _isFirstLoad 
                              ? Duration.zero 
                              : const Duration(milliseconds: 350),
                          curve: Curves.easeOutCubic,
                          width: _indicatorWidth,
                          height: 3,
                          decoration: BoxDecoration(
                            color: ShopStyles.primaryBlue,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
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
                  child: Stack( // Added Stack for vertical indicator
                    children: [
                      // MOBILE VERTICAL INDICATOR
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeOutCubic,
                        top: _mobileIndicatorTop,
                        left: 0,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeOutCubic,
                          width: 4,
                          height: _mobileIndicatorHeight,
                          color: ShopStyles.primaryBlue,
                        ),
                      ),
                      Column(
                        children: [
                          _MobileNavBarLink(key: _linkKeys['/'], title: 'Home', route: '/', currentRoute: widget.currentRoute, onTap: _handleMobileTap),
                          _MobileNavBarLink(key: _linkKeys['/services'], title: 'Services', route: '/services', currentRoute: widget.currentRoute, onTap: _handleMobileTap),
                          _MobileNavBarLink(key: _linkKeys['/capabilities'], title: 'Capabilities', route: '/capabilities', currentRoute: widget.currentRoute, onTap: _handleMobileTap),
                          _MobileNavBarLink(key: _linkKeys['/about'], title: 'About Us', route: '/about', currentRoute: widget.currentRoute, onTap: _handleMobileTap),
                          _MobileNavBarLink(key: _linkKeys['/gallery'], title: 'Gallery', route: '/gallery', currentRoute: widget.currentRoute, onTap: _handleMobileTap),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: SizedBox(width: double.infinity, child: _buildContactButton()),
                          ),
                        ],
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

  const _NavBarLink({super.key, required this.title, required this.route, required this.currentRoute, required this.onTap});

  @override
  State<_NavBarLink> createState() => _NavBarLinkState();
}

class _NavBarLinkState extends State<_NavBarLink> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isActive = widget.currentRoute == widget.route;

    return InkWell(
      onTap: () => widget.onTap(widget.route),
      // Triggered when finger/mouse touches down
      onTapDown: (_) => setState(() => _isPressed = true),
      // Triggered when finger/mouse lifts up
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap(widget.route);
      },
      // Triggered if user slides finger away without lifting
      onTapCancel: () => setState(() => _isPressed = false),
      onHover: (hovering) => setState(() => _isHovered = hovering),
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: _isHovered ? Colors.white24 : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: AnimatedScale(
          // Shrink to 92% size when pressed
          scale: _isPressed ? 0.92 : 1.0, 
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeInOut,
          child: Text(
            widget.title,
            style: ShopStyles.navLink.copyWith(
              color: (isActive || _isHovered) ? Colors.white : ShopStyles.textSecondary,
              shadows: _isHovered && !isActive
                  ? [Shadow(color: Colors.white.withValues(alpha: 0.3), blurRadius: 8)]
                  : null,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
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

  const _MobileNavBarLink({super.key, required this.title, required this.route, required this.currentRoute, required this.onTap});

  @override
  State<_MobileNavBarLink> createState() => _MobileNavBarLinkState();
}

class _MobileNavBarLinkState extends State<_MobileNavBarLink> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isActive = widget.currentRoute == widget.route;

    return InkWell(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap(widget.route);
      },
      onTapCancel: () => setState(() => _isPressed = false),
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
              color: _isHovered ? Colors.white24 : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: AnimatedScale(
          // Shrink slightly on press
          scale: _isPressed ? 0.96 : 1.0,
          duration: const Duration(milliseconds: 100),
          alignment: Alignment.centerLeft, // Keep text aligned to the left while scaling
          child: Text(
            widget.title,
            style: ShopStyles.navLink.copyWith(
              color: (isActive || _isHovered) ? Colors.white : ShopStyles.textSecondary,
              fontSize: 18,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}