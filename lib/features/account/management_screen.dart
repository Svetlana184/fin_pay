import 'package:fin_pay/models/savings_account.dart';
import 'package:flutter/material.dart' hide Card;
import '../../services/savings_service.dart';

class ManagementScreen extends StatefulWidget {
  const ManagementScreen({super.key});

  @override
  State<ManagementScreen> createState() => _ManagementScreenState();
}

class _ManagementScreenState extends State<ManagementScreen> {
  final _service = SavingsService();
  List<SavingsAccount> _deposits = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = await _service.getDeposits();
      if (mounted) setState(() { _deposits = list; _loading = false; });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
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
        title: const Text('Management',
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _deposits.isEmpty
          ? const Center(child: Text('Нет активных вкладов', style: TextStyle(color: Colors.grey)))
          : ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _deposits.length,
        itemBuilder: (context, i) => _buildDepositCard(_deposits[i]),
      ),
    );
  }

  Widget _buildDepositCard(SavingsAccount acc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(acc.accountNumber,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 14),
          _row('From', acc.startDate),
          _row('To', acc.endDate),
          _row('Time deposit', '${acc.termMonths ?? 12} months'),
          _row('Interest rate', '${(acc.interestRate ?? 5).toStringAsFixed(0)}%'),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          Text(value,
              style: const TextStyle(
                  color: Color(0xFF3B2F9F), fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}