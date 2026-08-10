import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme.dart';
import '../../providers/theme_provider.dart';
import '../../providers/user_provider.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Cek alamat setiap kali masuk home (login baru maupun sudah login)
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAddress());
  }

  void _checkAddress() {
    final userProv = Provider.of<UserProvider>(context, listen: false);
    if (!userProv.isLoggedIn || userProv.isAdmin) return;

    // Hanya tampilkan kalau alamat benar-benar kosong
    // Kalau sudah ada alamat, jangan ganggu tiap kali balik ke home
    final address = userProv.address;
    if (address.trim().isNotEmpty) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Alamat Belum Diisi',
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        content: Text(
          'Alamat kamu belum diisi. Lengkapi profil sekarang agar mouse kamu bisa dikirim kembali setelah selesai diperbaiki.',
          style: GoogleFonts.outfit(fontSize: 13, height: 1.6),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Nanti', style: GoogleFonts.outfit(color: Theme.of(context).colorScheme.onSurface.withAlpha(150))),
          ),
          ElevatedButton(
            onPressed: () { Navigator.of(ctx).pop(); context.push('/profile'); },
            child: Text('Ke Profil', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            _buildAppBar(context),
            SliverToBoxAdapter(child: _buildHero(context)),
            SliverToBoxAdapter(child: _buildStats(context)),
            SliverToBoxAdapter(child: _buildServicesTitle(context)),
            _buildServicesList(context),
            SliverToBoxAdapter(child: _buildCtaBanner(context)),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
        bottomNavigationBar: _buildBottomNav(context),
        floatingActionButton: _buildWhatsAppFAB(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: Theme.of(context).dividerTheme.color!),
      ),
      title: Row(
        children: [
          Image.asset(
            'assets/images/logo.png',
            height: 30,
          ),
        ],
      ),
      actions: [
        Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return IconButton(
              onPressed: () => themeProvider.toggleTheme(),
              icon: Icon(
                themeProvider.isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                color: (Theme.of(context).brightness == Brightness.dark ? AppTheme.textMuted : AppTheme.textMutedLight),
              ),
            );
          },
        ),
        IconButton(
          onPressed: () => context.push('/notifications'),
          icon: Icon(Icons.notifications_outlined, color: (Theme.of(context).brightness == Brightness.dark ? AppTheme.textMuted : AppTheme.textMutedLight)),
        ),
        Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            return InkWell(
              onTap: () => context.push('/profile'),
              customBorder: const CircleBorder(),
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.all(4),
                child: CircleAvatar(
                  radius: 17,
                  backgroundColor: (Theme.of(context).brightness == Brightness.dark ? AppTheme.surfaceHighColor : AppTheme.surfaceHighColorLight),
                  child: Text(
                    userProvider.initials,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHero(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerTheme.color!),
        color: Theme.of(context).colorScheme.surface,
        image: const DecorationImage(
          image: NetworkImage('https://bengkelmouse.duaenam.id/images/logo.jpg'),
          alignment: Alignment.centerRight,
          opacity: 0.06,
          fit: BoxFit.contain,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withAlpha(30),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.primaryColor.withAlpha(80)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6, height: 6,
                  decoration: const BoxDecoration(color: AppTheme.primaryColor, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Text(
                  'Buka & Siap Servis',
                  style: GoogleFonts.outfit(
                    fontSize: 11, color: AppTheme.primaryColor, fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Mouse kamu\nbermasalah?',
            style: GoogleFonts.outfit(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.onSurface,
              height: 1.1,
              letterSpacing: -1.0,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Servis & modifikasi mouse gaming\nby 26 Computer — Jakarta.',
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: (Theme.of(context).brightness == Brightness.dark ? AppTheme.textMuted : AppTheme.textMutedLight),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () => context.push('/booking'),
                    child: Text(
                      'Booking Sekarang',
                      style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: OutlinedButton(
                    onPressed: () => context.push('/orders'),
                    child: Text(
                      'Cek Orderan',
                      style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStats(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          _statCard(context, '500+', 'Mouse Diservice'),
          const SizedBox(width: 12),
          _statCard(context, '4.9★', 'Rating Pelanggan'),
          const SizedBox(width: 12),
          _statCard(context, '1–3hr', 'Estimasi Servis'),
        ],
      ),
    );
  }

  Widget _statCard(BuildContext context, String val, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerTheme.color!),
        ),
        child: Column(
          children: [
            Text(
              val,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(fontSize: 10, color: (Theme.of(context).brightness == Brightness.dark ? AppTheme.textMuted : AppTheme.textMutedLight)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesTitle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
      child: Row(
        children: [
          Text(
            'Layanan Kami',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const Spacer(),
          Text(
            'Semua →',
            style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.primaryColor, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  SliverList _buildServicesList(BuildContext context) {
    final services = [
      _ServiceItem('Ganti Switch', 'Double click? Kami ganti switch dengan yang baru.', 'Mulai Rp 80.000', Icons.mouse_outlined),
      _ServiceItem('Deep Cleaning', 'Bersihkan sensor, scroll, dan bagian dalam mouse.', 'Mulai Rp 50.000', Icons.cleaning_services_outlined),
      _ServiceItem('Ganti Kabel', 'Kabel kaku & berat? Upgrade ke paracord fleksibel.', 'Mulai Rp 120.000', Icons.cable_outlined),
      _ServiceItem('Perbaikan Sensor', 'Sensor loncat atau nggak akurat? Kita benerin.', 'Mulai Rp 100.000', Icons.gps_fixed_outlined),
      _ServiceItem('Ganti Baterai', 'Mouse wireless boros baterai atau nggak nyala.', 'Mulai Rp 75.000', Icons.battery_charging_full_outlined),
    ];

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (ctx, i) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: _buildServiceCard(context, services[i]),
        ),
        childCount: services.length,
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, _ServiceItem s) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).dividerTheme.color!),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withAlpha(30),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.primaryColor.withAlpha(60)),
            ),
            child: Icon(s.icon, color: AppTheme.primaryColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.title,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  s.description,
                  style: GoogleFonts.outfit(fontSize: 12, color: (Theme.of(context).brightness == Brightness.dark ? AppTheme.textMuted : AppTheme.textMutedLight)),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            s.price,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCtaBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryDark, AppTheme.primaryColor.withAlpha(200)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Konsultasi Gratis',
                  style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  'Hubungi kami via WhatsApp\nsebelum kirim mouse.',
                  style: GoogleFonts.outfit(fontSize: 13, color: Colors.white70, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(40),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withAlpha(80)),
            ),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.chat_rounded, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: Theme.of(context).dividerTheme.color!, width: 1)),
      ),
      child: BottomNavigationBar(
        currentIndex: 0,
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Theme.of(context).brightness == Brightness.dark ? AppTheme.textMuted : AppTheme.textMutedLight,
        selectedLabelStyle: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.outfit(fontSize: 11),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home_rounded), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt_outlined), activeIcon: Icon(Icons.list_alt_rounded), label: 'Pesanan'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline_rounded), activeIcon: Icon(Icons.add_circle_rounded), label: 'Booking'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), activeIcon: Icon(Icons.person_rounded), label: 'Profil'),
        ],
        onTap: (i) {
          if (i == 1) context.push('/orders');
          if (i == 2) context.push('/booking');
          if (i == 3) context.push('/profile');
        },
      ),
    );
  }

  Widget _buildWhatsAppFAB() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: FloatingActionButton(
        onPressed: () {
          // TODO: Launch WhatsApp
        },
        backgroundColor: const Color(0xFF25D366),
        elevation: 4,
        child: const Icon(Icons.chat_rounded, color: Colors.white, size: 26),
      ),
    );
  }
}

class _ServiceItem {
  final String title;
  final String description;
  final String price;
  final IconData icon;
  _ServiceItem(this.title, this.description, this.price, this.icon);
}
