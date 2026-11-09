class AtmLocation {
  final String id;
  final String atmCode;
  final String bankName;
  final String address;
  final String? city;
  final String? country;
  final double latitude;
  final double longitude;
  final String? atmType;
  final dynamic services; // JSONB — может быть строкой или списком
  final String? workingHours;
  final bool is247;

  AtmLocation({
    required this.id,
    required this.atmCode,
    required this.bankName,
    required this.address,
    this.city,
    this.country,
    required this.latitude,
    required this.longitude,
    this.atmType,
    this.services,
    this.workingHours,
    required this.is247,
  });

  factory AtmLocation.fromJson(Map<String, dynamic> json) {
    final rawServices = json['services'];
    List<String> servicesList = [];

    if (rawServices is List) {
      servicesList = rawServices.map((e) => e.toString()).toList();
    } else if (rawServices is String) {
      try {
        servicesList = (rawServices
            .replaceAll('[', '').replaceAll(']', '')
            .replaceAll('"', '').split(','))
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      } catch (_) {}
    }

    return AtmLocation(
      id: json['id'] as String,
      atmCode: (json['atm_code'] as String?) ?? '',
      bankName: (json['bank_name'] as String?) ?? '',
      address: (json['address'] as String?) ?? '',
      city: json['city'] as String?,
      country: json['country'] as String?,
      latitude: double.tryParse(json['latitude']?.toString() ?? '0') ?? 0.0,
      longitude: double.tryParse(json['longitude']?.toString() ?? '0') ?? 0.0,
      atmType: json['atm_type'] as String?,
      services: servicesList,
      workingHours: json['working_hours'] as String?,
      is247: (json['is_24_7'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'atm_code': atmCode,
    'bank_name': bankName,
    'address': address,
    'city': city,
    'country': country,
    'latitude': latitude,
    'longitude': longitude,
    'atm_type': atmType,
    'services': services,
    'working_hours': workingHours,
    'is_24_7': is247,
  };

  List<String> get servicesList => services is List ? List<String>.from(services) : [];
  bool get hasCashWithdrawal => servicesList.contains('cash_withdrawal');
  bool get hasBillPayment => servicesList.contains('bill_payment');
}