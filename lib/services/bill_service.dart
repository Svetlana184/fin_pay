import 'api_client.dart';
import '../models/tax_bill.dart';
import '../models/bill_profile.dart';

class BillService {
  final _client = ApiClient();

  /// Получить профили плательщика
  Future<List<BillProfile>> getProfiles() async {
    final res = await _client.get('/api/bills/profiles');
    final List<dynamic> items = res['data'] ?? [];
    return items.map((json) => BillProfile.fromJson(json)).toList();
  }

  /// Найти счёт по коду (нужен новый эндпоинт на бэкенде)
  Future<Map<String, dynamic>> findBillByCode(String code) async {
    try {
      final res = await _client.get('/api/bills/find', query: {'code': code});
      return res['data'] ?? {};
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// Оплатить счёт
  Future<Map<String, dynamic>> payBill({
    required String billId,
    required String accountId,
    required double amount,
    required String otpCode,
  }) async {
    try {
      final res = await _client.post('/api/bills/pay', body: {
        'bill_id': billId,
        'account_id': accountId,
        'amount': amount,
        'otp_code': otpCode,
      });
      return {'success': true, 'data': res['data']};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Оплатить налог
  Future<Map<String, dynamic>> payTax({
    required String taxBillId,
    required String accountId,
    required double amount,
    required String otpCode,
  }) async {
    try {
      final res = await _client.post('/api/bills/pay', body: {
        'tax_bill_id': taxBillId,
        'account_id': accountId,
        'amount': amount,
        'otp_code': otpCode,
      });
      return {'success': true, 'data': res['data']};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Получить список налоговых счетов пользователя
  Future<List<TaxBill>> getTaxBills() async {
    try {
      final res = await _client.get('/api/tax-bills');
      final List<dynamic> items = res['data'] ?? [];
      return items.map((json) => TaxBill.fromJson(json)).toList();
    } catch (e) {
      return _getDemoTaxBills();
    }
  }

  List<TaxBill> _getDemoTaxBills() {
    return [
      TaxBill(
        id: 'tax1',
        userId: 'user1',
        taxType: 'property',
        taxAuthority: 'ИФНС № 5 по г. Москве',
        userTaxId: '771234567890',
        assessmentYear: 2025,
        objectDescription: 'Квартира 65м²',
        assessedAmount: 12500,
        penalty: 0,
        discount: 0,
        totalAmount: 12500,
        currency: 'RUB',
        status: 'pending',
        issueDate: '2026-09-01',
        dueDate: '2026-12-01',
        createdAt: '2026-09-01',
      ),
    ];
  }
}