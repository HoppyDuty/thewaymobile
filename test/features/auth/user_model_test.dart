import 'package:flutter_test/flutter_test.dart';
import 'package:theway_mobile/features/auth/data/models/user_model.dart';

void main() {
  group('UserModel', () {
    test('fromJson parses the full verify-response shape', () {
      final user = UserModel.fromJson({
        'id': 1,
        'uuid': 'abc-123',
        'first_name': 'Ada',
        'last_name': 'Lovelace',
        'full_name': 'Ada Lovelace',
        'username': 'ada',
        'email': 'ada@example.com',
        'phone': '+2348012345678',
        'avatar_url': null,
        'referral_code': 'ADA123',
        'status': 'active',
        'role': 'student',
        'is_verified': true,
        'last_login_at': '2026-01-01T10:00:00Z',
        'created_at': '2025-01-01T10:00:00Z',
      });

      expect(user.id, 1);
      expect(user.fullName, 'Ada Lovelace');
      expect(user.isAdmin, isFalse);
    });

    test('isAdmin is true for admin and super_admin roles', () {
      Map<String, dynamic> baseJson(String role) => {
            'id': 1,
            'uuid': 'x',
            'first_name': 'A',
            'last_name': 'B',
            'username': 'ab',
            'email': 'a@b.com',
            'status': 'active',
            'role': role,
            'is_verified': true,
            'created_at': '2025-01-01T10:00:00Z',
          };

      expect(UserModel.fromJson(baseJson('admin')).isAdmin, isTrue);
      expect(UserModel.fromJson(baseJson('super_admin')).isAdmin, isTrue);
      expect(UserModel.fromJson(baseJson('student')).isAdmin, isFalse);
    });

    test('toJson -> fromJson round-trips correctly', () {
      final original = UserModel.fromJson({
        'id': 5,
        'uuid': 'u5',
        'first_name': 'First',
        'last_name': 'Last',
        'username': 'user5',
        'email': 'user5@example.com',
        'status': 'active',
        'role': 'student',
        'is_verified': false,
        'created_at': '2025-06-01T00:00:00Z',
      });

      final roundTripped = UserModel.fromJson(original.toJson());

      expect(roundTripped.id, original.id);
      expect(roundTripped.email, original.email);
      expect(roundTripped.isVerified, original.isVerified);
    });
  });
}
