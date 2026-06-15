import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zayrova/core/constants/colors.dart';
import 'package:zayrova/core/themes/zay_theme.dart';
import 'package:zayrova/domain/entities/notification_item_entity.dart';
import 'package:zayrova/presentation/components/empty_state.dart';
import 'package:zayrova/presentation/components/error_state.dart';
import 'package:zayrova/presentation/components/loading_state.dart';
import 'package:zayrova/presentation/components/zay_network_image.dart';
import 'package:zayrova/presentation/providers/feature/notification_controller.dart';
import 'package:zayrova/presentation/routes/zay_router.dart';
import 'package:zayrova/presentation/routes/zay_routes.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadNotifications());
  }

  Future<void> _loadNotifications() {
    return ref.read(notificationControllerProvider.notifier).loadNotifications();
  }

  Future<void> _markAllAsRead() {
    return ref.read(notificationControllerProvider.notifier).markAllAsRead();
  }

  Future<void> _markAsRead(NotificationItem notification) {
    return ref
        .read(notificationControllerProvider.notifier)
        .markAsRead(notification.id);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationControllerProvider);

    return Scaffold(
      backgroundColor: ZayColors.white,
      body: SafeArea(
        child: Column(
          children: [
            _NotificationHeader(
              unreadCount: state.unreadCount,
              isUpdating: state.isUpdating,
              onMarkAllRead: state.hasUnread ? _markAllAsRead : null,
            ),
            Expanded(
              child: _NotificationBody(
                state: state,
                onRetry: _loadNotifications,
                onRefresh: _loadNotifications,
                onMarkAsRead: _markAsRead,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationHeader extends StatelessWidget {
  const _NotificationHeader({
    required this.unreadCount,
    required this.isUpdating,
    required this.onMarkAllRead,
  });

  final int unreadCount;
  final bool isUpdating;
  final VoidCallback? onMarkAllRead;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 20),
      child: Row(
        children: [
          _HeaderIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: ZayRouter.goBack,
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'Notification',
                  style: ZayTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                    color: ZayColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (unreadCount > 0) ...[
                  const SizedBox(height: 3),
                  Text(
                    '$unreadCount unread',
                    style: ZayTheme.lightTheme.textTheme.displaySmall
                        ?.copyWith(color: ZayColors.textSecondary),
                  ),
                ],
              ],
            ),
          ),
          PopupMenuButton<String>(
            tooltip: 'Notification actions',
            enabled: !isUpdating,
            color: ZayColors.white,
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            onSelected: (value) {
              if (value == 'mark_all') {
                onMarkAllRead?.call();
                return;
              }

              if (value == 'settings') {
                ZayRouter.goto(ZayRoutes.settings);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'mark_all',
                enabled: onMarkAllRead != null,
                child: const Text('Mark all as read'),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Text('Notification settings'),
              ),
            ],
            child: _HeaderIconButton(
              icon: Icons.settings_outlined,
              onTap: null,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
  });

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

class _NotificationBody extends StatelessWidget {
  const _NotificationBody({
    required this.state,
    required this.onRetry,
    required this.onRefresh,
    required this.onMarkAsRead,
  });

  final NotificationState state;
  final Future<void> Function() onRetry;
  final Future<void> Function() onRefresh;
  final Future<void> Function(NotificationItem notification) onMarkAsRead;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && !state.hasLoadedNotifications) {
      return const LoadingStateWidget(message: 'Loading notifications...');
    }

    if (state.hasError && !state.hasLoadedNotifications) {
      return ErrorStateWidget(
        title: 'Notifications unavailable',
        message: state.errorMessage ?? 'Unable to load notifications.',
        onRetry: () => onRetry(),
      );
    }

    if (state.notifications.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.notifications_none_rounded,
        title: 'No notifications yet',
        message: 'Updates about orders, messages, and account activity will '
            'appear here.',
        actionText: 'Refresh',
        onAction: () => onRetry(),
      );
    }

    final notifications = state.sortedNotifications;
    final hasInlineError = state.hasError;

    return RefreshIndicator(
      color: ZayColors.primary,
      onRefresh: onRefresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
        itemCount: notifications.length + 1 + (hasInlineError ? 1 : 0),
        separatorBuilder: (context, index) {
          if (index == 0) {
            return const SizedBox(height: 10);
          }

          return const _NotificationDivider();
        },
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 18),
              child: Text(
                'Recent',
                style: ZayTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                  color: ZayColors.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            );
          }

          if (hasInlineError && index == 1) {
            return _NotificationInlineError(
              message: state.errorMessage ?? 'Unable to update notification.',
            );
          }

          final notificationIndex = index - 1 - (hasInlineError ? 1 : 0);
          final notification = notifications[notificationIndex];

          return NotificationTile(
            notification: notification,
            onTap: () => onMarkAsRead(notification),
          );
        },
      ),
    );
  }
}

