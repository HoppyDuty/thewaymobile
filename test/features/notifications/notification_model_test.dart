import 'package:flutter_test/flutter_test.dart';
import 'package:theway_mobile/features/notifications/data/models/notification_model.dart';

void main() {
  group('NotificationModel', () {
    test('parses an unread notification', () {
      final notification = NotificationModel.fromJson({
        'id': 1,
        'uuid': 'abc',
        'title': 'Payment successful',
        'body': 'Your payment was successful.',
        'type': 'payment',
        'is_read': false,
        'read_at': null,
        'created_at': '2026-01-01T00:00:00Z',
      });

      expect(notification.isRead, isFalse);
      expect(notification.readAt, isNull);
    });

    test('copyWith(isRead: true) marks it read without an explicit readAt', () {
      final notification = NotificationModel.fromJson({
        'id': 1,
        'uuid': 'abc',
        'title': 'T',
        'body': 'B',
        'type': 'general',
        'is_read': false,
        'created_at': '2026-01-01T00:00:00Z',
      });

      final updated = notification.copyWith(isRead: true);
      expect(updated.isRead, isTrue);
    });
  });
}
