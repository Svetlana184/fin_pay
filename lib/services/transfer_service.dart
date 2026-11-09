import '../models/transfer_recipient.dart';
import 'api_client.dart';

class TransferService {
  final _client = ApiClient();

  Future<List<TransferRecipient>> getBeneficiaries() async {
    final res = await _client.get('/api/beneficiaries');
    return (res['data'] as List).map((e) => TransferRecipient.fromJson(e)).toList();
  }

  Future<void> transfer({
    required String fromCardId,
    required String toAccount,
    required double amount,
    required String recipientName,
    String? description,
    bool saveBeneficiary = false,
  }) async {
    await _client.post('/api/transactions/transfer', body: {
      'from_card_id': fromCardId,
      'to_account': toAccount,
      'amount': amount,
      'recipient_name': recipientName,
      'description': description,
      'save_beneficiary': saveBeneficiary,
    });
  }

  Future<void> addBeneficiary({
    required String name,
    required String account,
    String? bank,
  }) async {
    await _client.post('/api/beneficiaries', body: {
      'recipient_name': name,
      'recipient_account': account,
      'recipient_bank': bank,
    });
  }
}