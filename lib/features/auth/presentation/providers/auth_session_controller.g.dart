// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_session_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authSessionControllerHash() =>
    r'7e55efad3d780903af199df4d9967fd368889181';

/// Owns [AuthSessionState] for the whole app. `build()` returns
/// immediately with [AuthSessionUnknown] and kicks off an async bootstrap
/// (check secure storage → show the cached profile immediately if one
/// exists → best-effort refresh from `/auth/me`) so the router never has
/// to `await` anything to decide where to send the user.
///
/// Copied from [AuthSessionController].
@ProviderFor(AuthSessionController)
final authSessionControllerProvider =
    NotifierProvider<AuthSessionController, AuthSessionState>.internal(
      AuthSessionController.new,
      name: r'authSessionControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$authSessionControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AuthSessionController = Notifier<AuthSessionState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
