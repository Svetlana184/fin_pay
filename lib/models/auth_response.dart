import 'user.dart';

class AuthResponse {
  final User user;
  final String token;

  AuthResponse({required this.user, required this.token});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return AuthResponse(
      user: User.fromJson(data['user'] as Map<String, dynamic>? ?? data),
      token: (data['token'] as String?) ?? (json['token'] as String?) ?? '',
    );
  }
}

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;
  final String? message;

  ApiResponse({
    required this.success,
    this.data,
    this.error,
    this.message,
  });

  factory ApiResponse.fromJson(
      Map<String, dynamic> json, {
        T Function(Map<String, dynamic>)? fromJson,
        T Function(List<dynamic>)? fromJsonList,
      }) {
    T? parsedData;
    final rawData = json['data'];

    if (rawData is Map<String, dynamic> && fromJson != null) {
      parsedData = fromJson(rawData);
    } else if (rawData is List && fromJsonList != null) {
      parsedData = fromJsonList(rawData);
    } else if (rawData is T) {
      parsedData = rawData;
    }

    return ApiResponse(
      success: (json['success'] as bool?) ?? false,
      data: parsedData,
      error: json['error'] as String?,
      message: json['message'] as String?,
    );
  }
}