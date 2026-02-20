import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
import 'auth_screens.dart';
import '../main.dart';
import 'package:provider/provider.dart';
import '../services/partner_provider.dart';
import '../services/auth_provider.dart';
import 'auction_screens.dart';

// ═══════════════════════════════════════════════
//  PARTNER SHELL
// ═══════════════════════════════════════════════
class PartnerShell extends StatefulWidget {
  const PartnerShell({super.key});

  @override
  State<PartnerShell> createState() => _PartnerShellState();
}

class _PartnerShellState extends State<PartnerShell> {
  int _currentIndex = 0;

  final _screens = const [
    _PartnerDashboard(),
    _ManageOffersScreen(),
    _OrdersScreen(),
    BulkOrderUploadScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PartnerProvider>().fetchProfile();
      context.read<PartnerProvider>().fetchOffers();
      context.read<PartnerProvider>().fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = context.watch<PartnerProvider>().tabIndex;

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: _buildDrawer(context, currentIndex),
      appBar: currentIndex == 0 ? null : AppBar(
        title: Text(
          currentIndex == 1 ? 'My Offers' : (currentIndex == 2 ? 'Orders' : 'Bulk Orders'),
          style: AppTextStyles.headlineSmall,
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(index: currentIndex, children: _screens),
    );
  }

  Widget _buildDrawer(BuildContext context, int currentIndex) {
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
            child: Row(children: [
              CircleAvatar(radius: 24, backgroundColor: Colors.white24, child: const Icon(Icons.storefront, color: Colors.white, size: 24)),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Fresh Bites', style: AppTextStyles.titleMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                Text('Partner Portal', style: AppTextStyles.caption.copyWith(color: Colors.white70)),
              ])),
            ]),
          ),
          const SizedBox(height: 12),
          _drawerItem(context, 0, 'Dashboard', Icons.dashboard_outlined, Icons.dashboard, currentIndex),
          _drawerItem(context, 1, 'My Offers', Icons.local_offer_outlined, Icons.local_offer, currentIndex),
          _drawerItem(context, 2, 'Orders', Icons.receipt_long_outlined, Icons.receipt_long, currentIndex),
          _drawerItem(context, 3, 'Bulk Orders', Icons.inventory_2_outlined, Icons.inventory_2, currentIndex),
          const Divider(height: 32, indent: 16, endIndent: 16),
          ListTile(
            leading: const Icon(Icons.person_outline, color: AppColors.textSecondary),
            title: Text('Profile', style: AppTextStyles.bodyMedium),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const _PartnerProfileScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined, color: AppColors.textSecondary),
            title: Text('Settings', style: AppTextStyles.bodyMedium),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const _PartnerSettingsScreen()));
            },
          ),
          const Spacer(),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(12),
            child: ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: Text('Log out', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              onTap: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _drawerItem(BuildContext context, int index, String label, IconData icon, IconData activeIcon, int currentIndex) {
    final isSelected = currentIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: Icon(isSelected ? activeIcon : icon, color: isSelected ? AppColors.primary : AppColors.textSecondary),
        title: Text(label, style: AppTextStyles.bodyMedium.copyWith(
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        )),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        selected: isSelected,
        selectedTileColor: AppColors.primary.withValues(alpha: 0.08),
        onTap: () {
          context.read<PartnerProvider>().setTabIndex(index);
          Navigator.pop(context);
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  DASHBOARD
// ═══════════════════════════════════════════════
class _PartnerDashboard extends StatefulWidget {
  const _PartnerDashboard();

  @override
  State<_PartnerDashboard> createState() => _PartnerDashboardState();
}

class _PartnerDashboardState extends State<_PartnerDashboard> {
  bool _isOnline = true;

  @override
  Widget build(BuildContext context) {
    return Consumer<PartnerProvider>(
      builder: (context, provider, child) {
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(provider.profile)),
            SliverPadding(
              padding: const EdgeInsets.all(AppDimens.paddingL),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildMetricsGrid(provider),
                  const SizedBox(height: 24),
                  Text('Recent Activity', style: AppTextStyles.headlineSmall.copyWith(fontSize: 18)),
                  const SizedBox(height: 16),
                  _buildActivityList(),
                ]),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(Map<String, dynamic>? profile) {
    final name = profile?['businessName'] ?? 'Fresh Bites';
    final rating = profile?['rating'] ?? 0.0;
    
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20, bottom: 30, left: 20, right: 20),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
        ),
      ),
      child: Column(
        children: [
          Row(children: [
            Builder(builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(),
            )),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: Row(children: [
                Icon(Icons.star, color: Colors.amber[400], size: 16),
                const SizedBox(width: 4),
                Text('$rating Rating', style: AppTextStyles.caption.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
              ]),
            ),
          ]),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Hello, $name', style: AppTextStyles.headlineMedium.copyWith(color: Colors.white)),
              const SizedBox(height: 4),
              Text('Ready to save food today?', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70)),
            ])),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
              child: Row(children: [
                const SizedBox(width: 12),
                Text(_isOnline ? 'Online' : 'Offline', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600, color: _isOnline ? AppColors.success : AppColors.textHint)),
                const SizedBox(width: 8),
                Switch(
                  value: _isOnline,
                  onChanged: (v) => setState(() => _isOnline = v),
                  activeColor: AppColors.success,
                  activeTrackColor: AppColors.success.withValues(alpha: 0.2),
                ),
              ]),
            )
          ]),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(PartnerProvider provider) {
    return Column(children: [
      Row(children: [
        Expanded(child: MetricCard(icon: Icons.local_offer, label: 'Active Offers', value: '${provider.offers.length}', color: AppColors.primary)),
        SizedBox(width: 16),
        Expanded(child: MetricCard(icon: Icons.receipt_long, label: 'Orders Today', value: '${provider.orders.where((o) => _isToday(o['createdAt'])).length}', color: AppColors.orange)),
      ]),
      const SizedBox(height: 16),
      Row(children: const [
        Expanded(child: MetricCard(icon: Icons.currency_rupee, label: 'Revenue', value: '₹2,450', color: AppColors.success)),
        SizedBox(width: 16),
        Expanded(child: MetricCard(icon: Icons.eco, label: 'Meals Saved', value: '148', color: const Color(0xFF1B5E20))),
      ]),
    ]);
  }

  Widget _buildActivityList() {
    return Column(children: [
      _activityItem(Icons.check_circle, AppColors.success, 'Order #482 Completed', '2 mins ago'),
      _activityItem(Icons.shopping_bag, AppColors.orange, 'New Order Received', '15 mins ago'),
      _activityItem(Icons.add_circle, AppColors.primary, 'New Offer Published', '1 hour ago'),
      _activityItem(Icons.star, Colors.amber, 'Received 5-star rating', '3 hours ago'),
    ]);
  }

  Widget _activityItem(IconData icon, Color color, String title, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), boxShadow: AppShadows.soft),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500)),
          Text(time, style: AppTextStyles.caption),
        ])),
      ]),
    );
  }
  bool _isToday(String? dateStr) {
    if (dateStr == null) return false;
    final date = DateTime.tryParse(dateStr);
    if (date == null) return false;
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
}

