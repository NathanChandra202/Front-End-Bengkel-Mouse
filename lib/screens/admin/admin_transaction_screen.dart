import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../theme.dart';
import '../../services/api_service.dart';

class AdminTransactionScreen extends StatefulWidget {
  const AdminTransactionScreen({super.key});

  @override
  State<AdminTransactionScreen> createState() => _AdminTransactionScreenState();
}

class _AdminTransactionScreenState extends State<AdminTransactionScreen> {
  bool _isLoading = true;
  List<dynamic> _transactions = [];

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    try {
      final data = await ApiService.getAllBookings();
      if (mounted) {
        setState(() {
          _transactions = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manajemen Transaksi',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _transactions.length,
            itemBuilder: (context, index) {
              final trx = _transactions[index];
              final dateStr = trx['createdAt'] != null ? DateFormat('dd MMM yyyy, HH:mm').format(DateTime.parse(trx['createdAt'])) : '-';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: InkWell(
                  onTap: () {
                    context.push('/admin/transactions/${trx['id']}').then((_) => _fetchTransactions());
                  },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withAlpha(20),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.receipt_outlined, color: AppTheme.primaryColor),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'BM-${trx['id']}'.substring(0, 11) + ' - ' + (trx['user']?['name'] ?? 'User'),
                            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dateStr,
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? AppTheme.textMuted
                                  : AppTheme.textMutedLight,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            trx['issue'] ?? '-',
                            style: GoogleFonts.outfit(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildStatusBadge(trx['status'] ?? 'PENDING'),
                  ],
                ),
              ),
            ),
            );
          },
        ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'PENDING':
      case 'CHECKING':
      case 'WAITING_PAYMENT':
        color = Colors.orange;
        break;
      case 'IN_PROGRESS':
      case 'TESTING':
        color = Colors.blue;
        break;
      case 'COMPLETED':
        color = Colors.green;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Text(
        status,
        style: GoogleFonts.outfit(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
