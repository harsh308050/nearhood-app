import 'package:flutter/material.dart';
import 'package:nearhood/core/theme/app_colors.dart';
import 'package:nearhood/core/theme/app_typography.dart';
import 'package:nearhood/core/utils/cm.dart';
import 'package:nearhood/common_widget/custom_text.dart';
import 'package:nearhood/features/post/data/models/post_model.dart';

enum PostMetadataMode { header, details }

class PostMetadataWidget extends StatelessWidget {
  final PostModel post;
  final PostMetadataMode mode;
  final double? horizontalPadding;

  const PostMetadataWidget({
    super.key,
    required this.post,
    required this.mode,
    this.horizontalPadding,
  });

  @override
  Widget build(BuildContext context) {
    final metadata = post.metadata;
    if (metadata == null || metadata.isEmpty) {
      return const SizedBox.shrink();
    }

    final double hp = horizontalPadding ?? 16.w;

    if (mode == PostMetadataMode.header) {
      return _buildHeader(context, metadata, hp);
    } else {
      return _buildDetails(context, metadata, hp);
    }
  }

  Widget _buildHeader(
    BuildContext context,
    Map<String, dynamic> metadata,
    double hp,
  ) {
    String? titleText;
    Color? tagColor;
    String? tagText;

    switch (post.category.toLowerCase()) {
      case 'safety alert':
        // Safety Alert doesn't have a title, its type is shown in details
        break;

      case 'lost & found':
        final subType = metadata['lostFoundType']?.toString() ?? 'Lost';
        final subjectType =
            metadata['subjectType']?.toString().toLowerCase() ?? '';
        String? name;
        if (subjectType == 'pet') {
          name = metadata['subjectName']?.toString();
        } else if (subjectType == 'item') {
          name = metadata['itemName']?.toString();
        } else if (subjectType == 'person') {
          name = metadata['personName']?.toString();
        } else if (subjectType == 'vehicle') {
          name = metadata['vehicleInfo']?.toString();
        }
        name ??=
            metadata['subjectName']?.toString() ??
            metadata['itemName']?.toString() ??
            metadata['personName']?.toString() ??
            metadata['vehicleInfo']?.toString() ??
            'Item';
        titleText = name;
        tagText = subType.toUpperCase();
        tagColor = subType.toLowerCase() == 'found'
            ? AppColors.green
            : AppColors.secondary;
        break;

      case 'for sale':
        titleText = metadata['itemTitle']?.toString();
        break;

      case 'event':
        titleText =
            metadata['eventTitle']?.toString() ?? metadata['title']?.toString();
        break;

      case 'recommendation':
        titleText = metadata['businessName']?.toString();
        break;

      case 'question':
        titleText = metadata['subject']?.toString();
        break;
    }

    if (titleText == null || titleText.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hp, vertical: 4.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (tagText != null) ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: tagColor!.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4.r),
                border: Border.all(color: tagColor.withValues(alpha: 0.3)),
              ),
              child: CustomText(
                tagText,
                style: AppTypography.overline.copyWith(
                  color: tagColor,
                  fontSize: 10.sp,
                ),
              ),
            ),
            sh(6),
          ],
          CustomText(
            titleText,
            style: AppTypography.cardTitle.copyWith(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.darkGrey,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetails(
    BuildContext context,
    Map<String, dynamic> metadata,
    double hp,
  ) {
    switch (post.category.toLowerCase()) {
      case 'safety alert':
        final alertType = metadata['alertType']?.toString() ?? 'General Alert';
        final severity = metadata['severity']?.toString() ?? 'Medium';

        Color severityColor = AppColors.yellow;
        if (severity.toLowerCase() == 'high') {
          severityColor = AppColors.red;
        } else if (severity.toLowerCase() == 'low') {
          severityColor = AppColors.blue;
        }

        return Container(
          margin: EdgeInsets.symmetric(horizontal: hp, vertical: 8.h),
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: AppColors.red.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.red.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: AppColors.red,
                size: 24.r,
              ),
              sw(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      alertType,
                      style: AppTypography.cardTitle.copyWith(
                        fontSize: 14.sp,
                        color: AppColors.red,
                      ),
                    ),
                    sh(2),
                    Row(
                      children: [
                        CustomText(
                          'Severity: ',
                          style: AppTypography.caption.copyWith(
                            fontSize: 12.sp,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 1.h,
                          ),
                          decoration: BoxDecoration(
                            color: severityColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: CustomText(
                            severity.toUpperCase(),
                            style: AppTypography.overline.copyWith(
                              color: severityColor,
                              fontSize: 9.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

      case 'lost & found':
        final lastSeenDate = metadata['lastSeenDate']?.toString();
        final subjectType = metadata['subjectType']?.toString() ?? 'Item';
        final breed = metadata['breed']?.toString();
        final contactPref = metadata['contactPreference']?.toString();
        final contactPhone = metadata['contactPhone']?.toString();
        String? contact;
        if (contactPref != null && contactPref.isNotEmpty) {
          if (contactPhone != null && contactPhone.isNotEmpty) {
            contact = '$contactPref ($contactPhone)';
          } else {
            contact = contactPref;
          }
        }

        return Container(
          margin: EdgeInsets.symmetric(horizontal: hp, vertical: 8.h),
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildKeyValueRow('Type', subjectType),
              if (breed != null && breed.isNotEmpty)
                _buildKeyValueRow('Breed/Color', breed),
              if (lastSeenDate != null && lastSeenDate.isNotEmpty)
                _buildKeyValueRow('Last Seen', lastSeenDate),
              if (contact != null && contact.isNotEmpty)
                _buildKeyValueRow('Contact Info', contact),
            ],
          ),
        );

      case 'for sale':
        final isFree = metadata['isFree'] == true;
        final price = metadata['price']?.toString() ?? '0';
        final priceText = isFree ? 'Free' : '₹$price';
        final condition = metadata['itemCondition']?.toString() ?? 'Good';
        final category = metadata['itemCategory']?.toString();
        final contactPref = metadata['contactPreference']?.toString();
        final contactPhone = metadata['contactPhone']?.toString();
        String? contact;
        if (contactPref != null && contactPref.isNotEmpty) {
          if (contactPhone != null && contactPhone.isNotEmpty) {
            contact = '$contactPref ($contactPhone)';
          } else {
            contact = contactPref;
          }
        }

        return Container(
          margin: EdgeInsets.symmetric(horizontal: hp, vertical: 8.h),
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(
                    priceText,
                    style: AppTypography.priceLabel.copyWith(
                      fontSize: 20.sp,
                      color: AppColors.green,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: CustomText(
                      condition,
                      style: AppTypography.overline.copyWith(
                        color: AppColors.primaryBlue,
                        fontSize: 11.sp,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(color: AppColors.borderLight),
              if (category != null && category.isNotEmpty)
                _buildKeyValueRow('Category', category),
              if (contact != null && contact.isNotEmpty)
                _buildKeyValueRow('Contact Info', contact),
            ],
          ),
        );

      case 'event':
        final eventDate = metadata['eventDate']?.toString() ?? '';
        final startTime = metadata['startTime']?.toString() ?? '';
        final endTime = metadata['endTime']?.toString() ?? '';
        final venue = metadata['venue']?.toString() ?? '';
        final isEventFree = metadata['isEventFree'] == true;
        final ticketPrice = metadata['ticketPrice']?.toString();

        final timeRange = endTime.isNotEmpty
            ? '$startTime - $endTime'
            : startTime;
        final admissionText = isEventFree
            ? 'Free'
            : (ticketPrice != null ? '₹$ticketPrice' : '');

        return Container(
          margin: EdgeInsets.symmetric(horizontal: hp, vertical: 8.h),
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 16.r,
                    color: AppColors.grey,
                  ),
                  sw(8),
                  CustomText(
                    '$eventDate  •  $timeRange',
                    style: AppTypography.bodyText.copyWith(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (venue.isNotEmpty) ...[
                sh(8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 16.r,
                      color: AppColors.red,
                    ),
                    sw(8),
                    Expanded(
                      child: CustomText(
                        venue,
                        style: AppTypography.caption.copyWith(
                          fontSize: 13.sp,
                          color: AppColors.darkGrey,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (admissionText.isNotEmpty) ...[
                sh(8),
                Row(
                  children: [
                    Icon(
                      Icons.local_activity_rounded,
                      size: 16.r,
                      color: AppColors.green,
                    ),
                    sw(8),
                    CustomText(
                      'Admission: $admissionText',
                      style: AppTypography.caption.copyWith(
                        fontSize: 13.sp,
                        color: AppColors.darkGrey,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );

      case 'recommendation':
        final type = metadata['recommendationType']?.toString() ?? 'recommend';
        final category = metadata['category']?.toString();

        String typeLabel = 'Highly Recommend 👍';
        Color typeColor = AppColors.green;
        if (type.toLowerCase() == 'avoid') {
          typeLabel = 'Avoid / Negative 👎';
          typeColor = AppColors.red;
        } else if (type.toLowerCase() == 'neutral') {
          typeLabel = 'Neutral 😐';
          typeColor = AppColors.grey;
        }

        return Container(
          margin: EdgeInsets.symmetric(horizontal: hp, vertical: 8.h),
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: typeColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: typeColor.withValues(alpha: 0.15)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: typeColor,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: CustomText(
                      typeLabel,
                      style: AppTypography.buttonLabel.copyWith(
                        fontSize: 12.sp,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ),
              if (category != null && category.isNotEmpty) ...[
                sh(8),
                _buildKeyValueRow('Business Category', category),
              ],
            ],
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildKeyValueRow(String key, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110.w,
            child: CustomText(
              key,
              style: AppTypography.caption.copyWith(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: CustomText(
              value,
              style: AppTypography.bodyText.copyWith(
                fontSize: 13.sp,
                color: AppColors.darkGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
