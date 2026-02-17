import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
import '../data/app_data.dart';

// ═══════════════════════════════════════════════
//  MODELS & AI LOGIC
// ═══════════════════════════════════════════════

class BulkOrder {
  final String id;
  final String title;
  final String description;
  final String restaurant;
  final String imageUrl; // New field
  final double minBid;
  final int minUsers; // 5
  final int durationSeconds; // 90
  
  // Simulation State
  final ValueNotifier<int> userCount;
  final ValueNotifier<bool> isLocked; // Locked means bidding started
  final ValueNotifier<List<Bid>> bids;
  final ValueNotifier<int> timeRemaining; // Seconds
  final ValueNotifier<DateTime?> lastBidTime; 
  final ValueNotifier<int?> countdown; // 3, 2, 1, or null


  BulkOrder({
    required this.id,
    required this.title,
    required this.description,
    required this.restaurant,
    required this.imageUrl,
    required this.minBid,
    this.minUsers = 5,
    this.durationSeconds = 90,
  }) : 
    userCount = ValueNotifier(1), // User + others
    isLocked = ValueNotifier(false),
    bids = ValueNotifier([]),
    timeRemaining = ValueNotifier(durationSeconds),
    lastBidTime = ValueNotifier(null),
    countdown = ValueNotifier(null);
}

class Bid {
  final String userId;
  final String userName;
  final double amount;
  final DateTime timestamp;
  Bid(this.userId, this.userName, this.amount, this.timestamp);
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
  static final List<BulkOrder> _activeOrders = [];
  static final ValueNotifier<List<BulkOrder>> ordersNotifier = ValueNotifier([]);

  // Mock Data Initialization
  static void init() {
    if (_activeOrders.isEmpty) {
      createOrder('Corporate Lunch Pack', '50 servings of premium Biryani with sides.', 'Royal Spice', 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8', 2000);
      createOrder('Vegan Party Platter', 'Assorted vegan appetizers for 20 people.', 'Green Eats', 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd', 1500);
    }
  }

  static void createOrder(String title, String desc, String restaurant, String imageUrl, double minBid) {
    final order = BulkOrder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: desc,
      restaurant: restaurant,
      imageUrl: imageUrl,
      minBid: minBid,
    );
    _activeOrders.add(order);
    ordersNotifier.value = List.from(_activeOrders);
  }

  // Simulates users joining the lobby
  static void joinLobby(BulkOrder order) {
    if (order.isLocked.value) return;

    // Simulate random users joining every few seconds
    Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (order.userCount.value >= order.minUsers) {
        timer.cancel();
        _startAuction(order);
      } else {
        order.userCount.value++;
      }
    });
  }

  // Start the live auction
  static void _startAuction(BulkOrder order) {
    order.isLocked.value = true;
    
    // Start Timer
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (order.timeRemaining.value <= 0 || (order.countdown.value == 0)) { // Stop if sold
        timer.cancel();
        order.countdown.value = 0; // Ensure sold state
        return;
      }

      order.timeRemaining.value--;
      
      final lastBid = order.lastBidTime.value ?? DateTime.now();
      final inactivitySecs = DateTime.now().difference(lastBid).inSeconds;
      
      bool startCountdown = order.timeRemaining.value <= 3 || inactivitySecs > 10;
      
      if (startCountdown) {
        if (order.countdown.value == null) {
           order.countdown.value = 3;
        } else if (order.countdown.value! > 0) {
           order.countdown.value = order.countdown.value! - 1;
        } else {
           // Sold
           timer.cancel();
           // End logic handled by UI observing countdown == 0
        }
      } else {
        if (order.countdown.value != null && order.timeRemaining.value > 3) {
            order.countdown.value = null;
        }
      }
    });

    // Start Bot Bidding
    Timer.periodic(const Duration(seconds: 4), (timer) {
      if (order.timeRemaining.value <= 0 || (order.countdown.value == 0)) { // Stop if sold
        timer.cancel();
        return;
      }
      
      // Random chance for a bot to bid
      if (Random().nextBool()) {
        double currentHigh = order.bids.value.isNotEmpty ? order.bids.value.first.amount : order.minBid;
        double increment = (Random().nextInt(5) + 1) * 10.0;
        double newBid = currentHigh + increment;
        
        List<String> botNames = ['Alice', 'Bob', 'Charlie', 'Dave', 'Eve'];
        String botName = botNames[Random().nextInt(botNames.length)];

        addBid(order, 'bot', botName, newBid);
      }
    });
  }

  static void addBid(BulkOrder order, String userId, String userName, double amount) {
    final newBid = Bid(userId, userName, amount, DateTime.now());
    // Insert at top (highest bid)
    order.bids.value = [newBid, ...order.bids.value]; 
    order.lastBidTime.value = DateTime.now();

    // Reset countdown (inactivity timer) ONLY if main timer is not running out (<3s)
    if (order.timeRemaining.value > 3) {
      order.countdown.value = null;
    }
    // If <3s, we do NOT reset countdown, and we do NOT extend time. Auction ends hard.
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
                  AuctionManager.createOrder(
                    _titleCtrl.text,
                    _descCtrl.text,
                    'My Restaurant', 
                    'https://images.unsplash.com/photo-1546069901-ba9599a7e63c', // Default image until upload logic added
                    double.tryParse(_priceCtrl.text) ?? 500,
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bulk Order Posted!')));
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
  @override
  void initState() {
    super.initState();
    AuctionManager.init(); // Ensure dummy data
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bulk Order Auctions'), backgroundColor: AppColors.primary, foregroundColor: Colors.white),
      body: ValueListenableBuilder<List<BulkOrder>>(
        valueListenable: AuctionManager.ordersNotifier,
        builder: (_, orders, __) {
          return ListView.builder(
            padding: const EdgeInsets.all(AppDimens.paddingL),
            itemCount: orders.length,
            itemBuilder: (_, i) => _AuctionCard(order: orders[i]),
          );
        },
      ),
    );
  }
}

