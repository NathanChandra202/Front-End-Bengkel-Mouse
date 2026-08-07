import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../theme.dart';
import '../../services/api_service.dart';
import '../../providers/user_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _showPass   = false;
  bool _loading    = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final data = await ApiService.login(_emailCtrl.text.trim(), _passCtrl.text);
      if (mounted) {
        setState(() => _loading = false);
        final userProv = Provider.of<UserProvider>(context, listen: false);
        userProv.setUser(data['user']);
        if (data['user']['role'] == 'ADMIN') {
          context.go('/admin');
        } else {
          context.go('/home');
          _checkAddress(context, data['user']);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    }
  }

  void _checkAddress(BuildContext context, Map<String, dynamic> user) {
    final address = (user['address'] as String?) ?? '';
    final msg = address.trim().isEmpty
        ? 'Alamat kamu belum diisi. Lengkapi profil sekarang agar pengiriman mouse kembali bisa diproses.'
        : 'Pastikan alamat kamu sudah benar di profil untuk pengiriman mouse kepulangan.';
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(
                address.trim().isEmpty ? Icons.warning_amber_rounded : Icons.location_on_outlined,
                color: address.trim().isEmpty ? Colors.orange : AppTheme.primaryColor,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                address.trim().isEmpty ? 'Alamat Belum Diisi' : 'Cek Alamat Kamu',
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          content: Text(
            msg,
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
    });
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _loading = true);
    try {
      final googleSignIn = GoogleSignIn.instance;
      await googleSignIn.initialize(
        serverClientId: '413473566922-1jgoa6purd23k4et9hbo9qq4ef2g57uj.apps.googleusercontent.com',
      );
      final googleUser = await googleSignIn.authenticate();
      final idToken = googleUser.authentication.idToken;
      if (idToken == null) throw Exception('Gagal mendapatkan ID token dari Google');

      final credential = GoogleAuthProvider.credential(idToken: idToken);
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final firebaseIdToken = await userCredential.user!.getIdToken();
      if (firebaseIdToken == null) throw Exception('Gagal mendapatkan token Firebase');

      final data = await ApiService.googleLogin(firebaseIdToken);
      if (mounted) {
        setState(() => _loading = false);
        final userProv = Provider.of<UserProvider>(context, listen: false);
        userProv.setUser(data['user']);
        if (data['user']['role'] == 'ADMIN') {
          context.go('/admin');
        } else {
          context.go('/home');
          _checkAddress(context, data['user']);
        }
      }
    } on GoogleSignInException catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        if (e.code != GoogleSignInExceptionCode.canceled) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Google Sign-In gagal: ${e.code.name}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.04,
                child: CustomPaint(painter: _GridPainter()),
              ),
            ),
            Positioned(
              top: -100,
              left: -80,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryColor.withAlpha(25),
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 24),
                        Center(
                          child: Image.asset('assets/images/logo.png', height: 80),
                        ),
                        const SizedBox(height: 48),
                        Text(
                          'Masuk ke akun kamu',
                          style: GoogleFonts.outfit(
                            fontSize: 28, fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onSurface,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Pantau servis mouse kamu kapan saja.',
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            color: (Theme.of(context).brightness == Brightness.dark
                                ? AppTheme.textMuted : AppTheme.textMutedLight),
                          ),
                        ),
                        const SizedBox(height: 36),

                        // Email
                        _buildLabel('Alamat Email'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          style: GoogleFonts.outfit(color: Theme.of(context).colorScheme.onSurface, fontSize: 15),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Email tidak boleh kosong';
                            if (!v.contains('@')) return 'Format email tidak valid';
                            return null;
                          },
                          decoration: const InputDecoration(
                            hintText: 'nama@email.com',
                            prefixIcon: Icon(Icons.email_outlined, size: 20),
                            prefixIconConstraints: BoxConstraints(minWidth: 50),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Password
                        _buildLabel('Password'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passCtrl,
                          obscureText: !_showPass,
                          style: GoogleFonts.outfit(color: Theme.of(context).colorScheme.onSurface, fontSize: 15),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Password tidak boleh kosong';
                            if (v.length < 6) return 'Password minimal 6 karakter';
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: '••••••••',
                            prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                            prefixIconConstraints: const BoxConstraints(minWidth: 50),
                            suffixIcon: IconButton(
                              onPressed: () => setState(() => _showPass = !_showPass),
                              icon: Icon(
                                _showPass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                size: 20,
                                color: (Theme.of(context).brightness == Brightness.dark
                                    ? AppTheme.textMuted : AppTheme.textMutedLight),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => context.push('/forgot-password'),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Lupa password?',
                              style: GoogleFonts.outfit(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Login Button
                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _login,
                            child: _loading
                                ? const SizedBox(width: 20, height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : Text('Masuk',
                                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.2)),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Divider
                        Row(children: [
                          Expanded(child: Divider(color: Theme.of(context).dividerTheme.color!)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text('atau', style: GoogleFonts.outfit(
                              color: (Theme.of(context).brightness == Brightness.dark
                                  ? AppTheme.textMuted : AppTheme.textMutedLight),
                              fontSize: 13)),
                          ),
                          Expanded(child: Divider(color: Theme.of(context).dividerTheme.color!)),
                        ]),
                        const SizedBox(height: 20),

                        // Google Sign-In Button
                        SizedBox(
                          height: 50,
                          child: OutlinedButton.icon(
                            onPressed: _loading ? null : _signInWithGoogle,
                            icon: Image.network(
                              'https://www.google.com/favicon.ico',
                              height: 20, width: 20,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.g_mobiledata, size: 24),
                            ),
                            label: Text(
                              'Masuk dengan Google',
                              style: GoogleFonts.outfit(
                                fontSize: 15, fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white24 : Colors.black26,
                              ),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Register
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Belum punya akun? ',
                              style: GoogleFonts.outfit(
                                color: (Theme.of(context).brightness == Brightness.dark
                                    ? AppTheme.textMuted : AppTheme.textMutedLight),
                                fontSize: 14),
                            ),
                            GestureDetector(
                              onTap: () => context.push('/register'),
                              child: Text(
                                'Daftar sekarang',
                                style: GoogleFonts.outfit(
                                  color: AppTheme.primaryColor,
                                  fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.outfit(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 13, fontWeight: FontWeight.w500),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white..strokeWidth = 1;
    const spacing = 32.0;
    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }
  @override
  bool shouldRepaint(_GridPainter old) => false;
}
