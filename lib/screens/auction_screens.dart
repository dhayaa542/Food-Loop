import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
import '../data/app_data.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../services/partner_provider.dart';
import 'payment_screen.dart';
import '../services/buyer_provider.dart';

// ═══════════════════════════════════════════════
//  MODELS & AI LOGIC
// ═══════════════════════════════════════════════

class BulkOrder {
  final String id;
  final String title;
  final String description;
  final String restaurant;
  final int partnerId; // Added partnerId
  final String imageUrl;
  final double minBid;
  final int minUsers = 3; // Default 3
  final int durationSeconds; 
  // Simulation State
  final ValueNotifier<int> userCount;
  final ValueNotifier<bool> isLocked; // Locked means bidding started
  final ValueNotifier<List<Bid>> bids;
  final ValueNotifier<int> timeRemaining; // Seconds
  final ValueNotifier<DateTime?> lastBidTime; 
  final ValueNotifier<int?> countdown; // 3, 2, 1, or null
  final String status;

  BulkOrder({
    required this.id,
    required this.title,
    required this.description,
    required this.restaurant,
    required this.partnerId,
    required this.imageUrl,
    required this.minBid,
    this.durationSeconds = 60,
    this.status = 'Active',
  }) : 
    userCount = ValueNotifier(1), 
    isLocked = ValueNotifier(false),
    bids = ValueNotifier([]),
    timeRemaining = ValueNotifier(60), // Default duration
    lastBidTime = ValueNotifier(DateTime.now()), 
    countdown = ValueNotifier(null);

  factory BulkOrder.fromJson(Map<String, dynamic> json) {
    return BulkOrder(
      id: json['id'].toString(),
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? 'No Description',
      restaurant: json['Partner']?['businessName'] ?? 'Unknown Restaurant',
      partnerId: json['partnerId'] ?? 0, // Parse partnerId
      imageUrl: json['imageUrl'] ?? 'https://via.placeholder.com/150',
      minBid: double.tryParse(json['price'].toString()) ?? 0.0,
      status: json['status'] ?? 'Active',
    );
  }
}

class Bid {
  final String userId;
  final String userName;
  final double amount;
  final DateTime timestamp;
  Bid(this.userId, this.userName, this.amount, this.timestamp);

  factory Bid.fromJson(Map<String, dynamic> json) {
    return Bid(
      json['userId'].toString(),
      json['User']?['name'] ?? 'Unknown',
      double.tryParse(json['amount'].toString()) ?? 0.0,
      DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}

/// "AI Model" that suggests optimal bid amounts based on current velocity and spread.
class SmartBidSuggester {
  static List<double> suggestBids(double currentHigh, double minBid) {
    if (currentHigh == 0) currentHigh = minBid;
    
    // Heuristic: Suggest +5%, +10%, +15% rounded to nearest 10
    double base = currentHigh;
    
    // Add small randomization to simulate "AI Analysis"
    // In a real model, this would use historical win rates.
    
    double low = _roundToTen(base * 1.05);
    double mid = _roundToTen(base * 1.10);
    double high = _roundToTen(base * 1.20);

    if (low <= base) low = base + 10;
    if (mid <= low) mid = low + 10;
    if (high <= mid) high = mid + 10;

    return [low, mid, high];
  }

  static double _roundToTen(double value) {
    return (value / 10).ceil() * 10.0;
  }
}

// ═══════════════════════════════════════════════
//  AUCTION MANAGER (SIMULATION ENGINE)
// ═══════════════════════════════════════════════

class AuctionManager {
  static final ValueNotifier<List<BulkOrder>> ordersNotifier = ValueNotifier([]);
  static final ValueNotifier<String> debugStatus = ValueNotifier('');

  // Fetch offers from backend
  static Future<void> fetchOffers(BuildContext context) async {
    try {
      debugStatus.value = 'Fetching...';
      final api = Provider.of<AuthProvider>(context, listen: false).api;
      debugStatus.value = 'Calling API...';
      final offersJson = await api.getAllOffers();
      debugStatus.value = 'Success: ${offersJson.length} items';
      
      List<BulkOrder> loadedOrders = [];
      for (var data in offersJson) {
        final order = BulkOrder.fromJson(data);
        // Optimization: Don't fetch bids for all 549 items sequentially!
        // It causes the UI to hang forever.
        // We will fetch bids only when entering the lobby or use a batch API later.
        /*
        try {
          final bidsJson = await api.getBids(int.parse(order.id));
          final List<Bid> fetchedBids = bidsJson.map((b) => Bid.fromJson(b)).toList();
          order.bids.value = fetchedBids;
          if (fetchedBids.isNotEmpty) {
             order.userCount.value = fetchedBids.map((b) => b.userId).toSet().length + 1; 
          }
        } catch (e) {
          print('Error fetching bids for ${order.id}: $e');
        }
        */
        loadedOrders.add(order);
      }
      
      ordersNotifier.value = loadedOrders;
    } catch (e, stack) {
      debugStatus.value = 'Error: $e';
      print('Error fetching offers: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load auctions: $e'), backgroundColor: Colors.red));
    }
  }

