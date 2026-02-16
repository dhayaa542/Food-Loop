import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
import 'auth_screens.dart';

// ═══════════════════════════════════════════════
//  ADMIN SHELL  (Drawer Navigation + Dropdown)
// ═══════════════════════════════════════════════
class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _currentIndex = 0;

  final _screens = const [
    _AdminDashboard(),
    _UserManagementScreen(),
    _PartnerApprovalScreen(),
    _OfferMonitoringScreen(),
    _AnalyticsScreen(),
  ];

  final _labels = const ['Dashboard', 'Users', 'Partners', 'Offers', 'Analytics'];
  final _icons = const [Icons.dashboard, Icons.people, Icons.storefront, Icons.local_offer, Icons.analytics];

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
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF43A047)]),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(radius: 28, backgroundColor: Colors.white24, child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 28)),
                  const SizedBox(height: 14),
                  Text('FoodLoop', style: AppTextStyles.headlineSmall.copyWith(color: Colors.white)),
                  const SizedBox(height: 2),
                  Text('Admin', style: AppTextStyles.caption.copyWith(color: Colors.white70)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ...List.generate(5, (i) {
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
//  ADMIN DASHBOARD  (Premium Design)
// ═══════════════════════════════════════════════
class _AdminDashboard extends StatefulWidget {
  const _AdminDashboard();

  @override
  State<_AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<_AdminDashboard> {
  int _hoveredBar = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView(
        padding: const EdgeInsets.all(AppDimens.paddingL),
        children: [
          // ── Welcome banner ──
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF43A047)],
              ),
              borderRadius: BorderRadius.circular(AppDimens.radiusCard),
              boxShadow: [BoxShadow(color: const Color(0xFF2E7D32).withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 6))],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Welcome back, Admin', style: AppTextStyles.headlineSmall.copyWith(color: Colors.white)),
                      const SizedBox(height: 6),
                      Text("Here's what's happening on FoodLoop today.",
                          style: AppTextStyles.bodySmall.copyWith(color: Colors.white70)),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.eco, color: Colors.white, size: 14),
                          const SizedBox(width: 6),
                          Text('100 meals saved today!', style: AppTextStyles.caption.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                        ]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), shape: BoxShape.circle),
                  child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 36),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Gradient metric cards (green palette) ──
          Row(children: [
            Expanded(child: _gradientMetric('1,247', 'Total Users', Icons.people,
                const [Color(0xFF1B5E20), Color(0xFF388E3C)], '+12%')),
            const SizedBox(width: 12),
            Expanded(child: _gradientMetric('86', 'Partners', Icons.storefront,
                const [Color(0xFF2E7D32), Color(0xFF4CAF50)], '+5')),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _gradientMetric('42', 'Active Offers', Icons.local_offer,
                const [Color(0xFF43A047), Color(0xFF66BB6A)], '8 new')),
            const SizedBox(width: 12),
            Expanded(child: _gradientMetric('3,891', 'Reservations', Icons.receipt_long,
                const [Color(0xFF558B2F), Color(0xFF8BC34A)], '+18%')),
          ]),
          const SizedBox(height: 24),

          // ── Weekly trend chart ──
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimens.radiusCard),
              boxShadow: AppShadows.soft,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text('Weekly Meals Saved', style: AppTextStyles.titleMedium),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.trending_up, size: 14, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text('+24%', style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ]),
                const SizedBox(height: 16),
                _buildPieChart(),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Sustainability impact ──
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimens.radiusCard),
              boxShadow: AppShadows.soft,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.eco, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text('Sustainability Impact', style: AppTextStyles.titleMedium),
                ]),
                const SizedBox(height: 18),
                _impactRow('Meals Saved', '2,847', 0.85, const Color(0xFF2E7D32), '/ 3,500 target'),
                const SizedBox(height: 14),
                _impactRow('CO₂ Reduced', '1.2 T', 0.60, const Color(0xFF388E3C), '/ 2.0 T target'),
                const SizedBox(height: 14),
                _impactRow('Food Waste Prevented', '680 kg', 0.72, const Color(0xFF43A047), '/ 950 kg target'),
                const SizedBox(height: 14),
                _impactRow('Active Cities', '4', 0.40, const Color(0xFF66BB6A), '/ 10 target'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Quick stats row ──
          Row(children: [
            Expanded(child: _quickStat(Icons.schedule, 'Avg Pickup', '18 min', const Color(0xFF2E7D32))),
            const SizedBox(width: 10),
            Expanded(child: _quickStat(Icons.star, 'Avg Rating', '4.6 ★', const Color(0xFF43A047))),
            const SizedBox(width: 10),
            Expanded(child: _quickStat(Icons.repeat, 'Return Rate', '67%', const Color(0xFF66BB6A))),
          ]),
          const SizedBox(height: 24),

          // ── Recent activity ──
          Text('Recent Activity', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 14),
          _activityTile(Icons.person_add, 'New user registered', 'Priya S. joined as Buyer', '2 min ago', const Color(0xFF1B5E20)),
          _activityTile(Icons.storefront, 'Partner request', 'Curry House applied for approval', '15 min ago', const Color(0xFF2E7D32)),
          _activityTile(Icons.check_circle, 'Offer sold out', 'Vegan Bowl at Green Leaf Cafe', '1 hr ago', const Color(0xFF388E3C)),
          _activityTile(Icons.flag, 'Report received', 'User flagged Smoothie Pack offer', '2 hrs ago', const Color(0xFF43A047)),
          _activityTile(Icons.trending_up, 'Milestone reached', '100 meals saved in a single day!', '3 hrs ago', const Color(0xFF66BB6A)),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _gradientMetric(String value, String label, IconData icon, List<Color> colors, String badge) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: colors),
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        boxShadow: [BoxShadow(color: colors[0].withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: Colors.white.withValues(alpha: 0.85), size: 22),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(AppDimens.radiusFull)),
              child: Text(badge, style: AppTextStyles.caption.copyWith(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
            ),
          ]),
          const SizedBox(height: 14),
          Text(value, style: AppTextStyles.headlineMedium.copyWith(color: Colors.white, fontSize: 26)),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.caption.copyWith(color: Colors.white.withValues(alpha: 0.8))),
        ],
      ),
    );
  }

  static const _pieData = [
    {'day': 'Mon', 'count': 128, 'color': Color(0xFF1B5E20)},
    {'day': 'Tue', 'count': 171, 'color': Color(0xFF2E7D32)},
    {'day': 'Wed', 'count': 214, 'color': Color(0xFF388E3C)},
    {'day': 'Thu', 'count': 157, 'color': Color(0xFF43A047)},
    {'day': 'Fri', 'count': 256, 'color': Color(0xFF4CAF50)},
    {'day': 'Sat', 'count': 285, 'color': Color(0xFF66BB6A)},
    {'day': 'Sun', 'count': 199, 'color': Color(0xFF81C784)},
  ];

  Widget _buildPieChart() {
    final total = _pieData.fold<int>(0, (sum, d) => sum + (d['count'] as int));
    return Row(
      children: [
        // Pie chart
        Expanded(
          flex: 3,
          child: SizedBox(
            height: 180,
            child: MouseRegion(
              onHover: (event) {
                final box = context.findRenderObject() as RenderBox?;
                if (box == null) return;
                // Simple sector detection based on angle from center
                final center = Offset(box.size.width * 0.33, 90);
                final localPos = event.localPosition;
                final dx = localPos.dx - center.dx;
                final dy = localPos.dy - center.dy;
                final dist = sqrt(dx * dx + dy * dy);
                if (dist < 20 || dist > 80) { if (_hoveredBar != -1) setState(() => _hoveredBar = -1); return; }
                var angle = atan2(dy, dx);
                if (angle < -pi / 2) angle += 2 * pi;
                angle += pi / 2; // start from top
                if (angle > 2 * pi) angle -= 2 * pi;
                double cumulative = 0;
                for (int i = 0; i < _pieData.length; i++) {
                  cumulative += (_pieData[i]['count'] as int) / total * 2 * pi;
                  if (angle <= cumulative) { if (_hoveredBar != i) setState(() => _hoveredBar = i); return; }
                }
              },
              onExit: (_) => setState(() => _hoveredBar = -1),
              child: CustomPaint(
                painter: _PieChartPainter(
                  data: _pieData,
                  total: total,
                  hoveredIndex: _hoveredBar,
                ),
                child: Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(
                      _hoveredBar >= 0 ? '${_pieData[_hoveredBar]['count']}' : '$total',
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: _hoveredBar >= 0 ? (_pieData[_hoveredBar]['color'] as Color) : const Color(0xFF2E7D32),
                        fontSize: _hoveredBar >= 0 ? 22 : 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      _hoveredBar >= 0 ? '${_pieData[_hoveredBar]['day']}' : 'Total',
                      style: AppTextStyles.caption.copyWith(fontSize: 11, color: AppColors.textHint),
                    ),
                  ]),
                ),
              ),
            ),
          ),
        ),
        // Legend
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(_pieData.length, (i) {
              final d = _pieData[i];
              final isH = _hoveredBar == i;
              return GestureDetector(
                onTap: () => setState(() => _hoveredBar = _hoveredBar == i ? -1 : i),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(children: [
                    Container(
                      width: 10, height: 10,
                      decoration: BoxDecoration(
                        color: d['color'] as Color,
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: isH ? [BoxShadow(color: (d['color'] as Color).withValues(alpha: 0.4), blurRadius: 4)] : [],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${d['day']}', style: AppTextStyles.caption.copyWith(
                      fontSize: 11,
                      fontWeight: isH ? FontWeight.w700 : FontWeight.w400,
                      color: isH ? (d['color'] as Color) : AppColors.textHint,
                    )),
                    const Spacer(),
                    Text('${d['count']}', style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: isH ? FontWeight.w700 : FontWeight.w500,
                      color: isH ? (d['color'] as Color) : AppColors.textSecondary,
                    )),
                  ]),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _impactRow(String label, String value, double progress, Color color, String target) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Text(label, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w500)),
          const Spacer(),
          Text(value, style: AppTextStyles.titleMedium.copyWith(fontSize: 14, color: color)),
          const SizedBox(width: 6),
          Text(target, style: AppTextStyles.caption.copyWith(fontSize: 10)),
        ]),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimens.radiusFull),
          child: LinearProgressIndicator(value: progress, backgroundColor: color.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color), minHeight: 8),
        ),
      ],
    );
  }

  Widget _quickStat(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        boxShadow: AppShadows.soft,
      ),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(height: 8),
        Text(value, style: AppTextStyles.titleMedium.copyWith(fontSize: 15, color: color)),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.caption.copyWith(fontSize: 10)),
      ]),
    );
  }

  Widget _activityTile(IconData icon, String title, String subtitle, String time, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
        boxShadow: AppShadows.soft,
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [color, color.withValues(alpha: 0.7)]),
            borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: AppTextStyles.titleMedium.copyWith(fontSize: 13)),
          const SizedBox(height: 2),
          Text(subtitle, style: AppTextStyles.caption),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: AppColors.textHint.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(AppDimens.radiusFull)),
          child: Text(time, style: AppTextStyles.caption.copyWith(fontSize: 10)),
        ),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════
