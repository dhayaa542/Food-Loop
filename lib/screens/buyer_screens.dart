import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
import 'auth_screens.dart';

// ═══════════════════════════════════════════════
//  BUYER SHELL  (Drawer Navigation)
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
    _BuyerProfileScreen(),
  ];

  final _drawerItems = const [
    _DrawerItem(Icons.home, 'Home'),
    _DrawerItem(Icons.explore, 'Nearby'),
    _DrawerItem(Icons.receipt_long, 'Reservations'),
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
        // Header
        Container(
          width: double.infinity,
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 24, bottom: 24, left: 20, right: 20),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF43A047)],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white24,
                child: Icon(Icons.person, color: Colors.white, size: 28),
              ),
              const SizedBox(height: 14),
              Text('FoodLoop', style: AppTextStyles.headlineSmall.copyWith(color: Colors.white)),
              const SizedBox(height: 2),
              Text(role, style: AppTextStyles.caption.copyWith(color: Colors.white70)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Menu items
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
      body: ListView(
        padding: const EdgeInsets.all(AppDimens.paddingL),
        children: [
          // Greeting
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Good evening,', style: AppTextStyles.bodyMedium),
                    Text('Alex 🌱', style: AppTextStyles.headlineMedium),
                  ],
                ),
              ),
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: const Icon(Icons.person, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Search bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface, borderRadius: BorderRadius.circular(AppDimens.radiusMedium), boxShadow: AppShadows.soft,
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: AppColors.textHint, size: 22),
                const SizedBox(width: 10),
                Text('Search dishes, restaurants...', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint)),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Recommended
          Text('Recommended For You', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 14),
          SizedBox(
            height: 260,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                OfferCard(title: 'Veggie Bowl', restaurant: 'Green Leaf Cafe', price: '₹89', distance: '1.2 km', pickupTime: '6–8 PM',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const _OfferDetailScreen()))),
                OfferCard(title: 'Pasta Pack', restaurant: 'Italiano Express', price: '₹99', distance: '2.1 km', pickupTime: '7–9 PM',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const _OfferDetailScreen()))),
                OfferCard(title: 'Sushi Box', restaurant: 'Sakura House', price: '₹130', distance: '0.8 km', pickupTime: '8–9 PM',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const _OfferDetailScreen()))),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Nearby Offers
          Text('Nearby Offers', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 14),
          OfferListTile(title: 'Breakfast Bag', restaurant: 'Morning Bites', price: '₹49', distance: '0.5 km',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const _OfferDetailScreen()))),
          OfferListTile(title: 'Curry Combo', restaurant: 'Desi Kitchen', price: '₹75', distance: '1.8 km',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const _OfferDetailScreen()))),
          OfferListTile(title: 'Sweet Treats', restaurant: 'Sugar Rush', price: '₹40', distance: '2.5 km',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const _OfferDetailScreen()))),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  OFFER DETAIL
