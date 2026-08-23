import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mv/widgets/contacts.dart';
import 'package:mv/widgets/styles.dart';
import 'package:mv/widgets/quote_form.dart';

/// Height of the fixed nav bar. The hero sits *underneath* it (the bar is
/// transparent at the top of a page), so [PageHero] insets its content by
/// this much to clear it.
const double kNavBarHeight = 70;

/// Carries the bar's current solidity down to the logo and links so their
/// colours can follow it.
///
/// The bar has two very different backdrops: bright hero footage when it's
/// floating, and near-black `#1a1a1a` once it's solid. One text palette can't
/// serve both — `#cccccc` links and a `#999999` tagline are right on the dark
/// bar but drop to 3.7:1 and 2.1:1 over the video. Rather than darkening the
/// scrim until the dim colours work (which just makes the bar a black band
/// across a bright hero), the text brightens as the bar goes transparent.
///
/// It's an InheritedWidget so a solidity change repaints only the handful of
/// leaf Text widgets that depend on it, leaving the rest of the bar alone.
class _NavPalette extends InheritedWidget {
  final double solidity;

  const _NavPalette({required this.solidity, required super.child});

  /// 1.0 (the solid palette) when there's no [_NavPalette] above — which is
  /// the case inside the mobile drawer, and correct there: the drawer is
  /// opaque.
  static double of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_NavPalette>()?.solidity ?? 1.0;

  /// Inactive nav link. Pure white over footage → `#cccccc` on the dark bar.
  /// White rather than an off-white now that there's no scrim behind it —
  /// every bit of contrast has to come from the glyphs themselves.
  static Color link(BuildContext context) =>
      Color.lerp(Colors.white, ShopStyles.textSecondary, of(context))!;

  /// Logo tagline. Barely below [link] while floating: hierarchy comes from
  /// size (11px vs 15px) instead of colour, because dimming it over bare
  /// footage is exactly what made it unreadable.
  static Color tagline(BuildContext context) =>
      Color.lerp(const Color(0xFFEAF1F8), ShopStyles.textMuted, of(context))!;

  /// The drop shadow that does the legibility work while the bar is
  /// transparent, fading out as it turns solid.
  ///
  /// Two layers on purpose: a wide soft one to darken the footage around the
  /// glyphs, and a tight dense one to define their edges. A single blur does
  /// one job or the other, not both.
  static List<Shadow> shadows(BuildContext context) {
    final t = 1 - of(context);
    if (t <= 0.01) return const [];
    return [
      Shadow(
        color: Colors.black.withValues(alpha: 0.55 * t),
        blurRadius: 14,
        offset: const Offset(0, 1),
      ),
      Shadow(
        color: Colors.black.withValues(alpha: 0.45 * t),
        blurRadius: 4,
      ),
    ];
  }

  @override
  bool updateShouldNotify(_NavPalette oldWidget) =>
      oldWidget.solidity != solidity;
}

class CustomNavigationBar extends StatefulWidget {
  final String currentRoute;
  final void Function(String route) onNavigate;
  final void Function(bool isOpen)? onMobileMenuChanged;

  /// How solid the bar is, 0 → 1.
  ///
  /// At 0 the bar paints no fill at all — just a soft top-down scrim so the
  /// logo and links stay legible over hero video — letting the hero run
  /// full-bleed to the top of the window. At 1 it's the solid dark bar.
  /// AppShell drives this continuously from the scroll position, so the bar
  /// eases between the two states as the hero's bottom edge passes under it
  /// rather than snapping.
  ///
  /// This is a listenable rather than a plain double on purpose: it changes
  /// every scroll frame, and only the bar's decoration should rebuild that
  /// often — not the whole shell.
  final ValueListenable<double> solidity;

