import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mv/widgets/contacts.dart';
import 'package:mv/widgets/styles.dart';
import 'package:mv/widgets/quote_form.dart';

class CustomNavigationBar extends StatefulWidget {
  final String currentRoute;
  final void Function(String route) onNavigate;
  final void Function(bool isOpen)? onMobileMenuChanged;

  const CustomNavigationBar({
    super.key,
    required this.currentRoute,
    required this.onNavigate,
    this.onMobileMenuChanged,
  });

  @override
  State<CustomNavigationBar> createState() => CustomNavigationBarState();
}

class CustomNavigationBarState extends State<CustomNavigationBar>
    with SingleTickerProviderStateMixin {
  bool _isMobileMenuOpen = false;
  late AnimationController _controller;

  final Map<String, GlobalKey> _linkKeys = {
    '/': GlobalKey(),
    '/services': GlobalKey(),
    '/capabilities': GlobalKey(),
    '/about': GlobalKey(),
    '/gallery': GlobalKey(),
  };

  // Desktop indicator
  double _indicatorLeft = 0;
  double _indicatorWidth = 0;

  // Mobile indicator
  double _mobileIndicatorTop = 0;
  double _mobileIndicatorHeight = 0;

  bool _isFirstLoad = true;
  double? _lastWidth;

  final GlobalKey _drawerKey = GlobalKey();
  double _drawerHeight = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _controller.addListener(_updateDrawerHeight);
    for (final r in ['/', '/services', '/capabilities', '/about', '/gallery']) {
      _linkKeys[r] = GlobalKey();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateIndicator());
  }

  @override
  void dispose() {
    _controller.removeListener(_updateDrawerHeight);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CustomNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentRoute != widget.currentRoute) {
      _isFirstLoad = false;
      WidgetsBinding.instance.addPostFrameCallback((_) => _updateIndicator());
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final currentWidth = MediaQuery.of(context).size.width;

    if (_lastWidth != null) {
      final wasDesktop = _lastWidth! >= 1024;
      final isDesktop = currentWidth >= 1024;

      if (wasDesktop != isDesktop) {
        // Snap indicator into place instead of sliding from a stale position.
        _isFirstLoad = true;

        // Close the mobile menu when switching to desktop. If left open,
        // _isMobileMenuOpen stays true and _buildMobileNav renders the
        // full-screen tap-outside overlay on the next mobile rebuild,
        // blocking all interaction.
        if (isDesktop && _isMobileMenuOpen) {
          _isMobileMenuOpen = false;
          _controller.reverse();
        }
      }
    }
    _lastWidth = currentWidth;

    WidgetsBinding.instance.addPostFrameCallback((_) => _updateIndicator());
  }

  void _updateIndicator() {
    if (!mounted) return;

    final key = _linkKeys[widget.currentRoute];
    if (key == null || key.currentContext == null) {
      // On mobile with menu closed the desktop links aren't in the tree —
      // nothing to measure yet, bail out without scheduling an infinite retry.
      if (!_isMobileMenuOpen && MediaQuery.of(context).size.width < 1024) return;

      Future.delayed(const Duration(milliseconds: 50), _updateIndicator);
      return;
    }

    final RenderObject? renderObject = key.currentContext!.findRenderObject();
    final RenderStack? stackBox =
        key.currentContext!.findAncestorRenderObjectOfType<RenderStack>();

    if (renderObject is RenderBox && stackBox != null) {
      final position = renderObject.localToGlobal(Offset.zero, ancestor: stackBox);
      setState(() {
        _indicatorLeft = position.dx;
        _indicatorWidth = renderObject.size.width;
        _mobileIndicatorTop = position.dy;
        _mobileIndicatorHeight = renderObject.size.height;
      });
    }

    _updateDrawerHeight();
  }

  void _updateDrawerHeight() {
    if (!mounted) return;
    final renderObject = _drawerKey.currentContext?.findRenderObject();
    if (renderObject is RenderBox && renderObject.hasSize) {
      final height = renderObject.size.height;
      if (height != _drawerHeight) {
        setState(() => _drawerHeight = height);
      }
    }
  }

  void _toggleMobileMenu() {
    if (!mounted) return;
    final newState = !_isMobileMenuOpen;
    setState(() {
      _isMobileMenuOpen = newState;
      if (newState) {
        _controller.forward();
        WidgetsBinding.instance.addPostFrameCallback((_) => _updateIndicator());
      } else {
        _controller.reverse();
      }
    });
    widget.onMobileMenuChanged?.call(newState);
  }

  // Public method to close the mobile menu from outside (e.g., tap-outside overlay in AppShell)
  void closeMobileMenu() {
    if (_isMobileMenuOpen) {
      _toggleMobileMenu();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    return SizedBox(
      width: double.infinity,
      child: isDesktop ? _buildDesktopNav() : _buildMobileNav(),
    );
  }

  Widget _buildDesktopNav() {
    return Container(
      height: 70,
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildLogo(),
          const SizedBox(width: 20),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 750,
                child: Stack(
                  alignment: Alignment.bottomLeft,
                  children: [
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
                    // Sliding active-route indicator
                    AnimatedPositioned(
                      duration: _indicatorWidth == 0 || _isFirstLoad
                          ? Duration.zero
                          : const Duration(milliseconds: 350),
                      curve: Curves.easeOutCubic,
                      left: _indicatorLeft,
                      bottom: 0,
                      child: Opacity(
                        opacity: _indicatorWidth == 0 ? 0 : 1,
                        child: AnimatedContainer(
                          duration: _indicatorWidth == 0 || _isFirstLoad
                              ? Duration.zero
                              : const Duration(milliseconds: 350),
                          curve: Curves.easeOutCubic,
                          width: _indicatorWidth,
                          height: 3,
                          decoration: const BoxDecoration(
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
    return Stack(
      // Clip.none lets the drawer paint below the nav bar's own layout height,
      // but the Stack's own size is determined solely by its non-Positioned
      // children (the Column below), so it never claims more vertical space
      // than the nav bar + drawer actually need.
      clipBehavior: Clip.none,
      children: [
        // LAYER 1: NAV BAR + DRAWER
        // The tap-outside overlay is now at the AppShell level (in main.dart)
        // so it can cover the page content area and receive taps there.
        Column(
          key: _drawerKey,
          mainAxisSize: MainAxisSize.min,
          children: [
            // TOP BAR
            Container(
              height: 70,
              decoration: const BoxDecoration(
                color: Color(0xFF1a1a1a),
                boxShadow: [
                  BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                ],
              ),
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildLogo(),
                  IconButton(
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

            // ANIMATED DRAWER
            ClipRect(
              child: SizeTransition(
                sizeFactor: _controller,
                axisAlignment: -1.0,
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(color: Color(0xFF2a2a2a)),
                  child: Stack(
                    children: [
                      // Vertical active-route indicator
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
                      // Links
                      Column(
                        mainAxisSize: MainAxisSize.min,
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
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _handleMobileTap(String route) {
    // Close the menu, then navigate ONLY once the close animation has fully
    // completed (controller reaches the dismissed state). Navigating earlier —
    // whether in the same frame or one frame later — cut the drawer's close
    // animation short, so it snapped or slid too fast. Waiting for the full
    // ~300ms slide lets it finish cleanly before the page switches.
    if (_isMobileMenuOpen) {
      void onStatusChanged(AnimationStatus status) {
        if (status == AnimationStatus.dismissed) {
          _controller.removeStatusListener(onStatusChanged);
          if (mounted) _navigateTo(route);
        }
      }
      _controller.addStatusListener(onStatusChanged);
      _toggleMobileMenu();
    } else {
      _navigateTo(route);
    }
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

  void _navigateTo(String route) {
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
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap(widget.route);
      },
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
          scale: _isPressed ? 0.96 : 1.0,
          duration: const Duration(milliseconds: 100),
          alignment: Alignment.centerLeft,
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