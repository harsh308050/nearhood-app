import 'dart:async';
import 'package:shimmer/shimmer.dart';
import 'package:nearhood/core/utils/custom_import.dart';
import 'package:nearhood/core/utils/time_ago_formatter.dart';
import 'package:nearhood/core/services/fcm_service.dart';
import 'package:nearhood/features/notifications/data/notification_datasource.dart';
import 'package:nearhood/features/notifications/data/models/notification_model.dart';
import 'package:nearhood/features/post/screens/post_detail_screen.dart';
import 'package:nearhood/features/chat/screens/chat_detail_screen.dart';
import 'package:nearhood/features/chat/models/chat_user.dart';

/// Notification Screen
///
/// Displays user's notification history with:
/// - Category-based icons on the left
/// - Title, body, and timestamp on the right
/// - Unread indicator (bold text + colored dot)
/// - Pull to refresh
/// - Pagination (load more on scroll)
/// - Mark as read on tap + navigate to post detail
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationDataSource _dataSource = NotificationDataSource();
  final ScrollController _scrollController = ScrollController();

  List<NotificationModel> _notifications = [];
  NotificationPagination? _pagination;
  int _unreadCount = 0;
  StreamSubscription<dynamic>? _fcmSub;

  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _scrollController.addListener(_onScroll);
    _fcmSub = FCMService().onMessage.listen((_) {
      if (mounted) _loadNotifications(refresh: true);
    });
  }

  @override
  void dispose() {
    _fcmSub?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Load more when scrolled to 80% of the list
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      if (!_isLoadingMore && _pagination != null && _pagination!.hasMore) {
        _loadMoreNotifications();
      }
    }
  }

  Future<void> _loadNotifications({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
    }

    try {
      final response = await _dataSource.getNotifications(page: 1, limit: 20);

      if (response != null) {
        setState(() {
          _notifications = response.notifications;
          _pagination = response.pagination;
          _unreadCount = response.unreadCount;
          _isLoading = false;
          _hasError = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    } catch (e) {
      debugPrint('❌ Load notifications error: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  Future<void> _loadMoreNotifications() async {
    if (_pagination == null || !_pagination!.hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final response = await _dataSource.getNotifications(
        page: _pagination!.currentPage + 1,
        limit: 20,
      );

      if (response != null) {
        setState(() {
          _notifications.addAll(response.notifications);
          _pagination = response.pagination;
          _unreadCount = response.unreadCount;
          _isLoadingMore = false;
        });
      } else {
        setState(() {
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Load more error: $e');
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _handleNotificationTap(NotificationModel notification) async {
    // Mark as read if unread
    if (!notification.isRead) {
      final newUnreadCount = await _dataSource.markAsRead(notification.id);

      if (newUnreadCount != null) {
        setState(() {
          // Update local notification state
          final index = _notifications.indexWhere(
            (n) => n.id == notification.id,
          );
          if (index != -1) {
            _notifications[index] = _notifications[index].copyWith(
              isRead: true,
              readAt: DateTime.now(),
            );
          }
          _unreadCount = newUnreadCount;
        });
      }
    }

    // Navigate based on notification type
    if (notification.type == 'CHAT_MESSAGE') {
      final senderId = notification.senderId ?? notification.data['senderId'] as String?;
      final senderName = notification.data['senderName'] as String? ?? notification.title;
      if (senderId != null && mounted) {
        callNextScreen(
          context,
          ChatDetailScreen(
            receiverId: senderId,
            otherUser: ChatUser(id: senderId, fullName: senderName),
          ),
        );
      }
    } else if (notification.postId != null) {
      if (!mounted) return;
      callNextScreen(context, PostDetailScreen(postId: notification.postId!));
    }
  }

  Future<void> _markAllAsRead() async {
    final modifiedCount = await _dataSource.markAllAsRead();

    if (modifiedCount != null && modifiedCount > 0) {
      setState(() {
        // Update all notifications to read
        _notifications = _notifications
            .map((n) => n.copyWith(isRead: true, readAt: DateTime.now()))
            .toList();
        _unreadCount = 0;
      });

      if (mounted) {
        AppSnackBar.showMessage(
          context,
          'Marked $modifiedCount notification${modifiedCount > 1 ? 's' : ''} as read',
          borderColor: AppColors.primaryBlue,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CommonAppBar(
        backgroundColor: AppColors.white,
        title: 'Notifications',
        actionButton: _unreadCount > 0
            ? TextButton(
                onPressed: _markAllAsRead,
                child: CustomText(
                  'Mark all read',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlue,
                  ),
                ),
              )
            : null,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildNotificationShimmer();
    }

    if (_hasError) {
      return EmptyStateWidget(
        title: 'Failed to load notifications',
        subtitle: 'There was an error fetching your notification history. Please try again.',
        btnText: 'Try again',
        onPressed: () => _loadNotifications(refresh: true),
      );
    }

    if (_notifications.isEmpty) {
      return EmptyStateWidget(
        showButton: false,
        title: "No Notifications Yet",
        subtitle: "When you receive notifications, they will appear here",
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadNotifications(refresh: true),
      color: AppColors.primaryBlue,
      child: ListView.separated(
        controller: _scrollController,
        padding: EdgeInsets.symmetric(vertical: 8.h),
        itemCount: _notifications.length + (_isLoadingMore ? 1 : 0),
        separatorBuilder: (context, index) =>
            Divider(height: 1, thickness: 1, color: AppColors.borderLight),
        itemBuilder: (context, index) {
          if (index == _notifications.length) {
            // Loading more shimmer tile
            return Shimmer.fromColors(
              baseColor: Colors.grey.withValues(alpha: 0.15),
              highlightColor: Colors.grey.withValues(alpha: 0.05),
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48.w,
                      height: 48.w,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 14.h,
                            width: 150.w,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 8.h),
                          Container(
                            height: 12.h,
                            width: double.infinity,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final notification = _notifications[index];
          return _NotificationTile(
            notification: notification,
            onTap: () => _handleNotificationTap(notification),
          );
        },
      ),
    );
  }

  Widget _buildNotificationShimmer() {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.symmetric(vertical: 8.h),
      itemCount: 8,
      separatorBuilder: (context, index) =>
          Divider(height: 1, thickness: 1, color: AppColors.borderLight),
      itemBuilder: (context, index) {
        return Container(
          color: AppColors.white,
          padding: EdgeInsets.all(16.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon shimmer
              Shimmer.fromColors(
                baseColor: Colors.grey.withValues(alpha: 0.15),
                highlightColor: Colors.grey.withValues(alpha: 0.05),
                child: Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              // Content shimmer
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title shimmer
                    Shimmer.fromColors(
                      baseColor: Colors.grey.withValues(alpha: 0.15),
                      highlightColor: Colors.grey.withValues(alpha: 0.05),
                      child: Container(
                        height: 14.h,
                        width: 160.w,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    // Body line 1 shimmer
                    Shimmer.fromColors(
                      baseColor: Colors.grey.withValues(alpha: 0.15),
                      highlightColor: Colors.grey.withValues(alpha: 0.05),
                      child: Container(
                        height: 12.h,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    // Body line 2 shimmer
                    Shimmer.fromColors(
                      baseColor: Colors.grey.withValues(alpha: 0.15),
                      highlightColor: Colors.grey.withValues(alpha: 0.05),
                      child: Container(
                        height: 12.h,
                        width: 200.w,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    // Time ago shimmer
                    Shimmer.fromColors(
                      baseColor: Colors.grey.withValues(alpha: 0.15),
                      highlightColor: Colors.grey.withValues(alpha: 0.05),
                      child: Container(
                        height: 10.h,
                        width: 60.w,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Individual notification tile widget
class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const _NotificationTile({required this.notification, required this.onTap});

  Color _getCategoryColor() {
    if (notification.type == 'CHAT_MESSAGE') return AppColors.primaryBlue;
    switch (notification.category) {
      case 'Safety Alert':
        return AppColors.red;
      case 'Event':
        return Colors.purple;
      case 'Lost & Found':
        return Colors.orange;
      case 'For Sale':
        return AppColors.green;
      case 'Recommendation':
        return AppColors.blue;
      case 'Question':
        return Colors.amber;
      default:
        return AppColors.primaryBlue;
    }
  }

  IconData _getCategoryIcon() {
    if (notification.type == 'CHAT_MESSAGE') return Icons.chat_bubble_rounded;
    switch (notification.category) {
      case 'Safety Alert':
        return Icons.warning_rounded;
      case 'Event':
        return Icons.event_rounded;
      case 'Lost & Found':
        return Icons.search_rounded;
      case 'For Sale':
        return Icons.sell_rounded;
      case 'Recommendation':
        return Icons.recommend_rounded;
      case 'Question':
        return Icons.help_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getCategoryColor();
    final icon = _getCategoryIcon();
    final timeAgo = formatTimeAgoNotification(notification.createdAt);

    return InkWell(
      onTap: onTap,
      child: Container(
        color: notification.isRead ? AppColors.white : AppColors.bgBlue,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CONTENT: Row(CATEGORY + COLUMN {TITLE + CONTENT})
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CATEGORY (icon)
                  Container(
                    width: 48.w,
                    height: 48.w,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(24.r), // circular
                    ),
                    child: Icon(icon, color: color, size: 26.r),
                  ),
                  SizedBox(width: 12.w),
                  // COLUMN {TITLE + CONTENT}
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          notification.title,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: notification.isRead
                                ? FontWeight.w600
                                : FontWeight.w700,
                            color: AppColors.darkGrey,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        CustomText(
                          notification.type == 'CHAT_MESSAGE' && notification.messageCount > 1
                              ? '${notification.body} (${notification.messageCount} messages)'
                              : notification.body,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: AppColors.grey,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            // COLUMN {INDICATOR + TIME AGO}
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!notification.isRead)
                  Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                  )
                else
                  SizedBox(width: 8.w, height: 8.w),
                SizedBox(height: 12.h),
                CustomText(
                  timeAgo,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.placeholderText,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
