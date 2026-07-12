import 'package:nearhood/common_widget/listing_card_widget.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:nearhood/core/network/api_call_state.dart';
import 'package:nearhood/core/utils/custom_import.dart';
import 'package:nearhood/features/business/bloc/business_bloc.dart';
import 'package:nearhood/features/business/bloc/business_event.dart';
import 'package:nearhood/features/business/bloc/business_state.dart';
import 'package:nearhood/features/business/models/business_models.dart';
import 'package:nearhood/features/business/screens/add_edit_listing_screen.dart';
import 'package:nearhood/features/business/screens/create_business_screen.dart';
import 'package:nearhood/features/business/screens/business_profile_screen.dart';

class MyBusinessDashboardScreen extends StatelessWidget {
  const MyBusinessDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BusinessBloc()..add(LoadDashboard()),
      child: const _MyBusinessDashboardBody(),
    );
  }
}

class _MyBusinessDashboardBody extends StatefulWidget {
  const _MyBusinessDashboardBody();

  @override
  State<_MyBusinessDashboardBody> createState() =>
      _MyBusinessDashboardBodyState();
}

class _MyBusinessDashboardBodyState extends State<_MyBusinessDashboardBody> {
  int _selectedTab = 0;

  static const _tabs = ['Overview', 'Products', 'Services', 'Posts'];

