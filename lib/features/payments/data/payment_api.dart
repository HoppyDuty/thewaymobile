import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/api_client.dart';
import 'models/payment_models.dart';

part 'payment_api.g.dart';

class PaymentApi {
  PaymentApi(this._client);

  final ApiClient _client;

  Future<PaymentInitiation> initiate({
    required String contentType,
    required int contentId,
    required String gateway,
  }) async {
    final data = await _client.post(
      '/payments/initiate',
      data: {'content_type': contentType, 'content_id': contentId, 'gateway': gateway},
    );
    return PaymentInitiation.fromJson(data!);
  }

  Future<PaymentVerification> verify(String paymentUuid) async {
    final data = await _client.get('/payments/$paymentUuid/verify');
    return PaymentVerification.fromJson(data!);
  }
}

@Riverpod(keepAlive: true)
PaymentApi paymentApi(PaymentApiRef ref) => PaymentApi(ref.watch(apiClientProvider));
