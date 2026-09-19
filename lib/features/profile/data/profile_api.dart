import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/page_meta.dart';
import '../../../core/storage/offline_cache.dart';
import 'models/profile_models.dart';

part 'profile_api.g.dart';

const _fullProfileCacheKey = 'profile_full';

class PaymentHistoryPage {
  const PaymentHistoryPage({required this.items, required this.meta});
  final List<PaymentHistoryItem> items;
  final PageMeta meta;
}

class ProfileApi {
  ProfileApi(this._client, this._cache);

  final ApiClient _client;
  final OfflineCache _cache;

  /// Network-first, falling back to the last cached copy (kept for
  /// [OfflineCache.maxAge]) if there's no connection — Profile previously
  /// had no offline story at all (`UI_UX_RULES.md` §11's "give Profile at
  /// least a basic cache"), so this brings it to parity with Home/Videos/
  /// Books/News's baseline.
  Future<FullProfile> getFullProfile() async {
    try {
      final data = await _client.get('/profile');
      await _cache.write(_fullProfileCacheKey, data!);
      return FullProfile.fromJson(data);
    } on ApiException catch (e) {
      if (!e.isNetworkError) rethrow;
      final cached = _cache.read(_fullProfileCacheKey);
      if (cached == null) rethrow;
      final parsed = tryParseCached(() => FullProfile.fromJson(Map<String, dynamic>.from(cached.data as Map)));
      if (parsed == null) rethrow;
      return parsed;
    }
  }

  /// Synchronous read of the cached profile — lets [ProfileController]
  /// paint immediately and revalidate in the background, same role as
  /// `HomeApi.readCachedHomeScreen`.
  FullProfile? readCachedFullProfile() {
    final cached = _cache.read(_fullProfileCacheKey);
    if (cached == null) return null;
    return tryParseCached(() => FullProfile.fromJson(Map<String, dynamic>.from(cached.data as Map)));
  }

  Future<UserStats> getStats() async {
    final data = await _client.get('/profile/stats');
    return UserStats.fromJson(data!);
  }

  Future<PurchasesSummary> getPurchases() async {
    final data = await _client.get('/profile/purchases');
    return PurchasesSummary.fromJson(data!);
  }

  Future<PaymentHistoryPage> getPaymentHistory({int page = 1}) async {
    final envelope = await _client.getPage('/profile/payments', query: {'page': page});
    return PaymentHistoryPage(
      items: envelope.list.map((p) => PaymentHistoryItem.fromJson(p as Map<String, dynamic>)).toList(),
      meta: PageMeta.fromJson(envelope.meta),
    );
  }

  Future<LeaderboardPosition> getLeaderboardPosition() async {
    final data = await _client.get('/profile/leaderboard');
    return LeaderboardPosition.fromJson(data!);
  }

  Future<ProfileUser> updateProfile({String? firstName, String? lastName, String? phone}) async {
    final data = await _client.patch(
      '/profile',
      data: {
        if (firstName != null) 'first_name': firstName,
        if (lastName != null) 'last_name': lastName,
        if (phone != null) 'phone': phone,
      },
    );
    return ProfileUser.fromJson(data!);
  }

  Future<String> updateAvatar(String filePath) async {
    final formData = FormData.fromMap({'avatar': await MultipartFile.fromFile(filePath)});
    final data = await _client.post('/profile/avatar', data: formData);
    return data!['avatar_url'] as String;
  }

  Future<UserPreferences> getPreferences() async {
    final data = await _client.get('/profile/preferences');
    return UserPreferences.fromJson(data!);
  }

  Future<UserPreferences> updatePreferences({
    String? theme,
    bool? pushNotificationsEnabled,
    bool? emailNotificationsEnabled,
    bool? examRemindersEnabled,
    String? preferredLanguage,
  }) async {
    final data = await _client.patch(
      '/profile/preferences',
      data: {
        if (theme != null) 'theme': theme,
        if (pushNotificationsEnabled != null) 'push_notifications_enabled': pushNotificationsEnabled,
        if (emailNotificationsEnabled != null) 'email_notifications_enabled': emailNotificationsEnabled,
        if (examRemindersEnabled != null) 'exam_reminders_enabled': examRemindersEnabled,
        if (preferredLanguage != null) 'preferred_language': preferredLanguage,
      },
    );
    return UserPreferences.fromJson(data!);
  }

  Future<void> deleteAccount({String? password}) {
    return _client.delete('/profile', data: {if (password != null) 'password': password});
  }
}

@Riverpod(keepAlive: true)
ProfileApi profileApi(ProfileApiRef ref) =>
    ProfileApi(ref.watch(apiClientProvider), ref.watch(offlineCacheProvider));
