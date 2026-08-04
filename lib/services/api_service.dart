  import 'dart:convert';
  import 'dart:io';
  import 'package:http/http.dart' as http;
  import 'package:shared_preferences/shared_preferences.dart';

  class ApiService {
    static String get baseUrl {
      return 'https://dev-api-bengkelmouse.duaenam.id/api';
    }

    static Future<String?> getToken() async {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('jwt_token');
    }

    static Future<void> saveToken(String token) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', token);
    }

    static Future<void> removeToken() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('jwt_token');
    }

    static Map<String, String> _headers(String? token) {
      return {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };
    }

    // Auth
    static Future<Map<String, dynamic>> login(String email, String password) async {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await saveToken(data['token']);
        return data;
      } else {
        throw Exception(jsonDecode(response.body)['error'] ?? 'Login failed');
      }
    }

    static Future<Map<String, dynamic>> googleLogin(String idToken) async {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': idToken}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await saveToken(data['token']);
        return data;
      } else {
        throw Exception(jsonDecode(response.body)['error'] ?? 'Google login failed');
      }
    }

    static Future<Map<String, dynamic>> register(String name, String email, String password, String phone, String address) async {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password, 'phone': phone, 'address': address}),
      );
      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['error'] ?? 'Registration failed');
      }
    }

    static Future<void> forgotPassword(String email) async {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      if (response.statusCode != 200) {
        final body = jsonDecode(response.body);
        throw Exception(body['error'] ?? 'Gagal mengirim OTP');
      }
    }

    static Future<void> resetPassword(String email, String otp, String newPassword) async {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'otp': otp, 'newPassword': newPassword}),
      );
      if (response.statusCode != 200) {
        final body = jsonDecode(response.body);
        throw Exception(body['error'] ?? 'Gagal mereset password');
      }
    }

    static Future<Map<String, dynamic>> getMe() async {
      final token = await getToken();
      final response = await http
          .get(Uri.parse('$baseUrl/auth/me'), headers: _headers(token))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw Exception('Failed to get user profile');
    }

    static Future<Map<String, dynamic>> updateProfile({String? name, String? phone, String? address}) async {
      final token = await getToken();
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (phone != null) body['phone'] = phone;
      if (address != null) body['address'] = address;
      final response = await http.put(
        Uri.parse('$baseUrl/auth/profile'),
        headers: _headers(token),
        body: jsonEncode(body),
      );
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw Exception(jsonDecode(response.body)['error'] ?? 'Failed to update profile');
    }

    // Stocks
    static Future<List<dynamic>> getStocks() async {
      final token = await getToken();
      final response = await http.get(Uri.parse('$baseUrl/stocks'), headers: _headers(token));
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw Exception('Failed to get stocks');
    }

    static Future<void> createStock(Map<String, dynamic> data) async {
      final token = await getToken();
      final response = await http.post(Uri.parse('$baseUrl/stocks'), headers: _headers(token), body: jsonEncode(data));
      if (response.statusCode != 201) throw Exception('Failed to create stock');
    }

    static Future<void> updateStock(String id, Map<String, dynamic> data) async {
      final token = await getToken();
      final response = await http.put(Uri.parse('$baseUrl/stocks/$id'), headers: _headers(token), body: jsonEncode(data));
      if (response.statusCode != 200) throw Exception('Failed to update stock');
    }

    static Future<void> deleteStock(String id) async {
      final token = await getToken();
      final response = await http.delete(Uri.parse('$baseUrl/stocks/$id'), headers: _headers(token));
      if (response.statusCode != 200) throw Exception('Failed to delete stock');
    }

    // Bookings
    static Future<void> createBooking(Map<String, dynamic> data) async {
      final token = await getToken();
      final response = await http.post(Uri.parse('$baseUrl/bookings'), headers: _headers(token), body: jsonEncode(data));
      if (response.statusCode != 201) throw Exception('Failed to create booking');
    }

    static Future<List<dynamic>> getAllBookings() async {
      final token = await getToken();
      final response = await http.get(Uri.parse('$baseUrl/bookings'), headers: _headers(token));
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw Exception('Failed to get bookings');
    }

    static Future<List<dynamic>> getUserBookings() async {
      final token = await getToken();
      final response = await http.get(Uri.parse('$baseUrl/bookings/my'), headers: _headers(token));
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw Exception('Failed to get user bookings');
    }

    static Future<Map<String, dynamic>> getBookingById(String id) async {
      final token = await getToken();
      final response = await http.get(Uri.parse('$baseUrl/bookings/$id'), headers: _headers(token));
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw Exception('Failed to get booking');
    }

    static Future<void> updateBookingStatus(String id, String status) async {
      final token = await getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/bookings/$id/status'), 
        headers: _headers(token), 
        body: jsonEncode({'status': status})
      );
      if (response.statusCode != 200) throw Exception('Failed to update booking status');
    }

    static Future<void> setBookingAmount(String id, double amount) async {
      final token = await getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/bookings/$id/amount'),
        headers: _headers(token),
        body: jsonEncode({'totalAmount': amount})
      );
      if (response.statusCode != 200) {
        final body = jsonDecode(response.body);
        throw Exception(body['error'] ?? 'Failed to set booking amount');
      }
    }

    static Future<void> uploadPaymentProof(String id, File file) async {
      final token = await getToken();
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/bookings/$id/payment'));
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath('paymentProof', file.path));
      
      var response = await request.send();
      if (response.statusCode != 200) throw Exception('Failed to upload payment proof');
    }
  }
