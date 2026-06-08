import 'package:flutter/services.dart';
import 'package:nearhood/core/utils/custom_import.dart';
import 'package:nearhood/features/auth/screens/auth_phone/otp_verification_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearhood/features/community_rules/community_rules_screen.dart';
import 'package:nearhood/core/network/api_call_state.dart';
import 'package:nearhood/features/auth/bloc/auth_bloc.dart';
import 'package:nearhood/features/auth/bloc/auth_event.dart';
import 'package:nearhood/features/auth/bloc/auth_state.dart';
import 'package:nearhood/features/auth/data/auth_datasource.dart';
import 'package:nearhood/features/auth/data/auth_repository.dart';
import 'package:nearhood/features/auth/model/auth_request_models.dart';

class MobileNumberScreen extends StatefulWidget {
  const MobileNumberScreen({super.key});

  @override
  State<MobileNumberScreen> createState() => _MobileNumberScreenState();
}

class _MobileNumberScreenState extends State<MobileNumberScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;
  bool _isSkipping = false;

  final AuthBloc _authBloc = AuthBloc(
    repository: AuthRepository(dataSource: AuthRemoteDataSource()),
  );

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _onSkipPressed() {
    _isSkipping = true;
    _authBloc.add(
      const UpdateRegisterRequested(
        UpdateRegisterRequest(
          onboarding: OnboardingUpdate(isPhoneSkipped: true),
        ),
      ),
    );
  }

  void _onSendOtp() {
    if (_phoneController.text.replaceAll(' ', '').length < 10) return;
    _isSkipping = false;
    _authBloc.add(
      SendOtpRequested(
        SendOtpRequest(phoneNumber: _phoneController.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isButtonEnabled =
        _phoneController.text.replaceAll(' ', '').length == 10;

    return BlocListener<AuthBloc, AuthState>(
      bloc: _authBloc,
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == ApiCallState.busy) {
          setState(() => _isLoading = true);
        } else {
          setState(() => _isLoading = false);
          if (state.status == ApiCallState.success) {
            if (_isSkipping) {
              callNextScreenAndClearStack(
                context,
                const CommunityRulesScreen(),
              );
            } else {
              callNextScreen(
                context,
                OtpVerificationScreen(
                  phoneNumber: '+91 ${_phoneController.text.trim()}',
                ),
              );
            }
          } else if (state.status == ApiCallState.failure) {
            AppSnackBar.showMessage(
              context,
              state.message ?? 'An error occurred',
            );
          }
        }
      },
      child: Scaffold(
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
