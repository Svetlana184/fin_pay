import 'package:flutter/material.dart';
import '../../services/card_service.dart';
import '../../services/user_service.dart';
import 'card_details_screen.dart';
import 'management_screen.dart';

class AccountAndCardScreen extends StatefulWidget {
  const AccountAndCardScreen({super.key});

  @override
  State<AccountAndCardScreen> createState() => _AccountAndCardScreenState();
}

class _AccountAndCardScreenState extends State<AccountAndCardScreen>
    with SingleTickerProviderStateMixin {
  final _cardService = CardService();
  final _userService = UserService();
  late TabController _tabController;

  Map<String, dynamic>? _profile;
  List<Map<String, dynamic>> _cards = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _loading = true; _error = null; });
    try {
      final results = await Future.wait([
        _userService.getProfile(),
        _cardService.getCards(),
      ]);
      if (mounted) {
        setState(() {
          _profile = results[0] as Map<String, dynamic>;
          _cards = results[1] as List<Map<String, dynamic>>;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Account and card',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: Column(
        children: [
          _buildTabSwitcher(),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? _buildError(_error!)
                : TabBarView(
              controller: _tabController,
              children: [_buildAccountTab(), _buildCardTab()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSwitcher() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _tabButton('Account', 0),
          _tabButton('Card', 1),
        ],
      ),
    );
  }

  Widget _tabButton(String label, int index) {
    final isSelected = _tabController.index == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _tabController.animateTo(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF3B2F9F) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccountTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Профиль
          Column(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey[300],
                backgroundImage: _profile?['avatar_url'] != null
                    ? NetworkImage(_profile!['avatar_url'])
                    : null,
                child: _profile?['avatar_url'] == null
                    ? const Icon(Icons.person, size: 60, color: Colors.white)
                    : null,
              ),
              const SizedBox(height: 12),
              Text(
                _profile?['full_name'] ?? 'Пользователь',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3B2F9F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Список карт (как "счетов" на скриншоте)
          if (_cards.isEmpty)
            const Center(child: Text('Нет доступных счетов'))
          else
            ..._cards.asMap().entries.map((entry) {
              final card = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildAccountCard(
                  accountName: 'Account ${entry.key + 1}',
                  accountNumber: card['last_4_digits'] ?? '••••',
                  balance: '${card['balance']} ${card['currency']}',
                  branch: 'New York', // можно брать из профиля
                ),
              );
            }),

          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ManagementScreen()),
            ),
            icon: const Icon(Icons.settings),
            label: const Text('Management'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B2F9F),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountCard({
    required String accountName,
    required String accountNumber,
    required String balance,
    required String branch,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(accountName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(accountNumber, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Available balance', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
              Text(balance, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF3B2F9F))),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Branch', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
              Text(branch, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF3B2F9F))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_cards.isEmpty)
            const Center(child: Text('Нет карт'))
          else
            ..._cards.map((card) => Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: _buildCreditCard(
                cardHolder: _profile?['full_name'] ?? 'User',
                cardType: card['card_type'] ?? 'Card',
                cardNumber: card['last_4_digits'] ?? '••••',
                balance: '${card['balance']} ${card['currency']}',
                cardBrand: card['card_type'] ?? 'VISA',
                gradientColors: _cardGradient(card['card_type']),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CardDetailsScreen(cardId: card['id']),
                  ),
                ),
              ),
            )),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add),
            label: const Text('Add card'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B2F9F),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _cardGradient(String? type) {
    switch (type?.toLowerCase()) {
      case 'visa':
        return const [Color(0xFF1A1A4E), Color(0xFF3B82F6)];
      case 'mastercard':
        return const [Color(0xFFFFB347), Color(0xFFFFCC33)];
      case 'mir':
        return const [Color(0xFF4CAF50), Color(0xFF8BC34A)];
      default:
        return const [Color(0xFF1A1A4E), Color(0xFF3B82F6)];
    }
  }

  Widget _buildCreditCard({
    required String cardHolder,
    required String cardType,
    required String cardNumber,
    required String balance,
    required String cardBrand,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradientColors, begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: gradientColors[0].withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -30, top: -30,
              child: Container(width: 150, height: 150, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.1))),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cardHolder, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(cardType, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)),
                      const SizedBox(height: 16),
                      Text('•••• •••• •••• $cardNumber', style: const TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 2, fontWeight: FontWeight.w500)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(balance, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      Text(cardBrand.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _loadData, child: const Text('Повторить')),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}