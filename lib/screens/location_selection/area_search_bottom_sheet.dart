import 'package:nearhood/core/utils/custom_import.dart';

class AreaSearchBottomSheet extends StatefulWidget {
  const AreaSearchBottomSheet({super.key});

  @override
  State<AreaSearchBottomSheet> createState() => _AreaSearchBottomSheetState();
}

class _AreaSearchBottomSheetState extends State<AreaSearchBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<LocalityItem> _filteredLocalities = [];

  // Sample localities data
  final List<LocalityItem> _allLocalities = const [
    LocalityItem(name: 'Bopal', city: 'Ahmedabad', state: 'Gujarat'),
    LocalityItem(name: 'Satellite', city: 'Ahmedabad', state: 'Gujarat'),
    LocalityItem(name: 'Prahlad Nagar', city: 'Ahmedabad', state: 'Gujarat'),
    LocalityItem(name: 'Thaltej', city: 'Ahmedabad', state: 'Gujarat'),
    LocalityItem(name: 'Vastrapur', city: 'Ahmedabad', state: 'Gujarat'),
    LocalityItem(name: 'Maninagar', city: 'Ahmedabad', state: 'Gujarat'),
    LocalityItem(name: 'Navrangpura', city: 'Ahmedabad', state: 'Gujarat'),
    LocalityItem(name: 'Koramangala', city: 'Bangalore', state: 'Karnataka'),
    LocalityItem(name: 'Whitefield', city: 'Bangalore', state: 'Karnataka'),
    LocalityItem(name: 'Indiranagar', city: 'Bangalore', state: 'Karnataka'),
    LocalityItem(name: 'HSR Layout', city: 'Bangalore', state: 'Karnataka'),
    LocalityItem(name: 'Bandra', city: 'Mumbai', state: 'Maharashtra'),
    LocalityItem(name: 'Andheri', city: 'Mumbai', state: 'Maharashtra'),
    LocalityItem(name: 'Powai', city: 'Mumbai', state: 'Maharashtra'),
  ];

  @override
  void initState() {
    super.initState();
    _filteredLocalities = _allLocalities;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredLocalities = _allLocalities;
      } else {
        _filteredLocalities = _allLocalities
            .where(
              (locality) =>
                  locality.name.toLowerCase().contains(query.toLowerCase()) ||
                  locality.city.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  void _onLocalitySelected(LocalityItem locality) {
    Navigator.pop(context, locality.name);
  }

  void _onUseCurrentLocation() {
    // Handle current location logic here
    Navigator.pop(context, AppStrings.currentLocation);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          _buildHandleBar(),

          // Top Bar
          _buildTopBar(),

          // Search Bar
          _buildSearchBar(),

          // Current Location Option
          _buildCurrentLocationOption(),

          // Divider
          Container(height: 1.h, color: AppColors.borderLight),

          // Results List
          Expanded(
            child: _filteredLocalities.isEmpty
                ? _buildEmptyState()
                : _buildLocalitiesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHandleBar() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Container(
        width: 40.w,
        height: 4.h,
        decoration: BoxDecoration(
          color: AppColors.borderLight,
          borderRadius: BorderRadius.circular(2.r),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 50.h,
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: CustomImageView(
              imagePath: AppAssets.icClose,
              height: 16.r,
              width: 16.r,
              color: AppColors.darkGrey,
            ),
          ),
          Expanded(
            child: Center(
              child: CustomText(
                AppStrings.selectYourArea,
                fontSize: 17.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.darkGrey,
              ),
            ),
          ),
          sw(24), // Balance the close button
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.all(16.r),
      child: CustomTextField(
        controller: _searchController,
        hint: AppStrings.searchLocalityPlaceholder,
        prefixIcon: AppAssets.icSearch,
        suffix: _searchController.text.isNotEmpty
            ? GestureDetector(
                onTap: () {
                  _searchController.clear();
                  _onSearchChanged('');
                },
                child: CustomImageView(
                  imagePath: AppAssets.icClose,
                  height: 16.r,
                  width: 16.r,
                  color: AppColors.primaryBlue,
                ),
              )
            : GestureDetector(
                onTap: _onUseCurrentLocation,
                child: CustomImageView(
                  imagePath: AppAssets.icGPS,
                  height: 20.r,
                  width: 20.r,
                  color: AppColors.primaryBlue,
                ),
              ),
        onChanged: _onSearchChanged,
        autofocus: false,
        backgroundColor: AppColors.background,
        focusedBorderColor: AppColors.primaryBlue,
        variant: CustomTextFieldVariant.outlined,
      ),
    );
  }

  Widget _buildCurrentLocationOption() {
    return InkWell(
      onTap: _onUseCurrentLocation,
      child: Container(
        padding: EdgeInsets.all(16.r),
        child: Row(
          children: [
            Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: EdgeInsets.all(10.r),
                child: CustomImageView(
                  imagePath: AppAssets.icGPS,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
            sw(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    AppStrings.useCurrentLocation,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlue,
                  ),
                  sh(2),
                  CustomText(
                    AppStrings.detectLocationAutomatic,
                    fontSize: 13.sp,
                    color: AppColors.grey,
                  ),
                ],
              ),
            ),
            CustomImageView(
              imagePath: AppAssets.icRightarrowWithoutbar,
              height: 16.r,
              width: 16.r,
              color: AppColors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocalitiesList() {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: _filteredLocalities.length,
      itemBuilder: (context, index) {
        final locality = _filteredLocalities[index];
        final isLast = index == _filteredLocalities.length - 1;

        return InkWell(
          onTap: () => _onLocalitySelected(locality),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
            decoration: BoxDecoration(
              border: Border(
                bottom: isLast
                    ? BorderSide.none
                    : BorderSide(color: AppColors.borderLight, width: 1.r),
              ),
            ),
            child: Row(
              children: [
                // CustomImageView(
                //   imagePath: AppAssets.icLocation,
                //   height: 20.r,
                //   width: 20.r,
                //   color: AppColors.grey,
                // ),
                // sw(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        locality.name,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkGrey,
                      ),
                      sh(2),
                      CustomText(
                        '${locality.city}, ${locality.state}',
                        fontSize: 13.sp,
                        color: AppColors.grey,
                      ),
                    ],
                  ),
                ),
                CustomImageView(
                  imagePath: AppAssets.icRightarrowWithoutbar,
                  height: 16.r,
                  width: 16.r,
                  color: AppColors.borderLight,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return EmptyStateWidget(
      title: AppStrings.noAreasFound,
      subtitle: AppStrings.tryDiffSearch,
      showButton: false,
    );
  }
}

/// Function to show the area search bottom sheet
Future<String?> showAreaSearchBottomSheet(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    transitionAnimationController: null,
    builder: (context) => const AreaSearchBottomSheet(),
  );
}

class LocalityItem {
  final String name;
  final String city;
  final String state;

  const LocalityItem({
    required this.name,
    required this.city,
    required this.state,
  });
}
