import 'package:flutter/material.dart';
import '../../services/bill_service.dart';

class PaymentHistoryScreen extends StatefulWidget {
  final String initialType;
  const PaymentHistoryScreen({super.key, this.initialType = 'electric'});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  final _billService = BillService();

  // Типы вкладок (как на скринах)
  static const List<Map<String, dynamic>> _filterTypes = [
    {'id': 'electric',  'label': 'Electric',  'icon': Icons.electrical_services},
    {'id': 'water',     'label': 'Water',     'icon': Icons.water_drop},
    {'id': 'mobile',    'label': 'Mobile',    'icon': Icons.phone_android},
    {'id': 'internet',  'label': 'Internet',  'icon': Icons.wifi},
    {'id': 'tax',       'label': 'Tax',       'icon': Icons.receipt_long},
  ];

  String _selectedType = 'electric';
  List<Map<String, dynamic>> _payments = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _loading = true);
    try {
      final list = await _billService.getPaymentHistory(type: _selectedType);
      if (mounted) setState(() { _payments = list; _loading = false; });
    } catch (_) {
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
        title: const Text('Payment history',
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      body: Column(
        children: [
          // Горизонтальные вкладки-фильтры
          _buildFilterTabs(),
          const SizedBox(height: 16),

          // Список платежей
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _payments.isEmpty
                ? const Center(child: Text('Нет платежей', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _payments.length,
              itemBuilder: (context, i) => _buildPaymentCard(_payments[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _filterTypes.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final t = _filterTypes[i];
          final isSelected = _selectedType == t['id'];
          return GestureDetector(
            onTap: () {
              setState(() => _selectedType = t['id'] as String);
              _loadHistory();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF3B2F9F) : Colors.grey[200],
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Text(
                t['label'] as String,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPaymentCard(Map<String, dynamic> p) {
    final month = (p['month_name'] as String? ?? '').trim();
    final date = p['completed_date'] ?? '';
    final status = (p['status'] as String? ?? 'completed').toLowerCase();
    final isSuccess = status == 'completed' || status == 'success';
    final amount = double.tryParse(p['amount']?.toString() ?? '0') ?? 0;
    final company = p['company_name'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок: месяц + дата
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(month, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(date, style: TextStyle(color: Colors.grey[500], fontSize: 13)),
            ],
          ),
          const SizedBox(height: 12),
          // Status + Amount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('Status  ', style: TextStyle(color: Colors.grey, fontSize: 14)),
                  Text(
                    isSuccess ? 'Successfully' : 'Unsuccessfully',
                    style: TextStyle(
                      color: isSuccess ? const Color(0xFF3B2F9F) : Colors.pink,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Text('Amount  ', style: TextStyle(color: Colors.grey, fontSize: 14)),
                  Text(
                    '\$${amount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Color(0xFF3B2F9F),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Company (только для Internet/Mobile — как на скрине 2)
          if (company != null && company.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Company  ', style: TextStyle(color: Colors.grey, fontSize: 14)),
                Text(
                  company,
                  style: const TextStyle(
                    color: Color(0xFF3B2F9F),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}