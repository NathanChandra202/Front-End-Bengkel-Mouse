import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Reusable vector logo for Bengkel Mouse.
/// Draws a computer mouse with a wire on the left, and a gear containing a wrench cutout on the top-right.
class BengkelMouseLogo extends StatelessWidget {
  final double size;
  final Color color;
  final Color gearHoleColor;

  const BengkelMouseLogo({
    super.key,
    this.size = 100,
    this.color = Colors.white,
    this.gearHoleColor = const Color(0xFF8B0E0E),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _BengkelMouseLogoPainter(
          color: color,
          gearHoleColor: gearHoleColor,
        ),
      ),
    );
  }
}

class _BengkelMouseLogoPainter extends CustomPainter {
  final Color color;
  final Color gearHoleColor;

  const _BengkelMouseLogoPainter({
    required this.color,
    required this.gearHoleColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / 100;
    final scaleY = size.height / 100;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5 * scaleX
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    // Draw the Mouse Body
    final mouseRect = Rect.fromLTWH(8 * scaleX, 28 * scaleY, 52 * scaleX, 60 * scaleY);
    final path = Path();
    
    // Draw mouse capsule
    path.addRRect(RRect.fromRectAndRadius(mouseRect, Radius.circular(22 * scaleX)));
    canvas.drawPath(path, strokePaint);

    // Left/Right click separator line
    canvas.drawLine(
      Offset(mouseRect.left, mouseRect.top + 26 * scaleY),
      Offset(mouseRect.right, mouseRect.top + 26 * scaleY),
      strokePaint,
    );

    // Vertical line between buttons
    canvas.drawLine(
      Offset(mouseRect.center.dx, mouseRect.top),
      Offset(mouseRect.center.dx, mouseRect.top + 26 * scaleY),
      strokePaint,
    );

    // Scroll wheel (small rounded rect)
    final wheelRect = Rect.fromCenter(
      center: Offset(mouseRect.center.dx, mouseRect.top + 13 * scaleY),
      width: 6 * scaleX,
      height: 12 * scaleY,
    );
    canvas.drawRRect(RRect.fromRectAndRadius(wheelRect, Radius.circular(3 * scaleX)), paint);

    // Curved mouse wire (bottom-left)
    final wirePath = Path()
      ..moveTo(mouseRect.left + 15 * scaleX, mouseRect.bottom - 1 * scaleY)
      ..cubicTo(
        mouseRect.left + 5 * scaleX, mouseRect.bottom + 10 * scaleY,
        mouseRect.left - 10 * scaleX, mouseRect.bottom + 5 * scaleY,
        mouseRect.left - 5 * scaleX, mouseRect.bottom - 8 * scaleY,
      );
    canvas.drawPath(wirePath, strokePaint);

    // Draw Gear (top-right, centered around x: 72, y: 22)
    final gearCenter = Offset(72 * scaleX, 22 * scaleY);
    final gearRadius = 14.0 * scaleX;
    
    final gearPath = Path();
    const toothCount = 8;
    for (int i = 0; i < toothCount; i++) {
      final angle = (i * 2 * math.pi / toothCount) - (math.pi / 8);
      final nextAngle = angle + (math.pi / toothCount);
      
      final outerX1 = gearCenter.dx + (gearRadius + 4 * scaleX) * math.cos(angle);
      final outerY1 = gearCenter.dy + (gearRadius + 4 * scaleY) * math.sin(angle);
      final outerX2 = gearCenter.dx + (gearRadius + 4 * scaleX) * math.cos(nextAngle);
      final outerY2 = gearCenter.dy + (gearRadius + 4 * scaleY) * math.sin(nextAngle);
      
      final innerAngle = nextAngle + (math.pi / toothCount);
      final innerX = gearCenter.dx + gearRadius * math.cos(innerAngle);
      final innerY = gearCenter.dy + gearRadius * math.sin(innerAngle);

      if (i == 0) {
        gearPath.moveTo(outerX1, outerY1);
      } else {
        gearPath.lineTo(outerX1, outerY1);
      }
      gearPath.lineTo(outerX2, outerY2);
      gearPath.lineTo(innerX, innerY);
    }
    gearPath.close();
    canvas.drawPath(gearPath, paint);

    // Draw Gear Hole
    final gearHolePaint = Paint()
      ..color = gearHoleColor
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(gearCenter, 6 * scaleX, gearHolePaint);

    // Diagonal wrench slot
    final wrenchSlotPaint = Paint()
      ..color = gearHoleColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5 * scaleX
      ..strokeCap = StrokeCap.square;
    
    canvas.drawLine(
      Offset(gearCenter.dx - 4 * scaleX, gearCenter.dy + 4 * scaleY),
      Offset(gearCenter.dx + 4 * scaleX, gearCenter.dy - 4 * scaleY),
      wrenchSlotPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _BengkelMouseLogoPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.gearHoleColor != gearHoleColor;
  }
}
