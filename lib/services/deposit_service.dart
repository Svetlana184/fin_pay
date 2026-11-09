import 'api_client.dart';

class DepositService {
  final _client = ApiClient();

  Future<List<Map<String, dynamic>>> getDeposits() async {
    final res = await _client.get('/api/savings');
    return List<Map<String, dynamic>>.from(res['data'] ?? []);
  }
}