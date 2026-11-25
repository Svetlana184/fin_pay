import 'api_client.dart';
import '../models/beneficiary.dart';
import 'card_service.dart';
import 'beneficiary_service.dart';

class MobilePrepaidService {
  final _client = ApiClient();
  final _cardService = CardService();
  final _beneficiaryService = BeneficiaryService();

  /// Карты для источника списания
  Future<List<Map<String, dynamic>>> getCards() => _cardService.getCards();

  /// Directory получателей (Emma, Justin и т.д.)
  Future<List<Beneficiary>> getBeneficiaries() => _beneficiaryService.getBeneficiaries();

  /// Демо-OTP (в prod — SMS)
  Future<String> getOtp() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return '123456';
  }

  /// Пополнение телефона
  /// POST /api/mobile-prepaid/recharge
  Future<Map<String, dynamic>> recharge({
    required String accountId,
    required String phone,
    required double amount,
    String? otpCode,
    bool biometricVerified = false,
  }) async {
    try {
      final res = await _client.post('/api/mobile-prepaid/recharge', body: {
        'account_id': accountId,
        'phone': phone,
        'amount': amount,
        'otp_code': otpCode,
        'biometric_verified': biometricVerified,
      });
      return {'success': true, 'data': res['data']};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}