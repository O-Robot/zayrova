import 'package:flutter/material.dart';
import 'package:zayrova/core/constants/colors.dart';
import 'package:zayrova/core/themes/zay_theme.dart';
import 'package:zayrova/domain/entities/conversation_entity.dart';
import 'package:zayrova/domain/entities/message_entity.dart';

class MessageHeader extends StatelessWidget {
  const MessageHeader({
    super.key,
    required this.title,
    required this.onBack,
    this.onNotification,
  });

  final String title;
  final VoidCallback onBack;
  final VoidCallback? onNotification;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 20),
      child: Row(
        children: [
          _HeaderIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: onBack,
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: ZayTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                color: ZayColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          _NotificationHeaderButton(onTap: onNotification),
        ],
      ),
    );
  }
}

class MessageSearchBar extends StatelessWidget {
  const MessageSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: ZayColors.white,
        border: Border.all(color: ZayColors.inputBorder.withAlpha(150)),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.search_rounded,
            color: ZayColors.textPrimary,
            size: 34,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: 'Search something...',
                border: InputBorder.none,
                hintStyle: ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
                  color: ZayColors.textSecondary,
                ),
              ),
              style: ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
                color: ZayColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Icon(
            Icons.tune_rounded,
            color: ZayColors.textPrimary,
            size: 30,
          ),
        ],
      ),
    );
  }
}

class ConversationAvatar extends StatelessWidget {
  const ConversationAvatar({
    super.key,
    required this.title,
    this.size = 74,
    this.borderWidth = 3,
  });