// ═══════════════════════════════════════════════
//  MANAGE OFFERS
// ═══════════════════════════════════════════════
class _ManageOffersScreen extends StatefulWidget {
  const _ManageOffersScreen();

  @override
  State<_ManageOffersScreen> createState() => _ManageOffersScreenState();
}

class _ManageOffersScreenState extends State<_ManageOffersScreen> {
  void _showAddOfferSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _CreateOfferSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddOfferSheet,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Offer', style: TextStyle(color: Colors.white)),
      ),
      body: Consumer<PartnerProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) return const Center(child: CircularProgressIndicator());
          
          if (provider.offers.isEmpty) {
             return Center(child: Text('No offers yet', style: AppTextStyles.bodyMedium));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppDimens.paddingL),
            itemCount: provider.offers.length,
            itemBuilder: (ctx, i) {
              final offer = provider.offers[i];
              return _offerCard(
                title: offer['title'],
                desc: offer['description'] ?? '',
                price: '₹${offer['price']}',
                originalPrice: offer['originalPrice'] != null ? '₹${offer['originalPrice']}' : '',
                quantity: offer['quantity'],
                pickupTime: offer['pickupTime'] ?? '',
                status: offer['status'] == 'Active' ? BadgeStatus.active : BadgeStatus.soldOut,
              );
            },
          );
        },
      ),
    );
  }

  Widget _offerCard({
    required String title, required String desc,
    required String price, required String originalPrice,
    required int quantity, required String pickupTime,
    required BadgeStatus status,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), boxShadow: AppShadows.soft),
      child: Column(
        children: [
          Stack(children: [
            Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                color: AppColors.primary.withValues(alpha: 0.1),
              ),
              child: Center(child: Icon(Icons.restaurant, size: 48, color: AppColors.primary.withValues(alpha: 0.3))),
            ),
            Positioned(
              top: 12, right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                child: Row(children: [
                  Icon(Icons.inventory_2, size: 14, color: quantity > 0 ? AppColors.primary : AppColors.error),
                  const SizedBox(width: 4),
                  Text(
                    quantity > 0 ? '$quantity left' : 'Sold Out',
                    style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700, color: quantity > 0 ? AppColors.primary : AppColors.error),
                  ),
                ]),
              ),
            ),
          ]),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Expanded(child: Text(title, style: AppTextStyles.titleMedium)),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text(price, style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary)),
                    Text(originalPrice, style: AppTextStyles.caption.copyWith(decoration: TextDecoration.lineThrough)),
                  ]),
                ]),
                const SizedBox(height: 4),
                Text(desc, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 12),
                Row(children: [
                  const Icon(Icons.access_time, size: 14, color: AppColors.textHint),
                  const SizedBox(width: 6),
                  Text(pickupTime, style: AppTextStyles.caption),
                  const Spacer(),
                  IconButton(icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.textSecondary), onPressed: () {}),
                  IconButton(icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.error), onPressed: () {}),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  ORDERS SCREEN
