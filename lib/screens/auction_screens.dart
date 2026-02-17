import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';

// ═══════════════════════════════════════════════
//  MODELS & AI LOGIC
// ═══════════════════════════════════════════════

class BulkOrder {
  final String id;
  final String title;
  final String description;
  final String restaurant;
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
      createOrder('Corporate Lunch Pack', '50 servings of premium Biryani with sides.', 'Royal Spice', 2000);
      createOrder('Vegan Party Platter', 'Assorted vegan appetizers for 20 people.', 'Green Eats', 1500);
    }
  }

  static void createOrder(String title, String desc, String restaurant, double minBid) {
    final order = BulkOrder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: desc,
      restaurant: restaurant,
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
      if (order.timeRemaining.value <= 0) {
        timer.cancel();
        order.countdown.value = 0; // Sold
        return;
      }

      order.timeRemaining.value--;
      
      // Check Inactivity Logic (No bid for 10s)
      final lastBid = order.lastBidTime.value ?? DateTime.now(); // If no bids, use current time?
      final inactivitySecs = DateTime.now().difference(lastBid).inSeconds;
      
      // Countdown Logic:
      // If timeRemaining <= 3 OR inactivity > 10
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
        // Reset countdown if condition false (e.g. new bid reset inactivity)
        if (order.countdown.value != null && order.timeRemaining.value > 3) {
            order.countdown.value = null;
        }
      }
    });

    // Start Bot Bidding
    Timer.periodic(const Duration(seconds: 4), (timer) {
      if (order.timeRemaining.value <= 0) {
        timer.cancel();
        return;
      }
      
      // Random chance for a bot to bid
      if (Random().nextBool()) {
        double currentHigh = order.bids.value.isNotEmpty ? order.bids.value.first.amount : order.minBid;
        double increment = (Random().nextInt(5) + 1) * 10.0; // Random increment 10-50
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
    
    // Soft Close: Clear countdown and extend timer if needed
    order.countdown.value = null;
    
    // If timer is about to run out (or countdown active), ensure at least 10s
    if (order.timeRemaining.value < 10) {
      order.timeRemaining.value = 10;
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
                  AuctionManager.createOrder(
                    _titleCtrl.text,
                    _descCtrl.text,
                    'My Restaurant', // Should be dynamic
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
                  decoration: BoxDecoration(color: Colors.amber.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                  child: const Text('⚡ Auction', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
                const Spacer(),
                const Icon(Icons.people, size: 16, color: Colors.grey),
                ValueListenableBuilder<int>(
                  valueListenable: order.userCount,
                  builder: (_, count, __) => Text(' $count/${order.minUsers} joined', style: AppTextStyles.caption),
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
          appBar: AppBar(title: const Text('Waiting Room')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 24),
                ValueListenableBuilder<int>(
                  valueListenable: order.userCount,
                  builder: (_, count, __) => Text(
                    '$count / ${order.minUsers}',
                    style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ),
                const Text('Waiting for users...'),
                const SizedBox(height: 8),
                const Text('First Come First Serve!', style: TextStyle(color:  Colors.red)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔴 LIVE BIDDING'),
        backgroundColor: Colors.red,
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
                padding: const EdgeInsets.all(16),
                color: Colors.red.shade50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.timer, color: Colors.red),
                    const SizedBox(width: 8),
                    ValueListenableBuilder<int>(
                      valueListenable: widget.order.timeRemaining,
                      builder: (_, seconds, __) {
                        final mins = seconds ~/ 60;
                        final secs = seconds % 60;
                        return Text(
                          '$mins:${secs.toString().padLeft(2, '0')}',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red),
                        );
                      },
                    ),
                  ],
                ),
              ),

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
                        return ListTile(
                          leading: CircleAvatar(child: Text(bid.userName[0])),
                          title: Text(bid.userName),
                          trailing: Text(
                            '₹${bid.amount}',
                            style: TextStyle(
                              fontSize: isTop ? 20 : 16,
                              fontWeight: isTop ? FontWeight.bold : FontWeight.normal,
                              color: isTop ? Colors.green : Colors.black,
                            ),
                          ),
                          tileColor: isTop ? Colors.green.withOpacity(0.1) : null,
                        );
                      },
                    );
                  },
                ),
              ),

              // Bidding Area
              Container(
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
                          const Icon(Icons.auto_awesome, color: Colors.purple, size: 20),
                          const SizedBox(width: 8),
                          Text('AI Suggested Bids', style: AppTextStyles.titleMedium),
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
                                  label: Text('₹$amt'),
                                  avatar: const Icon(Icons.arrow_upward, size: 16),
                                  backgroundColor: Colors.purple.withOpacity(0.1),
                                  labelStyle: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold),
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
              ),
            ],
          ),

          // Countdown / Sold Overlay
          ValueListenableBuilder<int?>(
            valueListenable: widget.order.countdown,
            builder: (_, count, __) {
              if (count == null) return const SizedBox.shrink();
              
              final isSold = count == 0;
              final Color bgColor = isSold ? AppColors.success.withOpacity(0.9) : Colors.black.withOpacity(0.7);
              final String text = isSold ? 'SOLD!' : 'Going Once...\n$count';
              
              return Container(
                color: bgColor,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        text,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      if (isSold) ...[
                        const SizedBox(height: 16),
                        ValueListenableBuilder<List<Bid>>(
                          valueListenable: widget.order.bids,
                          builder: (_, bids, __) {
                             final winner = bids.isNotEmpty ? bids.first.userName : 'Unknown';
                             final amount = bids.isNotEmpty ? bids.first.amount : 0;
                             return Text(
                               'Winner: $winner\n₹$amount',
                               textAlign: TextAlign.center,
                               style: const TextStyle(fontSize: 24, color: Colors.white),
                             );
                          },
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white, 
                            foregroundColor: AppColors.success,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          ),
                          child: const Text('Close Auction'),
                        ),
                      ],
                    ],
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
