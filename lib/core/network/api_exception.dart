/// Typed representation of the backend's error envelope
/// (`{success:false, message, code, errors}` — see `ApiResponse`/`Handler`
/// on the Laravel side). Every known `code` value from the API docs is
/// captured here so screens can `switch` on it instead of string-matching
/// the message.
class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.statusCode,
    this.code,
    this.errors,
  });

  final String message;
  final int? statusCode;
  final String? code;

  /// Field-level validation errors, e.g. `{"email": ["The email has already been taken."]}`.
  final Map<String, List<String>>? errors;

  bool get isValidationError => code == 'VALIDATION_ERROR' || errors != null;
  bool get isNetworkError => statusCode == null;
  bool get isForceUpdate => code == 'FORCE_UPDATE';
  bool get isMaintenance => code == 'MAINTENANCE';
  bool get isRateLimited => code == 'RATE_LIMITED';
  bool get requiresReauth =>
      code == 'TOKEN_EXPIRED' ||
      code == 'TOKEN_BLACKLISTED' ||
      code == 'TOKEN_INVALID' ||
      code == 'SESSION_TERMINATED' ||
      code == 'INVALID_TOKEN';

  String? firstErrorFor(String field) => errors?[field]?.firstOrNull;

  factory ApiException.network([String message = 'No internet connection. Please check your network and try again.']) {
    return ApiException(message: message);
  }

  @override
  String toString() => 'ApiException($code): $message';
}
