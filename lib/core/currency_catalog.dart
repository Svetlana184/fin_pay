class CurrencyInfo {
  final String code;
  final String name;
  final String flag;

  const CurrencyInfo({
    required this.code,
    required this.name,
    required this.flag,
  });
}

class CurrencyCatalog {
  static const Map<String, CurrencyInfo> _byCode = {
    'RUB': CurrencyInfo(code: 'RUB', name: 'Russian Ruble', flag: '🇷🇺'),
    'USD': CurrencyInfo(code: 'USD', name: 'US Dollar', flag: '🇺🇸'),
    'EUR': CurrencyInfo(code: 'EUR', name: 'Euro', flag: '🇪🇺'),
    'GBP': CurrencyInfo(code: 'GBP', name: 'British Pound', flag: '🇬🇧'),
    'CNY': CurrencyInfo(code: 'CNY', name: 'Chinese Yuan', flag: '🇨🇳'),
    'JPY': CurrencyInfo(code: 'JPY', name: 'Japanese Yen', flag: '🇯🇵'),
    'KZT': CurrencyInfo(code: 'KZT', name: 'Kazakhstani Tenge', flag: '🇰🇿'),
    'BYN': CurrencyInfo(code: 'BYN', name: 'Belarusian Ruble', flag: '🇧🇾'),
    'UAH': CurrencyInfo(code: 'UAH', name: 'Ukrainian Hryvnia', flag: '🇺🇦'),
    'TRY': CurrencyInfo(code: 'TRY', name: 'Turkish Lira', flag: '🇹🇷'),
    'CHF': CurrencyInfo(code: 'CHF', name: 'Swiss Franc', flag: '🇨🇭'),
    'AED': CurrencyInfo(code: 'AED', name: 'UAE Dirham', flag: '🇦🇪'),
    'INR': CurrencyInfo(code: 'INR', name: 'Indian Rupee', flag: '🇮🇳'),
    'KRW': CurrencyInfo(code: 'KRW', name: 'South Korean Won', flag: '🇰🇷'),
  };

  /// Возвращает информацию о валюте; для неизвестного кода — фолбэк.
  static CurrencyInfo byCode(String? code) {
    if (code == null || code.isEmpty) {
      return const CurrencyInfo(code: '—', name: 'Unknown', flag: '🏳️');
    }
    final upper = code.toUpperCase();
    return _byCode[upper] ??
        CurrencyInfo(code: upper, name: upper, flag: '🏳️');
  }
}