import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/mua_model.dart';
import '../models/booking_model.dart';

class BookingScreen extends StatefulWidget {
  final MuaModel mua;
  const BookingScreen({super.key, required this.mua});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey            = GlobalKey<FormState>();
  final _locationAddressCtrl = TextEditingController(); // field: location_address
  final _locationNotesCtrl   = TextEditingController(); // field: location_notes (opsional)
  final _notesCtrl           = TextEditingController(); // field: notes (opsional)

  // Pilihan yang perlu dipilih user
  ServiceModel? _selectedService; // dari service list MUA
  String?       _selectedTimeSlot;
  DateTime?     _eventDate;
  bool          _isLoading       = false;
  bool          _loadingSlots    = false;
  String?       _errorMessage;

  // Slot waktu yang tersedia dari /api/mua/{id}/availability
  List<String> _availableSlots = [];

  @override
  void dispose() {
    _locationAddressCtrl.dispose();
    _locationNotesCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  // ─── Pilih tanggal event ─────────────────────────────────────────
  Future<void> _pickEventDate() async {
    final now  = DateTime.now();
    final date = await showDatePicker(
      context    : context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate  : now.add(const Duration(days: 1)),
      lastDate   : now.add(const Duration(days: 365)),
      builder    : (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFFE91E8C)),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() {
        _eventDate       = date;
        _selectedTimeSlot = null; // reset slot kalau ganti tanggal
        _availableSlots  = [];
      });
      _loadAvailability();
    }
  }

  // ─── GET /api/mua/{id}/availability?date=YYYY-MM-DD ──────────────
  Future<void> _loadAvailability() async {
    if (_eventDate == null) return;

    setState(() => _loadingSlots = true);

    final dateStr =
        '${_eventDate!.year}-${_eventDate!.month.toString().padLeft(2, '0')}-${_eventDate!.day.toString().padLeft(2, '0')}';

    try {
      final result = await ApiService.getMuaAvailability(widget.mua.id, dateStr);
      if (!mounted) return;

      if (result['success'] == true) {
        setState(() {
          _availableSlots = List<String>.from(result['available_slots'] ?? []);
        });
      }
    } catch (_) {
      // Kalau gagal load availability, tampilkan slot default
      setState(() {
        _availableSlots = ['08:00', '10:00', '13:00', '15:00', '18:00'];
      });
    } finally {
      if (mounted) setState(() => _loadingSlots = false);
    }
  }

  // ─── POST /api/bookings ───────────────────────────────────────────
  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedService == null) {
      setState(() => _errorMessage = 'Pilih layanan terlebih dahulu');
      return;
    }
    if (_eventDate == null) {
      setState(() => _errorMessage = 'Pilih tanggal acara');
      return;
    }
    if (_selectedTimeSlot == null) {
      setState(() => _errorMessage = 'Pilih waktu');
      return;
    }

    setState(() {
      _isLoading    = true;
      _errorMessage = null;
    });

    final today = DateTime.now();
    final bookingDateStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final eventDateStr =
        '${_eventDate!.year}-${_eventDate!.month.toString().padLeft(2, '0')}-${_eventDate!.day.toString().padLeft(2, '0')}';

    try {
      // Field WAJIB semua harus ada — sesuai BookingApiController Laravel
      final result = await ApiService.createBooking(
        muaId          : widget.mua.id,
        serviceId      : _selectedService!.id,
        bookingDate    : bookingDateStr,      // tanggal order dibuat
        eventDate      : eventDateStr,        // tanggal acara
        timeSlot       : _selectedTimeSlot!,  // jam: "10:00"
        locationAddress: _locationAddressCtrl.text.trim(),
        price          : _selectedService!.price,
        locationNotes  : _locationNotesCtrl.text.trim().isEmpty
                            ? null
                            : _locationNotesCtrl.text.trim(),
        notes          : _notesCtrl.text.trim().isEmpty
                            ? null
                            : _notesCtrl.text.trim(),
      );

      if (!mounted) return;

      if (result['status'] == 'success') {
        final booking = BookingModel.fromJson(result['data']);
        _showSuccessDialog(booking);
      } else {
        // Tampilkan error dari Laravel
        final errors = result['errors'];
        if (errors != null) {
          final errMsg = (errors as Map).values
              .map((e) => e is List ? e.join(', ') : e.toString())
              .join('\n');
          setState(() => _errorMessage = errMsg);
        } else {
          setState(() => _errorMessage = result['message'] ?? 'Booking gagal');
        }
      }
    } catch (e) {
      setState(() => _errorMessage = 'Tidak bisa terhubung ke server');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── Dialog sukses booking ────────────────────────────────────────
  void _showSuccessDialog(BookingModel booking) {
    showDialog(
      context   : context,
      barrierDismissible: false,
      builder   : (ctx) => AlertDialog(
        shape  : RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title  : const Column(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 60),
            SizedBox(height: 8),
            Text('Booking Berhasil!', textAlign: TextAlign.center),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children    : [
            Text('ID Booking: #${booking.id}'),
            const SizedBox(height: 4),
            Text('Status: ${booking.statusLabel}'),
            const SizedBox(height: 4),
            Text('MUA akan konfirmasi pesananmu segera.'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);         // tutup dialog
              Navigator.pop(context);     // kembali ke detail MUA
              Navigator.pop(context);     // kembali ke home
            },
            style    : ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE91E8C)),
            child    : const Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final services = widget.mua.services;

    return Scaffold(
      appBar: AppBar(
        title          : Text('Booking - ${widget.mua.name}'),
        backgroundColor: const Color(0xFFE91E8C),
        foregroundColor: Colors.white,
      ),
      body  : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child  : Form(
          key  : _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children          : [

              // ── Error Message ─────────────────────────────────
              if (_errorMessage != null) ...[
                Container(
                  padding    : const EdgeInsets.all(12),
                  decoration : BoxDecoration(
                    color       : Colors.red[50],
                    border      : Border.all(color: Colors.red[200]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // ─────────────────────────────────────────────────
              // 1. PILIH LAYANAN
              // ─────────────────────────────────────────────────
              _SectionTitle(title: '1. Pilih Layanan'),
              const SizedBox(height: 8),
              if (services.isEmpty)
                const Text('Tidak ada layanan tersedia', style: TextStyle(color: Colors.grey))
              else
                ...services.map((s) => RadioListTile<ServiceModel>(
                  value       : s,
                  groupValue  : _selectedService,
                  onChanged   : (v) => setState(() => _selectedService = v),
                  activeColor : const Color(0xFFE91E8C),
                  title       : Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle    : Text('Rp ${_formatPrice(s.price)}'),
                  shape       : RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  tileColor   : _selectedService?.id == s.id
                      ? const Color(0xFFE91E8C).withOpacity(0.05)
                      : null,
                )),

              const SizedBox(height: 24),

              // ─────────────────────────────────────────────────
              // 2. TANGGAL ACARA
              // ─────────────────────────────────────────────────
              _SectionTitle(title: '2. Tanggal Acara'),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _pickEventDate,
                icon     : const Icon(Icons.calendar_today),
                label    : Text(
                  _eventDate == null
                      ? 'Pilih Tanggal'
                      : '${_eventDate!.day}/${_eventDate!.month}/${_eventDate!.year}',
                ),
                style: OutlinedButton.styleFrom(
                  padding      : const EdgeInsets.all(16),
                  shape        : RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: const BorderSide(color: Color(0xFFE91E8C)),
                  foregroundColor: const Color(0xFFE91E8C),
                ),
              ),

              const SizedBox(height: 24),

              // ─────────────────────────────────────────────────
              // 3. PILIH WAKTU (dari availability API)
              // ─────────────────────────────────────────────────
              _SectionTitle(title: '3. Pilih Waktu'),
              const SizedBox(height: 8),

              if (_eventDate == null)
                const Text(
                  'Pilih tanggal dulu untuk melihat slot yang tersedia',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                )
              else if (_loadingSlots)
                const Center(child: CircularProgressIndicator(color: Color(0xFFE91E8C)))
              else if (_availableSlots.isEmpty)
                const Text(
                  'Tidak ada slot tersedia di tanggal ini',
                  style: TextStyle(color: Colors.red),
                )
              else
                Wrap(
                  spacing : 8,
                  runSpacing: 8,
                  children: _availableSlots.map((slot) => ChoiceChip(
                    label          : Text(slot),
                    selected       : _selectedTimeSlot == slot,
                    onSelected     : (_) => setState(() => _selectedTimeSlot = slot),
                    selectedColor  : const Color(0xFFE91E8C),
                    labelStyle     : TextStyle(
                      color: _selectedTimeSlot == slot ? Colors.white : Colors.black,
                    ),
                  )).toList(),
                ),

              const SizedBox(height: 24),

              // ─────────────────────────────────────────────────
              // 4. ALAMAT LOKASI ACARA (WAJIB)
              // field: location_address
              // ─────────────────────────────────────────────────
              _SectionTitle(title: '4. Alamat Lokasi Acara *'),
              const SizedBox(height: 8),
              TextFormField(
                controller : _locationAddressCtrl,
                maxLines   : 3,
                decoration : InputDecoration(
                  hintText   : 'Jl. Merdeka No. 10, Bandung, Jawa Barat',
                  prefixIcon : const Icon(Icons.location_on),
                  border     : OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled     : true,
                  fillColor  : Colors.white,
                ),
                validator  : (v) {
                  if (v == null || v.trim().isEmpty) return 'Alamat lokasi wajib diisi';
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // ─────────────────────────────────────────────────
              // 5. CATATAN LOKASI (opsional)
              // field: location_notes
              // ─────────────────────────────────────────────────
              _SectionTitle(title: '5. Catatan Lokasi (opsional)'),
              const SizedBox(height: 8),
              TextFormField(
                controller : _locationNotesCtrl,
                decoration : InputDecoration(
                  hintText  : 'Contoh: Dekat masjid, parkir di belakang',
                  prefixIcon: const Icon(Icons.notes),
                  border    : OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled    : true,
                  fillColor : Colors.white,
                ),
              ),

              const SizedBox(height: 16),

              // ─────────────────────────────────────────────────
              // 6. CATATAN TAMBAHAN (opsional)
              // field: notes
              // ─────────────────────────────────────────────────
              _SectionTitle(title: '6. Catatan Tambahan (opsional)'),
              const SizedBox(height: 8),
              TextFormField(
                controller : _notesCtrl,
                maxLines   : 2,
                decoration : InputDecoration(
                  hintText  : 'Contoh: Saya alergi produk tertentu',
                  prefixIcon: const Icon(Icons.chat_bubble_outline),
                  border    : OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled    : true,
                  fillColor : Colors.white,
                ),
              ),

              const SizedBox(height: 24),

              // ─────────────────────────────────────────────────
              // RINGKASAN HARGA
              // ─────────────────────────────────────────────────
              if (_selectedService != null) ...[
                Container(
                  padding    : const EdgeInsets.all(16),
                  decoration : BoxDecoration(
                    color       : const Color(0xFFE91E8C).withOpacity(0.05),
                    border      : Border.all(color: const Color(0xFFE91E8C).withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children         : [
                      const Text('Total Pembayaran', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        'Rp ${_formatPrice(_selectedService!.price)}',
                        style: const TextStyle(
                          color     : Color(0xFFE91E8C),
                          fontSize  : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // ─────────────────────────────────────────────────
              // TOMBOL BOOKING
              // ─────────────────────────────────────────────────
              ElevatedButton(
                onPressed: _isLoading ? null : _submitBooking,
                style    : ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE91E8C),
                  foregroundColor: Colors.white,
                  padding        : const EdgeInsets.symmetric(vertical: 16),
                  shape          : RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20, width: 20,
                        child : CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Konfirmasi Booking',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    return price.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
    );
  }
}