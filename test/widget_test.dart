import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:theway_mobile/app.dart';
import 'package:theway_mobile/core/env/env.dart';
import 'package:theway_mobile/core/storage/hive_setup.dart';

void main() {
  setUpAll(() async {
    // No .env asset bundle available under `flutter test`; load the
    // in-memory fallback so ApiClient's baseUrl resolution doesn't throw.
    await Env.load().catchError((_) {});

    // `TheWayApp` reads `ThemeModeController` (backed by Hive) on its very
    // first build now — use a plain temp dir instead of `Hive.initFlutter()`,
    // which needs a `path_provider` platform channel unavailable here.
    await HiveSetup.init(testDirectoryPath: Directory.systemTemp.createTempSync('theway_test_hive_').path);
  });

  testWidgets('app boots to the splash screen', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: TheWayApp()));
    await tester.pump();

    expect(find.text('The Way'), findsOneWidget);
    expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
  });
}
