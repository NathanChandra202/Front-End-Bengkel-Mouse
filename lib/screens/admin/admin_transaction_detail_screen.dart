import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../theme.dart';
import '../../services/api_service.dart';

class AdminTransactionDetailScreen extends StatefulWidget {
  final String transactionId;
  const AdminTransactionDetailScreen({super.key, required this.transactionId});

  @override
  State<AdminTransactionDetailScreen> createState() => _AdminTransactionDetailScreenState();
}

class _AdminTransactionDetailScreenState extends State<AdminTransactionDetailScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _trx;

  @override
  void initState() {
    super.initState();
    _fetchBooking();
  }

  Future<void> _fetchBooking() async {
    try {
      final b = await ApiService.getBookingById(widget.transactionId);
      if (mounted) {
        setState(() {
          _trx = b;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(String status) async {
    try {
      await ApiService.updateBookingStatus(widget.transactionId, status);
      _fetchBooking();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _setAmountDialog() async {
    final ctrl = TextEditingController();
    final isTesting = _trx!['status'] == 'TESTING';
    final label = isTesting ? 'Pelunasan' : 'DP';
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Set Harga $label', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: 'Nominal $label (Rp)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(ctrl.text);
              if (amount != null) {
                Navigator.pop(ctx);
                try {
                  await ApiService.setBookingAmount(widget.transactionId, amount);
                  _fetchBooking();
                } catch (e) {
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            child: const Text('Kirim Tagihan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Transaksi')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_trx == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Transaksi')),
        body: const Center(child: Text('Transaksi tidak ditemukan')),
      );
    }

    final dateStr = _trx!['createdAt'] != null ? DateFormat('dd MMM yyyy, HH:mm').format(DateTime.parse(_trx!['createdAt'])) : '-';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detail Transaksi',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Theme.of(context).dividerTheme.color!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ID Transaksi',
                    style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.textMuted),
                  ),
                  Text(
                    'BM-${_trx!['id']}'.substring(0, 11),
                    style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Divider(height: 32),
                  _buildInfoRow('Pelanggan', _trx!['user']?['name'] ?? '-'),
                  const SizedBox(height: 12),
                  _buildInfoRow('Mouse', _trx!['mouseName'] ?? '-'),
                  const SizedBox(height: 12),
                  _buildInfoRow('Tanggal', dateStr),
                  const SizedBox(height: 12),
                  _buildInfoRow('Layanan', _trx!['issue'] ?? '-'),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total', style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.textMuted)),
                      Row(
                        children: [
                          Text(
                            _trx!['totalAmount'] != null ? 'Rp ${_formatRp((_trx!['totalAmount'] ?? 0).toInt() + (_trx!['uniqueCode'] ?? 0).toInt())}' : 'Belum Diset',
                            style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          if (_trx!['status'] == 'CHECKING' || _trx!['status'] == 'TESTING')
                            IconButton(
                              icon: const Icon(Icons.edit, size: 16),
                              onPressed: _setAmountDialog,
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Status Saat Ini',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          color: AppTheme.textMuted,
                        ),
                      ),
                      _buildStatusBadge(_trx!['status'] ?? 'PENDING'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            if (_trx!['paymentProofUrl'] != null) ...[
              Text(
                'Bukti Pembayaran',
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Container(
                height: 300,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Theme.of(context).dividerTheme.color!),
                  image: DecorationImage(
                    image: NetworkImage(ApiService.baseUrl.replaceFirst('/api', '') + _trx!['paymentProofUrl']),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
            
            // Update Status Section
            Text(
              'Update Status Pesanan',
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildNextStatusButton(_trx!['status'] ?? 'PENDING'),
          ],
        ),
      ),
    );
  }

  Widget _buildNextStatusButton(String currentStatus) {
    const nextStatus = {
      'PENDING':             'CHECKING',
      'CHECKING':            'WAITING_DP',
      'WAITING_DP':          'DP_REVIEW',
      'DP_REVIEW':           'IN_PROGRESS',
      'IN_PROGRESS':         'TESTING',
      'TESTING':             'WAITING_SETTLEMENT',
      'WAITING_SETTLEMENT':  'SETTLEMENT_REVIEW',
      'SETTLEMENT_REVIEW':   'COMPLETED',
    };
    const statusLabel = {
      'PENDING':             'Menunggu Paket',
      'CHECKING':            'Pengecekan',
      'WAITING_DP':          'Menunggu DP',
      'DP_REVIEW':           'Review DP',
      'IN_PROGRESS':         'Sedang Diperbaiki',
      'TESTING':             'Testing & QC',
      'WAITING_SETTLEMENT':  'Menunggu Pelunasan',
      'SETTLEMENT_REVIEW':   'Review Pelunasan',
      'COMPLETED':           'Selesai',
    };

    final next = nextStatus[currentStatus];

    if (currentStatus == 'COMPLETED') {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.withAlpha(20),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.withAlpha(80)),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.green),
            const SizedBox(width: 12),
            Text(
              'Pesanan sudah selesai',
              style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.green),
            ),
          ],
        ),
      );
    }

    // Block advance if waiting for customer payment proof
    if ((currentStatus == 'WAITING_DP' || currentStatus == 'WAITING_SETTLEMENT') && _trx!['paymentProofUrl'] == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.withAlpha(20),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.withAlpha(80)),
        ),
        child: Row(
          children: [
            const Icon(Icons.hourglass_empty_rounded, color: Colors.orange),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Menunggu pelanggan upload bukti transfer',
                style: GoogleFonts.outfit(fontSize: 14, color: Colors.orange),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Current status info
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerTheme.color!),
          ),
          child: Row(
            children: [
              const Icon(Icons.flag_rounded, size: 18, color: Colors.grey),
              const SizedBox(width: 10),
              Text('Status saat ini: ', style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.textMuted)),
              Text(statusLabel[currentStatus] ?? currentStatus,
                style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Next step button
        if (next != null)
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () => _confirmAndUpdate(next, statusLabel[next] ?? next),
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: Text(
                'Lanjut ke: ${statusLabel[next] ?? next}',
                style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _confirmAndUpdate(String nextStatus, String label) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Konfirmasi', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Text('Pindahkan status ke "$label"?', style: GoogleFonts.outfit()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Ya, Lanjut')),
        ],
      ),
    );
    if (confirm == true) _updateStatus(nextStatus);
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.textMuted),
        ),
        Text(
          value,
          style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600),
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

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'PENDING':
      case 'CHECKING':
        color = Colors.orange;
        break;
      case 'WAITING_DP':
      case 'DP_REVIEW':
        color = Colors.amber;
        break;
      case 'IN_PROGRESS':
      case 'TESTING':
        color = Colors.blue;
        break;
      case 'WAITING_SETTLEMENT':
      case 'SETTLEMENT_REVIEW':
        color = Colors.purple;
        break;
      case 'COMPLETED':
        color = Colors.green;
        break;
      case 'CANCELLED':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.split('_').map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase()).join(' '),
        style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

}