  final String title;
  final double size;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    final initials = _initialsForTitle(title);

    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(borderWidth),
      decoration: const BoxDecoration(
        color: ZayColors.primary,
        shape: BoxShape.circle,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF2F2F2),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            initials,
            style: ZayTheme.lightTheme.textTheme.bodyLarge?.copyWith(
              color: ZayColors.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class ActivityAvatarItem extends StatelessWidget {
  const ActivityAvatarItem({
    super.key,
    required this.conversation,
    required this.onTap,
  });

  final Conversation conversation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 92,
        child: Column(
          children: [
            ConversationAvatar(title: conversation.title, size: 74),
            const SizedBox(height: 10),
            Text(
              conversation.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
                color: ZayColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ConversationTile extends StatelessWidget {
  const ConversationTile({
    super.key,
    required this.conversation,
    required this.onTap,
  });

  final Conversation conversation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final lastMessage = conversation.lastMessage;
    final unreadCount = conversation.unreadCount;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ConversationAvatar(title: conversation.title, size: 64),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conversation.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
                      color: ZayColors.textPrimary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    lastMessage?.body ?? 'No messages yet.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
                      color: ZayColors.textSecondary,
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _relativeTime(
                    lastMessage?.createdAt ??
                        conversation.updatedAt ??
                        conversation.createdAt,
                  ),
                  style: ZayTheme.lightTheme.textTheme.displayMedium?.copyWith(
                    color: ZayColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (unreadCount > 0) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: 23,
                    height: 23,
                    decoration: const BoxDecoration(
                      color: ZayColors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        unreadCount > 9 ? '9+' : unreadCount.toString(),
                        style: ZayTheme.lightTheme.textTheme.displaySmall
                            ?.copyWith(
                              color: ZayColors.white,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.showDateLabel,
  });

  final Message message;
  final bool showDateLabel;

  @override
  Widget build(BuildContext context) {
    final isMine = message.senderType == MessageSenderType.customer;

    return Column(
      crossAxisAlignment:
          isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if (showDateLabel) ...[
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(
                _dateLabel(message.createdAt),
                style: ZayTheme.lightTheme.textTheme.displaySmall?.copyWith(
                  color: ZayColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
        Align(
          alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280),
            child: Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 17),
              decoration: BoxDecoration(
                color: isMine ? ZayColors.primary : ZayColors.cancel,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(22),
                  topRight: const Radius.circular(22),
                  bottomLeft: Radius.circular(isMine ? 22 : 0),
                  bottomRight: Radius.circular(isMine ? 0 : 22),
                ),
              ),
              child: Text(
                message.body,
                style: ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
                  color: isMine ? ZayColors.white : ZayColors.textPrimary,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            left: isMine ? 0 : 2,
            right: isMine ? 2 : 0,
            bottom: 18,
          ),
          child: Text(
            _timeLabel(message.createdAt),
            style: ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
              color: ZayColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class MessageComposer extends StatefulWidget {
  const MessageComposer({
    super.key,
    required this.onSend,
    this.isSending = false,
  });

  final ValueChanged<String> onSend;
  final bool isSending;

  @override
  State<MessageComposer> createState() => _MessageComposerState();
}

class _MessageComposerState extends State<MessageComposer> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final body = _controller.text.trim();
    if (body.isEmpty || widget.isSending) {
      return;
    }

    widget.onSend(body);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 18),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: ZayColors.white,
                border: Border.all(color: ZayColors.inputBorder),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.photo_camera_outlined,
                    color: ZayColors.textSecondary,
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Container(width: 1, height: 34, color: ZayColors.inputBorder),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: 'Type message...',
                        border: InputBorder.none,
                        hintStyle: ZayTheme.lightTheme.textTheme.displayMedium
                            ?.copyWith(
                              color: ZayColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      style: ZayTheme.lightTheme.textTheme.displayMedium
                          ?.copyWith(
                            color: ZayColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  // const Icon(
                  //   Icons.mic_none_rounded,
                  //   color: ZayColors.textSecondary,
                  //   size: 28,
                  // ),
                  // const SizedBox(width: 12),
                  // const Icon(
                  //   Icons.attach_file_rounded,
                  //   color: ZayColors.textSecondary,
                  //   size: 26,
                  // ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 14),
          GestureDetector(
            onTap: _send,
            child: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color:
                    widget.isSending
                        ? ZayColors.primary.withAlpha(130)
                        : ZayColors.primary,
                shape: BoxShape.circle,
              ),
              child:
                  widget.isSending
                      ? const Padding(
                        padding: EdgeInsets.all(15),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: ZayColors.white,
                        ),
                      )
                      : const Icon(
                        Icons.send_rounded,
                        color: ZayColors.white,
                        size: 25,
                      ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        width: 44,
        height: 44,
        child: Icon(icon, color: ZayColors.textPrimary, size: 24),
      ),
    );
  }
}

class _NotificationHeaderButton extends StatelessWidget {
  const _NotificationHeaderButton({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            const Icon(
              Icons.notifications_none_rounded,
              color: ZayColors.textPrimary,
              size: 30,
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Color(0xFFE30000),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _initialsForTitle(String title) {
  final words = title.trim().split(RegExp(r'\s+'));
  if (words.isEmpty || words.first.isEmpty) {
    return '?';
  }

  if (words.length == 1) {
    return words.first.substring(0, 1).toUpperCase();
  }

  return '${words.first.substring(0, 1)}${words.last.substring(0, 1)}'
      .toUpperCase();
}

String _relativeTime(DateTime dateTime) {
  final difference = DateTime.now().difference(dateTime);

  if (difference.inMinutes < 1) {
    return 'Now';
  }
  if (difference.inMinutes < 60) {
    return '${difference.inMinutes} min';
  }
  if (difference.inHours < 24) {
    return '${difference.inHours} hr';
  }
  if (difference.inDays < 7) {
    return '${difference.inDays} d';
  }

  final day = dateTime.day.toString().padLeft(2, '0');
  final month = dateTime.month.toString().padLeft(2, '0');
  return '$day/$month';
}

String _timeLabel(DateTime dateTime) {
  final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
  final minute = dateTime.minute.toString().padLeft(2, '0');
  final period = dateTime.hour >= 12 ? 'PM' : 'AM';
  return '$hour.$minute $period';
}

String _dateLabel(DateTime dateTime) {
  final now = DateTime.now();
  if (dateTime.year == now.year &&
      dateTime.month == now.month &&
      dateTime.day == now.day) {
    return 'Today';
  }

  final yesterday = now.subtract(const Duration(days: 1));
  if (dateTime.year == yesterday.year &&
      dateTime.month == yesterday.month &&
      dateTime.day == yesterday.day) {
    return 'Yesterday';
  }

  final day = dateTime.day.toString().padLeft(2, '0');
  final month = dateTime.month.toString().padLeft(2, '0');
  return '$day/$month/${dateTime.year}';
}
