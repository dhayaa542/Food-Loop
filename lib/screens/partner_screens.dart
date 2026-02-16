import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
import 'auth_screens.dart';

// ═══════════════════════════════════════════════
//  PARTNER SHELL  (Drawer Navigation)
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
    _CreateOfferScreen(),
    _PartnerReservationsScreen(),
  ];

  final _labels = const ['Dashboard', 'Create Offer', 'Orders'];
  final _icons = const [Icons.dashboard, Icons.add_circle, Icons.receipt_long];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_labels[_currentIndex], style: AppTextStyles.headlineSmall),
      ),
      drawer: Drawer(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(radius: 28, backgroundColor: Colors.white24, child: const Icon(Icons.storefront, color: Colors.white, size: 28)),
                  const SizedBox(height: 14),
                  Text('FoodLoop', style: AppTextStyles.headlineSmall.copyWith(color: Colors.white)),
                  const SizedBox(height: 2),
                  Text('Partner', style: AppTextStyles.caption.copyWith(color: Colors.white70)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ...List.generate(3, (i) {
              final selected = _currentIndex == i;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                child: ListTile(
                  leading: Icon(_icons[i], color: selected ? AppColors.primary : AppColors.textSecondary, size: 22),
                  title: Text(_labels[i], style: AppTextStyles.bodyMedium.copyWith(
                    color: selected ? AppColors.primary : AppColors.textPrimary,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  )),
                  selected: selected,
                  selectedTileColor: AppColors.primary.withValues(alpha: 0.08),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusMedium)),
                  onTap: () { setState(() => _currentIndex = i); Navigator.pop(context); },
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
                onTap: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      body: IndexedStack(index: _currentIndex, children: _screens),
    );
  }
}

// ═══════════════════════════════════════════════
//  PARTNER DASHBOARD
// ═══════════════════════════════════════════════
class _PartnerDashboard extends StatelessWidget {
  const _PartnerDashboard();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView(
        padding: const EdgeInsets.all(AppDimens.paddingL),
        children: [
          Text('Overview', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 14),
          Row(children: const [
            Expanded(child: MetricCard(icon: Icons.local_offer, label: 'Active Offers', value: '5', color: AppColors.primary)),
            SizedBox(width: 14),
            Expanded(child: MetricCard(icon: Icons.check_circle, label: 'Sold Out Today', value: '3', color: AppColors.success)),
          ]),
          const SizedBox(height: 14),
          Row(children: const [
            Expanded(child: MetricCard(icon: Icons.receipt_long, label: 'Reservations', value: '24', color: AppColors.info)),
            SizedBox(width: 14),
            Expanded(child: MetricCard(icon: Icons.currency_rupee, label: 'Weekly Revenue', value: '₹4,200', color: AppColors.orange)),
          ]),
          const SizedBox(height: 28),

          Text('Active Offers', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 14),
          _offerTile('Veggie Bowl', '3 left · ₹89', BadgeStatus.active),
          _offerTile('Pasta Delight', '5 left · ₹99', BadgeStatus.active),
          _offerTile('Breakfast Bag', 'Sold out', BadgeStatus.soldOut),
          _offerTile('Sushi Pack', '2 left · ₹130', BadgeStatus.active),
        ],
      ),
    );
  }

  Widget _offerTile(String title, String subtitle, BadgeStatus status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(AppDimens.paddingM),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppDimens.radiusCard), boxShadow: AppShadows.soft),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(AppDimens.radiusMedium)),
            child: const Icon(Icons.restaurant, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: AppTextStyles.titleMedium.copyWith(fontSize: 14)),
            Text(subtitle, style: AppTextStyles.caption),
          ])),
          StatusBadge(status: status),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  CREATE OFFER
// ═══════════════════════════════════════════════
class _CreateOfferScreen extends StatelessWidget {
  const _CreateOfferScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimens.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo upload
            Container(
              width: double.infinity, height: 160,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimens.radiusCard),
                border: Border.all(color: AppColors.divider, width: 1.5),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt_outlined, size: 40, color: AppColors.textHint),
                  const SizedBox(height: 8),
                  Text('Add Photo', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const AppInputField(label: 'Title', hint: 'e.g. Veggie Bowl', prefixIcon: Icons.restaurant),
            const SizedBox(height: 20),
            const AppInputField(label: 'Description', hint: 'Describe the offer...', prefixIcon: Icons.description_outlined),
            const SizedBox(height: 20),
            const AppInputField(label: 'Price (₹)', hint: 'e.g. 89', prefixIcon: Icons.currency_rupee, keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            const AppInputField(label: 'Quantity', hint: 'e.g. 5', prefixIcon: Icons.inventory_2_outlined, keyboardType: TextInputType.number),
            const SizedBox(height: 20),

            // Pickup time
            Text('Pickup Window', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppDimens.radiusMedium), border: Border.all(color: AppColors.divider)),
                  child: Row(children: [
                    const Icon(Icons.access_time, size: 18, color: AppColors.textHint),
                    const SizedBox(width: 8),
                    Text('6:00 PM', style: AppTextStyles.bodyMedium),
                  ]),
                ),
              ),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text('to', style: AppTextStyles.bodyMedium)),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppDimens.radiusMedium), border: Border.all(color: AppColors.divider)),
                  child: Row(children: [
                    const Icon(Icons.access_time, size: 18, color: AppColors.textHint),
                    const SizedBox(width: 8),
                    Text('8:00 PM', style: AppTextStyles.bodyMedium),
                  ]),
                ),
              ),
            ]),
            const SizedBox(height: 32),
            PrimaryButton(label: 'Publish Offer', onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Offer published!', style: AppTextStyles.bodySmall.copyWith(color: Colors.white)),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusMedium)),
              ));
            }),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  PARTNER RESERVATIONS
// ═══════════════════════════════════════════════
class _PartnerReservationsScreen extends StatelessWidget {
  const _PartnerReservationsScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView(
        padding: const EdgeInsets.all(AppDimens.paddingL),
        children: [
          Text('Today', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 14),
          _orderCard('Alex J.', 'Veggie Bowl', '₹89', '6:30 PM', BadgeStatus.active),
          _orderCard('Priya S.', 'Pasta Pack', '₹99', '7:00 PM', BadgeStatus.pending),
          _orderCard('Rahul K.', 'Veggie Bowl', '₹89', '6:45 PM', BadgeStatus.completed),
          const SizedBox(height: 24),
          Text('Yesterday', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 14),
          _orderCard('Sneha M.', 'Sushi Box', '₹130', '8:15 PM', BadgeStatus.completed),
          _orderCard('Arun D.', 'Breakfast Bag', '₹49', '8:30 AM', BadgeStatus.completed),
        ],
      ),
    );
  }

  Widget _orderCard(String customer, String item, String price, String time, BadgeStatus status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(AppDimens.paddingM),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppDimens.radiusCard), boxShadow: AppShadows.soft),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Text(customer[0], style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(customer, style: AppTextStyles.titleMedium.copyWith(fontSize: 14)),
            Text('$item · $price', style: AppTextStyles.caption),
            Text('Pickup: $time', style: AppTextStyles.caption.copyWith(fontSize: 11)),
          ])),
          StatusBadge(status: status),
        ],
      ),
    );
  }
}
