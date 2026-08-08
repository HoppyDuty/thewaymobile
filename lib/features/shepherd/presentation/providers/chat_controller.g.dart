// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$chatControllerHash() => r'230b9c0aec68e5950f260810342954f3d954a3fe';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$ChatController
    extends BuildlessAutoDisposeAsyncNotifier<ChatState> {
  late final String? uuid;

  FutureOr<ChatState> build(String? uuid);
}

/// Family key is the conversation's uuid, or `null` to start a brand-new
/// one — the family identity stays `null` for that screen instance's whole
/// lifetime even after the backend assigns a real uuid on first send (the
/// uuid then lives in [ChatState.uuid] instead), so no provider migration
/// is needed mid-conversation.
///
/// Copied from [ChatController].
@ProviderFor(ChatController)
const chatControllerProvider = ChatControllerFamily();

/// Family key is the conversation's uuid, or `null` to start a brand-new
/// one — the family identity stays `null` for that screen instance's whole
/// lifetime even after the backend assigns a real uuid on first send (the
/// uuid then lives in [ChatState.uuid] instead), so no provider migration
/// is needed mid-conversation.
///
/// Copied from [ChatController].
class ChatControllerFamily extends Family<AsyncValue<ChatState>> {
  /// Family key is the conversation's uuid, or `null` to start a brand-new
  /// one — the family identity stays `null` for that screen instance's whole
  /// lifetime even after the backend assigns a real uuid on first send (the
  /// uuid then lives in [ChatState.uuid] instead), so no provider migration
  /// is needed mid-conversation.
  ///
  /// Copied from [ChatController].
  const ChatControllerFamily();

  /// Family key is the conversation's uuid, or `null` to start a brand-new
  /// one — the family identity stays `null` for that screen instance's whole
  /// lifetime even after the backend assigns a real uuid on first send (the
  /// uuid then lives in [ChatState.uuid] instead), so no provider migration
  /// is needed mid-conversation.
  ///
  /// Copied from [ChatController].
  ChatControllerProvider call(String? uuid) {
    return ChatControllerProvider(uuid);
  }

  @override
  ChatControllerProvider getProviderOverride(
    covariant ChatControllerProvider provider,
  ) {
    return call(provider.uuid);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'chatControllerProvider';
}

/// Family key is the conversation's uuid, or `null` to start a brand-new
/// one — the family identity stays `null` for that screen instance's whole
/// lifetime even after the backend assigns a real uuid on first send (the
/// uuid then lives in [ChatState.uuid] instead), so no provider migration
/// is needed mid-conversation.
///
/// Copied from [ChatController].
class ChatControllerProvider
    extends AutoDisposeAsyncNotifierProviderImpl<ChatController, ChatState> {
  /// Family key is the conversation's uuid, or `null` to start a brand-new
  /// one — the family identity stays `null` for that screen instance's whole
  /// lifetime even after the backend assigns a real uuid on first send (the
  /// uuid then lives in [ChatState.uuid] instead), so no provider migration
  /// is needed mid-conversation.
  ///
  /// Copied from [ChatController].
  ChatControllerProvider(String? uuid)
    : this._internal(
        () => ChatController()..uuid = uuid,
        from: chatControllerProvider,
        name: r'chatControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$chatControllerHash,
        dependencies: ChatControllerFamily._dependencies,
        allTransitiveDependencies:
            ChatControllerFamily._allTransitiveDependencies,
        uuid: uuid,
      );

  ChatControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.uuid,
  }) : super.internal();

  final String? uuid;

  @override
  FutureOr<ChatState> runNotifierBuild(covariant ChatController notifier) {
    return notifier.build(uuid);
  }

  @override
  Override overrideWith(ChatController Function() create) {
    return ProviderOverride(
      origin: this,
      override: ChatControllerProvider._internal(
        () => create()..uuid = uuid,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        uuid: uuid,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<ChatController, ChatState>
  createElement() {
    return _ChatControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChatControllerProvider && other.uuid == uuid;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, uuid.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ChatControllerRef on AutoDisposeAsyncNotifierProviderRef<ChatState> {
  /// The parameter `uuid` of this provider.
  String? get uuid;
}

class _ChatControllerProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<ChatController, ChatState>
    with ChatControllerRef {
  _ChatControllerProviderElement(super.provider);

  @override
  String? get uuid => (origin as ChatControllerProvider).uuid;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
