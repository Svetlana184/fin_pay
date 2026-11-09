import 'package:flutter/material.dart';

import '../../services/deposit_service.dart';


class ManagementScreen extends StatefulWidget {
  const ManagementScreen({super.key});

  @override
  State<ManagementScreen> createState() => _ManagementScreenState();
}

class _ManagementScreenState extends State<ManagementScreen> {
  final _depositService = DepositService();
  List<Map<String, dynamic>> _deposits = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDeposits();
  }

  Future<void> _loadDeposits() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await _depositService.getDeposits();
      if (mounted) setState(() { _deposits = data; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Management',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadDeposits, child: const Text('Retry')),
          ],
        ),
      )
          : _deposits.isEmpty
          ? const Center(child: Text('Нет активных депозитов'))
          : RefreshIndicator(
        onRefresh: _loadDeposits,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ..._deposits.map((d) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildDepositCard(
                accountNumber: d['account_number'] ?? '—',
                fromDate: d['start_date'] ?? '—',
                toDate: d['end_date'] ?? '—',
                timeDeposit: '${d['term_months'] ?? 12} months',
                interestRate: '${d['interest_rate'] ?? 0}%',
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildDepositCard({
    required String accountNumber,
    required String fromDate,
    required String toDate,
    required String timeDeposit,
    required String interestRate,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Account',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                accountNumber,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildDetailRow('From', fromDate),
          const SizedBox(height: 12),
          _buildDetailRow('To', toDate),
          const SizedBox(height: 12),
          _buildDetailRow('Time deposit', timeDeposit),
          const SizedBox(height: 12),
          _buildDetailRow('Interest rate', interestRate),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF3B2F9F),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}