import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

class MouseTesterWidget extends StatefulWidget {
  const MouseTesterWidget({super.key});

  @override
  State<MouseTesterWidget> createState() => _MouseTesterWidgetState();
}

class _MouseTesterWidgetState extends State<MouseTesterWidget> {
  bool leftButtonPressed = false;
  bool rightButtonPressed = false;
  bool middleButtonPressed = false;
  bool sideButton1Pressed = false;
  bool sideButton2Pressed = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 300,
        height: 440,
        child: CustomPaint(
          painter: MousePainter(
            leftPressed: leftButtonPressed,
            rightPressed: rightButtonPressed,
            middlePressed: middleButtonPressed,
            sideButton1Pressed: sideButton1Pressed,
            sideButton2Pressed: sideButton2Pressed,
            isDark: Theme.of(context).brightness == Brightness.dark,
          ),
          child: Stack(
            children: [
              // Left Click Area
              Positioned(
                left: 35,
                top: 15,
                child: GestureDetector(
                  onTapDown: (_) => setState(() => leftButtonPressed = true),
                  onTapUp: (_) => setState(() => leftButtonPressed = false),
                  onTapCancel: () => setState(() => leftButtonPressed = false),
                  child: Container(
                    width: 105,
                    height: 165,
                    color: Colors.transparent,
                  ),
                ),
              ),
              // Right Click Area
              Positioned(
                right: 35,
                top: 15,
                child: GestureDetector(
                  onTapDown: (_) => setState(() => rightButtonPressed = true),
                  onTapUp: (_) => setState(() => rightButtonPressed = false),
                  onTapCancel: () => setState(() => rightButtonPressed = false),
                  child: Container(
                    width: 105,
                    height: 165,
                    color: Colors.transparent,
                  ),
                ),
              ),
              // Middle Click / Scroll Wheel Area
              Positioned(
                left: 118,
                top: 50,
                child: GestureDetector(
                  onTapDown: (_) => setState(() => middleButtonPressed = true),
                  onTapUp: (_) => setState(() => middleButtonPressed = false),
                  onTapCancel: () => setState(() => middleButtonPressed = false),
                  child: Container(
                    width: 45,
                    height: 110,
                    color: Colors.transparent,
                  ),
                ),
              ),
              // Side Button 1 (Top)
              Positioned(
                left: 20,
                top: 165,
                child: GestureDetector(
                  onTapDown: (_) => setState(() => sideButton1Pressed = true),
                  onTapUp: (_) => setState(() => sideButton1Pressed = false),
                  onTapCancel: () => setState(() => sideButton1Pressed = false),
                  child: Container(
                    width: 15,
                    height: 80,
                    color: Colors.transparent,
                  ),
                ),
              ),
              // Side Button 2 (Bottom)
              Positioned(
                left: 20,
                top: 250,
                child: GestureDetector(
                  onTapDown: (_) => setState(() => sideButton2Pressed = true),
                  onTapUp: (_) => setState(() => sideButton2Pressed = false),
                  onTapCancel: () => setState(() => sideButton2Pressed = false),
                  child: Container(
                    width: 15,
                    height: 90,
                    color: Colors.transparent,
                  ),
                ),
              ),
              // Logo Area (26 COMPUTER)
              Positioned(
                left: 100,
                top: 270,
                child: Column(
                  children: [
                    Text(
                      '26',
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'COMPUTER',
                      style: GoogleFonts.outfit(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MousePainter extends CustomPainter {
  final bool leftPressed;
  final bool rightPressed;
  final bool middlePressed;
  final bool sideButton1Pressed;
  final bool sideButton2Pressed;
  final bool isDark;

  MousePainter({
    required this.leftPressed,
    required this.rightPressed,
    required this.middlePressed,
    required this.sideButton1Pressed,
    required this.sideButton2Pressed,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bodyPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final outlinePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final highlightPaint = Paint()
      ..color = AppTheme.primaryColor
      ..style = PaintingStyle.fill;

    final centerX = size.width / 2;

    // Main body path - bentuk mouse persis seperti gambar
    final bodyPath = Path();
    
    // Bagian atas mouse - rounded
    bodyPath.moveTo(centerX - 65, 20);
    bodyPath.quadraticBezierTo(centerX - 85, 15, centerX - 95, 40);
    
    // Sisi kiri atas
    bodyPath.lineTo(centerX - 100, 70);
    bodyPath.lineTo(centerX - 103, 120);
    bodyPath.lineTo(centerX - 103, 180);
    
    // Lengkungan ke garis horizontal
    bodyPath.quadraticBezierTo(centerX - 102, 195, centerX - 98, 200);
    bodyPath.lineTo(centerX - 90, 200);
    
    // Bagian bawah mouse - lengkungan besar
    bodyPath.lineTo(centerX - 90, 230);
    bodyPath.quadraticBezierTo(centerX - 88, 280, centerX - 75, 330);
    bodyPath.quadraticBezierTo(centerX - 55, 370, centerX - 30, 395);
    
    // Bottom curve
    bodyPath.quadraticBezierTo(centerX - 15, 408, centerX, 410);
    bodyPath.quadraticBezierTo(centerX + 15, 408, centerX + 30, 395);
    
    // Sisi kanan bawah
    bodyPath.quadraticBezierTo(centerX + 55, 370, centerX + 75, 330);
    bodyPath.quadraticBezierTo(centerX + 88, 280, centerX + 90, 230);
    
    // Sisi kanan atas
    bodyPath.lineTo(centerX + 90, 200);
    bodyPath.lineTo(centerX + 98, 200);
    bodyPath.quadraticBezierTo(centerX + 102, 195, centerX + 103, 180);
    bodyPath.lineTo(centerX + 103, 120);
    bodyPath.lineTo(centerX + 100, 70);
    
    // Top right curve
    bodyPath.lineTo(centerX + 95, 40);
    bodyPath.quadraticBezierTo(centerX + 85, 15, centerX + 65, 20);
    
    // Top arc
    bodyPath.quadraticBezierTo(centerX + 40, 10, centerX, 8);
    bodyPath.quadraticBezierTo(centerX - 40, 10, centerX - 65, 20);
    bodyPath.close();

    // Draw main body
    canvas.drawPath(bodyPath, bodyPaint);

    // Tombol kiri - area klik kiri
    final leftButtonPath = Path();
    leftButtonPath.moveTo(centerX - 65, 20);
    leftButtonPath.quadraticBezierTo(centerX - 85, 15, centerX - 95, 40);
    leftButtonPath.lineTo(centerX - 100, 70);
    leftButtonPath.lineTo(centerX - 103, 120);
    leftButtonPath.lineTo(centerX - 103, 180);
    leftButtonPath.lineTo(centerX - 7, 180);
    leftButtonPath.lineTo(centerX - 7, 20);
    leftButtonPath.quadraticBezierTo(centerX - 30, 10, centerX - 65, 20);
    leftButtonPath.close();

    if (leftPressed) {
      canvas.drawPath(leftButtonPath, highlightPaint);
    }
    canvas.drawPath(leftButtonPath, outlinePaint);

    // Tombol kanan - area klik kanan
    final rightButtonPath = Path();
    rightButtonPath.moveTo(centerX + 65, 20);
    rightButtonPath.quadraticBezierTo(centerX + 85, 15, centerX + 95, 40);
    rightButtonPath.lineTo(centerX + 100, 70);
    rightButtonPath.lineTo(centerX + 103, 120);
    rightButtonPath.lineTo(centerX + 103, 180);
    rightButtonPath.lineTo(centerX + 7, 180);
    rightButtonPath.lineTo(centerX + 7, 20);
    rightButtonPath.quadraticBezierTo(centerX + 30, 10, centerX + 65, 20);
    rightButtonPath.close();

    if (rightPressed) {
      canvas.drawPath(rightButtonPath, highlightPaint);
    }
    canvas.drawPath(rightButtonPath, outlinePaint);

    // Scroll wheel tengah - bentuk oval panjang dengan garis horizontal
    final scrollWheelPaint = Paint()
      ..color = middlePressed ? AppTheme.primaryColor : Colors.white
      ..style = PaintingStyle.fill;

    final scrollWheelOutline = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    // Scroll wheel shape - lebih tinggi dan tipis
    final wheelPath = Path();
    wheelPath.addRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX, 95),
        width: 28,
        height: 105,
      ),
      const Radius.circular(14),
    ));
    
    canvas.drawPath(wheelPath, scrollWheelPaint);
    canvas.drawPath(wheelPath, scrollWheelOutline);

    // Garis horizontal di dalam scroll wheel (texture detail)
    final linePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    for (int i = 0; i < 11; i++) {
      final y = 50 + (i * 9.0);
      canvas.drawLine(
        Offset(centerX - 11, y),
        Offset(centerX + 11, y),
        linePaint,
      );
    }

    // Garis pembatas horizontal antara atas dan bawah mouse
    canvas.drawLine(
      Offset(centerX - 98, 200),
      Offset(centerX + 98, 200),
      outlinePaint,
    );

    // Tombol samping 1 (atas) - bentuk rounded rectangle
    final sideButton1Path = Path();
    sideButton1Path.addRRect(RRect.fromRectAndRadius(
      const Rect.fromLTWH(28, 165, 15, 80),
      const Radius.circular(7),
    ));

    if (sideButton1Pressed) {
      canvas.drawPath(sideButton1Path, highlightPaint);
    }
    canvas.drawPath(sideButton1Path, outlinePaint);

    // Tombol samping 2 (bawah) - bentuk rounded rectangle lebih panjang
    final sideButton2Path = Path();
    sideButton2Path.addRRect(RRect.fromRectAndRadius(
      const Rect.fromLTWH(28, 250, 15, 90),
      const Radius.circular(7),
    ));

    if (sideButton2Pressed) {
      canvas.drawPath(sideButton2Path, highlightPaint);
    }
    canvas.drawPath(sideButton2Path, outlinePaint);

    // Logo "26 COMPUTER" - circular design dengan bintang
    final logoPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final logoFillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // 3 lingkaran konsentris
    canvas.drawCircle(Offset(centerX, 295), 52, logoPaint);
    canvas.drawCircle(Offset(centerX, 295), 47, logoPaint);
    canvas.drawCircle(Offset(centerX, 295), 42, logoPaint);

    // Bintang-bintang kecil di sekitar lingkaran
    for (int i = 0; i < 12; i++) {
      final angle = (i * 30) * math.pi / 180;
      final x = centerX + 38 * math.cos(angle);
      final y = 295 + 38 * math.sin(angle);
      canvas.drawCircle(Offset(x, y), 2.5, logoFillPaint);
    }
  }

  @override
  bool shouldRepaint(MousePainter oldDelegate) {
    return oldDelegate.leftPressed != leftPressed ||
        oldDelegate.rightPressed != rightPressed ||
        oldDelegate.middlePressed != middlePressed ||
        oldDelegate.sideButton1Pressed != sideButton1Pressed ||
        oldDelegate.sideButton2Pressed != sideButton2Pressed ||
        oldDelegate.isDark != isDark;
  }
}
