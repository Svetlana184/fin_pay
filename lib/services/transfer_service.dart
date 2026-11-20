import 'api_client.dart';
import '../models/transfer_recipient.dart';

class TransferService {
  final _client = ApiClient();

  /// Получить список получателей
  Future<List<TransferRecipient>> getBeneficiaries() async {
    try {
      final res = await _client.get('/api/transfer-recipients');
      final List<dynamic> items = res['data'] ?? [];
      return items.map((json) => TransferRecipient.fromJson(json)).toList();
    } catch (e) {
      // Демо-данные если API недоступен
      return _getDemoRecipients();
    }
  }

  /// Добавить получателя
  Future<void> addBeneficiary({
    required String name,
    required String account,
    String? bank,
  }) async {
    await _client.post('/api/transfer-recipients', body: {
      'recipient_name': name,
      'recipient_account': account,
      'recipient_bank': bank,
    });
  }

  /// Выполнить перевод
  Future<Map<String, dynamic>> transfer({
    required String fromCardId,
    required String toAccount,
    required double amount,
    required String recipientName,
    String? description,
    bool saveBeneficiary = false,
  }) async {
    try {
      final res = await _client.post('/api/transactions/transfer', body: {
        'from_card_id': fromCardId,
        'to_account': toAccount,
        'amount': amount,
        'recipient_name': recipientName,
        'description': description,
        'save_beneficiary': saveBeneficiary,
      });
      return {'success': true, 'data': res['data']};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Конвертация суммы в текст (упрощённая)
  String amountToWords(double amount) {
    final whole = amount.toInt();
    final cents = ((amount - whole) * 100).round();

    final words = _convertNumber(whole);

    if (cents > 0) {
      return '$words and ${_convertNumber(cents)} cents';
    }
    return words;
  }

  String _convertNumber(int num) {
    if (num == 0) return 'zero';
    if (num == 1) return 'one';
    if (num == 2) return 'two';
    if (num == 3) return 'three';
    if (num == 4) return 'four';
    if (num == 5) return 'five';
    if (num == 6) return 'six';
    if (num == 7) return 'seven';
    if (num == 8) return 'eight';
    if (num == 9) return 'nine';
    if (num == 10) return 'ten';
    if (num == 11) return 'eleven';
    if (num == 12) return 'twelve';
    if (num == 13) return 'thirteen';
    if (num == 14) return 'fourteen';
    if (num == 15) return 'fifteen';
    if (num == 16) return 'sixteen';
    if (num == 17) return 'seventeen';
    if (num == 18) return 'eighteen';
    if (num == 19) return 'nineteen';
    if (num == 20) return 'twenty';
    if (num == 30) return 'thirty';
    if (num == 40) return 'forty';
    if (num == 50) return 'fifty';
    if (num == 60) return 'sixty';
    if (num == 70) return 'seventy';
    if (num == 80) return 'eighty';
    if (num == 90) return 'ninety';
    if (num == 100) return 'one hundred';
    if (num == 1000) return 'one thousand';

    if (num > 1000) {
      final thousands = num ~/ 1000;
      final remainder = num % 1000;
      return '${_convertNumber(thousands)} thousand ${_convertNumber(remainder)}';
    }

    if (num > 100) {
      final hundreds = num ~/ 100;
      final remainder = num % 100;
      return '${_convertNumber(hundreds)} hundred ${_convertNumber(remainder)}';
    }

    if (num > 20) {
      final tens = (num ~/ 10) * 10;
      final units = num % 10;
      return '${_convertNumber(tens)} ${_convertNumber(units)}';
    }

    return num.toString();
  }

  List<TransferRecipient> _getDemoRecipients() {
    return [
      TransferRecipient(
        id: 'r1',
        userId: 'user1',
        recipientName: 'Emma',
        recipientAccount: '0123456789109',
        recipientBank: 'FinPay Bank',
        isFavorite: true,
        createdAt: DateTime.now().toIso8601String(),
      ),
      TransferRecipient(
        id: 'r2',
        userId: 'user1',
        recipientName: 'Justin',
        recipientAccount: '0987654321098',
        recipientBank: 'FinPay Bank',
        isFavorite: true,
        createdAt: DateTime.now().toIso8601String(),
      ),
    ];
  }

}