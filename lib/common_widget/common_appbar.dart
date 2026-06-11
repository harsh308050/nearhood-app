import 'package:nearhood/core/utils/custom_import.dart';

/// A reusable, highly configurable AppBar widget.
///
/// Usage Examples:
///
/// // 1. A simple screen (title only, back button)
/// CommonAppBar(
///   title: 'Details',
/// )
///
/// // 2. A detail screen (title, back button, like + bookmark + share)
/// CommonAppBar(
///   title: 'Post',
///   showLike: true,
///   isLiked: false,
///   onLikePressed: () {},
///   showBookmark: true,
///   isBookmarked: true,
///   onBookmarkPressed: () {},
///   showShare: true,
///   onSharePressed: () {},
/// )
///
/// // 3. A home/feed screen (app branding, location selector, search, notification/profile)
/// CommonAppBar(
///   showBackButton: false,
///   showAppBranding: true,
///   appName: 'Nearhood',
///   appLogo: CustomImageView(imagePath: AppAssets.logo2, height: 24.h),
///   showLocationSelector: true,
///   locationLabel: 'Bopal',
///   onLocationPressed: () {},
///   showSearch: true,
///   onSearchChanged: (val) {},
///   showProfile: true,
///   onProfilePressed: () {},
/// )
///
/// // 4. A settings/form screen (close button, title left-aligned, action CTA button)
/// CommonAppBar(
///   showBackButton: false,
///   showCloseButton: true,
///   onClosePressed: () => Navigator.pop(context),
///   title: 'Edit Profile',
///   centerTitle: false,
///   showActionButton: true,
///   actionButtonLabel: 'Save',
///   onActionButtonPressed: () {},
/// )
class CommonAppBar extends StatefulWidget implements PreferredSizeWidget {
  // --- PREFIX SECTION ---
  final VoidCallback? onBackPressed;
  final bool showBackButton;

  final Widget? closeIcon;
  final VoidCallback? onClosePressed;
  final bool showCloseButton;

  final String? locationLabel;
  final VoidCallback? onLocationPressed;
  final bool showLocationSelector;

  final Widget? appLogo;
  final String? appName;
  final bool showAppBranding;

  // --- TITLE SECTION ---
  final String? title;
  final Widget? titleWidget;
  final bool centerTitle;
  final TextStyle? titleStyle;

  // --- SUFFIX SECTION ---
  final bool showVerticalMenu;
  final VoidCallback? onVerticalMenuPressed;
  final Widget? verticalMenuIcon;

  final bool showHorizontalMenu;
  final VoidCallback? onHorizontalMenuPressed;
  final Widget? horizontalMenuIcon;

  final bool showProfile;
  final VoidCallback? onProfilePressed;
  final ImageProvider? profileImage;
  final Widget? profileIcon;

  final bool showShare;
  final VoidCallback? onSharePressed;
  final Widget? shareIcon;

  final bool showLike;
  final VoidCallback? onLikePressed;
  final bool isLiked;
  final Widget? likeIcon;
  final Widget? likedIcon;

  final bool showBookmark;
  final VoidCallback? onBookmarkPressed;
  final bool isBookmarked;
  final Widget? bookmarkIcon;
  final Widget? bookmarkedIcon;

  final bool showSearch;
  final String searchHint;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onSearchClosed;
  final Widget? searchIcon;

  final bool showActionButton;
  final VoidCallback? onActionButtonPressed;
  final String? actionButtonLabel;
  final ButtonStyle? actionButtonStyle;
  final Widget? actionButton;

  // --- ADDITIONAL CONFIG ---
  final Color? backgroundColor;
  final double? elevation;
  final PreferredSizeWidget? bottom;
  final double? leadingWidth;
  final IconThemeData? iconTheme;

  const CommonAppBar({
    super.key,
    // Prefix
    this.onBackPressed,
    this.showBackButton = true,
    this.closeIcon,
    this.onClosePressed,
    this.showCloseButton = false,
    this.locationLabel,
    this.onLocationPressed,
    this.showLocationSelector = false,
    this.appLogo,
    this.appName,
    this.showAppBranding = false,

    // Title
    this.title,
    this.titleWidget,
    this.centerTitle = true,
    this.titleStyle,

    // Suffix
    this.showVerticalMenu = false,
    this.onVerticalMenuPressed,
    this.verticalMenuIcon,
    this.showHorizontalMenu = false,
    this.onHorizontalMenuPressed,
    this.horizontalMenuIcon,
    this.showProfile = false,
    this.onProfilePressed,
    this.profileImage,
    this.profileIcon,
    this.showShare = false,
    this.onSharePressed,
    this.shareIcon,
    this.showLike = false,
    this.onLikePressed,
    this.isLiked = false,
    this.likeIcon,
    this.likedIcon,
    this.showBookmark = false,
    this.onBookmarkPressed,
    this.isBookmarked = false,
    this.bookmarkIcon,
    this.bookmarkedIcon,
    this.showSearch = false,
    this.searchHint = AppStrings.searchPlaceholder,
    this.onSearchChanged,
    this.onSearchClosed,
    this.searchIcon,
    this.showActionButton = false,
    this.onActionButtonPressed,
    this.actionButtonLabel,
    this.actionButtonStyle,
    this.actionButton,

    // Config
    this.backgroundColor,
    this.elevation = 0,
    this.bottom,
    this.leadingWidth,
    this.iconTheme,
  });

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0.0));

  @override
  State<CommonAppBar> createState() => _CommonAppBarState();
}

