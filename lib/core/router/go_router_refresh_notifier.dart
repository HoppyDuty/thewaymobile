import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bridges Riverpod provider changes to `go_router`'s `refreshListenable`,
/// which expects a plain [Listenable] — Riverpod state changes aren't one
/// natively, so `GoRouter`'s `redirect` callback wouldn't otherwise re-run
/// when e.g. [AuthSessionState] changes after the router was built.
class GoRouterRefreshNotifier extends ChangeNotifier {
  GoRouterRefreshNotifier(Ref ref, List<ProviderListenable<Object?>> providers) {
    for (final provider in providers) {
      ref.listen(provider, (_, __) => notifyListeners());
    }
  }
}
