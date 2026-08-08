class ChatMessage {
  const ChatMessage({required this.role, required this.content, this.createdAt});

  /// 'user' | 'assistant' | 'system' (system never actually reaches the
  /// client — the backend only persists user/assistant turns).
  final String role;
  final String content;
  final DateTime? createdAt;

  bool get isUser => role == 'user';

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      role: json['role'] as String,
      content: json['content'] as String,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
    );
  }
}

class ConversationSummary {
  const ConversationSummary({
    required this.uuid,
    required this.title,
    required this.messageCount,
    this.lastMessageAt,
    required this.createdAt,
  });

  final String uuid;
  final String title;
  final int messageCount;
  final DateTime? lastMessageAt;
  final DateTime createdAt;

  factory ConversationSummary.fromJson(Map<String, dynamic> json) {
    return ConversationSummary(
      uuid: json['uuid'] as String,
      title: json['title'] as String? ?? 'New Conversation',
      messageCount: json['message_count'] as int? ?? 0,
      lastMessageAt: json['last_message_at'] != null ? DateTime.tryParse(json['last_message_at'] as String) : null,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

class ConversationDetail {
  const ConversationDetail({
    required this.uuid,
    required this.title,
    required this.messageCount,
    required this.messages,
    required this.createdAt,
  });

  final String uuid;
  final String title;
  final int messageCount;
  final List<ChatMessage> messages;
  final DateTime createdAt;

  factory ConversationDetail.fromJson(Map<String, dynamic> json) {
    return ConversationDetail(
      uuid: json['uuid'] as String,
      title: json['title'] as String? ?? 'New Conversation',
      messageCount: json['message_count'] as int? ?? 0,
      messages: (json['messages'] as List<dynamic>? ?? [])
          .map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

/// Result of `POST /shepherd/chat`.
class ChatResult {
  const ChatResult({required this.conversationUuid, required this.message, required this.messageCount});

  final String conversationUuid;
  final String message;
  final int messageCount;

  factory ChatResult.fromJson(Map<String, dynamic> json) {
    return ChatResult(
      conversationUuid: json['conversation_uuid'] as String,
      message: json['message'] as String,
      messageCount: json['message_count'] as int? ?? 0,
    );
  }
}
