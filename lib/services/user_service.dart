import 'api_client.dart';

class UserService {
  final _client = ApiClient();

  Future<Map<String, dynamic>> getProfile() async {
    final res = await _client.get('/api/users/me');
    return res['data'];
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final res = await _client.put('/api/users/me', body: data);
    return res['data'];
  }
}