import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A "hub and spoke" layout: one featured card centered at the top,
/// connected by dashed technical-style curves to two supporting cards
/// below it (one lower-left, one lower-right).
///
/// The connectors leave from the LEFT and RIGHT sides of the top card
/// (not its bottom edge), loop outward, and sweep back down into the
/// top of each side card — giving the pair of curves a rounded,
/// circle-like arc rather than a straight vertical drop.
///
/// Cards size themselves naturally (their own content decides height) —
/// this widget never forces a fixed height on a card, which is what
/// caused overflow when a card's text needed more room than a guessed
/// height allowed. Only card *width* is shrunk to fit narrow screens.
/// The top card's height IS measured (via GlobalKey, after each frame)
/// so the connector curves know where the card's sides actually are;
/// everything else about the geometry only depends on known
/// widths/positions, not on how tall the side cards end up being.
///
/// Falls back to a plain vertical stack (topCard, leftCard, rightCard,
/// no curves) if the available width is too narrow even at [minCardWidth]
/// for a 3-column hub to stay legible.
///
/// Usage:
///   HubSpokeLayout(
///     cardWidth: r.featureCardWidth,
///     topCard: myTopCardWidget,
///     leftCard: myLeftCardWidget,
///     rightCard: myRightCardWidget,
///   )
class HubSpokeLayout extends StatefulWidget {
  final Widget topCard;
  final Widget leftCard;
  final Widget rightCard;

  /// Preferred width for each card at full size (e.g. on desktop). Shrinks
  /// automatically on narrower viewports; height is never fixed — each
  /// card sizes to its own content.
  final double cardWidth;

  /// Horizontal empty space between the two side cards at full size.
  /// Shrinks proportionally on narrower viewports.
  final double horizontalGap;

  /// Height of the connector strip between the top card and the side
  /// cards, where the dashed curves are drawn.
  final double verticalGap;

  /// Color of the connector lines (drawn at reduced opacity) and node
  /// markers.
  final Color connectorColor;

  /// Below this card width, the hub shape stops being legible, so this
  /// falls back to a simple vertical stack (no curves) instead.
  final double minCardWidth;

  const HubSpokeLayout({
    super.key,
    required this.topCard,
    required this.leftCard,
    required this.rightCard,
    required this.cardWidth,
    this.horizontalGap = 40,
    this.verticalGap = 56,
    this.connectorColor = const Color(0xFF0d47a1),
    this.minCardWidth = 140,
  });

  @override
  State<HubSpokeLayout> createState() => _HubSpokeLayoutState();
}

class _HubSpokeLayoutState extends State<HubSpokeLayout> {
  final _topCardKey = GlobalKey();
  double _topCardHeight = 0;

  void _measure() {
    final ctx = _topCardKey.currentContext;
    final h = ctx?.size?.height ?? 0;
    if (h > 0 && (h - _topCardHeight).abs() > 0.5) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _topCardHeight = h);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth =
            constraints.maxWidth.isFinite ? constraints.maxWidth : widget.cardWidth * 2 + widget.horizontalGap;

        final effectiveGap = math.min(widget.horizontalGap, availableWidth * 0.06);
        final maxCardWidthForSpace = (availableWidth - effectiveGap) / 2;
        final effectiveCardWidth = math.min(widget.cardWidth, maxCardWidthForSpace);

        if (effectiveCardWidth < widget.minCardWidth) {
          // Too narrow for a legible 3-column hub — plain vertical stack.
          return Column(
            children: [
              widget.topCard,
              SizedBox(height: widget.verticalGap),
              widget.leftCard,
              SizedBox(height: widget.verticalGap),
              widget.rightCard,
            ],
          );
        }

        final rowWidth = effectiveCardWidth * 2 + effectiveGap;
        // Fallback estimate for the first frame or two, before the top
        // card has actually been measured, so the curves don't start out
        // collapsed to zero height.
        final topCardHeight = _topCardHeight > 0 ? _topCardHeight : 120.0;
        final connectorAreaHeight = topCardHeight + widget.verticalGap;

