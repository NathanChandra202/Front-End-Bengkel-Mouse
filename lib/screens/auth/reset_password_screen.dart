import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme.dart';
import '../../services/api_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _otpCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  String? _errorMsg;

  @override
  void dispose() {
    _otpCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    final otp = _otpCtrl.text.trim();
    final newPassword = _passwordCtrl.text;
    final confirm = _confirmCtrl.text;

    if (otp.isEmpty || newPassword.isEmpty || confirm.isEmpty) {
      setState(() => _errorMsg = 'Semua kolom wajib diisi');
      return;
    }
    if (otp.length != 6) {
      setState(() => _errorMsg = 'Kode OTP harus 6 digit');
      return;
    }
    if (newPassword.length < 6) {
      setState(() => _errorMsg = 'Password minimal 6 karakter');
      return;
    }
    if (newPassword != confirm) {
      setState(() => _errorMsg = 'Konfirmasi password tidak cocok');
      return;
    }

    setState(() { _loading = true; _errorMsg = null; });
    try {
      await ApiService.resetPassword(widget.email, otp, newPassword);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password berhasil diubah! Silakan login.'),
            backgroundColor: Color(0xFF22C55E),
          ),
        );
        // Go back to login
        context.go('/login');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMsg = e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        appBar: AppBar(
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
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.primaryColor.withAlpha(80)),
                ),
                child: const Icon(Icons.verified_outlined, color: AppTheme.primaryColor, size: 28),
              ),
              const SizedBox(height: 24),
              Text(
                'Masukkan Kode OTP',
                style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface, letterSpacing: -0.5),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: GoogleFonts.outfit(fontSize: 14, color: (Theme.of(context).brightness == Brightness.dark ? AppTheme.textMuted : AppTheme.textMutedLight), height: 1.6),
                  children: [
                    const TextSpan(text: 'Kode 6 digit telah dikirim ke '),
                    TextSpan(
                      text: widget.email,
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: AppTheme.primaryColor),
                    ),
                    const TextSpan(text: '. Masukkan kode dan password baru kamu.'),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // OTP Field
              Text('Kode OTP (6 Digit)', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _otpCtrl,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 10,
                ),
                decoration: InputDecoration(
                  hintText: '------',
                  hintStyle: GoogleFonts.outfit(fontSize: 24, letterSpacing: 10, color: Theme.of(context).hintColor),
                  counterText: '',
                ),
              ),
              const SizedBox(height: 24),

              // New Password
              Text('Password Baru', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordCtrl,
                obscureText: _obscurePass,
                style: GoogleFonts.outfit(color: Theme.of(context).colorScheme.onSurface, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Minimal 6 karakter',
                  prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                  prefixIconConstraints: const BoxConstraints(minWidth: 50),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePass ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20),
                    onPressed: () => setState(() => _obscurePass = !_obscurePass),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Confirm Password
              Text('Konfirmasi Password', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _confirmCtrl,
                obscureText: _obscureConfirm,
                style: GoogleFonts.outfit(color: Theme.of(context).colorScheme.onSurface, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Ulangi password baru',
                  prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                  prefixIconConstraints: const BoxConstraints(minWidth: 50),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20),
                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
              ),

              if (_errorMsg != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withAlpha(80)),
                  ),
                  child: Text(
                    _errorMsg!,
                    style: GoogleFonts.outfit(color: Colors.red, fontSize: 13),
                  ),
                ),
              ],

              const SizedBox(height: 32),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _loading ? null : _resetPassword,
                  child: _loading
                    ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text('Ubah Password', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
