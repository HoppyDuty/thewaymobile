import 'package:flutter_test/flutter_test.dart';
import 'package:theway_mobile/core/error/error_mapper.dart';
import 'package:theway_mobile/core/network/api_exception.dart';

void main() {
  group('mapErrorToMessage', () {
    test('network errors get a friendly connectivity message', () {
      final message = mapErrorToMessage(ApiException.network());
      expect(message, contains("couldn't reach the server"));
    });

    test('maintenance errors get the maintenance message', () {
      final error = ApiException(message: 'raw', code: 'MAINTENANCE', statusCode: 503);
      expect(mapErrorToMessage(error), contains('maintenance'));
    });

    test('rate-limited errors get a friendly throttling message', () {
      final error = ApiException(message: 'raw', code: 'RATE_LIMITED', statusCode: 429);
      expect(mapErrorToMessage(error), contains('too often'));
    });

    test('business-logic errors pass the backend message through as-is', () {
      final error = ApiException(message: 'Invalid or expired code.', code: 'INVALID_CODE', statusCode: 422);
      expect(mapErrorToMessage(error), 'Invalid or expired code.');
    });

    test('unknown non-ApiException errors get a generic fallback', () {
      expect(mapErrorToMessage(Exception('boom')), 'Something went wrong. Please try again.');
    });
  });
}
