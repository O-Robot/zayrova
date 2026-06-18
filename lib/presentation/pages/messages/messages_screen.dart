import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zayrova/core/constants/colors.dart';
import 'package:zayrova/core/themes/zay_theme.dart';
import 'package:zayrova/domain/entities/conversation_entity.dart';
import 'package:zayrova/presentation/components/empty_state.dart';
import 'package:zayrova/presentation/components/error_state.dart';
import 'package:zayrova/presentation/components/loading_state.dart';
import 'package:zayrova/presentation/pages/messages/message_components.dart';
import 'package:zayrova/presentation/providers/feature/message_controller.dart';
import 'package:zayrova/presentation/routes/zay_router.dart';
import 'package:zayrova/presentation/routes/zay_routes.dart';

class MessagesScreen extends ConsumerStatefulWidget {
  const MessagesScreen({super.key});

  @override
  ConsumerState<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<MessagesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadConversations());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadConversations() {
    return ref.read(messageControllerProvider.notifier).loadConversations();
  }

  void _openConversation(Conversation conversation) {
    ZayRouter.goto(ZayRoutes.messageDetail, {
      'conversationId': conversation.id,
      'title': conversation.title,
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(messageControllerProvider);
    final conversations = _filteredConversations(state.sortedConversations);

    return Scaffold(
      backgroundColor: ZayColors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MessageHeader(
              title: 'Message',
              onBack: () => ZayRouter.goBack(),
              onNotification: () => ZayRouter.goto(ZayRoutes.notifications),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
              child: MessageSearchBar(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
              ),
            ),
            Expanded(
              child: _MessagesBody(
                state: state,
                conversations: conversations,
                isSearching: _query.trim().isNotEmpty,
                onRetry: _loadConversations,
                onRefresh: _loadConversations,
                onOpenConversation: _openConversation,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Conversation> _filteredConversations(List<Conversation> conversations) {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) {
      return conversations;
    }

    return conversations.where((conversation) {
      final preview = conversation.lastMessage?.body.toLowerCase() ?? '';
      return conversation.title.toLowerCase().contains(query) ||
          preview.contains(query);
    }).toList();
  }
}

class _MessagesBody extends StatelessWidget {
  const _MessagesBody({
    required this.state,
    required this.conversations,
    required this.isSearching,
    required this.onRetry,
    required this.onRefresh,
    required this.onOpenConversation,
  });

  final MessageState state;
  final List<Conversation> conversations;
  final bool isSearching;
  final Future<void> Function() onRetry;
  final Future<void> Function() onRefresh;
  final ValueChanged<Conversation> onOpenConversation;

  @override
  Widget build(BuildContext context) {
    if (state.isLoadingConversations && !state.hasLoadedConversations) {
      return const LoadingStateWidget(message: 'Loading conversations...');
    }

    if (state.hasError && state.conversations.isEmpty) {
      return ErrorStateWidget(
        title: 'Messages unavailable',
        message: state.errorMessage ?? 'Unable to load conversations.',
        onRetry: () => onRetry(),
      );
    }

    if (state.conversations.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.chat_bubble_outline_rounded,
        title: 'No conversations yet',
        message: 'Customer support and seller messages will appear here.',
        actionText: 'Refresh',
        onAction: () => onRetry(),
      );
    }

    if (conversations.isEmpty && isSearching) {
      return EmptyStateWidget(
        icon: Icons.search_off_rounded,
        title: 'No messages found',
        message: 'Try searching by conversation name or message preview.',
      );
    }

    return RefreshIndicator(
      color: ZayColors.primary,
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 36, 24, 28),
        children: [
          Text(
            'Activities',
            style: ZayTheme.lightTheme.textTheme.titleLarge?.copyWith(
              color: ZayColors.textPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 116,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final conversation = conversations[index];
                return ActivityAvatarItem(
                  conversation: conversation,
                  onTap: () => onOpenConversation(conversation),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 18),
              itemCount: conversations.length > 8 ? 8 : conversations.length,
            ),
          ),
          const SizedBox(height: 34),
          Text(
            'Messages',
            style: ZayTheme.lightTheme.textTheme.titleLarge?.copyWith(
              color: ZayColors.textPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: 12),
          if (state.hasError)
            _InlineMessageError(
              message: state.errorMessage ?? 'Unable to update messages.',
            ),
          ...conversations.map(
            (conversation) => ConversationTile(
              conversation: conversation,
              onTap: () => onOpenConversation(conversation),
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineMessageError extends StatelessWidget {
  const _InlineMessageError({required this.message});

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
