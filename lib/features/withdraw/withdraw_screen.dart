import 'package:flutter/material.dart' hide Card;
import '../../models/card.dart';
import '../../services/card_service.dart';
import '../../services/transfer_service.dart';

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final _cardService = CardService();
  final _transferService = TransferService();

  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();

  List<Card> _cards = [];
  Card? _selectedCard;
  String? _selectedAmount; // '10', '50', '100', '150', '200', 'other'
  bool _loading = true;
  bool _verifying = false;

  static const List<String> _presetAmounts = ['10', '50', '100', '150', '200'];

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
          _cards = cards.map((e) => Card.fromJson(e)).toList();
          if (_cards.isNotEmpty) _selectedCard = _cards.first;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  double? get _withdrawAmount {
    if (_selectedAmount == null) return null;
    if (_selectedAmount == 'other') {
      return double.tryParse(_amountController.text.replaceAll('\$', '').replaceAll(',', '').trim());
    }
    return double.tryParse(_selectedAmount!);
  }

  bool get _canVerify {
    return _selectedCard != null &&
        _phoneController.text.trim().isNotEmpty &&
        _withdrawAmount != null &&
        _withdrawAmount! > 0;
  }

  String get _phoneError {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) return '';
    final clean = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (clean.length < 10) return 'Введите корректный номер';
    return '';
  }

  Future<void> _onVerify() async {
    if (!_canVerify) return;

    setState(() => _verifying = true);

    // В реальном приложении: POST /api/withdraw
    // Для демо используем transfer с пометкой "withdraw"
    final result = await _transferService.transfer(
      fromCardId: _selectedCard!.id,
      toAccount: _phoneController.text.trim(),
      amount: _withdrawAmount!,
      recipientName: 'Withdraw',
      description: 'Снятие наличных',
      saveBeneficiary: false,
    );

    setState(() => _verifying = false);

    if (mounted) {
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Операция подтверждена'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Ошибка'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showAccountPicker() async {
    final picked = await showModalBottomSheet<Card>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AccountPickerSheet(
        cards: _cards,
        selected: _selectedCard,
        onPick: (card) => Navigator.pop(ctx, card),
      ),
    );
    if (picked != null) {
      setState(() => _selectedCard = picked);
    }
  }

  void _onPresetSelected(String amount) {
    setState(() {
      _selectedAmount = amount;
      if (amount != 'other') {
        _amountController.clear();
      }
    });
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
        title: const Text('Withdraw',
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildIllustration(),
            const SizedBox(height: 24),
            _buildCardSelector(),
            if (_selectedCard != null) ...[
              const SizedBox(height: 8),
              Text(
                'Available balance: \$${_selectedCard!.balance.toStringAsFixed(0)}',
                style: const TextStyle(
                    color: Color(0xFF3B2F9F), fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
            const SizedBox(height: 16),
            _buildPhoneField(),
            if (_phoneError.isNotEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 4, left: 4),
                  child: Text(_phoneError,
                      style: const TextStyle(color: Colors.red, fontSize: 12)),
                ),
              ),
            const SizedBox(height: 24),
            _buildAmountSection(),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _canVerify && !_verifying ? _onVerify : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _canVerify
                      ? const Color(0xFF3B2F9F)
                      : const Color(0xFF3B2F9F).withOpacity(0.2),
                  foregroundColor: _canVerify ? Colors.white : Colors.white70,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _verifying
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Verify',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
          // Имитация иллюстрации из шаблона
          Positioned(left: 30, top: 40, child: Icon(Icons.account_balance_wallet, size: 70, color: const Color(0xFF3B2F9F))),
          Positioned(right: 40, bottom: 30, child: Icon(Icons.phone_android, size: 70, color: const Color(0xFF3B2F9F))),
          Positioned(top: 30, right: 60, child: Icon(Icons.monetization_on, size: 50, color: Colors.amber)),
          Positioned(bottom: 40, left: 60, child: Icon(Icons.attach_money, size: 50, color: Colors.green)),
          const Icon(Icons.swap_horiz, size: 80, color: Color(0xFF3B2F9F)),
        ],
      ),
    );
  }

  Widget _buildCardSelector() {
    return GestureDetector(
      onTap: _showAccountPicker,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedCard != null
                  ? '${_selectedCard!.cardType} **** **** **** ${_selectedCard!.last4Digits}'
                  : 'Choose account/card',
              style: TextStyle(
                  color: _selectedCard != null ? Colors.black87 : Colors.grey[500],
                  fontSize: 15),
            ),
            Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneField() {
    return TextField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: 'Phone number',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF3B2F9F))),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        prefixIcon: const Icon(Icons.phone, color: Colors.grey),
      ),
    );
  }

  Widget _buildAmountSection() {
    final isOther = _selectedAmount == 'other';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Choose amount',
            style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        // Сетка пресетов
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.2,
          children: [
            ..._presetAmounts.map((amount) => _buildPresetButton(amount)),
            _buildPresetButton('other', label: 'Other'),
          ],
        ),
        // Поле ввода для "Other"
        if (isOther) ...[
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Amount',
              prefixIcon: const Icon(Icons.attach_money, color: Colors.grey),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF3B2F9F))),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPresetButton(String amount, {String? label}) {
    final isSelected = _selectedAmount == amount;
    final displayLabel = label ?? '\$$amount';
    return GestureDetector(
      onTap: () => _onPresetSelected(amount),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3B2F9F) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isSelected ? const Color(0xFF3B2F9F) : Colors.grey[300]!,
              width: isSelected ? 0 : 1),
          boxShadow: isSelected
              ? []
              : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)],
        ),
        alignment: Alignment.center,
        child: Text(
          displayLabel,
          style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 15),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}

/// Bottom sheet выбора счёта (скрин 3)
class _AccountPickerSheet extends StatelessWidget {
  final List<Card> cards;
  final Card? selected;
  final ValueChanged<Card> onPick;

  const _AccountPickerSheet({
    required this.cards,
    required this.selected,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text('Choose account:',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: cards.map((card) {
                  final isSelected = selected?.id == card.id;
                  return ListTile(
                    title: Text(
                      '${card.cardType} **** **** **** ${card.last4Digits}',
                      style: TextStyle(
                          color: isSelected ? const Color(0xFF3B2F9F) : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check, color: Color(0xFF3B2F9F))
                        : null,
                    onTap: () => onPick(card),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}