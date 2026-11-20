import 'package:flutter/material.dart' hide Card;
import 'package:go_router/go_router.dart';
import '../../models/card.dart';
import '../../models/transfer_recipient.dart';
import '../../services/card_service.dart';
import '../../services/transfer_service.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _cardService = CardService();
  final _transferService = TransferService();

  final _nameController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _amountController = TextEditingController();
  final _contentController = TextEditingController();

  List<Card> _cards = [];
  List<TransferRecipient> _recipients = [];
  Card? _selectedCard;
  TransferRecipient? _selectedRecipient;
  String _transferType = 'card_number';
  bool _saveBeneficiary = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final cards = await _cardService.getCards();
      final recipients = await _transferService.getBeneficiaries();
      if (mounted) {
        setState(() {
          _cards = cards.cast<Card>();
          _recipients = recipients;
          if (cards.isNotEmpty) _selectedCard = cards.first as Card?;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  double get _amount {
    return double.tryParse(_amountController.text.replaceAll('\$', '').replaceAll(',', '')) ?? 0;
  }

  String get _amountInWords {
    if (_amount == 0) return '';
    return _transferService.amountToWords(_amount);
  }

  bool get _canConfirm {
    return _selectedCard != null &&
        _nameController.text.trim().isNotEmpty &&
        _cardNumberController.text.trim().isNotEmpty &&
        _amount > 0;
  }

  void _onRecipientSelected(TransferRecipient? recipient) {
    setState(() {
      _selectedRecipient = recipient;
      if (recipient != null) {
        _nameController.text = recipient.recipientName;
        _cardNumberController.text = recipient.recipientAccount;
      }
    });
  }

  void _onConfirm() {
    if (!_canConfirm) return;

    context.push('/transfer/confirm', extra: {
      'fromCard': _selectedCard,
      'recipientName': _nameController.text.trim(),
      'cardNumber': _cardNumberController.text.trim(),
      'amount': _amount,
      'content': _contentController.text.trim(),
      'saveBeneficiary': _saveBeneficiary,
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
        title: const Text('Transfer',
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Выбор карты/счёта
            _buildCardSelector(),
            if (_selectedCard != null) ...[
              const SizedBox(height: 8),
              Text(
                'Available balance: \$${_selectedCard!.balance.toStringAsFixed(0)}',
                style: const TextStyle(color: Color(0xFF3B2F9F), fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
            const SizedBox(height: 24),

            // Тип транзакции
            const Text('Choose transaction',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildTransactionTypes(),
            const SizedBox(height: 24),

            // Выбор получателя
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Choose beneficiary',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () {
                    // Найти получателя
                  },
                  child: const Text('Find beneficiary',
                      style: TextStyle(color: Color(0xFF3B2F9F))),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildBeneficiaries(),
            const SizedBox(height: 24),

            // Форма перевода
            _buildTransferForm(),
          ],
        ),
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
          hint: const Text('Choose account / card'),
          items: _cards.map((card) => DropdownMenuItem(
            value: card,
            child: Text('${card.cardType} **** ${card.last4Digits}'),
          )).toList(),
          onChanged: (card) => setState(() => _selectedCard = card),
        ),
      ),
    );
  }

  Widget _buildTransactionTypes() {
    final types = [
      {'id': 'card_number', 'label': 'Transfer via\ncard number', 'icon': Icons.credit_card},
      {'id': 'same_bank', 'label': 'Transfer to\nthe same bank', 'icon': Icons.person},
      {'id': 'another_bank', 'label': 'Transfer to\nanother bank', 'icon': Icons.account_balance},
    ];

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: types.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final type = types[index];
          final isSelected = _transferType == type['id'];
          return GestureDetector(
            onTap: () => setState(() => _transferType = type['id'] as String),
            child: Container(
              width: 120,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF3B2F9F) : Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(type['icon'] as IconData,
                      color: isSelected ? Colors.white : Colors.grey[600], size: 32),
                  const SizedBox(height: 8),
                  Text(type['label'] as String,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[600], fontSize: 11)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBeneficiaries() {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // Кнопка добавления
          GestureDetector(
            onTap: () => _onRecipientSelected(null),
            child: Container(
              width: 80,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.add, color: Colors.grey, size: 32),
            ),
          ),
          // Получатели
          ..._recipients.map((r) => GestureDetector(
            onTap: () => _onRecipientSelected(r),
            child: Container(
              width: 80,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: _selectedRecipient?.id == r.id ? const Color(0xFF3B2F9F) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: _selectedRecipient?.id == r.id ? const Color(0xFF3B2F9F) : Colors.grey[300]!),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.grey[300],
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(r.recipientName.split(' ').first,
                      style: TextStyle(
                          fontSize: 11,
                          color: _selectedRecipient?.id == r.id ? Colors.white : Colors.black87)),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildTransferForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
      ),
      child: Column(
        children: [
          _buildTextField('Name', _nameController),
          const SizedBox(height: 12),
          _buildTextField('Card number', _cardNumberController),
          const SizedBox(height: 12),
          _buildTextField('Amount', _amountController, keyboardType: TextInputType.number),
          if (_amountInWords.isNotEmpty) ...[
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(_amountInWords,
                  style: const TextStyle(color: Color(0xFF3B2F9F), fontSize: 12, fontWeight: FontWeight.w500)),
            ),
          ],
          const SizedBox(height: 12),
          _buildTextField('Content', _contentController),
          const SizedBox(height: 16),
          Row(
            children: [
              Checkbox(
                value: _saveBeneficiary,
                onChanged: (v) => setState(() => _saveBeneficiary = v ?? false),
                activeColor: const Color(0xFF3B2F9F),
              ),
              const Text('Save to directory of beneficiary'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _canConfirm ? _onConfirm : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _canConfirm ? const Color(0xFF3B2F9F) : const Color(0xFF3B2F9F).withOpacity(0.3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Confirm',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller, {TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cardNumberController.dispose();
    _amountController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}