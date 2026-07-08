import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:nearhood/core/utils/custom_import.dart';
import 'package:nearhood/features/chat/bloc/chat_bloc.dart';
import 'package:nearhood/features/chat/bloc/chat_event.dart';
import 'package:nearhood/features/chat/bloc/chat_state.dart';
import 'package:nearhood/features/chat/models/chat_user.dart';
import 'package:nearhood/features/chat/screens/chat_detail_screen.dart';
import 'package:nearhood/common_widget/user_avatar_widget.dart';
import 'package:nearhood/core/utils/shared_pref_helper.dart';

class UserSearchScreen extends StatefulWidget {
  const UserSearchScreen({super.key});

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Preload users list when opening search screen
    context.read<ChatBloc>().add(const LoadAllUsers());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String? get _currentUserId => sharedPrefGetUser()?.id;

  @override
  Widget build(BuildContext context) {
    final chatBloc = context.read<ChatBloc>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CommonAppBar(
        backgroundColor: AppColors.white,
        title: AppStrings.chatNewMessage,
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildSearchBar(chatBloc),
          Expanded(child: _buildUsersList(chatBloc)),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ChatBloc chatBloc) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      color: AppColors.white,
      child: CustomTextField(
        controller: _searchController,
        hint: AppStrings.chatSearchNeighborsByName,
        prefixIcon: Icons.search,
        suffixIcon: _searchController.text.isNotEmpty ? Icons.clear : null,
        onSuffixIconTap: () {
          _searchController.clear();
          chatBloc.add(const SearchUsers(''));
          setState(() {});
        },
        onChanged: (value) {
          chatBloc.add(SearchUsers(value));
          setState(() {});
        },
        borderRadius: 12.0,
        backgroundColor: AppColors.background,
        borderColor: AppColors.borderLight,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      ),
    );
  }

  Widget _buildUsersList(ChatBloc chatBloc) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        if (state.isLoadingUsers && state.allUsers.isEmpty) {
          return _buildLoadingShimmer();
        }

        final existingChatUserIds = state.conversations
            .map((conv) => conv.otherUser?.id)
            .whereType<String>()
            .toSet();

        final users = state.filteredUsers
            .where(
              (user) =>
                  user.id != _currentUserId &&
                  !existingChatUserIds.contains(user.id),
            )
            .toList();

        if (users.isEmpty) {
          return _buildEmptyUsers();
        }

        return ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return _buildUserItem(user, chatBloc);
          },
        );
      },
    );
  }

  Widget _buildUserItem(ChatUser user, ChatBloc chatBloc) {
    return InkWell(
      onTap: () {
        // Clear search state before navigating away
        chatBloc.add(const SearchUsers(''));
        callNextScreenBuilder(
          context,
          (ctx) => BlocProvider.value(
            value: chatBloc,
            child: ChatDetailScreen(receiverId: user.id, otherUser: user),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            Stack(
              children: [
                UserAvatarWidget(
                  size: 52.r,
                  name: user.fullName,
                  imageUrl: user.profilePhotoUrl,
                ),
                if (user.isVerified)
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
                  CustomText(
                    user.fullName,
                    style: AppTypography.cardTitle.copyWith(
                      color: AppColors.darkGrey,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  sh(2),
                  CustomText(
                    user.locality.isNotEmpty
                        ? user.locality
                        : AppStrings.chatNearbyNeighbor,
                    style: AppTypography.bodyText.copyWith(
                      color: AppColors.grey,
                      fontSize: 13.sp,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.grey, size: 20.r),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return ListView.builder(
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
                    color: AppColors.white,
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
                        color: AppColors.white,
                      ),
                      sh(6),
                      Container(
                        height: 12.h,
                        width: 180.w,
                        color: AppColors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyUsers() {
    return EmptyStateWidget(
      title: AppStrings.chatNoNeighborsFound,
      subtitle: AppStrings.chatTryDifferentName,
      showButton: false,
    );
  }
}
