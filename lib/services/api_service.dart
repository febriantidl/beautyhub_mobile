import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000/api';

  static const String _tokenKey = 'access_token';
  static const String _userKey  = 'user_data';

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
    if (data['success'] == true && data['data'] != null) {
      await saveToken(data['data']['access_token']);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(data['data']['user']));
    }
    return data;
  }

  static Future<Map<String, dynamic>> logout() async {
    final response = await http.post(
      Uri.parse('$baseUrl/logout'),
      headers: await _headers(),
    );
    await removeToken();
    return jsonDecode(response.body);
  }

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
      if (location != null)     'location'    : location,
      if (style != null)        'style'        : style,
      if (minRating != null)    'min_rating'   : minRating.toString(),
      if (verifiedOnly == true) 'verified_only': 'true',
      if (maxPrice != null)     'max_price'    : maxPrice.toString(),
    };
    final uri = Uri.parse('$baseUrl/muas').replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: await _headers());
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getMuaDetail(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/muas/$id'),
      headers: await _headers(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getMuaPortfolio(int id, {int page = 1}) async {
    final uri = Uri.parse('$baseUrl/muas/$id/portfolio')
        .replace(queryParameters: {'page': page.toString()});
    final response = await http.get(uri, headers: await _headers());
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getMuaReviews(int id, {int page = 1}) async {
    final uri = Uri.parse('$baseUrl/muas/$id/reviews')
        .replace(queryParameters: {'page': page.toString()});
    final response = await http.get(uri, headers: await _headers());
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getMuaAvailability(int muaId, String date) async {
    final uri = Uri.parse('$baseUrl/mua/$muaId/availability')
        .replace(queryParameters: {'date': date});
    final response = await http.get(uri, headers: await _headers(withAuth: false));
    return jsonDecode(response.body);
  }

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

  static Future<Map<String, dynamic>> myBookings() async {
    final response = await http.get(
      Uri.parse('$baseUrl/bookings/my'),
      headers: await _headers(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> cancelBooking(int id) async {
    final response = await http.put(
      Uri.parse('$baseUrl/bookings/$id/cancel'),
      headers: await _headers(),
    );
    return jsonDecode(response.body);
  }

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
    request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    if (styleCategory != null && styleCategory.isNotEmpty) {
      request.fields['style_category'] = styleCategory;
    }
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return jsonDecode(response.body);
  }

  // ═══════════════════════════════════════════════════════════════════
  // NOTIFICATIONS
  // ═══════════════════════════════════════════════════════════════════

  static Future<Map<String, dynamic>> getNotifications() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notifications'),
        headers: await _headers(),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'data': []};
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // HELPER
  // ═══════════════════════════════════════════════════════════════════

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  static Future<Map<String, dynamic>?> getCachedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);
    if (userData == null) return null;
    return jsonDecode(userData);
  }
}