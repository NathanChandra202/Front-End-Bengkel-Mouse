import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  static const _faqs = [
    {
      'q': 'Bagaimana cara melakukan booking servis?',
      'a': 'Buka menu Booking di halaman utama atau tab bawah. Isi informasi mouse kamu (Brand, Model), pilih kategori masalah, tambahkan deskripsi detail dan foto opsional, lalu ikuti langkah pengiriman.'
    },
    {
      'q': 'Berapa lama proses perbaikan mouse?',
      'a': 'Rata-rata 3–7 hari kerja tergantung jenis kerusakan dan ketersediaan sparepart. Kamu bisa pantau statusnya secara real-time di menu Pesanan.'
    },
    {
      'q': 'Bagaimana cara mengetahui biaya perbaikan?',
      'a': 'Setelah mouse diterima, admin kami akan melakukan pengecekan dan menentukan estimasi biaya. Kamu akan mendapatkan notifikasi dan dapat melihatnya di detail pesanan sebelum menyetujui.'
    },
    {
      'q': 'Metode pembayaran apa yang tersedia?',
      'a': 'Saat ini kami menerima pembayaran via transfer bank (BCA, BNI, Mandiri) atau dompet digital (GoPay, OVO). Kamu perlu melampirkan bukti transfer di halaman pembayaran.'
    },
    {
      'q': 'Apakah ada garansi setelah perbaikan?',
      'a': 'Ya! Kami memberikan garansi servis selama 30 hari setelah perbaikan untuk masalah yang sama. Jika masalah muncul kembali, kirimkan mouse kembali dan tidak akan dikenakan biaya.'
    },
    {
      'q': 'Bagaimana cara mengirim mouse ke bengkel?',
      'a': 'Kamu bisa mengirim via kurir (GoSend, JNE, J&T) atau datang langsung ke bengkel. Pastikan mouse dikemas dengan aman dan tuliskan ID Booking di paket untuk memudahkan admin.'
    },
    {
      'q': 'Apakah saya bisa membatalkan pesanan?',
      'a': 'Pembatalan dapat dilakukan selama status masih PENDING (sebelum mouse diterima admin). Hubungi kami via WhatsApp untuk proses pembatalan.'
    },
    {
      'q': 'Bagaimana jika mouse saya hilang atau rusak lebih parah selama servis?',
      'a': 'Kami bertanggung jawab penuh atas keamanan mouse kamu selama proses servis. Jika ada masalah, hubungi kami segera dan kami akan menyelesaikannya.'
    },
  ];

  Future<void> _launchWhatsApp() async {
    const phone = '6281234567890'; // replace with real number
    const message = 'Halo Bengkel Mouse, saya membutuhkan bantuan.';
    final uri = Uri.parse('https://wa.me/$phone?text=${Uri.encodeComponent(message)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchEmail() async {
    final uri = Uri.parse('mailto:support@bengkelmouse.id?subject=Bantuan%20Servis');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Pusat Bantuan',
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: Theme.of(context).colorScheme.onSurface),
            onPressed: () => context.pop(),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: Theme.of(context).dividerTheme.color!),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.primaryColor, AppTheme.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.support_agent_rounded, color: Colors.white, size: 32),
                      const SizedBox(height: 12),
                      Text(
                        'Kami siap membantu!',
                        style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Temukan jawaban dari pertanyaan umum di bawah, atau hubungi tim kami langsung.',
                        style: GoogleFonts.outfit(fontSize: 13, color: Colors.white70, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Contact section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'HUBUNGI KAMI',
                  style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.primaryColor, letterSpacing: 0.8),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildContactCard(
                        context,
                        icon: Icons.phone_in_talk_rounded,
                        label: 'WhatsApp',
                        value: '+62 812-3456-7890',
                        color: const Color(0xFF25D366),
                        onTap: _launchWhatsApp,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildContactCard(
                        context,
                        icon: Icons.email_rounded,
                        label: 'Email',
                        value: 'support@bengkelmouse.id',
                        color: Colors.blue,
                        onTap: _launchEmail,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Theme.of(context).dividerTheme.color!),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withAlpha(20),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.location_on_rounded, color: AppTheme.primaryColor, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Alamat Bengkel', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface)),
                            const SizedBox(height: 2),
                            Text(
                              'Jl. H. Hasan No.26, RT.3/RW.10, Baru, Kec. Pasar Rebo, Jakarta Timur 13780',
                              style: GoogleFonts.outfit(fontSize: 12, color: isDark ? AppTheme.textMuted : AppTheme.textMutedLight, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // FAQ
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'PERTANYAAN UMUM (FAQ)',
                  style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.primaryColor, letterSpacing: 0.8),
                ),
              ),
              const SizedBox(height: 12),
              ..._faqs.map((faq) => _buildFAQTile(context, faq['q']!, faq['a']!, isDark)),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactCard(BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerTheme.color!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 10),
            Text(label, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 2),
            Text(value, style: GoogleFonts.outfit(fontSize: 11, color: color, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQTile(BuildContext context, String question, String answer, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerTheme.color!),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.question_mark_rounded, color: AppTheme.primaryColor, size: 14),
          ),
          title: Text(
            question,
            style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface),
          ),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              answer,
              style: GoogleFonts.outfit(fontSize: 13, color: isDark ? AppTheme.textMuted : AppTheme.textMutedLight, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}