// ═══════════════════════════════════════════════
class _OrdersScreen extends StatefulWidget {
  const _OrdersScreen();

  @override
  State<_OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<_OrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          color: AppColors.background,
          child: TabBar(
            controller: _tabCtrl,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textHint,
            indicatorColor: AppColors.primary,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
            tabs: const [Tab(text: 'Pending'), Tab(text: 'Ready'), Tab(text: 'History')],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _buildOrderList('Pending'),
          _buildOrderList('Ready'), // Mapped to Active/Ready
          _buildOrderList('Completed'),
        ],
      ),
    );
  }

  Widget _buildOrderList(String status) {
    return Consumer<PartnerProvider>(
      builder: (context, provider, child) {
        // Filter orders
        final orders = provider.orders.where((o) => o['status'] == status).toList();
        
        if (orders.isEmpty) {
          return Center(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox_outlined, size: 64, color: AppColors.textHint.withValues(alpha: 0.3)),
              const SizedBox(height: 16),
              Text('No orders here', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint)),
            ],
          ));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppDimens.paddingL),
          itemCount: orders.length,
          itemBuilder: (_, i) => _orderCard(orders[i], status),
        );
      },
    );
  }

  Widget _orderCard(dynamic order, String status) {
    final buyerName = order['Buyer']?['name'] ?? 'Guest';
    final total = order['totalAmount'];
    final date = DateTime.tryParse(order['createdAt']) ?? DateTime.now();
    final timeStr = '${date.hour}:${date.minute.toString().padLeft(2, '0')}'; 

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), boxShadow: AppShadows.soft),
      child: Column(
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('#10${order['id']}', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
            ),
            const Spacer(),
            Text(timeStr, style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            CircleAvatar(radius: 20, backgroundColor: Colors.grey[200], child: Text(buyerName[0], style: AppTextStyles.titleMedium)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(buyerName, style: AppTextStyles.titleMedium.copyWith(fontSize: 15)),
              Text('Total: ₹$total', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
            ])),
          ]),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),
          if (status == 'Pending')
            Row(children: [
              Expanded(child: OutlinedButton(onPressed: () {}, child: const Text('Reject'))),
              const SizedBox(width: 12),
              Expanded(child: ElevatedButton(
                onPressed: () {
                    context.read<PartnerProvider>().updateOrderStatus(order['id'], 'Ready');
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                child: const Text('Accept'),
              )),
            ])
          else if (status == 'Ready')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                    context.read<PartnerProvider>().updateOrderStatus(order['id'], 'Completed');
                },
                icon: const Icon(Icons.check, size: 18),
                label: const Text('Mark Completed'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white),
              ),
            )
          else
            Row(children: [
              const Icon(Icons.check_circle, size: 16, color: AppColors.success),
              const SizedBox(width: 6),
              const Text('Completed', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w500)),
              const Spacer(),
              TextButton(onPressed: () {}, child: const Text('View Details')),
            ]),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  CREATE OFFER SHEET
// ═══════════════════════════════════════════════
class _CreateOfferSheet extends StatefulWidget {
  const _CreateOfferSheet();

  @override
  State<_CreateOfferSheet> createState() => _CreateOfferSheetState();
}

