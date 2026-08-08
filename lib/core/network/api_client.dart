import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../env/env.dart';
import '../storage/secure_storage_service.dart';
import 'api_exception.dart';
import 'device_headers.dart';

part 'api_client.g.dart';

/// Thin wrapper around [Dio] that every feature's data layer talks through.
///
/// Handles, in one place:
/// - injecting the `X-Device-*`/`X-App-Version*` headers on every request
/// - attaching the JWT and silently refreshing it once on a 401 that
///   signals an expired/invalid token (queuing concurrent requests while
///   the refresh is in flight so we don't fire multiple refreshes at once)
/// - unwrapping the `{success, data, message}` envelope and mapping
///   `{success:false, message, code, errors}` into a typed [ApiException]
///
/// `phase4.md`'s prescribed `CbtSyncService` reads `apiClient.dio` directly
/// for cases that need raw Dio (e.g. download progress callbacks), so the
/// underlying instance is exposed via [dio].
class ApiClient {
  ApiClient({
    required SecureStorageService secureStorage,
    required DeviceHeaders deviceHeaders,
  })  : _secureStorage = secureStorage,
        _deviceHeaders = deviceHeaders {
    dio = Dio(
      BaseOptions(
        baseUrl: Env.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        headers: {
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          options.headers.addAll(await _deviceHeaders.build());
          final token = await _secureStorage.readAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );

    dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onError: (error, handler) async {
          final code = _extractCode(error.response?.data);
          final isAuthFailure = error.response?.statusCode == 401 &&
              (code == 'TOKEN_EXPIRED' || code == null);

          if (!isAuthFailure || _isRefreshing) {
            return handler.next(error);
          }

          final refreshed = await _tryRefresh();
          if (!refreshed) {
            await _secureStorage.clearSession();
            onAuthFailure?.call();
            return handler.next(error);
          }

          try {
            final retried = await dio.fetch(error.requestOptions);
            return handler.resolve(retried);
          } on DioException catch (retryError) {
            return handler.next(retryError);
          }
        },
      ),
    );
  }

  late final Dio dio;
  final SecureStorageService _secureStorage;
  final DeviceHeaders _deviceHeaders;
  bool _isRefreshing = false;

  /// Wired up by the auth feature once it exists — called when a token
  /// refresh fails so the app can drop the user back to the login screen.
  void Function()? onAuthFailure;

  Future<bool> _tryRefresh() async {
    _isRefreshing = true;
    try {
      final response = await dio.post('/auth/refresh');
      final token = response.data?['data']?['access_token'] as String?;
      if (token == null) return false;
      await _secureStorage.writeAccessToken(token);
      return true;
    } on DioException {
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  String? _extractCode(dynamic data) {
    if (data is Map) return data['code'] as String?;
    return null;
  }

  ApiException _mapError(DioException error) {
    final data = error.response?.data;
    if (data is Map) {
      final rawErrors = data['errors'];
      return ApiException(
        message: data['message'] as String? ?? 'Something went wrong. Please try again.',
        statusCode: error.response?.statusCode,
        code: data['code'] as String?,
        errors: rawErrors is Map
            ? rawErrors.map((key, value) => MapEntry(key.toString(), List<String>.from(value as List)))
            : null,
      );
    }
    return ApiException.network();
  }

  Future<Map<String, dynamic>?> _unwrap(Future<Response> Function() call) async {
    final envelope = await _unwrapEnvelope(call);
    return envelope.data as Map<String, dynamic>?;
  }

  Future<ApiEnvelope> _unwrapEnvelope(Future<Response> Function() call) async {
    try {
      final response = await call();
      final body = response.data;
      if (body is Map<String, dynamic>) {
        return ApiEnvelope(data: body['data'], meta: body['meta'] as Map<String, dynamic>?);
      }
      return const ApiEnvelope();
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<Map<String, dynamic>?> get(String path, {Map<String, dynamic>? query}) =>
      _unwrap(() => dio.get(path, queryParameters: query));

  Future<Map<String, dynamic>?> post(String path, {Object? data}) =>
      _unwrap(() => dio.post(path, data: data));

  Future<Map<String, dynamic>?> patch(String path, {Object? data}) =>
      _unwrap(() => dio.patch(path, data: data));

  Future<Map<String, dynamic>?> delete(String path, {Object? data}) =>
      _unwrap(() => dio.delete(path, data: data));

  /// For paginated endpoints where the backend returns `data` as a bare
  /// JSON array with pagination info as a sibling `meta` object (as
  /// opposed to a `{items: [...]}`-wrapped map — the API is inconsistent
  /// about this between endpoints, so callers must know which shape theirs
  /// uses; see each feature's API class for which endpoints need this).
  Future<ApiEnvelope> getPage(String path, {Map<String, dynamic>? query}) =>
      _unwrapEnvelope(() => dio.get(path, queryParameters: query));

  Future<ApiEnvelope> postPage(String path, {Object? data}) => _unwrapEnvelope(() => dio.post(path, data: data));
}

/// Raw `{data, meta}` pair for endpoints whose `data` is a JSON array
/// rather than an object — see [ApiClient.getPage].
class ApiEnvelope {
  const ApiEnvelope({this.data, this.meta});

  final dynamic data;
  final Map<String, dynamic>? meta;

  List<dynamic> get list => (data as List<dynamic>?) ?? const [];
}

@Riverpod(keepAlive: true)
ApiClient apiClient(ApiClientRef ref) {
  return ApiClient(
    secureStorage: ref.watch(secureStorageServiceProvider),
    deviceHeaders: ref.watch(deviceHeadersProvider),
  );
}
