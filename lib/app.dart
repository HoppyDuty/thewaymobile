import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_reconnect_coordinator.dart';
import 'core/notifications/snackbar_service.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_controller.dart';
import 'core/widgets/app_offline_banner.dart';

class TheWayApp extends ConsumerWidget {
  const TheWayApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final snackbarService = ref.watch(snackbarServiceProvider);
    final themeMode = ref.watch(themeModeControllerProvider);
    // AppReconnectCoordinator is `keepAlive: true` but still lazy until
    // something watches it — without this, it's defined but never actually
    // instantiated, so it silently never fires. This is that one watch.
    ref.watch(appReconnectCoordinatorProvider);

    return MaterialApp.router(
      title: 'The Way',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
      scaffoldMessengerKey: snackbarService.scaffoldMessengerKey,
      builder: (context, child) => AppOfflineBanner(child: child ?? const SizedBox.shrink()),
    );
  }
}