//  USER MANAGEMENT  (Fully Interactive)
// ═══════════════════════════════════════════════

class _UserData {
  String name;
  String email;
  String role;
  String joined;
  int orders;
  bool isSuspended;
  _UserData({required this.name, required this.email, required this.role, required this.joined, required this.orders, this.isSuspended = false});
}

class _UserManagementScreen extends StatefulWidget {
  const _UserManagementScreen();

  @override
  State<_UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<_UserManagementScreen> {
  final _searchCtrl = TextEditingController();
  String _filterMode = 'All';

  final List<_UserData> _users = [
    _UserData(name: 'Alex Johnson', email: 'alex.j@email.com', role: 'Buyer', joined: 'Jan 2026', orders: 12),
    _UserData(name: 'Priya Sharma', email: 'priya.s@email.com', role: 'Buyer', joined: 'Feb 2026', orders: 5),
    _UserData(name: 'Rahul Kumar', email: 'rahul.k@email.com', role: 'Buyer', joined: 'Dec 2025', orders: 0, isSuspended: true),
    _UserData(name: 'Sneha Menon', email: 'sneha.m@email.com', role: 'Buyer', joined: 'Jan 2026', orders: 8),
    _UserData(name: 'Arun Das', email: 'arun.d@email.com', role: 'Buyer', joined: 'Nov 2025', orders: 21),
    _UserData(name: 'Meera Roy', email: 'meera.r@email.com', role: 'Buyer', joined: 'Feb 2026', orders: 3),
    _UserData(name: 'Vikram Patil', email: 'vikram.p@email.com', role: 'Buyer', joined: 'Jan 2026', orders: 15),
    _UserData(name: 'Divya Nair', email: 'divya.n@email.com', role: 'Buyer', joined: 'Dec 2025', orders: 9, isSuspended: true),
  ];

  List<_UserData> get _filteredUsers {
    final query = _searchCtrl.text.trim().toLowerCase();
    return _users.where((u) {
      final matchesSearch = query.isEmpty || u.name.toLowerCase().contains(query) || u.email.toLowerCase().contains(query);
      final matchesFilter = _filterMode == 'All' || (_filterMode == 'Active' && !u.isSuspended) || (_filterMode == 'Suspended' && u.isSuspended);
      return matchesSearch && matchesFilter;
    }).toList();
  }

  int get _activeCount => _users.where((u) => !u.isSuspended).length;
  int get _suspendedCount => _users.where((u) => u.isSuspended).length;

  void _toggleSuspend(_UserData user) {
    final action = user.isSuspended ? 'reactivate' : 'suspend';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusCard)),
        title: Text('${user.isSuspended ? 'Reactivate' : 'Suspend'} User'),
        content: Text('Are you sure you want to $action ${user.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() => user.isSuspended = !user.isSuspended);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('${user.name} has been ${user.isSuspended ? 'suspended' : 'reactivated'}',
                    style: AppTextStyles.bodySmall.copyWith(color: Colors.white)),
                backgroundColor: const Color(0xFF2E7D32),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusMedium)),
              ));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: user.isSuspended ? const Color(0xFF2E7D32) : AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusMedium)),
            ),
            child: Text(user.isSuspended ? 'Reactivate' : 'Suspend'),
          ),
        ],
      ),
    );
  }

  void _viewUser(_UserData user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: user.isSuspended ? [Colors.grey.shade400, Colors.grey.shade300] : [const Color(0xFF2E7D32), const Color(0xFF66BB6A)]),
                shape: BoxShape.circle,
              ),
              child: Center(child: Text(user.name[0], style: AppTextStyles.headlineLarge.copyWith(color: Colors.white))),
            ),
            const SizedBox(height: 16),
            Text(user.name, style: AppTextStyles.headlineSmall),
            const SizedBox(height: 4),
            Text(user.email, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            StatusBadge(status: user.isSuspended ? BadgeStatus.suspended : BadgeStatus.active),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFF2E7D32).withValues(alpha: 0.05), borderRadius: BorderRadius.circular(AppDimens.radiusCard)),
              child: Column(children: [
                _detailRow(Icons.person_outline, 'Role', user.role),
                const Divider(height: 20),
                _detailRow(Icons.calendar_today, 'Joined', user.joined),
                const Divider(height: 20),
                _detailRow(Icons.shopping_bag_outlined, 'Total Orders', '${user.orders}'),
                const Divider(height: 20),
                _detailRow(Icons.star_outline, 'Avg Rating', '4.${(user.name.length % 5) + 3}'),
                const Divider(height: 20),
                _detailRow(Icons.location_on_outlined, 'City', 'Bengaluru'),
              ]),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () { Navigator.pop(ctx); _toggleSuspend(user); },
                icon: Icon(user.isSuspended ? Icons.check_circle_outline : Icons.block, size: 18),
                label: Text(user.isSuspended ? 'Reactivate User' : 'Suspend User'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: user.isSuspended ? const Color(0xFF2E7D32) : AppColors.error,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusMedium)),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(children: [
      Icon(icon, size: 18, color: const Color(0xFF43A047)),
      const SizedBox(width: 12),
      Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
      const Spacer(),
      Text(value, style: AppTextStyles.titleMedium.copyWith(fontSize: 14)),
    ]);
  }

  void _cycleFilter() {
    setState(() {
      if (_filterMode == 'All') _filterMode = 'Active';
      else if (_filterMode == 'Active') _filterMode = 'Suspended';
      else _filterMode = 'All';
    });
  }

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredUsers;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Header + Search (pinned) ──
          Padding(
            padding: const EdgeInsets.fromLTRB(AppDimens.paddingL, AppDimens.paddingL, AppDimens.paddingL, 0),
            child: Column(children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF43A047)],
                  ),
                  borderRadius: BorderRadius.circular(AppDimens.radiusCard),
                  boxShadow: [BoxShadow(color: const Color(0xFF2E7D32).withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 6))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.people, color: Colors.white, size: 24),
                      const SizedBox(width: 10),
                      Text('User Management', style: AppTextStyles.headlineSmall.copyWith(color: Colors.white)),
                    ]),
                    const SizedBox(height: 16),
                    Row(children: [
                      _headerStat('${_users.length}', 'Total'),
                      _headerStat('$_activeCount', 'Active'),
                      _headerStat('$_suspendedCount', 'Suspended'),
                      _headerStat('${filtered.length}', 'Showing'),
                    ]),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppDimens.radiusCard),
                  boxShadow: AppShadows.soft,
                ),
                child: Row(children: [
                  const Icon(Icons.search, color: Color(0xFF43A047), size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Search users by name or email...',
                        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                  if (_searchCtrl.text.isNotEmpty)
                    GestureDetector(
                      onTap: () { _searchCtrl.clear(); setState(() {}); },
                      child: const Icon(Icons.close, size: 18, color: AppColors.textHint),
                    ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _cycleFilter,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                        border: Border.all(color: const Color(0xFF2E7D32).withValues(alpha: 0.2)),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.filter_list, size: 14, color: Color(0xFF2E7D32)),
                        const SizedBox(width: 4),
                        Text(_filterMode, style: AppTextStyles.caption.copyWith(color: const Color(0xFF2E7D32), fontWeight: FontWeight.w600)),
                      ]),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 14),
            ]),
          ),

          // ── Scrollable user list ──
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.search_off, size: 48, color: AppColors.textHint.withValues(alpha: 0.4)),
                      const SizedBox(height: 12),
                      Text('No users found', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint)),
                    ]),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingL),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) => _userCard(filtered[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _headerStat(String value, String label) {
    return Expanded(
      child: Column(children: [
        Text(value, style: AppTextStyles.headlineSmall.copyWith(color: Colors.white, fontSize: 20)),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.caption.copyWith(color: Colors.white70, fontSize: 11)),
      ]),
    );
  }

  Widget _userCard(_UserData user) {
    final green = user.isSuspended ? const Color(0xFF9E9E9E) : const Color(0xFF2E7D32);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        boxShadow: AppShadows.soft,
        border: user.isSuspended ? Border.all(color: AppColors.error.withValues(alpha: 0.15)) : null,
      ),
      child: Column(
        children: [
          Row(children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: user.isSuspended
                      ? [Colors.grey.shade400, Colors.grey.shade300]
                      : [const Color(0xFF2E7D32), const Color(0xFF66BB6A)],
                ),
                shape: BoxShape.circle,
              ),
              child: Center(child: Text(user.name[0], style: AppTextStyles.headlineSmall.copyWith(color: Colors.white, fontSize: 18))),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(user.name, style: AppTextStyles.titleMedium.copyWith(fontSize: 15)),
              const SizedBox(height: 2),
              Text(user.email, style: AppTextStyles.caption),
            ])),
            StatusBadge(status: user.isSuspended ? BadgeStatus.suspended : BadgeStatus.active),
          ]),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: green.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
            ),
            child: Row(children: [
              _infoChip(Icons.person_outline, user.role, green),
              const SizedBox(width: 12),
              _infoChip(Icons.calendar_today, 'Joined ${user.joined}', green),
              const Spacer(),
              _infoChip(Icons.shopping_bag_outlined, '${user.orders} orders', green),
            ]),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _viewUser(user),
                icon: Icon(Icons.visibility, size: 16, color: green),
                label: Text('View', style: AppTextStyles.bodySmall.copyWith(color: green, fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: green.withValues(alpha: 0.3)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusMedium)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: user.isSuspended
                  ? ElevatedButton.icon(
                      onPressed: () => _toggleSuspend(user),
                      icon: const Icon(Icons.check_circle_outline, size: 16),
                      label: Text('Reactivate', style: AppTextStyles.bodySmall.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusMedium)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    )
                  : OutlinedButton.icon(
                      onPressed: () => _toggleSuspend(user),
                      icon: const Icon(Icons.block, size: 16, color: AppColors.error),
                      label: Text('Suspend', style: AppTextStyles.bodySmall.copyWith(color: AppColors.error, fontWeight: FontWeight.w600)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.error.withValues(alpha: 0.3)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusMedium)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String text, Color color) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 13, color: color.withValues(alpha: 0.7)),
      const SizedBox(width: 4),
      Text(text, style: AppTextStyles.caption.copyWith(fontSize: 11, color: color.withValues(alpha: 0.8))),
    ]);
  }
}