class _NotificationInlineError extends StatelessWidget {
  const _NotificationInlineError({required this.message});

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

class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  final NotificationItem notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _NotificationAvatar(notification: notification),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: ZayTheme.lightTheme.textTheme.displayLarge
                              ?.copyWith(
                            color: ZayColors.textPrimary,
                            fontWeight:
                                isUnread ? FontWeight.w900 : FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _relativeTime(notification.createdAt),
                        style: ZayTheme.lightTheme.textTheme.displayMedium
                            ?.copyWith(color: ZayColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    notification.message,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style:
                        ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
                      color: ZayColors.textSecondary,
                      height: 1.55,
                      fontWeight:
                          isUnread ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  if (notification.type == NotificationType.message) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Reply the message',
                      style: ZayTheme.lightTheme.textTheme.displayLarge
                          ?.copyWith(
                        color: ZayColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isUnread) ...[
              const SizedBox(width: 8),
              Container(
                width: 9,
                height: 9,
                margin: const EdgeInsets.only(top: 8),
                decoration: const BoxDecoration(
                  color: ZayColors.secondary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NotificationAvatar extends StatelessWidget {
  const _NotificationAvatar({required this.notification});

  final NotificationItem notification;

  @override
  Widget build(BuildContext context) {
    final imageUrl = notification.imageUrl;

    if (imageUrl != null && imageUrl.isNotEmpty) {
      return ClipOval(
        child: ZayNetworkImage(
          imageUrl: imageUrl,
          width: 64,
          height: 64,
          fit: BoxFit.cover,
        ),
      );
    }

    return Container(
      width: 64,
      height: 64,
      decoration: const BoxDecoration(
        color: Color(0xFFFAFAFA),
        shape: BoxShape.circle,
      ),
      child: Icon(
        _iconForType(notification.type),
        color: ZayColors.textPrimary,
        size: 30,
      ),
    );
  }
}

class _NotificationDivider extends StatelessWidget {
  const _NotificationDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 1,
      color: Color(0xFFF0F0F0),
    );
  }
}

IconData _iconForType(NotificationType type) {
  switch (type) {
    case NotificationType.order:
      return Icons.local_mall_outlined;
    case NotificationType.promotion:
      return Icons.discount_outlined;
    case NotificationType.account:
      return Icons.person_outline_rounded;
    case NotificationType.system:
      return Icons.settings_outlined;
    case NotificationType.message:
      return Icons.chat_bubble_outline_rounded;
    case NotificationType.other:
      return Icons.notifications_none_rounded;
  }
}

String _relativeTime(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inMinutes < 1) {
    return 'Just now';
  }

  if (difference.inMinutes < 60) {
    return '${difference.inMinutes} m ago';
  }

  if (difference.inHours < 24) {
    return '${difference.inHours} h ago';
  }

  if (difference.inDays < 7) {
    return '${difference.inDays} d ago';
  }

  final day = dateTime.day.toString().padLeft(2, '0');
  final month = dateTime.month.toString().padLeft(2, '0');
  return '$day/$month/${dateTime.year}';
}
