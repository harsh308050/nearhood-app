import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nearhood/core/utils/custom_import.dart';
import 'package:nearhood/core/utils/shared_pref_helper.dart';
import 'package:nearhood/core/network/api_call_state.dart';
import 'package:nearhood/features/auth/bloc/auth_bloc.dart';
import 'package:nearhood/features/auth/bloc/auth_event.dart';
import 'package:nearhood/features/auth/bloc/auth_state.dart';
import 'package:nearhood/features/auth/model/auth_request_models.dart';
import 'package:nearhood/features/auth/model/auth_response_models.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Forward the global AuthBloc so updates propagate to homescreen immediately
    return BlocProvider<AuthBloc>.value(
      value: context.read<AuthBloc>(),
      child: const EditProfileScreenBody(),
    );
  }
}

class EditProfileScreenBody extends StatefulWidget {
  const EditProfileScreenBody({super.key});

  @override
  State<EditProfileScreenBody> createState() => _EditProfileScreenBodyState();
}

class _EditProfileScreenBodyState extends State<EditProfileScreenBody> {
  final _formKey = GlobalKey<FormState>();
  
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _localityController;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;
  late final TextEditingController _phoneController;

  String? _localImagePath;
  UserProfile? _userProfile;

  @override
  void initState() {
    super.initState();
    _userProfile = sharedPrefGetUser();

    // Prefill data from cached UserProfile
    _nameController = TextEditingController(text: _userProfile?.fullName ?? '');
    _emailController = TextEditingController(text: _userProfile?.email ?? '');
    
    final localityName = _userProfile?.location?.locality?.name ?? '';
    _localityController = TextEditingController(text: localityName);

    final cityName = _userProfile?.location?.city?.name ?? '';
    _cityController = TextEditingController(text: cityName);

    final stateName = _userProfile?.location?.state?.name ?? '';
    _stateController = TextEditingController(text: stateName);

    final phoneNumber = _userProfile?.phone?.number ?? '';
    _phoneController = TextEditingController(text: phoneNumber);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _localityController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 85,
      );
      if (!mounted) return;
      if (pickedFile != null) {
        setState(() {
          _localImagePath = pickedFile.path;
        });
      }
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.showMessage(
        context,
        "Failed to pick image: $e",
        borderColor: AppColors.red,
      );
    }
  }

  void _saveProfile() {
    if (_nameController.text.trim().isEmpty) {
      AppSnackBar.showMessage(
        context,
        "Full Name cannot be empty",
        borderColor: AppColors.red,
      );
      return;
    }

    context.read<AuthBloc>().add(
      UpdateProfileRequested(
        UpdateProfileRequest(
          fullName: _nameController.text.trim(),
          profilePhotoUrl: _localImagePath ?? _userProfile?.profilePhotoUrl,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == ApiCallState.success) {
          AppSnackBar.showMessage(
            context,
            "Profile updated successfully",
            borderColor: AppColors.green,
          );
          Navigator.pop(context, true);
        } else if (state.status == ApiCallState.failure) {
          AppSnackBar.showMessage(
            context,
            state.message ?? "Failed to update profile",
            borderColor: AppColors.red,
          );
        }
      },
      builder: (context, state) {
        final isBusy = state.status == ApiCallState.busy;

        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: CommonAppBar(
            backgroundColor: AppColors.white,
            showBackButton: true,
            onBackPressed: () => Navigator.pop(context),
            title: 'Edit Profile',
            centerTitle: true,
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(1.0.h),
              child: Container(color: AppColors.borderLight, height: 1.0.h),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Picture Section
                    _buildAvatarSection(),
                    sh(24),

                    // Basic Details Fields
                    CustomTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      hint: 'Enter your full name',
                      enabled: !isBusy,
                      isRequired: true,
                    ),
                    sh(16),

                    CustomTextField(
                      controller: _emailController,
                      label: 'Email Address',
                      hint: 'No email address linked',
                      enabled: false,
                    ),
                    sh(16),

                    CustomTextField(
                      controller: _phoneController,
                      label: 'Mobile Number',
                      hint: 'No mobile number linked',
                      enabled: false,
                    ),
                    sh(16),

                    CustomTextField(
                      controller: _localityController,
                      label: 'Locality',
                      hint: 'Locality not set',
                      enabled: false,
                    ),
                    sh(16),

                    CustomTextField(
                      controller: _cityController,
                      label: 'City',
                      hint: 'City not set',
                      enabled: false,
                    ),
                    sh(16),

                    CustomTextField(
                      controller: _stateController,
                      label: 'State',
                      hint: 'State not set',
                      enabled: false,
                    ),
                    sh(32),

                    // Save Button
                    CustomButton(
                      text: 'Save Changes',
                      isLoading: isBusy,
                      onPressed: isBusy ? null : _saveProfile,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatarSection() {
    return Center(
      child: GestureDetector(
        onTap: _pickProfileImage,
        child: Stack(
          children: [
            Container(
              width: 100.r,
              height: 100.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.background,
                border: Border.all(color: AppColors.primaryBlue, width: 1.5.r),
              ),
              child: ClipOval(
                child: _localImagePath != null
                    ? Image.file(
                        File(_localImagePath!),
                        fit: BoxFit.cover,
                      )
                    : (_userProfile?.profilePhotoUrl != null &&
                            _userProfile!.profilePhotoUrl!.isNotEmpty
                        ? CustomImageView(
                            imagePath: _userProfile!.profilePhotoUrl!,
                            fit: BoxFit.cover,
                          )
                        : CustomImageView(
                            imagePath: AppAssets.profilePlaceholder,
                            fit: BoxFit.cover,
                          )),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(6.r),
                decoration: const BoxDecoration(
                  color: AppColors.primaryBlue,
                  shape: BoxShape.circle,
                ),
                child: CustomImageView(
                  imagePath: AppAssets.icCamera,
                  color: AppColors.white,
                  height: 16.r,
                  width: 16.r,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
