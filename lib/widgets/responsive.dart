import 'package:flutter/material.dart';

/// Breakpoints for screen size categories
enum ScreenSize { mobile, tablet, desktop }

/// A centralized responsive utility class.
/// Use [Responsive.of(context)] to get a snapshot of all scaled values
/// for the current screen width.
///
/// Usage:
///   final r = Responsive.of(context);
///   Text('Hello', style: TextStyle(fontSize: r.heading1))
///   SizedBox(height: r.spacingXL)
///   Container(padding: r.pagePadding)
class Responsive {
  final double screenWidth;
  final double screenHeight;
  final ScreenSize screenSize;

  const Responsive._({
    required this.screenWidth,
    required this.screenHeight,
    required this.screenSize,
  });

  /// Factory constructor — call this in your build methods.
  factory Responsive.of(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final ScreenSize s;
    if (w < 600) {
      s = ScreenSize.mobile;
    } else if (w < 1024) {
      s = ScreenSize.tablet;
    } else {
      s = ScreenSize.desktop;
    }
    return Responsive._(screenWidth: w, screenHeight: size.height, screenSize: s);
  }

  // ─── Convenience booleans ────────────────────────────────────────────────
  bool get isMobile => screenSize == ScreenSize.mobile;
  bool get isTablet => screenSize == ScreenSize.tablet;
  bool get isDesktop => screenSize == ScreenSize.desktop;
  bool get isMobileOrTablet => isMobile || isTablet;

  // ─── Layout ──────────────────────────────────────────────────────────────

  /// Max content width (used in Center + Container constraints)
  double get maxContentWidth => isDesktop ? 1200 : double.infinity;

  /// Max narrow content width (CTAs, single-column sections)
  double get maxNarrowWidth => isDesktop ? 800 : double.infinity;