// ═══════════════════════════════════════════════
//  PARTNER APPROVALS  (Premium Design)
// ═══════════════════════════════════════════════
class _PartnerApprovalScreen extends StatefulWidget {
  const _PartnerApprovalScreen();

  @override
  State<_PartnerApprovalScreen> createState() => _PartnerApprovalScreenState();
}

class _PartnerApprovalScreenState extends State<_PartnerApprovalScreen> {
  final List<_PartnerData> _partners = [
    _PartnerData('Curry House', 'Koramangala, Bengaluru', 'Indian Cuisine', 'pending', '4.2', '12', 'Feb 10'),
    _PartnerData('Bake My Day', 'HSR Layout, Bengaluru', 'Bakery & Desserts', 'pending', '4.5', '8', 'Feb 12'),
    _PartnerData('Wok Station', 'Whitefield, Bengaluru', 'Chinese & Thai', 'pending', '4.0', '15', 'Feb 14'),
    _PartnerData('Green Leaf Cafe', 'Indiranagar, Bengaluru', 'Vegan & Healthy', 'approved', '4.7', '45', 'Jan 5'),
    _PartnerData('Morning Bites', 'MG Road, Bengaluru', 'Breakfast & Brunch', 'approved', '4.3', '32', 'Jan 15'),
    _PartnerData('Sakura House', 'JP Nagar, Bengaluru', 'Japanese & Sushi', 'approved', '4.8', '28', 'Dec 20'),
  ];

