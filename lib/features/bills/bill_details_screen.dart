import 'package:flutter/material.dart';
import '../../models/card.dart';
import '../../models/bill_provider.dart';
import '../../services/card_service.dart';
import '../../services/bill_service.dart';

class BillDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> billData;
  const BillDetailsScreen({super.key, required this.billData});

  @override
  State<BillDetailsScreen> createState() => _BillDetailsScreenState();
}

class _BillDetailsScreenState extends State<BillDetailsScreen> {
  final _cardService = CardService();
  final _billService = BillService();

  List<Card> _cards = [];
  Card? _selectedCard;
  String? _otpCode;
  bool _loading = true;
  bool _paying = false;
  bool _showSuccess = false;

  String get _billType => widget.billData['bill_type'] ?? 'internet';
  BillProvider? get _provider {
    final p = widget.billData['provider'];
    if (p == null) return null;
    return BillProvider.fromJson(Map<String, dynamic>.from(p));
  }

  String get _title {
    switch (_billType) {
      case 'electric': return 'Electric bill';
      case 'water':    return 'Water bill';
      case 'mobile':   return 'Mobile bill';
      case 'internet': return 'Internet bill';
      default:         return 'Bill details';
    }
  }

  String get _feeLabel {
    switch (_billType) {
      case 'electric': return 'Electric fee';
      case 'water':    return 'Water fee';
      case 'mobile':   return 'Mobile fee';
      case 'internet': return 'Internet fee';
      default:         return 'Service fee';
    }
  }

  IconData get _illustrationIcon {
    switch (_billType) {
      case 'electric': return Icons.electrical_services;
      case 'water':    return Icons.water_drop;
      case 'mobile':   return Icons.phone_android;
      case 'internet': return Icons.wifi;
      default:         return Icons.receipt_long;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    setState(() => _loading = true);
    try {
      final cards = await _cardService.getCards();
      if (mounted) {
        setState(() {
          _cards = cards;
          if (cards.isNotEmpty) _selectedCard = cards.first;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleGetOTP() async {
    setState(() => _otpCode = '123456');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('OTP код: 123456'), backgroundColor: Colors.green),
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
    final billId = widget.billData['id'] as String?;
    final amount = double.tryParse(widget.billData['total_amount']?.toString() ?? '0') ?? 0;

    final result = await _billService.payBill(
      billId: billId,
      accountId: _selectedCard!.id,
      amount: amount,
      otpCode: _otpCode!,
    );
    setState(() => _paying = false);

    if (result['success'] == true) {
      setState(() => _showSuccess = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['error'] ?? 'Ошибка'), backgroundColor: Colors.red),
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
        backgroundColor: Colors.grey[50],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(_title,
            style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Иллюстрация (как на скрине 2)
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF3B2F9F).withOpacity(0.06),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(_illustrationIcon, size: 90, color: const Color(0xFF3B2F9F)),
            ),
            const SizedBox(height: 16),
            Text(
              '${widget.billData['period_from'] ?? '01/10/2019'} - ${widget.billData['period_to'] ?? '01/11/2019'}',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 24),

            // Карточка деталей
            _buildBillCard(),
            const SizedBox(height: 24),

            // Выбор карты
            _buildCardSelector(),
            const SizedBox(height: 24),

            // OTP
            _buildOTPSection(),
            const SizedBox(height: 32),

            // Кнопка оплаты
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
                    : const Text('Pay the bill',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillCard() {
    final recipientName = widget.billData['recipient_name'] ?? 'Jackson Maine';
    final address = widget.billData['recipient_address'] ?? '403 East 4th Street, Santa Ana';
    final phone = widget.billData['recipient_phone'] ?? '+8424599721';
    final code = widget.billData['bill_number'] ?? '#2343543';
    final periodFrom = widget.billData['period_from'] ?? '01/10/2019';
    final periodTo = widget.billData['period_to'] ?? '01/11/2019';
    final fee = double.tryParse(widget.billData['service_fee']?.toString() ?? '50') ?? 50;
    final tax = double.tryParse(widget.billData['tax']?.toString() ?? '10') ?? 10;
    final total = double.tryParse(widget.billData['total_amount']?.toString() ?? '60') ?? 60;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('All the Bills', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _row('Name', recipientName),
          _row('Address', address, multiline: true),
          _row('Phone number', phone),
          _row('Code', code),
          _row('From', periodFrom),
          _row('To', periodTo),
          const Divider(height: 24),
          _row(_feeLabel, '\$$fee', valueColor: const Color(0xFF3B2F9F), bold: true),
          _row('Tax', '\$$tax', valueColor: const Color(0xFF3B2F9F), bold: true),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('TOTAL', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('\$$total',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.pinkAccent)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {Color? valueColor, bool bold = false, bool multiline = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: multiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14),
              textAlign: TextAlign.left),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: valueColor,
                  fontSize: 14,
                  fontWeight: bold ? FontWeight.bold : FontWeight.w600,
                )),
          ),
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
                onChanged: (v) => setState(() => _otpCode = v),
                decoration: InputDecoration(
                  hintText: 'OTP',
                  suffixIcon: const Icon(Icons.chevron_right),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
              child: const Text('Get OTP',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                height: 240,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF3B2F9F).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(left: 30, top: 30, child: Icon(Icons.credit_card, size: 90, color: Colors.blue.shade100)),
                    Positioned(right: 30, bottom: 40, child: Icon(Icons.shield, size: 70, color: Colors.green.shade100)),
                    Container(
                      height: 180, width: 110,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B2F9F).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF3B2F9F), width: 3),
                      ),
                      child: const Icon(Icons.check_circle, size: 80, color: Color(0xFF3B2F9F)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              const Text('Transaction successfully!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF3B2F9F)),
                  textAlign: TextAlign.center),
              const SizedBox(height: 16),
              Text("You've pay your $_billType bill!",
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
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