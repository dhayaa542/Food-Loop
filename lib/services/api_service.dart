import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  // Use 10.0.2.2 for Android Emulator, localhost for iOS/Web
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:5001/api';
    if (Platform.isAndroid) return 'http://10.0.2.2:5001/api';
    return 'http://localhost:5001/api';
  }

  final _storage = const FlutterSecureStorage();
  String? _token;

  Future<void> loadToken() async {
    _token = await _storage.read(key: 'jwt_token');
  }

  Future<String?> getToken() async => _token;

  Future<Map<String, String>> _getHeaders() async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (_token != null) {
      headers['x-auth-token'] = _token!;
    }
    return headers;
  }

  // Auth
  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: await _getHeaders(),
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: await _getHeaders(),
      body: jsonEncode({'email': email, 'password': password}),
    );
    
    final data = _handleResponse(response);
    if (data.containsKey('token')) {
      _token = data['token'];
      await _storage.write(key: 'jwt_token', value: _token);
    }
    return data;
  }

  Future<void> logout() async {
    _token = null;
    await _storage.delete(key: 'jwt_token');
  }

  // Partners
  Future<Map<String, dynamic>> getPartnerProfile() async {
    final response = await http.get(
      Uri.parse('$baseUrl/partners/profile'),
      headers: await _getHeaders(),
    );
    return _handleResponse(response);
  }

  Future<List<dynamic>> getPartnerOffers() async {
    final response = await http.get(
      Uri.parse('$baseUrl/partners/offers'),
      headers: await _getHeaders(),
    );
    return _handleListResponse(response);
  }

  Future<Map<String, dynamic>> createOffer(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/partners/offers'),
      headers: await _getHeaders(),
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  Future<List<dynamic>> getPartnerOrders() async {
    final response = await http.get(
      Uri.parse('$baseUrl/partners/orders'),
      headers: await _getHeaders(),
    );
    return _handleListResponse(response);
  }
  
  Future<Map<String, dynamic>> updateOrderStatus(int id, String status) async {
    final response = await http.put(
      Uri.parse('$baseUrl/partners/orders/$id/status'),
      headers: await _getHeaders(),
      body: jsonEncode({'status': status}),
    );
    return _handleResponse(response);
  }

  // Buyer
  Future<List<dynamic>> getAllOffers() async {
    final response = await http.get(
      Uri.parse('$baseUrl/offers'),
      // No headers needed for public, or maybe just content-type
    );
    return _handleListResponse(response);
  }

  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/orders'),
      headers: await _getHeaders(),
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  Future<List<dynamic>> getMyOrders() async {
    final response = await http.get(
      Uri.parse('$baseUrl/orders'),
      headers: await _getHeaders(),
    );
    return _handleListResponse(response);
  }

  // Bidding
  Future<List<dynamic>> getBids(int offerId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/bids/$offerId'),
      // headers: await _getHeaders(), // Bids are public currently
    );
    return _handleListResponse(response);
  }

  Future<Map<String, dynamic>> placeBid(int offerId, double amount) async {
    final response = await http.post(
      Uri.parse('$baseUrl/bids'),
      headers: await _getHeaders(),
      body: jsonEncode({'offerId': offerId, 'amount': amount}),
    );
    return _handleResponse(response);
  }
  
  // Password Reset
  Future<Map<String, dynamic>> resetPassword(String email, String newPassword) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/reset-password'),
      headers: await _getHeaders(),
      body: jsonEncode({'email': email, 'newPassword': newPassword}),
    );
    return _handleResponse(response);
  }

  // Helper
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw HttpException(response.body, response.statusCode);
    }
  }

    // Helper for lists
  List<dynamic> _handleListResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw HttpException(response.body, response.statusCode);
    }
  }
}

class HttpException implements Exception {
  final String message;
  final int statusCode;
  HttpException(this.message, this.statusCode);
  @override
  String toString() => 'HttpException: $statusCode $message';
}
