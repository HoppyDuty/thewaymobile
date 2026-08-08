import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/network/api_client.dart';
import 'app_version_check.dart';

part 'app_version_api.g.dart';

class AppVersionApi {
  AppVersionApi(this._client);

  final ApiClient _client;

  Future<AppVersionCheck> check() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final data = await _client.post('/app/version', data: {
      'platform': currentPlatformName(),
      'version_code': int.tryParse(packageInfo.buildNumber) ?? 1,
    });
    return AppVersionCheck.fromJson(data!);
  }
}

@Riverpod(keepAlive: true)
AppVersionApi appVersionApi(AppVersionApiRef ref) => AppVersionApi(ref.watch(apiClientProvider));
