import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme.dart';
import '../../services/api_service.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _brandCtrl   = TextEditingController();
  final _modelCtrl   = TextEditingController();
  final _detailsCtrl = TextEditingController();
  final List<String> _selectedCategories = [];
  XFile? _pickedMedia;
  final ImagePicker _picker = ImagePicker();
  bool _submitting = false;

  final _categories = const [
    'Double Clicking / Klik Ganda',
    'Scroll Wheel Bermasalah',
    'Sensor Loncat / Tidak Akurat',
    'Kabel Rusak / Paracord',
    'Deep Cleaning',
    'Mouse Wireless - Baterai',
    'Modifikasi Custom',
    'Lainnya',
  ];

  int _step = 0; // 0 = info mouse, 1 = detail, 2 = kirim

  @override
  void dispose() {
    _brandCtrl.dispose();
    _modelCtrl.dispose();
    _detailsCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final brand = _brandCtrl.text.trim();
    final model = _modelCtrl.text.trim();
    if (brand.isEmpty || model.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi brand dan model mouse terlebih dahulu.')),
      );
      return;
    }
    if (_selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih minimal satu kategori masalah.')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final booking = await ApiService.createBookingAndReturn({
        'mouseName': '$brand $model',
        'issue': _selectedCategories.join(', '),
        'details': _detailsCtrl.text.trim(),
        'categories': _selectedCategories,
      });
      if (mounted) {
        _showBookingSuccessSheet(booking);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showBookingSuccessSheet(Map<String, dynamic> booking) {
    final bookingId = booking['id'] ?? '';
    final shortId = bookingId.length > 8 ? 'BM-${bookingId.substring(0, 8).toUpperCase()}' : 'BM-$bookingId';
    final mouseName = booking['mouseName'] ?? '-';
    final issue = booking['issue'] ?? '-';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (ctx) => _BookingSuccessSheet(
        bookingId: shortId,
        rawBookingId: bookingId,
        mouseName: mouseName,
        issue: issue,
        onViewOrders: () {
          Navigator.of(ctx).pop();
          context.go('/orders');
        },
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
            'Booking Servis',
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
        body: Column(
          children: [
            _buildStepIndicator(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: _step == 0
                      ? _mouseInfoStep()
                      : _step == 1
                          ? _detailStep()
                          : _shipStep(),
                ),
              ),
            ),
            _buildNavButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    final steps = ['Info Mouse', 'Detail Keluhan', 'Cara Kirim'];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerTheme.color!)),
      ),
      child: Row(
        children: List.generate(steps.length, (i) {
          final done  = i < _step;
          final active = i == _step;
          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: done
                        ? AppTheme.primaryColor
                        : active
                            ? AppTheme.primaryColor.withAlpha(30)
                            : Theme.of(context).colorScheme.surface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: done || active ? AppTheme.primaryColor : Theme.of(context).dividerTheme.color!,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: done
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : Text(
                            '${i + 1}',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: active ? AppTheme.primaryColor : (Theme.of(context).brightness == Brightness.dark ? AppTheme.textMuted : AppTheme.textMutedLight),
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        steps[i],
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                          color: active ? Theme.of(context).colorScheme.onSurface : (Theme.of(context).brightness == Brightness.dark ? AppTheme.textMuted : AppTheme.textMutedLight),
                        ),
                      ),
                    ],
                  ),
                ),
                if (i < steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 1,
                      color: i < _step ? AppTheme.primaryColor : Theme.of(context).dividerTheme.color!,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _mouseInfoStep() {
    return Column(
      key: const ValueKey(0),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Informasi Mouse', 'Isi detail mouse yang mau diservis.'),
        const SizedBox(height: 24),
        _label('Brand Mouse'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _brandCtrl,
          style: GoogleFonts.outfit(color: Theme.of(context).colorScheme.onSurface, fontSize: 15),
          decoration: const InputDecoration(
            hintText: 'Logitech, Razer, Zowie, dsb.',
            prefixIcon: Icon(Icons.mouse_outlined, size: 20),
            prefixIconConstraints: BoxConstraints(minWidth: 50),
          ),
        ),
        const SizedBox(height: 18),
        _label('Tipe / Model Mouse'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _modelCtrl,
          style: GoogleFonts.outfit(color: Theme.of(context).colorScheme.onSurface, fontSize: 15),
          decoration: const InputDecoration(
            hintText: 'G Pro X Superlight, Viper Mini, EC2-A, dsb.',
            prefixIcon: Icon(Icons.settings_input_composite_outlined, size: 20),
            prefixIconConstraints: BoxConstraints(minWidth: 50),
          ),
        ),
        const SizedBox(height: 18),
        _label('Kategori Masalah (Bisa pilih lebih dari satu)'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 10,
          children: _categories.map((c) {
            final isSelected = _selectedCategories.contains(c);
            return InkWell(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedCategories.remove(c);
                  } else {
                    _selectedCategories.add(c);
                  }
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryColor.withAlpha(20) : Theme.of(context).colorScheme.surface,
                  border: Border.all(
                    color: isSelected ? AppTheme.primaryColor : Theme.of(context).dividerTheme.color!,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                      size: 18,
                      color: isSelected ? AppTheme.primaryColor : (Theme.of(context).brightness == Brightness.dark ? AppTheme.textMuted : AppTheme.textMutedLight),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      c,
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected ? AppTheme.primaryColor : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _detailStep() {
    return Column(
      key: const ValueKey(1),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Detail Keluhan', 'Ceritain masalahnya secara detail biar teknisi kita siap.'),
        const SizedBox(height: 24),
        _label('Deskripsi Masalah'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _detailsCtrl,
          maxLines: 5,
          style: GoogleFonts.outfit(color: Theme.of(context).colorScheme.onSurface, fontSize: 15),
          decoration: const InputDecoration(
            hintText: 'Contoh: klik kiri sering double click saat diklik sekali, sudah terjadi sejak 2 minggu lalu...',
          ),
        ),
        const SizedBox(height: 20),
        _label('Foto/Video Kondisi Mouse (Opsional)'),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () async {
            showModalBottomSheet(
              context: context,
              backgroundColor: Theme.of(context).colorScheme.surface,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (ctx) => SafeArea(
                child: Wrap(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.photo_library_outlined),
                      title: Text('Pilih dari Galeri (Foto)', style: GoogleFonts.outfit(color: Theme.of(context).colorScheme.onSurface)),
                      onTap: () async {
                        Navigator.pop(ctx);
                        final xfile = await _picker.pickImage(source: ImageSource.gallery);
                        if (xfile != null) setState(() => _pickedMedia = xfile);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.video_library_outlined),
                      title: Text('Pilih dari Galeri (Video)', style: GoogleFonts.outfit(color: Theme.of(context).colorScheme.onSurface)),
                      onTap: () async {
                        Navigator.pop(ctx);
                        final xfile = await _picker.pickVideo(source: ImageSource.gallery);
                        if (xfile != null) setState(() => _pickedMedia = xfile);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.camera_alt_outlined),
                      title: Text('Ambil Foto/Video', style: GoogleFonts.outfit(color: Theme.of(context).colorScheme.onSurface)),
                      onTap: () async {
                        Navigator.pop(ctx);
                        final xfile = await _picker.pickImage(source: ImageSource.camera);
                        if (xfile != null) setState(() => _pickedMedia = xfile);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 130),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).dividerTheme.color!, style: BorderStyle.solid),
            ),
            child: _pickedMedia == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate_outlined, size: 34, color: (Theme.of(context).brightness == Brightness.dark ? AppTheme.textMuted : AppTheme.textMutedLight)),
                      const SizedBox(height: 8),
                      Text(
                        'Tambah foto atau video (MP4/JPG/PNG)',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(color: (Theme.of(context).brightness == Brightness.dark ? AppTheme.textMuted : AppTheme.textMutedLight), fontSize: 13),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _pickedMedia!.path.endsWith('.mp4') ? Icons.video_file : Icons.image,
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _pickedMedia!.name,
                              style: GoogleFonts.outfit(color: Theme.of(context).colorScheme.onSurface, fontSize: 14, fontWeight: FontWeight.w500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            color: (Theme.of(context).brightness == Brightness.dark ? AppTheme.textMuted : AppTheme.textMutedLight),
                            onPressed: () => setState(() => _pickedMedia = null),
                          ),
                        ],
                      ),
                      if (!_pickedMedia!.path.endsWith('.mp4'))
                         Padding(
                           padding: const EdgeInsets.only(top: 8),
                           child: ClipRRect(
                             borderRadius: BorderRadius.circular(8),
                             child: Image.file(
                               File(_pickedMedia!.path),
                               height: 100,
                               width: double.infinity,
                               fit: BoxFit.cover,
                               errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
                             ),
                           ),
                         ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _shipStep() {
    return Column(
      key: const ValueKey(2),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Cara Pengiriman', 'Kirimkan mouse kamu ke alamat bengkel kami.'),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.primaryColor.withAlpha(60)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, color: AppTheme.primaryColor, size: 20),
                  const SizedBox(width: 8),
                  Text('Alamat Bengkel', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface, fontSize: 15)),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Jl. H. Hasan No.26, RT.3/RW.10, Baru,\nKec. Pasar Rebo, Jakarta Timur 13780',
                style: GoogleFonts.outfit(color: (Theme.of(context).brightness == Brightness.dark ? AppTheme.textMuted : AppTheme.textMutedLight), fontSize: 14, height: 1.7),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _infoTile(Icons.local_shipping_outlined, 'GoSend / JNE / J&T / Antar Langsung', 'Ongkir ditanggung pelanggan.'),
        const SizedBox(height: 10),
        _infoTile(Icons.receipt_long_outlined, 'ID Booking', 'Tuliskan ID Booking di paket untuk memudahkan admin.'),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text('Buat Booking', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _infoTile(IconData icon, String title, String sub) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerTheme.color!),
      ),
      child: Row(
        children: [
          Icon(icon, color: (Theme.of(context).brightness == Brightness.dark ? AppTheme.textMuted : AppTheme.textMutedLight), size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
                Text(sub, style: GoogleFonts.outfit(fontSize: 12, color: (Theme.of(context).brightness == Brightness.dark ? AppTheme.textMuted : AppTheme.textMutedLight))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButtons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: Theme.of(context).dividerTheme.color!)),
      ),
      child: Row(
        children: [
          if (_step > 0)
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: () => setState(() => _step--),
                  child: Text('Kembali', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          if (_step > 0) const SizedBox(width: 12),
          if (_step < 2)
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () => setState(() => _step++),
                  child: Text('Lanjut', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, String sub) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface, letterSpacing: -0.5)),
        const SizedBox(height: 4),
        Text(sub, style: GoogleFonts.outfit(fontSize: 13, color: (Theme.of(context).brightness == Brightness.dark ? AppTheme.textMuted : AppTheme.textMutedLight))),
      ],
    );
  }

  Widget _label(String t) => Text(t, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface));
}

class _BookingSuccessSheet extends StatefulWidget {
  final String bookingId;
  final String rawBookingId;
  final String mouseName;
  final String issue;
  final VoidCallback onViewOrders;

  const _BookingSuccessSheet({
    required this.bookingId,
    required this.rawBookingId,
    required this.mouseName,
    required this.issue,
    required this.onViewOrders,
  });

  @override
  State<_BookingSuccessSheet> createState() => _BookingSuccessSheetState();
}

class _BookingSuccessSheetState extends State<_BookingSuccessSheet> {
  Map<String, dynamic>? _storeInfo;
  bool _loadingStore = true;
  bool _copied = false;

  @override
  void initState() {
    super.initState();
    _loadStoreInfo();
  }

  Future<void> _loadStoreInfo() async {
    try {
      final info = await ApiService.getStoreInfo();
      if (mounted) setState(() { _storeInfo = info; _loadingStore = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingStore = false);
    }
  }

  String _buildTemplate() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final senderName = userProvider.name.isNotEmpty ? userProvider.name : 'Pengguna';
    final receiverName = _storeInfo?['receiverName'] ?? _storeInfo?['name'] ?? 'Bengkel Mouse';
    final address = _storeInfo?['address'] ?? '-';
    final phone = _storeInfo?['phone'] ?? _storeInfo?['whatsapp'] ?? '-';
    return '''Pengirim: $senderName

Kepada: $receiverName
Alamat: $address
No. HP: $phone

ID Booking: ${widget.bookingId}
Nama Mouse: ${widget.mouseName}
Keluhan: ${widget.issue}''';
  }

  Future<void> _copyTemplate() async {
    await Clipboard.setData(ClipboardData(text: _buildTemplate()));
    if (mounted) {
      setState(() => _copied = true);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _copied = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = isDark ? AppTheme.textMuted : AppTheme.textMutedLight;

    return PopScope(
      canPop: false,
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
          // Handle bar
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: mutedColor.withAlpha(60), borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          // Success header
          Center(
            child: Column(
              children: [
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(
                    color: AppTheme.statusDone.withAlpha(30),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.statusDone.withAlpha(80)),
                  ),
                  child: const Icon(Icons.check_circle_outline_rounded, color: AppTheme.statusDone, size: 32),
                ),
                const SizedBox(height: 12),
                Text(
                  'Booking Berhasil!',
                  style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: ${widget.bookingId}',
                  style: GoogleFonts.outfit(fontSize: 13, color: mutedColor, letterSpacing: 0.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Shipping template section
          Text(
            'Template Pengiriman',
            style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface),
          ),
          const SizedBox(height: 4),
          Text(
            'Tempel info ini di paket yang akan kamu kirim.',
            style: GoogleFonts.outfit(fontSize: 12, color: mutedColor),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primaryColor.withAlpha(60)),
            ),
            child: _loadingStore
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryColor),
                      ),
                    ),
                  )
                : Text(
                    _buildTemplate(),
                    style: GoogleFonts.robotoMono(fontSize: 12, color: Theme.of(context).colorScheme.onSurface, height: 1.8),
                  ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton.icon(
              onPressed: _loadingStore ? null : _copyTemplate,
              icon: Icon(_copied ? Icons.check_rounded : Icons.copy_outlined, size: 18),
              label: Text(
                _copied ? 'Tersalin!' : 'Salin Template',
                style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: _copied ? AppTheme.statusDone : AppTheme.primaryColor,
                side: BorderSide(color: (_copied ? AppTheme.statusDone : AppTheme.primaryColor).withAlpha(120)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: widget.onViewOrders,
              child: Text('Lihat Pesanan', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    ),
    );
  }
}
