import 'dart:async';

import 'package:flutter/services.dart';
import 'package:nearhood/core/utils/custom_import.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearhood/core/animations/shake_animation.dart';
import 'package:nearhood/core/network/api_call_state.dart';
import 'package:nearhood/features/auth/bloc/auth_bloc.dart';
import 'package:nearhood/features/auth/bloc/auth_event.dart';
import 'package:nearhood/features/auth/bloc/auth_state.dart';
import 'package:nearhood/features/auth/data/auth_datasource.dart';
import 'package:nearhood/features/auth/data/auth_repository.dart';
import 'package:nearhood/features/auth/model/auth_request_models.dart';
import 'package:nearhood/features/community_rules/community_rules_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;

  const OtpVerificationScreen({super.key, required this.phoneNumber});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final int _otpLength = 4;
  late List<FocusNode> _focusNodes;
  late List<TextEditingController> _controllers;
  int _resendTimer = 30;
  Timer? _timer;
  bool _hasError = false;
  final ShakeWidgetController _shakeController = ShakeWidgetController();

  final AuthBloc _authBloc = AuthBloc(
    repository: AuthRepository(dataSource: AuthRemoteDataSource()),
  );

  @override
  void initState() {
    super.initState();
    _focusNodes = List.generate(_otpLength, (index) {
      var node = FocusNode();
      node.addListener(() {
        if (mounted) setState(() {});
      });
      return node;
    });
    _controllers = List.generate(
      _otpLength,
      (index) => TextEditingController(),
    );
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var node in _focusNodes) {
      node.dispose();
    }
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    setState(() => _resendTimer = 30);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_resendTimer > 0) {
        setState(() => _resendTimer--);
      } else {
        timer.cancel();
      }
    });
  }

  void _onOtpChanged(String value, int index) {
    if (value.isNotEmpty) {
      if (index < _otpLength - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        _verifyOtp();
      }
    } else {
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }
    setState(() {
      _hasError = false;
    });
  }

  void _verifyOtp() {
    String otp = _controllers.map((c) => c.text).join();
    if (otp.length != _otpLength) return;

    _authBloc.add(VerifyOtpRequested(VerifyOtpRequest(otp: otp)));
  }

  void _showError() {
    setState(() {
      _hasError = true;
      _shakeController.shake();
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _hasError = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      bloc: _authBloc,
      listenWhen: (previous, current) =>
          previous.status != current.status &&
          current.status != ApiCallState.busy,
      listener: (context, state) {
        if (state.status == ApiCallState.success) {
          AppSnackBar.showMessage(
            context,
            'Verification successful!',
            borderColor: AppColors.green,
          );
          callNextScreenAndClearStack(context, const CommunityRulesScreen());
        } else if (state.status == ApiCallState.failure) {
          _showError();
          AppSnackBar.showMessage(
            context,
            state.message ?? 'Verification failed',
            borderColor: AppColors.red,
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: CommonAppBar(onBackPressed: () => Navigator.pop(context)),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 40.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomText(
                  AppStrings.enterOtp,
                  style: AppTypography.screenTitle.copyWith(fontSize: 24.sp),
                ),
                sh(8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomText(
                      "${AppStrings.sentTo}${widget.phoneNumber}",
                      style: AppTypography.bodyText.copyWith(
                        color: AppColors.grey,
                      ),
                    ),
                    sw(8),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: CustomImageView(
                        imagePath: AppAssets.icEdit,
                        height: 16.r,
                        width: 16.r,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
                sh(32),

                // Custom OTP Input
                ShakeWidget(
                  controller: _shakeController,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_otpLength, (index) {
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: _buildOtpBox(index),
                      );
                    }),
                  ),
                ),

                if (_hasError) ...[
                  sh(16),
                  CustomText(
                    AppStrings.invalidOtp,
                    style: AppTypography.bodyText.copyWith(
                      color: AppColors.red,
                    ),
                  ),
                ],

                sh(24),

                // Resend Section
                if (_resendTimer > 0)
                  CustomText(
                    "${AppStrings.resendIn}00:${_resendTimer.toString().padLeft(2, '0')}",
                    style: AppTypography.bodyText.copyWith(
                      color: AppColors.grey,
                    ),
                  )
                else
                  Column(
                    children: [
                      CustomText(
                        AppStrings.didntReceiveIt,
                        style: AppTypography.bodyText.copyWith(
                          color: AppColors.grey,
                        ),
                      ),
                      sh(8),
                      GestureDetector(
                        onTap: () {
                          _startTimer();
                          _authBloc.add(
                            SendOtpRequested(
                              SendOtpRequest(phoneNumber: widget.phoneNumber),
                            ),
                          );
                        },
                        child: CustomText(
                          AppStrings.resendOtp,
                          style: AppTypography.bodyText.copyWith(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOtpBox(int index) {
    bool isFocused = _focusNodes[index].hasFocus;
    bool isFilled = _controllers[index].text.isNotEmpty;

    Color borderColor = AppColors.borderLight;
    if (_hasError) {
      borderColor = AppColors.red;
    } else if (isFocused || isFilled) {
      borderColor = AppColors.primaryBlue;
    }

    Color bgColor = AppColors.white;
    if (isFilled) {
      bgColor = AppColors.bgBlue;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 60.w,
      height: 68.h,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: borderColor, width: 2.r),
        boxShadow: isFocused && !_hasError
            ? [
                BoxShadow(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  blurRadius: 12.r,
                  spreadRadius: 2.r,
                  offset: Offset(0, 4.h),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 4.r,
                  spreadRadius: 0,
                  offset: Offset(0, 2.h),
                ),
              ],
      ),
      child: Center(
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(1),
          ],
          style: AppTypography.heroTitle.copyWith(
            fontSize: 28.sp,
            color: AppColors.darkGrey,
            height: 1.2, // to prevent text clipping
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            focusedErrorBorder: InputBorder.none,
            filled: false,
            counterText: "",
            contentPadding: EdgeInsets.zero,
            isDense: true,
          ),
          onChanged: (value) => _onOtpChanged(value, index),
          onTap: () {
            // Ensure we focus the first empty box instead of allowing skipping
            if (!isFilled) {
              for (int i = 0; i < _otpLength; i++) {
                if (_controllers[i].text.isEmpty) {
                  _focusNodes[i].requestFocus();
                  break;
                }
              }
            }
          },
        ),
      ),
    );
  }
}