        return Center(
          child: SizedBox(
            width: rowWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Top card + connector curves share a Stack so the
                // curves can originate from the card's left/right edges
                // instead of its bottom edge.
                SizedBox(
                  width: rowWidth,
                  height: connectorAreaHeight,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned.fill(
                        child: IgnorePointer(
                          child: CustomPaint(
                            painter: _HubConnectorPainter(
                              rowWidth: rowWidth,
                              cardWidth: effectiveCardWidth,
                              topCardHeight: topCardHeight,
                              color: widget.connectorColor,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        left: (rowWidth - effectiveCardWidth) / 2,
                        width: effectiveCardWidth,
                        child: SizedBox(
                          key: _topCardKey,
                          width: effectiveCardWidth,
                          child: widget.topCard,
                        ),
                      ),
                    ],
                  ),
                ),
                // Side cards — natural height each, spaced apart by
                // effectiveGap via spaceBetween.
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: effectiveCardWidth, child: widget.leftCard),
                    SizedBox(width: effectiveCardWidth, child: widget.rightCard),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Paints two dashed, technical/blueprint-style curves that leave the
/// LEFT and RIGHT sides of the top card, loop outward, and sweep back
/// down into the top of each side card — reading as a rounded, circular
/// arc rather than a straight drop from the card's bottom edge.
///
/// Geometry is derived purely from [rowWidth], [cardWidth] and
/// [topCardHeight] (all known ahead of paint), so this never depends on
/// how tall the side cards end up being.
class _HubConnectorPainter extends CustomPainter {
  final double rowWidth;
  final double cardWidth;
  final double topCardHeight;
  final Color color;

  _HubConnectorPainter({
    required this.rowWidth,
    required this.cardWidth,
    required this.topCardHeight,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final nodeFillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final nodeRingPaint = Paint()
      ..color = color.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;

    final topCardLeft = (rowWidth - cardWidth) / 2;
    final topCardRight = topCardLeft + cardWidth;
    // Leave from the side of the card, a bit above its vertical center,
    // so the loop has room to bulge outward before curving back down.
    final sideY = topCardHeight * 0.45;
    final endY = size.height;

    // Left connector: leaves the top card's left edge, bulges out to
    // the left, then sweeps down into the left card's top-center —
    // reading as a rounded, circular arc.
    _drawConnector(
      canvas,
      linePaint,
      nodeFillPaint,
      nodeRingPaint,
      start: Offset(topCardLeft, sideY),
      end: Offset(cardWidth / 2, endY),
      bulgeOutward: true,
    );

    // Right connector: mirrored — leaves the right edge, bulges right,
    // sweeps down into the right card's top-center.
    _drawConnector(
      canvas,
      linePaint,
      nodeFillPaint,
      nodeRingPaint,
      start: Offset(topCardRight, sideY),
      end: Offset(rowWidth - cardWidth / 2, endY),
      bulgeOutward: false,
    );
  }

  void _drawConnector(
    Canvas canvas,
    Paint linePaint,
    Paint nodeFillPaint,
    Paint nodeRingPaint, {
    required Offset start,
    required Offset end,
    required bool bulgeOutward,
  }) {
    final verticalSpan = end.dy - start.dy;
    // Outward bulge distance: how far past the card's own side the curve
    // swings before turning back in — this is what reads as "circular"
    // rather than a straight diagonal drop.
    final bulge = cardWidth * 0.4;
    final direction = bulgeOutward ? -1.0 : 1.0;

    final controlPoint1 = Offset(
      start.dx + bulge * direction,
      start.dy + verticalSpan * 0.35,
    );
    final controlPoint2 = Offset(
      start.dx + bulge * 0.55 * direction,
      start.dy + verticalSpan * 0.85,
    );

    final path = Path()..moveTo(start.dx, start.dy);
    path.cubicTo(
      controlPoint1.dx, controlPoint1.dy,
      controlPoint2.dx, controlPoint2.dy,
      end.dx, end.dy,
    );

    _drawDashedPath(canvas, path, linePaint, dashLength: 6, gapLength: 5);

    const nodeRadius = 4.0;
    const ringRadius = 7.0;
    for (final point in [start, end]) {
      canvas.drawCircle(point, ringRadius, nodeRingPaint);
      canvas.drawCircle(point, nodeRadius, nodeFillPaint);
    }
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint, {required double dashLength, required double gapLength}) {
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      var drawDash = true;
      while (distance < metric.length) {
        final segmentLength = drawDash ? dashLength : gapLength;
        final next = math.min(distance + segmentLength, metric.length);
        if (drawDash) {
          canvas.drawPath(metric.extractPath(distance, next), paint);
        }
        distance = next;
        drawDash = !drawDash;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _HubConnectorPainter oldDelegate) {
    return oldDelegate.rowWidth != rowWidth ||
        oldDelegate.cardWidth != cardWidth ||
        oldDelegate.topCardHeight != topCardHeight ||
        oldDelegate.color != color;
  }
}