class ExchangeRate {
  final String currencyFrom;
  final String currencyTo;
  final double rate;
  final String validFrom;
  final String? validUntil;

  ExchangeRate({
    required this.currencyFrom,
    required this.currencyTo,
    required this.rate,
    required this.validFrom,
    this.validUntil,
  });

  factory ExchangeRate.fromJson(Map<String, dynamic> json) {
    return ExchangeRate(
      currencyFrom: (json['currency_from'] as String?) ?? '',
      currencyTo: (json['currency_to'] as String?) ?? '',
      rate: double.tryParse(json['rate']?.toString() ?? '0') ?? 0.0,
      validFrom: (json['valid_from'] as String?) ?? '',
      validUntil: json['valid_until'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'currency_from': currencyFrom,
    'currency_to': currencyTo,
    'rate': rate,
    'valid_from': validFrom,
    'valid_until': validUntil,
  };

  String get pair => '$currencyFrom/$currencyTo';
  double convert(double amount) => amount * rate;
}