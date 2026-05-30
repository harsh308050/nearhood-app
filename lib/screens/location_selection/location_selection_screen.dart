import 'package:nearhood/core/utils/custom_import.dart';
import 'package:nearhood/screens/location_selection/area_search_bottom_sheet.dart';
import 'package:nearhood/screens/location_selection/address_details_screen.dart';

class LocationSelectionScreen extends StatefulWidget {
  const LocationSelectionScreen({super.key});

  @override
  State<LocationSelectionScreen> createState() =>
      _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  String? selectedCountry;
  final TextEditingController _localityController = TextEditingController();
  final _countryDropdownKey = GlobalKey<CustomDropdownState<String>>();
  final _localityFieldKey = GlobalKey<CustomTextFieldState>();

  // Static country list
  final List<DropdownItem<String>> countries = const [
    DropdownItem(value: 'india', label: 'India'),
    DropdownItem(value: 'usa', label: 'United States'),
    DropdownItem(value: 'uk', label: 'United Kingdom'),
    DropdownItem(value: 'canada', label: 'Canada'),
    DropdownItem(value: 'australia', label: 'Australia'),
    DropdownItem(value: 'germany', label: 'Germany'),
    DropdownItem(value: 'france', label: 'France'),
    DropdownItem(value: 'japan', label: 'Japan'),
    DropdownItem(value: 'singapore', label: 'Singapore'),
    DropdownItem(value: 'uae', label: 'United Arab Emirates'),
  ];

  @override
  void dispose() {
    _localityController.dispose();
    super.dispose();
  }

  void _onLocalityFieldTap() async {
    final result = await showAreaSearchBottomSheet(context);

    if (result != null) {
      _localityController.text = result;
      _localityFieldKey.currentState?.validate();
    }
  }

  void _onContinue() {
    // Validate country selection
    final countryError = _countryDropdownKey.currentState?.validate();
    // Validate locality selection
    final localityError = _localityFieldKey.currentState?.validate();

    if (countryError != null || localityError != null) {
      return;
    }

    // Navigate to Address Details screen
    final locality = _localityController.text.trim();
    // Assuming locality might be something like "Bopal, Ahmedabad", we can split it or just pass it
    // For this UI mockup, we'll extract the first part as location, rest as subLocation if comma exists
    String locName = locality;
    String subLoc = 'Ahmedabad, Gujarat'; // Default sublocation per design

    if (locality.contains(',')) {
      final parts = locality.split(',');
      locName = parts.first.trim();
      subLoc = parts.skip(1).join(',').trim();
    }

    callNextScreen(
      context,
      AddressDetailsScreen(locationName: locName, subLocation: subLoc),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sh(24),

                    // Hero Illustration
                    _buildHeroIllustration(),
                    sh(24),

                    // Header
                    CustomText(
                      AppStrings.whereDoYouLive,
                      style: AppTypography.heroTitle.copyWith(
                        color: AppColors.darkGrey,
                        fontSize: 24.sp,
                      ),
                    ),
                    sh(8),
                    CustomText(
                      AppStrings.connectToNeibours,
                      fontSize: 15.sp,
                      color: AppColors.grey,
                    ),
                    sh(24),

                    // Country Dropdown
                    CustomDropdown<String>(
                      key: _countryDropdownKey,
                      label: AppStrings.country,
                      hint: AppStrings.selectCountry,
                      isRequired: true,
                      isSearchable: true,
                      searchHint: AppStrings.selectCountryPlaceholder,
                      items: countries,
                      value: selectedCountry,
                      prefixIcon: AppAssets.icWorld,
                      onChanged: (value) {
                        setState(() {
                          selectedCountry = value;
                        });
                      },
                    ),
                    sh(20),

                    // Locality Search Field
                    CustomTextField(
                      key: _localityFieldKey,
                      controller: _localityController,
                      label: AppStrings.localityArea,
                      hint: AppStrings.localityAreaPlaceholder,
                      prefixIcon: AppAssets.icSearch,
                      suffixIcon: AppAssets.icGPS,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done,
                      readOnly: true,
                      isRequired: true,
                      emptyErrorMessage: AppStrings.pleaseEnterLocality,
                      onTap: _onLocalityFieldTap,
                      onSuffixIconTap: _onLocalityFieldTap,
                      onSubmitted: (_) => _onContinue(),
                    ),
                    sh(40),
                  ],
                ),
              ),
            ),

            // Continue Button
            Padding(
              padding: EdgeInsets.all(20.r),
              child: CustomButton.filled(
                text: AppStrings.continueButton,
                onPressed: _onContinue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroIllustration() {
    return ClipRRect(
      borderRadius: BorderRadiusGeometry.circular(20.r),
      child: CustomImageView(
        imagePath: AppAssets.mapPlaceholder,
        fit: BoxFit.fill,
      ),
    );
  }
}
