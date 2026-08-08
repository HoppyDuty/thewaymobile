/// Which flow an OTP code is being verified for — the same
/// `/auth/otp/resend` endpoint and [OtpInput] widget are shared across all
/// three, but what happens after a successful `code` differs.
enum OtpPurpose {
  registration('registration'),
  login('login'),
  forgotPassword('forgot_password');

  const OtpPurpose(this.apiValue);

  /// The `type` value the backend expects on `/auth/otp/resend`.
  final String apiValue;
}
