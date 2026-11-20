import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const String baseUrl = 'http://192.168.1.185:3000';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Регистрация
  Future<Map<String, dynamic>> register({
    required String phone,
    required String fullName,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': phone,
          'fullName': fullName,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        // Сохраняем токен
        await _storage.write(key: 'auth_token', value: data['data']['token']);
        return {'success': true, 'data': data['data']};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Ошибка регистрации'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Ошибка соединения с сервером'};
    }
  }

  // Вход
  Future<Map<String, dynamic>> login({
    required String phone,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await _storage.write(key: 'auth_token', value: data['data']['token']);
        return {'success': true, 'data': data['data']};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Ошибка входа'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Ошибка соединения с сервером'};
    }
  }

  // Получение профиля
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final token = await _storage.read(key: 'auth_token');

      final response = await http.get(
        Uri.parse('$baseUrl/api/users/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data['data']};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Ошибка получения профиля'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Ошибка соединения с сервером'};
    }
  }

  // Обновление профиля
  Future<Map<String, dynamic>> updateProfile({
    String? email,
    String? city,
    String? country,
    String? avatarUrl,
  }) async {
    try {
      final token = await _storage.read(key: 'auth_token');

      final response = await http.put(
        Uri.parse('$baseUrl/api/users/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'email': ?email,
          'city': ?city,
          'country': ?country,
          'avatar_url': ?avatarUrl,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data['data']};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Ошибка обновления профиля'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Ошибка соединения с сервером'};
    }
  }

  // Изменение пароля (нужно добавить на бэкенде)
  Future<Map<String, dynamic>> changePassword({
    required String recentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    // Пока заглушка - нужно добавить endpoint на бэкенде
    try {
      final token = await _storage.read(key: 'auth_token');

      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/change-password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'recentPassword': recentPassword,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Пароль успешно изменен'};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Ошибка изменения пароля'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Ошибка соединения с сервером'};
    }
  }

  // Выход
  Future<void> logout(BuildContext context) async {
    await _storage.delete(key: 'auth_token');
    // Используем go для замены всего стека
    // ignore: use_build_context_synchronously
    context.go('/login');
  }

  // Получение токена
  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }
}