  /// Horizontal page padding
  EdgeInsets get pagePadding => EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : isTablet ? 24 : 24,
      );

  /// Section vertical padding
  EdgeInsets get sectionPadding => EdgeInsets.symmetric(
        vertical: isMobile ? 48 : isTablet ? 64 : 80,
        horizontal: isMobile ? 16 : 24,
      );

  // ─── Typography ───────────────────────────────────────────────────────────

  /// Hero / display headline
  double get displayHeading => isMobile ? 32 : isTablet ? 44 : 56;

  /// Section heading (h1)
  double get heading1 => isMobile ? 28 : isTablet ? 36 : 42;

  /// Sub-section heading (h2)
  double get heading2 => isMobile ? 22 : isTablet ? 26 : 28;

  /// Card / item title (h3)
  double get heading3 => isMobile ? 18 : isTablet ? 20 : 22;

  /// Large body / sub-heading
  double get bodyLarge => isMobile ? 16 : isTablet ? 18 : 22;

  /// Standard body text
  double get body => isMobile ? 14 : isTablet ? 15 : 16;

  /// Small / caption text
  double get caption => isMobile ? 12 : 14;

  /// Stat number (big bold numbers)
  double get statNumber => isMobile ? 36 : isTablet ? 42 : 48;

  /// Button label font size
  double get buttonText => isMobile ? 15 : isTablet ? 17 : 18;

  /// Large CTA button label
  double get buttonTextLarge => isMobile ? 16 : isTablet ? 18 : 20;

  // ─── Spacing ─────────────────────────────────────────────────────────────

  double get spacingXS => 8;
  double get spacingS  => isMobile ? 12 : 16;
  double get spacingM  => isMobile ? 16 : isTablet ? 20 : 24;
  double get spacingL  => isMobile ? 24 : isTablet ? 32 : 40;
  double get spacingXL => isMobile ? 32 : isTablet ? 40 : 48;
  double get spacingXXL => isMobile ? 40 : isTablet ? 48 : 60;

  // ─── Icons ───────────────────────────────────────────────────────────────

  double get iconSmall  => isMobile ? 16 : 20;
  double get iconMedium => isMobile ? 24 : 28;
  double get iconLarge  => isMobile ? 36 : isTablet ? 44 : 48;
  double get iconHero   => isMobile ? 40 : isTablet ? 48 : 56;

  // ─── Hero section ────────────────────────────────────────────────────────

  double get heroHeight => isMobile ? 520 : isTablet ? 600 : 700;

  /// Hero section padding (for pages that use vertical padding instead of fixed height)
  EdgeInsets get heroPadding => EdgeInsets.symmetric(
        vertical: isMobile ? 60 : isTablet ? 80 : 100,
        horizontal: isMobile ? 16 : 24,
      );

  /// Hero sub-heading font size (slightly smaller than displayHeading)
  double get heroSubHeading => isMobile ? 16 : isTablet ? 18 : 20;

  // ─── Cards ───────────────────────────────────────────────────────────────

  double get cardPadding => isMobile ? 20 : isTablet ? 24 : 32;
  double get cardSpacing => isMobile ? 16 : isTablet ? 20 : 24;
  double get cardRadius  => 8;

  /// Feature card width (null = fill in Wrap)
  double? get featureCardWidth => isDesktop ? 350 : null;

  /// Service card width (home page compact cards)
  double? get serviceCardWidth => isDesktop ? 280 : isTablet ? 300 : null;

  double get serviceCardHeight => isMobile ? 200 : 220;

  /// Detailed service card width (Services page full-detail cards)
  double? get detailedServiceCardWidth => isDesktop ? 550 : null;

  // ─── Grid ────────────────────────────────────────────────────────────────

  /// Number of columns for material chips
  int get materialGridColumns => isMobile ? 2 : 3;

  double get materialChipAspectRatio => isMobile ? 2.0 : 2.5;

  /// Number of columns for industries grid
  int get industryGridColumns => isMobile ? 2 : 4;

  double get industryGridAspectRatio => isMobile ? 1.2 : 1.5;

  // ─── Process steps ───────────────────────────────────────────────────────

  double get processStepPadding => isMobile ? 16 : isTablet ? 20 : 24;
  double get processNumberSize  => isMobile ? 40 : 48;
  double get processNumberFont  => isMobile ? 20 : 24;

  // ─── Capabilities ────────────────────────────────────────────────────────

  /// Equipment / material-category card width (Wrap, 2-up on desktop)
  double? get equipmentCardWidth => isDesktop ? 360 : null;

  /// Tolerance card stat font (blue highlight number)
  double get toleranceStatFont => isMobile ? 24 : isTablet ? 28 : 32;

  /// Tolerance card title font
  double get toleranceTitleFont => isMobile ? 13 : isTablet ? 15 : 16;

  /// Capacity stat value font
  double get capacityStatFont => isMobile ? 22 : isTablet ? 26 : 28;

  /// Columns for certifications grid
  int get certGridColumns => isMobile ? 2 : 3;

  /// Aspect ratio for certification cards
  double get certGridAspectRatio => isMobile ? 1.4 : 1.8;

  // ─── Gallery ─────────────────────────────────────────────────────────────

  /// Columns for the gallery work grid
  int get galleryGridColumns => isMobile ? 1 : isTablet ? 2 : 3;

  /// Aspect ratio for gallery item cards
  double get galleryItemAspectRatio => isMobile ? 0.85 : 0.9;

  /// Image placeholder height inside a gallery card
  double get galleryImageHeight => isMobile ? 160 : 200;

  /// Icon size inside gallery image placeholder
  double get galleryImageIcon => isMobile ? 60 : 80;

  /// Filter chip horizontal/vertical padding
  EdgeInsets get filterChipPadding => EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: isMobile ? 10 : 12,
      );

  /// Filter section vertical padding
  EdgeInsets get filterSectionPadding => EdgeInsets.symmetric(
        vertical: isMobile ? 24 : 40,
        horizontal: isMobile ? 16 : 24,
      );

  /// Capability card stat font size
  double get capabilityStatFont => isMobile ? 26 : isTablet ? 28 : 32;

  /// Capability card label/description font size
  double get capabilityLabelFont => isMobile ? 12 : 14;

  // ─── About ───────────────────────────────────────────────────────────────

  /// Max width for narrow prose sections (story, mission, timeline)
  double get maxProseWidth => isDesktop ? 900 : double.infinity;

  /// Max width for mission quote box
  double get maxMissionWidth => isDesktop ? 1000 : double.infinity;

  /// Story / mission body text font size
  double get bodyProse => isMobile ? 15 : isTablet ? 16 : 18;

  /// Mission quote font size
  double get missionQuoteFont => isMobile ? 16 : isTablet ? 18 : 20;

  /// Value card width (About page — 3-up on desktop)
  double? get valueCardWidth => isDesktop ? 350 : null;

  /// Team member card width (About page)
  double? get teamCardWidth => isDesktop ? 350 : null;

  /// Team member avatar diameter
  double get teamAvatarSize => isMobile ? 90 : 120;

  /// Team member avatar icon size
  double get teamAvatarIcon => isMobile ? 45 : 60;

  /// Timeline year font size
  double get timelineYearFont => isMobile ? 18 : isTablet ? 20 : 24;

  /// Timeline year column width
  double get timelineYearWidth => isMobile ? 56 : 80;

  /// Timeline vertical bar height
  double get timelineBarHeight => isMobile ? 60 : 80;

  /// Timeline bottom spacing
  double get timelineItemSpacing => isMobile ? 20 : 32;

  // ─── Buttons ─────────────────────────────────────────────────────────────

  EdgeInsets get primaryButtonPadding => EdgeInsets.symmetric(
        horizontal: isMobile ? 28 : isTablet ? 36 : 40,
        vertical: isMobile ? 16 : 20,
      );

  EdgeInsets get ctaButtonPadding => EdgeInsets.symmetric(
        horizontal: isMobile ? 32 : isTablet ? 40 : 48,
        vertical: isMobile ? 18 : 24,
      );

  // ─── Footer ──────────────────────────────────────────────────────────────

  double get footerPaddingVertical => isMobile ? 32 : 40;

  // ─── Helpers ─────────────────────────────────────────────────────────────

  /// Returns [mobileValue] on mobile, [tabletValue] on tablet, [desktopValue] on desktop.
  T value<T>({required T mobile, required T tablet, required T desktop}) {
    switch (screenSize) {
      case ScreenSize.mobile:
        return mobile;
      case ScreenSize.tablet:
        return tablet;
      case ScreenSize.desktop:
        return desktop;
    }
  }

  /// Returns [mobileValue] on mobile/tablet, [desktopValue] on desktop.
  T valueWide<T>({required T compact, required T wide}) {
    return isDesktop ? wide : compact;
  }
}