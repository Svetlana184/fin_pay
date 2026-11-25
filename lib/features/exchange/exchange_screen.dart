import 'package:flutter/material.dart';
import '../../core/currency_catalog.dart';
import '../../models/exchange_rate.dart';
import '../../services/exchange_service.dart';

class ExchangeScreen extends StatefulWidget {
  const ExchangeScreen({super.key});

  @override
  State<ExchangeScreen> createState() => _ExchangeScreenState();
}

class _ExchangeScreenState extends State<ExchangeScreen> {
  final _service = ExchangeService();
  final _fromController = TextEditingController();
  final _toController = TextEditingController();

  List<ExchangeRate> _rates = [];
  String _fromCode = 'USD';
  String _toCode = 'USD';
  bool _loading = true;
  bool _editingFrom = true; // поле, из которого считаем

  @override
  void initState() {
    super.initState();
    _loadRates();
  }

  Future<void> _loadRates() async {
    setState(() => _loading = true);
    try {
      final rates = await _service.getRates();
      if (mounted) setState(() { _rates = rates; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  double? get _rate => _service.findRate(_rates, _fromCode, _toCode);

  double? get _amount {
    final src = _editingFrom ? _fromController.text : _toController.text;
    return double.tryParse(src.replaceAll(',', '').trim());
  }

  bool get _canExchange => _amount != null && _amount! > 0 && _rate != null;

  void _recalculate() {
    final rate = _rate;
    if (rate == null) return;
    if (_editingFrom) {
      final a = double.tryParse(_fromController.text) ?? 0;
      _toController.text = (a * rate).toStringAsFixed(2);
    } else {
      final a = double.tryParse(_toController.text) ?? 0;
      _fromController.text = (a / rate).toStringAsFixed(2);
    }
    setState(() {});
  }

  void _swap() {
    setState(() {
      final tmp = _fromCode;
      _fromCode = _toCode;
      _toCode = tmp;
      _recalculate();
    });
  }

  Future<void> _pickCurrency({required bool isFrom}) async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CurrencyPickerSheet(
        selected: isFrom ? _fromCode : _toCode,
        onPick: (code) => Navigator.pop(ctx, code),
      ),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) { _fromCode = picked; _editingFrom = true; }
        else { _toCode = picked; _editingFrom = false; }
        _recalculate();
      });
    }
  }

  Future<void> _onExchange() async {
    final result = await _service.convert(
      fromCurrency: _fromCode,
      toCurrency: _toCode,
      amount: _amount!,
    );
    if (!mounted) return;
    final converted = result['converted_amount'] ?? _toController.text;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Конвертация: $_amount $_fromCode → $converted $_toCode'),
        backgroundColor: Colors.green,
      ),
    );
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
        title: const Text('Exchange',
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
            _buildConverterCard(),
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
          Positioned(left: 24, top: 40, child: Icon(Icons.currency_bitcoin, size: 44, color: Colors.amber.shade300)),
          Positioned(right: 24, top: 30, child: Icon(Icons.monetization_on, size: 44, color: Colors.amber)),
          Positioned(bottom: 30, left: 40, child: Icon(Icons.groups, size: 44, color: const Color(0xFF3B2F9F).withOpacity(0.5))),
          Positioned(bottom: 30, right: 40, child: Icon(Icons.groups, size: 44, color: const Color(0xFF3B2F9F).withOpacity(0.5))),
          Container(
            height: 160, width: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF3B2F9F), width: 3),
            ),
            child: const Icon(Icons.swap_horiz, size: 50, color: Color(0xFF3B2F9F)),
          ),
        ],
      ),
    );
  }

  Widget _buildConverterCard() {
    final rate = _rate;
    final showRate = _canExchange && rate != null;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
      ),
      child: Column(
        children: [
          _buildField('From', _fromController, _fromCode, true, () { _editingFrom = true; _recalculate(); }),
          const SizedBox(height: 4),
          IconButton(
            onPressed: _swap,
            icon: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_downward, color: Color(0xFF3B2F9F)),
                Icon(Icons.arrow_upward, color: Colors.pink),
              ],
            ),
          ),
          const SizedBox(height: 4),
          _buildField('To', _toController, _toCode, false, () { _editingFrom = false; _recalculate(); }),
          // Строка курса — только когда есть сумма и валидный курс (скрин 2)
          if (showRate) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Currency rate',
                    style: TextStyle(color: Color(0xFF3B2F9F), fontWeight: FontWeight.w600)),
                Text(
                  '1 $_fromCode = ${rate!.toStringAsFixed(0)} $_toCode',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _canExchange ? _onExchange : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _canExchange
                    ? const Color(0xFF3B2F9F)
                    : const Color(0xFF3B2F9F).withOpacity(0.15),
                foregroundColor: _canExchange ? Colors.white : Colors.white70,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Exchange',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, String code,
      bool isFrom, VoidCallback onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: ctrl,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => onChanged(),
                  decoration: const InputDecoration(
                    hintText: 'Amount',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
              InkWell(
                onTap: () => _pickCurrency(isFrom: isFrom),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  child: Row(
                    children: [
                      Text(code, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const Icon(Icons.unfold_more, size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }
}

/// Bottom sheet «Select the currency» (скрин 3)
class _CurrencyPickerSheet extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onPick;
  const _CurrencyPickerSheet({required this.selected, required this.onPick});

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
                children: [
                  const Expanded(
                    child: Text('Select the currency',
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
                children: CurrencyCatalog.all.map((c) {
                  final isSelected = c.code == selected;
                  return ListTile(
                    // Формат как на скрине: "VND ( Viet Nam Dong )"
                    title: Text(
                      '${c.code} ( ${c.name} )',
                      style: TextStyle(
                        color: isSelected ? const Color(0xFF3B2F9F) : Colors.black87,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    trailing: isSelected ? const Icon(Icons.check, color: Color(0xFF3B2F9F)) : null,
                    onTap: () => onPick(c.code),
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