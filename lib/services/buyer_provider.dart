import 'package:flutter/material.dart';
import 'api_service.dart';

class BuyerProvider with ChangeNotifier {
  final ApiService _api = ApiService();
  
  List<dynamic> _offers = [];
  List<dynamic> _myOrders = [];
  bool _isLoading = false;

  List<dynamic> get offers => _offers;
  List<dynamic> get myOrders => _myOrders;
  bool get isLoading => _isLoading;

  Future<void> fetchOffers() async {
    _isLoading = true;
    notifyListeners();
    try {
      _offers = await _api.getAllOffers();
    } catch (e) {
      print('Fetch offers error: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchMyOrders() async {
    _isLoading = true;
    notifyListeners();
    try {
      _myOrders = await _api.getMyOrders();
    } catch (e) {
      print('Fetch orders error: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createOrder(Map<String, dynamic> data) async {
    try {
      await _api.createOrder(data);
      await fetchOffers(); // Refresh offers to update quantity
      return true;
    } catch (e) {
      print('Create order error: $e');
      return false;
    }
  }
}
