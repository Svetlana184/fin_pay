import 'package:flutter/material.dart' hide Card;
import 'package:fl_chart/fl_chart.dart';
import '../../models/card.dart';
import '../../models/transaction.dart';
import '../../services/card_service.dart';
import '../../services/transaction_service.dart';

class TransactionReportScreen extends StatefulWidget {
  const TransactionReportScreen({super.key});

  @override
  State<TransactionReportScreen> createState() => _TransactionReportScreenState();
}

class _TransactionReportScreenState extends State<TransactionReportScreen> {
  final _cardService = CardService();
  final _txService = TransactionService();

  Card? _card;
  List<Transaction> _transactions = [];
  bool _loading = true;
  int _selectedMonth = 3; // Apr (0-indexed: Jan=0)

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
        _txService.getTransactions(limit: 50),
      ]);
      if (mounted) {
        setState(() {
          final cards = results[0] as List<Card>;
          _card = cards.isNotEmpty ? cards.first : null;
          _transactions = results[1] as List<Transaction>;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  // Демо-данные баланса по месяцам (в prod — агрегация из API)
  List<_MonthBalance> get _monthlyBalances => [
    _MonthBalance('Jan', 400, 200),
    _MonthBalance('Feb', 600, 300),
    _MonthBalance('Mar', 800, 500),
    _MonthBalance('Apr', 500, 250),
    _MonthBalance('May', 700, 350),
    _MonthBalance('Jun', 600, 300),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF3B2F9F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Transaction report',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildCard(),
            const SizedBox(height: 24),
            _buildBalanceChart(),
            const SizedBox(height: 24),
            _buildTransactionsList(),
          ],
        ),
      ),
    );
  }

  // === Карта ===
  Widget _buildCard() {
    final card = _card;
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A4E), Color(0xFF2F7CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: const Color(0xFF3B2F9F).withOpacity(0.3), blurRadius: 14, offset: const Offset(0, 6))],
      ),
      child: Stack(
        children: [
          Positioned(right: -30, top: -30, child: Container(width: 160, height: 160, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.2)))),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(card?.holderName ?? 'John Smith', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    const Text('Amazon Platinium', style: TextStyle(color: Colors.white, fontSize: 13)),
                    const SizedBox(height: 16),
                    Text('4756 •••• •••• ${card?.last4Digits ?? '9018'}', style: const TextStyle(color: Colors.white, fontSize: 17, letterSpacing: 2)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('\$${card?.balance.toStringAsFixed(2) ?? '3469.52'}', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    const Text('VISA', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // === График баланса ===
  Widget _buildBalanceChart() {
    final totalBalance = _monthlyBalances.fold<double>(0, (sum, m) => sum + m.income - m.expense);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Balance', style: TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              children: [
                TextSpan(text: totalBalance.toInt().toString(), style: const TextStyle(color: Color(0xFF3B2F9F))),
                const TextSpan(text: ' USD', style: TextStyle(fontSize: 16, color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 1000,
                barGroups: _monthlyBalances.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final m = entry.value;
                  final isSelected = idx == _selectedMonth;
                  return BarChartGroupData(
                    x: idx,
                    barRods: [
                      BarChartRodData(
                        toY: m.income.toDouble(),
                        color: isSelected ? const Color(0xFF3B2F9F) : const Color(0xFF3B2F9F).withOpacity(0.4),
                        width: 10,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                      BarChartRodData(
                        toY: -m.expense.toDouble(),
                        color: isSelected ? Colors.pink : Colors.pink.withOpacity(0.4),
                        width: 10,
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(4)),
                      ),
                    ],
                  );
                }).toList(),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= _monthlyBalances.length) return const SizedBox.shrink();
                        final m = _monthlyBalances[idx];
                        final isSelected = idx == _selectedMonth;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(m.label,
                              style: TextStyle(
                                color: isSelected ? const Color(0xFF3B2F9F) : Colors.grey,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 12,
                              )),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 250, getDrawingHorizontalLine: (_) => FlLine(color: Colors.grey[200]!, strokeWidth: 1)),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // === Список транзакций по дням ===
  Widget _buildTransactionsList() {
    // Группируем: сегодня и вчера
    final now = DateTime.now();
    final today = _transactions.where((t) => _isSameDay(t.createdAt as DateTime, now)).toList();
    final yesterday = _transactions.where((t) => _isSameDay(t.createdAt as DateTime, now.subtract(const Duration(days: 1)))).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (today.isNotEmpty) ...[
          const Text('Today', style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ...today.map((t) => _buildTransactionTile(t)),
        ],
        if (yesterday.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text('Yesterday', style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ...yesterday.map((t) => _buildTransactionTile(t)),
        ],
        if (today.isEmpty && yesterday.isEmpty)
          const Center(child: Padding(padding: EdgeInsets.all(40), child: Text('Нет транзакций'))),
      ],
    );
  }

  Widget _buildTransactionTile(Transaction tx) {
    final isIncome = tx.isIncome;
    final color = _colorForCategory(tx.categoryName ?? '');
    final icon = _iconForCategory(tx.categoryName ?? tx.counterpartyName ?? '');
    final statusText = tx.status == 'completed' ? 'Successfully' : 'Unsuccessfully';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.counterpartyName ?? tx.categoryName ?? 'Transaction',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(statusText, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : '-'}\$${tx.amount.abs().toStringAsFixed(0)}',
            style: TextStyle(
              color: isIncome ? const Color(0xFF3B2F9F) : Colors.pink,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Color _colorForCategory(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('water')) return const Color(0xFF3B2F9F);
    if (lower.contains('electric')) return const Color(0xFF2196F3);
    if (lower.contains('internet')) return const Color(0xFF4DB6AC);
    if (lower.contains('income') || lower.contains('salary')) return const Color(0xFFE91E63);
    if (lower.contains('jane')) return const Color(0xFFFF9800);
    return const Color(0xFF9C27B0);
  }

  IconData _iconForCategory(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('water')) return Icons.water_drop;
    if (lower.contains('electric')) return Icons.bolt;
    if (lower.contains('internet')) return Icons.wifi;
    if (lower.contains('income') || lower.contains('salary')) return Icons.attach_money;
    if (lower.contains('jane') || lower.contains('transfer')) return Icons.swap_horiz;
    return Icons.receipt_long;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _MonthBalance {
  final String label;
  final double income;
  final double expense;
  const _MonthBalance(this.label, this.income, this.expense);
}