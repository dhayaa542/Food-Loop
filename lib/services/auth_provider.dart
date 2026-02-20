import 'package:flutter/material.dart';
import 'api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  bool _isAuthenticated = false;
  Map<String, dynamic>? _user;
  bool _isLoading = true;

  bool get isAuthenticated => _isAuthenticated;
  Map<String, dynamic>? get user => _user;
  bool get isLoading => _isLoading;
  ApiService get api => _apiService;

  Future<void> tryAutoLogin() async {
    await _apiService.loadToken();
    final token = await _apiService.getToken();
    if (token != null) {
      // Ideally we should validate token with backend, but for now we assume it's valid if present
      // or we can decode it if we want user details
      _isAuthenticated = true;
      // We might want to fetch user profile here if not stored
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    try {
      final data = await _apiService.login(email, password);
      _user = data['user'];
      _isAuthenticated = true;
      notifyListeners();
      return true;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<bool> register(Map<String, dynamic> data) async {
    try {
      final res = await _apiService.register(data);
       _user = res['user'];
       _isAuthenticated = true;
      notifyListeners();
      return true;
    } catch (e) {
      print('Register error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    await _apiService.logout();
    _isAuthenticated = false;
    _user = null;
    notifyListeners();
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    try {
      final res = await _apiService.updateProfile(data);
      if (res.containsKey('user')) {
        _user = res['user'];
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Update profile error: $e');
      return false;
    }
  }

  Future<bool> resetPassword(String email, String newPassword) async {
    try {
      await _apiService.resetPassword(email, newPassword);
      return true;
    } catch (e) {
      print('Reset password error: $e');
      return false;
    }
  }
}
