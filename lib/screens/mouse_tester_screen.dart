import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../widgets/mouse_tester_widget.dart';

class MouseTesterScreen extends StatefulWidget {
  const MouseTesterScreen({super.key});

  @override
  State<MouseTesterScreen> createState() => _MouseTesterScreenState();
}

class _MouseTesterScreenState extends State<MouseTesterScreen> {
  int leftClickCount = 0;
  int rightClickCount = 0;
  int middleClickCount = 0;
  int sideButton1Count = 0;
  int sideButton2Count = 0;

  void _resetCounters() {
    setState(() {
      leftClickCount = 0;
      rightClickCount = 0;
      middleClickCount = 0;
      sideButton1Count = 0;
      sideButton2Count = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Test Mouse',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _resetCounters,
              tooltip: 'Reset Counter',
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              height: 1,
              color: Theme.of(context).dividerTheme.color!,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              Text(
                'Tes Tombol Mouse',
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Klik setiap tombol untuk menguji fungsinya',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppTheme.textMuted
                      : AppTheme.textMutedLight,
                ),
              ),
              const SizedBox(height: 30),
              // Mouse Tester Widget
              const MouseTesterWidget(),
              const SizedBox(height: 40),
              // Click counters
              Text(
                'Statistik Klik',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              _buildCounterCard(
                'Klik Kiri',
                leftClickCount,
                Icons.mouse_outlined,
                AppTheme.primaryColor,
              ),
              const SizedBox(height: 10),
              _buildCounterCard(
                'Klik Kanan',
                rightClickCount,
                Icons.mouse_outlined,
                AppTheme.statusProgress,
              ),
              const SizedBox(height: 10),
              _buildCounterCard(
                'Scroll Wheel (Tengah)',
                middleClickCount,
                Icons.settings_input_composite_outlined,
                AppTheme.statusDone,
              ),
              const SizedBox(height: 10),
              _buildCounterCard(
                'Tombol Samping 1',
                sideButton1Count,
                Icons.touch_app_outlined,
                AppTheme.statusCancelled,
              ),
              const SizedBox(height: 10),
              _buildCounterCard(
                'Tombol Samping 2',
                sideButton2Count,
                Icons.touch_app_outlined,
                const Color(0xFFFF9800),
              ),
              const SizedBox(height: 30),
              // Info card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.primaryColor.withAlpha(60),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: AppTheme.primaryColor,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Klik pada setiap bagian mouse untuk menguji apakah tombol berfungsi dengan baik.',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: AppTheme.primaryColor,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCounterCard(String title, int count, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerTheme.color!,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: color.withAlpha(60),
              ),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: color.withAlpha(60),
              ),
            ),
            child: Text(
              '$count',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
