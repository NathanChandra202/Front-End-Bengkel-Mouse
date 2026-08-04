import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme.dart';
import '../../providers/theme_provider.dart';
import '../../providers/user_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final isDark = themeProvider.isDarkMode;

    final name = userProvider.name.isNotEmpty ? userProvider.name : 'Pengguna';
    final email = userProvider.email.isNotEmpty ? userProvider.email : '-';
    final phone = userProvider.phone.isNotEmpty ? userProvider.phone : '-';
    final initials = userProvider.initials;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Profil Saya',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          automaticallyImplyLeading: false,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: Theme.of(context).dividerTheme.color!),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 24),
              // User Card Info
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).dividerTheme.color!),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: AppTheme.primaryColor.withAlpha(20),
                      child: Text(
                        initials,
                        style: GoogleFonts.outfit(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            email,
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              color: isDark ? AppTheme.textMuted : AppTheme.textMutedLight,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            phone,
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              color: isDark ? AppTheme.textMuted : AppTheme.textMutedLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit_outlined, color: isDark ? AppTheme.textMuted : AppTheme.textMutedLight, size: 20),
                      onPressed: () => _showEditProfileDialog(context, userProvider),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Settings Group 1: Account & Activities
              _buildSectionHeader(context, 'Aktivitas & Akun'),
              _buildSettingCard(
                context,
                children: [
                  _buildSettingItem(
                    context,
                    icon: Icons.list_alt_rounded,
                    title: 'Riwayat Pesanan',
                    subtitle: 'Cek status perbaikan mouse kamu',
                    onTap: () => context.push('/orders'),
                  ),
                  _buildDivider(context),
                  _buildSettingItem(
                    context,
                    icon: Icons.location_on_outlined,
                    title: 'Alamat Saya',
                    subtitle: 'Kelola alamat pengiriman & penjemputan',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Fitur alamat segera hadir!')),
                      );
                    },
                  ),
                  _buildDivider(context),
                  _buildSettingItem(
                    context,
                    icon: Icons.payment_outlined,
                    title: 'Metode Pembayaran',
                    subtitle: 'Kelola e-wallet & rekening bank',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Fitur pembayaran segera hadir!')),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Settings Group 2: App Settings
              _buildSectionHeader(context, 'Pengaturan Aplikasi'),
              _buildSettingCard(
                context,
                children: [
                  _buildSettingItem(
                    context,
                    icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    title: 'Mode Gelap',
                    subtitle: isDark ? 'Aktif' : 'Nonaktif',
                    trailing: Switch.adaptive(
                      value: isDark,
                      activeThumbColor: AppTheme.primaryColor,
                      onChanged: (_) => themeProvider.toggleTheme(),
                    ),
                  ),
                  _buildDivider(context),
                  _buildSettingItem(
                    context,
                    icon: Icons.notifications_none_rounded,
                    title: 'Notifikasi',
                    subtitle: 'Atur pemberitahuan update status',
                    onTap: () => context.push('/notifications'),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Settings Group 3: Support & Log Out
              _buildSectionHeader(context, 'Dukungan'),
              _buildSettingCard(
                context,
                children: [
                  _buildSettingItem(
                    context,
                    icon: Icons.help_outline_rounded,
                    title: 'Pusat Bantuan',
                    subtitle: 'Pertanyaan umum & panduan layanan',
                    onTap: () => context.push('/help'),
                  ),
                  _buildDivider(context),
                  _buildSettingItem(
                    context,
                    icon: Icons.logout_rounded,
                    title: 'Keluar Akun',
                    subtitle: 'Keluar dari sesi saat ini',
                    titleColor: AppTheme.primaryColor,
                    iconColor: AppTheme.primaryColor,
                    onTap: () => _showLogoutDialog(context),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNav(context),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, UserProvider userProvider) {
    final nameCtrl = TextEditingController(text: userProvider.name);
    final phoneCtrl = TextEditingController(text: userProvider.phone);
    final addressCtrl = TextEditingController(text: userProvider.address);
    bool saving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Edit Profil', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: Theme.of(ctx).colorScheme.onSurface)),
                  const SizedBox(height: 20),
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Nama',
                      labelStyle: GoogleFonts.outfit(),
                    ),
                    style: GoogleFonts.outfit(color: Theme.of(ctx).colorScheme.onSurface),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Nomor Telepon',
                      labelStyle: GoogleFonts.outfit(),
                    ),
                    style: GoogleFonts.outfit(color: Theme.of(ctx).colorScheme.onSurface),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: addressCtrl,
                    decoration: InputDecoration(
                      labelText: 'Alamat',
                      labelStyle: GoogleFonts.outfit(),
                    ),
                    style: GoogleFonts.outfit(color: Theme.of(ctx).colorScheme.onSurface),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: saving
                          ? null
                          : () async {
                              setModalState(() => saving = true);
                              try {
                                await userProvider.updateProfile(
                                  name: nameCtrl.text.trim(),
                                  phone: phoneCtrl.text.trim(),
                                  address: addressCtrl.text.trim(),
                                );
                                if (ctx.mounted) {
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Profil berhasil diperbarui!')),
                                  );
                                }
                              } catch (e) {
                                if (ctx.mounted) {
                                  setModalState(() => saving = false);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
                                  );
                                }
                              }
                            },
                      child: saving
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text('Simpan', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppTheme.primaryColor,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingCard(BuildContext context, {required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerTheme.color!),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Color? iconColor,
    Color? titleColor,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: (iconColor ?? AppTheme.primaryColor).withAlpha(15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor ?? (isDark ? AppTheme.textColor : AppTheme.textColorLight),
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: titleColor ?? Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      color: isDark ? AppTheme.textMuted : AppTheme.textMutedLight,
                    ),
                  ),
                ],
              ),
            ),
            trailing ??
                Icon(
                  Icons.chevron_right_rounded,
                  color: isDark ? AppTheme.textMuted : AppTheme.textMutedLight,
                  size: 20,
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 16,
      endIndent: 16,
      color: Theme.of(context).dividerTheme.color!,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Keluar Akun',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Apakah kamu yakin ingin keluar dari akun?',
          style: GoogleFonts.outfit(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Batal',
              style: GoogleFonts.outfit(color: AppTheme.textMuted, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final userProvider = Provider.of<UserProvider>(context, listen: false);
              await userProvider.logout();
              if (context.mounted) context.go('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              'Keluar',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: Colors.white),
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
        currentIndex: 3,
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
          if (i == 0) context.go('/home');
          if (i == 1) context.push('/orders');
          if (i == 2) context.push('/booking');
        },
      ),
    );
  }
}
