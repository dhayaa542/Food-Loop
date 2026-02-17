import 'package:flutter/material.dart';
import '../widgets/widgets.dart';

// ═══════════════════════════════════════════════
//  DATA MODELS & STATE
// ═══════════════════════════════════════════════
class Offer {
  final String title, restaurant, price, originalPrice, distance, pickupTime, about;
  final String? imageUrl;
  final BadgeStatus? status;
  const Offer({
    required this.title, required this.restaurant, required this.price, 
    this.originalPrice = '', required this.distance, this.pickupTime = '', 
    this.about = 'Delicious and sustainable meal.', this.imageUrl, this.status
  });
}

class BuyerData {
  static final ValueNotifier<List<Offer>> reservations = ValueNotifier([
    const Offer(title: 'Sushi Box', restaurant: 'Sakura House', price: '₹130', distance: '0.8 km', pickupTime: 'Feb 14, 8–9 PM', status: BadgeStatus.completed),
  ]);
  
  static final ValueNotifier<Map<String, String>> profile = ValueNotifier({
    'name': 'Alex Johnson',
    'email': 'alex.j@email.com',
    'phone': '+91 98765 43210',
    'address': '123, Eco Street, Green City',
  });

  static void addReservation(Offer offer) {
    // Add as 'Active' reservation
    final newRes = Offer(
      title: offer.title, restaurant: offer.restaurant, price: offer.price, 
      distance: offer.distance, pickupTime: offer.pickupTime, 
      status: BadgeStatus.active
    );
    reservations.value = [newRes, ...reservations.value];
  }

  static void updateProfile(String name, String phone, String address) {
    profile.value = {
      ...profile.value,
      'name': name,
      'phone': phone,
      'address': address,
    };
  }
}
