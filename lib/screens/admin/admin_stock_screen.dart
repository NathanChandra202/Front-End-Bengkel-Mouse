import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../theme.dart';
import '../../providers/admin_provider.dart';

class AdminStockScreen extends StatelessWidget {
  const AdminStockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final adminProv = Provider.of<AdminProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manajemen Stock',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: adminProv.stocks.length,
        itemBuilder: (context, index) {
          final stock = adminProv.stocks[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Text(
                stock.name,
                style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              subtitle: Text(
                'Kategori: ${stock.category} • Harga: Rp${stock.price.toInt()}',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppTheme.textMuted
                      : AppTheme.textMutedLight,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withAlpha(20),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Qty: ${stock.quantity}',
                      style: GoogleFonts.outfit(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    onPressed: () => _showStockDialog(context, stock: stock),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                    onPressed: () => adminProv.deleteStock(stock.id),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showStockDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showStockDialog(BuildContext context, {StockItem? stock}) {
    final isEdit = stock != null;
    final nameCtrl = TextEditingController(text: stock?.name ?? '');
    final catCtrl = TextEditingController(text: stock?.category ?? '');
    final qtyCtrl = TextEditingController(text: stock?.quantity.toString() ?? '');
    final priceCtrl = TextEditingController(text: stock?.price.toString() ?? '');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(isEdit ? 'Edit Stock' : 'Tambah Stock', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama Barang')),
                const SizedBox(height: 12),
                TextField(controller: catCtrl, decoration: const InputDecoration(labelText: 'Kategori')),
                const SizedBox(height: 12),
                TextField(controller: qtyCtrl, decoration: const InputDecoration(labelText: 'Quantity'), keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'Harga'), keyboardType: TextInputType.number),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
              ElevatedButton(
                onPressed: () async {
                  final qty = int.tryParse(qtyCtrl.text) ?? 0;
                  final price = double.tryParse(priceCtrl.text) ?? 0.0;
                  final adminProv = Provider.of<AdminProvider>(context, listen: false);

                  try {
                    if (isEdit) {
                      await adminProv.updateStock(
                        stock.id,
                        nameCtrl.text,
                        catCtrl.text,
                        qty,
                        price,
                      );
                    } else {
                      await adminProv.addStock(
                        nameCtrl.text,
                        catCtrl.text,
                        qty,
                        price,
                      );
                    }
                    if (context.mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Berhasil menyimpan data stock!')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Gagal menyimpan data ke database.')),
                      );
                    }
                  }
                },
                child: const Text('Simpan'),
              )
          ],
        );
      },
    );
  }
}
