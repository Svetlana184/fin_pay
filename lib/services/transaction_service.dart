import '../models/transaction.dart';
import 'api_client.dart';

class TransactionService {
  final _client = ApiClient();

  Future<List<Transaction>> getTransactions({
    int limit = 20,
    int offset = 0,
    String? type,
  }) async {
    final query = <String, String>{
      'limit': limit.toString(),
      'offset': offset.toString(),
      // ИЗМЕНЕНО: if вместо ?type
      'type': ?type,
    };

    final res = await _client.get('/api/transactions', query: query);
    final List<dynamic> items = res['data'] ?? [];
    return items.map((json) => Transaction.fromJson(json)).toList();
  }

  Future<List<Transaction>> getIncomeTransactions({int limit = 20}) {
    return getTransactions(limit: limit, type: 'income');
  }

  Future<List<Transaction>> getExpenseTransactions({int limit = 20}) {
    return getTransactions(limit: limit, type: 'expense');
  }

  Future<List<Transaction>> getRecentTransactions({int count = 5}) {
    return getTransactions(limit: count, offset: 0);
  }

  Future<Transaction> getTransactionById(String id) async {
    final res = await _client.get('/api/transactions/$id');
    return Transaction.fromJson(res['data']);
  }

  Future<Map<String, dynamic>> transfer({
    required String fromCardId,
    required String toAccount,
    required double amount,
    required String recipientName,
    String? description,
    bool saveBeneficiary = false,
  }) async {
    final body = {
      'from_card_id': fromCardId,
      'to_account': toAccount,
      'amount': amount,
      'recipient_name': recipientName,
      // ИЗМЕНЕНО: if вместо ?description
      'description': ?description,
      'save_beneficiary': saveBeneficiary,
    };

    final res = await _client.post('/api/transactions/transfer', body: body);
    return res['data'] ?? {};
  }

  double calculateTotal(List<Transaction> transactions) {
    return transactions.fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double calculateIncome(List<Transaction> transactions) {
    return transactions
        .where((tx) => tx.isIncome)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double calculateExpense(List<Transaction> transactions) {
    return transactions
        .where((tx) => tx.isExpense)
        .fold(0.0, (sum, tx) => sum + tx.amount.abs());
  }

  Map<String, List<Transaction>> groupByDate(List<Transaction> transactions) {
    final grouped = <String, List<Transaction>>{};
    for (final tx in transactions) {
      final dateKey = _formatDateKey(tx.createdAt);
      grouped.putIfAbsent(dateKey, () => []).add(tx);
    }
    return grouped;
  }

  Map<String, List<Transaction>> groupByCategory(List<Transaction> transactions) {
    final grouped = <String, List<Transaction>>{};
    for (final tx in transactions) {
      final category = tx.categoryName ?? 'Без категории';
      grouped.putIfAbsent(category, () => []).add(tx);
    }
    return grouped;
  }

  String _formatDateKey(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final txDate = DateTime(date.year, date.month, date.day);

      if (txDate == today) return 'Сегодня';
      if (txDate == yesterday) return 'Вчера';
      return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}