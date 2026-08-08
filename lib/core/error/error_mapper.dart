import '../network/api_exception.dart';

/// Central place technical errors get turned into user-facing copy
/// (`uiuxrules.md` §7 — never show `SocketException`/`DioException`/
/// `401 Unauthorized`/`SQLSTATE`/etc. directly). Every catch block that
/// needs to show something to the user should go through this instead of
/// calling `error.toString()`.
String mapErrorToMessage(Object error) {
  if (error is ApiException) {
    if (error.isNetworkError) {
      return "We couldn't reach the server. Please check your connection and try again.";
    }
    if (error.isMaintenance) {
      return 'The Way is undergoing scheduled maintenance. Please check back shortly.';
    }
    if (error.isRateLimited) {
      return "You're doing that a bit too often — please wait a moment and try again.";
    }
    // Business-logic messages from the backend (invalid OTP, already
    // purchased, quota exceeded, etc.) are already written to be
    // user-facing — pass them through as-is.
    return error.message;
  }

  return 'Something went wrong. Please try again.';
}
