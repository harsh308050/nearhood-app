import 'package:nearhood/core/utils/custom_import.dart';
import 'package:nearhood/features/post/data/models/post_model.dart';
import 'package:nearhood/features/post/widgets/poll_widget.dart';
import 'package:nearhood/features/post/widgets/location_map_preview_widget.dart';

class PostAttachmentsWidget extends StatefulWidget {
  final List<String> mediaUrls;
  final AttachedLocationModel? attachedLocation;
  final PollModel? poll;
  final String currentUserId;
  final String? postAuthorId;
  final Function(String optionId)? onPollOptionTap;
  final double imageHeight;
  final BorderRadius? borderRadius;

  final bool isDetail;

  const PostAttachmentsWidget({
    super.key,
    required this.mediaUrls,
    required this.attachedLocation,
    required this.poll,
    required this.currentUserId,
    this.postAuthorId,
    this.onPollOptionTap,
    this.imageHeight = 220.0,
    this.borderRadius,
    this.isDetail = false,
  });

  @override
  State<PostAttachmentsWidget> createState() => _PostAttachmentsWidgetState();
}

class _PostAttachmentsWidgetState extends State<PostAttachmentsWidget>
    with AutomaticKeepAliveClientMixin {
  late String _activeTab;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initActiveTab();
  }

  @override
  void didUpdateWidget(covariant PostAttachmentsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Ensure active tab is still valid if attachments changed
    final available = _getAvailableTabs();
    if (!available.contains(_activeTab)) {
      _initActiveTab();
    }
  }

  List<String> _getAvailableTabs() {
    final tabs = <String>[];
    if (widget.mediaUrls.isNotEmpty) tabs.add('photos');
    if (widget.poll != null) tabs.add('poll');
    if (widget.attachedLocation != null &&
        widget.attachedLocation!.address != null) {
      tabs.add('location');
    }
    return tabs;
  }

  void _initActiveTab() {
    final available = _getAvailableTabs();
    if (available.isNotEmpty) {
      _activeTab = available.first;
    } else {
      _activeTab = '';
    }
  }

  String _getTabLabel(String tab) {
    switch (tab) {
      case 'photos':
        return 'Photos';
      case 'poll':
        return 'Poll';
      case 'location':
        return 'Location';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    final availableTabs = _getAvailableTabs();
    if (availableTabs.isEmpty) return const SizedBox.shrink();

    final isTabbed = availableTabs.length > 1;
    final paddingVal = widget.isDetail ? 20.w : 16.w;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isTabbed) ...[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: paddingVal),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: availableTabs.map((tab) {
                  final isActive = _activeTab == tab;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _activeTab = tab;
                      });
                    },
                    child: Container(
                      width: 80.w,
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(right: 8.w),
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.primaryBlue.withValues(alpha: 0.08)
                            : AppColors.white,
                        borderRadius: BorderRadius.circular(100.r),
                        border: Border.all(
                          color: isActive
                              ? AppColors.primaryBlue
                              : AppColors.borderLight,
                          width: isActive ? 1.5.w : 1.w,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomText(
                            _getTabLabel(tab),
                            style: AppTypography.caption.copyWith(
                              fontSize: 12.sp,
                              fontWeight: isActive
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isActive
                                  ? AppColors.primaryBlue
                                  : AppColors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          sh(8),
        ],
        _buildActiveContent(paddingVal),
      ],
    );
  }

  Widget _buildActiveContent(double paddingVal) {
    switch (_activeTab) {
      case 'photos':
        if (widget.isDetail) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: paddingVal),
            child: PostMediaCarouselWidget(
              mediaUrls: widget.mediaUrls,
              height: widget.imageHeight,
              borderRadius: widget.borderRadius,
            ),
          );
        } else {
          return PostMediaCarouselWidget(
            mediaUrls: widget.mediaUrls,
            height: widget.imageHeight,
            borderRadius: widget.borderRadius,
          );
        }
      case 'poll':
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          margin: EdgeInsets.symmetric(horizontal: paddingVal, vertical: 8.h),
          decoration: BoxDecoration(
            color: AppColors.bgBlue,
            borderRadius: BorderRadius.circular(10),
          ),
          child: PollWidget(
            poll: widget.poll!,
            currentUserId: widget.currentUserId,
            postAuthorId: widget.postAuthorId,
            onOptionSelected: (optionId) {
              widget.onPollOptionTap?.call(optionId);
            },
          ),
        );
      case 'location':
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: paddingVal, vertical: 8.h),
          child: LocationMapPreviewWidget(
            latitude: widget.attachedLocation!.latitude,
            longitude: widget.attachedLocation!.longitude,
            address: widget.attachedLocation!.address!,
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
