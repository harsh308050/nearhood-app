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
          SizedBox(height: 12.h),
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
            Icon(Icons.storefront_outlined, size: 64.r, color: AppColors.grey),
            SizedBox(height: 16.h),
            Text(
              'No business profile found',
              style: AppTypography.sectionHeader
                  .copyWith(color: AppColors.darkGrey),
            ),
            SizedBox(height: 8.h),
            Text(
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
                                    child: Text(
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
                                    SizedBox(width: 4.w),
                                    Icon(
                                      Icons.verified,
                                      color: AppColors.primaryBlue,
                                      size: 16.r,
                                    ),
                                  ],
                                ],
                              ),
                              SizedBox(height: 4.h),
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
                                    child: Text(
                                      profile.category,
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        color: AppColors.primaryBlue,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  if (profile.subCategory != null) ...[
                                    SizedBox(width: 6.w),
                                    Text(
                                      profile.subCategory!,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: AppColors.grey,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              SizedBox(height: 4.h),
                              // Business type
                              Row(
                                children: [
                                  Icon(
                                    profile.businessType == 'neighbor_for_hire'
                                        ? Icons.person_outline
                                        : Icons.storefront_outlined,
                                    size: 14.r,
                                    color: AppColors.grey,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    profile.businessType == 'neighbor_for_hire'
                                        ? AppStrings.neighborForHire
                                        : AppStrings.professionalBusiness,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: AppColors.grey,
                                    ),
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
          SizedBox(height: 16.h),

          // ── Details Section ───────────────────────────────────────
          _buildDetailRow(
            Icons.description_outlined,
            'Description',
            profile.description,
          ),
          _buildDetailRow(
            Icons.location_on_outlined,
            'Address',
            profile.address,
          ),
          _buildDetailRow(
            Icons.pin_drop_outlined,
            'Locality',
            '${profile.localityName}, ${profile.city}',
          ),
          if (profile.phone != null && profile.phone!.isNotEmpty)
            _buildDetailRow(
              Icons.phone_outlined,
              'Phone',
              '+91 ${profile.phone}',
            ),
          if (profile.website != null && profile.website!.isNotEmpty)
            _buildDetailRow(
              Icons.language,
              'Website',
              profile.website!,
            ),
          if (profile.gstNumber != null && profile.gstNumber!.isNotEmpty)
            _buildDetailRow(
              Icons.verified_outlined,
              'GST Number',
              profile.gstNumber!,
            ),

          // Working hours summary
          if (profile.workingHours != null &&
              profile.workingHours!.values.any((h) => h.isOpen)) ...[
            SizedBox(height: 12.h),
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
        child: Icon(
          Icons.storefront,
          color: AppColors.primaryBlue.withValues(alpha: 0.3),
          size: 48.r,
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
      child: Icon(Icons.store, color: AppColors.grey, size: 28.r),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18.r, color: AppColors.grey),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.darkGrey,
                  ),
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
        Icon(Icons.access_time, size: 18.r, color: AppColors.grey),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Working Hours',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: AppColors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                openDays.join(', '),
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.darkGrey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
