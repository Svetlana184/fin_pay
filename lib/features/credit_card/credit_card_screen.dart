import 'package:flutter/material.dart' hide Card;
import '../../models/credit_card_transaction.dart';
import '../../models/card.dart';
import '../../services/credit_card_service.dart';
import '../../services/card_service.dart';

class CreditCardScreen extends StatefulWidget {
  const CreditCardScreen({super.key});

  @override
  State<CreditCardScreen> createState() => _CreditCardScreenState();
}

class _CreditCardScreenState extends State<CreditCardScreen> {
  final _creditService = CreditCardService();
  final _cardService = CardService();

  List<CreditCardTransaction> _transactions = [];
  List<Card> _cards = [];
  Card? _selectedCard;
  String? _otpCode;
  bool _loading = true;
  bool _paying = false;
  bool _showSuccess = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final transactions = await _creditService.getTransactions();
      final cards = await _cardService.getCards();
      if (mounted) {
        setState(() {
          _transactions = transactions;
          _cards = cards.cast<Card>();
          if (cards.isNotEmpty) _selectedCard = cards.first as Card?;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  double get _totalAmount => _transactions.fold(0.0, (sum, tx) => sum + tx.amount);

  IconData _getIcon(String iconType) {
    switch (iconType) {
      case 'camera': return Icons.camera_alt;
      case 'tv': return Icons.tv;
      case 'shopping_cart': return Icons.shopping_cart;
      default: return Icons.shopping_bag;
    }
  }

  Color _parseColor(String hex) {
    return Color(int.parse(hex.replaceFirst('0x', '0xFF')));
  }

  Future<void> _handleGetOTP() async {
    final otp = await _creditService.getOTP();
    setState(() => _otpCode = otp);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('OTP код: $otp'), backgroundColor: Colors.green),
    );
  }

  Future<void> _handlePay() async {
    if (_selectedCard == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Выберите карту'), backgroundColor: Colors.red),
      );
      return;
    }

    if (_otpCode == null || _otpCode!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите OTP код'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _paying = true);

    final result = await _creditService.payWithOTP(
      accountId: _selectedCard!.id,
      amount: _totalAmount,
      otpCode: _otpCode!,
    );

    setState(() => _paying = false);

    if (result['success'] == true) {
      setState(() => _showSuccess = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['error'] ?? 'Ошибка оплаты'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showSuccess) return _buildSuccessScreen();
    if (_loading) return Scaffold(body: const Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF3B2F9F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Credit card',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Карта
            if (_selectedCard != null) _buildCreditCard(_selectedCard!),
            const SizedBox(height: 24),

            // Список транзакций
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
              ),
              child: Column(
                children: [
                  ..._transactions.map((tx) => _buildTransactionTile(tx)),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('TOTAL', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(
                        '-\$${_totalAmount.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.pink),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Выбор карты
            _buildCardSelector(),
            const SizedBox(height: 24),

            // OTP верификация
            _buildOTPSection(),
            const SizedBox(height: 30),

            // Кнопка Pay
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _paying ? null : _handlePay,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _paying ? Colors.grey : const Color(0xFF3B2F9F),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _paying
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Pay',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditCard(Card card) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A4E), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: const Color(0xFF3B2F9F).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Stack(
        children: [
          Positioned(right: -30, top: -30, child: Container(width: 150, height: 150, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.1)))),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(card.holderName ?? 'John Smith', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Amazon Platinium', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)),
                    const SizedBox(height: 16),
                    Text('4756 •••• •••• ${card.last4Digits}', style: const TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 2)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('\$${card.balance.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    const Text('VISA', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTile(CreditCardTransaction tx) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _parseColor(tx.iconColor),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_getIcon(tx.icon), color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(tx.date, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
          Text(tx.formattedAmount, style: const TextStyle(color: Colors.pink, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildCardSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Card>(
          isExpanded: true,
          value: _selectedCard,
          hint: const Text('Choose account/card'),
          items: _cards.map((card) => DropdownMenuItem(
            value: card,
            child: Text('${card.cardType} **** ${card.last4Digits}'),
          )).toList(),
          onChanged: (card) => setState(() => _selectedCard = card),
        ),
      ),
    );
  }

  Widget _buildOTPSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Get OTP to verify transaction',
            style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: (value) => setState(() => _otpCode = value),
                decoration: InputDecoration(
                  hintText: 'OTP',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: _handleGetOTP,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B2F9F),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Get OTP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSuccessScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 250,
                decoration: BoxDecoration(
                  color: const Color(0xFF3B2F9F).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(left: 40, top: 40, child: Icon(Icons.credit_card, size: 80, color: Colors.blue.shade100)),
                    Positioned(right: 30, bottom: 60, child: Icon(Icons.shield, size: 60, color: Colors.green.shade100)),
                    Container(
                      height: 200,
                      width: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B2F9F).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF3B2F9F), width: 3),
                      ),
                      child: const Icon(Icons.check_circle, size: 80, color: Color(0xFF3B2F9F)),
                    ),
                    Positioned(right: 60, top: 80, child: Icon(Icons.add_circle, size: 50, color: Colors.white)),
                    Positioned(left: 40, bottom: 40, child: Icon(Icons.account_balance_wallet, size: 50, color: Colors.orange)),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              const Text('Transaction successfully!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF3B2F9F)),
                  textAlign: TextAlign.center),
              const SizedBox(height: 16),
              const Text('You have successfully traded!',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showSuccess = false;
                      _transactions = [];
                      _otpCode = null;
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B2F9F),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Confirm',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}