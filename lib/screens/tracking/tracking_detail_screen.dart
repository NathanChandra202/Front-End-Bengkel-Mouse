import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme.dart';
import '../../services/api_service.dart';

class TrackingDetailScreen extends StatefulWidget {
  final String bookingId;
  const TrackingDetailScreen({super.key, required this.bookingId});

  @override
  State<TrackingDetailScreen> createState() => _TrackingDetailScreenState();
}

class _TrackingDetailScreenState extends State<TrackingDetailScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _booking;
  Timer? _refreshTimer;
  Map<String, dynamic>? _existingReview;
  bool _reviewLoading = true;

  static const _statusToStep = {
    'PENDING':         0,
    'CHECKING':        1,
    'WAITING_PAYMENT': 2,
    'PAYMENT_REVIEW':  3,
    'IN_PROGRESS':     4,
    'TESTING':         5,
    'COMPLETED':       6,
    'CANCELLED':       0,
  };

  @override
  void initState() {
    super.initState();
    _fetchBooking();
    // Auto-refresh setiap 10 detik
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) => _silentRefresh());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _silentRefresh() async {
    try {
      final data = await ApiService.getBookingById(widget.bookingId);
      if (mounted) setState(() => _booking = data);
    } catch (_) {}
  }

  Future<void> _fetchBooking() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getBookingById(widget.bookingId);
      if (mounted) setState(() { _booking = data; _isLoading = false; });
      // Fetch review if COMPLETED
      if (data['status'] == 'COMPLETED') {
        _fetchReview();
      } else {
        if (mounted) setState(() => _reviewLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() { _isLoading = false; _reviewLoading = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data: ${e.toString().replaceFirst('Exception: ', '')}')),
        );
      }
    }
  }

  Future<void> _fetchReview() async {
    try {
      final review = await ApiService.getReview(widget.bookingId);
      if (mounted) setState(() { _existingReview = review; _reviewLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _reviewLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.bookingId, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600)),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: Theme.of(context).colorScheme.onSurface),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_booking == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.bookingId, style: GoogleFonts.outfit(fontSize: 16)),
          leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.of(context).pop()),
        ),
        body: const Center(child: Text('Data booking tidak ditemukan')),
      );
    }

    final status = _booking!['status'] as String? ?? 'PENDING';
    final currentStep = _statusToStep[status] ?? 0;

    final steps = [
      _TrackStep('Menunggu Paket', 'Booking dibuat. Kirimkan mouse kamu ke bengkel kami.', AppTheme.statusWaiting, Icons.local_shipping_outlined),
      _TrackStep('Pengecekan', 'Mouse diterima dan sedang dicek oleh teknisi.', AppTheme.statusChecking, Icons.search_outlined),
      _TrackStep('Menunggu Pembayaran', 'Estimasi biaya sudah dikirim. Mohon lakukan transfer.', AppTheme.statusPayment, Icons.payment_outlined),
      _TrackStep('Review Pembayaran', 'Bukti transfer sedang diverifikasi admin.', AppTheme.statusReview, Icons.verified_outlined),
      _TrackStep('Sedang Diperbaiki', 'Teknisi sedang mengerjakan mouse kamu.', AppTheme.statusRepairing, Icons.build_outlined),
      _TrackStep('Testing & QC', 'Mouse sedang diuji sebelum dikirim balik.', AppTheme.statusQC, Icons.science_outlined),
      _TrackStep('Selesai', 'Mouse sudah beres dan dikirim kembali ke kamu.', AppTheme.statusDone, Icons.check_circle_outline_rounded),
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.bookingId,
            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface, letterSpacing: 0.3),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: Theme.of(context).colorScheme.onSurface),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh_rounded, color: Theme.of(context).brightness == Brightness.dark ? AppTheme.textMuted : AppTheme.textMutedLight),
              onPressed: _fetchBooking,
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: Theme.of(context).dividerTheme.color!),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: _fetchBooking,
          color: AppTheme.primaryColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildMouseCard(context, _booking!, status),
                if (status == 'WAITING_PAYMENT') _buildPaymentBanner(context),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                  child: Text(
                    'Riwayat Status',
                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface),
                  ),
                ),
                _buildTimeline(context, steps, currentStep),
                if (status == 'COMPLETED')
                  _buildReviewSection(context),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMouseCard(BuildContext context, Map<String, dynamic> booking, String status) {
    final mouseName = booking['mouseName'] ?? '-';
    final issue = booking['issue'] ?? '-';
    final statusLabel = _statusLabel(status);
    final statusColor = _statusColorFromStatus(status);
    final dateRaw = booking['createdAt'];
    String dateStr = '-';
    if (dateRaw != null) {
      try {
        final dt = DateTime.parse(dateRaw).toLocal();
        dateStr = '${dt.day} ${_monthName(dt.month)} ${dt.year}';
      } catch (_) {}
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerTheme.color!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primaryColor.withAlpha(60)),
                ),
                child: const Icon(Icons.mouse_outlined, color: AppTheme.primaryColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mouseName,
                      style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface),
                    ),
                    Text(
                      issue,
                      style: GoogleFonts.outfit(fontSize: 13, color: (Theme.of(context).brightness == Brightness.dark ? AppTheme.textMuted : AppTheme.textMutedLight)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: Theme.of(context).dividerTheme.color!),
          const SizedBox(height: 14),
          _buildInfoRow(context, 'Status Saat Ini', statusLabel, statusColor),
          const SizedBox(height: 8),
          _buildInfoRow(context, 'Tanggal Booking', dateStr, (Theme.of(context).brightness == Brightness.dark ? AppTheme.textMuted : AppTheme.textMutedLight)),
          const SizedBox(height: 8),
          _buildInfoRow(context, 'Estimasi Selesai', '1–3 Hari Kerja', (Theme.of(context).brightness == Brightness.dark ? AppTheme.textMuted : AppTheme.textMutedLight)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.outfit(fontSize: 13, color: (Theme.of(context).brightness == Brightness.dark ? AppTheme.textMuted : AppTheme.textMutedLight))),
        Text(
          value,
          style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: valueColor),
        ),
      ],
    );
  }

  Widget _buildPaymentBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryDark, AppTheme.primaryColor.withAlpha(200)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.payment_rounded, color: Colors.white, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tagihan Menunggu Pembayaran',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 14),
                ),
                Text(
                  'Transfer sesuai nominal + kode unik.',
                  style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => context.push('/payment/${widget.bookingId}'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(40),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withAlpha(80)),
              ),
              child: Text(
                'Bayar →',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(BuildContext context, List<_TrackStep> steps, int currentStep) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: List.generate(steps.length, (i) {
          final isDone    = i < currentStep;
          final isCurrent = i == currentStep;
          final isPending = i > currentStep;
          final step      = steps[i];
          final color     = isDone || isCurrent ? step.color : (Theme.of(context).brightness == Brightness.dark ? AppTheme.textMuted : AppTheme.textMutedLight).withAlpha(80);

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isPending ? Theme.of(context).colorScheme.surface : color.withAlpha(30),
                      shape: BoxShape.circle,
                      border: Border.all(color: isPending ? Theme.of(context).dividerTheme.color! : color, width: 1.5),
                    ),
                    child: Center(
                      child: isDone
                          ? Icon(Icons.check_rounded, size: 18, color: color)
                          : Icon(step.icon, size: 18, color: isPending ? (Theme.of(context).brightness == Brightness.dark ? AppTheme.textMuted : AppTheme.textMutedLight).withAlpha(100) : color),
                    ),
                  ),
                  if (i < steps.length - 1)
                    Container(
                      width: 2,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: isDone
                              ? [color.withAlpha(120), color.withAlpha(40)]
                              : [Theme.of(context).dividerTheme.color!, Theme.of(context).dividerTheme.color!],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 6, bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.label,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                          color: isPending ? (Theme.of(context).brightness == Brightness.dark ? AppTheme.textMuted : AppTheme.textMutedLight).withAlpha(120) : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        step.note,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: isPending ? (Theme.of(context).brightness == Brightness.dark ? AppTheme.textMuted : AppTheme.textMutedLight).withAlpha(100) : (Theme.of(context).brightness == Brightness.dark ? AppTheme.textMuted : AppTheme.textMutedLight),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildReviewSection(BuildContext context) {
    if (_reviewLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
      );
    }

    if (_existingReview != null) {
      final rating = (_existingReview!['rating'] as num?)?.toInt() ?? 0;
      final comment = _existingReview!['comment'] as String? ?? '';
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.statusDone.withAlpha(80)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.star_rounded, color: AppTheme.statusDone, size: 18),
                const SizedBox(width: 6),
                Text('Ulasan Kamu', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: List.generate(5, (i) => Icon(
                i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                color: const Color(0xFFFFC107),
                size: 22,
              )),
            ),
            if (comment.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                comment,
                style: GoogleFonts.outfit(fontSize: 13, color: (Theme.of(context).brightness == Brightness.dark ? AppTheme.textMuted : AppTheme.textMutedLight), height: 1.5),
              ),
            ],
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: OutlinedButton.icon(
          onPressed: () => _showReviewSheet(context),
          icon: const Icon(Icons.star_outline_rounded, size: 20),
          label: Text('Berikan Ulasan', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600)),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.primaryColor,
            side: BorderSide(color: AppTheme.primaryColor.withAlpha(120)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }

  void _showReviewSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ReviewSheet(
        bookingId: widget.bookingId,
        onSubmitted: (review) {
          Navigator.of(ctx).pop();
          setState(() => _existingReview = review);
        },
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'PENDING': return 'Menunggu Paket';
      case 'CHECKING': return 'Pengecekan';
      case 'WAITING_PAYMENT': return 'Menunggu Pembayaran';
      case 'PAYMENT_REVIEW': return 'Review Pembayaran';
      case 'IN_PROGRESS': return 'Sedang Diperbaiki';
      case 'TESTING': return 'Testing & QC';
      case 'COMPLETED': return 'Selesai';
      case 'CANCELLED': return 'Dibatalkan';
      default: return status.split('_').map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase()).join(' ');
    }
  }

  Color _statusColorFromStatus(String status) {
    switch (status) {
      case 'PENDING': return AppTheme.statusWaiting;
      case 'CHECKING': return AppTheme.statusChecking;
      case 'WAITING_PAYMENT': return AppTheme.statusPayment;
      case 'PAYMENT_REVIEW': return AppTheme.statusReview;
      case 'IN_PROGRESS': return AppTheme.statusRepairing;
      case 'TESTING': return AppTheme.statusQC;
      case 'COMPLETED': return AppTheme.statusDone;
      case 'CANCELLED': return Colors.red;
      default: return Colors.grey;
    }
  }

  String _monthName(int m) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return months[m - 1];
  }
}

