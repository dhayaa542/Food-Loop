import 'package:flutter/material.dart';
import 'api_service.dart';

class PartnerProvider with ChangeNotifier {
  final ApiService _api = ApiService();
  
  Map<String, dynamic>? _profile;
  List<dynamic> _offers = [];
  List<dynamic> _orders = [];
  bool _isLoading = false;

  Map<String, dynamic>? get profile => _profile;
  List<dynamic> get offers => _offers;
  List<dynamic> get orders => _orders;
  bool get isLoading => _isLoading;

  Future<void> fetchProfile() async {
    _isLoading = true;
    notifyListeners();
    try {
      _profile = await _api.getPartnerProfile();
    } catch (e) {
      print('Fetch profile error: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchOffers() async {
    _isLoading = true;
    notifyListeners();
    try {
      _offers = await _api.getPartnerOffers();
    } catch (e) {
      print('Fetch offers error: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createOffer(Map<String, dynamic> data) async {
    try {
      await _api.createOffer(data);
      await fetchOffers(); // Refresh list
      return true;
    } catch (e) {
      print('Create offer error: $e');
      return false;
    }
  }

  Future<void> fetchOrders() async {
    _isLoading = true;
    notifyListeners();
    try {
      _orders = await _api.getPartnerOrders();
    } catch (e) {
      print('Fetch orders error: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateOrderStatus(int id, String status) async {
    try {
      await _api.updateOrderStatus(id, status);
      await fetchOrders(); // Refresh list
    } catch (e) {
      print('Update order error: $e');
    }
  }
}
