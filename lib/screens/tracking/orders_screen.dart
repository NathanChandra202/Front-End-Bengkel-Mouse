import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme.dart';
import '../../services/api_service.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<dynamic> _orders = [];
  Timer? _refreshTimer;

  static const _activeStatuses = {
    'PENDING', 'CHECKING', 'WAITING_DP', 'DP_REVIEW', 'IN_PROGRESS', 'TESTING',
    'WAITING_SETTLEMENT', 'SETTLEMENT_REVIEW',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchOrders();
    // Auto-refresh setiap 15 detik
    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (_) => _silentRefresh());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _silentRefresh() async {
    try {
      final data = await ApiService.getUserBookings();
      if (mounted) setState(() => _orders = data);
    } catch (_) {}
  }

  Future<void> _fetchOrders() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getUserBookings();
      if (mounted) {
        setState(() {
          _orders = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat pesanan: ${e.toString().replaceFirst('Exception: ', '')}')),
        );
      }
    }
  }

  List<dynamic> get _activeOrders =>
      _orders.where((o) => _activeStatuses.contains(o['status'])).toList();

  List<dynamic> get _completedOrders =>
      _orders.where((o) => o['status'] == 'COMPLETED' || o['status'] == 'CANCELLED').toList();

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Pesanan Saya', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: Theme.of(context).colorScheme.onSurface),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
          ),

          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppTheme.primaryColor,
            indicatorWeight: 2,
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: (Theme.of(context).brightness == Brightness.dark ? AppTheme.textMuted : AppTheme.textMutedLight),
            labelStyle: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600),
            unselectedLabelStyle: GoogleFonts.outfit(fontSize: 13),
            dividerColor: Theme.of(context).dividerTheme.color!,
            tabs: const [
              Tab(text: 'Aktif'),
              Tab(text: 'Selesai'),
              Tab(text: 'Semua'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildOrderList(_activeOrders),
                  _buildOrderList(_completedOrders),
                  _buildOrderList(_orders),
                ],
              ),
      ),
    );
  }

  Widget _buildOrderList(List<dynamic> orders) {
    if (orders.isEmpty) {
      return RefreshIndicator(
        onRefresh: _fetchOrders,
        color: AppTheme.primaryColor,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.35),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inbox_outlined, size: 56, color: (Theme.of(context).brightness == Brightness.dark ? AppTheme.textMuted : AppTheme.textMutedLight).withAlpha(100)),
                  const SizedBox(height: 12),
                  Text('Belum ada pesanan', style: GoogleFonts.outfit(color: (Theme.of(context).brightness == Brightness.dark ? AppTheme.textMuted : AppTheme.textMutedLight), fontSize: 15)),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _fetchOrders,
      color: AppTheme.primaryColor,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        itemCount: orders.length,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (ctx, i) => _buildOrderCard(ctx, orders[i]),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext ctx, Map<String, dynamic> order) {
    final id = order['id'] ?? '';
    final shortId = id.length > 8 ? 'BM-${id.substring(0, 8).toUpperCase()}' : 'BM-$id';
    final mouseName = order['mouseName'] ?? '-';
    final issue = order['issue'] ?? '-';
    final status = order['status'] ?? 'PENDING';
    final statusLabel = _statusLabel(status);
    final statusColor = _statusColor(status);
    final dateRaw = order['createdAt'];
    String dateStr = '-';
    if (dateRaw != null) {
      try {
        final dt = DateTime.parse(dateRaw).toLocal();
        dateStr = '${dt.day} ${_monthName(dt.month)} ${dt.year}';
      } catch (_) {}
    }

    return GestureDetector(
      onTap: () => ctx.push('/tracking/$id'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: (status == 'WAITING_DP' || status == 'WAITING_SETTLEMENT')
                ? AppTheme.primaryColor.withAlpha(120)
                : Theme.of(context).dividerTheme.color!,
            width: (status == 'WAITING_DP' || status == 'WAITING_SETTLEMENT') ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  shortId,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: (Theme.of(context).brightness == Brightness.dark ? AppTheme.textMuted : AppTheme.textMutedLight),
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                _statusBadge(statusLabel, statusColor),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: AppTheme.primaryColor.withAlpha(50)),
                  ),
                  child: const Icon(Icons.mouse_outlined, size: 20, color: AppTheme.primaryColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mouseName,
                        style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface),
                      ),
                      Text(
                        issue,
                        style: GoogleFonts.outfit(fontSize: 12, color: (Theme.of(context).brightness == Brightness.dark ? AppTheme.textMuted : AppTheme.textMutedLight)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(height: 1, color: Theme.of(context).dividerTheme.color!),
            const SizedBox(height: 12),
            // Bottom row — action jika perlu bayar, atau lihat detail
            if (status == 'WAITING_DP' || status == 'WAITING_SETTLEMENT')
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 12, color: (Theme.of(context).brightness == Brightness.dark ? AppTheme.textMuted : AppTheme.textMutedLight)),
                  const SizedBox(width: 5),
                  Text(dateStr, style: GoogleFonts.outfit(fontSize: 12, color: (Theme.of(context).brightness == Brightness.dark ? AppTheme.textMuted : AppTheme.textMutedLight))),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => ctx.push('/payment/$id'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status == 'WAITING_SETTLEMENT' ? 'Lunasi →' : 'Bayar DP →',
                        style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 12, color: (Theme.of(context).brightness == Brightness.dark ? AppTheme.textMuted : AppTheme.textMutedLight)),
                  const SizedBox(width: 5),
                  Text(dateStr, style: GoogleFonts.outfit(fontSize: 12, color: (Theme.of(context).brightness == Brightness.dark ? AppTheme.textMuted : AppTheme.textMutedLight))),
                  const Spacer(),
                  Text(
                    'Lihat Detail →',
                    style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primaryColor),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(35),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Text(
        label,
        style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'PENDING': return 'Menunggu Paket';
      case 'CHECKING': return 'Pengecekan';
      case 'WAITING_DP': return 'Menunggu DP';
      case 'DP_REVIEW': return 'Review DP';
      case 'IN_PROGRESS': return 'Sedang Diperbaiki';
      case 'TESTING': return 'Testing & QC';
      case 'WAITING_SETTLEMENT': return 'Menunggu Pelunasan';
      case 'SETTLEMENT_REVIEW': return 'Review Pelunasan';
      case 'COMPLETED': return 'Selesai';
      case 'CANCELLED': return 'Dibatalkan';
      default: return status.split('_').map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase()).join(' ');
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'PENDING': return AppTheme.statusWaiting;
      case 'CHECKING': return AppTheme.statusChecking;
      case 'WAITING_DP': return AppTheme.statusPayment;
      case 'DP_REVIEW': return AppTheme.statusReview;
      case 'IN_PROGRESS': return AppTheme.statusRepairing;
      case 'TESTING': return AppTheme.statusQC;
      case 'WAITING_SETTLEMENT': return AppTheme.statusPayment;
      case 'SETTLEMENT_REVIEW': return AppTheme.statusReview;
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
