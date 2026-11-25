import 'api_client.dart';
import '../models/exchange_rate.dart';

class ExchangeService {
  final _client = ApiClient();

  /// GET /api/exchange-rates — ПУБЛИЧНЫЙ (в index.js без authenticateToken)
  Future<List<ExchangeRate>> getRates() async {
    final res = await _client.get('/api/exchange-rates', auth: false);
    final List<dynamic> items = res['data'] ?? [];
    return items.map((json) => ExchangeRate.fromJson(json)).toList();
  }

  /// Прямой или обратный курс. null — если пары нет в БД.
  double? findRate(List<ExchangeRate> rates, String from, String to) {
    if (from == to) return 1.0;
    final direct = rates.where((r) => r.currencyFrom == from && r.currencyTo == to);
    if (direct.isNotEmpty) return direct.first.rate;
    final inverse = rates.where((r) => r.currencyFrom == to && r.currencyTo == from);
    if (inverse.isNotEmpty) return 1.0 / inverse.first.rate;
    return null;
  }

  /// POST /api/exchange — выполнение конвертации (новый эндпоинт)
  Future<Map<String, dynamic>> convert({
    required String fromCurrency,
    required String toCurrency,
    required double amount,
    String? accountId,
  }) async {
    final res = await _client.post('/api/exchange', body: {
      'from_currency': fromCurrency,
      'to_currency': toCurrency,
      'amount': amount,
      if (accountId != null) 'account_id': accountId,
    });
    return res['data'] ?? {};
  }
}