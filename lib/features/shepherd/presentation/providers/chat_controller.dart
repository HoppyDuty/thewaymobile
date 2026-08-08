import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/chat_models.dart';
import '../../data/shepherd_api.dart';

part 'chat_controller.g.dart';

class ChatState {
  const ChatState({required this.messages, this.uuid, this.title, this.isSending = false});

  final List<ChatMessage> messages;

  /// Null until the first message of a brand-new conversation is sent —
  /// the backend assigns the uuid, not the client.
  final String? uuid;
  final String? title;
  final bool isSending;

  ChatState copyWith({List<ChatMessage>? messages, String? uuid, String? title, bool? isSending}) {
    return ChatState(
      messages: messages ?? this.messages,
      uuid: uuid ?? this.uuid,
      title: title ?? this.title,
      isSending: isSending ?? this.isSending,
    );
  }
}

/// Family key is the conversation's uuid, or `null` to start a brand-new
/// one — the family identity stays `null` for that screen instance's whole
/// lifetime even after the backend assigns a real uuid on first send (the
/// uuid then lives in [ChatState.uuid] instead), so no provider migration
/// is needed mid-conversation.
@riverpod
class ChatController extends _$ChatController {
  @override
  Future<ChatState> build(String? uuid) async {
    if (uuid == null) {
      return const ChatState(messages: []);
    }
    final detail = await ref.watch(shepherdApiProvider).getConversation(uuid);
    return ChatState(messages: detail.messages, uuid: detail.uuid, title: detail.title);
  }

  Future<void> sendMessage(String message, {int? examTypeId}) async {
    final current = state.valueOrNull ?? const ChatState(messages: []);
    if (current.isSending) return;

    final userMessage = ChatMessage(role: 'user', content: message, createdAt: DateTime.now());
    state = AsyncData(current.copyWith(messages: [...current.messages, userMessage], isSending: true));

    try {
      final result = await ref
          .read(shepherdApiProvider)
          .chat(message: message, conversationUuid: current.uuid, examTypeId: examTypeId);

      final assistantMessage = ChatMessage(role: 'assistant', content: result.message, createdAt: DateTime.now());
      state = AsyncData(
        ChatState(
          messages: [...current.messages, userMessage, assistantMessage],
          uuid: result.conversationUuid,
          title: current.title,
        ),
      );
    } catch (e) {
      // Roll back the optimistic user message — the request never landed.
      state = AsyncData(current.copyWith(isSending: false));
      rethrow;
    }
  }
}
