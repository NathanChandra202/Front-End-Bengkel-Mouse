import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme.dart';
import '../../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl    = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _waCtrl      = TextEditingController();
  final _passCtrl    = TextEditingController();
  bool _showPass     = false;
  bool _loading      = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _waCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final name    = _nameCtrl.text.trim();
    final email   = _emailCtrl.text.trim();
    final phone   = _waCtrl.text.trim();
    final password = _passCtrl.text;

    if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua field harus diisi.')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await ApiService.register(name, email, password, phone, '');
      if (mounted) {
        context.go('/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
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
          title: Text(
            'Buat Akun Baru',
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
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Daftar sekarang,\nbayar nanti.',
                style: GoogleFonts.outfit(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                  letterSpacing: -0.8,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Isi data diri kamu untuk mulai booking servis.',
                style: GoogleFonts.outfit(color: (Theme.of(context).brightness == Brightness.dark ? AppTheme.textMuted : AppTheme.textMutedLight), fontSize: 14),
              ),
              const SizedBox(height: 36),

              _buildLabel('Nama Lengkap'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
                style: GoogleFonts.outfit(color: Theme.of(context).colorScheme.onSurface, fontSize: 15),
                decoration: const InputDecoration(
                  hintText: 'Nama kamu',
                  prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
                  prefixIconConstraints: BoxConstraints(minWidth: 50),
                ),
              ),
              const SizedBox(height: 18),

              _buildLabel('Alamat Email'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: GoogleFonts.outfit(color: Theme.of(context).colorScheme.onSurface, fontSize: 15),
                decoration: const InputDecoration(
                  hintText: 'nama@email.com',
                  prefixIcon: Icon(Icons.email_outlined, size: 20),
                  prefixIconConstraints: BoxConstraints(minWidth: 50),
                ),
              ),
              const SizedBox(height: 18),

              _buildLabel('Nomor WhatsApp'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _waCtrl,
                keyboardType: TextInputType.phone,
                style: GoogleFonts.outfit(color: Theme.of(context).colorScheme.onSurface, fontSize: 15),
                decoration: const InputDecoration(
                  hintText: '08xxxxxxxxxxxx',
                  prefixIcon: Icon(Icons.phone_android_outlined, size: 20),
                  prefixIconConstraints: BoxConstraints(minWidth: 50),
                ),
              ),
              const SizedBox(height: 18),

              _buildLabel('Password'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passCtrl,
                obscureText: !_showPass,
                style: GoogleFonts.outfit(color: Theme.of(context).colorScheme.onSurface, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Min. 8 karakter',
                  prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                  prefixIconConstraints: const BoxConstraints(minWidth: 50),
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _showPass = !_showPass),
                    icon: Icon(
                      _showPass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: 20,
                      color: (Theme.of(context).brightness == Brightness.dark ? AppTheme.textMuted : AppTheme.textMutedLight),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 36),

              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _loading ? null : _register,
                  child: _loading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text('Buat Akun', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: GoogleFonts.outfit(color: Theme.of(context).colorScheme.onSurface, fontSize: 13, fontWeight: FontWeight.w500));
  }
}
