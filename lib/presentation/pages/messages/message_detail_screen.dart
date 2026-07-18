import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zayrova/core/constants/colors.dart';
import 'package:zayrova/core/themes/zay_theme.dart';
import 'package:zayrova/domain/entities/conversation_entity.dart';
import 'package:zayrova/domain/entities/message_entity.dart';
import 'package:zayrova/presentation/components/empty_state.dart';
import 'package:zayrova/presentation/components/error_state.dart';
import 'package:zayrova/presentation/components/loading_state.dart';
import 'package:zayrova/presentation/pages/messages/message_components.dart';
import 'package:zayrova/presentation/providers/feature/message_controller.dart';
import 'package:zayrova/presentation/routes/zay_router.dart';
import 'package:zayrova/presentation/routes/zay_routes.dart';

class MessageDetailScreen extends ConsumerStatefulWidget {
  const MessageDetailScreen({
    super.key,
    required this.conversationId,
    this.title,
  });

  final String? conversationId;
  final String? title;

  @override
  ConsumerState<MessageDetailScreen> createState() =>
      _MessageDetailScreenState();
}

class _MessageDetailScreenState extends ConsumerState<MessageDetailScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadMessages());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() {
    final conversationId = widget.conversationId;
    if (conversationId == null || conversationId.isEmpty) {
      return Future.value();
    }

    return ref
        .read(messageControllerProvider.notifier)
        .loadMessages(conversationId);
  }

  Future<void> _sendMessage(String body) async {
    final conversationId = widget.conversationId;
    if (conversationId == null || conversationId.isEmpty) {
      return;
    }

    final sent = await ref
        .read(messageControllerProvider.notifier)
        .sendMessage(conversationId: conversationId, body: body);

    if (sent) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) {
      return;
    }

    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(messageControllerProvider);
    final hasConversationId =
        widget.conversationId != null && widget.conversationId!.isNotEmpty;
    final conversationTitle =
        state.selectedConversation?.title ?? widget.title ?? 'Message';

    return Scaffold(
      backgroundColor: ZayColors.white,
      body: SafeArea(
        child: Column(
          children: [
            MessageHeader(
              title: 'Message',
              onBack: () => ZayRouter.goBack(),
              onNotification: () => ZayRouter.goto(ZayRoutes.notifications),
            ),
            _ConversationHeader(
              title: conversationTitle,
              conversation: state.selectedConversation,
            ),
            Expanded(
              child: _MessageDetailBody(
                state: state,
                scrollController: _scrollController,
                conversationId: widget.conversationId,
                onRetry: _loadMessages,
              ),
            ),
            if (hasConversationId)
              MessageComposer(isSending: state.isSending, onSend: _sendMessage),
          ],
        ),
      ),
    );
  }
}

class _ConversationHeader extends StatelessWidget {
  const _ConversationHeader({required this.title, required this.conversation});

  final String title;
  final Conversation? conversation;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      decoration: const BoxDecoration(
        color: ZayColors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 24,
            offset: Offset(0, 14),
          ),
        ],
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(18),
          bottomRight: Radius.circular(18),
        ),
      ),
      child: Row(
        children: [
          ConversationAvatar(title: title, size: 64),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ZayTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                    color: ZayColors.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  conversation?.isClosed == true ? 'Closed' : 'Active',
                  style: ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
                    color: const Color(0xFF23D36B),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          const Icon(
            Icons.videocam_outlined,
            color: ZayColors.textPrimary,
            size: 28,
          ),
          const SizedBox(width: 22),
          const Icon(
            Icons.call_outlined,
            color: ZayColors.textPrimary,
            size: 24,
          ),
        ],
      ),
    );
  }
}

class _MessageDetailBody extends StatelessWidget {
  const _MessageDetailBody({
    required this.state,
    required this.scrollController,
    required this.conversationId,
    required this.onRetry,
  });

  final MessageState state;
  final ScrollController scrollController;
  final String? conversationId;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    if (conversationId == null || conversationId!.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.chat_bubble_outline_rounded,
        title: 'Conversation unavailable',
        message: 'The selected conversation could not be opened.',
      );
    }

    if (state.isLoadingMessages && !state.hasLoadedMessages) {
      return const LoadingStateWidget(message: 'Loading messages...');
    }

    if (state.hasError && state.messages.isEmpty) {
      return ErrorStateWidget(
        title: 'Conversation unavailable',
        message: state.errorMessage ?? 'Unable to load messages.',
        onRetry: () => onRetry(),
      );
    }

    if (state.messages.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.chat_outlined,
        title: 'No messages yet',
        message: 'Send a message to start this conversation.',
        actionText: 'Refresh',
        onAction: () => onRetry(),
      );
    }

    final messages = state.sortedMessages;

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(24, 34, 24, 18),
      itemCount: messages.length + (state.hasError ? 1 : 0),
      itemBuilder: (context, index) {
        if (state.hasError && index == 0) {
          return _InlineSendError(
            message: state.errorMessage ?? 'Unable to send message.',
          );
        }

        final messageIndex = index - (state.hasError ? 1 : 0);
        final message = messages[messageIndex];
        final previous = messageIndex > 0 ? messages[messageIndex - 1] : null;

        return MessageBubble(
          message: message,
          showDateLabel: _shouldShowDateLabel(previous, message),
        );
      },
    );
  }
}

class _InlineSendError extends StatelessWidget {
  const _InlineSendError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ZayColors.secondary.withAlpha(35),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: ZayColors.primary,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: ZayTheme.lightTheme.textTheme.displayMedium?.copyWith(
                color: ZayColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

bool _shouldShowDateLabel(Message? previous, Message current) {
  if (previous == null) {
    return true;
  }

  return previous.createdAt.year != current.createdAt.year ||
      previous.createdAt.month != current.createdAt.month ||
      previous.createdAt.day != current.createdAt.day;
}
