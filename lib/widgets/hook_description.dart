import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

class GlobalHookOverlay extends StatelessWidget {
  const GlobalHookOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      type: MaterialType.transparency,
      child: Container(
        width: double.infinity,
        color: isDark ? const Color(0xFF161618) : const Color(0xFFF3F4F6),
        padding: EdgeInsets.only(
          top: 6,
          bottom: MediaQuery.of(context).padding.bottom > 0 
              ? MediaQuery.of(context).padding.bottom 
              : 6,
          left: 16,
          right: 16,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.verified_rounded,
              size: 14,
              color: AppTheme.primaryColor.withValues(alpha: 0.8),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "Satu-satunya tempat service mouse berbasis aplikasi di Indonesia.",
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
