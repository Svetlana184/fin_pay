import 'api_client.dart';
import '../models/credit_card_transaction.dart';

class CreditCardService {
  final _client = ApiClient();

  /// Получить список карт пользователя
  Future<List<CreditCardInfo>> getCards() async {
    final res = await _client.get('/api/cards');
    final List<dynamic> items = res['data'] ?? [];
    return items.map((json) => CreditCardInfo.fromJson(json)).toList();
  }

  /// Получить транзакции (демо-данные для кредитной карты)
  Future<List<CreditCardTransaction>> getTransactions() async {
    // В реальном приложении: GET /api/transactions?type=expense
    // Для демо используем захардкоженные данные как на скриншоте
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      CreditCardTransaction(
        id: 'tx1',
        title: 'Buy Camera',
        date: '02/11/2018',
        amount: 1200,
        icon: 'camera',
        iconColor: '0xFF3B2F9F',
      ),
      CreditCardTransaction(
        id: 'tx2',
        title: 'Buy Television',
        date: '02/11/2018',
        amount: 1200,
        icon: 'tv',
        iconColor: '0xFFFF4757',
      ),
      CreditCardTransaction(
        id: 'tx3',
        title: 'Buy Camera',
        date: '02/11/2018',
        amount: 1200,
        icon: 'camera',
        iconColor: '0xFF1890FF',
      ),
      CreditCardTransaction(
        id: 'tx4',
        title: 'Buy Television',
        date: '02/11/2018',
        amount: 1200,
        icon: 'tv',
        iconColor: '0xFFFFA500',
      ),
    ];
  }

  /// Получить OTP код (демо)
  Future<String> getOTP() async {
    await Future.delayed(const Duration(seconds: 1));
    return '123456'; // Демо OTP
  }

  /// Оплатить с OTP верификацией
  Future<Map<String, dynamic>> payWithOTP({
    required String accountId,
    required double amount,
    required String otpCode,
  }) async {
    try {
      final res = await _client.post('/api/bills/pay', body: {
        'account_id': accountId,
        'amount': amount,
        'otp_code': otpCode,
        'bill_id': null,
        'tax_bill_id': null,
      });
      return {'success': true, 'data': res['data']};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}