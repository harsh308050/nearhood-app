import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearhood/core/network/api_call_state.dart';
import 'package:nearhood/core/utils/custom_import.dart';
import 'package:nearhood/features/business/bloc/business_bloc.dart';
import 'package:nearhood/features/business/bloc/business_event.dart';
import 'package:nearhood/features/business/bloc/business_state.dart';
import 'package:nearhood/features/business/models/business_models.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BusinessProfileScreen extends StatefulWidget {
  const BusinessProfileScreen({super.key});

  @override
  State<BusinessProfileScreen> createState() => _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends State<BusinessProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BusinessBloc>().add(FetchBusinessProfile());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CommonAppBar(
        title: AppStrings.myBusiness,
        showBackButton: true,
      ),
      body: BlocBuilder<BusinessBloc, BusinessState>(
        builder: (context, state) {
          if (state.fetchProfileStatus == ApiCallState.busy) {
            return _buildShimmer();
          }
          if (state.businessProfile == null) {
            return _buildEmpty();
          }
          return _buildProfile(state.businessProfile!);
        },
      ),
    );
  }

  Widget _buildShimmer() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          shimmer(
            child: Container(
              height: 140.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
          ),
          sh(12),
          shimmer(
            child: Container(
              height: 260.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomImageView(imagePath: AppAssets.icMarket, color: AppColors.grey, height: 64.r, width: 64.r),
            sh(16),
            CustomText(
              'No business profile found',
              style: AppTypography.sectionHeader
                  .copyWith(color: AppColors.darkGrey),
            ),
            sh(8),
            CustomText(
              'Create a business page to get started.',
              style: AppTypography.bodyText.copyWith(color: AppColors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfile(BusinessProfile profile) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Profile Card ──────────────────────────────────────────
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cover photo
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(16.r),
                  ),
                  child: _buildCover(profile.coverUrl),
                ),

                // Logo + Name + Category
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo overlapping cover
                      Transform.translate(
                        offset: const Offset(0, -30),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.white,
                              width: 3,
                            ),
                          ),
                          child: _buildLogo(profile.logoUrl),
                        ),
                      ),
                      Transform.translate(
                        offset: const Offset(0, -20),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 2.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Business name
                              Row(
                                children: [
                                  Flexible(
                                    child: CustomText(
                                      profile.businessName,
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.darkGrey,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (profile.isVerified) ...[
                                    sw(4),
                                    CustomImageView(
                                      imagePath: AppAssets.icVerified,
                                      color: AppColors.primaryBlue,
                                      height: 16.r,
                                      width: 16.r,
                                    ),
                                  ],
                                ],
                              ),
                              sh(4),
                              // Category + Subcategory
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 3.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryBlue.withValues(
                                        alpha: 0.08,
                                      ),
                                      borderRadius: BorderRadius.circular(6.r),
                                    ),
                                    child: CustomText(
                                      profile.category,
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        color: AppColors.primaryBlue,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  if (profile.subCategory != null) ...[
                                    sw(6),
                                    CustomText(
                                      profile.subCategory!,
                                      style: AppTypography.bodyText.copyWith(fontSize: 12.sp, color: AppColors.grey),
                                    ),
                                  ],
                                ],
                              ),
                              sh(4),
                              // Business type
                              Row(
                                children: [
                                  CustomImageView(
                                    imagePath: profile.businessType == 'neighbor_for_hire'
                                        ? AppAssets.icProfile
                                        : AppAssets.icMarket,
                                    color: AppColors.grey,
                                    height: 14.r,
                                    width: 14.r,
                                  ),
                                  sw(4),
                                  CustomText(
                                    profile.businessType == 'neighbor_for_hire'
                                        ? AppStrings.neighborForHire
                                        : AppStrings.professionalBusiness,
                                    style: AppTypography.bodyText.copyWith(fontSize: 12.sp, color: AppColors.grey),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          sh(16),

          // ── Details Section ───────────────────────────────────────
          _buildDetailRow(
            CustomImageView(imagePath: AppAssets.icDocument, color: AppColors.grey, height: 18.r, width: 18.r),
            'Description',
            profile.description,
          ),
          _buildDetailRow(
            CustomImageView(imagePath: AppAssets.icLocation, color: AppColors.grey, height: 18.r, width: 18.r),
            'Address',
            profile.address,
          ),
          _buildDetailRow(
            CustomImageView(imagePath: AppAssets.icLocation, color: AppColors.grey, height: 18.r, width: 18.r),
            'Locality',
            '${profile.localityName}, ${profile.city}',
          ),
          if (profile.phone != null && profile.phone!.isNotEmpty)
            _buildDetailRow(
              CustomImageView(imagePath: AppAssets.icCall, color: AppColors.grey, height: 18.r, width: 18.r),
              'Phone',
              '+91 ${profile.phone}',
            ),
          if (profile.website != null && profile.website!.isNotEmpty)
            _buildDetailRow(
              CustomImageView(imagePath: AppAssets.icWorld, color: AppColors.grey, height: 18.r, width: 18.r),
              'Website',
              profile.website!,
            ),
          if (profile.gstNumber != null && profile.gstNumber!.isNotEmpty)
            _buildDetailRow(
              CustomImageView(imagePath: AppAssets.icVerified, color: AppColors.grey, height: 18.r, width: 18.r),
              'GST Number',
              profile.gstNumber!,
            ),

          // Working hours summary
          if (profile.workingHours != null &&
              profile.workingHours!.values.any((h) => h.isOpen)) ...[
            sh(12),
            _buildWorkingHoursSummary(profile.workingHours!),
          ],
        ],
      ),
    );
  }

  Widget _buildCover(String? coverUrl) {
    if (coverUrl != null && coverUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: coverUrl,
        height: 140.h,
        width: double.infinity,
        fit: BoxFit.cover,
        errorWidget: (_, __, ___) => _buildCoverPlaceholder(),
      );
    }
    return _buildCoverPlaceholder();
  }

  Widget _buildCoverPlaceholder() {
    return Container(
      height: 140.h,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryBlue.withValues(alpha: 0.15),
            AppColors.primaryBlue.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: CustomImageView(
          imagePath: AppAssets.icMarket,
          color: AppColors.primaryBlue.withValues(alpha: 0.3),
          height: 48.r,
          width: 48.r,
        ),
      ),
    );
  }

  Widget _buildLogo(String? logoUrl) {
    return ClipOval(
      child: SizedBox(
        width: 64.r,
        height: 64.r,
        child: _buildLogoImage(logoUrl),
      ),
    );
  }

  Widget _buildLogoImage(String? logoUrl) {
    if (logoUrl != null && logoUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: logoUrl,
        width: 64.r,
        height: 64.r,
        fit: BoxFit.cover,
        errorWidget: (_, __, ___) => _buildLogoPlaceholder(),
      );
    }
    return _buildLogoPlaceholder();
  }

  Widget _buildLogoPlaceholder() {
    return Container(
      width: 64.r,
      height: 64.r,
      decoration: BoxDecoration(
        color: AppColors.background,
        shape: BoxShape.circle,
      ),
      child: CustomImageView(imagePath: AppAssets.icMarket, color: AppColors.grey, height: 28.r, width: 28.r),
    );
  }

  Widget _buildDetailRow(Widget iconWidget, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          iconWidget,
          sw(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  label,
                  style: AppTypography.caption.copyWith(fontSize: 11.sp, color: AppColors.grey, fontWeight: FontWeight.w500),
                ),
                sh(2),
                CustomText(
                  value,
                  style: AppTypography.bodyText.copyWith(color: AppColors.darkGrey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkingHoursSummary(Map<String, WorkingHours> hours) {
    const dayLabels = {
      'monday': 'Mon',
      'tuesday': 'Tue',
      'wednesday': 'Wed',
      'thursday': 'Thu',
      'friday': 'Fri',
      'saturday': 'Sat',
      'sunday': 'Sun',
    };

    final openDays = hours.entries
        .where((e) => e.value.isOpen)
        .map((e) => dayLabels[e.key] ?? e.key)
        .toList();

    if (openDays.isEmpty) return const SizedBox.shrink();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomImageView(imagePath: AppAssets.icTime, color: AppColors.grey, height: 18.r, width: 18.r),
        sw(10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                'Working Hours',
                style: AppTypography.caption.copyWith(fontSize: 11.sp, color: AppColors.grey, fontWeight: FontWeight.w500),
              ),
              sh(2),
              CustomText(
                openDays.join(', '),
                style: AppTypography.bodyText.copyWith(color: AppColors.darkGrey),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