class _CreateOfferSheetState extends State<_CreateOfferSheet> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _origPriceCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  final _pickupCtrl = TextEditingController();

  Future<void> _submit() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;

    final success = await context.read<PartnerProvider>().createOffer({
      'title': title,
      'description': _descCtrl.text.trim(),
      'price': double.tryParse(_priceCtrl.text) ?? 0,
      'originalPrice': double.tryParse(_origPriceCtrl.text),
      'quantity': int.tryParse(_qtyCtrl.text) ?? 1,

      'pickupTime': _pickupCtrl.text.trim(),
      'imageUrl': 'https://loremflickr.com/320/240/food,dish?random=${DateTime.now().millisecondsSinceEpoch}',
    });

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Offer Created Successfully!'), backgroundColor: AppColors.success));
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to create offer. Check connection/fields.'), backgroundColor: AppColors.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 24, left: 20, right: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Text('Create New Offer', style: AppTextStyles.headlineSmall),
            const SizedBox(height: 24),
            Row(children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)),
                child: const Icon(Icons.add_a_photo, color: Colors.grey),
              ),
              const SizedBox(width: 16),
              Expanded(child: Column(children: [
                AppInputField(label: 'Title', hint: 'e.g. Veggie Surprise', controller: _titleCtrl),
              ])),
            ]),
            const SizedBox(height: 16),
            const SizedBox(height: 16),
            AppInputField(label: 'Description', hint: 'What\'s in the bag?', controller: _descCtrl),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: AppInputField(label: 'Price', hint: '₹', keyboardType: TextInputType.number, controller: _priceCtrl)),
              SizedBox(width: 16),
              Expanded(child: AppInputField(label: 'Original Price', hint: '₹', keyboardType: TextInputType.number, controller: _origPriceCtrl)),
            ]),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: AppInputField(label: 'Quantity', hint: '5', keyboardType: TextInputType.number, controller: _qtyCtrl)),
              SizedBox(width: 16),
              Expanded(child: AppInputField(label: 'Pickup Time', hint: '6pm - 8pm', controller: _pickupCtrl)),
            ]),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(label: 'Publish Offer', onPressed: _submit),
            ),
          ],
        ),
      ),
    );
  }
}
// ═══════════════════════════════════════════════
//  PARTNER PROFILE
// ═══════════════════════════════════════════════
// ═══════════════════════════════════════════════
//  PARTNER PROFILE
// ═══════════════════════════════════════════════
// ═══════════════════════════════════════════════
//  PARTNER PROFILE
// ═══════════════════════════════════════════════
class _PartnerProfileScreen extends StatefulWidget {
  const _PartnerProfileScreen();

  @override
  State<_PartnerProfileScreen> createState() => _PartnerProfileScreenState();
}

class _PartnerProfileScreenState extends State<_PartnerProfileScreen> {
  String _name = 'Fresh Bites';
  String _phone = '+91 98765 43210';
  String _address = '123, Green Street, Eco City';
  String _cuisine = 'Healthy, Vegetarian';