  const CustomNavigationBar({
    super.key,
    required this.currentRoute,
    required this.onNavigate,
    required this.solidity,
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

  /// Floating over a hero: completely transparent — no fill, no scrim. The
  /// hero runs unbroken to the top of the window and the nav simply sits on
  /// it (Tom's call, 2026-08-23).
  ///
  /// Legibility then rests entirely on the text itself: white, with the
  /// heavier drop shadow in [_NavPalette.shadows]. Measured against real
  /// frames of both hero clips the links come out around 4:1 where WCAG AA
  /// wants 4.5:1 for text this size — the shadow carries it perceptually,
  /// but the raw figure is short. If it ever reads as washed out over a
  /// brighter clip, the fixes in order of least visual cost are: raise the
  /// hero's own top vignette (Layer 4 in page_hero.dart) from 0.24 toward
  /// 0.44, or put a light scrim back here.
  static const BoxDecoration _floatingDecoration = BoxDecoration();

  /// Past the hero: the solid dark bar.
  static const BoxDecoration _solidDecoration = BoxDecoration(
    color: Color(0xFF1a1a1a),
    boxShadow: [
      BoxShadow(color: Color(0x47000000), blurRadius: 8, offset: Offset(0, 2)),
    ],
  );

  /// Wraps the bar's contents in the decoration for the current solidity.
  ///
  /// Two things can make the bar solid, and it takes whichever wants it more:
  ///
  ///  * [CustomNavigationBar.solidity] — driven by scroll position. This is a
  ///    plain Container rather than an AnimatedContainer precisely because the
  ///    scroll position *is* the animation; an implicit tween layered on top
  ///    would only lag behind the finger.
  ///  * the mobile drawer's own open/close controller — a see-through header
  ///    floating above an opaque drawer reads as two unrelated panels, and
  ///    riding the drawer's 300 ms slide means the header darkens *with* it
  ///    instead of snapping the moment the menu is tapped.
  Widget _bar({required EdgeInsets padding, required Widget child}) {
    return ListenableBuilder(
      listenable: Listenable.merge([widget.solidity, _controller]),
      child: child,
      builder: (context, built) {
        final scrolled = widget.solidity.value.clamp(0.0, 1.0);
        final drawer = _controller.value;
        final t = scrolled > drawer ? scrolled : drawer;
        return Container(
          height: kNavBarHeight,
          padding: padding,
          decoration: BoxDecoration.lerp(_floatingDecoration, _solidDecoration, t),
          // Wraps the cached child: an InheritedWidget still notifies its
          // dependents when its value changes, even though `built` itself is
          // the same widget instance and isn't rebuilt.
          child: _NavPalette(solidity: t, child: built!),
        );
      },
    );
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
    return _bar(
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
            _bar(
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
                            child: SizedBox(
                              width: double.infinity,
                              child: _buildContactButton(outlined: true),
                            ),
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
    return _HoverLogo(onTap: () => _navigateTo('/'));
  }

  Widget _buildContactButton({bool outlined = false}) {
    return _NavContactButton(
      onPressed: () => showQuoteDialog(context),
      outlined: outlined,
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
              color: (isActive || _isHovered)
                  ? Colors.white
                  : _NavPalette.link(context),
              shadows: _isHovered && !isActive
                  ? [Shadow(color: Colors.white.withValues(alpha: 0.3), blurRadius: 8)]
                  // Over hero footage the links get a soft dark shadow; it
                  // fades out as the bar turns solid.
                  : _NavPalette.shadows(context),
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

// ─── Logo with hover opacity ──────────────────────────────────────────────────
class _HoverLogo extends StatefulWidget {
  final VoidCallback onTap;
  const _HoverLogo({required this.onTap});

  @override
  State<_HoverLogo> createState() => _HoverLogoState();
}

class _HoverLogoState extends State<_HoverLogo> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isHovered ? 1.03 : 1.0,
          duration: const Duration(milliseconds: 180),
          child: Row(
            children: [
              Image.asset(
                'assets/logo/MV-Manufacturing.png',
                width: 100,
                height: 60,
                fit: BoxFit.fill,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 180),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      shadows: _NavPalette.shadows(context),
                    ),
                    child: const Text(CompanyContact.name),
                  ),
                  Text(
                    CompanyContact.tagline,
                    style: TextStyle(
                      // #999999 on the solid bar, but far brighter over hero
                      // footage — at 11px it needs 4.5:1, and #999999 manages
                      // barely 2:1 there.
                      color: _NavPalette.tagline(context),
                      fontSize: 11,
                      shadows: _NavPalette.shadows(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── GET A QUOTE button (self-contained hover state) ─────────────────────────
class _NavContactButton extends StatefulWidget {
  final VoidCallback onPressed;

  /// Draw a white border.
  ///
  /// Off in the top bar, where the button sits among the nav links and a box
  /// around one of them would be the only framed thing on an otherwise
  /// transparent bar. On in the mobile drawer, where it's a full-width block
  /// on a flat panel with no links beside it — there the border is what makes
  /// it read as the action rather than another menu row.
  final bool outlined;

  const _NavContactButton({required this.onPressed, this.outlined = false});

  @override
  State<_NavContactButton> createState() => _NavContactButtonState();
}

class _NavContactButtonState extends State<_NavContactButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: OutlinedButton(
          onPressed: widget.onPressed,
          // Ghost button: no fill at rest, so the hero shows straight through
          // it the same way it does through the rest of the bar. Hover and
          // press are the only things that put any background there.
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.pressed)) {
                return Colors.white.withValues(alpha: 0.26);
              }
              if (states.contains(WidgetState.hovered)) {
                return Colors.white.withValues(alpha: 0.15);
              }
              return Colors.transparent;
            }),
            // The default overlay would stack a second highlight on top of
            // the backgroundColor above and muddy both states.
            overlayColor: const WidgetStatePropertyAll(Colors.transparent),
            foregroundColor: const WidgetStatePropertyAll(Colors.white),
            side: WidgetStateProperty.resolveWith((states) {
              if (!widget.outlined) return BorderSide.none;
              final lit = states.contains(WidgetState.hovered) ||
                  states.contains(WidgetState.pressed);
              return BorderSide(
                color: Colors.white.withValues(alpha: lit ? 0.95 : 0.7),
                width: 1.6,
              );
            }),
            padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            ),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            // A drop shadow under a see-through button just looks like a
            // smudge on the video.
            elevation: const WidgetStatePropertyAll(0),
            shadowColor: const WidgetStatePropertyAll(Colors.transparent),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'GET A QUOTE',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  // Same shadow the nav links get while the bar floats.
                  shadows: _NavPalette.shadows(context),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_rounded,
                size: 18,
                shadows: _NavPalette.shadows(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}