import 'api_client.dart';
import '../models/beneficiary.dart';

class BeneficiaryService {
  final _client = ApiClient();

  /// Получить всех бенефициаров
  Future<List<Beneficiary>> getBeneficiaries() async {
    try {
      final res = await _client.get('/api/beneficiaries');
      final List<dynamic> items = res['data'] ?? [];
      return items.map((json) => Beneficiary.fromJson(json)).toList();
    } catch (e) {
      return _getDemoBeneficiaries();
    }
  }

  /// Добавить нового бенефициара
  Future<Map<String, dynamic>> addBeneficiary({
    required String name,
    required String cardNumber,
    required String transferType,
    String? bankName,
    String? branchName,
  }) async {
    try {
      final res = await _client.post('/api/beneficiaries', body: {
        'recipient_name': name,
        'recipient_account': cardNumber,
        'transfer_type': transferType,
        'recipient_bank': bankName,
        'branch_name': branchName,
      });
      return {'success': true, 'data': res['data']};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Удалить бенефициара
  Future<void> deleteBeneficiary(String id) async {
    await _client.delete('/api/beneficiaries/$id');
  }

  List<Beneficiary> _getDemoBeneficiaries() {
    return [
      Beneficiary(
        id: 'b1',
        name: 'Push',
        cardNumber: '12788980890',
        transferType: 'card_number',
        createdAt: DateTime.now(),
      ),
      Beneficiary(
        id: 'b2',
        name: 'Olivia',
        cardNumber: '03445976231',
        transferType: 'card_number',
        createdAt: DateTime.now(),
      ),
      Beneficiary(
        id: 'b3',
        name: 'Alexander',
        cardNumber: '12788980890',
        transferType: 'same_bank',
        createdAt: DateTime.now(),
      ),
      Beneficiary(
        id: 'b4',
        name: 'Harper',
        cardNumber: '03445976231',
        transferType: 'same_bank',
        createdAt: DateTime.now(),
      ),
      Beneficiary(
        id: 'b5',
        name: 'Thomas',
        cardNumber: '12788980890',
        transferType: 'another_bank',
        createdAt: DateTime.now(),
      ),
      Beneficiary(
        id: 'b6',
        name: 'Sanmatha',
        cardNumber: '03445976231',
        transferType: 'another_bank',
        createdAt: DateTime.now(),
      ),
      Beneficiary(
        id: 'b7',
        name: 'Justin Biber',
        cardNumber: '12788980890',
        transferType: 'another_bank',
        createdAt: DateTime.now(),
      ),
    ];
  }
}