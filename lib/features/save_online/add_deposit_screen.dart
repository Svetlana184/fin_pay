import 'package:flutter/material.dart' hide Card;
import '../../models/card.dart';
import '../../services/card_service.dart';
import '../../services/savings_service.dart';

class AddDepositScreen extends StatefulWidget {
  const AddDepositScreen({super.key});

  @override
  State<AddDepositScreen> createState() => _AddDepositScreenState();
}

class _AddDepositScreenState extends State<AddDepositScreen> {
  final _cardService = CardService();
  final _savingsService = SavingsService();
  final _amountController = TextEditingController();

  List<Card> _cards = [];
  Card? _selectedCard;
  _DepositTerm? _selectedTerm;
  bool _loading = true;
  bool _creating = false;

  static const List<_DepositTerm> _availableTerms = [
    _DepositTerm(months: 3, rate: 4.0),
    _DepositTerm(months: 6, rate: 4.5),
    _DepositTerm(months: 12, rate: 5.0),
    _DepositTerm(months: 16, rate: 5.5),
    _DepositTerm(months: 24, rate: 6.0),
  ];

  double? get _amount {
    final text = _amountController.text.replaceAll('\$', '').replaceAll(',', '').trim();
    return double.tryParse(text);
  }

  bool get _canVerify {
    return _selectedCard != null &&
        _selectedTerm != null &&
        _amount != null &&
        _amount! >= 1000 &&
        _amount! <= _selectedCard!.balance;
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
          _cards = cards.map((e) => Card.fromJson(e)).toList();
          if (_cards.isNotEmpty) _selectedCard = _cards.first;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _onVerify() async {
    if (!_canVerify) return;

    setState(() => _creating = true);

    final result = await _savingsService.createDeposit(
      accountId: _selectedCard!.id,
      termMonths: _selectedTerm!.months,
      amount: _amount!,
      interestRate: _selectedTerm!.rate,
    );

    setState(() => _creating = false);

    if (mounted) {
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Вклад успешно создан!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['error'] ?? 'Ошибка'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _showTermPicker() async {
    final picked = await showModalBottomSheet<_DepositTerm>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _TermPickerSheet(
        terms: _availableTerms,
        selected: _selectedTerm,
        onPick: (term) => Navigator.pop(ctx, term),
      ),
    );
    if (picked != null) {
      setState(() => _selectedTerm = picked);
    }
  }

  Future<void> _showCardPicker() async {
    final picked = await showModalBottomSheet<Card>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CardPickerSheet(
        cards: _cards,
        selected: _selectedCard,
        onPick: (card) => Navigator.pop(ctx, card),
      ),
    );
    if (picked != null) {
      setState(() => _selectedCard = picked);
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
        title: const Text('Add',
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
            _buildForm(),
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
          Positioned(left: 30, top: 30, child: Icon(Icons.savings, size: 80, color: Colors.pink[300])),
          Positioned(right: 40, bottom: 30, child: Icon(Icons.attach_money, size: 60, color: Colors.amber)),
          Positioned(top: 20, right: 30, child: Icon(Icons.monetization_on, size: 50, color: Colors.green)),
          const Icon(Icons.account_balance_wallet, size: 90, color: Color(0xFF3B2F9F)),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
      ),
      child: Column(
        children: [
          // Выбор карты
          GestureDetector(
            onTap: _showCardPicker,
            child: Container(
              width: double.infinity,
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
                        ? 'Account ${_selectedCard!.cardType} **** ${_selectedCard!.last4Digits}'
                        : 'Choose account/card',
                    style: TextStyle(
                        color: _selectedCard != null ? Colors.black87 : Colors.grey[500],
                        fontSize: 15),
                  ),
                  Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
                ],
              ),
            ),
          ),
          if (_selectedCard != null) ...[
            const SizedBox(height: 8),
            Text(
              'Available balance: ${_selectedCard!.balance.toStringAsFixed(0)}\$',
              style: const TextStyle(color: Color(0xFF3B2F9F), fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
          const SizedBox(height: 16),

          // Выбор срока вклада
          GestureDetector(
            onTap: _showTermPicker,
            child: Container(
              width: double.infinity,
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
                    _selectedTerm != null
                        ? '${_selectedTerm!.months} months'
                        : 'Choose time deposit',
                    style: TextStyle(
                        color: _selectedTerm != null ? Colors.black87 : Colors.grey[500],
                        fontSize: 15),
                  ),
                  Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
                ],
              ),
            ),
          ),
          if (_selectedTerm != null) ...[
            const SizedBox(height: 8),
            Text(
              'Interest rate ${_selectedTerm!.rate}%/ ${_selectedTerm!.months} months',
              style: const TextStyle(color: Color(0xFF3B2F9F), fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ],
          const SizedBox(height: 16),

          // Сумма
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Amount (At least \$1000)',
              prefixIcon: const Icon(Icons.attach_money, color: Colors.grey),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF3B2F9F))),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          if (_amount != null && _amount! < 1000) ...[
            const SizedBox(height: 4),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Минимальная сумма: \$1000',
                  style: TextStyle(color: Colors.red, fontSize: 12)),
            ),
          ],
          const SizedBox(height: 24),

          // Кнопка Verify
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _canVerify && !_creating ? _onVerify : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _canVerify
                    ? const Color(0xFF3B2F9F)
                    : const Color(0xFF3B2F9F).withOpacity(0.2),
                foregroundColor: _canVerify ? Colors.white : Colors.white70,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _creating
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Verify',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
}

class _DepositTerm {
  final int months;
  final double rate;
  const _DepositTerm({required this.months, required this.rate});
}

/// Bottom sheet выбора срока вклада
class _TermPickerSheet extends StatelessWidget {
  final List<_DepositTerm> terms;
  final _DepositTerm? selected;
  final ValueChanged<_DepositTerm> onPick;

  const _TermPickerSheet({required this.terms, required this.selected, required this.onPick});

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
                    child: Text('Choose time deposit',
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
                children: terms.map((term) {
                  final isSelected = selected?.months == term.months;
                  return ListTile(
                    title: Text(
                      '${term.months} months ( Interest rate ${term.rate}% )',
                      style: TextStyle(
                          color: isSelected ? const Color(0xFF3B2F9F) : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                    ),
                    trailing: isSelected ? const Icon(Icons.check, color: Color(0xFF3B2F9F)) : null,
                    onTap: () => onPick(term),
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

/// Bottom sheet выбора карты
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
                    child: Text('Choose card',
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
                children: [
                  ...cards.map((card) {
                    final isSelected = selected?.id == card.id;
                    return ListTile(
                      title: Text(
                        '${card.cardType} **** ${card.last4Digits}',
                        style: TextStyle(
                            color: isSelected ? const Color(0xFF3B2F9F) : Colors.black87,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                      ),
                      subtitle: Text('Balance: ${card.balance} ${card.currency}'),
                      trailing: isSelected ? const Icon(Icons.check, color: Color(0xFF3B2F9F)) : null,
                      onTap: () => onPick(card),
                    );
                  }),
                  ListTile(
                    leading: const Icon(Icons.add, color: Colors.grey),
                    title: const Text('Add new card', style: TextStyle(color: Colors.grey)),
                    onTap: () {
                      Navigator.pop(context);
                      // Навигация на экран добавления карты
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}