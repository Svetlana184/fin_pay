import '../models/atm_location.dart';
import 'api_client.dart';

class AtmService {
  final _client = ApiClient();

  /// Список банкоматов/отделений.
  /// [city] — фильтр по городу (регистронезависимый),
  /// [type] — 'branch' / 'atm' / и т.п. (как в БД, поле atm_type),
  /// [limit] — максимум записей.
  Future<List<AtmLocation>> getAtms({
    String? city,
    String? type,
    int limit = 50,
  }) async {
    final query = <String, String>{
      'limit': limit.toString(),
      if (city != null && city.isNotEmpty) 'city': city,
      if (type != null && type.isNotEmpty) 'type': type,
    };

    final res = await _client.get('/api/atms', query: query, auth: false);
    final List<dynamic> items = res['data'] ?? [];
    return items
        .map((json) => AtmLocation.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}