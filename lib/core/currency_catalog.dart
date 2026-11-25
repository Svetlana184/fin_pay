class CurrencyInfo {
  final String code;
  final String name;
  const CurrencyInfo(this.code, this.name);
}

class CurrencyCatalog {
  static const List<CurrencyInfo> all = [
    CurrencyInfo('VND', 'Viet Nam Dong'),
    CurrencyInfo('HKD', 'Hong Kong Dollar'),
    CurrencyInfo('USD', 'Dollar'),
    CurrencyInfo('NTS', 'Taiwan Dollar'),
    CurrencyInfo('JS',  'Jamaika Dollar'),
    CurrencyInfo('KRM', 'Korean Won'),
    CurrencyInfo('RUB', 'Russian Ruble'),
    CurrencyInfo('EUR', 'Euro'),
  ];

  static CurrencyInfo byCode(String code) =>
      all.firstWhere((c) => c.code == code,
          orElse: () => CurrencyInfo(code, code));
}