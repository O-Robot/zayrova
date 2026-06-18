import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zayrova/domain/entities/conversation_entity.dart';
import 'package:zayrova/domain/entities/message_entity.dart';
import 'package:zayrova/presentation/providers/usecase_providers.dart';

final messageControllerProvider =
    NotifierProvider<MessageController, MessageState>(MessageController.new);

class MessageState {
  const MessageState({
    this.conversations = const [],
    this.messages = const [],
    this.selectedConversation,
    this.isLoadingConversations = false,
    this.isLoadingMessages = false,
    this.isSending = false,
    this.errorMessage,
    this.hasLoadedConversations = false,
    this.hasLoadedMessages = false,
  });

  final List<Conversation> conversations;
  final List<Message> messages;
  final Conversation? selectedConversation;
  final bool isLoadingConversations;
  final bool isLoadingMessages;
  final bool isSending;
  final String? errorMessage;
  final bool hasLoadedConversations;
  final bool hasLoadedMessages;

  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  List<Conversation> get sortedConversations {
    final sorted = [...conversations];
    sorted.sort((a, b) {
      final aDate = a.updatedAt ?? a.lastMessage?.createdAt ?? a.createdAt;
      final bDate = b.updatedAt ?? b.lastMessage?.createdAt ?? b.createdAt;
      return bDate.compareTo(aDate);
    });
    return sorted;
  }

  List<Message> get sortedMessages {
    final sorted = [...messages];
    sorted.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return sorted;
  }

  MessageState copyWith({
    List<Conversation>? conversations,
    List<Message>? messages,
    Conversation? selectedConversation,
    bool? isLoadingConversations,
    bool? isLoadingMessages,
    bool? isSending,
    String? errorMessage,
    bool? hasLoadedConversations,
    bool? hasLoadedMessages,
    bool clearSelectedConversation = false,
    bool clearError = false,
  }) {
    return MessageState(
      conversations: conversations ?? this.conversations,
      messages: messages ?? this.messages,
      selectedConversation: clearSelectedConversation
          ? null
          : selectedConversation ?? this.selectedConversation,
      isLoadingConversations:
          isLoadingConversations ?? this.isLoadingConversations,
      isLoadingMessages: isLoadingMessages ?? this.isLoadingMessages,
      isSending: isSending ?? this.isSending,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      hasLoadedConversations:
          hasLoadedConversations ?? this.hasLoadedConversations,
      hasLoadedMessages: hasLoadedMessages ?? this.hasLoadedMessages,
    );
  }
}

class MessageController extends Notifier<MessageState> {
  @override
  MessageState build() {
    return const MessageState();
  }

  Future<void> loadConversations() async {
    state = state.copyWith(isLoadingConversations: true, clearError: true);

    final result = await ref.read(getConversationsUseCaseProvider).call();

    if (result.isSuccess && result.data != null) {
      state = state.copyWith(
        conversations: result.data,
        isLoadingConversations: false,
        hasLoadedConversations: true,
      );
      return;
    }

    state = state.copyWith(
      isLoadingConversations: false,
      errorMessage: result.message ?? 'Unable to load conversations.',
      hasLoadedConversations: true,
    );
  }

  Future<void> loadMessages(String conversationId) async {
    final selected = _conversationById(conversationId);
    state = state.copyWith(
      selectedConversation: selected,
      messages: const [],
      isLoadingMessages: true,
      hasLoadedMessages: false,
      clearError: true,
    );

    final result = await ref.read(getMessagesUseCaseProvider).call(
          conversationId,
        );

    if (result.isSuccess && result.data != null) {
      state = state.copyWith(
        messages: result.data,
        selectedConversation: selected ?? _conversationById(conversationId),
        isLoadingMessages: false,
        hasLoadedMessages: true,
      );
      return;
    }

    state = state.copyWith(
      isLoadingMessages: false,
      errorMessage: result.message ?? 'Unable to load messages.',
      hasLoadedMessages: true,
    );
  }

  Future<bool> sendMessage({
    required String conversationId,
    required String body,
  }) async {
    final trimmedBody = body.trim();
    if (trimmedBody.isEmpty) {
      return false;
    }

    state = state.copyWith(isSending: true, clearError: true);

    final result = await ref.read(sendMessageUseCaseProvider).call(
          conversationId: conversationId,
          body: trimmedBody,
        );

    if (result.isSuccess && result.data != null) {
      final sentMessage = result.data!;
      final shouldAppend =
          sentMessage.conversationId == conversationId &&
              sentMessage.body.trim().isNotEmpty;

      state = state.copyWith(
        messages: shouldAppend ? [...state.messages, sentMessage] : null,
        conversations: _replaceConversationLastMessage(
          conversationId,
          shouldAppend ? sentMessage : null,
        ),
        isSending: false,
      );
      return true;
    }

    state = state.copyWith(
      isSending: false,
      errorMessage: result.message ?? 'Unable to send message.',
    );
    return false;
  }

  Conversation? _conversationById(String conversationId) {
    for (final conversation in state.conversations) {
      if (conversation.id == conversationId) {
        return conversation;
      }
    }
    return null;
  }

  List<Conversation> _replaceConversationLastMessage(
    String conversationId,
    Message? message,
  ) {
    if (message == null) {
      return state.conversations;
    }

    return state.conversations.map((conversation) {
      if (conversation.id != conversationId) {
        return conversation;
      }

      return conversation.copyWith(
        lastMessage: message,
        updatedAt: message.createdAt,
        unreadCount: 0,
      );
    }).toList();
  }
}
