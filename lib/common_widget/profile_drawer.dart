import 'package:firebase_auth/firebase_auth.dart';
import 'package:nearhood/core/utils/custom_import.dart';
import 'package:nearhood/core/utils/shared_pref_helper.dart';
import 'package:nearhood/common_widget/user_avatar_widget.dart';
import 'package:nearhood/features/getstarted/getstarted_screen.dart';
import 'package:nearhood/features/profile/profile_screen.dart';
import 'package:nearhood/features/chat/services/socket_service.dart';

class ProfileDrawer extends StatelessWidget {
  const ProfileDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final user = sharedPrefGetUser();
    final userName = user?.fullName ?? 'Neighbor';
    final userEmail = user?.email ?? '';
    final locality = user?.location?.locality?.name ?? 'My Area';
    return Drawer(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      backgroundColor: AppColors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Profile Header Section - Horizontal Layout
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24.r),
              child: Row(
                children: [
                  // Avatar
                  UserAvatarWidget(
                    size: 60.r,
                    imageUrl: user?.profilePhotoUrl,
                    name: userName,
                    isAreaLead: user?.role == 'area_lead',
                  ),
                  sw(16),
                  // User Info Column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // User Name with verified badge
                        Row(
                          children: [
                            Flexible(
                              child: CustomText(
                                userName,
                                style: AppTypography.cardTitle.copyWith(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.darkGrey,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (user?.isVerified == true) ...[
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
                        // Email
                        if (userEmail.isNotEmpty)
                          CustomText(
                            userEmail,
                            style: AppTypography.caption.copyWith(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.grey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Divider below profile
            Divider(height: 1.h, thickness: 1.h, color: AppColors.borderLight),

            sh(8),

            // Menu Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildMenuItem(
                    context,
                    icon: AppAssets.icProfile,
                    label: 'My Profile',
                    onTap: () {
                      Navigator.pop(context);
                      callNextScreen(context, const ProfileScreen());
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: AppAssets.icNews,
                    label: 'Local News',
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Navigate to local news screen
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: AppAssets.icCalender,
                    label: 'Events',
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Navigate to events screen
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: AppAssets.icMarket,
                    label: 'Add Business',
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Navigate to add business screen
                    },
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    context,
                    icon: AppAssets.icSetting,
                    label: 'Settings',
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Navigate to settings screen
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: AppAssets.icHelp,
                    label: 'Help & Support',
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Navigate to help screen
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: AppAssets.icInfo,
                    label: 'About Nearhood',
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Navigate to about screen
                    },
                  ),
                ],
              ),
            ),

            // Logout Button at Bottom
            Padding(
              padding: EdgeInsets.all(20.r),
              child: CustomButton.outlined(
                text: 'Logout',
                onPressed: () {
                  _showLogoutDialog(context);
                },
                leading: CustomImageView(
                  imagePath: AppAssets.icSignout,
                  height: 20.r,
                  width: 20.r,
                  color: AppColors.red,
                ),
                textStyle: AppTypography.buttonLabel.copyWith(
                  color: AppColors.red,
                  fontWeight: FontWeight.bold,
                ),
                borderColor: AppColors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: CustomImageView(
        imagePath: icon,
        height: 22.r,
        width: 22.r,
        color: AppColors.darkGrey,
      ),
      title: CustomText(
        label,
        style: AppTypography.bodyText.copyWith(
          fontSize: 15.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.darkGrey,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: AppColors.grey, size: 20.r),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Divider(height: 1.h, color: AppColors.borderLight),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
        backgroundColor: Colors.transparent,
        child: DialogWidget(
          title: 'Logout',
          subTitle: 'Are you sure you want to logout from your account?',
          positiveLabel: 'Logout',
          negativeLabel: 'Cancel',
          showTopImage: false,
          isRowButtons: true,
          positiveBackgroundColor: AppColors.red,
          positiveTap: () async {
            Navigator.pop(dialogContext); // Close dialog
            await _performLogout(context);
          },
        ),
      ),
    );
  }

  Future<void> _performLogout(BuildContext context) async {
    final navigator = Navigator.of(context);
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: WaveDotsLoader(color: AppColors.primaryBlue, size: 10.0),
        ),
      );

      // Reset socket to clear session info and avoid lingering listeners
      SocketService().reset();

      // Clear shared preferences
      await sharedPrefClearAllData();

      // Sign out from Firebase
      await FirebaseAuth.instance.signOut();

      // Close loading dialog
      navigator.pop();

      // Navigate to GetStarted screen and clear stack
      navigator.pushAndRemoveUntil(
        CustomPageRoute(
          page: const GetstartedScreen(),
          transitionType: PageTransitionType.fade,
        ),
        (_) => false,
      );
    } catch (e) {
      // Close loading dialog if still open
      try {
        navigator.pop();
      } catch (_) {}

      // Show error message
      if (context.mounted) {
        AppSnackBar.showMessage(
          context,
          'Failed to logout. Please try again.',
          borderColor: AppColors.red,
          isTop: true,
        );
      }
    }
  }
}