  void _editProfile() {
    final user = context.read<AuthProvider>().user;
    final nameCtrl = TextEditingController(text: user?['businessName'] ?? user?['name'] ?? '');
    final phoneCtrl = TextEditingController(text: user?['phone'] ?? '');
    final addrCtrl = TextEditingController(text: user?['address'] ?? '');
    final cuisineCtrl = TextEditingController(text: user?['cuisine'] ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Edit Profile', style: AppTextStyles.headlineSmall),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppInputField(label: 'Restaurant Name', hint: 'Name', controller: nameCtrl),
              const SizedBox(height: 12),
              AppInputField(label: 'Phone', hint: 'Phone', controller: phoneCtrl),
              const SizedBox(height: 12),
              AppInputField(label: 'Address', hint: 'Address', controller: addrCtrl),
              const SizedBox(height: 12),
              AppInputField(label: 'Cuisine', hint: 'Cuisine', controller: cuisineCtrl),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final success = await context.read<AuthProvider>().updateProfile({
                'businessName': nameCtrl.text.trim(), // API expects businessName for partner display usually, or mapping
                // Wait, User model has 'name' and 'businessName'. 
                // Partner profile screen currently shows '_name' which defaults to 'Fresh Bites'.
                // If I update 'name' it changes user's name. If I update 'businessName' it changes business name.
                // The prompt says "Restaurant Name", so I should probably update 'businessName'.
                // And also maybe 'name' if we want to keep them in sync or just businessName.
                // Let's update both for now or just businessName.
                // Actually the API userController updates whatever is passed.
                // Let's pass 'businessName' as the main display name for partners.
                'businessName': nameCtrl.text.trim(),
                'phone': phoneCtrl.text.trim(),
                'address': addrCtrl.text.trim(),
                'cuisine': cuisineCtrl.text.trim(),
              });

              if (mounted) {
                 Navigator.pop(ctx);
                 if (success) {
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile Updated'), backgroundColor: AppColors.success));
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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(right: -30, top: -30, child: Icon(Icons.storefront, size: 200, color: Colors.white.withValues(alpha: 0.1))),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: CircleAvatar(
                              radius: 40,
                              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                              child: const Icon(Icons.storefront, size: 40, color: AppColors.primary),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Use AuthProvider data
                          Consumer<AuthProvider>(
                            builder: (_, auth, __) {
                              final user = auth.user;
                              final name = user?['businessName'] ?? user?['name'] ?? 'Fresh Bites';
                              return Text(name, style: AppTextStyles.headlineSmall.copyWith(color: Colors.white));
                            }
                          ),
                          Text('Partner since 2024', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(icon: const Icon(Icons.edit, color: Colors.white), onPressed: _editProfile),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(AppDimens.paddingL),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _sectionHeader('Performance'),
                const SizedBox(height: 12),
                Row(children: const [
                  Expanded(child: MetricCard(icon: Icons.star, label: 'Rating', value: '4.8', color: Colors.amber)),
                  SizedBox(width: 16),
                  Expanded(child: MetricCard(icon: Icons.check_circle, label: 'Orders', value: '1,240', color: AppColors.success)),
                ]),
                const SizedBox(height: 24),
                _sectionHeader('Contact Info'),
                const SizedBox(height: 12),
                _infoTile(Icons.email_outlined, 'Email', 'partner@foodloop.com'),
                _infoTile(Icons.phone_outlined, 'Phone', _phone),
                _infoTile(Icons.location_on_outlined, 'Address', _address),
                const SizedBox(height: 24),
                _sectionHeader('Store Details'),
                const SizedBox(height: 12),
                _infoTile(Icons.restaurant_menu, 'Cuisine', _cuisine),
                _infoTile(Icons.access_time, 'Opening Hours', '10:00 AM - 10:00 PM'),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(title, style: AppTextStyles.titleMedium.copyWith(fontSize: 18, color: AppColors.textPrimary));
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), boxShadow: AppShadows.soft),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
          Text(value, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600, fontSize: 15)),
        ])),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════
//  PARTNER SETTINGS
// ═══════════════════════════════════════════════
class _PartnerSettingsScreen extends StatefulWidget {
  const _PartnerSettingsScreen();

  @override
  State<_PartnerSettingsScreen> createState() => _PartnerSettingsScreenState();
}

class _PartnerSettingsScreenState extends State<_PartnerSettingsScreen> {
  bool _notif = true;
  bool _sound = true;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, mode, __) {
        final isDark = mode == ThemeMode.dark;
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text('Settings', style: AppTextStyles.headlineSmall),
            backgroundColor: AppColors.background,
            iconTheme: const IconThemeData(color: AppColors.textPrimary),
          ),
          body: ListView(
            padding: const EdgeInsets.all(AppDimens.paddingL),
            children: [
              _sectionHeader('App Settings'),
              const SizedBox(height: 12),
              _settingCard([
                _switchRow(Icons.notifications_outlined, 'Notifications', 'Receive order updates', _notif, (v) => setState(() => _notif = v)),
                const Divider(height: 1),
                _switchRow(Icons.dark_mode_outlined, 'Dark Mode', 'Reduce eye strain', isDark, (v) {
                  themeNotifier.value = v ? ThemeMode.dark : ThemeMode.light;
                }),
                const Divider(height: 1),
                _switchRow(Icons.volume_up_outlined, 'Sound', 'Play sound on new order', _sound, (v) => setState(() => _sound = v)),
              ]),
              const SizedBox(height: 32),
              _sectionHeader('Support & Legal'),
              const SizedBox(height: 12),
              _settingCard([
                _linkRow(Icons.help_outline, 'Help & Support', () {}),
                const Divider(height: 1),
                _linkRow(Icons.privacy_tip_outlined, 'Privacy Policy', () {}),
                const Divider(height: 1),
                _linkRow(Icons.description_outlined, 'Terms & Conditions', () {}),
              ]),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false),
                  icon: const Icon(Icons.logout, color: AppColors.error),
                  label: const Text('Log Out', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.error, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(child: Text('Version 1.0.0', style: AppTextStyles.caption.copyWith(color: AppColors.textHint))),
            ],
          ),
        );
      }
    );
  }

  Widget _sectionHeader(String title) {
    return Text(title, style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 0.5));
  }

  Widget _settingCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), boxShadow: AppShadows.soft),
      child: Column(children: children),
    );
  }

  Widget _switchRow(IconData icon, String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(title, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: AppTextStyles.caption),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary,
    );
  }

  Widget _linkRow(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: AppColors.textSecondary, size: 20),
      ),
      title: Text(title, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, size: 20, color: AppColors.textHint),
    );
  }
}