class _TrackStep {
  final String label, note;
  final Color color;
  final IconData icon;
  _TrackStep(this.label, this.note, this.color, this.icon);
}

class _ReviewSheet extends StatefulWidget {
  final String bookingId;
  final void Function(Map<String, dynamic> review) onSubmitted;

  const _ReviewSheet({required this.bookingId, required this.onSubmitted});

  @override
  State<_ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends State<_ReviewSheet> {
  int _rating = 0;
  final _commentCtrl = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating == 0) {
      setState(() => _error = 'Pilih rating bintang terlebih dahulu.');
      return;
    }
    setState(() { _submitting = true; _error = null; });
    try {
      final review = await ApiService.createReview(widget.bookingId, _rating, _commentCtrl.text.trim());
      if (mounted) widget.onSubmitted(review);
    } catch (e) {
      if (mounted) setState(() { _submitting = false; _error = e.toString().replaceFirst('Exception: ', ''); });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = isDark ? AppTheme.textMuted : AppTheme.textMutedLight;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).padding.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: mutedColor.withAlpha(60), borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Text('Berikan Ulasan', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 4),
            Text('Bagaimana pengalaman servis kamu?', style: GoogleFonts.outfit(fontSize: 13, color: mutedColor)),
            const SizedBox(height: 20),
            // Star rating
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (i) {
                  final star = i + 1;
                  return GestureDetector(
                    onTap: () => setState(() => _rating = star),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        star <= _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: const Color(0xFFFFC107),
                        size: 40,
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 20),
            Text('Komentar (Opsional)', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _commentCtrl,
              maxLines: 4,
              style: GoogleFonts.outfit(color: Theme.of(context).colorScheme.onSurface, fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Ceritakan pengalaman servis kamu...',
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(_error!, style: GoogleFonts.outfit(fontSize: 12, color: Colors.red)),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text('Kirim Ulasan', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
