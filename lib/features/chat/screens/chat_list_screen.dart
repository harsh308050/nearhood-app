import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:nearhood/core/utils/custom_import.dart';
import 'package:nearhood/features/chat/bloc/chat_bloc.dart';
import 'package:nearhood/features/chat/bloc/chat_event.dart';
import 'package:nearhood/features/chat/bloc/chat_state.dart';
import 'package:nearhood/features/chat/models/conversation_model.dart';
import 'package:nearhood/features/chat/screens/chat_detail_screen.dart';
import 'package:nearhood/features/chat/screens/user_search_screen.dart';
import 'package:nearhood/features/chat/screens/blocked_users_screen.dart';
import 'package:nearhood/common_widget/user_avatar_widget.dart';
import 'package:nearhood/common_widget/long_press_overlay_menu.dart';
import 'package:intl/intl.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(ConnectSocket());
    context.read<ChatBloc>().add(LoadConversations());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CommonAppBar(
        backgroundColor: AppColors.white,
        showBackButton: false,
        centerTitle: false,
        titleWidget: CustomText(
          AppStrings.messages,
          style: AppTypography.screenTitle.copyWith(
            color: AppColors.darkGrey,
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        showVerticalMenu: true,
        onVerticalMenuPressed: _showMenu,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(child: _buildConversationsList()),
        ],
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        child: FloatingActionButton(
          heroTag: 'chat_fab',
          backgroundColor: AppColors.primaryBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28.r),
          ),
          onPressed: () {
            final chatBloc = context.read<ChatBloc>();
            callNextScreenBuilderWithResult(
              context,
              (ctx) => BlocProvider.value(
                value: chatBloc,
                child: const UserSearchScreen(),
              ),
            ).then((_) {
              if (mounted) {
                chatBloc.add(LoadConversations());
              }
            });
          },
          child: CustomImageView(
            imagePath: AppAssets.icAdd,
            color: AppColors.white,
            height: 16.r,
            width: 16.r,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      color: AppColors.white,
      child: CustomTextField(
        controller: _searchController,
        hint: AppStrings.chatSearchChats,
        prefixIcon: Icons.search,
        suffixIcon: _searchController.text.isNotEmpty ? Icons.clear : null,
        onSuffixIconTap: () {
          _searchController.clear();
          setState(() {
            _searchQuery = '';
          });
        },
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        borderRadius: 12.0,
        backgroundColor: AppColors.background,
        borderColor: AppColors.borderLight,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      ),
    );
  }

  Widget _buildConversationsList() {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        final isLoading =
            state.isLoadingConversations && state.conversations.isEmpty;
        final hasError = state.error != null && state.conversations.isEmpty;

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          switchInCurve: Curves.easeIn,
          switchOutCurve: Curves.easeOut,
          transitionBuilder: (child, animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: isLoading
              ? _buildLoadingShimmer()
              : hasError
              ? _buildErrorState(state.error!)
              : _buildConversationContent(state),
        );
      },
    );
  }

  Widget _buildConversationContent(ChatState state) {
    final filteredConversations = state.conversations.where((conv) {
      if (conv.isBlocked) return false;
      final otherUser = conv.otherUser;
      if (otherUser == null) return false;
      return otherUser.fullName.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
    }).toList();

    if (filteredConversations.isEmpty) {
      return _buildEmptyConversations(_searchQuery.isNotEmpty);
    }

    return RefreshIndicator(
      key: const ValueKey('conversations'),
      onRefresh: () async {
        context.read<ChatBloc>().add(LoadConversations());
      },
      child: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        itemCount: filteredConversations.length,
        itemBuilder: (context, index) {
          final conversation = filteredConversations[index];
          return _buildConversationItem(conversation, state);
        },
      ),
    );
  }

  Widget _buildConversationItem(
    ConversationModel conversation,
    ChatState state,
  ) {
    final otherUser = conversation.otherUser;
    if (otherUser == null) return const SizedBox.shrink();

    final lastMessage = conversation.lastMessage;
    final unreadCount = conversation.unreadCount;
    final isTyping = state.typingUsers[otherUser.id] ?? false;

    return GestureDetector(
      onLongPressStart: (details) => _showConversationOverlay(
        context,
        conversation,
        state,
        details.globalPosition,
      ),
      child: InkWell(
        onTap: () => _openChat(conversation),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            children: [
              Stack(
                children: [
                  UserAvatarWidget(
                    size: 52.r,
                    name: otherUser.fullName,
                    imageUrl: otherUser.profilePhotoUrl,
                  ),
                  if (otherUser.isVerified)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: EdgeInsets.all(2.r),
                        decoration: const BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                        ),
                        child: CustomImageView(
                          imagePath: AppAssets.icVerified,
                          height: 14.r,
                          width: 14.r,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                ],
              ),
              sw(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: CustomText(
                            otherUser.fullName,
                            style: AppTypography.cardTitle.copyWith(
                              color: AppColors.darkGrey,
                              fontSize: 15.sp,
                              fontWeight: unreadCount > 0
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (lastMessage != null)
                          CustomText(
                            _formatTime(lastMessage.createdAt),
                            style: AppTypography.bodyText.copyWith(
                              color: unreadCount > 0
                                  ? AppColors.primaryBlue
                                  : AppColors.grey,
                              fontSize: 12.sp,
                              fontWeight: unreadCount > 0
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        if (conversation.isMuted) ...[
                          sw(4),
                          Icon(
                            Icons.notifications_off,
                            color: AppColors.grey,
                            size: 14.r,
                          ),
                        ],
                      ],
                    ),
                    sh(4),
                    Row(
                      children: [
                        Expanded(
                          child: isTyping
                              ? CustomText(
                                  AppStrings.chatTyping,
                                  style: AppTypography.bodyText.copyWith(
                                    color: AppColors.primaryBlue,
                                    fontSize: 13.sp,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                )
                              : conversation.isBlocked
                              ? Row(
                                  children: [
                                    Icon(
                                      Icons.block,
                                      color: AppColors.red,
                                      size: 14.r,
                                    ),
                                    sw(4),
                                    CustomText(
                                      AppStrings.chatBlocked,
                                      style: AppTypography.bodyText.copyWith(
                                        color: AppColors.red,
                                        fontSize: 13.sp,
                                      ),
                                    ),
                                  ],
                                )
                              : _buildLastMessagePreview(
                                  lastMessage,
                                  unreadCount > 0
                                      ? AppColors.darkGrey
                                      : AppColors.grey,
                                  unreadCount > 0,
                                ),
                        ),
                        if (unreadCount > 0) ...[
                          sw(8),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: CustomText(
                              unreadCount > 99 ? '99+' : unreadCount.toString(),
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLastMessagePreview(
    MessagePreview? lastMessage,
    Color color,
    bool isBold,
  ) {
    if (lastMessage == null) {
      return CustomText(
        AppStrings.chatStartConversation,
        style: AppTypography.bodyText.copyWith(
          color: color,
          fontSize: 13.sp,
          fontWeight: isBold ? FontWeight.w500 : FontWeight.normal,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    final textStyle = AppTypography.bodyText.copyWith(
      color: color,
      fontSize: 13.sp,
      fontWeight: isBold ? FontWeight.w500 : FontWeight.normal,
    );

    if (lastMessage.isImage) {
      return Row(
        children: [
          Icon(Icons.photo, color: color, size: 16.r),
          sw(4),
          Expanded(
            child: CustomText(
              'Photo',
              style: textStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    if (lastMessage.isLocation) {
      return Row(
        children: [
          Icon(Icons.location_on, color: color, size: 16.r),
          sw(4),
          Expanded(
            child: CustomText(
              'Location',
              style: textStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    return CustomText(
      lastMessage.content.isNotEmpty
          ? lastMessage.content
          : AppStrings.chatStartConversation,
      style: textStyle,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  void _showConversationOverlay(
    BuildContext context,
    ConversationModel conversation,
    ChatState state,
    Offset tapPosition,
  ) {
    final cardHeight = 76.0.h;
    final cardTop = tapPosition.dy - cardHeight / 2;
    final cardLeft = 16.0.w;
    final cardWidth = MediaQuery.of(context).size.width - 32.0.w;

    LongPressOverlayMenu.show(
      context: context,
      position: Offset(cardLeft, cardTop),
      size: Size(cardWidth, cardHeight),
      menuWidth: cardWidth,
      menuBorderRadius: 12,
      menuSpacing: 8,
      child: _buildOverlayConversationItem(conversation, state),
      menuItems: [
        OverlayMenuItem(
          icon: Icons.chat_bubble_outline,
          label: AppStrings.chatOpenChat,
          color: AppColors.primaryBlue,
          onTap: () => _openChat(conversation),
        ),
        OverlayMenuItem(
          icon: Icons.delete_outline,
          label: AppStrings.chatHideChat,
          color: AppColors.red,
          onTap: () => _deleteConversation(conversation),
        ),
      ],
    );
  }

  Widget _buildOverlayConversationItem(
    ConversationModel conversation,
    ChatState state,
  ) {
    final otherUser = conversation.otherUser;
    if (otherUser == null) return const SizedBox.shrink();

    final lastMessage = conversation.lastMessage;
    final unreadCount = conversation.unreadCount;
    final isTyping = state.typingUsers[otherUser.id] ?? false;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.3),
            blurRadius: 16.r,
            spreadRadius: 2.r,
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              UserAvatarWidget(
                size: 52.r,
                name: otherUser.fullName,
                imageUrl: otherUser.profilePhotoUrl,
              ),
              if (otherUser.isVerified)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: EdgeInsets.all(2.r),
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                    ),
                    child: CustomImageView(
                      imagePath: AppAssets.icVerified,
                      height: 14.r,
                      width: 14.r,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
            ],
          ),
          sw(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CustomText(
                        otherUser.fullName,
                        style: AppTypography.cardTitle.copyWith(
                          color: AppColors.darkGrey,
                          fontSize: 15.sp,
                          fontWeight: unreadCount > 0
                              ? FontWeight.bold
                              : FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (lastMessage != null)
                      CustomText(
                        _formatTime(lastMessage.createdAt),
                        style: AppTypography.bodyText.copyWith(
                          color: unreadCount > 0
                              ? AppColors.primaryBlue
                              : AppColors.grey,
                          fontSize: 12.sp,
                          fontWeight: unreadCount > 0
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                  ],
                ),
                sh(4),
                Row(
                  children: [
                    Expanded(
                      child: isTyping
                          ? CustomText(
                              AppStrings.chatTyping,
                              style: AppTypography.bodyText.copyWith(
                                color: AppColors.primaryBlue,
                                fontSize: 13.sp,
                                fontStyle: FontStyle.italic,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                          : _buildLastMessagePreview(
                              lastMessage,
                              unreadCount > 0
                                  ? AppColors.darkGrey
                                  : AppColors.grey,
                              unreadCount > 0,
                            ),
                    ),
                    if (unreadCount > 0) ...[
                      sw(8),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: CustomText(
                          unreadCount > 99 ? '99+' : unreadCount.toString(),
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _deleteConversation(ConversationModel conversation) {
    final chatBloc = context.read<ChatBloc>();

    chatBloc.add(HideConversation(conversation.id));

    AppSnackBar.showMessage(
      context,
      AppStrings.chatHidden,
      isTop: false,
      buttonText: AppStrings.chatUndo,
      borderColor: AppColors.grey,
      onButtonPressed: () {
        chatBloc.add(UnhideConversation(conversation.id));
      },
      duration: const Duration(seconds: 4),
    );
  }

  Widget _buildLoadingShimmer() {
    return KeyedSubtree(
      key: const ValueKey('shimmer'),
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        itemCount: 8,
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Row(
                children: [
                  Container(
                    width: 52.r,
                    height: 52.r,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  sw(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 14.h,
                          width: 120.w,
                          color: Colors.white,
                        ),
                        sh(6),
                        Container(
                          height: 12.h,
                          width: 180.w,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyConversations(bool isSearchEmpty) {
    return KeyedSubtree(
      key: const ValueKey('empty'),
      child: EmptyStateWidget(
        title: isSearchEmpty
            ? AppStrings.chatNoMessagesFound
            : AppStrings.chatNoConversationsYet,
        subtitle: isSearchEmpty
            ? AppStrings.chatSearchSomethingElse
            : AppStrings.chatStartChatting,
        illustration: !isSearchEmpty
            ? null
            : CustomImageView(
                imagePath: AppAssets.icMessage,
                color: AppColors.grey.withValues(alpha: 0.5),
                height: 64.r,
                width: 64.r,
              ),
        showButton: false,
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return KeyedSubtree(
      key: const ValueKey('error'),
      child: EmptyStateWidget(
        title: AppStrings.chatSomethingWentWrong,
        subtitle: error,
        illustration: Icon(
          Icons.error_outline,
          color: AppColors.red,
          size: 48.r,
        ),
        btnText: AppStrings.retry,
        onPressed: () {
          context.read<ChatBloc>().add(LoadConversations());
        },
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return DateFormat('h:mm a').format(dateTime);
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else if (now.difference(dateTime).inDays < 7) {
      return DateFormat('EEE').format(dateTime);
    } else {
      return DateFormat('MMM d').format(dateTime);
    }
  }

  void _openChat(ConversationModel conversation) {
    final otherUser = conversation.otherUser;
    if (otherUser == null) return;

    final chatBloc = context.read<ChatBloc>();
    chatBloc.add(JoinConversation(conversation.id));
    chatBloc.add(LoadMessages(conversation.id));
    chatBloc.add(
      MarkAsRead(
        conversationId: conversation.id,
        messageIds: [],
        readerId: otherUser.id,
      ),
    );

    callNextScreenBuilderWithResult(
      context,
      (ctx) => BlocProvider.value(
        value: chatBloc,
        child: ChatDetailScreen(
          conversationId: conversation.id,
          receiverId: otherUser.id,
          otherUser: otherUser,
        ),
      ),
    ).then((_) {
      if (mounted) {
        chatBloc.add(LoadConversations());
      }
    });
  }

  void _showMenu() {
    final RenderBox appBar = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final position = RelativeRect.fromRect(
      Rect.fromCenter(
        center: Offset(appBar.size.width - 40.w, kToolbarHeight / 2),
        width: 0,
        height: 0,
      ),
      Offset.zero & overlay.size,
    );

    showMenu<String>(
      context: context,
      position: position,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      elevation: 4,
      items: [
        PopupMenuItem<String>(
          value: 'blocked_users',
          child: Row(
            children: [
              Icon(Icons.block, color: AppColors.darkGrey, size: 20.r),
              sw(10),
              CustomText(
                AppStrings.chatBlockedUsers,
                style: AppTypography.bodyText.copyWith(
                  color: AppColors.darkGrey,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value == 'blocked_users' && mounted) {
        final chatBloc = context.read<ChatBloc>();
        callNextScreenBuilder(
          context,
          (ctx) => BlocProvider.value(
            value: chatBloc,
            child: const BlockedUsersScreen(),
          ),
        );
      }
    });
  }
}
