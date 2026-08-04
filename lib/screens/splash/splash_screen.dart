import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/bengkel_mouse_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _textSlideAnimation;
  late Animation<double> _loadingProgressAnimation;
  late Animation<double> _bgAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    // Subtle breathing animation for the low-poly background
    _bgAnimation = Tween<double>(begin: 0.85, end: 1.05).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeInOut),
      ),
    );

    // Logo scale: bounce/elastic entry
    _logoScaleAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.7, curve: Curves.elasticOut),
      ),
    );

    // Logo fade
    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.4, curve: Curves.easeIn),
      ),
    );

    // Text fade in
    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 0.8, curve: Curves.easeIn),
      ),
    );

    // Text slide from left/bottom
    _textSlideAnimation = Tween<double>(begin: 25.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    // Loading bar progress
    _loadingProgressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.95, curve: Curves.easeInOut),
      ),
    );

    _controller.forward();
    _navigateToNext();
  }

  /// FIXED VERSION:
  /// - fetchUser() dibungkus .timeout() supaya gak nge-hang selamanya
  ///   kalau API lambat/gak kebalas/base URL salah.
  /// - Seluruh proses fetch dibungkus try-catch supaya error apapun
  ///   (timeout, exception, format response salah, dll) TIDAK menggagalkan
  ///   navigasi. Splash akan selalu lanjut ke halaman berikutnya.
  Future<void> _navigateToNext() async {
    final userProv = Provider.of<UserProvider>(context, listen: false);

    // Jalankan fetchUser dengan timeout supaya gak gantung tanpa batas
    final fetchFuture = userProv.fetchUser().timeout(
      const Duration(seconds: 8),
      onTimeout: () {
        debugPrint('[SplashScreen] fetchUser() timeout setelah 8 detik');
      },
    );

    try {
      // Tunggu animasi splash minimal selesai + fetch data user
      await Future.wait([
        Future.delayed(const Duration(milliseconds: 3500)),
        fetchFuture,
      ]);
    } catch (e, stackTrace) {
      // Apapun errornya (network error, parsing error, dll),
      // JANGAN biarkan splash macet. Cukup log lalu lanjut ke bawah.
      debugPrint('[SplashScreen] Gagal fetch user: $e');
      debugPrint('$stackTrace');
    }

    // Guard: widget mungkin sudah di-dispose kalau user keluar dari app
    // saat proses fetch masih berjalan.
    if (!mounted) return;

    // Apapun hasil fetch di atas (berhasil / gagal / timeout),
    // navigasi TETAP jalan berdasarkan state UserProvider saat ini.
    if (userProv.isLoggedIn) {
      if (userProv.isAdmin) {
        context.go('/admin');
      } else {
        context.go('/home');
      }
    } else {
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF7A0808), // Fallback background color
        body: Stack(
          children: [
            // Custom Low-Poly Red Background
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _bgAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _LowPolyPainter(scale: _bgAnimation.value),
                  );
                },
              ),
            ),

            // Subtle dark overlay to ensure readability
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.35),
                      Colors.black.withOpacity(0.15),
                      Colors.black.withOpacity(0.45),
                    ],
                  ),
                ),
              ),
            ),

            // Logo and Title Content
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Main Logo & Brand Text Row
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _logoFadeAnimation.value,
                          child: Transform.scale(
                            scale: _logoScaleAnimation.value,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Reusable Custom Logo
                                const BengkelMouseLogo(
                                  size: 100,
                                  color: Colors.white,
                                  gearHoleColor: Color(0xFF8B0E0E),
                                ),
                                const SizedBox(width: 16),
                                // Text Column: "Bengkel Mouse"
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Bengkel',
                                      style: GoogleFonts.outfit(
                                        fontSize: 42,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        height: 0.95,
                                      ),
                                    ),
                                    Text(
                                      'Mouse',
                                      style: GoogleFonts.outfit(
                                        fontSize: 42,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        height: 0.95,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 18),

                    // "by 26 Computer"
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _textSlideAnimation.value),
                          child: Opacity(
                            opacity: _textFadeAnimation.value,
                            child: Text(
                              'by 26 Computer'.toUpperCase(),
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withOpacity(0.85),
                                letterSpacing: 4.5,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Loading Bar at Bottom
            Positioned(
              bottom: 60,
              left: 50,
              right: 50,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Opacity(
                    opacity: _textFadeAnimation.value,
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Container(
                            height: 3,
                            width: 180,
                            color: Colors.white.withOpacity(0.15),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: FractionallySizedBox(
                                widthFactor: _loadingProgressAnimation.value,
                                heightFactor: 1.0,
                                child: Container(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'memuat sistem...',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter to generate low-poly red triangles matching the brand image.
class _LowPolyPainter extends CustomPainter {
  final double scale;
  const _LowPolyPainter({required this.scale});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Base gradient
    final baseGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFF5A0202), // Very dark crimson
        const Color(0xFF8B0E0E), // Brand red
        const Color(0xFF3D0101), // Near black red
      ],
    );
    canvas.drawRect(rect, Paint()..shader = baseGradient.createShader(rect));

    // Low poly triangles definition
    final points = [
      Offset(0.0, 0.0),          // 0
      Offset(0.3, -0.05),        // 1
      Offset(0.65, 0.0),         // 2
      Offset(1.0, -0.1),         // 3
      Offset(-0.05, 0.35),       // 4
      Offset(0.25, 0.28),        // 5
      Offset(0.55, 0.42),        // 6
      Offset(0.85, 0.30),        // 7
      Offset(1.05, 0.45),        // 8
      Offset(0.0, 0.70),         // 9
      Offset(0.35, 0.65),        // 10
      Offset(0.70, 0.75),        // 11
      Offset(1.0, 0.80),         // 12
      Offset(-0.1, 1.05),        // 13
      Offset(0.4, 1.0),          // 14
      Offset(0.8, 1.05),         // 15
      Offset(1.05, 1.0),         // 16
    ];

    // Map to actual pixels
    final p = points.map((pt) {
      return Offset(pt.dx * size.width, pt.dy * size.height);
    }).toList();

    // Triangles (indices of points) and their color variations
    final triangles = [
      _Triangle(0, 1, 5, const Color(0xFF6B0505)),
      _Triangle(0, 5, 4, const Color(0xFF991212)),
      _Triangle(1, 2, 6, const Color(0xFF5A0202)),
      _Triangle(1, 6, 5, const Color(0xFFB01A1A)),
      _Triangle(2, 3, 7, const Color(0xFF7A0808)),
      _Triangle(2, 7, 6, const Color(0xFF4A0000)),
      _Triangle(3, 8, 7, const Color(0xFF8F0F0F)),

      _Triangle(4, 5, 10, const Color(0xFF800707)),
      _Triangle(4, 10, 9, const Color(0xFF5C0303)),
      _Triangle(5, 6, 11, const Color(0xFF9D1515)),
      _Triangle(5, 11, 10, const Color(0xFF6E0505)),
      _Triangle(6, 7, 12, const Color(0xFFB51D1D)),
      _Triangle(6, 12, 11, const Color(0xFF480101)),
      _Triangle(7, 8, 12, const Color(0xFF7D0909)),

      _Triangle(9, 10, 14, const Color(0xFF630303)),
      _Triangle(9, 14, 13, const Color(0xFF870B0B)),
      _Triangle(10, 11, 15, const Color(0xFF500202)),
      _Triangle(10, 15, 14, const Color(0xFFB21C1C)),
      _Triangle(11, 12, 16, const Color(0xFF720606)),
      _Triangle(11, 16, 15, const Color(0xFF901010)),
    ];

    // Apply scale shift centered around middle
    final center = Offset(size.width / 2, size.height / 2);

    for (var tri in triangles) {
      final p1 = _scalePoint(p[tri.a], center, scale);
      final p2 = _scalePoint(p[tri.b], center, scale);
      final p3 = _scalePoint(p[tri.c], center, scale);

      final path = Path()
        ..moveTo(p1.dx, p1.dy)
        ..lineTo(p2.dx, p2.dy)
        ..lineTo(p3.dx, p3.dy)
        ..close();

      final paint = Paint()
        ..color = tri.color.withOpacity(0.4) // Subtle opacity overlay
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, paint);

      // Draw subtle wireframe lines between low-poly facets
      final linePaint = Paint()
        ..color = Colors.white.withOpacity(0.04)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawPath(path, linePaint);
    }
  }

  Offset _scalePoint(Offset pt, Offset center, double scaleFactor) {
    return Offset(
      center.dx + (pt.dx - center.dx) * scaleFactor,
      center.dy + (pt.dy - center.dy) * scaleFactor,
    );
  }

  @override
  bool shouldRepaint(covariant _LowPolyPainter oldDelegate) => oldDelegate.scale != scale;
}

class _Triangle {
  final int a, b, c;
  final Color color;
  _Triangle(this.a, this.b, this.c, this.color);
}