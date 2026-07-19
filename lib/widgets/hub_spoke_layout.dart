import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A "hub and spoke" layout: one featured card centered at the top,
/// connected by dashed technical-style curves to two supporting cards
/// below it (one lower-left, one lower-right).
///
/// Cards size themselves naturally (their own content decides height) —
/// this widget never forces a fixed height on a card, which is what
/// caused overflow when a card's text needed more room than a guessed
/// height allowed. Only card *width* is shrunk to fit narrow screens; the
/// connector curves are drawn in a fixed-height strip between the rows,
/// whose geometry only depends on known widths/positions, not on how
/// tall any individual card ends up being.
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
class HubSpokeLayout extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth =
            constraints.maxWidth.isFinite ? constraints.maxWidth : cardWidth * 2 + horizontalGap;

        final effectiveGap = math.min(horizontalGap, availableWidth * 0.06);
        final maxCardWidthForSpace = (availableWidth - effectiveGap) / 2;
        final effectiveCardWidth = math.min(cardWidth, maxCardWidthForSpace);

        if (effectiveCardWidth < minCardWidth) {
          // Too narrow for a legible 3-column hub — plain vertical stack.
          return Column(
            children: [
              topCard,
              SizedBox(height: verticalGap),
              leftCard,
              SizedBox(height: verticalGap),
              rightCard,
            ],
          );
        }

        final rowWidth = effectiveCardWidth * 2 + effectiveGap;

        return Center(
          child: SizedBox(
            width: rowWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Top card — natural height, centered over the row below.
                Center(
                  child: SizedBox(width: effectiveCardWidth, child: topCard),
                ),
                // Connector strip: fixed height (just for the curves), no
                // dependency on any card's actual height.
                SizedBox(
                  height: verticalGap,
                  width: rowWidth,
                  child: CustomPaint(
                    painter: _HubConnectorPainter(
                      rowWidth: rowWidth,
                      cardWidth: effectiveCardWidth,
                      color: connectorColor,
                    ),
                  ),
                ),
                // Side cards — natural height each, spaced apart by
                // effectiveGap via spaceBetween.
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: effectiveCardWidth, child: leftCard),
                    SizedBox(width: effectiveCardWidth, child: rightCard),
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

/// Paints two dashed, technical/blueprint-style curves from the top card's
/// lower edges down to the top of each side card, with small node markers
/// at each end. Geometry is derived purely from [rowWidth] and [cardWidth]
/// (both known ahead of layout), so this never depends on any card's
/// actual rendered height.
class _HubConnectorPainter extends CustomPainter {
  final double rowWidth;
  final double cardWidth;
  final Color color;

  _HubConnectorPainter({
    required this.rowWidth,
    required this.cardWidth,
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

    // Left connector: from top card's lower-left area down to the left
    // card's top-center.
    _drawConnector(
      canvas,
      linePaint,
      nodeFillPaint,
      nodeRingPaint,
      start: Offset(topCardLeft + cardWidth * 0.12, 0),
      end: Offset(cardWidth / 2, size.height),
    );

    // Right connector: from top card's lower-right area down to the right
    // card's top-center.
    _drawConnector(
      canvas,
      linePaint,
      nodeFillPaint,
      nodeRingPaint,
      start: Offset(topCardRight - cardWidth * 0.12, 0),
      end: Offset(rowWidth - cardWidth / 2, size.height),
    );
  }

  void _drawConnector(
    Canvas canvas,
    Paint linePaint,
    Paint nodeFillPaint,
    Paint nodeRingPaint, {
    required Offset start,
    required Offset end,
  }) {
    final path = Path()..moveTo(start.dx, start.dy);
    final controlPoint1 = Offset(start.dx, start.dy + (end.dy - start.dy) * 0.6);
    final controlPoint2 = Offset(end.dx, start.dy + (end.dy - start.dy) * 0.35);
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
        oldDelegate.color != color;
  }
}