  // Refresh bids for a specific order (Polling)
  static Future<void> refreshBids(BuildContext context, BulkOrder order) async {
    try {
      final api = Provider.of<AuthProvider>(context, listen: false).api;
      final bidsJson = await api.getBids(int.parse(order.id));
      final List<Bid> fetchedBids = bidsJson.map((b) => Bid.fromJson(b)).toList();
      
      // Update data
      order.bids.value = fetchedBids;
      if (fetchedBids.isNotEmpty) {
          order.userCount.value = fetchedBids.map((b) => b.userId).toSet().length + 1;
          // order.lastBidTime.value = fetchedBids.first.timestamp; // Use local time for sync
          order.lastBidTime.value = DateTime.now(); // Reset inactivity on new bid
          order.countdown.value = null; // Reset countdown
      }
    } catch (e) {
      print('Error refreshing bids: $e');
    }
  }

  static Future<void> joinLobby(BuildContext context, BulkOrder order) async {
    try {
      final api = Provider.of<AuthProvider>(context, listen: false).api;
      final res = await api.joinAuctionLobby(int.parse(order.id));
      if (res.containsKey('count')) {
        order.userCount.value = res['count'];
      }
    } catch (e) {
      print('Error joining lobby: $e');
    }
  }

  static Future<void> refreshLobby(BuildContext context, BulkOrder order) async {
    try {
      final api = Provider.of<AuthProvider>(context, listen: false).api;
      final res = await api.getLobbyParticipantCount(int.parse(order.id));
      if (res.containsKey('count')) {
         order.userCount.value = res['count'];
      }
    } catch (e) {
      print('Error refreshing lobby: $e');
    }
  }

