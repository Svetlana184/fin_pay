import '../models/exchange_rate.dart';
import 'api_client.dart';

class ExchangeService {
  final _client = ApiClient();

  Future<List<ExchangeRate>> getRates() async {
    final res = await _client.get('/api/exchange-rates', auth: false);
    final List<dynamic> items = res['data'] ?? [];
    return items
        .map((json) => ExchangeRate.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}