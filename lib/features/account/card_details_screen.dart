import 'package:fin_pay/models/user.dart';
import 'package:flutter/material.dart' hide Card;
import '../../services/card_service.dart';
import '../../models/card.dart';
import '../../services/user_service.dart';

class CardDetailsScreen extends StatefulWidget {
  final String cardId;
  const CardDetailsScreen({super.key, required this.cardId});

  @override
  State<CardDetailsScreen> createState() => _CardDetailsScreenState();
}

class _CardDetailsScreenState extends State<CardDetailsScreen> {
  final _cardService = CardService();
  final _userService = UserService();

  Card? _card;
  User? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        _cardService.getCardDetails(widget.cardId),
        _userService.getProfile(),
      ]);
      if (mounted) {
        setState(() {
          _card = results[0] as Card;
          _user = results[1] as User?;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete card?'),
        content: const Text('Карта будет удалена безвозвратно.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Удалить', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      // Бэкенд разрешает удалять только blocked-карту → сначала блокируем
      if (_card!.status != 'blocked') {
        await _cardService.updateCardStatus(_card!.id, 'blocked');
      }
      await _cardService.deleteCard(_card!.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Карта удалена'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Card',
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _card == null
          ? const Center(child: Text('Карта не найдена'))
          : Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              children: [
                _buildRow('Name', _card!.holderName ?? _user?.fullName ?? 'Push Puttichai'),
                _buildRow('Card number',
                    _card!.maskedNumber ?? '**** **** ${_card!.last4Digits ?? '9018'}'),
                _buildRow('Valid from', _card!.validFrom ?? '10/15'),
                _buildRow('Good thru', _card!.expiresAtFormatted ?? '10/20'),
                _buildRow('Available balance', '\$${_card!.balance.toStringAsFixed(0)}'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: GestureDetector(
              onTap: _handleDelete,
              child: const Text(
                'Delete card',
                style: TextStyle(color: Colors.pinkAccent, fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 15)),
              Flexible(
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: Color(0xFF3B2F9F),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1, color: Colors.grey[200]),
      ],
    );
  }
}