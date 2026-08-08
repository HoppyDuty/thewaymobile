/// Returned by `/auth/register`, `/auth/login`, `/auth/otp/resend`, and
/// `/auth/forgot-password/verify`'s sibling endpoints whenever the next
/// step is "enter the 6-digit code that was emailed to you."
class OtpChallenge {
  const OtpChallenge({
    required this.otpToken,
    required this.expiresIn,
    this.maskedEmail,
    this.resendAfter,
    this.resendCount,
  });

  final String otpToken;
  final int expiresIn;
  final String? maskedEmail;
  final int? resendAfter;
  final int? resendCount;

  factory OtpChallenge.fromJson(Map<String, dynamic> json) {
    return OtpChallenge(
      otpToken: json['otp_token'] as String,
      expiresIn: json['expires_in'] as int? ?? 600,
      maskedEmail: (json['email'] ?? json['masked_email']) as String?,
      resendAfter: json['resend_after'] as int?,
      resendCount: json['resend_count'] as int?,
    );
  }
}