  int get _pendingCount => _partners.where((p) => p.status == 'pending').length;
  int get _approvedCount => _partners.where((p) => p.status == 'approved').length;
  int get _rejectedCount => _partners.where((p) => p.status == 'rejected').length;

  void _approvePartner(_PartnerData partner) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: const Color(0xFF2E7D32).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 20),
        ),
        const SizedBox(width: 10),
        const Text('Approve Partner'),
      ]),
      content: Text('Approve "${partner.name}" to start listing on FoodLoop?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () { setState(() => partner.status = 'approved'); Navigator.pop(ctx);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('${partner.name} approved ✓'), backgroundColor: const Color(0xFF2E7D32),
              behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ));
          },
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
          child: const Text('Approve', style: TextStyle(color: Colors.white)),
        ),
      ],
    ));
  }

  void _rejectPartner(_PartnerData partner) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.cancel, color: AppColors.error, size: 20),
        ),
        const SizedBox(width: 10),
        const Text('Reject Partner'),
      ]),
      content: Text('Reject "${partner.name}"? They can reapply later.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () { setState(() => partner.status = 'rejected'); Navigator.pop(ctx);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('${partner.name} rejected'), backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ));
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
          child: const Text('Reject', style: TextStyle(color: Colors.white)),
        ),
      ],
    ));
  }

  void _viewPartner(_PartnerData p) {
    showModalBottomSheet(context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.65, minChildSize: 0.4, maxChildSize: 0.85, expand: false,
        builder: (_, scrollCtrl) => ListView(controller: scrollCtrl, padding: const EdgeInsets.all(24), children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),
          Center(child: Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)]),
              shape: BoxShape.circle,
            ),
            child: const Center(child: Icon(Icons.storefront, color: Colors.white, size: 32)),
          )),
          const SizedBox(height: 14),
          Center(child: Text(p.name, style: AppTextStyles.headlineSmall)),
          const SizedBox(height: 4),
          Center(child: Text(p.location, style: AppTextStyles.caption)),
          const SizedBox(height: 8),
          Center(child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(color: const Color(0xFF2E7D32).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
            child: Text(p.type, style: AppTextStyles.bodySmall.copyWith(color: const Color(0xFF2E7D32), fontWeight: FontWeight.w600)),
          )),
          const SizedBox(height: 24),
          _detailRow(Icons.star, 'Rating', '${p.rating} / 5.0'),
          _detailRow(Icons.restaurant_menu, 'Total Offers', p.totalOffers),
          _detailRow(Icons.calendar_today, 'Applied', p.appliedDate),
          _detailRow(Icons.verified, 'Status', p.status[0].toUpperCase() + p.status.substring(1)),
        ]),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: const Color(0xFF2E7D32).withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 18, color: const Color(0xFF2E7D32)),
        ),
        const SizedBox(width: 14),
        Expanded(child: Text(label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint))),
        Text(value, style: AppTextStyles.titleMedium.copyWith(fontSize: 14)),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pending = _partners.where((p) => p.status == 'pending').toList();
    final approved = _partners.where((p) => p.status == 'approved').toList();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView(
        padding: const EdgeInsets.all(AppDimens.paddingL),
        children: [
          // ── Gradient header ──
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF43A047)],
              ),
              borderRadius: BorderRadius.circular(AppDimens.radiusCard),
              boxShadow: [BoxShadow(color: const Color(0xFF2E7D32).withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 6))],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.storefront, color: Colors.white, size: 24),
                const SizedBox(width: 10),
                Text('Partner Management', style: AppTextStyles.headlineSmall.copyWith(color: Colors.white)),
              ]),
              const SizedBox(height: 16),
              Row(children: [
                _pHeaderStat('${_partners.length}', 'Total'),
                _pHeaderStat('$_pendingCount', 'Pending'),
                _pHeaderStat('$_approvedCount', 'Approved'),
                _pHeaderStat('$_rejectedCount', 'Rejected'),
              ]),
            ]),
          ),
          const SizedBox(height: 20),

          // ── Pending section ──
          if (pending.isNotEmpty) ...[
            Row(children: [
              Container(width: 4, height: 20, decoration: BoxDecoration(color: const Color(0xFFFFA000), borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 10),
              Text('Pending Approvals', style: AppTextStyles.titleMedium.copyWith(fontSize: 16)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFFFA000).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                child: Text('${pending.length}', style: AppTextStyles.bodySmall.copyWith(color: const Color(0xFFFFA000), fontWeight: FontWeight.w700)),
              ),
            ]),
            const SizedBox(height: 12),
            ...pending.map((p) => _partnerCard(p, true)),
            const SizedBox(height: 24),
          ],

          // ── Approved section ──
          if (approved.isNotEmpty) ...[
            Row(children: [
              Container(width: 4, height: 20, decoration: BoxDecoration(color: const Color(0xFF2E7D32), borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 10),
              Text('Approved Partners', style: AppTextStyles.titleMedium.copyWith(fontSize: 16)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFF2E7D32).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                child: Text('${approved.length}', style: AppTextStyles.bodySmall.copyWith(color: const Color(0xFF2E7D32), fontWeight: FontWeight.w700)),
              ),
            ]),
            const SizedBox(height: 12),
            ...approved.map((p) => _partnerCard(p, false)),
          ],
        ],
      ),
    );
  }

  Widget _pHeaderStat(String value, String label) {
    return Expanded(child: Column(children: [
      Text(value, style: AppTextStyles.headlineSmall.copyWith(color: Colors.white, fontSize: 20)),
      const SizedBox(height: 2),
      Text(label, style: AppTextStyles.caption.copyWith(color: Colors.white70, fontSize: 11)),
    ]));
  }

  Widget _partnerCard(_PartnerData p, bool showActions) {
    final isPending = p.status == 'pending';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        boxShadow: AppShadows.soft,
        border: isPending ? Border.all(color: const Color(0xFFFFA000).withValues(alpha: 0.2)) : null,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: isPending
                  ? [const Color(0xFFFFA000), const Color(0xFFFFCA28)]
                  : [const Color(0xFF2E7D32), const Color(0xFF66BB6A)]),
              shape: BoxShape.circle,
            ),
            child: Center(child: Text(p.name[0], style: AppTextStyles.headlineSmall.copyWith(color: Colors.white, fontSize: 18))),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(p.name, style: AppTextStyles.titleMedium.copyWith(fontSize: 15)),
            const SizedBox(height: 2),
            Row(children: [
              Icon(Icons.location_on, size: 12, color: AppColors.textHint.withValues(alpha: 0.6)),
              const SizedBox(width: 3),
              Expanded(child: Text(p.location, style: AppTextStyles.caption, overflow: TextOverflow.ellipsis)),
            ]),
          ])),
          StatusBadge(status: isPending ? BadgeStatus.pending : BadgeStatus.active),
        ]),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF2E7D32).withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
          ),
          child: Row(children: [
            _pInfoChip(Icons.restaurant_menu, p.type),
            const Spacer(),
            _pInfoChip(Icons.star, '${p.rating} ★'),
            const SizedBox(width: 12),
            _pInfoChip(Icons.local_offer, '${p.totalOffers} offers'),
          ]),
        ),
        if (showActions) ...[
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: OutlinedButton.icon(
              onPressed: () => _viewPartner(p),
              icon: const Icon(Icons.visibility, size: 16, color: Color(0xFF2E7D32)),
              label: Text('View', style: AppTextStyles.bodySmall.copyWith(color: const Color(0xFF2E7D32), fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: const Color(0xFF2E7D32).withValues(alpha: 0.3)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusMedium)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            )),
            const SizedBox(width: 8),
            Expanded(child: OutlinedButton.icon(
              onPressed: () => _rejectPartner(p),
              icon: const Icon(Icons.close, size: 16, color: AppColors.error),
              label: Text('Reject', style: AppTextStyles.bodySmall.copyWith(color: AppColors.error, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.error.withValues(alpha: 0.3)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusMedium)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            )),
            const SizedBox(width: 8),
            Expanded(child: ElevatedButton.icon(
              onPressed: () => _approvePartner(p),
              icon: const Icon(Icons.check, size: 16),
              label: Text('Approve', style: AppTextStyles.bodySmall.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusMedium)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            )),
          ]),
        ] else ...[
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _viewPartner(p),
            child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              Text('View Details', style: AppTextStyles.bodySmall.copyWith(color: const Color(0xFF2E7D32), fontWeight: FontWeight.w600)),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_forward_ios, size: 12, color: Color(0xFF2E7D32)),
            ]),
          ),
        ],
      ]),
    );
  }

  Widget _pInfoChip(IconData icon, String text) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 13, color: const Color(0xFF2E7D32).withValues(alpha: 0.6)),
      const SizedBox(width: 4),
      Text(text, style: AppTextStyles.caption.copyWith(fontSize: 11, color: const Color(0xFF2E7D32).withValues(alpha: 0.8))),
    ]);
  }
}

