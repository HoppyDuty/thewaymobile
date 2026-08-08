import 'package:flutter_test/flutter_test.dart';
import 'package:theway_mobile/features/auth/data/models/otp_challenge.dart';

void main() {
  group('OtpChallenge', () {
    test('parses email as the masked-email hint', () {
      final challenge = OtpChallenge.fromJson({
        'otp_token': 'tok_123',
        'expires_in': 600,
        'email': 'a***@example.com',
      });

      expect(challenge.otpToken, 'tok_123');
      expect(challenge.maskedEmail, 'a***@example.com');
    });

    test('falls back to a default expiry when absent', () {
      final challenge = OtpChallenge.fromJson({'otp_token': 'tok_456'});
      expect(challenge.expiresIn, 600);
    });

    test('parses resend metadata when present', () {
      final challenge = OtpChallenge.fromJson({
        'otp_token': 'tok_789',
        'resend_after': 45,
        'resend_count': 2,
      });

      expect(challenge.resendAfter, 45);
      expect(challenge.resendCount, 2);
    });
  });
}
