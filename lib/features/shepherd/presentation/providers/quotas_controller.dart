import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/ai_quota_models.dart';
import '../../data/shepherd_api.dart';

part 'quotas_controller.g.dart';

@riverpod
Future<AiQuotas> quotas(QuotasRef ref) {
  return ref.watch(shepherdApiProvider).getQuotas();
}