class _PartnerData {
  String name, location, type, status, rating, totalOffers, appliedDate;
  _PartnerData(this.name, this.location, this.type, this.status, this.rating, this.totalOffers, this.appliedDate);
}

// ═══════════════════════════════════════════════
//  OFFER MONITORING  (Premium Design)
// ═══════════════════════════════════════════════
class _OfferMonitoringScreen extends StatefulWidget {
  const _OfferMonitoringScreen();

  @override
  State<_OfferMonitoringScreen> createState() => _OfferMonitoringScreenState();
}

class _OfferMonitoringScreenState extends State<_OfferMonitoringScreen> {
  final _searchCtrl = TextEditingController();
  String _filterMode = 'All';

  final List<_OfferData> _offers = [
    _OfferData('Vegan Bowl', 'Green Leaf Cafe', '₹89', 3, 'active', '5:00–7:00 PM', '4.5'),
    _OfferData('Pasta Delight', 'Italiano Express', '₹99', 5, 'active', '6:00–8:00 PM', '4.2'),
    _OfferData('Breakfast Bag', 'Morning Bites', '₹49', 0, 'soldOut', '7:00–9:00 AM', '4.7'),
    _OfferData('Sushi Pack', 'Sakura House', '₹130', 2, 'active', '12:00–2:00 PM', '4.8'),
    _OfferData('Smoothie Pack', 'Juice Corner', '₹45', 4, 'flagged', '3:00–5:00 PM', '3.9'),
    _OfferData('Curry Combo', 'Curry House', '₹75', 6, 'active', '7:00–9:00 PM', '4.1'),
    _OfferData('Bread Basket', 'Bake My Day', '₹55', 0, 'soldOut', '8:00–10:00 AM', '4.6'),
  ];

