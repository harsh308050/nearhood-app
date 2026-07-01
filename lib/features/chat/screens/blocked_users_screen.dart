import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearhood/core/utils/custom_import.dart';
import 'package:nearhood/features/chat/bloc/chat_bloc.dart';
import 'package:nearhood/features/chat/bloc/chat_event.dart';
import 'package:nearhood/features/chat/bloc/chat_state.dart';
import 'package:nearhood/features/chat/models/conversation_model.dart';
import 'package:nearhood/features/chat/screens/chat_detail_screen.dart';
import 'package:nearhood/common_widget/user_avatar_widget.dart';

class BlockedUsersScreen extends StatefulWidget {
  const BlockedUsersScreen({super.key});

  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(LoadBlockedUsers());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CommonAppBar(
        backgroundColor: AppColors.white,
        title: AppStrings.chatBlockedUsers,
        centerTitle: true,
      ),
      body: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          final blockedUsers = state.blockedUsers;

          if (blockedUsers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.block,
                    size: 48.r,
                    color: AppColors.grey.withValues(alpha: 0.4),
                  ),
                  sh(16),
                  CustomText(
                    AppStrings.chatNoBlockedUsers,
                    style: AppTypography.cardTitle.copyWith(
                      color: AppColors.darkGrey,
                      fontSize: 16.sp,
                    ),
                  ),
                  sh(8),
                  CustomText(
                    AppStrings.chatNoBlockedUsersDesc,
                    style: AppTypography.bodyText.copyWith(
                      color: AppColors.grey,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            itemCount: blockedUsers.length,
            itemBuilder: (context, index) {
              return _buildBlockedUserTile(blockedUsers[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildBlockedUserTile(ConversationModel conversation) {
    final otherUser = conversation.otherUser;
    if (otherUser == null) return const SizedBox.shrink();

    return InkWell(
      onTap: () => _openChat(conversation),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            UserAvatarWidget(
              size: 48.r,
              name: otherUser.fullName,
              imageUrl: otherUser.profilePhotoUrl,
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
                          otherUser.fullName,
                          style: AppTypography.cardTitle.copyWith(
                            color: AppColors.darkGrey,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (otherUser.isVerified) ...[
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
                    otherUser.locality.isNotEmpty
                        ? otherUser.locality
                        : AppStrings.chatNearbyNeighbor,
                    style: AppTypography.bodyText.copyWith(
                      color: AppColors.grey,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () => _showUnblockDialog(conversation),
              borderRadius: BorderRadius.circular(20.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: AppColors.primaryBlue.withValues(alpha: 0.3),
                  ),
                ),
                child: CustomText(
                  AppStrings.chatUnblockUser,
                  style: AppTypography.bodyText.copyWith(
                    color: AppColors.primaryBlue,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUnblockDialog(ConversationModel conversation) {
    final otherUser = conversation.otherUser;
    if (otherUser == null) return;

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
        backgroundColor: Colors.transparent,
        child: DialogWidget(
          title: AppStrings.chatUnblockConfirmation,
          subTitle: AppStrings.chatUnblockConfirmationSubtitle,
          positiveLabel: AppStrings.chatUnblockUser,
          negativeLabel: AppStrings.cancel,
          showTopImage: false,
          isRowButtons: true,
          positiveTap: () {
            Navigator.pop(dialogContext);
            context.read<ChatBloc>().add(UnblockUser(otherUser.id));
            context.read<ChatBloc>().add(LoadBlockedUsers());
          },
        ),
      ),
    );
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
        chatBloc.add(LoadBlockedUsers());
      }
    });
  }
}
