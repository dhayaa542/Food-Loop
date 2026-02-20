import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
import 'auth_screens.dart';
import 'package:provider/provider.dart';
import '../services/buyer_provider.dart';
import '../services/auth_provider.dart';
import 'auction_screens.dart';
import '../data/app_data.dart';
import 'dart:math';
import '../services/location_service.dart';
import 'payment_screen.dart';
import 'package:geolocator/geolocator.dart';

// ═══════════════════════════════════════════════
//  DATA MODELS & STATE
// ═══════════════════════════════════════════════


// ═══════════════════════════════════════════════
//  BUYER SHELL
// ═══════════════════════════════════════════════
class BuyerShell extends StatefulWidget {
  const BuyerShell({super.key});

  @override
  State<BuyerShell> createState() => _BuyerShellState();
}

class _BuyerShellState extends State<BuyerShell> {
  int _currentIndex = 0;

  final _screens = const [
    _BuyerHomeScreen(),
    _NearbyScreen(),
    _ReservationsScreen(),
    BulkOrderListScreen(),
    _BuyerProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BuyerProvider>().fetchOffers();
      context.read<BuyerProvider>().fetchMyOrders();
    });
  }

  final _drawerItems = const [
    _DrawerItem(Icons.home, 'Home'),
    _DrawerItem(Icons.explore, 'Nearby'),
    _DrawerItem(Icons.receipt_long, 'Reservations'),
    _DrawerItem(Icons.gavel, 'Auctions'),
    _DrawerItem(Icons.person, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = context.watch<BuyerProvider>().tabIndex;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_drawerItems[currentIndex].label, style: AppTextStyles.headlineSmall),
      ),
      drawer: _buildDrawer(context, _drawerItems, currentIndex, (i) {
        context.read<BuyerProvider>().setTabIndex(i);
        Navigator.pop(context);
      }, 'Buyer'),
      body: IndexedStack(index: currentIndex, children: _screens),
    );
  }
}

// ═══════════════════════════════════════════════
//  SHARED DRAWER BUILDER
// ═══════════════════════════════════════════════
class _DrawerItem {
  final IconData icon;
  final String label;
  const _DrawerItem(this.icon, this.label);
}

Widget _buildDrawer(BuildContext context, List<_DrawerItem> items, int currentIndex, Function(int) onTap, String role) {
  return Drawer(
    backgroundColor: AppColors.surface,
    child: Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 24, bottom: 24, left: 20, right: 20),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF43A047)],
            ),
          ),
          child: Consumer<AuthProvider>(
            builder: (_, auth, __) {
              final user = auth.user;
              final name = user != null ? user['name'] : 'Guest';
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   const CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.person, color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 14),
                  Text(name, style: AppTextStyles.headlineSmall.copyWith(color: Colors.white)),
                  const SizedBox(height: 2),
                  Text(role, style: AppTextStyles.caption.copyWith(color: Colors.white70)),
                ],
              );
            }
          ),
        ),
        const SizedBox(height: 8),
        ...List.generate(items.length, (i) {
          final selected = currentIndex == i;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            child: ListTile(
              leading: Icon(items[i].icon, color: selected ? AppColors.primary : AppColors.textSecondary, size: 22),
              title: Text(items[i].label, style: AppTextStyles.bodyMedium.copyWith(
                color: selected ? AppColors.primary : AppColors.textPrimary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              )),
              selected: selected,
              selectedTileColor: AppColors.primary.withValues(alpha: 0.08),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusMedium)),
              onTap: () => onTap(i),
            ),
          );
        }),
        const Spacer(),
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error, size: 22),
            title: Text('Log out', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusMedium)),
            onTap: () {
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    ),
  );
}