  void _cycleFilter() {
    setState(() {
      _filterMode = _filterMode == 'All' ? 'Active' : _filterMode == 'Active' ? 'Sold Out' : _filterMode == 'Sold Out' ? 'Flagged' : 'All';
    });
  }

  List<_OfferData> get _filtered {
    var list = _offers.where((o) {
      if (_filterMode == 'Active') return o.status == 'active';
      if (_filterMode == 'Sold Out') return o.status == 'soldOut';
      if (_filterMode == 'Flagged') return o.status == 'flagged';
      return true;
    }).toList();
    final q = _searchCtrl.text.toLowerCase();
    if (q.isNotEmpty) list = list.where((o) => o.name.toLowerCase().contains(q) || o.partner.toLowerCase().contains(q)).toList();
    return list;
  }

  BadgeStatus _badgeFor(String s) => s == 'active' ? BadgeStatus.active : s == 'soldOut' ? BadgeStatus.soldOut : BadgeStatus.suspended;

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final activeCount = _offers.where((o) => o.status == 'active').length;
    final soldOutCount = _offers.where((o) => o.status == 'soldOut').length;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(AppDimens.paddingL),
          child: Column(children: [
            // ── Gradient header ──
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF43A047)],
                ),
                borderRadius: BorderRadius.circular(AppDimens.radiusCard),
                boxShadow: [BoxShadow(color: const Color(0xFF2E7D32).withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 6))],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Icon(Icons.local_offer, color: Colors.white, size: 24),
                  const SizedBox(width: 10),
                  Text('Offer Monitoring', style: AppTextStyles.headlineSmall.copyWith(color: Colors.white)),
                ]),
                const SizedBox(height: 16),
                Row(children: [
                  _oHeaderStat('${_offers.length}', 'Total'),
                  _oHeaderStat('$activeCount', 'Active'),
                  _oHeaderStat('$soldOutCount', 'Sold Out'),
                  _oHeaderStat('${filtered.length}', 'Showing'),
                ]),
              ]),
            ),
            const SizedBox(height: 14),

            // ── Search bar ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimens.radiusCard),
                boxShadow: AppShadows.soft,
              ),
              child: Row(children: [
                const Icon(Icons.search, color: Color(0xFF43A047), size: 22),
                const SizedBox(width: 10),
                Expanded(child: TextField(
                  controller: _searchCtrl,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search offers or partners...',
                    hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
                    border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  style: AppTextStyles.bodyMedium,
                )),
                if (_searchCtrl.text.isNotEmpty)
                  GestureDetector(onTap: () { _searchCtrl.clear(); setState(() {}); }, child: const Icon(Icons.close, size: 18, color: AppColors.textHint)),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _cycleFilter,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                      border: Border.all(color: const Color(0xFF2E7D32).withValues(alpha: 0.2)),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.filter_list, size: 14, color: Color(0xFF2E7D32)),
                      const SizedBox(width: 4),
                      Text(_filterMode, style: AppTextStyles.caption.copyWith(color: const Color(0xFF2E7D32), fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 14),
          ]),
        ),

        // ── Offer list ──
        Expanded(
          child: filtered.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.search_off, size: 48, color: AppColors.textHint.withValues(alpha: 0.4)),
                  const SizedBox(height: 12),
                  Text('No offers found', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint)),
                ]))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingL),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => _offerCard(filtered[i]),
                ),
        ),
      ]),
    );
  }

  Widget _oHeaderStat(String value, String label) {
    return Expanded(child: Column(children: [
      Text(value, style: AppTextStyles.headlineSmall.copyWith(color: Colors.white, fontSize: 20)),
      const SizedBox(height: 2),
      Text(label, style: AppTextStyles.caption.copyWith(color: Colors.white70, fontSize: 11)),
    ]));
  }

  Widget _offerCard(_OfferData o) {
    final isSoldOut = o.status == 'soldOut';
    final isFlagged = o.status == 'flagged';
    final accent = isFlagged ? AppColors.error : isSoldOut ? const Color(0xFF9E9E9E) : const Color(0xFF2E7D32);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        boxShadow: AppShadows.soft,
        border: isFlagged ? Border.all(color: AppColors.error.withValues(alpha: 0.2)) : null,
      ),
      child: Column(children: [
        Row(children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: isSoldOut
                  ? [Colors.grey.shade400, Colors.grey.shade300]
                  : isFlagged
                      ? [AppColors.error.withValues(alpha: 0.8), AppColors.error.withValues(alpha: 0.5)]
                      : [const Color(0xFF2E7D32), const Color(0xFF66BB6A)]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Icon(Icons.restaurant, color: Colors.white, size: 22)),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(o.name, style: AppTextStyles.titleMedium.copyWith(fontSize: 15)),
            const SizedBox(height: 2),
            Text(o.partner, style: AppTextStyles.caption),
          ])),
          StatusBadge(status: _badgeFor(o.status)),
        ]),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: accent.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(AppDimens.radiusMedium)),
          child: Row(children: [
            _oInfoChip(Icons.attach_money, o.price, accent),
            const SizedBox(width: 14),
            _oInfoChip(Icons.inventory_2, isSoldOut ? 'Sold Out' : '${o.stock} left', accent),
            const Spacer(),
            _oInfoChip(Icons.access_time, o.pickupTime, accent),
          ]),
        ),
        const SizedBox(height: 10),
        Row(children: [
          Icon(Icons.star, size: 14, color: const Color(0xFFFFA000)),
          const SizedBox(width: 4),
          Text(o.rating, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)),
          const Spacer(),
          if (isFlagged) Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.flag, size: 12, color: AppColors.error),
              const SizedBox(width: 4),
              Text('Review Required', style: AppTextStyles.caption.copyWith(color: AppColors.error, fontWeight: FontWeight.w600, fontSize: 10)),
            ]),
          ),
        ]),
      ]),
    );
  }

  Widget _oInfoChip(IconData icon, String text, Color color) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 13, color: color.withValues(alpha: 0.6)),
      const SizedBox(width: 4),
      Text(text, style: AppTextStyles.caption.copyWith(fontSize: 11, color: color.withValues(alpha: 0.8))),
    ]);
  }
}

