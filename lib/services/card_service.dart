import 'api_client.dart';

class CardService {
  final _client = ApiClient();

  Future<List<Map<String, dynamic>>> getCards() async {
    final res = await _client.get('/api/cards');
    return List<Map<String, dynamic>>.from(res['data'] ?? []);
  }

  Future<Map<String, dynamic>> getCardDetails(String cardId) async {
    final res = await _client.get('/api/cards/$cardId');
    return res['data'];
  }

  Future<Map<String, dynamic>> updateCardStatus(String cardId, String status) async {
    final res = await _client.patch('/api/cards/$cardId/status', body: {'status': status});
    return res['data'];
  }

  Future<void> deleteCard(String cardId) async {
    await _client.delete('/api/cards/$cardId');
  }
}