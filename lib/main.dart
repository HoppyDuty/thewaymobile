import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/env/env.dart';
import 'core/storage/hive_setup.dart';

/// Riverpod swallows a provider's `build()` exception into its `AsyncError`
/// state by default — nothing reaches the console, so a screen showing the
/// generic "Something went wrong" error state leaves no trace of what
/// actually failed. This surfaces it in debug builds only.
class _DebugProviderErrorLogger extends ProviderObserver {
  @override
  void providerDidFail(ProviderBase provider, Object error, StackTrace stackTrace, ProviderContainer container) {
    debugPrint('[Provider:${provider.name ?? provider.runtimeType}] $error\n$stackTrace');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Env.load();
  await HiveSetup.init();

  runApp(
    ProviderScope(
      observers: [if (kDebugMode) _DebugProviderErrorLogger()],
      child: const TheWayApp(),
    ),
  );
}
