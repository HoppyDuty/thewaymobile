/// What's being paid for — matches `InitiatePaymentRequest`'s
/// `content_type` enum exactly (`exam_type`, not `cbt_exam`).
class PaymentContentType {
  static const examType = 'exam_type';
  static const videoCourse = 'video_course';
  static const book = 'book';
}

class PaymentGateway {
  static const paystack = 'paystack';
  static const flutterwave = 'flutterwave';
  static const manual = 'manual';
}

class ManualPaymentDetails {
  const ManualPaymentDetails({
    required this.bankName,
    required this.accountNumber,
    required this.accountName,
    required this.instructions,
  });

  final String bankName;
  final String accountNumber;
  final String accountName;
  final String instructions;

  factory ManualPaymentDetails.fromJson(Map<String, dynamic> json) {
    return ManualPaymentDetails(
      bankName: json['bank_name'] as String? ?? '',
      accountNumber: json['account_number'] as String? ?? '',
      accountName: json['account_name'] as String? ?? '',
      instructions: json['instructions'] as String? ?? '',
    );
  }
}

class PaymentInitiation {
  const PaymentInitiation({
    required this.paymentUuid,
    required this.reference,
    required this.amount,
    required this.currency,
    required this.gateway,
    this.paymentUrl,
    this.manualDetails,
  });

  final String paymentUuid;
  final String reference;
  final num amount;
  final String currency;
  final String gateway;

  /// Null for `manual` — nothing to open, the sheet shows [manualDetails]
  /// instead.
  final String? paymentUrl;
  final ManualPaymentDetails? manualDetails;

  factory PaymentInitiation.fromJson(Map<String, dynamic> json) {
    return PaymentInitiation(
      paymentUuid: json['payment_uuid'] as String,
      reference: json['reference'] as String,
      amount: json['amount'] as num? ?? 0,
      currency: json['currency'] as String? ?? 'NGN',
      gateway: json['gateway'] as String,
      paymentUrl: json['payment_url'] as String?,
      manualDetails: json['manual_details'] != null
          ? ManualPaymentDetails.fromJson(json['manual_details'] as Map<String, dynamic>)
          : null,
    );
  }
}

class PaymentVerification {
  const PaymentVerification({required this.status, required this.message, this.expiresAt});

  final String status;
  final String message;
  final String? expiresAt;

  bool get isSuccessful => status == 'successful';

  factory PaymentVerification.fromJson(Map<String, dynamic> json) {
    return PaymentVerification(
      status: json['status'] as String? ?? 'pending',
      message: json['message'] as String? ?? '',
      expiresAt: json['expires_at'] as String?,
    );
  }
}
