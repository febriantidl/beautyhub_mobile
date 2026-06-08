import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/api_service.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  List<dynamic> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    try {
      final result = await ApiService.myBookings();
      if (result['success'] == true) {
        setState(() => _bookings = result['data'] ?? []);
      }
    } catch (e) {
      // ignore
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'approved':
        return 'Disetujui';
      case 'rejected':
        return 'Ditolak';
      case 'pending':
        return 'Menunggu';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  void _showQrCode(dynamic booking) {
      final qrData = booking['verification_code'] ?? '${booking['id']}';

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 32,
        right: 32,
        top: 32,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          const Icon(Icons.check_circle, color: Colors.green, size: 48),
          const SizedBox(height: 8),
          const Text(
            'Booking Disetujui!',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Tunjukkan QR ini ke MUA saat acara',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFCF4C4C), width: 2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 200,
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'ID Booking: #${booking['id']}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            'Kode: ${booking['booking_code'] ?? '-'}',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            'Tanggal: ${booking['event_date'] ?? '-'}',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 4),
          Text(
            'Waktu: ${booking['time_slot'] ?? '-'}',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 32),
        ],
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Booking Saya',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF4D0012),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _loadBookings();
            },
          )
        ],
      ),
      body: _isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(color: Color(0xFFCF4C4C)))
          : _bookings.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_today,
                          size: 60, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Belum ada booking',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadBookings,
                  color: const Color(0xFFCF4C4C),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _bookings.length,
                    itemBuilder: (context, index) {
                      final booking = _bookings[index];
                      final status = booking['status'] ?? 'pending';
                      final isApproved = status == 'approved';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withValues(alpha: 0.06),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Column(
                          children: [
                            // Header status
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: _statusColor(status)
                                    .withValues(alpha: 0.1),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isApproved
                                        ? Icons.check_circle
                                        : status == 'rejected'
                                            ? Icons.cancel
                                            : Icons.access_time,
                                    color: _statusColor(status),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _statusLabel(status),
                                    style: TextStyle(
                                      color: _statusColor(status),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '#${booking['id']}',
                                    style: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontSize: 12),
                                  ),
                                ],
                              ),
                            ),

                            // Info booking
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                          Icons.face_retouching_natural,
                                          size: 16,
                                          color: Color(0xFFCF4C4C)),
                                      const SizedBox(width: 6),
                                      Text(
                                        booking['mua']?['name'] ??
                                            'MUA',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_today,
                                          size: 14,
                                          color: Colors.grey),
                                      const SizedBox(width: 6),
                                      Text(
                                          booking['event_date'] ?? '-',
                                          style: const TextStyle(
                                              fontSize: 13)),
                                      const SizedBox(width: 16),
                                      const Icon(Icons.access_time,
                                          size: 14,
                                          color: Colors.grey),
                                      const SizedBox(width: 6),
                                      Text(
                                          booking['time_slot'] ?? '-',
                                          style: const TextStyle(
                                              fontSize: 13)),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on,
                                          size: 14,
                                          color: Colors.grey),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          booking[
                                                  'location_address'] ??
                                              '-',
                                          style: const TextStyle(
                                              fontSize: 13),
                                          maxLines: 1,
                                          overflow:
                                              TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(Icons.payments,
                                          size: 14,
                                          color: Colors.grey),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Rp ${booking['price'] ?? 0}',
                                        style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight:
                                                FontWeight.bold,
                                            color:
                                                Color(0xFFCF4C4C)),
                                      ),
                                    ],
                                  ),

                                  // Tombol lihat QR kalau approved
                                  if (isApproved) ...[
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: () =>
                                            _showQrCode(booking),
                                        icon: const Icon(
                                            Icons.qr_code,
                                            color: Colors.white),
                                        label: const Text(
                                            'Lihat QR Code',
                                            style: TextStyle(
                                                color: Colors.white)),
                                        style:
                                            ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF4D0012),
                                          shape:
                                              RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(
                                                    12),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],

                                  // Pesan ditolak
                                  if (status == 'rejected') ...[
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade50,
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.info,
                                              color: Colors.red,
                                              size: 16),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              booking['rejection_reason'] ??
                                                  'Booking ditolak oleh MUA.',
                                              style: const TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 12),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}