import 'package:nearhood/core/utils/custom_import.dart';
import 'package:nearhood/screens/auth/mobile_number_screen.dart';

class AddressDetailsScreen extends StatefulWidget {
  final String locationName;
  final String subLocation;

  const AddressDetailsScreen({
    super.key,
    required this.locationName,
    required this.subLocation,
  });

  @override
  State<AddressDetailsScreen> createState() => _AddressDetailsScreenState();
}

class _AddressDetailsScreenState extends State<AddressDetailsScreen> {
  final TextEditingController _pinCodeController = TextEditingController();
  final TextEditingController _flatController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();

  final _pinCodeFieldKey = GlobalKey<CustomTextFieldState>();
  final _flatFieldKey = GlobalKey<CustomTextFieldState>();
  bool _showPinCodeCheck = false;

  @override
  void initState() {
    super.initState();
    _pinCodeController.addListener(_onPinCodeChanged);
  }

  void _onPinCodeChanged() {
    final isValid = _pinCodeController.text.length == 6;
    if (_showPinCodeCheck != isValid) {
      setState(() {
        _showPinCodeCheck = isValid;
      });
    }
  }

  @override
  void dispose() {
    _pinCodeController.removeListener(_onPinCodeChanged);
    _pinCodeController.dispose();
    _flatController.dispose();
    _streetController.dispose();
    super.dispose();
  }

  void _onContinue() {
    final isPinCodeValid = _pinCodeFieldKey.currentState?.validate() == null;
    final isFlatValid = _flatFieldKey.currentState?.validate() == null;

    if (isPinCodeValid && isFlatValid) {
      callNextScreenAndClearStack(context, const MobileNumberScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Section (Back Button + Header)
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sh(20),
                    CustomBackButton(screenContext: context),
                    sh(30),

                    // Title
                    CustomText(
                      AppStrings.yourAddressDetails,
                      style: AppTypography.heroTitle.copyWith(
                        color: AppColors.darkGrey,
                        fontSize: 24.sp,
                      ),
                    ),
                    sh(8),
                    CustomText(
                      AppStrings.addressDetailsSubtitle,
                      fontSize: 15.sp,
                      color: AppColors.grey,
                    ),
                    sh(24),

                    // Pre-filled Location Card
                    _buildLocationCard(),
                    sh(24),

                    // Forms
                    CustomTextField(
                      key: _pinCodeFieldKey,
                      controller: _pinCodeController,
                      label: AppStrings.pinCode,
                      hint: 'e.g. 380058',
                      keyboardType: TextInputType.number,
                      isRequired: true,
                      emptyErrorMessage: AppStrings.pincodeRequired,
                      suffixIcon: _showPinCodeCheck
                          ? AppAssets.icCheckRound
                          : null,
                      maxLength: 6,
                      textInputAction: TextInputAction.next,
                    ),
                    sh(16),

                    CustomTextField(
                      key: _flatFieldKey,
                      controller: _flatController,
                      label: AppStrings.flatBuildingName,
                      hint: AppStrings.flatBuildingNamePlaceholder,
                      keyboardType: TextInputType.text,
                      isRequired: true,
                      emptyErrorMessage: AppStrings.flatBuildingRequired,
                      textInputAction: TextInputAction.next,
                    ),
                    sh(16),

                    CustomTextField(
                      controller: _streetController,
                      label: AppStrings.streetLandmark,
                      hint: AppStrings.streetLandmarkPlaceholder,
                      keyboardType: TextInputType.text,
                      isRequired: false,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _onContinue(),
                    ),
                    sh(32),

                    // Info Box
                    _buildPrivacyInfoBox(),
                    sh(20),
                  ],
                ),
              ),
            ),

            // Bottom Continue Button
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

  Widget _buildLocationCard() {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon Circle
          Container(
            height: 48.h,
            width: 48.w,
            decoration: const BoxDecoration(
              color: AppColors.bgBlue,
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: EdgeInsets.all(12.r),
              child: CustomImageView(
                imagePath: AppAssets.icExplore,
                color: AppColors.primaryBlue,
              ),
            ),
          ),
          sw(16),
          // Location Texts
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  widget.locationName,
                  style: AppTypography.cardTitle.copyWith(
                    color: AppColors.darkGrey,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                sh(4),
                CustomText(
                  widget.subLocation,
                  style: AppTypography.bodyText.copyWith(
                    color: AppColors.grey,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
          // Edit Icon
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Padding(
              padding: EdgeInsets.all(8.r),
              child: CustomImageView(
                imagePath: AppAssets.icEdit,
                color: AppColors.primaryBlue,
                height: 20.h,
                width: 20.w,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyInfoBox() {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.bgBlue,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomImageView(
            imagePath: AppAssets.icSafetyAlert,
            color: AppColors.primaryBlue,
            height: 20.h,
            width: 20.w,
          ),
          sw(12),
          Expanded(
            child: CustomText(
              AppStrings.addressPrivacyNote,
              style: AppTypography.bodyText.copyWith(
                color: AppColors.primaryBlue,
                fontSize: 13.sp,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
