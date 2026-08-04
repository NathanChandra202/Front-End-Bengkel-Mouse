import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme.dart';
import '../../services/api_service.dart';

class PaymentInstructionScreen extends StatefulWidget {
  final String bookingId;
  const PaymentInstructionScreen({super.key, required this.bookingId});

  @override
  State<PaymentInstructionScreen> createState() => _PaymentInstructionScreenState();
}

class _PaymentInstructionScreenState extends State<PaymentInstructionScreen> {
  bool _isLoadingBooking = true;
  bool _submitting = false;

  File? _proofFile;
  final ImagePicker _picker = ImagePicker();

  int _baseAmount = 0;
  int _uniqueCode = 0;
  int get _totalAmount => _baseAmount + _uniqueCode;

  final _banks = const [
    _BankInfo('BCA', '1234567890', 'PT Bengkel Mouse Dua Enam'),
    _BankInfo('BRI', '0987654321', 'PT Bengkel Mouse Dua Enam'),
  ];

  @override
  void initState() {
    super.initState();
    _fetchBooking();
  }

  Future<void> _fetchBooking() async {
    setState(() => _isLoadingBooking = true);
    try {
      final data = await ApiService.getBookingById(widget.bookingId);
      if (mounted) {
        final rawAmount = data['totalAmount'];
        final rawUnique = data['uniqueCode'];
        setState(() {
          _baseAmount = rawAmount != null ? (rawAmount as num).toInt() : 0;
          _uniqueCode = rawUnique != null ? (rawUnique as num).toInt() : 0;
          _isLoadingBooking = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingBooking = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat tagihan: ${e.toString().replaceFirst('Exception: ', '')}')),
        );
      }
    }
  }

  Future<void> _pickProof() async {
    final xfile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (xfile != null) setState(() => _proofFile = File(xfile.path));
  }

  Future<void> _submit() async {
    if (_proofFile == null) return;
    setState(() => _submitting = true);
    try {
      await ApiService.uploadPaymentProof(widget.bookingId, _proofFile!);
      if (mounted) {
        setState(() => _submitting = false);
        _showSuccessSheet();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal upload bukti: ${e.toString().replaceFirst('Exception: ', '')}')),
        );
      }
    }
  }