class _CommonAppBarState extends State<CommonAppBar> {
  bool _isSearchActive = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchActive = !_isSearchActive;
      if (_isSearchActive) {
        _searchFocusNode.requestFocus();
      } else {
        _searchController.clear();
        _searchFocusNode.unfocus();
        widget.onSearchClosed?.call();
      }
    });
  }

  void _onSearchClearPressed() {
    if (_searchController.text.isNotEmpty) {
      _searchController.clear();
      widget.onSearchChanged?.call('');
    } else {
      _toggleSearch();
    }
  }

  Widget _buildIconButton({
    required Widget icon,
    required VoidCallback? onTap,
    EdgeInsetsGeometry? padding,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Padding(padding: padding ?? EdgeInsets.all(8.r), child: icon),
    );
  }

  // --- PREFIX BUILDERS ---
  List<Widget> _buildPrefixWidgets() {
    final List<Widget> prefixWidgets = [];

    if (widget.showBackButton) {
      prefixWidgets.add(
        GestureDetector(
          onTap: widget.onBackPressed,
          child: CustomBackButton(screenContext: context),
        ),
      );
      prefixWidgets.add(sw(8));
    }

    if (widget.showCloseButton) {
      prefixWidgets.add(
        _buildIconButton(
          onTap: widget.onClosePressed,
          icon:
              widget.closeIcon ??
              CustomImageView(
                imagePath: AppAssets.icClose,
                color: AppColors.darkGrey,
                height: 20.h,
                width: 20.w,
              ),
        ),
      );
      prefixWidgets.add(sw(8));
    }

    if (widget.showAppBranding) {
      prefixWidgets.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.appLogo != null) ...[
              widget.appLogo!,
              sw(8),
            ] else ...[
              CustomImageView(
                imagePath: AppAssets.logo2,
                height: 24.h,
                width: 24.w,
              ),
              sw(8),
            ],
            if (widget.appName != null)
              CustomText(
                widget.appName!,
                style: AppTypography.screenTitle.copyWith(fontSize: 20.sp),
              ),
          ],
        ),
      );
      prefixWidgets.add(sw(8));
    }

    if (widget.showLocationSelector) {
      prefixWidgets.add(
        GestureDetector(
          onTap: widget.onLocationPressed,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColors.bgBlue.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomImageView(
                  imagePath: AppAssets.icLocation,
                  color: AppColors.primaryBlue,
                  height: 16.h,
                  width: 16.w,
                ),
                sw(6),
                CustomText(
                  widget.locationLabel ?? '',
                  style: AppTypography.bodyText.copyWith(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                sw(4),
                CustomImageView(
                  imagePath: AppAssets.icDownarrow,
                  height: 20.h,
                  width: 20.w,
                ),
              ],
            ),
          ),
        ),
      );
      prefixWidgets.add(sw(8));
    }

    return prefixWidgets;
  }

  // --- SUFFIX BUILDERS ---
  List<Widget> _buildSuffixWidgets() {
    final List<Widget> suffixWidgets = [];

    if (widget.showSearch && !_isSearchActive) {
      suffixWidgets.add(
        _buildIconButton(
          onTap: _toggleSearch,
          icon:
              widget.searchIcon ??
              CustomImageView(
                imagePath: AppAssets.icSearch,
                color: AppColors.darkGrey,
                height: 20.h,
                width: 20.w,
              ),
        ),
      );
      suffixWidgets.add(sw(4));
    }

    if (widget.showLike && !_isSearchActive) {
      suffixWidgets.add(
        _buildIconButton(
          onTap: widget.onLikePressed,
          icon: widget.isLiked
              ? (widget.likedIcon ??
                    CustomImageView(
                      imagePath: AppAssets
                          .icHeart, // Replace with filled heart asset if available
                      color: AppColors.red,
                      height: 20.h,
                      width: 20.w,
                    ))
              : (widget.likeIcon ??
                    CustomImageView(
                      imagePath: AppAssets.icHeart,
                      color: AppColors.darkGrey,
                      height: 20.h,
                      width: 20.w,
                    )),
        ),
      );
      suffixWidgets.add(sw(4));
    }

    if (widget.showBookmark && !_isSearchActive) {
      suffixWidgets.add(
        _buildIconButton(
          onTap: widget.onBookmarkPressed,
          icon: widget.isBookmarked
              ? (widget.bookmarkedIcon ??
                    CustomImageView(
                      imagePath: AppAssets
                          .icBookmark, // Replace with filled if available
                      color: AppColors.primaryBlue,
                      height: 20.h,
                      width: 20.w,
                    ))
              : (widget.bookmarkIcon ??
                    CustomImageView(
                      imagePath: AppAssets.icBookmark,
                      color: AppColors.darkGrey,
                      height: 20.h,
                      width: 20.w,
                    )),
        ),
      );
      suffixWidgets.add(sw(4));
    }

    if (widget.showShare && !_isSearchActive) {
      suffixWidgets.add(
        _buildIconButton(
          onTap: widget.onSharePressed,
          icon:
              widget.shareIcon ??
              CustomImageView(
                imagePath: AppAssets.icShare,
                color: AppColors.darkGrey,
                height: 18.h,
                width: 18.w,
              ),
        ),
      );
      suffixWidgets.add(sw(4));
    }

    if (widget.showHorizontalMenu && !_isSearchActive) {
      suffixWidgets.add(
        _buildIconButton(
          onTap: widget.onHorizontalMenuPressed,
          icon:
              widget.horizontalMenuIcon ??
              CustomImageView(
                imagePath: AppAssets.icMenuHorizontal,
                color: AppColors.darkGrey,
                height: 20.h,
                width: 20.w,
              ),
        ),
      );
      suffixWidgets.add(sw(4));
    }

    if (widget.showVerticalMenu && !_isSearchActive) {
      suffixWidgets.add(
        _buildIconButton(
          onTap: widget.onVerticalMenuPressed,
          icon:
              widget.verticalMenuIcon ??
              CustomImageView(
                imagePath: AppAssets
                    .icMenu, // Vertical icon if exists, falling back to menu
                color: AppColors.darkGrey,
                height: 20.h,
                width: 20.w,
              ),
        ),
      );
      suffixWidgets.add(sw(4));
    }

    if (widget.showProfile && !_isSearchActive) {
      suffixWidgets.add(
        _buildIconButton(
          onTap: widget.onProfilePressed,
          padding: EdgeInsets.zero,
          icon:
              widget.profileIcon ??
              (widget.profileImage != null
                  ? CircleAvatar(
                      radius: 16.r,
                      backgroundImage: widget.profileImage,
                    )
                  : CustomImageView(
                      imagePath: AppAssets.icProfile,
                      height: 32.h,
                      width: 32.w,
                    )),
        ),
      );
      suffixWidgets.add(sw(4));
    }

    if (widget.actionButton != null && !_isSearchActive) {
      suffixWidgets.add(widget.actionButton!);
      suffixWidgets.add(sw(4));
    } else if (widget.showActionButton && !_isSearchActive) {
      suffixWidgets.add(
        CustomButton.filled(
          height: 32.h,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          text: widget.actionButtonLabel ?? '',
          onPressed: widget.onActionButtonPressed,
          textStyle: AppTypography.buttonLabel.copyWith(fontSize: 14.sp),
        ),
      );
      suffixWidgets.add(sw(4));
    }

    return suffixWidgets;
  }

  // --- TITLE & SEARCH BUILDER ---
  Widget _buildTitleOrSearch() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _isSearchActive
          ? _buildSearchBar()
          : Align(
              alignment: widget.centerTitle
                  ? Alignment.center
                  : Alignment.topLeft,
              child:
                  widget.titleWidget ??
                  (widget.title != null
                      ? CustomText(
                          widget.title!,
                          style:
                              widget.titleStyle ??
                              AppTypography.screenTitle.copyWith(
                                fontSize: 20.sp,
                              ),
                          overflow: TextOverflow.ellipsis,
                        )
                      : const SizedBox.shrink()),
            ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      key: const ValueKey('search_bar'),
      height: 40.h,
      child: CustomTextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        hint: widget.searchHint,
        prefixIcon: AppAssets.icSearch,
        suffix: GestureDetector(
          onTap: _onSearchClearPressed,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: CustomImageView(
              imagePath: AppAssets.icClose,
              height: 16.r,
              width: 16.r,
              color: AppColors.darkGrey,
            ),
          ),
        ),
        onChanged: widget.onSearchChanged,
        autofocus: true,
        borderRadius: 20.r,
        borderColor: AppColors.borderLight,
        focusedBorderColor: AppColors.primaryBlue,
        backgroundColor: AppColors.white,
        variant: CustomTextFieldVariant.outlined,
        textStyle: AppTypography.bodyText,
        hintStyle: AppTypography.bodyText.copyWith(color: AppColors.grey),
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: widget.backgroundColor ?? AppColors.background,
      elevation: widget.elevation,
      automaticallyImplyLeading:
          false, // We handle leading ourselves via prefix
      titleSpacing: 0,
      scrolledUnderElevation: 0.0,
      surfaceTintColor: Colors.transparent,
      iconTheme: widget.iconTheme,
      leadingWidth: 0,
      title: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Row(
          children: [
            if (!_isSearchActive) ..._buildPrefixWidgets(),
            Expanded(child: _buildTitleOrSearch()),
            if (!_isSearchActive) ...[sw(8), ..._buildSuffixWidgets()],
          ],
        ),
      ),
      bottom: widget.bottom,
    );
  }
}