// ═══════════════════════════════════════════════
//  BUYER HOME
// ═══════════════════════════════════════════════
class _BuyerHomeScreen extends StatelessWidget {
  const _BuyerHomeScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<BuyerProvider>(
        builder: (context, provider, child) {
          final offers = provider.offers;
          final user = context.watch<AuthProvider>().user;
          final name = user != null ? user['name'] : 'Guest';

          return Stack(
            children: [
              Container(
                height: 220,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [Color(0xFF1B5E20), AppColors.background],
                    stops: [0.0, 0.9],
                  ),
                ),
              ),
              SafeArea(
                child: ListView(
                  padding: const EdgeInsets.all(AppDimens.paddingL),
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Good evening,', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70)),
                              Text('$name 🌱', style: AppTextStyles.headlineMedium.copyWith(color: Colors.white)),
                            ],
                          ),
                        ),
                        Container(
                          decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                          padding: const EdgeInsets.all(4),
                          child: const CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.person, color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search dishes, restaurants...',
                          hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
                          icon: const Icon(Icons.search, color: AppColors.primary),
                          border: InputBorder.none,
                          suffixIcon: Container(
                            margin: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
                            child: const Icon(Icons.tune, size: 18, color: AppColors.primary),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Text('Recommended For You', style: AppTextStyles.headlineSmall),
                        const Spacer(),
                        Text('View All', style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 270,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: offers.length,
                        itemBuilder: (context, index) {
                          final offer = offers[index];
                          return _offerCard(context, offer);
                        },
                      ),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Text('Nearby Offers', style: AppTextStyles.headlineSmall),
                        const Spacer(),
                        Text('View All', style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...offers.map((offer) => _offerTile(context, offer)).toList(),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _offerCard(BuildContext context, dynamic data) {
    final title = data['title'];
    final restaurant = data['Partner']?['businessName'] ?? 'Unknown';
    final price = '₹${data['price']}';
    final pickupTime = data['pickupTime'] ?? '';
    final imageUrl = data['imageUrl'] ?? '';
    
    return OfferCard(
      title: title,
      restaurant: restaurant,
      price: price,
      distance: '1.2 km', // Mock distance
      pickupTime: pickupTime,
      imageUrl: imageUrl,
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _OfferDetailScreen(offerData: data))),
    );
  }

  Widget _offerTile(BuildContext context, dynamic data) {
    return OfferListTile(
      title: data['title'],
      restaurant: data['Partner']?['businessName'] ?? 'Unknown',
      price: '₹${data['price']}',
      distance: '1.2 km',
      imageUrl: data['imageUrl'] ?? '',
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _OfferDetailScreen(offerData: data))),
    );
  }
}

// ═══════════════════════════════════════════════
//  OFFER DETAIL
// ═══════════════════════════════════════════════
class _OfferDetailScreen extends StatelessWidget {
  final dynamic offerData;
  const _OfferDetailScreen({required this.offerData});

