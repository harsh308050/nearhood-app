import 'package:nearhood/core/utils/custom_import.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearhood/features/home/home_screen.dart';
import 'package:nearhood/core/network/api_call_state.dart';
import 'package:nearhood/features/auth/bloc/auth_bloc.dart';
import 'package:nearhood/features/auth/bloc/auth_event.dart';
import 'package:nearhood/features/auth/bloc/auth_state.dart';
import 'package:nearhood/features/auth/data/auth_datasource.dart';
import 'package:nearhood/features/auth/data/auth_repository.dart';
import 'package:nearhood/features/auth/model/auth_request_models.dart';

class CommunityRulesScreen extends StatefulWidget {
  const CommunityRulesScreen({super.key});

  @override
  State<CommunityRulesScreen> createState() => _CommunityRulesScreenState();
}

class _CommunityRulesScreenState extends State<CommunityRulesScreen> {
  bool _agreedToRules = false;
  bool _isLoading = false;

  final AuthBloc _authBloc = AuthBloc(
    repository: AuthRepository(dataSource: AuthRemoteDataSource()),
  );

  void _onJoinPressed() {
    if (!_agreedToRules || _isLoading) return;
    _authBloc.add(
      const UpdateRegisterRequested(
        UpdateRegisterRequest(
          onboarding: OnboardingUpdate(hasAgreedToRules: true),
        ),
      ),
    );
  }

  Widget _buildRuleItem(String number, String title, String description) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderLight, width: 1.5.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32.r,
            height: 32.r,
            decoration: const BoxDecoration(
              color: AppColors.bgBlue,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: CustomText(
                number,
                style: AppTypography.screenTitle.copyWith(
                  color: AppColors.primaryBlue,
                  fontSize: 16.sp,
                ),
              ),
            ),
          ),
          sw(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  title,
                  style: AppTypography.screenTitle.copyWith(
                    color: AppColors.primaryBlue,
                    fontSize: 16.sp,
                  ),
                ),
                sh(4),
                CustomText(
                  description,
                  style: AppTypography.bodyText.copyWith(
                    color: AppColors.darkGrey,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      bloc: _authBloc,
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == ApiCallState.busy) {
          setState(() => _isLoading = true);
        } else {
          setState(() => _isLoading = false);
          if (state.status == ApiCallState.success) {
            callNextScreenAndClearStack(context, HomeScreen());
          } else if (state.status == ApiCallState.failure) {
            AppSnackBar.showMessage(
              context,
              state.message ?? 'Failed to update rules agreement',
            );
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: CommonAppBar(
          showBackButton: false,
          titleWidget: CustomImageView(
            imagePath: AppAssets.logoTxt,
            height: 22.h,
            fit: BoxFit.contain,
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(2.h),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 20.w),
              color: AppColors.primaryBlue,
              height: 0.5.h,
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 24.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CustomText(
                        AppStrings.communityRules,
                        style: AppTypography.heroTitle.copyWith(
                          color: AppColors.primaryBlue,
                          fontSize: 24.sp,
                        ),
                      ),
                      sh(12),
                      CustomText(
                        AppStrings.communityRulesSubtitle,
                        style: AppTypography.bodyText.copyWith(
                          color: AppColors.darkGrey,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      sh(32),
                      _buildRuleItem(
                        "1",
                        AppStrings.rule1Title,
                        AppStrings.rule1Desc,
                      ),
                      _buildRuleItem(
                        "2",
                        AppStrings.rule2Title,
                        AppStrings.rule2Desc,
                      ),
                      _buildRuleItem(
                        "3",
                        AppStrings.rule3Title,
                        AppStrings.rule3Desc,
                      ),
                      _buildRuleItem(
                        "4",
                        AppStrings.rule4Title,
                        AppStrings.rule4Desc,
                      ),
                      sh(16),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _agreedToRules = !_agreedToRules;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.all(16.r),
                          decoration: BoxDecoration(
                            color:
                                AppColors.background, // Match screen background
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: AppColors.borderLight,
                              width: 1.5.r,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 24.r,
                                height: 24.r,
                                margin: EdgeInsets.only(top: 2.h),
                                decoration: BoxDecoration(
                                  color: _agreedToRules
                                      ? AppColors.primaryBlue
                                      : AppColors.white,
                                  borderRadius: BorderRadius.circular(6.r),
                                  border: Border.all(
                                    color: _agreedToRules
                                        ? AppColors.primaryBlue
                                        : AppColors.grey,
                                    width: 1.5.r,
                                  ),
                                ),
                                child: _agreedToRules
                                    ? Icon(
                                        Icons.check,
                                        size: 16.r,
                                        color: AppColors.white,
                                      )
                                    : null,
                              ),
                              sw(12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CustomText(
                                      AppStrings.agreeToFollowRules,
                                      style: AppTypography.bodyText.copyWith(
                                        color: AppColors.darkGrey,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    sh(4),
                                    CustomText(
                                      AppStrings.accountSuspensionWarning,
                                      style: AppTypography.caption.copyWith(
                                        color: AppColors.grey,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
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
              Padding(
                padding: EdgeInsets.all(20.w),
                child: CustomButton.filled(
                  text: AppStrings.joinNearhood,
                  onPressed: _agreedToRules ? _onJoinPressed : null,
                  backgroundColor: _agreedToRules
                      ? AppColors.primaryBlue
                      : AppColors.borderLight,
                  textColor: _agreedToRules ? AppColors.white : AppColors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