  void _onMenuSelected(String value) {
    switch (value) {
      case 'edit_profile':
        final bloc = context.read<BusinessBloc>();
        final profile =
            bloc.state.businessProfile ?? bloc.state.dashboard?.profile;
        if (profile != null) {
          callNextScreenWithResult(
            context,
            CreateBusinessScreen(profile: profile),
          ).then((_) {
            if (mounted) {
              context.read<BusinessBloc>().add(LoadDashboard());
            }
          });
        }
        break;
      case 'view_public_profile':
        final bloc = context.read<BusinessBloc>();
        if (bloc.state.businessProfile != null) {
          callNextScreen(
            context,
            BlocProvider(
              create: (_) => BusinessBloc()..add(FetchBusinessProfile()),
              child: const BusinessProfileScreen(),
            ),
          );
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CommonAppBar(
        title: AppStrings.myBusiness,
        showBackButton: true,
        showVerticalMenu: true,
        onVerticalMenuPressed: () {
          showModalBottomSheet(
            context: context,
            backgroundColor: AppColors.transparent,
            builder: (ctx) => Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
              ),
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: AppColors.borderLight,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                    sh(16),
                    _buildMenuItem(
                      ctx,
                      icon: Icons.edit_outlined,
                      label: 'Edit Business Profile',
                      onTap: () {
                        Navigator.pop(ctx);
                        _onMenuSelected('edit_profile');
                      },
                    ),
                    _buildMenuItem(
                      ctx,
                      icon: Icons.visibility_outlined,
                      label: 'View Public Profile',
                      onTap: () {
                        Navigator.pop(ctx);
                        _onMenuSelected('view_public_profile');
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      body: BlocListener<BusinessBloc, BusinessState>(
        listenWhen: (prev, curr) =>
            prev.dashboardStatus != ApiCallState.success &&
            curr.dashboardStatus == ApiCallState.success,
        listener: (context, state) {
          context.read<BusinessBloc>().add(LoadListings('product'));
          context.read<BusinessBloc>().add(LoadListings('service'));
        },
        child: Column(
          children: [
            _buildTabSelector(),
            Expanded(
              child: BlocBuilder<BusinessBloc, BusinessState>(
                builder: (context, state) {
                  if (state.dashboardStatus == ApiCallState.busy) {
                    return _buildShimmer();
                  }
                  if (state.dashboardStatus == ApiCallState.failure) {
                    return _buildError();
                  }
                  return _buildTabContent(state);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Pill Tab Selector (matches homepage style) ─────────────────────────────

  Widget _buildTabSelector() {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Container(
        height: 40.h,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(100.r),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final barWidth = constraints.maxWidth;
            final cellWidth = barWidth / _tabs.length;
            final capsuleWidth = cellWidth - 4.r;

            return Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOutCubic,
                  left: (_selectedTab * cellWidth) + 2.r,
                  top: 2.r,
                  width: capsuleWidth,
                  height: 40.h - 4.r - 2.w,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      borderRadius: BorderRadius.circular(100.r),
                    ),
                  ),
                ),
                Row(
                  children: List.generate(_tabs.length, (i) {
                    final isSelected = _selectedTab == i;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTab = i),
                        child: Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.all(2.r),
                          child: CustomText(
                            _tabs[i],
                            style: AppTypography.cardTitle.copyWith(
                              color: isSelected
                                  ? AppColors.white
                                  : AppColors.grey,
                              fontSize: 13.sp,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ─── Tab Content ────────────────────────────────────────────────────────────

  Widget _buildTabContent(BusinessState state) {
    switch (_selectedTab) {
      case 0:
        return _OverviewTab(state: state);
      case 1:
        return _ListingsTab(
          type: 'product',
          listings: state.products,
          status: state.listingsStatus,
          bloc: context.read<BusinessBloc>(),
        );
      case 2:
        return _ListingsTab(
          type: 'service',
          listings: state.services,
          status: state.listingsStatus,
          bloc: context.read<BusinessBloc>(),
        );
      case 3:
        return _PostsTab();
      default:
        return const SizedBox.shrink();
    }
  }

  // ─── Shimmer / Error ────────────────────────────────────────────────────────

  Widget _buildShimmer() {
    final grey = BoxDecoration(
      color: AppColors.grey.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(4.r),
    );
    final greyCard = BoxDecoration(
      color: AppColors.grey.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(8.r),
    );
    final greyChip = BoxDecoration(
      color: AppColors.grey.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(10.r),
    );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          shimmer(
            child: Container(
              height: 140.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.grey.withValues(alpha: 0.3),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 40.r, 16.w, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                shimmer(
                  child: Container(
                    height: 18.h,
                    width: 200.w,
                    decoration: grey,
                  ),
                ),
                sh(6),
                shimmer(
                  child: Container(
                    height: 14.h,
                    width: 120.w,
                    decoration: grey,
                  ),
                ),
                sh(4),
                shimmer(
                  child: Container(
                    height: 12.h,
                    width: 100.w,
                    decoration: grey,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
            child: shimmer(
              child: Container(
                height: 40.h,
                width: double.infinity,
                decoration: greyChip,
              ),
            ),
          ),
          // Working hours grid
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
            child: shimmer(
              child: Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 14.h, width: 100.w, decoration: grey),
                    sh(10),
                    Row(
                      children: [
                        Expanded(
                          child: Container(height: 52.h, decoration: greyCard),
                        ),
                        sw(6),
                        Expanded(
                          child: Container(height: 52.h, decoration: greyCard),
                        ),
                        sw(6),
                        Expanded(
                          child: Container(height: 52.h, decoration: greyCard),
                        ),
                      ],
                    ),
                    sh(6),
                    Row(
                      children: [
                        Expanded(
                          child: Container(height: 52.h, decoration: greyCard),
                        ),
                        sw(6),
                        Expanded(
                          child: Container(height: 52.h, decoration: greyCard),
                        ),
                        sw(6),
                        Expanded(
                          child: Container(height: 52.h, decoration: greyCard),
                        ),
                      ],
                    ),
                    sh(6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 52.h,
                          width: 100.w,
                          decoration: greyCard,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Stats grid
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
            child: shimmer(
              child: Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 14.h, width: 60.w, decoration: grey),
                    sh(10),
                    Row(
                      children: [
                        Expanded(
                          child: Container(height: 60.h, decoration: greyChip),
                        ),
                        sw(8),
                        Expanded(
                          child: Container(height: 60.h, decoration: greyChip),
                        ),
                        sw(8),
                        Expanded(
                          child: Container(height: 60.h, decoration: greyChip),
                        ),
                      ],
                    ),
                    sh(8),
                    Row(
                      children: [
                        Expanded(
                          child: Container(height: 60.h, decoration: greyChip),
                        ),
                        sw(8),
                        Expanded(
                          child: Container(height: 60.h, decoration: greyChip),
                        ),
                        sw(8),
                        Expanded(
                          child: Container(height: 60.h, decoration: greyChip),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Quick actions
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
            child: Row(
              children: [
                Expanded(
                  child: shimmer(
                    child: Container(height: 40.h, decoration: greyChip),
                  ),
                ),
                sw(8),
                Expanded(
                  child: shimmer(
                    child: Container(height: 40.h, decoration: greyChip),
                  ),
                ),
              ],
            ),
          ),
          sh(32),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomImageView(
              imagePath: AppAssets.icWarning,
              color: AppColors.grey,
              height: 48.r,
              width: 48.r,
            ),
            sh(12),
            CustomText(
              AppStrings.defaultError,
              style: AppTypography.bodyText.copyWith(color: AppColors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext ctx, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.darkGrey, size: 22.r),
      title: CustomText(
        label,
        style: AppTypography.bodyText.copyWith(
          fontSize: 15.sp,
          color: AppColors.darkGrey,
        ),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 2.h),
    );
  }
}

// ─── Overview Tab ─────────────────────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  final BusinessState state;
  const _OverviewTab({required this.state});

  @override
  Widget build(BuildContext context) {
    final d = state.dashboard;
    final p = d?.profile;
    if (d == null || p == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCoverAndLogo(p),
          _buildProfileInfo(p, d),
          _buildVisibilityBanner(p.visibilityState),
          _buildDetailsSection(p),
          if (p.workingHours != null) _buildWorkingHours(p.workingHours!),
          _buildStatsSection(d, state),
          _buildQuickActions(context),
          sh(MediaQuery.of(context).padding.bottom + 32.h),
        ],
      ),
    );
  }

  Widget _buildCoverAndLogo(BusinessProfile p) {
    final coverPlaceholder = Container(height: 140.h, color: AppColors.bgBlue);
    final logoPlaceholder = Container(
      width: 60.r,
      height: 60.r,
      color: AppColors.background,
      child: CustomImageView(
        imagePath: AppAssets.icMarket,
        color: AppColors.grey,
        height: 28.r,
        width: 28.r,
      ),
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(16.r),
            bottomRight: Radius.circular(16.r),
          ),
          child: p.coverUrl != null && p.coverUrl!.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: p.coverUrl!,
                  height: 140.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => coverPlaceholder,
                  errorWidget: (_, __, ___) => coverPlaceholder,
                )
              : Container(
                  height: 140.h,
                  width: double.infinity,
                  color: AppColors.bgBlue,
                  child: CustomImageView(
                    imagePath: AppAssets.icMarket,
                    color: AppColors.primaryBlue.withValues(alpha: 0.3),
                    height: 48.r,
                    width: 48.r,
                  ),
                ),
        ),
        Positioned(
          bottom: -30.r,
          left: 16.w,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.white, width: 3.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.08),
                  blurRadius: 8.r,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: p.logoUrl,
                width: 100.r,
                height: 100.r,
                fit: BoxFit.cover,
                placeholder: (_, __) => logoPlaceholder,
                errorWidget: (_, __, ___) => logoPlaceholder,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileInfo(BusinessProfile p, BusinessDashboard d) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 40.r, 16.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: CustomText(
                  p.businessName,
                  style: AppTypography.screenTitle.copyWith(fontSize: 20.sp),
                ),
              ),
              if (p.isVerified)
                CustomImageView(
                  imagePath: AppAssets.icVerified,
                  height: 18.r,
                  width: 18.r,
                  color: AppColors.primaryBlue,
                ),
              if (p.gstNumber != null && p.gstNumber!.isNotEmpty) ...[
                sw(6),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: AppColors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: CustomText(
                    'GST',
                    style: AppTypography.caption.copyWith(
                      fontSize: 10.sp,
                      color: AppColors.green,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
          sh(4),
          Row(
            children: [
              CustomText(
                p.category,
                style: AppTypography.bodyText.copyWith(
                  fontSize: 14.sp,
                  color: AppColors.primaryBlue,
                ),
              ),
              if (p.subCategory != null)
                CustomText(
                  ' \u2022 ${p.subCategory}',
                  style: AppTypography.bodyText.copyWith(
                    fontSize: 14.sp,
                    color: AppColors.grey,
                  ),
                ),
            ],
          ),
          sh(2),
          CustomText(
            p.businessType == 'neighbor_for_hire'
                ? 'Neighbor for Hire'
                : 'Professional Business',
            style: AppTypography.caption.copyWith(fontSize: 12.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildVisibilityBanner(String visibility) {
    final isHidden = visibility == 'hidden';
    final color = isHidden ? AppColors.orange : AppColors.green;

    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          CustomImageView(
            imagePath: isHidden ? AppAssets.icEyeoff : AppAssets.icEyeon,
            color: color,
            height: 18.r,
            width: 18.r,
          ),
          sw(8),
          Expanded(
            child: CustomText(
              isHidden
                  ? 'Profile hidden - Get a recommendation or boost to go live'
                  : 'Profile visible in directory and marketplace',
              style: AppTypography.caption.copyWith(
                fontSize: 11.sp,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(BusinessProfile p) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
      padding: EdgeInsets.all(14.w),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            'About',
            style: AppTypography.cardTitle.copyWith(fontSize: 15.sp),
          ),
          sh(8),
          CustomText(
            p.description,
            style: AppTypography.bodyText.copyWith(
              fontSize: 13.sp,
              height: 1.5,
            ),
          ),
          sh(12),
          _buildDetailRow(
            CustomImageView(
              imagePath: AppAssets.icLocation,
              color: AppColors.primaryBlue,
              height: 18.r,
              width: 18.r,
            ),
            '${p.address}, ${p.localityName}, ${p.city}',
          ),
          if (p.phone != null && p.phone!.isNotEmpty)
            _buildDetailRow(
              CustomImageView(
                imagePath: AppAssets.icCall,
                color: AppColors.primaryBlue,
                height: 18.r,
                width: 18.r,
              ),
              p.phone!,
            ),
          if (p.website != null && p.website!.isNotEmpty)
            _buildDetailRow(
              CustomImageView(
                imagePath: AppAssets.icWorld,
                color: AppColors.primaryBlue,
                height: 18.r,
                width: 18.r,
              ),
              p.website!,
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(Widget iconWidget, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          iconWidget,
          sw(8),
          Expanded(
            child: CustomText(
              text,
              style: AppTypography.cardTitle.copyWith(
                fontSize: 12.sp,
                color: AppColors.primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkingHours(Map<String, WorkingHours> hours) {
    const days = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];
    const shortDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final hasOpen = hours.values.any((h) => h.isOpen == true);

    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
      padding: EdgeInsets.all(14.w),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            'Working Hours',
            style: AppTypography.cardTitle.copyWith(fontSize: 15.sp),
          ),
          sh(10),
          if (!hasOpen)
            CustomText(
              'Not set',
              style: AppTypography.caption.copyWith(fontSize: 12.sp),
            )
          else
            Column(
              children: [
                // Row 1: Mon, Tue, Wed
                Row(
                  children: [
                    _buildDayChip(hours[days[0]], shortDays[0]),
                    sw(6),
                    _buildDayChip(hours[days[1]], shortDays[1]),
                    sw(6),
                    _buildDayChip(hours[days[2]], shortDays[2]),
                  ],
                ),
                sh(6),
                // Row 2: Thu, Fri, Sat
                Row(
                  children: [
                    _buildDayChip(hours[days[3]], shortDays[3]),
                    sw(6),
                    _buildDayChip(hours[days[4]], shortDays[4]),
                    sw(6),
                    _buildDayChip(hours[days[5]], shortDays[5]),
                  ],
                ),
                sh(6),
                // Row 3: Sun centered
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [_buildDayChip(hours[days[6]], shortDays[6])],
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildDayChip(WorkingHours? h, String label) {
    final isOpen = h?.isOpen == true;
    final hasTime = isOpen && h?.open != null && h?.close != null;

    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          color: isOpen
              ? AppColors.green.withValues(alpha: 0.06)
              : AppColors.background,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isOpen
                ? AppColors.green.withValues(alpha: 0.2)
                : AppColors.borderLight,
          ),
        ),
        child: Column(
          children: [
            CustomText(
              label,
              style: AppTypography.caption.copyWith(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: isOpen ? AppColors.green : AppColors.grey,
              ),
            ),
            sh(2),
            CustomText(
              hasTime ? '${h!.open}\n${h.close}' : 'Closed',
              style: AppTypography.caption.copyWith(
                fontSize: 10.sp,
                color: isOpen ? AppColors.darkGrey : AppColors.grey,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(BusinessDashboard d, BusinessState state) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
      padding: EdgeInsets.all(14.w),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            'Stats',
            style: AppTypography.cardTitle.copyWith(fontSize: 15.sp),
          ),
          sh(10),
          Row(
            children: [
              _buildStatItem(
                CustomImageView(
                  imagePath: AppAssets.icEyeon,
                  color: AppColors.primaryBlue,
                  height: 18.r,
                  width: 18.r,
                ),
                '${d.totalProfileViews}',
                'Views',
                color: AppColors.primaryBlue,
              ),
              sw(8),
              _buildStatItem(
                Icon(
                  Icons.trending_up_outlined,
                  color: AppColors.orange,
                  size: 18.r,
                ),
                '${d.activeBoosts}',
                'Boosts',
                color: AppColors.orange,
              ),
              sw(8),
              _buildStatItem(
                CustomImageView(
                  imagePath: AppAssets.icPosts,
                  color: AppColors.green,
                  height: 18.r,
                  width: 18.r,
                ),
                '${d.weeklyPostsUsed}/${d.weeklyPostsLimit}',
                'Posts',
                color: AppColors.green,
              ),
            ],
          ),
          sh(8),
          Row(
            children: [
              _buildStatItem(
                Icon(
                  Icons.inventory_2_outlined,
                  color: AppColors.secondary,
                  size: 18.r,
                ),
                '${state.products.length}',
                'Products',
                color: AppColors.secondary,
              ),
              sw(8),
              _buildStatItem(
                Icon(
                  Icons.handyman_outlined,
                  color: AppColors.blue,
                  size: 18.r,
                ),
                '${state.services.length}',
                'Services',
                color: AppColors.blue,
              ),
              sw(8),
              _buildStatItem(
                CustomImageView(
                  imagePath: AppAssets.icLike,
                  color: AppColors.yellow,
                  height: 18.r,
                  width: 18.r,
                ),
                '${d.profile?.recommendationCount ?? 0}',
                'Reviews',
                color: AppColors.yellow,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    Widget iconWidget,
    String value,
    String label, {
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Column(
          children: [
            iconWidget,
            sh(4),
            CustomText(
              value,
              style: AppTypography.cardTitle.copyWith(fontSize: 16.sp),
            ),
            sh(2),
            CustomText(
              label,
              style: AppTypography.caption.copyWith(
                fontSize: 10.sp,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
      child: Row(
        children: [
          _buildActionChip(
            context,
            iconWidget: CustomImageView(
              imagePath: AppAssets.icAdd,
              color: AppColors.white,
              height: 16.r,
              width: 16.r,
            ),
            label: 'Add Product',
            onTap: () => callNextScreen(
              context,
              AddEditListingScreen(
                type: 'product',
                bloc: context.read<BusinessBloc>(),
              ),
            ),
          ),
          sw(8),
          _buildActionChip(
            context,
            iconWidget: Icon(
              Icons.add_reaction_outlined,
              color: AppColors.white,
              size: 16.r,
            ),
            label: 'Add Service',
            onTap: () => callNextScreen(
              context,
              AddEditListingScreen(
                type: 'service',
                bloc: context.read<BusinessBloc>(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip(
    BuildContext context, {
    required Widget iconWidget,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              iconWidget,
              sw(6),
              CustomText(
                label,
                style: AppTypography.bodyText.copyWith(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12.r),
      border: Border.all(color: AppColors.borderLight, width: 0.5),
    );
  }
}

// ─── Listings Tab ─────────────────────────────────────────────────────────────

class _ListingsTab extends StatelessWidget {
  final String type;
  final List<BusinessListing> listings;
  final ApiCallState status;
  final BusinessBloc bloc;

  const _ListingsTab({
    required this.type,
    required this.listings,
    required this.status,
    required this.bloc,
  });

  @override
  Widget build(BuildContext context) {
    if (status == ApiCallState.busy) {
      return Center(child: WaveDotsLoader(color: AppColors.primaryBlue));
    }

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
          child: SizedBox(
            width: double.infinity,
            height: 42.h,
            child: CustomButton.filled(
              leading: CustomImageView(
                imagePath: AppAssets.icAdd,
                color: AppColors.white,
              ),
              text: 'Add ${type == 'product' ? 'Product' : 'Service'}',
              onPressed: () => callNextScreen(
                context,
                AddEditListingScreen(type: type, bloc: bloc),
              ),
              height: 42.h,
              borderRadius: 10.r,
              textStyle: AppTypography.buttonLabel.copyWith(fontSize: 14.sp),
            ),
          ),
        ),
        Expanded(
          child: listings.isEmpty
              ? _buildEmptyState(context)
              : _buildList(context),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              type == 'product'
                  ? Icons.inventory_2_outlined
                  : Icons.handyman_outlined,
              size: 48.r,
              color: AppColors.grey.withValues(alpha: 0.5),
            ),
            sh(12),
            CustomText(
              'No ${type}s yet',
              style: AppTypography.emptyStateTitle.copyWith(fontSize: 18.sp),
            ),
            sh(6),
            CustomText(
              'Add your first ${type} to get started.',
              style: AppTypography.emptyStateBody.copyWith(fontSize: 14.sp),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _getPriceText(BusinessListing listing) {
    if (listing.priceType == 'contact') return 'Contact for Price';
    if (listing.priceType == 'range' &&
        listing.priceMin != null &&
        listing.priceMax != null) {
      return '₹${listing.priceMin!.toStringAsFixed(0)} - ₹${listing.priceMax!.toStringAsFixed(0)}';
    }
    if (listing.price == null) return '';
    final unit = listing.priceUnit != null
        ? ' /${listing.priceUnit!.replaceAll('per_', '')}'
        : '';
    return '₹${listing.price!.toStringAsFixed(0)}$unit';
  }

  Widget _buildList(BuildContext context) {
    if (type == 'product') {
      return GridView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12.h,
          crossAxisSpacing: 12.w,
          childAspectRatio: 0.75, // Adjust based on card content
        ),
        itemCount: listings.length,
        itemBuilder: (context, index) {
          final item = listings[index];
          return ListingCardWidget(
            imageUrl: item.mediaUrls.isNotEmpty ? item.mediaUrls.first : '',
            price: _getPriceText(item),
            isFree: item.price == 0,
            title: item.title,
            isMyBusiness: true,
            onEditTap: () {
              callNextScreen(
                context,
                AddEditListingScreen(type: type, bloc: bloc, listing: item),
              );
            },
          );
        },
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      itemCount: listings.length,
      itemBuilder: (context, index) {
        final item = listings[index];
        return _ListingCard(listing: item);
      },
    );
  }
}

class _ListingCard extends StatelessWidget {
  final BusinessListing listing;
  const _ListingCard({required this.listing});

  String get _priceText {
    if (listing.priceType == 'contact') return 'Contact for Price';
    if (listing.priceType == 'range' &&
        listing.priceMin != null &&
        listing.priceMax != null) {
      return '₹${listing.priceMin!.toStringAsFixed(0)} - ₹${listing.priceMax!.toStringAsFixed(0)}';
    }
    if (listing.price == null) return '';
    final unit = listing.priceUnit != null
        ? ' /${listing.priceUnit!.replaceAll('per_', '')}'
        : '';
    return '₹${listing.price!.toStringAsFixed(0)}$unit';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderLight, width: 0.5),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: listing.mediaUrls.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: listing.mediaUrls.first,
                    width: 56.r,
                    height: 56.r,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 56.r,
                    height: 56.r,
                    color: AppColors.background,
                    child: Icon(
                      listing.type == 'product'
                          ? Icons.inventory_2_outlined
                          : Icons.handyman_outlined,
                      color: AppColors.grey,
                      size: 24.r,
                    ),
                  ),
          ),
          sw(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  listing.title,
                  style: AppTypography.cardTitle.copyWith(fontSize: 14.sp),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                sh(2),
                Row(
                  children: [
                    if (_priceText.isNotEmpty)
                      CustomText(
                        _priceText,
                        style: AppTypography.priceLabel.copyWith(
                          fontSize: 13.sp,
                        ),
                      ),
                    if (listing.category != null) ...[
                      sw(6),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 1.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: CustomText(
                          listing.category!,
                          style: AppTypography.caption.copyWith(
                            fontSize: 10.sp,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (listing.type == 'product' && listing.condition != null) ...[
                  sh(3),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 1.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: CustomText(
                      listing.condition!,
                      style: AppTypography.caption.copyWith(
                        fontSize: 10.sp,
                        color: AppColors.orange,
                      ),
                    ),
                  ),
                ],
                if (listing.type == 'service' &&
                    listing.serviceArea != null) ...[
                  sh(3),
                  Row(
                    children: [
                      CustomImageView(
                        imagePath: listing.serviceArea == 'home_visit'
                            ? AppAssets.icHome
                            : AppAssets.icMarket,
                        color: AppColors.grey,
                        height: 12.r,
                        width: 12.r,
                      ),
                      sw(3),
                      CustomText(
                        listing.serviceArea == 'home_visit'
                            ? 'Home Visit'
                            : 'At Your Location',
                        style: AppTypography.caption.copyWith(fontSize: 10.sp),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: listing.isAvailable
                  ? AppColors.green.withValues(alpha: 0.1)
                  : AppColors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: CustomText(
              listing.isAvailable ? 'Active' : 'Out of Stock',
              style: AppTypography.caption.copyWith(
                fontSize: 11.sp,
                color: listing.isAvailable ? AppColors.green : AppColors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Posts Tab ────────────────────────────────────────────────────────────────

class _PostsTab extends StatelessWidget {
  const _PostsTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomImageView(
              imagePath: AppAssets.icPosts,
              color: AppColors.grey.withValues(alpha: 0.5),
              height: 48.r,
              width: 48.r,
            ),
            sh(12),
            CustomText(
              'No posts yet',
              style: AppTypography.emptyStateTitle.copyWith(fontSize: 18.sp),
            ),
            sh(6),
            CustomText(
              'Share business updates with your neighbors.',
              style: AppTypography.emptyStateBody.copyWith(fontSize: 14.sp),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
