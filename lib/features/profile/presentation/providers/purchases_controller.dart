import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/profile_models.dart';
import '../../data/profile_api.dart';

part 'purchases_controller.g.dart';

@riverpod
Future<PurchasesSummary> purchases(PurchasesRef ref) {
  return ref.watch(profileApiProvider).getPurchases();
}
