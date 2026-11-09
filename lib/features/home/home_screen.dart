import 'package:flutter/material.dart' hide Card;
import 'package:go_router/go_router.dart';
import '../../models/card.dart';
import '../../models/transaction.dart';
import '../../models/user.dart';
import '../../services/card_service.dart';
import '../../services/transaction_service.dart';
import '../../services/user_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _cardService = CardService();
  final _userService = UserService();
  final _transactionService = TransactionService();

  User? _user;
  List<Card> _cards = [];
  List<Transaction> _transactions = [];
  int _unreadNotifications = 3;
  bool _loading = true;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        _userService.getProfile(),
        _cardService.getCards(),
        _transactionService.getTransactions(limit: 5),
      ]);
      if (mounted) {
        setState(() {
          _user = results[0] as User?;
          _cards = results[1] as List<Card>;
          _transactions = results[2] as List<Transaction>;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(child: _buildHeader()),
          // Card
          SliverToBoxAdapter(child: _buildCardSection()),
          // Quick Actions Grid
          SliverToBoxAdapter(child: _buildActionsGrid()),
          // Recent Transactions
          SliverToBoxAdapter(child: _buildRecentTransactions()),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3B2F9F), Color(0xFF5B4FCF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            backgroundImage: _user?.avatarUrl != null
                ? NetworkImage(_user!.avatarUrl!)
                : null,
            child: _user?.avatarUrl == null
                ? const Icon(Icons.person, color: Color(0xFF3B2F9F))
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Hi,', style: TextStyle(color: Colors.white70, fontSize: 14)),
                Text(
                  _user?.fullName ?? 'User',
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 28),
                onPressed: () => context.push('/mail'),
              ),
              if (_unreadNotifications > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '$_unreadNotifications',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardSection() {
    return Container(
      margin: const EdgeInsets.all(20),
      height: 220,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A4E), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: const Color(0xFF3B2F9F).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Stack(
        children: [
          Positioned(right: -40, top: -40, child: Container(width: 200, height: 200, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.1)))),
          Positioned(right: 40, bottom: -20, child: Container(width: 100, height: 100, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.1)))),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_user?.fullName ?? 'John Smith', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('Amazon Platinium', style: TextStyle(color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 16),
                    Text(
                      _cards.isNotEmpty ? '4756 •••• •••• ${_cards.first.last4Digits ?? '9018'}' : '4756 •••• •••• 9018',
                      style: const TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 2),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _cards.isNotEmpty ? '\$${_cards.first.balance.toStringAsFixed(2)}' : '\$3,469.52',
                      style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const Text('VISA', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsGrid() {
    final actions = [
      {'icon': Icons.credit_card, 'label': 'Account\nand Card', 'color': const Color(0xFF3B2F9F), 'route': '/account'},
      {'icon': Icons.compare_arrows, 'label': 'Transfer', 'color': const Color(0xFFE91E63), 'route': '/transfer'},
      {'icon': Icons.account_balance, 'label': 'Withdraw', 'color': const Color(0xFF00BCD4), 'route': '/withdraw'},
      {'icon': Icons.phone_android, 'label': 'Mobile\nprepaid', 'color': const Color(0xFFFF9800), 'route': '/mobile-prepaid'},
      {'icon': Icons.receipt_long, 'label': 'Pay the\nbill', 'color': const Color(0xFF4CAF50), 'route': '/pay-bill'},
      {'icon': Icons.savings, 'label': 'Save\nonline', 'color': const Color(0xFF9C27B0), 'route': '/save-online'},
      {'icon': Icons.credit_card, 'label': 'Credit\ncard', 'color': const Color(0xFFFF5722), 'route': '/credit-card'},
      {'icon': Icons.analytics, 'label': 'Transaction\nreport', 'color': const Color(0xFF3F51B5), 'route': '/transaction-report'},
      {'icon': Icons.people, 'label': 'Beneficiary', 'color': const Color(0xFFE91E63), 'route': '/beneficiary'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
            ),
            itemCount: actions.length,
            itemBuilder: (context, index) {
              final action = actions[index];
              return GestureDetector(
                onTap: () => context.push(action['route'] as String),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(action['icon'] as IconData, color: action['color'] as Color, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        action['label'] as String,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                      ),
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

  Widget _buildRecentTransactions() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recent Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () => context.push('/transactions'),
                child: const Text('See all'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_transactions.isEmpty)
            const Center(child: Text('No transactions yet'))
          else
            ..._transactions.take(5).map((tx) => _buildTransactionTile(tx)),
        ],
      ),
    );
  }

  Widget _buildTransactionTile(Transaction tx) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: tx.isIncome ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(tx.isIncome ? Icons.arrow_downward : Icons.arrow_upward, color: tx.isIncome ? Colors.green : Colors.red),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.counterpartyName ?? tx.categoryName ?? 'Transaction', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(tx.categoryName ?? 'General', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                tx.formattedAmount,
                style: TextStyle(fontWeight: FontWeight.bold, color: tx.isIncome ? Colors.green : Colors.red),
              ),
              Text(_formatDate(tx.createdAt as DateTime), style: TextStyle(color: Colors.grey[500], fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5))]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home, 'Home', 0, '/home'),
          _navItem(Icons.search, 'Search', 1, '/search'),
          _navItem(Icons.mail_outline, 'Mail', 2, '/mail'),
          _navItem(Icons.settings, 'Settings', 3, '/settings'),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index, String route) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _currentIndex = index);
        context.push(route);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF3B2F9F) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isActive ? Colors.white : Colors.grey, size: 20),
            if (isActive) ...[
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ],
        ),
      ),
    );
  }
}