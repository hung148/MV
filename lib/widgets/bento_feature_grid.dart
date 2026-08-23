import 'package:flutter/material.dart';

/// A "bento grid" layout for a features/highlights section: one larger
/// featured card spans the full row width, with two smaller supporting
/// cards below it, side by side.
///
/// This replaces the earlier hub-and-spoke connector-line layout.
/// Hierarchy between the featured card and its two supporters is
/// communicated through relative size and card styling alone — no
/// connector lines, no height measuring, no curve geometry required.
///
/// Below [breakpoint] the layout collapses to a single full-width
/// column (featured card, then each supporting card stacked), which is
/// how bento grids are expected to degrade on mobile.
///
/// Usage:
///   BentoFeatureGrid(
///     featuredCard: precisionCard,
///     secondaryCardA: speedCard,
///     secondaryCardB: ownerCard,
///     gap: r.cardSpacing,
///   )
class BentoFeatureGrid extends StatelessWidget {
  /// The larger, visually-emphasized card — spans the full row width.
  final Widget featuredCard;

  /// First smaller supporting card — sits bottom-left on wide screens.
  final Widget secondaryCardA;

  /// Second smaller supporting card — sits bottom-right on wide screens.
  final Widget secondaryCardB;

  /// Space between the featured card and the row below it, and between
  /// the two secondary cards in that row.
  final double gap;

  /// Below this available width, collapse to a single full-width column
  /// instead of a featured card + side-by-side row.
  final double breakpoint;

  const BentoFeatureGrid({
    super.key,
    required this.featuredCard,
    required this.secondaryCardA,
    required this.secondaryCardB,
    this.gap = 24,
    this.breakpoint = 640,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final rowWidth = constraints.maxWidth.isFinite ? constraints.maxWidth : 900.0;
        final isNarrow = rowWidth < breakpoint;
        final trayPadding = isNarrow ? gap * 0.6 : gap * 0.85;

        final grid = isNarrow
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  featuredCard,
                  SizedBox(height: gap),
                  secondaryCardA,
                  SizedBox(height: gap),
                  secondaryCardB,
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  featuredCard,
                  SizedBox(height: gap),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: secondaryCardA),
                        SizedBox(width: gap),
                        Expanded(child: secondaryCardB),
                      ],
                    ),
                  ),
                ],
              );

        // Soft-tinted "tray" behind the whole trio: without it the cards
        // just float on the same white as the section background, and
        // three floating white boxes is what read as basic/flat. The
        // tray gives the group a visible edge and gap color, so it reads
        // as one deliberate grid/mosaic rather than loose cards.
        return Container(
          padding: EdgeInsets.all(trayPadding),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFf5f8fc), Color(0xFFeaf1fb)],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFe1e9f6)),
          ),
          child: grid,
        );
      },
    );
  }
}