  // Place a bid
  static Future<bool> placeBid(BuildContext context, int offerId, double amount) async {
    try {
      final api = Provider.of<AuthProvider>(context, listen: false).api;
      await api.placeBid(offerId, amount);
      
      // Optimistic Update: Reset local inactivity immediately
      // We need to find the order in the list to update its notifier
      final orders = ordersNotifier.value;
      try {
        final order = orders.firstWhere((o) => o.id == offerId.toString());
        order.lastBidTime.value = DateTime.now();
        order.countdown.value = null;
      } catch (e) {
        // Order not found in list, ignore
      }
      
      return true;
    } catch (e) {
      print('Error placing bid: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to bid: $e')));
      return false;
    }
  }
  // Start local auction timer
  static void startLocalAuction(BulkOrder order) {
    if (order.isLocked.value) return; // Already started
    
    order.isLocked.value = true;
    order.lastBidTime.value = DateTime.now(); // Reset on start
    order.timeRemaining.value = order.durationSeconds; // Ensure full duration

    // Start Timer to decrement timeRemaining
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (order.timeRemaining.value > 0) {
        order.timeRemaining.value--;
        
        // Inactivity Check
        final lastActivity = order.lastBidTime.value ?? DateTime.now();
        final inactivitySeconds = DateTime.now().difference(lastActivity).inSeconds;
        
        if (inactivitySeconds >= 10) {
           // Start Countdown if not already
           if (order.countdown.value == null) {
             order.countdown.value = 3;
           } else {
             if (order.countdown.value! > 1) {
               order.countdown.value = order.countdown.value! - 1;
             } else {
               // End Auction & RESET
               timer.cancel();
               _resetAuction(order);
             }
           }
        } else {
          order.countdown.value = null;
        }

      } else {
        // Time expired -> Reset
        timer.cancel();
        _resetAuction(order);
      }
    });
  }

  static void _resetAuction(BulkOrder order) {
     // Reset Logic as per user request: "refresh user count to 0 and start from first"
     // We set userCount to 0 (or 1 if current user stays?). 
     // Let's set to 0 to force "Waiting for users..." state clearly.
     // Also unlock so it goes back to Lobby.
     
     Future.delayed(const Duration(seconds: 2), () {
        order.isLocked.value = false;
        order.userCount.value = 0; 
        order.bids.value = [];
        order.timeRemaining.value = order.durationSeconds;
        order.countdown.value = null;
        order.lastBidTime.value = DateTime.now();
     });
  }

  // Post a new bulk order (Auction)
  static Future<bool> postBulkOrder(BuildContext context, String title, String description, double minBid) async {
    try {
      final api = Provider.of<AuthProvider>(context, listen: false).api;
      await api.createOffer({
        'title': title,
        'description': description,
        'price': minBid,
        'imageUrl': 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c', // Default or allow upload
        // Backend handles partnerId from token
        'status': 'Active', 
      });
      return true;
    } catch (e) {
      print('Error posting order: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to post: $e')));
      return false;
    }
  }
}

// ═══════════════════════════════════════════════
//  UI: PARTNER UPLOAD
// ═══════════════════════════════════════════════

class BulkOrderUploadScreen extends StatefulWidget {
  const BulkOrderUploadScreen({super.key});

  @override
  State<BulkOrderUploadScreen> createState() => _BulkOrderUploadScreenState();
}

