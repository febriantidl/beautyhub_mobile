import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // ─── Ganti IP ini sesuai komputer kamu ───────────────────────────
  // Android Emulator  → 10.0.2.2
  // iOS Simulator     → localhost
  // HP Fisik          → IP komputer kamu, contoh: 192.168.1.5
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  // ─── Key SharedPreferences ────────────────────────────────────────
  static const String _tokenKey = 'access_token';
  static const String _userKey  = 'user_data';

  // ─── Simpan & ambil token ─────────────────────────────────────────
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  // ─── Header default ───────────────────────────────────────────────
  static Future<Map<String, String>> _headers({bool withAuth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (withAuth) {
      final token = await getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  // ═══════════════════════════════════════════════════════════════════
  // AUTH
  // ═══════════════════════════════════════════════════════════════════

  /// POST /api/register
  /// Field: name, email, password, password_confirmation, [mua_name]
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? muaName,
  }) async {
    final body = {
      'name'                 : name,
      'email'                : email,
      'password'             : password,
      'password_confirmation': passwordConfirmation,
      if (muaName != null) 'mua_name': muaName,
    };

    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: await _headers(withAuth: false),
      body: jsonEncode(body),
    );

    return jsonDecode(response.body);
  }

  /// POST /api/login
  /// Field: email, password
  /// Response penting: data.access_token, data.user
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: await _headers(withAuth: false),
      body: jsonEncode({'email': email, 'password': password}),
    );

    final data = jsonDecode(response.body);

    // Kalau login berhasil, simpan token otomatis
    if (data['success'] == true && data['data'] != null) {
      await saveToken(data['data']['access_token']);
      // Simpan data user juga
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(data['data']['user']));
    }

    return data;
  }

  /// POST /api/logout
  static Future<Map<String, dynamic>> logout() async {
    final response = await http.post(
      Uri.parse('$baseUrl/logout'),
      headers: await _headers(),
    );
    await removeToken();
    return jsonDecode(response.body);
  }

  /// GET /api/me
  static Future<Map<String, dynamic>> me() async {
    final response = await http.get(
      Uri.parse('$baseUrl/me'),
      headers: await _headers(),
    );
    return jsonDecode(response.body);
  }

  // ═══════════════════════════════════════════════════════════════════
  // MUA
  // ═══════════════════════════════════════════════════════════════════

  /// GET /api/muas
  /// Params opsional: location, style, min_rating, verified_only, max_price, sort, per_page
  static Future<Map<String, dynamic>> getMuas({
    String? location,
    String? style,
    double? minRating,
    bool? verifiedOnly,
    double? maxPrice,
    String sort = 'rating',
    int perPage = 10,
    int page = 1,
  }) async {
    final queryParams = {
      'sort'    : sort,
      'per_page': perPage.toString(),
      'page'    : page.toString(),
      if (location != null)     'location'      : location,
      if (style != null)        'style'          : style,
      if (minRating != null)    'min_rating'     : minRating.toString(),
      if (verifiedOnly == true) 'verified_only'  : 'true',
      if (maxPrice != null)     'max_price'      : maxPrice.toString(),
    };

    final uri = Uri.parse('$baseUrl/muas').replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: await _headers());
    return jsonDecode(response.body);
  }

  /// GET /api/muas/{id}
  static Future<Map<String, dynamic>> getMuaDetail(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/muas/$id'),
      headers: await _headers(),
    );
    return jsonDecode(response.body);
  }

  /// GET /api/muas/{id}/portfolio
  static Future<Map<String, dynamic>> getMuaPortfolio(int id, {int page = 1}) async {
    final uri = Uri.parse('$baseUrl/muas/$id/portfolio')
        .replace(queryParameters: {'page': page.toString()});
    final response = await http.get(uri, headers: await _headers());
    return jsonDecode(response.body);
  }

  /// GET /api/muas/{id}/reviews
  static Future<Map<String, dynamic>> getMuaReviews(int id, {int page = 1}) async {
    final uri = Uri.parse('$baseUrl/muas/$id/reviews')
        .replace(queryParameters: {'page': page.toString()});
    final response = await http.get(uri, headers: await _headers());
    return jsonDecode(response.body);
  }

  /// GET /api/mua/{mua_id}/availability?date=YYYY-MM-DD
  static Future<Map<String, dynamic>> getMuaAvailability(int muaId, String date) async {
    final uri = Uri.parse('$baseUrl/mua/$muaId/availability')
        .replace(queryParameters: {'date': date});
    final response = await http.get(uri, headers: await _headers(withAuth: false));
    return jsonDecode(response.body);
  }

  /// GET /api/mua/{mua_id}/services
  static Future<dynamic> getMuaServices(int muaId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/mua/$muaId/services'),
      headers: await _headers(withAuth: false),
    );
    return jsonDecode(response.body);
  }

  // ═══════════════════════════════════════════════════════════════════
  // BOOKING
  // ═══════════════════════════════════════════════════════════════════

  /// POST /api/bookings
  /// Field wajib: mua_id, service_id, booking_date, event_date,
  ///              time_slot, location_address, price
  /// Field opsional: location_notes, notes
  static Future<Map<String, dynamic>> createBooking({
    required int    muaId,
    required int    serviceId,
    required String bookingDate,
    required String eventDate,
    required String timeSlot,
    required String locationAddress,
    required double price,
    String? locationNotes,
    String? notes,
  }) async {
    final body = {
      'mua_id'          : muaId,
      'service_id'      : serviceId,
      'booking_date'    : bookingDate,
      'event_date'      : eventDate,
      'time_slot'       : timeSlot,
      'location_address': locationAddress,
      'price'           : price,
      if (locationNotes != null) 'location_notes': locationNotes,
      if (notes != null)         'notes'          : notes,
    };

    final response = await http.post(
      Uri.parse('$baseUrl/bookings'),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    return jsonDecode(response.body);
  }

  /// GET /api/bookings/my
  static Future<Map<String, dynamic>> myBookings() async {
    final response = await http.get(
      Uri.parse('$baseUrl/bookings/my'),
      headers: await _headers(),
    );
    return jsonDecode(response.body);
  }

  /// PUT /api/bookings/{id}/cancel
  static Future<Map<String, dynamic>> cancelBooking(int id) async {
    final response = await http.put(
      Uri.parse('$baseUrl/bookings/$id/cancel'),
      headers: await _headers(),
    );
    return jsonDecode(response.body);
  }

  /// GET /api/booking/{id} (public)
  static Future<Map<String, dynamic>> getBookingDetail(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/booking/$id'),
      headers: await _headers(withAuth: false),
    );
    return jsonDecode(response.body);
  }

  // ═══════════════════════════════════════════════════════════════════
  // CHATBOT
  // ═══════════════════════════════════════════════════════════════════

  /// POST /api/chatbot/message
  /// Field: message (string, max 500)
  static Future<Map<String, dynamic>> sendChatMessage(String message) async {
    final response = await http.post(
      Uri.parse('$baseUrl/chatbot/message'),
      headers: await _headers(),
      body: jsonEncode({'message': message}),
    );
    return jsonDecode(response.body);
  }

  // ═══════════════════════════════════════════════════════════════════
  // SEARCH BY IMAGE
  // ═══════════════════════════════════════════════════════════════════

  /// POST /api/search/by-image
  /// Pakai multipart/form-data — field: image (File), style_category (optional)
  static Future<Map<String, dynamic>> searchByImage({
    required File imageFile,
    String? styleCategory,
  }) async {
    final token = await getToken();

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/search/by-image'),
    );

    request.headers['Accept']        = 'application/json';
    request.headers['Authorization'] = 'Bearer $token';

    // Field nama WAJIB 'image' — sesuai validasi Laravel
    request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

    if (styleCategory != null && styleCategory.isNotEmpty) {
      request.fields['style_category'] = styleCategory;
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return jsonDecode(response.body);
  }

  // ═══════════════════════════════════════════════════════════════════
  // HELPER
  // ═══════════════════════════════════════════════════════════════════

  /// Cek apakah user sudah login (ada token tersimpan)
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Ambil data user dari SharedPreferences (tanpa hit API)
  static Future<Map<String, dynamic>?> getCachedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);
    if (userData == null) return null;
    return jsonDecode(userData);
  }
}