import 'dart:async';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:nearhood/core/utils/custom_import.dart';
import 'package:nearhood/features/chat/bloc/chat_bloc.dart';
import 'package:nearhood/features/chat/bloc/chat_event.dart';
import 'package:nearhood/features/chat/bloc/chat_state.dart';
import 'package:nearhood/features/chat/models/message_model.dart';
import 'package:nearhood/features/chat/models/chat_user.dart';
import 'package:nearhood/common_widget/user_avatar_widget.dart';
import 'package:nearhood/common_widget/long_press_overlay_menu.dart';
import 'package:nearhood/common_widget/report_dialog.dart';
import 'package:nearhood/core/services/fcm_service.dart';
import 'package:nearhood/core/utils/shared_pref_helper.dart';
import 'package:shimmer/shimmer.dart';

class ChatDetailScreen extends StatefulWidget {
  final String? conversationId;
  final String receiverId;
  final ChatUser otherUser;

  const ChatDetailScreen({
    super.key,
    this.conversationId,
    required this.receiverId,
    required this.otherUser,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();
  late final String? _currentUserId;
  ChatBloc? _chatBloc;
  String? _conversationId;
  bool _isInitialized = false;
  final Set<String> _markedMessageIds = {};
  int? _previousMessageCount;
  Timer? _typingDebounceTimer;

  @override
  void initState() {
    super.initState();
    _currentUserId = sharedPrefGetUser()?.id;
    _chatBloc = context.read<ChatBloc>();
    _conversationId = widget.conversationId;

    // Suppress foreground notifications for this conversation
    FCMService().activeConversationId = _conversationId;

    _messageController.addListener(_onMessageChanged);
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_conversationId != null) {
        _joinAndLoadMessages(_conversationId!);
      } else {
        _chatBloc?.add(CreateConversation(widget.receiverId));
      }
    });
  }

  void _joinAndLoadMessages(String conversationId) {
    _chatBloc!.add(JoinConversation(conversationId));
    _chatBloc!.add(LoadMessages(conversationId));
    _chatBloc!.add(
      MarkAsRead(conversationId: conversationId, readerId: widget.otherUser.id),
    );
  }

  @override
  void dispose() {
    _messageController.removeListener(_onMessageChanged);
    _scrollController.removeListener(_onScroll);
    final wasTyping = _typingDebounceTimer != null;
    _typingDebounceTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    _messageFocusNode.dispose();

    // Clear active conversation so notifications resume
    FCMService().activeConversationId = null;

    if (wasTyping) {
      _chatBloc?.add(
        StopTyping(
          conversationId: _conversationId,
          receiverId: widget.otherUser.id,
        ),
      );
    }

    if (_conversationId != null) {
      _chatBloc?.add(LeaveConversation(_conversationId!));
    }
    _chatBloc = null;
    super.dispose();
  }

  void _onMessageChanged() {
    final wasTyping = _typingDebounceTimer != null;
    _typingDebounceTimer?.cancel();
    _typingDebounceTimer = null;
    final hasText = _messageController.text.trim().isNotEmpty;

    if (!hasText) {
      if (wasTyping) {
        _chatBloc?.add(
          StopTyping(
            conversationId: _conversationId,
            receiverId: widget.otherUser.id,
          ),
        );
      }
      return;
    }

    if (!wasTyping) {
      _chatBloc?.add(
        StartTyping(
          conversationId: _conversationId,
          receiverId: widget.otherUser.id,
        ),
      );
    }

    // Automatically send StopTyping if the user ceases typing for 3 seconds
    _typingDebounceTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        _typingDebounceTimer = null;
        _chatBloc?.add(
          StopTyping(
            conversationId: _conversationId,
            receiverId: widget.otherUser.id,
          ),
        );
      }
    });
  }

  void _scrollToBottom({bool smooth = true}) {
    if (!mounted || !_scrollController.hasClients) return;
    if (_scrollController.offset == 0) return;
    if (smooth) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
      );
    } else {
      _scrollController.jumpTo(0);
    }
  }

  bool _isNearBottom() {
    if (!_scrollController.hasClients) return true;
    return _scrollController.offset <= 200;
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent - 100 &&
        _conversationId != null &&
        !_chatBloc!.state.isLoadingMessages &&
        _chatBloc!.state.hasMoreMessages) {
      _chatBloc!.add(LoadMoreMessages());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatBloc, ChatState>(
      bloc: _chatBloc,
      listenWhen: (prev, curr) =>
          prev.currentConversationId != curr.currentConversationId ||
          prev.isLoadingMessages != curr.isLoadingMessages ||
          prev.messages.length != curr.messages.length ||
          prev.typingUsers[widget.otherUser.id] !=
              curr.typingUsers[widget.otherUser.id],
      listener: (context, state) {
        if (state.currentConversationId != null && _conversationId == null) {
          _conversationId = state.currentConversationId;
          FCMService().activeConversationId = _conversationId;
          _joinAndLoadMessages(state.currentConversationId!);
        }
        if (state.messages.isNotEmpty && _conversationId != null) {
          final unreadMessageIds = state.messages
              .where(
                (m) =>
                    !m.isRead &&
                    m.senderId != _currentUserId &&
                    !_markedMessageIds.contains(m.id),
              )
              .map((m) => m.id)
              .toList();

          if (unreadMessageIds.isNotEmpty) {
            _markedMessageIds.addAll(unreadMessageIds);
            _chatBloc?.add(
              MarkAsRead(
                conversationId: _conversationId!,
                messageIds: unreadMessageIds,
                readerId: widget.otherUser.id,
              ),
            );
          }
        }
        if (!_isInitialized &&
            !state.isLoadingMessages &&
            state.messages.isNotEmpty) {
          _isInitialized = true;
          _scrollToBottom(smooth: false);
        } else if (state.messages.isNotEmpty && _isNearBottom()) {
          final justTyping = state.typingUsers[widget.otherUser.id] ?? false;
          if (justTyping ||
              state.messages.length > (_previousMessageCount ?? 0)) {
            _scrollToBottom(smooth: true);
          }
        }
        _previousMessageCount = state.messages.length;
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(),
        body: Column(
          children: [
            Expanded(child: _buildMessageList()),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return CommonAppBar(
      backgroundColor: AppColors.white,
      centerTitle: false,
      titleWidget: Row(
        children: [
          UserAvatarWidget(
            size: 36.r,
            name: widget.otherUser.fullName,
            imageUrl: widget.otherUser.profilePhotoUrl,
          ),
          sw(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: CustomText(
                        widget.otherUser.fullName,
                        style: AppTypography.cardTitle.copyWith(
                          color: AppColors.darkGrey,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (widget.otherUser.isVerified) ...[
                      sw(4),
                      CustomImageView(
                        imagePath: AppAssets.icVerified,
                        height: 14.r,
                        width: 14.r,
                        color: AppColors.primaryBlue,
                      ),
                    ],
                  ],
                ),
                sh(2),
                CustomText(
                  widget.otherUser.locality.isNotEmpty
                      ? widget.otherUser.locality
                      : AppStrings.chatOnline,
                  style: AppTypography.bodyText.copyWith(
                    color: AppColors.grey,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.call, color: AppColors.primaryBlue, size: 22.r),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: AppColors.darkGrey, size: 22.r),
            onPressed: _showChatOptions,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        final showTyping = state.typingUsers[widget.otherUser.id] ?? false;

        if (state.isLoadingMessages && state.messages.isEmpty) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            switchInCurve: Curves.easeIn,
            switchOutCurve: Curves.easeOut,
            child: _buildLoadingMessages(),
          );
        }

        if (state.messages.isEmpty) {
          if (showTyping) {
            return ListView(
              controller: _scrollController,
              reverse: true,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              children: [_buildTypingIndicatorBubble()],
            );
          }
          return _buildEmptyMessages();
        }

        final items = _buildMessageItems(state.messages).reversed.toList();

        return ListView.builder(
          controller: _scrollController,
          reverse: true,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          itemCount:
              items.length +
              (state.isLoadingMessages ? 1 : 0) +
              (showTyping ? 1 : 0),
          itemBuilder: (context, index) {
            // Case 1: Typing indicator is active and index is 0 (bottom-most in reverse list)
            if (showTyping && index == 0) {
              return _buildTypingIndicatorBubble();
            }

            // Adjust message index if typing indicator is shown (since index 0 is consumed by it)
            final msgIndex = showTyping ? index - 1 : index;
            final itemCount = items.length;

            // Case 2: Render message items
            if (msgIndex < itemCount) {
              final item = items[msgIndex];
              if (item is _DateDividerItem) {
                return _buildDateDivider(item.date);
              }
              final msgItem = item as _MessageItem;
              return Builder(
                builder: (bubbleContext) {
                  return _buildMessageBubble(
                    bubbleContext,
                    msgItem.message,
                    msgItem.isMine,
                    msgItem.showAvatar,
                  );
                },
              );
            }

            // Case 3: Render loading indicator (at the top-most position in reverse list)
            if (state.isLoadingMessages) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(8.r),
                  child: const CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        );
      },
    );
  }

  List<dynamic> _buildMessageItems(List<MessageModel> messages) {
    final items = <dynamic>[];
    DateTime? lastDate;

    for (int i = 0; i < messages.length; i++) {
      final message = messages[i];
      final messageDate = DateTime(
        message.createdAt.year,
        message.createdAt.month,
        message.createdAt.day,
      );

      if (lastDate == null || messageDate != lastDate) {
        items.add(_DateDividerItem(messageDate));
        lastDate = messageDate;
      }

      final isMine = message.senderId == _currentUserId;
      final prevSameDay =
          i > 0 &&
          DateTime(
                messages[i - 1].createdAt.year,
                messages[i - 1].createdAt.month,
                messages[i - 1].createdAt.day,
              ) ==
              messageDate;
      final showAvatar =
          i == 0 ||
          messages[i - 1].senderId != message.senderId ||
          !prevSameDay;

      items.add(
        _MessageItem(message: message, isMine: isMine, showAvatar: showAvatar),
      );
    }

    return items;
  }

  Widget _buildDateDivider(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    String label;
    if (messageDate == today) {
      label = 'Today';
    } else if (messageDate == yesterday) {
      label = 'Yesterday';
    } else if (now.difference(date).inDays < 7) {
      label = DateFormat('EEEE').format(date);
    } else {
      label = DateFormat('MMMM d, yyyy').format(date);
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(8.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: CustomText(
            label,
            style: AppTypography.bodyText.copyWith(
              color: AppColors.grey,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(
    BuildContext bubbleContext,
    MessageModel message,
    bool isMine,
    bool showAvatar, {
    bool isHighlighted = false,
  }) {
    final isRead = message.isRead;
    final time = DateFormat('h:mm a').format(message.createdAt);
    final showDeletedText = message.isDeleted;

    return Padding(
      padding: EdgeInsets.only(
        left: isMine ? 48.w : 0,
        right: isMine ? 0 : 48.w,
        top: showAvatar ? 8.h : 2.h,
      ),
      child: Align(
        alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
        child: _buildSwipeToReplyWrapper(
          message: message,
          isMine: isMine,
          isHighlighted: isHighlighted,
          child: GestureDetector(
            onLongPress: (showDeletedText || isHighlighted)
                ? null
                : () => _showCopyDeleteOptions(
                    bubbleContext,
                    message,
                    showAvatar,
                  ),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: showDeletedText
                    ? (isMine
                          ? AppColors.primaryBlue.withValues(alpha: 0.8)
                          : AppColors.background)
                    : (isMine ? AppColors.primaryBlue : AppColors.white),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                  bottomLeft: Radius.circular(isMine ? 16.r : 4.r),
                  bottomRight: Radius.circular(isMine ? 4.r : 16.r),
                ),
                boxShadow: [
                  if (isHighlighted)
                    BoxShadow(
                      color: (isMine ? AppColors.primaryBlue : AppColors.white)
                          .withValues(alpha: 0.4),
                      blurRadius: 16.r,
                      spreadRadius: 2.r,
                    )
                  else
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: IntrinsicWidth(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (message.replyTo != null)
                      _buildQuotedReply(message, isMine),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (showDeletedText) ...[
                          Icon(
                            Icons.block,
                            size: 14.r,
                            color: isMine
                                ? AppColors.white.withValues(alpha: 0.7)
                                : AppColors.grey,
                          ),
                          sw(4),
                        ],
                        Flexible(
                          child: CustomText(
                            showDeletedText
                                ? AppStrings.chatMessageWasDeleted
                                : message.content,
                            style: AppTypography.bodyText.copyWith(
                              color: showDeletedText
                                  ? (isMine
                                        ? AppColors.white.withValues(alpha: 0.7)
                                        : AppColors.grey)
                                  : (isMine
                                        ? AppColors.white
                                        : AppColors.darkGrey),
                              fontSize: 15.sp,
                              fontStyle: showDeletedText
                                  ? FontStyle.italic
                                  : FontStyle.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                    sh(4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomText(
                            time,
                            style: TextStyle(
                              color: isMine
                                  ? AppColors.white.withValues(alpha: 0.7)
                                  : AppColors.grey,
                              fontSize: 11.sp,
                            ),
                          ),
                          if (message.isEdited && !showDeletedText) ...[
                            sw(4),
                            CustomText(
                              AppStrings.chatEdited,
                              style: TextStyle(
                                color: isMine
                                    ? AppColors.white.withValues(alpha: 0.6)
                                    : AppColors.grey,
                                fontSize: 10.sp,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                          if (isMine && !showDeletedText) ...[
                            sw(4),
                            Icon(
                              isRead ? Icons.done_all : Icons.done,
                              size: 16.r,
                              color: isRead
                                  ? Colors.lightBlueAccent
                                  : AppColors.white.withValues(alpha: 0.7),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuotedReply(MessageModel message, bool isMine) {
    final replyTo = message.replyTo!;
    final replySenderName = replyTo.sender?.fullName ?? AppStrings.chatUnknown;
    final isReplyMine = replyTo.senderId == _currentUserId;

    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
        decoration: BoxDecoration(
          color:
              (isMine ? AppColors.white : AppColors.primaryBlue).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8.r),
          border: Border(
            left: BorderSide(
              color: isMine
                  ? AppColors.white.withValues(alpha: 0.5)
                  : AppColors.primaryBlue,
              width: 3,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              isReplyMine ? AppStrings.chatYou : replySenderName,
              style: AppTypography.bodyText.copyWith(
                color: isMine
                    ? AppColors.white.withValues(alpha: 0.9)
                    : AppColors.primaryBlue,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            sh(2),
            CustomText(
              replyTo.content.isNotEmpty
                  ? replyTo.content
                  : AppStrings.chatAttachment,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodyText.copyWith(
                color: isMine
                    ? AppColors.white.withValues(alpha: 0.7)
                    : AppColors.grey,
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _setReplyTo(MessageModel message) {
    _chatBloc?.add(SetReplyTo(message));
    _messageFocusNode.requestFocus();
  }

  Widget _buildSwipeToReplyWrapper({
    required Widget child,
    required MessageModel message,
    required bool isMine,
    required bool isHighlighted,
  }) {
    if (message.isDeleted || isHighlighted) return child;

    return _SwipeToReplyWrapper(
      isMine: isMine,
      onReply: () => _setReplyTo(message),
      child: child,
    );
  }

  Widget _buildLoadingMessages() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      itemCount: 10,
      itemBuilder: (context, index) {
        final isMine = index % 2 == 0;
        return Padding(
          padding: EdgeInsets.only(
            left: isMine ? 48.w : 0,
            right: isMine ? 0 : 48.w,
            top: 8.h,
          ),
          child: Align(
            alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: 40.h,
                width: 150.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyMessages() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          UserAvatarWidget(
            size: 64.r,
            name: widget.otherUser.fullName,
            imageUrl: widget.otherUser.profilePhotoUrl,
          ),
          sh(16),
          CustomText(
            AppStrings.chatStartConversation,
            style: AppTypography.cardTitle.copyWith(
              color: AppColors.darkGrey,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          sh(8),
          CustomText(
            '${AppStrings.chatSendAMessageTo} ${widget.otherUser.fullName}',
            style: AppTypography.bodyText.copyWith(
              color: AppColors.grey,
              fontSize: 14.sp,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        final replyTo = state.replyToMessage;
        final editingMessage = state.editingMessage;
        final isBlocked = state.isCurrentConversationBlocked;
        final isBlockedByOther = state.isBlockedByOther;

        if (isBlocked) {
          return _buildBlockBanner();
        }

        if (isBlockedByOther) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.block, color: AppColors.red, size: 18.r),
                  sw(8),
                  CustomText(
                    AppStrings.chatBlockedByOther,
                    style: AppTypography.bodyText.copyWith(
                      color: AppColors.red,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (editingMessage != null) _buildEditPreviewBar(editingMessage),
              if (replyTo != null && editingMessage == null)
                _buildReplyPreviewBar(replyTo),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                child: SafeArea(
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.add_circle_outline,
                          color: AppColors.primaryBlue,
                          size: 28.r,
                        ),
                        onPressed: _showAttachmentOptions,
                      ),
                      sw(8),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(24.r),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: TextField(
                            controller: _messageController,
                            focusNode: _messageFocusNode,
                            maxLines: 4,
                            minLines: 1,
                            decoration: InputDecoration(
                              hintText: 'Message...',
                              hintStyle: TextStyle(
                                color: AppColors.grey,
                                fontSize: 15.sp,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 10.h,
                              ),
                            ),
                            textCapitalization: TextCapitalization.sentences,
                          ),
                        ),
                      ),
                      sw(8),
                      ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _messageController,
                        builder: (context, value, child) {
                          final hasText = value.text.trim().isNotEmpty;
                          return hasText
                                ? IconButton(
                                    icon: Container(
                                      padding: EdgeInsets.all(8.r),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryBlue,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.send,
                                        color: AppColors.white,
                                        size: 18.r,
                                      ),
                                    ),
                                    onPressed: _sendMessage,
                                  )
                                : IconButton(
                                    icon: Icon(
                                      Icons.mic,
                                      color: AppColors.primaryBlue,
                                      size: 28.r,
                                    ),
                                    onPressed: () {},
                                  );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBlockBanner() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Icon(Icons.block, color: AppColors.red, size: 18.r),
            sw(8),
            Expanded(
              child: CustomText(
                AppStrings.chatYouBlocked,
                style: AppTypography.bodyText.copyWith(
                  color: AppColors.red,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                _showUnblockDialog(widget.otherUser.id);
              },
              child: CustomText(
                AppStrings.chatUnblockUser,
                style: AppTypography.bodyText.copyWith(
                  color: AppColors.primaryBlue,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUnblockDialog(String targetUserId) {
    showDialog(
      context: context,
      builder: (context) => DialogWidget(
        topWidget: Icon(
          Icons.lock_open_rounded,
          size: 50.r,
          color: AppColors.primaryBlue,
        ),
        title: AppStrings.chatUnblockConfirmation,
        subTitle: AppStrings.chatUnblockConfirmationSubtitle,
        positiveLabel: AppStrings.chatUnblockUser,
        positiveTap: () {
          Navigator.pop(context);
          _chatBloc?.add(UnblockUser(targetUserId));
        },
        showNegativeButton: true,
        negativeLabel: AppStrings.cancel,
      ),
    );
  }

  void _showBlockDialog() {
    showDialog(
      context: context,
      builder: (context) => DialogWidget(
        topWidget: Icon(Icons.block, size: 50.r, color: AppColors.red),
        title: AppStrings.chatBlockConfirmation,
        subTitle: AppStrings.chatBlockConfirmationSubtitle,
        positiveLabel: AppStrings.chatBlockUser,
        positiveTap: () {
          Navigator.pop(context);
          _chatBloc?.add(BlockUser(widget.otherUser.id));
        },
        positiveBackgroundColor: AppColors.red,
        positiveTextColor: AppColors.white,
        showNegativeButton: true,
        negativeLabel: AppStrings.cancel,
      ),
    );
  }

  Widget _buildReplyPreviewBar(MessageModel replyTo) {
    final isReplyMine = replyTo.senderId == _currentUserId;
    final senderName = isReplyMine
        ? AppStrings.chatYou
        : (replyTo.sender?.fullName ?? widget.otherUser.fullName);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          left: BorderSide(color: AppColors.primaryBlue, width: 3),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomText(
                  senderName,
                  style: AppTypography.bodyText.copyWith(
                    color: AppColors.primaryBlue,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                sh(2),
                CustomText(
                  replyTo.content.isNotEmpty
                      ? replyTo.content
                      : AppStrings.chatAttachment,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyText.copyWith(
                    color: AppColors.grey,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
          sw(8),
          IconButton(
            icon: Icon(Icons.close, color: AppColors.grey, size: 20.r),
            onPressed: () {
              _chatBloc?.add(ClearReplyTo());
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildEditPreviewBar(MessageModel editingMessage) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          left: BorderSide(color: AppColors.primaryBlue, width: 3),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.edit_outlined, color: AppColors.primaryBlue, size: 18.r),
          sw(8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomText(
                  AppStrings.chatEditingMessage,
                  style: AppTypography.bodyText.copyWith(
                    color: AppColors.primaryBlue,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                sh(2),
                CustomText(
                  editingMessage.content,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyText.copyWith(
                    color: AppColors.grey,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
          sw(8),
          IconButton(
            icon: Icon(Icons.close, color: AppColors.grey, size: 20.r),
            onPressed: () {
              _chatBloc?.add(ClearEditingMessage());
              _messageController.clear();
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty || _conversationId == null) return;

    final editingMessage = _chatBloc?.state.editingMessage;

    if (editingMessage != null) {
      _chatBloc?.add(
        EditMessage(messageId: editingMessage.id, content: content),
      );
    } else {
      final replyToId = _chatBloc?.state.replyToMessage?.id;

      _chatBloc?.add(
        SendMessage(
          receiverId: widget.otherUser.id,
          content: content,
          conversationId: _conversationId,
          replyToMessageId: replyToId,
        ),
      );
    }

    _typingDebounceTimer?.cancel();
    _typingDebounceTimer = null;
    _messageController.clear();
    _chatBloc?.add(
      StopTyping(
        conversationId: _conversationId,
        receiverId: widget.otherUser.id,
      ),
    );

    // Let the BlocListener handle scrolling when the sent message is received back from socket.
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 4.h,
                width: 40.w,
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              sh(16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildAttachmentOption(
                    icon: Icons.camera_alt,
                    label: AppStrings.chatCamera,
                    color: AppColors.primaryBlue,
                    onTap: () => Navigator.pop(context),
                  ),
                  _buildAttachmentOption(
                    icon: Icons.photo_library,
                    label: AppStrings.chatGallery,
                    color: AppColors.green,
                    onTap: () => Navigator.pop(context),
                  ),
                  _buildAttachmentOption(
                    icon: Icons.location_on,
                    label: AppStrings.chatLocation,
                    color: AppColors.red,
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
              sh(16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24.r),
          ),
          sh(8),
          CustomText(
            label,
            style: AppTypography.bodyText.copyWith(
              color: AppColors.darkGrey,
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }

  void _showChatOptions() {
    final chatBloc = context.read<ChatBloc>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: chatBloc,
        child: BlocBuilder<ChatBloc, ChatState>(
          builder: (context, state) {
            final isBlocked = state.isCurrentConversationBlocked;

            final currentConv = state.conversations.where(
              (c) => c.id == _conversationId,
            ).firstOrNull;
            final isMuted = currentConv?.isMuted ?? false;

            return Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.r),
                  topRight: Radius.circular(20.r),
                ),
              ),
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 4.h,
                      width: 40.w,
                      decoration: BoxDecoration(
                        color: AppColors.borderLight,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                    sh(16),
                    ListTile(
                      leading: Icon(
                        isMuted ? Icons.notifications : Icons.notifications_off,
                        color: isMuted ? AppColors.primaryBlue : AppColors.grey,
                      ),
                      title: CustomText(
                        isMuted ? AppStrings.chatUnmuteNotifications : AppStrings.chatMuteNotifications,
                        style: AppTypography.cardTitle.copyWith(
                          color: isMuted ? AppColors.primaryBlue : AppColors.darkGrey,
                          fontSize: 16.sp,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        if (_conversationId != null) {
                          _chatBloc?.add(MuteConversation(_conversationId!));
                        }
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        isBlocked ? Icons.lock_open : Icons.block,
                        color: isBlocked
                            ? AppColors.primaryBlue
                            : AppColors.red,
                      ),
                      title: CustomText(
                        isBlocked
                            ? AppStrings.chatUnblockUser
                            : AppStrings.chatBlockUser,
                        style: AppTypography.cardTitle.copyWith(
                          color: isBlocked
                              ? AppColors.primaryBlue
                              : AppColors.red,
                          fontSize: 16.sp,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        if (isBlocked) {
                          _showUnblockDialog(widget.otherUser.id);
                        } else {
                          _showBlockDialog();
                        }
                      },
                    ),
                    if (!isBlocked)
                      ListTile(
                        leading: const Icon(
                          Icons.flag_outlined,
                          color: AppColors.red,
                        ),
                        title: CustomText(
                          AppStrings.report,
                          style: AppTypography.cardTitle.copyWith(
                            color: AppColors.red,
                            fontSize: 16.sp,
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          ReportDialog.show(
                            context,
                            targetType: ReportTargetType.user,
                            targetId: widget.otherUser.id,
                            onReportAndDelete: () {
                              _showBlockDialog();
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

  Widget _buildTypingIndicatorBubble() {
    return Padding(
      padding: EdgeInsets.only(left: 0, right: 48.w, top: 8.h, bottom: 8.h),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            UserAvatarWidget(
              size: 28.r,
              name: widget.otherUser.fullName,
              imageUrl: widget.otherUser.profilePhotoUrl,
            ),
            sw(8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                  bottomLeft: Radius.circular(4.r),
                  bottomRight: Radius.circular(16.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: WaveDotsLoader(color: AppColors.grey, size: 6.0.r),
            ),
          ],
        ),
      ),
    );
  }

  void _showCopyDeleteOptions(
    BuildContext bubbleContext,
    MessageModel message,
    bool showAvatar,
  ) {
    if (message.isDeleted == true) return;

    final renderBox = bubbleContext.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final size = renderBox.size;
    final position = renderBox.localToGlobal(Offset.zero);
    final isMine = message.senderId == _currentUserId;
    final screenWidth = MediaQuery.of(context).size.width;

    final double? menuLeft = isMine ? null : position.dx;
    final double? menuRight = isMine
        ? (screenWidth - (position.dx + size.width))
        : null;

    LongPressOverlayMenu.show(
      context: context,
      position: position,
      size: size,
      menuWidth: 150,
      menuBorderRadius: 16,
      menuSpacing: 4,
      menuLeft: menuLeft,
      menuRight: menuRight,
      child: _buildMessageBubble(
        context,
        message,
        isMine,
        showAvatar,
        isHighlighted: true,
      ),
      menuItems: [
        OverlayMenuItem(
          icon: Icons.copy,
          label: AppStrings.chatCopy,
          color: AppColors.darkGrey,
          onTap: () {
            Clipboard.setData(ClipboardData(text: message.content));
            AppSnackBar.showMessage(
              context,
              AppStrings.chatMessageCopied,
              backgroundColor: AppColors.white,
              borderColor: AppColors.primaryBlue,
            );
          },
        ),
        if (isMine)
          OverlayMenuItem(
            icon: Icons.edit_outlined,
            label: AppStrings.chatEdit,
            color: AppColors.darkGrey,
            onTap: () => _startEditingMessage(message),
          ),
        OverlayMenuItem(
          icon: Icons.delete_outline_rounded,
          label: AppStrings.delete,
          color: AppColors.red,
          onTap: () => _showDeleteDialog(message),
        ),
      ],
    );
  }

  void _startEditingMessage(MessageModel message) {
    _chatBloc?.add(SetEditingMessage(message));
    _messageController.text = message.content;
    _messageController.selection = TextSelection.fromPosition(
      TextPosition(offset: message.content.length),
    );
    _messageFocusNode.requestFocus();
  }

  void _showDeleteDialog(MessageModel message) {
    final isMine = message.senderId == _currentUserId;
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, anim1, anim2) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.symmetric(horizontal: 40.w),
            child: DialogWidget(
              title: AppStrings.chatDeleteMessage,
              subTitle: isMine
                  ? AppStrings.chatDeleteForEveryoneSubtitle
                  : AppStrings.chatDeleteForMeSubtitle,
              topWidget: Container(
                width: 56.r,
                height: 56.r,
                decoration: BoxDecoration(
                  color: AppColors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.red,
                  size: 28.r,
                ),
              ),

              positiveLabel: isMine
                  ? AppStrings.chatDeleteForEveryone
                  : AppStrings.chatDeleteForMe,
              positiveBackgroundColor: isMine
                  ? AppColors.red
                  : AppColors.background,
              positiveTextColor: isMine ? AppColors.white : AppColors.darkGrey,
              positiveTap: () {
                Navigator.pop(context);
                _chatBloc?.add(
                  DeleteMessage(
                    messageId: message.id,
                    conversationId: _conversationId ?? '',
                    deleteType: isMine ? 'everyone' : 'me',
                  ),
                );
              },
              neutralLabel: isMine ? AppStrings.chatDeleteForMe : null,
              neutralTap: isMine
                  ? () {
                      Navigator.pop(context);
                      _chatBloc?.add(
                        DeleteMessage(
                          messageId: message.id,
                          conversationId: _conversationId ?? '',
                          deleteType: 'me',
                        ),
                      );
                    }
                  : null,
              negativeLabel: AppStrings.cancel,
              negativeTap: () => Navigator.pop(context),
              showNegativeButton: true,
              showTopImage: false,
              isRowButtons: false,
            ),
          ),
        );
      },
    );
  }
}

class _DateDividerItem {
  final DateTime date;
  _DateDividerItem(this.date);
}

class _MessageItem {
  final MessageModel message;
  final bool isMine;
  final bool showAvatar;
  _MessageItem({
    required this.message,
    required this.isMine,
    required this.showAvatar,
  });
}

class _SwipeToReplyWrapper extends StatefulWidget {
  final Widget child;
  final bool isMine;
  final VoidCallback onReply;

  const _SwipeToReplyWrapper({
    required this.child,
    required this.isMine,
    required this.onReply,
  });

  @override
  State<_SwipeToReplyWrapper> createState() => _SwipeToReplyWrapperState();
}

class _SwipeToReplyWrapperState extends State<_SwipeToReplyWrapper>
    with SingleTickerProviderStateMixin {
  double _dragOffset = 0;
  late AnimationController _animController;
  late Animation<double> _anim;

  static const double _replyThreshold = 80;
  static const double _maxDrag = 120;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _anim = _animController; // ponytail: unused until _onDragEnd, starts at 0
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onDragStart(DragStartDetails details) {
    _animController.stop();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    final delta = details.primaryDelta ?? 0;
    double newOffset = _dragOffset + delta;

    if (widget.isMine) {
      newOffset = newOffset.clamp(-_maxDrag, 0);
    } else {
      newOffset = newOffset.clamp(0, _maxDrag);
    }

    setState(() {
      _dragOffset = newOffset;
    });
  }

  void _onDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;

    final triggered = widget.isMine
        ? (_dragOffset < -_replyThreshold || velocity < -300)
        : (_dragOffset > _replyThreshold || velocity > 300);

    if (triggered) widget.onReply();

    // Animate back to 0
    _anim = Tween<double>(begin: _dragOffset, end: 0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: triggered ? Curves.elasticOut : Curves.easeOut,
      ),
    );
    _animController.forward(from: 0).then((_) {
      if (mounted) setState(() => _dragOffset = 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final showReplyIcon =
        (widget.isMine && _dragOffset < -20) ||
        (!widget.isMine && _dragOffset > 20);
    final replyProgress =
        (_dragOffset.abs() / _replyThreshold).clamp(0.0, 1.0);

    return GestureDetector(
      onHorizontalDragStart: _onDragStart,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      child: AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          final currentOffset = _animController.isAnimating
              ? _anim.value
              : _dragOffset;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: widget.isMine ? null : -40,
                right: widget.isMine ? -40 : null,
                top: 0,
                bottom: 0,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 100),
                  opacity: showReplyIcon ? replyProgress : 0,
                  child: Center(
                    child: Container(
                      width: 32.r,
                      height: 32.r,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.reply,
                        color: AppColors.primaryBlue,
                        size: 18.r,
                      ),
                    ),
                  ),
                ),
              ),
              Transform.translate(
                offset: Offset(currentOffset, 0),
                child: child,
              ),
            ],
          );
        },
        child: widget.child,
      ),
    );
  }
}
