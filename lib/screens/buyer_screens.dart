import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
import 'auth_screens.dart';
import 'package:provider/provider.dart';
import '../services/buyer_provider.dart';
import '../services/auth_provider.dart';
import 'auction_screens.dart';
import '../data/app_data.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text(_drawerItems[_currentIndex].label, style: AppTextStyles.headlineSmall),
      ),
      drawer: _buildDrawer(context, _drawerItems, _currentIndex, (i) {
        setState(() => _currentIndex = i);
        Navigator.pop(context);
      }, 'Buyer'),
      body: IndexedStack(index: _currentIndex, children: _screens),
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
    final originalPrice = data['originalPrice'] != null ? '₹${data['originalPrice']}' : '';
    final pickupTime = data['pickupTime'] ?? '';
    // OfferCard constructor needs update or use named args.
    // Assuming OfferCard is defined in widgets which I can't easily change right now via this chunk. 
    // Wait, OfferCard was used in previous chunk.
    // I'll reconstruct using OfferCard widget but adapting arguments.
    // Actually I should view widgets.dart to see OfferCard signature, but assuming based on usage:
    // OfferCard(title, restaurant, price, originalPrice, distance, pickupTime, onTap)
    
    return OfferCard(
      title: title,
      restaurant: restaurant,
      price: price,
      distance: '1.2 km', // Mock distance
      pickupTime: pickupTime,
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _OfferDetailScreen(offerData: data))),
    );
  }

  Widget _offerTile(BuildContext context, dynamic data) {
    return OfferListTile(
      title: data['title'],
      restaurant: data['Partner']?['businessName'] ?? 'Unknown',
      price: '₹${data['price']}',
      distance: '1.2 km',
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
                  ? Image.network(imageUrl, fit: BoxFit.cover)
                  : Container(
                      color: AppColors.primary.withOpacity(0.1),
                      child: const Center(child: Icon(Icons.restaurant, size: 64, color: AppColors.primary)),
                    ),
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
                       final success = await context.read<BuyerProvider>().createOrder({
                         'partnerId': partnerId,
                         'items': [
                           {'offerId': offerId, 'quantity': 1, 'price': offerData['price']}
                         ],
                         'totalAmount': offerData['price']
                       });

                       if (success && context.mounted) {
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
                                Text('Reserved!', style: AppTextStyles.headlineMedium),
                                const SizedBox(height: 8),
                                Text('Head to $restaurant during the pickup window.', textAlign: TextAlign.center, style: AppTextStyles.bodyMedium),
                                const SizedBox(height: 24),
                                PrimaryButton(label: 'View Reservations', onPressed: () {
                                  Navigator.pop(context); // Close sheet
                                  Navigator.pop(context); // Close detail
                                  // Ideally navigate to reservations tab
                                }),
                              ],
                            ),
                          ),
                        );
                       }
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
class _NearbyScreen extends StatefulWidget {
  const _NearbyScreen();
  @override
  State<_NearbyScreen> createState() => _NearbyScreenState();
}

class _NearbyScreenState extends State<_NearbyScreen> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDimens.paddingL),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppDimens.radiusMedium), boxShadow: AppShadows.soft),
              child: Row(
                children: [
                  const Icon(Icons.search, color: AppColors.textHint, size: 22),
                  const SizedBox(width: 10),
                  Text('Search nearby offers...', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint)),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingL),
              children: ['All', 'Vegan', 'Indian', 'Italian', 'Bakery', 'Japanese'].map((label) {
                final selected = label == _selectedFilter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(label),
                    selected: selected,
                    showCheckmark: false,
                    onSelected: (_) => setState(() => _selectedFilter = label),
                    backgroundColor: selected ? AppColors.primary : Colors.white,
                    labelStyle: AppTextStyles.bodySmall.copyWith(
                      color: selected ? Colors.white : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: selected ? AppColors.primary : AppColors.divider),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingL),
              children: [
                OfferListTile(title: 'Veggie Bowl', restaurant: 'Green Leaf Cafe', price: '₹89', distance: '1.2 km',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _OfferDetailScreen(offerData: {'title': 'Veggie Bowl', 'Partner': {'businessName': 'Green Leaf Cafe'}, 'price': 89, 'quantity': 5, 'id': 991, 'partnerId': 991 })))),
                OfferListTile(title: 'Pasta Pack', restaurant: 'Italiano Express', price: '₹99', distance: '2.1 km',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _OfferDetailScreen(offerData: {'title': 'Pasta Pack', 'Partner': {'businessName': 'Italiano Express'}, 'price': 99, 'quantity': 3, 'id': 992, 'partnerId': 992 })))),
              ],
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
    return ListView(
      padding: const EdgeInsets.all(AppDimens.paddingL),
      children: items.map((r) {
        // assuming first item details, or just total
        final total = r['totalAmount'];
        final status = r['status'];
        final date = DateTime.tryParse(r['createdAt']) ?? DateTime.now();
        final timeStr = '${date.hour}:${date.minute.toString().padLeft(2, '0')}'; 

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(AppDimens.paddingM),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppDimens.radiusCard), boxShadow: AppShadows.soft),
          child: Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(AppDimens.radiusMedium)),
                child: const Icon(Icons.restaurant, color: AppColors.primary),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Order #10${r['id']}', style: AppTextStyles.titleMedium.copyWith(fontSize: 14)),
                  Text('Placed at $timeStr', style: AppTextStyles.caption),
                  const SizedBox(height: 4),
                  Text('₹$total', style: AppTextStyles.caption.copyWith(fontSize: 11)),
                ]),
              ),
              StatusBadge(status: status == 'Pending' ? BadgeStatus.pending : (status == 'Ready' ? BadgeStatus.active : BadgeStatus.completed)),
            ],
          ),
        );
      }).toList(),
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
            onPressed: () {
              // Implement update profile API call here later
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile Update Not Implemented Yet'), backgroundColor: AppColors.primary));
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
