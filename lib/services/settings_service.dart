import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import '../services/api_client.dart';

class SettingsService {
  final _client = ApiClient();
  final _storage = const FlutterSecureStorage();
  final _localAuth = LocalAuthentication();

  /// Смена пароля
  Future<Map<String, dynamic>> changePassword({
    required String recentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final res = await _client.post('/api/auth/change-password', body: {
        'recentPassword': recentPassword,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      });
      return {'success': true, 'message': res['message'] ?? 'Пароль изменен'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Проверка доступности биометрии
  Future<bool> canCheckBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (_) {
      return false;
    }
  }

  /// Аутентификация по биометрии
  Future<bool> authenticateWithBiometrics() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Подтвердите личность для входа в настройки',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
    } catch (_) {
      return false;
    }
  }

  /// Сохранение предпочтений биометрии
  Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(key: 'biometric_enabled', value: enabled.toString());
  }

  /// Получение состояния биометрии
  Future<bool> isBiometricEnabled() async {
    final value = await _storage.read(key: 'biometric_enabled');
    return value == 'true';
  }

  /// Сохранение языка
  Future<void> setLanguage(String languageCode) async {
    await _storage.write(key: 'app_language', value: languageCode);
  }

  /// Получение текущего языка
  Future<String> getLanguage() async {
    return await _storage.read(key: 'app_language') ?? 'ru';
  }

  /// Выход из системы
  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'biometric_enabled');
  }
}