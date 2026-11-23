import 'package:flutter/material.dart';
import '../../core/currency_catalog.dart';
import '../../models/exchange_rate.dart';
import '../../services/exchange_service.dart';

class ExchangeRateScreen extends StatefulWidget {
  const ExchangeRateScreen({super.key});
  @override
  State<ExchangeRateScreen> createState() => _ExchangeRateScreenState();
}

class _ExchangeRateScreenState extends State<ExchangeRateScreen> {
  final _service = ExchangeService();
  List<ExchangeRate> _rates = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final r = await _service.getRates();
      if (mounted) setState(() { _rates = r; _loading = false; });
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50], elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87), onPressed: () => Navigator.pop(context)),
        title: const Text('Exchange rate', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          _headerRow(),
          Expanded(
            child: ListView.separated(
              itemCount: _rates.length,
              separatorBuilder: (_, _) => Divider(height: 1, color: Colors.grey[200]),
              itemBuilder: (context, i) {
                final r = _rates[i];
                final info = CurrencyCatalog.byCode(r.currencyTo);
                final buy = r.rate * 0.98;   // имитация спредов buy/sell
                final sell = r.rate * 1.02;
                return ListTile(
                  leading: Text(info.flag, style: const TextStyle(fontSize: 24)),
                  title: Text(info.name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(width: 70, child: Text(buy.toStringAsFixed(3), textAlign: TextAlign.right)),
                      SizedBox(width: 70, child: Text(sell.toStringAsFixed(3), textAlign: TextAlign.right)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          const Expanded(child: Text('Country', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
          const SizedBox(width: 30, child: Text('Buy', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
          const SizedBox(width: 70, child: Text('Sell', textAlign: TextAlign.right, style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}