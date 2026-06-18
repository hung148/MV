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

  // Key to measure the drawer's current rendered height, so the
  // "tap outside to close" overlay can start right below the drawer
  // instead of covering the whole screen (which was swallowing taps on
  // the links themselves, since the overlay painted on top of them).
  final GlobalKey _drawerKey = GlobalKey();
  double _drawerHeight = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    // Re-measure the drawer's height every frame while it's animating
    // open/closed, so the tap-outside overlay (which starts below the
    // drawer) tracks the drawer's growing/shrinking edge instead of
    // snapping to a stale height.
    _controller.addListener(_updateDrawerHeight);
    // initialize keys for routes you use
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
    setState(() {
      _isMobileMenuOpen = !_isMobileMenuOpen;
      if (_isMobileMenuOpen) {
        _controller.forward();
        // Wait for the drawer to exist before measuring
        WidgetsBinding.instance.addPostFrameCallback((_) => _updateIndicator());
      } else {
        _controller.reverse();
        // We don't reset _mobileIndicatorHeight to 0 immediately 
        // so it stays visible while the drawer is sliding up.
      }
    });
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
      height: 70, // Fixed height to match AppShell padding
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
    final screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // LAYER 1: NAV BAR + DRAWER
        // This must come BEFORE the overlay in the children list so the
        // overlay paints (and hit-tests) on top of it. Stack hit-testing
        // walks children back-to-front, so whichever child is listed last
        // gets first crack at a tap. With the overlay listed first (as it
        // used to be), this Column painted over it and silently swallowed
        // every "tap outside to close" gesture.
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
            // SizeTransition is driven by _controller (the same one used for the
            // menu icon), so open AND close both animate against a real 0->1
            // value. AnimatedSize only animates when it can measure a child's
            // natural size on both ends of the transition; toggling height
            // between null and 0 collapses the child to 0 in the same frame,
            // so there's nothing left for AnimatedSize to interpolate on close.
            ClipRect(
              child: SizeTransition(
                sizeFactor: _controller,
                axisAlignment: -1.0, // anchor to top, like Alignment.topCenter
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(color: Color(0xFF2a2a2a)),
                  child: Stack( 
                    children: [
                      // Vertical Indicator
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
                      // Links Column
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

        // LAYER 2: INVISIBLE OVERLAY (must be listed AFTER the drawer Column above)
        // Starts at _drawerHeight (top bar + current drawer extent) rather
        // than top: 0 — covering from the very top swallowed every tap on
        // the drawer's own links before they could reach the InkWells
        // underneath, since Stack hit-testing gives the last/topmost child
        // first crack at a tap and this overlay painted above everything.
        // That's what made link taps look like they only closed the menu.
        if (_isMobileMenuOpen)
          Positioned(
            top: _drawerHeight,
            left: 0,
            right: 0,
            height: screenHeight - _drawerHeight,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _toggleMobileMenu,
              child: Container(color: Colors.transparent),
            ),
          ),
      ],
    );
  }

  void _handleMobileTap(String route) {
    // Menu intentionally stays open here — tapping a link should switch
    // the page underneath while the drawer stays open on top. Use the
    // hamburger/X icon or tap outside to close it (_toggleMobileMenu).
    _navigateTo(route);
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

  // Delegates to AppShell's onNavigate (context.go).
  void _navigateTo(String route) {
    // IMPORTANT: don't call Navigator.of(context).pop() / canPop() here.
    // Inside a ShellRoute, the nearest Navigator found by walking up from
    // this context IS the GoRouter navigator that owns the page stack —
    // there's no separate Navigator above it to "close a dialog" on.
    // canPop() was returning true simply because GoRouter had back
    // history, so pop() was popping the route stack itself, racing with /
    // undoing the context.go(route) call below. That's what made link
    // taps look like "menu closes, page doesn't change" — the pop and the
    // go() were fighting over the same stack. If a quote dialog needs to
    // be dismissed before navigating, that should happen via the dialog's
    // own onPressed/close handler, not from here.
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
      // onTapUp (below) already calls widget.onTap, so a separate onTap
      // handler here would fire the same callback twice per click — Flutter
      // dispatches onTapDown -> onTapUp -> onTap for a single tap gesture,
      // not just one of them. That meant every click called _navigateTo
      // (and therefore context.go) twice in a row, which can race with
      // GoRouter's own transition handling.
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
      // onTapUp is the single source of truth for the tap action — it
      // already calls widget.onTap. A separate onTap handler used to sit
      // alongside this and fire the exact same callback again for the same
      // gesture (Flutter dispatches onTapDown -> onTapUp -> onTap in that
      // order for one tap, not just one of them), so every tap called
      // _handleMobileTap -> _navigateTo -> context.go(route) TWICE in a
      // row. The first call closed the drawer and kicked off navigation;
      // the second call landed milliseconds later while GoRouter was still
      // processing the first transition, and re-triggering go() to a
      // location it considers unchanged from its in-flight state is what
      // made the route swap silently no-op — hence "menu closes, page
      // doesn't change."
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