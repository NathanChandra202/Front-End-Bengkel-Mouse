import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../theme.dart';
import '../../services/api_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isLoading = true;
  List<dynamic> _bookings = [];

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    try {
      final data = await ApiService.getUserBookings();
      if (mounted) {
        setState(() {
          _bookings = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getNotifMessage(String status) {
    switch (status) {
      case 'PENDING': return 'Pesanan kamu telah diterima dan menunggu konfirmasi admin.';
      case 'CHECKING': return 'Admin sedang mengecek kondisi mouse kamu.';
      case 'WAITING_PAYMENT': return 'Estimasi biaya sudah ditetapkan. Silakan lakukan pembayaran.';
      case 'PAYMENT_REVIEW': return 'Bukti pembayaran sedang diverifikasi oleh admin.';
      case 'IN_PROGRESS': return 'Mouse kamu sedang dalam proses perbaikan.';
      case 'TESTING': return 'Perbaikan selesai, sedang dilakukan pengujian akhir.';
      case 'COMPLETED': return 'Perbaikan selesai! Mouse siap untuk diambil/dikirim.';
      case 'CANCELLED': return 'Pesanan telah dibatalkan.';
      default: return 'Status pesanan diperbarui.';
    }
  }

  IconData _getNotifIcon(String status) {
    switch (status) {
      case 'PENDING': return Icons.hourglass_empty_rounded;
      case 'CHECKING': return Icons.search_rounded;
      case 'WAITING_PAYMENT': return Icons.payment_rounded;
      case 'PAYMENT_REVIEW': return Icons.receipt_long_rounded;
      case 'IN_PROGRESS': return Icons.build_rounded;
      case 'TESTING': return Icons.verified_rounded;
      case 'COMPLETED': return Icons.check_circle_rounded;
      case 'CANCELLED': return Icons.cancel_rounded;
      default: return Icons.notifications_rounded;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
      case 'CHECKING':
        return Colors.orange;
      case 'WAITING_PAYMENT':
        return Colors.amber.shade700;
      case 'PAYMENT_REVIEW':
        return Colors.blue.shade300;
      case 'IN_PROGRESS':
      case 'TESTING':
        return Colors.blue;
      case 'COMPLETED':
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
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
            'Notifikasi',
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: Theme.of(context).colorScheme.onSurface),
            onPressed: () => context.pop(),
          ),
          actions: [
            TextButton(
              onPressed: _fetchBookings,
              child: Text('Refresh', style: GoogleFonts.outfit(color: AppTheme.primaryColor, fontWeight: FontWeight.w600, fontSize: 13)),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: Theme.of(context).dividerTheme.color!),
          ),
        ),
        body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bookings.isEmpty
            ? _buildEmpty(isDark)
            : RefreshIndicator(
                onRefresh: _fetchBookings,
                color: AppTheme.primaryColor,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: _bookings.length,
                  separatorBuilder: (_, __) => Divider(height: 1, color: Theme.of(context).dividerTheme.color),
                  itemBuilder: (context, index) {
                    final booking = _bookings[index];
                    final status = booking['status'] ?? 'PENDING';
                    final color = _getStatusColor(status);
                    final icon = _getNotifIcon(status);
                    final message = _getNotifMessage(status);
                    final mouseName = booking['mouseName'] ?? '-';
                    final dateStr = booking['updatedAt'] != null
                        ? DateFormat('dd MMM yyyy, HH:mm').format(DateTime.parse(booking['updatedAt']))
                        : '-';

                    return InkWell(
                      onTap: () => context.push('/tracking/${booking['id']}'),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: color.withAlpha(20),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(icon, color: color, size: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          mouseName,
                                          style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: color.withAlpha(20),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(status, style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    message,
                                    style: GoogleFonts.outfit(fontSize: 13, color: isDark ? AppTheme.textMuted : AppTheme.textMutedLight, height: 1.4),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    dateStr,
                                    style: GoogleFonts.outfit(fontSize: 11, color: isDark ? AppTheme.textMuted : AppTheme.textMutedLight),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.chevron_right_rounded, color: isDark ? AppTheme.textMuted : AppTheme.textMutedLight, size: 20),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }

  Widget _buildEmpty(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none_rounded, size: 72, color: isDark ? AppTheme.textMuted : AppTheme.textMutedLight),
          const SizedBox(height: 16),
          Text(
            'Belum ada notifikasi',
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            'Notifikasi terkait pesanan kamu\nakan muncul di sini.',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(fontSize: 14, color: isDark ? AppTheme.textMuted : AppTheme.textMutedLight, height: 1.5),
          ),
        ],
      ),
    );
  }
}
