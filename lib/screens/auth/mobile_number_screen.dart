import 'package:flutter/services.dart';
import 'package:nearhood/core/utils/custom_import.dart';
import 'package:nearhood/screens/auth/otp_verification_screen.dart';
import 'package:nearhood/screens/auth/community_rules_screen.dart';

class MobileNumberScreen extends StatefulWidget {
  const MobileNumberScreen({super.key});

  @override
  State<MobileNumberScreen> createState() => _MobileNumberScreenState();
}

class _MobileNumberScreenState extends State<MobileNumberScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _onSkipPressed() {
    callNextScreen(context, const CommunityRulesScreen());
  }

  void _onSendOtp() {
    if (_phoneController.text.replaceAll(' ', '').length < 10) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      callNextScreen(
        context,
        OtpVerificationScreen(
          phoneNumber: '+91 ${_phoneController.text.trim()}',
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isButtonEnabled =
        _phoneController.text.replaceAll(' ', '').length == 10;

    return Scaffold(
      backgroundColor: AppColors.bgBlue,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Hero Section (Top 35%)
            Expanded(
              flex: 45,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomImageView(
                      imagePath: AppAssets.logo2,
                      height: 80.h,
                      fit: BoxFit.cover,
                    ),
                    sh(24),
                    CustomText(
                      AppStrings.verifyYourNumber,
                      style: AppTypography.heroTitle.copyWith(
                        color: AppColors.primaryBlue,
                        fontSize: 24.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    sh(12),
                    CustomText(
                      AppStrings.weWillSendOtp,
                      style: AppTypography.bodyText.copyWith(
                        color: AppColors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            // Input Card (Bottom 65%)
            Expanded(
              flex: 65,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(
                  20.w,
                  24.h,
                  20.w,
                  MediaQuery.of(context).padding.bottom + 20.h,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24.r),
                    topRight: Radius.circular(24.r),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomTextField(
                      controller: _phoneController,
                      label: AppStrings.mobileNumber,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                        _PhoneNumberFormatter(),
                      ],
                      onChanged: (value) {
                        setState(() {});
                      },
                      hint: AppStrings.mobileNumberPlaceholder,
                      prefix: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              CustomText(
                                "+91",
                                style: AppTypography.bodyText.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.darkGrey,
                                ),
                              ),
                              sw(4),
                              CustomImageView(
                                imagePath: AppAssets.icDownarrow,
                                color: AppColors.grey,
                              ),
                            ],
                          ),
                          sw(12),
                          Container(
                            width: 1.r,
                            height: 24.h,
                            color: AppColors.borderLight,
                          ),
                          sw(12),
                        ],
                      ),
                    ),
                    sh(16),
                    // Info Note
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomImageView(
                          imagePath: AppAssets.icLock,
                          color: AppColors.grey,
                          height: 16.r,
                          width: 16.r,
                        ),
                        sw(8),
                        Expanded(
                          child: CustomText(
                            AppStrings.oneNumberOneAccount,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Primary CTA
                    CustomButton.filled(
                      text: AppStrings.sendOtp,
                      isLoading: _isLoading,
                      onPressed: isButtonEnabled && !_isLoading
                          ? _onSendOtp
                          : null,
                      backgroundColor: AppColors.primaryBlue,
                    ),
                    sh(16),
                    // Skip Option
                    Center(
                      child: GestureDetector(
                        onTap: _onSkipPressed,
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          child: CustomText(
                            AppStrings.skipForNow,
                            style: AppTypography.bodyText.copyWith(
                              color: AppColors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final String text = newValue.text.replaceAll(' ', '');
    String formatted = '';

    for (int i = 0; i < text.length; i++) {
      formatted += text[i];
      if (i == 4 && i != text.length - 1) {
        formatted += ' ';
      }
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
