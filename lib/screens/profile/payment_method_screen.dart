import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme.dart';

class PaymentMethodScreen extends StatelessWidget {
  const PaymentMethodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Metode Pembayaran',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Theme.of(context).dividerTheme.color!),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildPaymentCard(
            context,
            title: 'Gopay',
            subtitle: 'Otomatis pakai saldo Gopay',
            icon: Icons.account_balance_wallet,
            isDark: isDark,
          ),
          const SizedBox(height: 16),
          _buildPaymentCard(
            context,
            title: 'BCA Virtual Account',
            subtitle: 'Transfer dari m-BCA / ATM BCA',
            icon: Icons.account_balance,
            isDark: isDark,
          ),
          const SizedBox(height: 16),
          _buildPaymentCard(
            context,
            title: 'Transfer Bank Lainnya',
            subtitle: 'BNI, Mandiri, BRI, dll',
            icon: Icons.account_balance,
            isDark: isDark,
          ),
          const SizedBox(height: 32),
          Text(
            'Metode pembayaran tambahan akan hadir segera. Saat ini pembayaran dilakukan manual sesuai instruksi pada halaman pesanan.',
            style: GoogleFonts.outfit(
              fontSize: 13,
              color: isDark ? AppTheme.textMuted : AppTheme.textMutedLight,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerTheme.color!),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: (isDark ? Colors.grey[800] : Colors.grey[100]),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppTheme.primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: isDark ? AppTheme.textMuted : AppTheme.textMutedLight,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.check_circle, color: AppTheme.primaryColor, size: 20),
        ],
      ),
    );
  }
}
