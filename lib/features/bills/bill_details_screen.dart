import 'package:flutter/material.dart' hide Card;
import '../../models/card.dart';
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
          _cards = cards.cast<Card>();
          if (cards.isNotEmpty) _selectedCard = cards.first as Card?;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleGetOTP() async {
    // Демо OTP
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
    final taxBillId = widget.billData['tax_bill_id'] as String?;
    final amount = double.tryParse(widget.billData['total_amount']?.toString() ?? '0') ?? 0;

    Map<String, dynamic> result;
    if (billId != null) {
      result = await _billService.payBill(
        billId: billId,
        accountId: _selectedCard!.id,
        amount: amount,
        otpCode: _otpCode!,
      );
    } else if (taxBillId != null) {
      result = await _billService.payTax(
        taxBillId: taxBillId,
        accountId: _selectedCard!.id,
        amount: amount,
        otpCode: _otpCode!,
      );
    } else {
      result = {'success': false, 'error': 'Не указан счёт'};
    }

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

    final billType = widget.billData['tax_bill_id'] != null ? 'tax' : 'bill';
    final title = billType == 'tax' ? 'Tax bill' : 'Electric bill';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(title,
            style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Иллюстрация
            _buildIllustration(),
            const SizedBox(height: 24),

            // Детали счёта
            _buildBillDetails(),
            const SizedBox(height: 24),

            // Выбор карты
            _buildCardSelector(),
            const SizedBox(height: 24),

            // OTP верификация
            _buildOTPSection(),
            const SizedBox(height: 30),

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
                    : Text('Pay the bill',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIllustration() {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF3B2F9F).withOpacity(0.06),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(left: 30, top: 30, child: Icon(Icons.account_balance_wallet, size: 70, color: const Color(0xFF3B2F9F))),
          Positioned(right: 40, bottom: 30, child: Icon(Icons.phone_android, size: 70, color: const Color(0xFF3B2F9F))),
          Positioned(top: 20, right: 60, child: Icon(Icons.monetization_on, size: 50, color: Colors.amber)),
          Positioned(bottom: 40, left: 60, child: Icon(Icons.attach_money, size: 50, color: Colors.green)),
          const Icon(Icons.swap_horiz, size: 80, color: Color(0xFF3B2F9F)),
        ],
      ),
    );
  }

  Widget _buildBillDetails() {
    final recipientName = widget.billData['recipient_name'] ?? 'Jackson Maine';
    final address = widget.billData['recipient_address'] ?? '403 East 4th Street, Santa Ana';
    final phone = widget.billData['recipient_phone'] ?? '+8424599721';
    final code = widget.billData['bill_number'] ?? '#2343543';
    final periodFrom = widget.billData['period_from'] ?? '01/10/2019';
    final periodTo = widget.billData['period_to'] ?? '01/11/2019';
    final serviceFee = double.tryParse(widget.billData['service_fee']?.toString() ?? '470') ?? 470;
    final tax = double.tryParse(widget.billData['tax']?.toString() ?? '10') ?? 10;
    final total = double.tryParse(widget.billData['total_amount']?.toString() ?? '480') ?? 480;

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
          _buildDetailRow('Name', recipientName),
          _buildDetailRow('Address', address),
          _buildDetailRow('Phone number', phone),
          _buildDetailRow('Code', code),
          _buildDetailRow('From', periodFrom),
          _buildDetailRow('To', periodTo),
          const Divider(height: 24),
          _buildDetailRow('Electric fee', '\$$serviceFee', isBold: true),
          _buildDetailRow('Tax', '\$$tax', isBold: true),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('TOTAL', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('\$$total',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.pink)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: 14)),
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
                  ],
                ),
              ),
              const SizedBox(height: 40),
              const Text('Transaction successfully!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF3B2F9F)),
                  textAlign: TextAlign.center),
              const SizedBox(height: 16),
              const Text('You\'ve pay your electric bill',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
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