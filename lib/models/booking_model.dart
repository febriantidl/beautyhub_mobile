// ═══════════════════════════════════════════════════════════════════
// booking_model.dart
// Field mengikuti PERSIS response POST /api/bookings dan GET /api/booking/{id}
// ═══════════════════════════════════════════════════════════════════

class BookingModel {
  final int     id;
  final int?    userId;
  final int     muaId;
  final int?    serviceId;
  final String  bookingDate;
  final String  eventDate;
  final String  timeSlot;
  final String? locationAddress;
  final double  price;
  final String  status;          // pending | confirmed | rejected | cancelled | completed
  final String? verificationCode;
  final String? qrCodeUrl;
  final String? createdAt;
  // Dari GET /api/booking/{id}
  final String? muaName;
  final String? serviceName;

  BookingModel({
    required this.id,
    this.userId,
    required this.muaId,
    this.serviceId,
    required this.bookingDate,
    required this.eventDate,
    required this.timeSlot,
    this.locationAddress,
    required this.price,
    required this.status,
    this.verificationCode,
    this.qrCodeUrl,
    this.createdAt,
    this.muaName,
    this.serviceName,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id                : json['id'],
      userId            : json['user_id'],
      muaId             : json['mua_id'] ?? json['mua']?['id'] ?? 0,
      serviceId         : json['service_id'] ?? json['service']?['id'],
      bookingDate       : json['booking_date'] ?? '',
      eventDate         : json['event_date'] ?? '',
      timeSlot          : json['time_slot'] ?? '',
      locationAddress   : json['location_address'],
      price             : (json['price'] as num?)?.toDouble() ?? 0.0,
      status            : json['status'] ?? 'pending',
      verificationCode  : json['verification_code'],
      qrCodeUrl         : json['qr_code_url'],
      createdAt         : json['created_at']?.toString(),
      muaName           : json['mua']?['name'],
      serviceName       : json['service']?['name'],
    );
  }

  // Helper: warna status
  String get statusLabel {
    switch (status) {
      case 'pending'   : return 'Menunggu Konfirmasi';
      case 'confirmed' : return 'Dikonfirmasi';
      case 'rejected'  : return 'Ditolak';
      case 'cancelled' : return 'Dibatalkan';
      case 'completed' : return 'Selesai';
      default          : return status;
    }
  }
}