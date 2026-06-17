/// API 统一异常
class ApiException implements Exception {
  ApiException(this.message, [this.detail]);

  final String message;
  final String? detail;

  @override
  String toString() => detail != null ? '$message ($detail!)' : message;
}