class _OfferData {
  String name, partner, price, status, pickupTime, rating;
  int stock;
  _OfferData(this.name, this.partner, this.price, this.stock, this.status, this.pickupTime, this.rating);
}

// ═══════════════════════════════════════════════
//  ANALYTICS  (Premium Design)
// ═══════════════════════════════════════════════
class _AnalyticsScreen extends StatefulWidget {
  const _AnalyticsScreen();

  @override
  State<_AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<_AnalyticsScreen> {
  int _hoveredAnalyticsBar = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView(
        padding: const EdgeInsets.all(AppDimens.paddingL),
        children: [
          // ── Gradient header ──
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF43A047)],
              ),
              borderRadius: BorderRadius.circular(AppDimens.radiusCard),
              boxShadow: [BoxShadow(color: const Color(0xFF2E7D32).withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 6))],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.analytics, color: Colors.white, size: 24),
                const SizedBox(width: 10),
                Text('Analytics Overview', style: AppTextStyles.headlineSmall.copyWith(color: Colors.white)),
              ]),
              const SizedBox(height: 16),
              Row(children: [
                _aHeaderStat('2,847', 'Meals Saved'),
                _aHeaderStat('1.2 T', 'CO₂ Reduced'),
                _aHeaderStat('₹4.2L', 'Money Saved'),
                _aHeaderStat('312', 'New Users'),
              ]),
            ]),
          ),
          const SizedBox(height: 20),

          // ── This Month Summary ──
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimens.radiusCard),
              boxShadow: AppShadows.soft,
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text('Monthly Impact', style: AppTextStyles.titleMedium.copyWith(fontSize: 16)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFF2E7D32).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: Text('Feb 2026', style: AppTextStyles.caption.copyWith(color: const Color(0xFF2E7D32), fontWeight: FontWeight.w600)),
                ),
              ]),
              const SizedBox(height: 16),
              Row(children: [
                _summaryCard('🍽️', 'Meals\nSaved', '2,847', const Color(0xFF2E7D32)),
                const SizedBox(width: 10),
                _summaryCard('🌿', 'CO₂\nReduced', '1.2 T', const Color(0xFF388E3C)),
                const SizedBox(width: 10),
                _summaryCard('💰', 'Money\nSaved', '₹4.2L', const Color(0xFF43A047)),
                const SizedBox(width: 10),
                _summaryCard('👥', 'New\nUsers', '312', const Color(0xFF66BB6A)),
              ]),
            ]),
          ),
          const SizedBox(height: 20),

          // ── Peak Pickup Times ──
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppDimens.radiusCard), boxShadow: AppShadows.soft),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text('Peak Pickup Times', style: AppTextStyles.titleMedium.copyWith(fontSize: 16)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFF2E7D32).withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.trending_up, size: 14, color: Color(0xFF2E7D32)),
                    const SizedBox(width: 4),
                    Text('This Week', style: AppTextStyles.caption.copyWith(color: const Color(0xFF2E7D32), fontWeight: FontWeight.w600)),
                  ]),
                ),
              ]),
              const SizedBox(height: 4),
              Text('Most popular hours for pickups', style: AppTextStyles.caption),
              const SizedBox(height: 16),
              _buildAnalyticsPieChart(),
            ]),
          ),
          const SizedBox(height: 20),

          // ── Popular Cuisines ──
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppDimens.radiusCard), boxShadow: AppShadows.soft),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text('Popular Cuisines', style: AppTextStyles.titleMedium.copyWith(fontSize: 16)),
                const Spacer(),
                Text('By reservations', style: AppTextStyles.caption),
              ]),
              const SizedBox(height: 20),
              _cuisineRow('Indian', 0.85, '340', const Color(0xFF1B5E20), Icons.restaurant),
              const SizedBox(height: 14),
              _cuisineRow('Vegan', 0.65, '260', const Color(0xFF2E7D32), Icons.eco),
              const SizedBox(height: 14),
              _cuisineRow('Italian', 0.50, '200', const Color(0xFF388E3C), Icons.local_pizza),
              const SizedBox(height: 14),
              _cuisineRow('Japanese', 0.35, '140', const Color(0xFF43A047), Icons.set_meal),
              const SizedBox(height: 14),
              _cuisineRow('Bakery', 0.25, '100', const Color(0xFF66BB6A), Icons.bakery_dining),
            ]),
          ),
          const SizedBox(height: 20),

          // ── Growth row ──
          Row(children: [
            Expanded(child: _growthCard('User Growth', '+18%', Icons.trending_up, const Color(0xFF2E7D32))),
            const SizedBox(width: 12),
            Expanded(child: _growthCard('Offer Growth', '+24%', Icons.local_offer, const Color(0xFF388E3C))),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _growthCard('Partner Growth', '+12%', Icons.storefront, const Color(0xFF43A047))),
            const SizedBox(width: 12),
            Expanded(child: _growthCard('Revenue', '+31%', Icons.attach_money, const Color(0xFF66BB6A))),
          ]),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _aHeaderStat(String value, String label) {
    return Expanded(child: Column(children: [
      Text(value, style: AppTextStyles.headlineSmall.copyWith(color: Colors.white, fontSize: 18)),
      const SizedBox(height: 2),
      Text(label, style: AppTextStyles.caption.copyWith(color: Colors.white70, fontSize: 10)),
    ]));
  }

  Widget _summaryCard(String emoji, String label, String value, Color color) {
    return Expanded(child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Column(children: [
        Text(emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 8),
        Text(value, style: AppTextStyles.titleMedium.copyWith(color: color, fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.caption.copyWith(fontSize: 10), textAlign: TextAlign.center),
      ]),
    ));
  }

  static const _analyticsPieData = [
    {'time': '7 AM', 'count': 42, 'color': Color(0xFF1B5E20)},
    {'time': '9 AM', 'count': 71, 'color': Color(0xFF2E7D32)},
    {'time': '12 PM', 'count': 121, 'color': Color(0xFF388E3C)},
    {'time': '2 PM', 'count': 85, 'color': Color(0xFF43A047)},
    {'time': '5 PM', 'count': 142, 'color': Color(0xFF4CAF50)},
    {'time': '7 PM', 'count': 128, 'color': Color(0xFF66BB6A)},
    {'time': '9 PM', 'count': 57, 'color': Color(0xFF81C784)},
  ];

  Widget _buildAnalyticsPieChart() {
    final total = _analyticsPieData.fold<int>(0, (sum, d) => sum + (d['count'] as int));
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: SizedBox(
            height: 180,
            child: MouseRegion(
              onHover: (event) {
                final box = context.findRenderObject() as RenderBox?;
                if (box == null) return;
                final center = Offset(box.size.width * 0.33, 90);
                final localPos = event.localPosition;
                final dx = localPos.dx - center.dx;
                final dy = localPos.dy - center.dy;
                final dist = sqrt(dx * dx + dy * dy);
                if (dist < 20 || dist > 80) { if (_hoveredAnalyticsBar != -1) setState(() => _hoveredAnalyticsBar = -1); return; }
                var angle = atan2(dy, dx);
                if (angle < -pi / 2) angle += 2 * pi;
                angle += pi / 2;
                if (angle > 2 * pi) angle -= 2 * pi;
                double cumulative = 0;
                for (int i = 0; i < _analyticsPieData.length; i++) {
                  cumulative += (_analyticsPieData[i]['count'] as int) / total * 2 * pi;
                  if (angle <= cumulative) { if (_hoveredAnalyticsBar != i) setState(() => _hoveredAnalyticsBar = i); return; }
                }
              },
              onExit: (_) => setState(() => _hoveredAnalyticsBar = -1),
              child: CustomPaint(
                painter: _PieChartPainter(
                  data: _analyticsPieData,
                  total: total,
                  hoveredIndex: _hoveredAnalyticsBar,
                ),
                child: Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(
                      _hoveredAnalyticsBar >= 0 ? '${_analyticsPieData[_hoveredAnalyticsBar]['count']}' : '$total',
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: _hoveredAnalyticsBar >= 0 ? (_analyticsPieData[_hoveredAnalyticsBar]['color'] as Color) : const Color(0xFF2E7D32),
                        fontSize: _hoveredAnalyticsBar >= 0 ? 22 : 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      _hoveredAnalyticsBar >= 0 ? '${_analyticsPieData[_hoveredAnalyticsBar]['time']}' : 'Pickups',
                      style: AppTextStyles.caption.copyWith(fontSize: 11, color: AppColors.textHint),
                    ),
                  ]),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(_analyticsPieData.length, (i) {
              final d = _analyticsPieData[i];
              final isH = _hoveredAnalyticsBar == i;
              return GestureDetector(
                onTap: () => setState(() => _hoveredAnalyticsBar = _hoveredAnalyticsBar == i ? -1 : i),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(children: [
                    Container(
                      width: 10, height: 10,
                      decoration: BoxDecoration(
                        color: d['color'] as Color,
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: isH ? [BoxShadow(color: (d['color'] as Color).withValues(alpha: 0.4), blurRadius: 4)] : [],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${d['time']}', style: AppTextStyles.caption.copyWith(
                      fontSize: 11,
                      fontWeight: isH ? FontWeight.w700 : FontWeight.w400,
                      color: isH ? (d['color'] as Color) : AppColors.textHint,
                    )),
                    const Spacer(),
                    Text('${d['count']}', style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: isH ? FontWeight.w700 : FontWeight.w500,
                      color: isH ? (d['color'] as Color) : AppColors.textSecondary,
                    )),
                  ]),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _cuisineRow(String name, double fill, String count, Color color, IconData icon) {
    return Row(children: [
      Container(
        width: 32, height: 32,
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 16, color: color),
      ),
      const SizedBox(width: 10),
      SizedBox(width: 60, child: Text(name, style: AppTextStyles.bodySmall.copyWith(fontSize: 12, fontWeight: FontWeight.w600))),
      Expanded(child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimens.radiusFull),
        child: LinearProgressIndicator(
          value: fill,
          backgroundColor: color.withValues(alpha: 0.08),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 10,
        ),
      )),
      const SizedBox(width: 10),
      SizedBox(width: 50, child: Text(count, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w700), textAlign: TextAlign.right)),
    ]);
  }

  Widget _growthCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        boxShadow: AppShadows.soft,
      ),
      child: Row(children: [
        Container(
          width: 42, height: 42,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.6)]),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: AppTextStyles.titleMedium.copyWith(color: color, fontSize: 18, fontWeight: FontWeight.w700)),
          Text(label, style: AppTextStyles.caption.copyWith(fontSize: 11)),
        ])),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════