class _AuctionCard extends StatelessWidget {
  final BulkOrder order;
  const _AuctionCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.warning.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: const Text('⚡ Auction', style: TextStyle(color: AppColors.warning, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
                const Spacer(),
                const Icon(Icons.people, size: 16, color: AppColors.textSecondary),
                ValueListenableBuilder<int>(
                  valueListenable: order.userCount,
                  builder: (_, count, __) => Text(' $count/${order.minUsers} joined', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                ),
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
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  AuctionManager.joinLobby(order);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => AuctionLobbyScreen(order: order)));
                },
                child: const Text('Join Lobby', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AuctionLobbyScreen extends StatelessWidget {
  final BulkOrder order;
  const AuctionLobbyScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: order.isLocked,
      builder: (_, isLocked, __) {
        if (isLocked) {
          // If locked/started, show LIVE SCREEN
          return LiveAuctionScreen(order: order);
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
                  valueListenable: order.userCount,
                  builder: (_, count, __) => Text(
                    '$count / ${order.minUsers}',
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

    AuctionManager.addBid(widget.order, 'user', 'You', amount);
    _amountCtrl.clear();
    FocusScope.of(context).unfocus(); // Dismiss keyboard
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bid Placed!'), backgroundColor: Colors.green),
    );
  }

  bool _reservationAdded = false;

  @override
  void initState() {
    super.initState();
    widget.order.countdown.addListener(_onCountdownChanged);
  }

  @override
  void dispose() {
    widget.order.countdown.removeListener(_onCountdownChanged);
    _amountCtrl.dispose();
    super.dispose();
  }

  void _onCountdownChanged() {
    if (widget.order.countdown.value == 0 && !_reservationAdded) {
       final bids = widget.order.bids.value;
       if (bids.isNotEmpty && bids.first.userId == 'user') {
         _reservationAdded = true;
         // Add to reservations
         final wonOffer = Offer(
           title: widget.order.title,
           restaurant: widget.order.restaurant,
           price: '₹${bids.first.amount.toInt()}',
           distance: '2.5 km', // Simulation
           pickupTime: 'Today, 8-9 PM',
           status: BadgeStatus.active,
           about: widget.order.description,
           imageUrl: widget.order.imageUrl,
         );
         BuyerData.addReservation(wonOffer);
         
         // Notify user they won (optional, but good UX)
         WidgetsBinding.instance.addPostFrameCallback((_) {
           if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
               const SnackBar(
                 content: Text('Congratulations! Order added to Reservations.'),
                 backgroundColor: AppColors.primary,
                 duration: Duration(seconds: 4),
               ),
             );
           }
         });
       }
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

              // Product Info Card (New)
              ValueListenableBuilder<int?>(
                valueListenable: widget.order.countdown,
                builder: (_, count, __) {
                  if (count == 0) return const SizedBox.shrink(); // Hide if Sold

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
              ValueListenableBuilder<int?>(
                valueListenable: widget.order.countdown,
                builder: (_, count, __) {
                  final isSold = count == 0;
                  
                  if (isSold) {
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
                            ValueListenableBuilder<List<Bid>>(
                              valueListenable: widget.order.bids,
                              builder: (_, bids, __) {
                                final winner = bids.isNotEmpty ? bids.first.userName : 'No Bids';
                                final amount = bids.isNotEmpty ? bids.first.amount : widget.order.minBid;
                                return Container(
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
                                      Text('₹$amount', style: AppTextStyles.headlineLarge.copyWith(color: AppColors.success, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 32),
                            ElevatedButton.icon(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(Icons.check),
                              label: const Text('Close Auction'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.success,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
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
                                         AuctionManager.addBid(widget.order, 'user', 'You', amt);
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

          // Countdown Overlay (Only for "Going Once...")
          ValueListenableBuilder<int?>(
            valueListenable: widget.order.countdown,
            builder: (_, count, __) {
              if (count == null || count == 0) return const SizedBox.shrink(); // Don't show if Sold or Null
              
              return Container(
                color: Colors.black.withOpacity(0.7),
                child: Center(
                  child: Text(
                    'Going Once...\n$count',
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