  void _showSuccessSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(28, 24, 28, 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppTheme.statusDone.withAlpha(30),
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.statusDone.withAlpha(80)),
              ),
              child: const Icon(Icons.check_rounded, color: AppTheme.statusDone, size: 36),
            ),
            const SizedBox(height: 20),
            Text(
              'Bukti Transfer Terkirim!',
              style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface),
            ),
            const SizedBox(height: 8),
            Text(
              'Admin kami akan memverifikasi pembayaran kamu.\nNotifikasi akan dikirim setelah disetujui.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(fontSize: 14, color: (Theme.of(context).brightness == Brightness.dark ? AppTheme.textMuted : AppTheme.textMutedLight), height: 1.6),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.go('/home');
                },
                child: Text('Kembali ke Beranda', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Instruksi Pembayaran',
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: Theme.of(context).colorScheme.onSurface),
            onPressed: () => Navigator.of(context).pop(),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: Theme.of(context).dividerTheme.color!),
          ),
        ),
        body: _isLoadingBooking
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildBillCard(),
                    const SizedBox(height: 20),

                    // Warning info
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.statusChecking.withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.statusChecking.withAlpha(80)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline_rounded, color: AppTheme.statusChecking, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Transfer tepat Rp ${_formatRp(_totalAmount)} termasuk kode unik .$_uniqueCode di akhir. Ini membantu admin memverifikasi pembayaran kamu dengan cepat.',
                              style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.statusChecking, height: 1.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Rincian
                    Text(
                      'Rincian Tagihan',
                      style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Theme.of(context).dividerTheme.color!),
                      ),
                      child: Column(
                        children: [
                          _billRow('Jasa Perbaikan', 'Rp ${_formatRp(_baseAmount)}'),
                          const SizedBox(height: 12),
                          Container(height: 1, color: Theme.of(context).dividerTheme.color!),
                          const SizedBox(height: 12),
                          _billRow('Subtotal', 'Rp ${_formatRp(_baseAmount)}'),
                          const SizedBox(height: 6),
                          _billRow('Kode Unik', '+Rp $_uniqueCode', highlight: true),
                          const SizedBox(height: 12),
                          Container(height: 1, color: Theme.of(context).dividerTheme.color!),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('TOTAL BAYAR', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface)),
                              Text(
                                'Rp ${_formatRp(_totalAmount)}',
                                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.primaryColor),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Bank accounts
                    Text(
                      'Rekening Tujuan',
                      style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface),
                    ),
                    const SizedBox(height: 12),
                    ..._banks.map((b) => _buildBankCard(b)),

                    const SizedBox(height: 24),

                    // Upload proof
                    Text(
                      'Upload Bukti Transfer',
                      style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Upload foto struk transfer sebagai bukti pembayaran.',
                      style: GoogleFonts.outfit(fontSize: 13, color: (Theme.of(context).brightness == Brightness.dark ? AppTheme.textMuted : AppTheme.textMutedLight)),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _pickProof,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 120,
                        decoration: BoxDecoration(
                          color: _proofFile != null
                              ? AppTheme.statusDone.withAlpha(20)
                              : Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _proofFile != null ? AppTheme.statusDone.withAlpha(120) : Theme.of(context).dividerTheme.color!,
                            width: _proofFile != null ? 1.5 : 1,
                          ),
                        ),
                        child: _proofFile != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.file(_proofFile!, fit: BoxFit.cover),
                                    Positioned(
                                      top: 8, right: 8,
                                      child: GestureDetector(
                                        onTap: () => setState(() => _proofFile = null),
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                          child: const Icon(Icons.close, color: Colors.white, size: 16),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.upload_file_outlined,
                                    size: 36,
                                    color: (Theme.of(context).brightness == Brightness.dark ? AppTheme.textMuted : AppTheme.textMutedLight),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tap untuk pilih foto struk',
                                    style: GoogleFonts.outfit(
                                      fontSize: 13,
                                      color: (Theme.of(context).brightness == Brightness.dark ? AppTheme.textMuted : AppTheme.textMutedLight),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            border: Border(top: BorderSide(color: Theme.of(context).dividerTheme.color!)),
          ),
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _proofFile != null && !_submitting && !_isLoadingBooking ? _submit : null,
              style: ElevatedButton.styleFrom(
                disabledBackgroundColor: (Theme.of(context).brightness == Brightness.dark ? AppTheme.surfaceHighColor : AppTheme.surfaceHighColorLight),
                disabledForegroundColor: (Theme.of(context).brightness == Brightness.dark ? AppTheme.textMuted : AppTheme.textMutedLight),
              ),
              child: _submitting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(
                      _proofFile != null ? 'Kirim Bukti Transfer' : 'Upload Bukti Dulu',
                      style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBillCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryDark, AppTheme.primaryColor.withAlpha(180)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(40),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.bookingId,
                  style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white70),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Total Pembayaran',
            style: GoogleFonts.outfit(fontSize: 13, color: Colors.white70),
          ),
          const SizedBox(height: 6),
          Text(
            _baseAmount == 0 ? 'Belum Diset' : 'Rp ${_formatRp(_totalAmount)}',
            style: GoogleFonts.outfit(
              fontSize: 38,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Termasuk kode unik: .$_uniqueCode',
            style: GoogleFonts.outfit(fontSize: 13, color: Colors.white60),
          ),
        ],
      ),
    );
  }

  Widget _buildBankCard(_BankInfo bank) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerTheme.color!),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: (Theme.of(context).brightness == Brightness.dark ? AppTheme.surfaceHighColor : AppTheme.surfaceHighColorLight),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                bank.name,
                style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(bank.accountNumber, style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface, letterSpacing: 1.2)),
                Text('a.n. ${bank.accountName}', style: GoogleFonts.outfit(fontSize: 12, color: (Theme.of(context).brightness == Brightness.dark ? AppTheme.textMuted : AppTheme.textMutedLight))),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: bank.accountNumber));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Nomor rekening disalin!', style: GoogleFonts.outfit())),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.primaryColor.withAlpha(80)),
              ),
              child: Text(
                'Salin',
                style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primaryColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _billRow(String label, String value, {bool highlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.outfit(fontSize: 13, color: (Theme.of(context).brightness == Brightness.dark ? AppTheme.textMuted : AppTheme.textMutedLight))),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 13,
            fontWeight: highlight ? FontWeight.w600 : FontWeight.w500,
            color: highlight ? AppTheme.primaryColor : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  String _formatRp(int amount) {
    final s = amount.toString();
    final result = StringBuffer();
    int count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      result.write(s[i]);
      count++;
      if (count % 3 == 0 && i != 0) result.write('.');
    }
    return result.toString().split('').reversed.join();
  }
}

class _BankInfo {
  final String name, accountNumber, accountName;
  const _BankInfo(this.name, this.accountNumber, this.accountName);
}
