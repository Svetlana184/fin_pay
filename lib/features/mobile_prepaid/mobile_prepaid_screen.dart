import 'package:flutter/material.dart' hide Card;
import 'package:go_router/go_router.dart';
import '../../models/card.dart';
import '../../models/beneficiary.dart';
import '../../services/mobile_prepaid_service.dart';

class MobilePrepaidScreen extends StatefulWidget {
  const MobilePrepaidScreen({super.key});

  @override
  State<MobilePrepaidScreen> createState() => _MobilePrepaidScreenState();
}

class _MobilePrepaidScreenState extends State<MobilePrepaidScreen> {
  final _service = MobilePrepaidService();
  final _phoneController = TextEditingController();

  List<Card> _cards = [];
  List<Beneficiary> _beneficiaries = [];
  Card? _selectedCard;
  Beneficiary? _selectedBeneficiary;
  double? _selectedAmount;
  bool _loading = true;

  static const List<double> _presets = [10, 20, 30];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        _service.getCards(),
        _service.getBeneficiaries(),
      ]);
      if (mounted) {
        setState(() {
          _cards = results[0] as List<Card>;
          _beneficiaries = results[1] as List<Beneficiary>;
          if (_cards.isNotEmpty) _selectedCard = _cards.first;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  double? get _amount {
    if (_selectedAmount != null) return _selectedAmount;
    return null;
  }

  bool get _canConfirm {
    return _selectedCard != null &&
        _phoneController.text.trim().isNotEmpty &&
        _amount != null &&
        _amount! > 0;
  }

  void _onConfirm() {
    if (!_canConfirm) return;
    context.push('/home/mobile-prepaid/confirm', extra: {
      'fromCard': _selectedCard,
      'phone': _phoneController.text.trim(),
      'amount': _amount,
    });
  }

  Future<void> _showCardPicker() async {
    final picked = await showModalBottomSheet<Card>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CardPickerSheet(
        cards: _cards,
        selected: _selectedCard,
        onPick: (c) => Navigator.pop(ctx, c),
      ),
    );
    if (picked != null) setState(() => _selectedCard = picked);
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
        title: const Text('Mobile prepaid',
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardSelector(),
            if (_selectedCard != null) ...[
              const SizedBox(height: 8),
              Text(
                'Available balance : ${_selectedCard!.balance.toStringAsFixed(0)}\$S',
                style: const TextStyle(
                    color: Color(0xFF3B2F9F), fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
            const SizedBox(height: 24),
            _buildDirectoryHeader(),
            const SizedBox(height: 12),
            _buildDirectory(),
            const SizedBox(height: 24),
            const Text('Phone number',
                style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            _buildPhoneField(),
            const SizedBox(height: 24),
            const Text('Choose amount',
                style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
            _buildAmountPresets(),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _canConfirm ? _onConfirm : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _canConfirm
                      ? const Color(0xFF3B2F9F)
                      : const Color(0xFF3B2F9F).withOpacity(0.2),
                  foregroundColor: _canConfirm ? Colors.white : Colors.white70,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Confirm',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardSelector() {
    return GestureDetector(
      onTap: _showCardPicker,
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
                  : 'Choose account / card',
              style: TextStyle(
                  color: _selectedCard != null ? Colors.black87 : Colors.grey[500], fontSize: 15),
            ),
            Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  Widget _buildDirectoryHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Directory', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        TextButton(
          onPressed: () => context.push('/home/beneficiary'),
          child: const Text('Find beneficiary',
              style: TextStyle(color: Color(0xFF3B2F9F), fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _buildDirectory() {
    return SizedBox(
      height: 110,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // Кнопка «+»
          GestureDetector(
            onTap: () => setState(() => _selectedBeneficiary = null),
            child: Container(
              width: 90,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
              ),
              child: Center(
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF3B2F9F).withOpacity(0.1),
                  ),
                  child: const Icon(Icons.add, color: Color(0xFF3B2F9F), size: 28),
                ),
              ),
            ),
          ),
          ..._beneficiaries.map((b) {
            final isSelected = _selectedBeneficiary?.id == b.id;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedBeneficiary = b;
                  if (b.cardNumber.isNotEmpty) {
                    _phoneController.text = b.cardNumber;
                  }
                });
              },
              child: Container(
                width: 90,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF3B2F9F) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: b.avatarUrl != null ? NetworkImage(b.avatarUrl!) : null,
                      child: b.avatarUrl == null
                          ? const Icon(Icons.person, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      b.name.split(' ').first,
                      style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
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
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF3B2F9F))),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildAmountPresets() {
    return Row(
      children: _presets.map((a) {
        final isSelected = _selectedAmount == a;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: GestureDetector(
              onTap: () => setState(() => _selectedAmount = a),
              child: Container(
                height: 64,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF3B2F9F) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: isSelected
                      ? []
                      : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
                ),
                alignment: Alignment.center,
                child: Text(
                  '\$$a',
                  style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[600],
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }
}

class _CardPickerSheet extends StatelessWidget {
  final List<Card> cards;
  final Card? selected;
  final ValueChanged<Card> onPick;
  const _CardPickerSheet({required this.cards, required this.selected, required this.onPick});

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
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
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
                    trailing: isSelected ? const Icon(Icons.check, color: Color(0xFF3B2F9F)) : null,
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