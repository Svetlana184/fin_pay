import 'package:fin_pay/models/savings_account.dart';
import 'package:fin_pay/models/user.dart';
import 'package:fin_pay/services/api_client.dart';
import 'package:flutter/material.dart' hide Card;
import 'package:go_router/go_router.dart';
import '../../services/card_service.dart';
import '../../services/savings_service.dart';
import '../../services/user_service.dart';
import '../../models/card.dart';

class AccountAndCardScreen extends StatefulWidget {
  const AccountAndCardScreen({super.key});

  @override
  State<AccountAndCardScreen> createState() => _AccountAndCardScreenState();
}

class _AccountAndCardScreenState extends State<AccountAndCardScreen> {
  final _cardService = CardService();
  final _savingsService = SavingsService();
  final _userService = UserService();

  bool _showAccounts = true; // true = Account, false = Card
  User? _user;
  List<SavingsAccount> _accounts = [];
  List<Card> _cards = [];
  bool _loading = true;

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
        _savingsService.getDeposits(),
        _cardService.getCards(),
      ]);
      if (mounted) {
        setState(() {
          _user = results[0] as User?;
          _accounts = results[1] as List<SavingsAccount>;
          _cards = results[2] as List<Card>;
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
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Account and card',
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          const SizedBox(height: 8),
          _buildSegmentedSwitch(),
          const SizedBox(height: 24),
          _buildProfileAvatar(),
          const SizedBox(height: 24),
          Expanded(
            child: _showAccounts ? _buildAccountsList() : _buildCardsList(),
          ),
        ],
      ),
    );
  }

  // === Переключатель Account / Card ===
  Widget _buildSegmentedSwitch() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildSegment('Account', _showAccounts, () {
              setState(() => _showAccounts = true);
            }),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSegment('Card', !_showAccounts, () {
              setState(() => _showAccounts = false);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSegment(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: active ? const Color(0xFF3B2F9F) : Colors.grey[200],
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  // === Аватар + имя ===
  Widget _buildProfileAvatar() {
    return Column(
      children: [
        CircleAvatar(
          radius: 44,
          backgroundColor: Colors.grey[300],
          backgroundImage: _user?.avatarUrl != null
              ? NetworkImage(_user!.avatarUrl!)
              : null,
          child: _user?.avatarUrl == null
              ? const Icon(Icons.person, size: 44, color: Colors.white)
              : null,
        ),
        const SizedBox(height: 12),
        Text(
          _user?.fullName ?? 'Push Puttichai',
          style: const TextStyle(
            color: Color(0xFF3B2F9F),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // === Вкладка Account: список депозитов (GET /api/savings) ===
  Widget _buildAccountsList() {
    if (_accounts.isEmpty) {
      return const Center(child: Text('Нет счетов', style: TextStyle(color: Colors.grey)));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _accounts.length,
      itemBuilder: (context, i) {
        final acc = _accounts[i];
        return GestureDetector(
          onTap: () => context.push('/home/management'),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3))],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Account ${i + 1}',
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                    Text(acc.accountNumber,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 14),
                _row('Available balance',
                    '\$${acc.balance.toStringAsFixed(0)}', valueColor: const Color(0xFF3B2F9F)),
                const SizedBox(height: 8),
                _row('Branch', _user?.city ?? 'New York', valueColor: const Color(0xFF3B2F9F)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _row(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        Text(value, style: TextStyle(color: valueColor, fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }

  // === Вкладка Card: список карт (GET /api/cards) ===
  Widget _buildCardsList() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        ..._cards.map((card) => Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: GestureDetector(
            onTap: () => context.push('/home/account/card/${card.id}'),
            child: _buildCardWidget(card),
          ),
        )),
        const SizedBox(height: 8),
        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: _showAddCardSheet,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B2F9F),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Add card',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // === Виджет карты с градиентом (как на скрине 2) ===
  Widget _buildCardWidget(Card card) {
    final isVisa = card.cardType.toLowerCase().contains('visa');
    final colors = isVisa
        ? const [Color(0xFF1A1A4E), Color(0xFF2F7CF6)]
        : const [Color(0xFFF6B23D), Color(0xFFF59E0B)];

    final number = card.maskedNumber ??
        '4756 •••• •••• ${card.last4Digits ?? '9018'}';

    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: colors[0].withOpacity(0.35), blurRadius: 14, offset: const Offset(0, 6))],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(isVisa ? 0.25 : 0.3),
              ),
            ),
          ),
          if (!isVisa)
            Positioned(
              right: 30,
              bottom: 40,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.25),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_user?.fullName ?? 'John Smith',
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    const Text('Amazon Platinium',
                        style: TextStyle(color: Colors.white, fontSize: 13)),
                    const SizedBox(height: 16),
                    Text(number,
                        style: const TextStyle(color: Colors.white, fontSize: 17, letterSpacing: 2)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('\$${card.balance.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    _buildBrandLogo(isVisa),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandLogo(bool isVisa) {
    if (isVisa) {
      return const Text('VISA',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ));
    }
    // Логотип Mastercard: два пересекающихся круга
    return Stack(
      children: [
        Container(width: 34, height: 34, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white)),
        Padding(
          padding: const EdgeInsets.only(left: 18),
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ),
      ],
    );
  }

  // === Bottom sheet добавления карты (POST /api/cards) ===
  void _showAddCardSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => const _AddCardSheet(),
    );
  }
}

class _AddCardSheet extends StatefulWidget {
  const _AddCardSheet();

  @override
  State<_AddCardSheet> createState() => _AddCardSheetState();
}

class _AddCardSheetState extends State<_AddCardSheet> {
  final _numberController = TextEditingController();
  final _typeController = TextEditingController();
  final _expiryController = TextEditingController();
  bool _saving = false;

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final client = ApiClient();
      await client.post('/api/cards', body: {
        'card_number': _numberController.text.trim(),
        'card_type': _typeController.text.trim().isEmpty ? 'Visa' : _typeController.text.trim(),
        'expires_at': _expiryController.text.trim(),
      });
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Карта добавлена'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Add new card', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(controller: _numberController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Card number')),
          const SizedBox(height: 12),
          TextField(controller: _typeController, decoration: const InputDecoration(labelText: 'Card type (Visa / Mastercard)')),
          const SizedBox(height: 12),
          TextField(controller: _expiryController, decoration: const InputDecoration(labelText: 'Expires at (YYYY-MM-DD)')),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B2F9F)),
              child: _saving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}