//  PIE CHART PAINTER
// ═══════════════════════════════════════════════
class _PieChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final int total;
  final int hoveredIndex;

  _PieChartPainter({required this.data, required this.total, required this.hoveredIndex});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width < size.height ? size.width : size.height) / 2 - 10;
    final innerRadius = radius * 0.55;

    double startAngle = -pi / 2;

    for (int i = 0; i < data.length; i++) {
      final sweepAngle = (data[i]['count'] as int) / total * 2 * pi;
      final isHovered = hoveredIndex == i;
      final paint = Paint()
        ..color = (data[i]['color'] as Color).withValues(alpha: isHovered ? 1.0 : 0.85)
        ..style = PaintingStyle.fill;

      final midAngle = startAngle + sweepAngle / 2;
      final offset = isHovered ? Offset(cos(midAngle) * 6, sin(midAngle) * 6) : Offset.zero;
      final sliceCenter = center + offset;
      final outerR = isHovered ? radius + 4 : radius;

      final path = Path()
        ..moveTo(sliceCenter.dx + innerRadius * cos(startAngle), sliceCenter.dy + innerRadius * sin(startAngle))
        ..arcTo(Rect.fromCircle(center: sliceCenter, radius: outerR), startAngle, sweepAngle, false)
        ..arcTo(Rect.fromCircle(center: sliceCenter, radius: innerRadius), startAngle + sweepAngle, -sweepAngle, false)
        ..close();

      canvas.drawPath(path, paint);

      final gapPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawPath(path, gapPaint);

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) =>
    oldDelegate.hoveredIndex != hoveredIndex;
}
