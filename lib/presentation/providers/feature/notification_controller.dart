import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zayrova/domain/entities/notification_item_entity.dart';
import 'package:zayrova/presentation/providers/usecase_providers.dart';

final notificationControllerProvider =
    NotifierProvider<NotificationController, NotificationState>(
  NotificationController.new,
);

class NotificationState {
  const NotificationState({
    this.notifications = const [],
    this.isLoading = false,
    this.isUpdating = false,
    this.errorMessage,
    this.hasLoadedNotifications = false,
  });

  final List<NotificationItem> notifications;
  final bool isLoading;
  final bool isUpdating;
  final String? errorMessage;
  final bool hasLoadedNotifications;

  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  int get unreadCount {
    return notifications.where((notification) => !notification.isRead).length;
  }

  bool get hasUnread => unreadCount > 0;

  List<NotificationItem> get sortedNotifications {
    final sorted = [...notifications];
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted;
  }

  NotificationState copyWith({
    List<NotificationItem>? notifications,
    bool? isLoading,
    bool? isUpdating,
    String? errorMessage,
    bool? hasLoadedNotifications,
    bool clearError = false,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      isUpdating: isUpdating ?? this.isUpdating,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      hasLoadedNotifications:
          hasLoadedNotifications ?? this.hasLoadedNotifications,
    );
  }
}

class NotificationController extends Notifier<NotificationState> {
  @override
  NotificationState build() {
    return const NotificationState();
  }

  Future<void> loadNotifications({bool? isRead}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await ref.read(getNotificationsUseCaseProvider).call(
          isRead: isRead,
        );

    if (result.isSuccess && result.data != null) {
      state = state.copyWith(
        notifications: result.data,
        isLoading: false,
        hasLoadedNotifications: true,
      );
      return;
    }

    state = state.copyWith(
      isLoading: false,
      errorMessage: result.message ?? 'Unable to load notifications.',
      hasLoadedNotifications: true,
    );
  }

  Future<void> markAsRead(String id) async {
    NotificationItem? currentItem;
    for (final notification in state.notifications) {
      if (notification.id == id) {
        currentItem = notification;
        break;
      }
    }

    if (currentItem == null || currentItem.isRead) {
      return;
    }

    state = state.copyWith(isUpdating: true, clearError: true);

    final result =
        await ref.read(markNotificationAsReadUseCaseProvider).call(id);

    if (result.isSuccess && result.data != null) {
      final updatedNotification = result.data!;
      final updated = state.notifications.map((notification) {
        if (notification.id != id) {
          return notification;
        }

        return updatedNotification.id == id
            ? updatedNotification
            : notification.copyWith(isRead: true);
      }).toList();

      state = state.copyWith(
        notifications: updated,
        isUpdating: false,
      );
      return;
    }

    state = state.copyWith(
      isUpdating: false,
      errorMessage: result.message ?? 'Unable to update notification.',
    );
  }

  Future<void> markAllAsRead() async {
    if (!state.hasUnread) {
      return;
    }

    state = state.copyWith(isUpdating: true, clearError: true);

    final result = await ref.read(markAllNotificationsAsReadUseCaseProvider)();

    if (result.isSuccess) {
      final updatesById = {
        for (final notification in result.data ?? <NotificationItem>[])
          notification.id: notification,
      };

      final updated = state.notifications.map((notification) {
        return updatesById[notification.id] ??
            notification.copyWith(isRead: true);
      }).toList();

      state = state.copyWith(
        notifications: updated,
        isUpdating: false,
      );
      return;
    }

    state = state.copyWith(
      isUpdating: false,
      errorMessage: result.message ?? 'Unable to update notifications.',
    );
  }
}