// ═══════════════════════════════════════════════
class _OfferDetailScreen extends StatelessWidget {
  const _OfferDetailScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220, pinned: true,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.3), shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppColors.primary.withValues(alpha: 0.1),
                child: const Center(child: Icon(Icons.restaurant, size: 72, color: AppColors.primary)),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppDimens.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Veggie Bowl', style: AppTextStyles.headlineMedium),
                  const SizedBox(height: 4),
                  Text('Green Leaf Cafe • 1.2 km away', style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 20),

                  // Price
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
                    ),
                    child: Row(
                      children: [
                        Text('₹89', style: AppTextStyles.headlineMedium.copyWith(color: AppColors.primary)),
                        const SizedBox(width: 8),
                        Text('₹200', style: AppTextStyles.bodyMedium.copyWith(decoration: TextDecoration.lineThrough, color: AppColors.textHint)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(AppDimens.radiusFull)),
                          child: Text('55% off', style: AppTextStyles.caption.copyWith(color: AppColors.success, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Info rows
                  _infoRow(Icons.access_time, 'Pickup Window', '6:00 PM – 8:00 PM'),
                  _infoRow(Icons.inventory_2, 'Qty Available', '3 left'),
                  _infoRow(Icons.eco, 'You Save', '0.8 kg CO₂'),
                  const SizedBox(height: 20),

                  Text('About this offer', style: AppTextStyles.titleMedium),
                  const SizedBox(height: 8),
                  Text('A delicious mix of seasonal vegetables, quinoa, and house dressing. Perfect for a healthy and sustainable meal.',
                      style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 32),

                  PrimaryButton(
                    label: 'Reserve Now',
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                        builder: (_) => Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), shape: BoxShape.circle),
                                child: const Icon(Icons.check_circle, color: AppColors.success, size: 48),
                              ),
                              const SizedBox(height: 16),
                              Text('Reserved!', style: AppTextStyles.headlineSmall),
                              const SizedBox(height: 8),
                              Text('Pick up your Veggie Bowl between 6–8 PM at Green Leaf Cafe.',
                                  style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
                              const SizedBox(height: 24),
                              PrimaryButton(label: 'Done', onPressed: () { Navigator.pop(context); Navigator.pop(context); }),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 10),
          Text(label, style: AppTextStyles.bodyMedium),
          const Spacer(),
          Text(value, style: AppTextStyles.titleMedium.copyWith(fontSize: 14)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  NEARBY
// ═══════════════════════════════════════════════
class _NearbyScreen extends StatelessWidget {
  const _NearbyScreen();

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
                final selected = label == 'All';
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(label),
                    selected: selected,
                    onSelected: (_) {},
                    selectedColor: AppColors.primary.withValues(alpha: 0.15),
                    checkmarkColor: AppColors.primary,
                    labelStyle: AppTextStyles.bodySmall.copyWith(
                      color: selected ? AppColors.primary : AppColors.textSecondary,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                    backgroundColor: AppColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                      side: BorderSide(color: selected ? AppColors.primary : AppColors.divider),
                    ),
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
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const _OfferDetailScreen()))),
                OfferListTile(title: 'Pasta Pack', restaurant: 'Italiano Express', price: '₹99', distance: '2.1 km',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const _OfferDetailScreen()))),
                OfferListTile(title: 'Breakfast Bag', restaurant: 'Morning Bites', price: '₹49', distance: '0.5 km',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const _OfferDetailScreen()))),
                OfferListTile(title: 'Curry Combo', restaurant: 'Desi Kitchen', price: '₹75', distance: '1.8 km',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const _OfferDetailScreen()))),
                OfferListTile(title: 'Sweet Treats', restaurant: 'Sugar Rush', price: '₹40', distance: '2.5 km',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const _OfferDetailScreen()))),
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
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            const TabBar(
              tabs: [Tab(text: 'Upcoming'), Tab(text: 'Completed'), Tab(text: 'Cancelled')],
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textHint,
              indicatorColor: AppColors.primary,
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _reservationList([
                    _ReservationData('Veggie Bowl', 'Green Leaf Cafe', '₹89', 'Today, 6–8 PM', BadgeStatus.active),
                    _ReservationData('Pasta Pack', 'Italiano Express', '₹99', 'Tomorrow, 7–9 PM', BadgeStatus.pending),
                  ]),
                  _reservationList([
                    _ReservationData('Sushi Box', 'Sakura House', '₹130', 'Feb 14, 8–9 PM', BadgeStatus.completed),
                    _ReservationData('Breakfast Bag', 'Morning Bites', '₹49', 'Feb 13, 7–9 AM', BadgeStatus.completed),
                  ]),
                  _reservationList([
                    _ReservationData('Curry Combo', 'Desi Kitchen', '₹75', 'Feb 12, 6–8 PM', BadgeStatus.cancelled),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _reservationList(List<_ReservationData> items) {
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
      children: items.map((r) => Container(
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
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(r.title, style: AppTextStyles.titleMedium.copyWith(fontSize: 14)),
                Text(r.restaurant, style: AppTextStyles.caption),
                const SizedBox(height: 4),
                Text('${r.price} · ${r.time}', style: AppTextStyles.caption.copyWith(fontSize: 11)),
              ]),
            ),
            StatusBadge(status: r.status),
          ],
        ),
      )).toList(),
    );
  }
}

class _ReservationData {
  final String title, restaurant, price, time;
  final BadgeStatus status;
  const _ReservationData(this.title, this.restaurant, this.price, this.time, this.status);
}

// ═══════════════════════════════════════════════
//  BUYER PROFILE
// ═══════════════════════════════════════════════
class _BuyerProfileScreen extends StatelessWidget {
  const _BuyerProfileScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView(
        padding: const EdgeInsets.all(AppDimens.paddingL),
        children: [
          Center(
            child: CircleAvatar(
              radius: 44,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: const Icon(Icons.person, color: AppColors.primary, size: 44),
            ),
          ),
          const SizedBox(height: 14),
          Center(child: Text('Alex Johnson', style: AppTextStyles.headlineSmall)),
          Center(child: Text('alex.j@email.com', style: AppTextStyles.caption)),
          const SizedBox(height: 28),

          // Stats
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

          // Settings
          _settingsTile(Icons.notifications_outlined, 'Notifications'),
          _settingsTile(Icons.location_on_outlined, 'Address'),
          _settingsTile(Icons.help_outline, 'Help & Support'),
          _settingsTile(Icons.info_outline, 'About FoodLoop'),
        ],
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