class _BulkOrderUploadScreenState extends State<BulkOrderUploadScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Bulk Order')),
      body: Padding(
        padding: const EdgeInsets.all(AppDimens.paddingL),
        child: Column(
          children: [
            AppInputField(label: 'Order Title', hint: 'E.g. Lunch Pack', controller: _titleCtrl, prefixIcon: Icons.title),
            const SizedBox(height: 16),
            AppInputField(label: 'Description', hint: 'Describe the contents', controller: _descCtrl, prefixIcon: Icons.description),
            const SizedBox(height: 16),
            AppInputField(label: 'Minimum Bid Amount (₹)', hint: '500', controller: _priceCtrl, prefixIcon: Icons.attach_money, keyboardType: TextInputType.number),
            const SizedBox(height: 32),
            PrimaryButton(
              label: 'Post Auction',
              onPressed: () {
                if (_titleCtrl.text.isNotEmpty && _priceCtrl.text.isNotEmpty) {
                  AuctionManager.postBulkOrder(
                    context,
                    _titleCtrl.text,
                    _descCtrl.text,
                    double.tryParse(_priceCtrl.text) ?? 500,
                  ).then((success) {
                    if (success) {
                       // Correct navigation: Switch to Dashboard tab
                       context.read<PartnerProvider>().setTabIndex(0);
                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bulk Order Posted!')));
                       AuctionManager.fetchOffers(context); // Refresh list
                    }
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  UI: BUYER LIST & LOBBY
// ═══════════════════════════════════════════════

class BulkOrderListScreen extends StatefulWidget {
  const BulkOrderListScreen({super.key});

  @override
  State<BulkOrderListScreen> createState() => _BulkOrderListScreenState();
}

class _BulkOrderListScreenState extends State<BulkOrderListScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Fetch real data instead of init()
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await AuctionManager.fetchOffers(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bulk Order Auctions'), backgroundColor: AppColors.primary, foregroundColor: Colors.white),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDimens.paddingL),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search auctions...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadData,
              child: ValueListenableBuilder<List<BulkOrder>>(
                valueListenable: AuctionManager.ordersNotifier,
                builder: (_, orders, __) {
                  // Client-side filtering
                  final filteredOrders = orders.where((o) {
                    final title = o.title.toLowerCase();
                    final restaurant = o.restaurant.toLowerCase();
                    return title.contains(_searchQuery) || restaurant.contains(_searchQuery);
                  }).toList();

                  if (filteredOrders.isEmpty) {
                     return ListView(
                       children: [
                         SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                         Center(child: Text(orders.isEmpty ? 'No active auctions found.' : 'No matches found.', style: const TextStyle(color: Colors.grey))),
                         const SizedBox(height: 16),
                         Center(child: ElevatedButton(onPressed: _loadData, child: const Text('Refresh'))),
                         const SizedBox(height: 20),
                         Padding(
                           padding: const EdgeInsets.all(8.0),
                           child: ValueListenableBuilder<String>(
                             valueListenable: AuctionManager.debugStatus,
                             builder: (_, status, __) => Text('Debug: $status', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                           ),
                         ),
                       ],
                     );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingL),
                    itemCount: filteredOrders.length,
                    itemBuilder: (_, i) => _AuctionCard(order: filteredOrders[i]),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuctionCard extends StatelessWidget {
  final BulkOrder order;
  const _AuctionCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: order.userCount,
      builder: (_, count, __) {
        // Determine State
        final bool isSold = order.status == 'Sold Out' || order.status == 'Expired';
        final bool isFull = count >= order.minUsers;
        
        Color cardColor = Colors.white;
        Color borderColor = Colors.transparent;
        String statusText = '⚡ Auction';
        Color statusColor = AppColors.warning;
        Color statusBg = AppColors.warning.withOpacity(0.1);
        bool canJoin = true;

        if (isSold) {
          cardColor = Colors.red.shade50;
          borderColor = Colors.red.shade200;
          statusText = 'SOLD';
          statusColor = Colors.red;
          statusBg = Colors.red.withOpacity(0.1);
          canJoin = false;
        } else if (isFull) {
          cardColor = Colors.yellow.shade50;
          borderColor = Colors.orange.shade200;
          statusText = 'FULL';
          statusColor = Colors.orange.shade800;
          statusBg = Colors.orange.withOpacity(0.1);
          // canJoin = false; // User didn't explicitly say disable join for full, but implied it. 
          // "tell full". Usually full lobbies can't be joined.
          // For now let's keep it joinable (spectator?) or disable? 
          // "make it yellow and tell full". Let's assume join is still possible to spectate or bid if slot opens?
          // Actually, "Full" usually means you can't join. Let's disable for now to be safe, or just visual.
          // Let's keep join enabled but visual warning, as per "tell full".
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: borderColor, width: isSold || isFull ? 1.5 : 0),
          ),
          elevation: 4,
          color: cardColor,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(8)),
                      child: Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                    const Spacer(),
                    const Icon(Icons.people, size: 16, color: AppColors.textSecondary),
                    Text(' $count/${order.minUsers} joined', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(order.title, style: AppTextStyles.titleMedium.copyWith(fontSize: 18)),
                Text(order.restaurant, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                Text('Starts at ₹${order.minBid}', style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary)),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSold ? Colors.grey : AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: canJoin ? () {
                      AuctionManager.joinLobby(context, order);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => AuctionLobbyScreen(order: order)));
                    } : null,
                    child: Text(isSold ? 'Auction Closed' : 'Join Lobby', style: const TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class AuctionLobbyScreen extends StatefulWidget {
  final BulkOrder order;
  const AuctionLobbyScreen({super.key, required this.order});

  @override
  State<AuctionLobbyScreen> createState() => _AuctionLobbyScreenState();
}

class _AuctionLobbyScreenState extends State<AuctionLobbyScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Poll for participants
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      AuctionManager.refreshLobby(context, widget.order);
      // Check if we should start
      if (widget.order.userCount.value >= widget.order.minUsers) {
          AuctionManager.startLocalAuction(widget.order);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: widget.order.isLocked,
      builder: (_, isLocked, __) {
        if (isLocked) {
          // If locked/started, show LIVE SCREEN
          return LiveAuctionScreen(order: widget.order);
        }
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(title: const Text('Waiting Room'), backgroundColor: AppColors.primary, foregroundColor: Colors.white, centerTitle: true),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: AppColors.primary),
                const SizedBox(height: 24),
                ValueListenableBuilder<int>(
                  valueListenable: widget.order.userCount,
                  builder: (_, count, __) => Text(
                    '$count / ${widget.order.minUsers}',
                    style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ),
                Text('Waiting for users...', style: AppTextStyles.bodyMedium),
                const SizedBox(height: 8),
                Text('First Come First Serve!', style: AppTextStyles.labelLarge.copyWith(color: AppColors.orange, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════
//  UI: LIVE AUCTION
// ═══════════════════════════════════════════════

class LiveAuctionScreen extends StatefulWidget {
  final BulkOrder order;
  const LiveAuctionScreen({super.key, required this.order});

  @override
  State<LiveAuctionScreen> createState() => _LiveAuctionScreenState();
}

class _LiveAuctionScreenState extends State<LiveAuctionScreen> {
  final _amountCtrl = TextEditingController();

  void _submitBid() {
    final amount = double.tryParse(_amountCtrl.text);
    if (amount == null) return;

    final currentBids = widget.order.bids.value;
    final currentHigh = currentBids.isNotEmpty ? currentBids.first.amount : widget.order.minBid;

    if (amount <= currentHigh) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bid must be higher than ₹$currentHigh'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    AuctionManager.placeBid(context, int.parse(widget.order.id), amount).then((success) {
      if (success) {
        _amountCtrl.clear();
        FocusScope.of(context).unfocus();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bid Placed!'), backgroundColor: Colors.green),
        );
        AuctionManager.refreshBids(context, widget.order);
      }
    });
  }

  bool _reservationAdded = false;

  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    // Poll for new bids
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      AuctionManager.refreshBids(context, widget.order);
    });
    
    // Listen for end
    widget.order.timeRemaining.addListener(_onTimeChanged);
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    widget.order.timeRemaining.removeListener(_onTimeChanged);
    _amountCtrl.dispose();
    super.dispose();
  }

  void _onTimeChanged() {
    if (widget.order.timeRemaining.value <= 0 && !_reservationAdded) {
       // Logic handled by UI observing timeRemaining <= 0
       // We can trigger a rebuild or specific action if needed
       // For now, the ValueListenableBuilder in build() handles the "Sold" view.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('LIVE AUCTION', style: AppTextStyles.headlineSmall.copyWith(color: Colors.white, letterSpacing: 1.2)),
        backgroundColor: AppColors.primary,
        centerTitle: true,
        elevation: 0,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
               // Only user can leave? Or pop?
               Navigator.of(context).pop();
            },
            tooltip: 'Exit Auction',
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Timer Header
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  border: Border(bottom: BorderSide(color: AppColors.divider)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.timer_outlined, color: AppColors.primary),
                    const SizedBox(width: 8),
                    ValueListenableBuilder<int>(
                      valueListenable: widget.order.timeRemaining,
                      builder: (_, seconds, __) {
                        final mins = seconds ~/ 60;
                        final secs = seconds % 60;
                        
                        Color timerColor = AppColors.primary;
                        if (seconds <= 10) timerColor = AppColors.error;
                        else if (seconds <= 30) timerColor = AppColors.warning;

                        return Text(
                          '$mins:${secs.toString().padLeft(2, '0')}',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: timerColor),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Countdown Overlay
              ValueListenableBuilder<int?>(
                valueListenable: widget.order.countdown,
                builder: (_, count, __) {
                  if (count == null) return const SizedBox.shrink();
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    alignment: Alignment.center,
                    color: Colors.red.withOpacity(0.1),
                    child: Text(
                      'Ending in $count...',
                      style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: AppColors.error),
                    ),
                  );
                },
              ),

              // Product Info Card (New)
              ValueListenableBuilder<int>(
                valueListenable: widget.order.timeRemaining,
                builder: (_, time, __) {
                  if (time <= 0) return const SizedBox.shrink(); // Hide if Sold

                  return Container(
                    padding: const EdgeInsets.all(12),
                    color: Colors.white,
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            widget.order.imageUrl,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(width: 80, height: 80, color: Colors.grey.shade300, child: const Icon(Icons.fastfood)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.order.title, style: AppTextStyles.titleMedium),
                              const SizedBox(height: 4),
                              Text(widget.order.description, style: AppTextStyles.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.store, size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(widget.order.restaurant, style: AppTextStyles.bodySmall),
                                  const Spacer(),
                                  Text('Base Price: ₹${widget.order.minBid.toInt()}', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const Divider(height: 1),

              // Bid List
              Expanded(
                child: ValueListenableBuilder<List<Bid>>(
                  valueListenable: widget.order.bids,
                  builder: (_, bids, __) {
                    if (bids.isEmpty) return const Center(child: Text('No bids yet. Be the first!'));
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: bids.length,
                      itemBuilder: (_, i) {
                        final bid = bids[i];
                        final isTop = i == 0;
                        return Card(
                          elevation: isTop ? 2 : 0,
                          margin: const EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: isTop ? const BorderSide(color: AppColors.primary, width: 1.5) : BorderSide.none,
                          ),
                          color: isTop ? AppColors.primary.withOpacity(0.05) : Colors.white,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isTop ? AppColors.primary : Colors.grey.shade200,
                              foregroundColor: isTop ? Colors.white : Colors.grey.shade700,
                              child: Text(bid.userName[0]),
                            ),
                            title: Text(bid.userName, style: isTop ? AppTextStyles.titleMedium.copyWith(color: AppColors.primary) : AppTextStyles.bodyLarge),
                            trailing: Text(
                              '₹${bid.amount.toInt()}',
                              style: TextStyle(
                                fontSize: isTop ? 20 : 16,
                                fontWeight: isTop ? FontWeight.bold : FontWeight.w500,
                                color: isTop ? AppColors.primary : AppColors.textPrimary,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              // Bidding Area (Input OR Winner)
              ValueListenableBuilder<int>(
                valueListenable: widget.order.timeRemaining,
                builder: (_, time, __) {
                  final isSold = time <= 0;
                  
                  if (isSold) {
                    return ValueListenableBuilder<List<Bid>>(
                      valueListenable: widget.order.bids,
                      builder: (_, bids, __) {
                        final winner = bids.isNotEmpty ? bids.first.userName : 'No Bids';
                        final amount = bids.isNotEmpty ? bids.first.amount : widget.order.minBid;
                        
                        // Check if current user is winner
                        final currentUser = context.read<AuthProvider>().user;
                        final isWinner = bids.isNotEmpty && currentUser != null && bids.first.userId == currentUser['id'].toString();

                        return Container(
                          padding: const EdgeInsets.all(32),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5))],
                          ),
                          child: SafeArea(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '🎉 SOLD! 🎉',
                                  style: AppTextStyles.headlineLarge.copyWith(color: AppColors.success, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.success.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: AppColors.success.withOpacity(0.3)),
                                  ),
                                  child: Column(
                                    children: [
                                      Text('Winner', style: AppTextStyles.bodyMedium),
                                      Text(winner, style: AppTextStyles.headlineMedium.copyWith(fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 8),
                                      Text('Final Price', style: AppTextStyles.bodyMedium),
                                      Text('₹${amount.toInt()}', style: AppTextStyles.headlineLarge.copyWith(color: AppColors.success, fontWeight: FontWeight.bold)),
                                      if (isWinner) ...[
                                        const SizedBox(height: 12),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(color: AppColors.success, borderRadius: BorderRadius.circular(20)),
                                          child: const Text('You Won!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 32),
                                
                                if (isWinner)
                                  SizedBox(
                                    width: double.infinity,
                                    height: 54,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => PaymentScreen(
                                              amount: amount,
                                              onPaymentSuccess: () async {
                                                // Create Order
                                                final error = await context.read<BuyerProvider>().createOrder({
                                                  'partnerId': widget.order.partnerId,
                                                  'items': [
                                                    {'offerId': int.parse(widget.order.id), 'quantity': 1, 'price': amount}
                                                  ],
                                                  'totalAmount': amount
                                                });

                                                if (error == null && context.mounted) {
                                                  Navigator.pop(context); // Close Payment
                                                  Navigator.pop(context); // Close Auction
                                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Auction Paid & Order Created!'), backgroundColor: AppColors.success));
                                                } else if (context.mounted) {
                                                  Navigator.pop(context);
                                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Order Failed: $error'), backgroundColor: AppColors.error));
                                                }
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      child: const Text('Make Payment', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                                    ),
                                  )
                                else
                                  ElevatedButton.icon(
                                    onPressed: () => Navigator.of(context).pop(),
                                    icon: const Icon(Icons.check),
                                    label: const Text('Close Auction'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }

                  // Active Bidding Area
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5))],
                    ),
                    child: SafeArea(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Custom Bid Input (Native TextField)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.edit, color: Colors.grey, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    controller: _amountCtrl,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      hintText: 'Enter custom amount...',
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: _submitBid,
                                  icon: const Icon(Icons.send, color: AppColors.primary),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // AI Suggestions
                          Row(
                            children: [
                              Icon(Icons.auto_awesome, color: AppColors.primary.withOpacity(0.7), size: 18),
                              const SizedBox(width: 8),
                              Text('Quick Bid', style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ValueListenableBuilder<List<Bid>>(
                            valueListenable: widget.order.bids,
                            builder: (_, bids, __) {
                              double currentHigh = bids.isNotEmpty ? bids.first.amount : widget.order.minBid;
                              final suggestions = SmartBidSuggester.suggestBids(currentHigh, 10);
                              
                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: suggestions.map((amt) => Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: ActionChip(
                                      label: Text('₹${amt.toInt()}'),
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                                      avatar: Icon(Icons.arrow_upward, size: 14, color: AppColors.primary),
                                      backgroundColor: AppColors.primary.withOpacity(0.05),
                                      side: BorderSide(color: AppColors.primary.withOpacity(0.2)),
                                      labelStyle: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                                      onPressed: () {
                                         AuctionManager.placeBid(context, int.parse(widget.order.id), amt).then((success) {
                                            if (success) {
                                               AuctionManager.refreshBids(context, widget.order);
                                            }
                                         });
                                      },
                                    ),
                                  )).toList(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),

          // Countdown Overlay (Only for "Going Once...") - Removed in favor of simple time
          // We can optionally add it back based on time <= 3
          ValueListenableBuilder<int>(
             valueListenable: widget.order.timeRemaining,
             builder: (_, time, __) {
                if (time > 3 || time <= 0) return const SizedBox.shrink();
                return Container(
                color: Colors.black.withOpacity(0.7),
                child: Center(
                  child: Text(
                    'Ending in...\n$time',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              );
             },
          ),
        ],
      ),
    );
  }
}
