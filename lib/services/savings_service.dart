import 'api_client.dart';
import '../models/savings_account.dart';

class SavingsService {
  final _client = ApiClient();

  /// Получить список активных депозитов
  Future<List<SavingsAccount>> getDeposits() async {
    try {
      final res = await _client.get('/api/savings');
      final List<dynamic> items = res['data'] ?? [];
      return items.map((json) => SavingsAccount.fromJson(json)).toList();
    } catch (e) {
      return _getDemoDeposits();
    }
  }

  /// Создать новый вклад
  Future<Map<String, dynamic>> createDeposit({
    required String accountId,
    required int termMonths,
    required double amount,
    required double interestRate,
  }) async {
    try {
      final res = await _client.post('/api/savings', body: {
        'account_id': accountId,
        'term_months': termMonths,
        'amount': amount,
        'interest_rate': interestRate,
        'account_type': 'deposit',
      });
      return {'success': true, 'data': res['data']};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  List<SavingsAccount> _getDemoDeposits() {
    return [
      SavingsAccount(
        id: 'dep1',
        userId: 'user1',
        accountNumber: '1900 8988 5456',
        accountType: 'deposit',
        balance: 50000,
        currency: 'USD',
        interestRate: 5.0,
        startDate: DateTime.now().subtract(const Duration(days: 180)).toIso8601String(),
        endDate: DateTime.now().add(const Duration(days: 180)).toIso8601String(),
        termMonths: 12,
        status: 'active',
        minBalance: 1000,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      ),
    ];
  }
}