  @override
  Widget build(BuildContext context) {
    final title = offerData['title'];
    final restaurant = offerData['Partner']?['businessName'] ?? 'Unknown';
    final price = '₹${offerData['price']}';
    final pickupTime = offerData['pickupTime'] ?? '6-8 PM';
    final description = offerData['description'] ?? 'No description';
    final imageUrl = offerData['imageUrl'];
    final partnerId = offerData['partnerId'];
    final offerId = offerData['id'];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppColors.background,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: const Icon(Icons.favorite_border, color: Colors.black, size: 20),
                    onPressed: () {},
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: title,
                child: imageUrl != null && imageUrl.isNotEmpty
                  ? Image.network(imageUrl, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Image.network('https://images.unsplash.com/photo-1546069901-ba9599a7e63c', fit: BoxFit.cover))
                  : Image.network('https://images.unsplash.com/photo-1546069901-ba9599a7e63c', fit: BoxFit.cover),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppDimens.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(title, style: AppTextStyles.headlineLarge)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                        child: Text('4.8 ★', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.success, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('$restaurant • 1.2 km', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 24),
                  
                  // Info Cards
                  Row(
                    children: [
                      _infoCard(Icons.access_time, 'Pickup', pickupTime),
                      const SizedBox(width: 12),
                      _infoCard(Icons.inventory_2, 'Left', '${offerData['quantity']} Packs'),
                      const SizedBox(width: 12),
                      _infoCard(Icons.eco, 'Save', '0.8 kg'),
                    ],
                  ),
                  const SizedBox(height: 32),

                  Text('About this offer', style: AppTextStyles.headlineSmall),
                  const SizedBox(height: 12),
                  Text(
                    description,
                    style: AppTextStyles.bodyMedium.copyWith(height: 1.5, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 100), // Spacing for bottom bar
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0,-5))],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Price', style: AppTextStyles.caption),
                  const SizedBox(height: 4),
                  Text(price, style: AppTextStyles.headlineMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(width: 24),
              Expanded(
                child: SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () async {
                       final double priceVal = double.tryParse(offerData['price'].toString()) ?? 0.0;
                       final int pId = int.tryParse(offerData['partnerId'].toString()) ?? 0;
                       final int oId = int.tryParse(offerData['id'].toString()) ?? 0;

                       if (priceVal <= 0 || pId == 0 || oId == 0) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid Offer Data'), backgroundColor: Colors.red));
                          return;
                       }

                       // Navigate to Payment Screen
                       Navigator.push(
                         context,
                         MaterialPageRoute(
                           builder: (_) => PaymentScreen(
                             amount: priceVal,
                             onPaymentSuccess: () async {
                               // Perform Order Creation AFTER Payment
                               final error = await context.read<BuyerProvider>().createOrder({
                                 'partnerId': pId,
                                 'items': [
                                   {'offerId': oId, 'quantity': 1, 'price': priceVal}
                                 ],
                                 'totalAmount': priceVal
                               });

                              if (error == null && context.mounted) {
                                  Navigator.pop(context); // Close Payment Screen
                                  // Navigator.pop(context); // Keep detail open or close? The original logic had pop then show sheet.
                                  // Let's show the success sheet ON TOP of detail screen (after popping payment)
                                  
                                  showModalBottomSheet(
                                    context: context,
                                    backgroundColor: Colors.transparent,
                                    builder: (_) => Container(
                                      margin: const EdgeInsets.all(16),
                                      padding: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const CircleAvatar(
                                            radius: 32, backgroundColor: AppColors.success,
                                            child: Icon(Icons.check, color: Colors.white, size: 32),
                                          ),
                                          const SizedBox(height: 16),
                                          Text('Reserved!', style: AppTextStyles.headlineMedium.copyWith(fontWeight: FontWeight.bold)),
                                          const SizedBox(height: 8),
                                          Text('Pick up at $pickupTime', textAlign: TextAlign.center, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                                          const SizedBox(height: 24),
                                          PrimaryButton(label: 'View Orders', onPressed: () {
                                            Navigator.pop(context); // Close sheet
                                            Navigator.pop(context); // Close detail
                                            context.read<BuyerProvider>().setTabIndex(1); // Switch to Orders tab
                                          }),
                                        ],
                                      ),
                                    ),
                                  );
                                } else if (context.mounted) {
                                  Navigator.pop(context); // Close Payment Screen
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Order Failed: $error'), backgroundColor: AppColors.error));
                                }
                              },
                            ),
                          ),
                        );
                        // Removed invalid code accessing 'error' outside callback
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text('Reserve Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(height: 8),
            Text(value, style: AppTextStyles.titleMedium.copyWith(fontSize: 13), textAlign: TextAlign.center, maxLines: 1),
            const SizedBox(height: 4),
            Text(label, style: AppTextStyles.caption.copyWith(fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  NEARBY
// ═══════════════════════════════════════════════
// ═══════════════════════════════════════════════
//  NEARBY (AI POWERED)
// ═══════════════════════════════════════════════
class _NearbyScreen extends StatefulWidget {
  const _NearbyScreen();
  @override
  State<_NearbyScreen> createState() => _NearbyScreenState();
}

class _NearbyScreenState extends State<_NearbyScreen> with SingleTickerProviderStateMixin {
  String _selectedFilter = 'All';
  bool _isScanning = true;
  String _statusMessage = 'Initializing AI...';
  List<Map<String, dynamic>> _nearbyOffers = [];
  Position? _userLocation;

  late AnimationController _scanCtrl;

  @override
  void initState() {
    super.initState();
    _scanCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    _initAI();
  }

  @override
  void dispose() {
    _scanCtrl.dispose();
    super.dispose();
  }

  Future<void> _initAI() async {
    // 1. Get Location
    setState(() => _statusMessage = 'Acquiring GPS Signal...');
    _userLocation = await LocationService().getCurrentLocation();
    
    if (_userLocation == null) {
      if (mounted) setState(() { _isScanning = false; _statusMessage = 'Location access denied.'; });
      return;
    }

    // 2. Fetch Data (Simulated for Demo, ideally fetch from API with coordinates)
    setState(() => _statusMessage = 'Scanning for food nearby...');
    
    // In a real app, we'd call an API. Here we'll grab offers from Provider and "enrich" them with fake coordinates near the user
    final allOffers = context.read<BuyerProvider>().offers; // Assuming this is populated
    if (allOffers.isEmpty) await context.read<BuyerProvider>().fetchOffers();
    final freshOffers = context.read<BuyerProvider>().offers;

    // 3. AI Processing
    final List<Map<String, dynamic>> processed = [];
    final random = Random();

    for (var offer in freshOffers) {
      // Simulate Partner Location (random offset from user)
      // 0.01 deg is approx 1.1km
      final latOffset = (random.nextDouble() - 0.5) * 0.05; 
      final lngOffset = (random.nextDouble() - 0.5) * 0.05;
      
      final pLat = _userLocation!.latitude + latOffset;
      final pLng = _userLocation!.longitude + lngOffset;

      final distMeters = LocationService().calculateDistance(
        _userLocation!.latitude, _userLocation!.longitude, 
        pLat, pLng
      );
      
      final partner = offer['Partner'] ?? {};
      final rating = double.tryParse(partner['rating']?.toString() ?? '4.0') ?? 4.0;

      // AI Score Formula: 
      // Distance Weight: 60% (Lower is better)
      // Rating Weight: 40% (Higher is better)
      // Normalized Distance (0-5km) -> 1.0 - 0.0
      double distScore = (5000 - distMeters).clamp(0, 5000) / 5000; 
      double rateScore = rating / 5.0;
      double aiScore = (distScore * 0.7) + (rateScore * 0.3);

      processed.add({
        ...offer,
        'distanceMeters': distMeters,
        'distanceStr': LocationService().formatDistance(distMeters),
        'aiScore': aiScore,
      });
    }

    // Sort by AI Score descending
    processed.sort((a, b) => (b['aiScore'] as double).compareTo(a['aiScore'] as double));

    if (mounted) {
      setState(() {
        _nearbyOffers = processed;
        _isScanning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isScanning) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RotationTransition(
                turns: _scanCtrl,
                child: const Icon(Icons.radar, size: 64, color: AppColors.primary),
              ),
              const SizedBox(height: 24),
              Text(_statusMessage, style: AppTextStyles.titleMedium),
              const SizedBox(height: 8),
              Text('Using AI to find best offers near you...', style: AppTextStyles.caption),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header with Location
          Container(
            padding: const EdgeInsets.all(AppDimens.paddingL),
            color: AppColors.surface,
            child: Row(
              children: [
                const Icon(Icons.my_location, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Your Location', style: AppTextStyles.caption),
                    Text('Lat: ${_userLocation?.latitude.toStringAsFixed(4)}, Lng: ${_userLocation?.longitude.toStringAsFixed(4)}', style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold)),
                  ]),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: const Text('AI Active', style: TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppDimens.paddingL),
              itemCount: _nearbyOffers.length,
              itemBuilder: (_, i) {
                final offer = _nearbyOffers[i];
                final partner = offer['Partner'] ?? {};
                return OfferListTile(
                  title: offer['title'], 
                  restaurant: partner['businessName'] ?? 'Unknown', 
                  price: '₹${offer['price']}', 
                  distance: offer['distanceStr'],
                  imageUrl: offer['imageUrl'] ?? '',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _OfferDetailScreen(offerData: offer))),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  RESERVATIONS
// ═══════════════════════════════════════════════
class _ReservationsScreen extends StatelessWidget {
  const _ReservationsScreen();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            const TabBar(
              tabs: [Tab(text: 'Active'), Tab(text: 'History')],
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textHint,
              indicatorColor: AppColors.primary,
            ),
            Expanded(
              child: Consumer<BuyerProvider>(
                builder: (context, provider, child) {
                  final reservations = provider.myOrders;
                  final active = reservations.where((r) => r['status'] == 'Pending' || r['status'] == 'Ready').toList();
                  final history = reservations.where((r) => r['status'] == 'Completed' || r['status'] == 'Cancelled').toList();

                  return TabBarView(
                    children: [
                      _reservationList(active),
                      _reservationList(history),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _reservationList(List<dynamic> items) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long, size: 64, color: AppColors.textHint.withValues(alpha: 0.3)),
            const SizedBox(height: 12),
            Text('No reservations', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint)),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppDimens.paddingL),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (_, i) {
        final r = items[i];
        final partner = r['Partner'] ?? {};
        final partnerUser = partner['User'] ?? {};
        final email = partnerUser['email'] ?? 'No email';
        final orderItems = r['OrderItems'] as List? ?? [];
        
        // Get Image: Try first item's offer image, fallback to partner image
        String imageUrl = partner['imageUrl'] ?? '';
        if (orderItems.isNotEmpty && orderItems.first['Offer'] != null) {
          imageUrl = orderItems.first['Offer']['imageUrl'] ?? imageUrl;
        }

        final total = r['totalAmount'];
        final status = r['status'];
        final date = DateTime.tryParse(r['createdAt']) ?? DateTime.now();
        final timeStr = '${date.hour}:${date.minute.toString().padLeft(2, '0')}';

        return Container(
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), boxShadow: AppShadows.soft),
          child: Column(
            children: [
              // Image Header
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: SizedBox(
                  height: 120,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      imageUrl.isNotEmpty
                          ? Image.network(imageUrl, fit: BoxFit.cover, width: double.infinity,
                              errorBuilder: (_, __, ___) => Container(color: Colors.grey[200], child: const Icon(Icons.broken_image)))
                          : Container(color: Colors.grey[200], child: const Icon(Icons.restaurant, size: 40)),
                      Positioned(
                        top: 12, right: 12,
                        child: StatusBadge(status: status == 'Pending' ? BadgeStatus.pending : (status == 'Ready' ? BadgeStatus.active : BadgeStatus.completed)),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(partner['businessName'] ?? 'Unknown Restaurant', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold))),
                        Text('₹$total', style: AppTextStyles.headlineSmall.copyWith(color: AppColors.primary, fontSize: 18)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Placed at $timeStr • Order #10${r['id']}', style: AppTextStyles.caption),
                    const Divider(height: 24),
                    Row(
                      children: [
                        const Icon(Icons.email_outlined, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 8),
                        Expanded(child: Text(email, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary))),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════
//  BUYER PROFILE
// ═══════════════════════════════════════════════
class _BuyerProfileScreen extends StatefulWidget {
  const _BuyerProfileScreen();
  @override
  State<_BuyerProfileScreen> createState() => _BuyerProfileScreenState();
}

class _BuyerProfileScreenState extends State<_BuyerProfileScreen> {
  void _editProfile(Map<String, String> current) {
    final nameCtrl = TextEditingController(text: current['name']);
    final phoneCtrl = TextEditingController(text: current['phone']);
    final addrCtrl = TextEditingController(text: current['address']);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Edit Profile', style: AppTextStyles.headlineSmall),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppInputField(label: 'Name', hint: 'Your Name', controller: nameCtrl),
              const SizedBox(height: 12),
              AppInputField(label: 'Phone', hint: 'Phone Number', controller: phoneCtrl),
              const SizedBox(height: 12),
              AppInputField(label: 'Address', hint: 'Delivery Address', controller: addrCtrl),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final success = await context.read<AuthProvider>().updateProfile({
                'name': nameCtrl.text.trim(),
                'phone': phoneCtrl.text.trim(),
                'address': addrCtrl.text.trim(),
              });
              
              if (mounted) {
                Navigator.pop(ctx);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile Updated Successfully'), backgroundColor: AppColors.success));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update profile'), backgroundColor: AppColors.error));
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<AuthProvider>(
        builder: (_, auth, __) {
          final data = auth.user ?? {'name': 'Guest', 'email': 'guest@foodloop.com', 'phone': '', 'address': ''};
          return ListView(
            padding: const EdgeInsets.all(AppDimens.paddingL),
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  const Center(
                    child: CircleAvatar(
                      radius: 44,
                      backgroundColor: AppColors.primary, 
                      child: Icon(Icons.person, color: Colors.white, size: 44),
                    ),
                  ),
                  Positioned(
                    right: 120, bottom: 0,
                    child: IconButton(
                      icon: const CircleAvatar(radius: 14, backgroundColor: Colors.white, child: Icon(Icons.edit, size: 16, color: AppColors.primary)),
                      onPressed: () => _editProfile({'name': data['name'], 'phone': data['phone'] ?? '', 'address': data['address'] ?? ''}),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Center(child: Text(data['name'], style: AppTextStyles.headlineSmall)),
              Center(child: Text(data['email'], style: AppTextStyles.caption)),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(AppDimens.paddingM),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppDimens.radiusCard), boxShadow: AppShadows.soft),
                child: Row(
                  children: [
                    _stat('12', 'Meals\nSaved', AppColors.primary),
                    _stat('₹1,840', 'Money\nSaved', AppColors.info),
                    _stat('4.2 kg', 'CO₂\nReduced', AppColors.success),
                  ],
                ),
              ),
              const SizedBox(height: 28),
            const SizedBox(height: 28),
               _settingsTile(Icons.phone_outlined, data['phone'] ?? 'Add Phone'),
               _settingsTile(Icons.location_on_outlined, data['address'] ?? 'Add Address'),
              _settingsTile(Icons.notifications_outlined, 'Notifications'),
              _settingsTile(Icons.help_outline, 'Help & Support'),
            ],
          );
        }
      ),
    );
  }

  Widget _stat(String value, String label, Color color) {
    return Expanded(
      child: Column(children: [
        Text(value, style: AppTextStyles.headlineSmall.copyWith(color: color)),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.caption, textAlign: TextAlign.center),
      ]),
    );
  }

  Widget _settingsTile(IconData icon, String label) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppDimens.radiusMedium), boxShadow: AppShadows.soft),
      child: ListTile(
        leading: Icon(icon, color: AppColors.textSecondary),
        title: Text(label, style: AppTextStyles.bodyMedium),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusMedium)),
      ),
    );
  }
}
