import 'package:flutter_test/flutter_test.dart';
import 'package:theway_mobile/features/app_version/app_version_check.dart';

void main() {
  group('AppVersionCheck', () {
    test('maintenance blocks regardless of force_update', () {
      final check = AppVersionCheck.fromJson({
        'maintenance': true,
        'title': 'Down for maintenance',
        'message': 'Back soon.',
        'ends_at': '2026-01-01T12:00:00Z',
      });

      expect(check.isBlocking, isTrue);
      expect(check.hasOptionalUpdate, isFalse);
    });

    test('force_update blocks when not under maintenance', () {
      final check = AppVersionCheck.fromJson({
        'maintenance': false,
        'status': 'force_update',
        'force_update': true,
        'update_url': 'https://play.google.com/store/apps/details?id=ng.theway.app',
        'message': 'Please update.',
      });

      expect(check.isBlocking, isTrue);
    });

    test('optional_update does not block but is flagged', () {
      final check = AppVersionCheck.fromJson({
        'maintenance': false,
        'status': 'optional_update',
        'force_update': false,
        'message': 'A new version is available.',
      });

      expect(check.isBlocking, isFalse);
      expect(check.hasOptionalUpdate, isTrue);
    });

    test('up_to_date is fully clear', () {
      final check = AppVersionCheck.fromJson({
        'maintenance': false,
        'status': 'up_to_date',
        'force_update': false,
        'message': 'You are up to date.',
      });

      expect(check.isBlocking, isFalse);
      expect(check.hasOptionalUpdate, isFalse);
    });
  });
}
