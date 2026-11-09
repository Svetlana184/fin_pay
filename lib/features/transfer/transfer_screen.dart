//import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide Card;

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

  List<Card> _cards = [];
  List<TransferRecipient> _beneficiaries = [];
  Card? _selectedCard;
  TransferRecipient? _selectedBeneficiary;
  String _transferType = 'card_number';
  final _nameController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _amountController = TextEditingController();
  final _contentController = TextEditingController();
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
      final results = await Future.wait([
        _cardService.getCards(),
        _transferService.getBeneficiaries(),
      ]);
      if (mounted) {
        setState(() {
          _cards = results[0] as List<Card>;
          _beneficiaries = results[1] as List<TransferRecipient>;
          if (_cards.isNotEmpty) _selectedCard = _cards.first;
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
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black87), onPressed: () => Navigator.pop(context)),
        title: const Text('Transfer', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardSelector(),
            const SizedBox(height: 24),
            const Text('Choose transaction', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildTransactionTypes(),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Choose beneficiary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                TextButton(onPressed: () {}, child: const Text('Find beneficiary', style: TextStyle(color: Color(0xFF3B2F9F)))),
              ],
            ),
            const SizedBox(height: 12),
            _buildBeneficiaries(),
            const SizedBox(height: 24),
            _buildForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildCardSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)),
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
        separatorBuilder: (_, __) => const SizedBox(width: 12),
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
                  Icon(type['icon'] as IconData, color: isSelected ? Colors.white : Colors.grey[600], size: 32),
                  const SizedBox(height: 8),
                  Text(
                    type['label'] as String,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: isSelected ? Colors.white : Colors.grey[600], fontSize: 11),
                  ),
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
          // Add new
          GestureDetector(
            onTap: () => setState(() => _selectedBeneficiary = null),
            child: Container(
              width: 80,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.add, color: Colors.grey, size: 32),
            ),
          ),
          ..._beneficiaries.map((b) => GestureDetector(
            onTap: () {
              setState(() {
                _selectedBeneficiary = b;
                _nameController.text = b.recipientName;
                _cardNumberController.text = b.recipientAccount;
              });
            },
            child: Container(
              width: 80,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: _selectedBeneficiary?.id == b.id ? const Color(0xFF3B2F9F) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _selectedBeneficiary?.id == b.id ? const Color(0xFF3B2F9F) : Colors.grey[300]!),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(radius: 24, backgroundImage: b?.recipientBank != null ? null : null, child: const Icon(Icons.person)),
                  const SizedBox(height: 4),
                  Text(b!.recipientName.split(' ').first, style: TextStyle(fontSize: 11, color: _selectedBeneficiary?.id == b.id ? Colors.white : Colors.black87)),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          _buildTextField('Name', _nameController),
          const SizedBox(height: 12),
          _buildTextField('Card number', _cardNumberController),
          const SizedBox(height: 12),
          _buildTextField('Amount', _amountController, keyboardType: TextInputType.number),
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
              onPressed: _handleTransfer,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B2F9F), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Confirm', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Future<void> _handleTransfer() async {
    if (_selectedCard == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select a card')));
      return;
    }
    if (_nameController.text.isEmpty || _cardNumberController.text.isEmpty || _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fill all fields')));
      return;
    }

    try {
      await _transferService.transfer(
        fromCardId: _selectedCard!.id,
        toAccount: _cardNumberController.text,
        amount: double.parse(_amountController.text),
        recipientName: _nameController.text,
        description: _contentController.text,
        saveBeneficiary: _saveBeneficiary,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transfer successful!'), backgroundColor: Colors.green));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
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