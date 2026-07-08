import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:nearhood/core/utils/custom_import.dart';
import 'package:nearhood/core/utils/shared_pref_helper.dart';
import 'package:nearhood/core/network/api_call_state.dart';
import 'package:nearhood/common_widget/user_avatar_widget.dart';
import 'package:nearhood/features/post/widgets/visibility_picker_sheet.dart';
import 'package:nearhood/features/post/bloc/create_post_bloc.dart';
import 'package:nearhood/features/post/bloc/create_post_event.dart';
import 'package:nearhood/features/post/bloc/create_post_state.dart';
import 'package:nearhood/features/post/data/models/post_model.dart';
import 'package:nearhood/features/post/data/models/form_schema_model.dart';
import 'package:nearhood/features/post/data/post_datasource.dart';
import 'package:nearhood/features/post/data/post_repository.dart';
import 'package:nearhood/features/post/screens/location_picker_screen.dart';
import 'package:nearhood/features/post/widgets/create_poll_sheet.dart';
import 'package:nearhood/features/post/widgets/dynamic_form_builder.dart';
import 'package:nearhood/features/post/widgets/location_map_preview_widget.dart';

class CreatePostScreen extends StatelessWidget {
  final String category;
  final PostModel? postToEdit;

  const CreatePostScreen({super.key, required this.category, this.postToEdit});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CreatePostBloc>(
      create: (context) => CreatePostBloc(
        repository: PostRepository(dataSource: PostRemoteDataSource()),
      ),
      child: CreatePostScreenBody(category: category, postToEdit: postToEdit),
    );
  }
}

class CreatePostScreenBody extends StatefulWidget {
  final String category;
  final PostModel? postToEdit;

  const CreatePostScreenBody({
    super.key,
    required this.category,
    this.postToEdit,
  });

  @override
  State<CreatePostScreenBody> createState() => _CreatePostScreenBodyState();
}

class _CreatePostScreenBodyState extends State<CreatePostScreenBody> {
  final TextEditingController _contentController = TextEditingController();
  bool _isPostEnabled = false;
  String _selectedVisibility = 'MyArea';
  int _selectedRadius = 10000;

  // Attachment States
  final List<String> _mediaPaths = [];
  Map<String, dynamic>? _selectedLocation;
  Map<String, dynamic>? _createdPoll;

  // SDUI Schema State
  final PostRepository _repository = PostRepository(
    dataSource: PostRemoteDataSource(),
  );
  FormSchemaModel? _formSchema;
  bool _isLoadingSchema = true;
  String? _schemaError;

  // GlobalKey to access DynamicFormBuilder state
  final GlobalKey<DynamicFormBuilderState> _formBuilderKey =
      GlobalKey<DynamicFormBuilderState>();

  @override
  void initState() {
    super.initState();
    if (widget.postToEdit != null) {
      _contentController.text = widget.postToEdit!.content;
      _selectedVisibility = widget.postToEdit!.visibilityRadius;
      _selectedRadius = widget.postToEdit!.maxRadiusMeters.toInt();
      _mediaPaths.addAll(widget.postToEdit!.mediaUrls);

      if (widget.postToEdit!.attachedLocation != null) {
        _selectedLocation = {
          'address': widget.postToEdit!.attachedLocation!.address,
          'latitude': widget.postToEdit!.attachedLocation!.latitude,
          'longitude': widget.postToEdit!.attachedLocation!.longitude,
        };
      }
      if (widget.postToEdit!.poll != null) {
        _createdPoll = {
          'question': widget.postToEdit!.poll!.question,
          'options': widget.postToEdit!.poll!.options
              .map((e) => e.text)
              .toList(),
        };
      }
      _isPostEnabled = widget.postToEdit!.content.trim().isNotEmpty;
    }
    _contentController.addListener(_validatePostEnabled);
    _fetchFormSchema();
  }

  /// Fetch the form schema for this category from the API.
  Future<void> _fetchFormSchema() async {
    setState(() {
      _isLoadingSchema = true;
      _schemaError = null;
    });

    final result = await _repository.getFormSchema(widget.category);

    result.when(
      success: (schema) {
        setState(() {
          _formSchema = schema;
          _isLoadingSchema = false;
          // Apply defaults from the schema
          _applySchemaDefaults(schema);
        });
      },
      failure: (error) {
        setState(() {
          _isLoadingSchema = false;
          _schemaError = error.message;
          // Even if schema fetch fails, use hardcoded fallback defaults
          _applyFallbackDefaults();
        });
      },
    );
  }

  /// Apply defaults from the fetched schema (visibility, content placeholder, etc.)
  void _applySchemaDefaults(FormSchemaModel schema) {
    if (widget.postToEdit == null) {
      _selectedVisibility = schema.defaultVisibility.radius;
      _selectedRadius = schema.defaultVisibility.maxRadiusMeters;
    }
  }

  /// Fallback defaults when schema fetch fails.
  void _applyFallbackDefaults() {
    if (widget.postToEdit == null) {
      _selectedVisibility = 'MyArea';
      _selectedRadius = 10000;
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  void _validatePostEnabled() {
    setState(() {
      // Content is always required by the backend
      bool hasContent = _contentController.text.trim().isNotEmpty;
      _isPostEnabled = hasContent;
    });
  }

  bool _isVideo(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.avi') ||
        lower.endsWith('.mkv') ||
        lower.contains('video');
  }

  Future<void> _pickImages(ImageSource source) async {
    if (_mediaPaths.length >= 4) {
      AppSnackBar.showMessage(context, AppStrings.maxImagesReached);
      return;
    }

    try {
      final ImagePicker picker = ImagePicker();
      if (source == ImageSource.gallery) {
        final List<XFile> pickedFiles = await picker.pickMultipleMedia();
        if (pickedFiles.isNotEmpty) {
          setState(() {
            final availableSlots = 4 - _mediaPaths.length;
            final filesToAdd = pickedFiles
                .take(availableSlots)
                .map((x) => x.path);
            _mediaPaths.addAll(filesToAdd);
          });
          _validatePostEnabled();
        }
      } else {
        _showCameraOptions();
      }
    } catch (e) {
      AppSnackBar.showMessage(
        context,
        "Failed to pick media: $e",
        borderColor: AppColors.red,
      );
    }
  }

  void _showCameraOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 16.h),
              ListTile(
                leading: const Icon(
                  Icons.camera_alt,
                  color: AppColors.primaryBlue,
                ),
                title: const Text('Take Photo'),
                onTap: () async {
                  Navigator.pop(ctx);
                  _captureMedia(isVideo: false);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.videocam,
                  color: AppColors.primaryBlue,
                ),
                title: const Text('Record Video'),
                onTap: () async {
                  Navigator.pop(ctx);
                  _captureMedia(isVideo: true);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _captureMedia({required bool isVideo}) async {
    if (_mediaPaths.length >= 4) {
      AppSnackBar.showMessage(context, AppStrings.maxImagesReached);
      return;
    }
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? file = isVideo
          ? await picker.pickVideo(source: ImageSource.camera)
          : await picker.pickImage(source: ImageSource.camera);
      if (file != null) {
        setState(() {
          _mediaPaths.add(file.path);
        });
        _validatePostEnabled();
      }
    } catch (e) {
      AppSnackBar.showMessage(
        context,
        "Failed to capture media: $e",
        borderColor: AppColors.red,
      );
    }
  }

  String _getVisibilityLabel(String value) {
    switch (value) {
      case 'Nearby':
        return 'My Area + Nearby (${_selectedRadius ~/ 1000} KM)';
      case 'City':
        return 'Whole City';
      case 'MyArea':
      default:
        return 'My Area Only';
    }
  }

  void _showVisibilityPicker() {
    showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (context) => VisibilityPickerSheet(
        selectedValue: _selectedVisibility,
        selectedRadius: _selectedRadius,
      ),
    ).then((value) {
      if (value != null) {
        setState(() {
          _selectedVisibility = value['visibility'] as String;
          _selectedRadius = value['radius'] as int;
        });
      }
    });
  }

  // ─── Schema-driven helpers ─────────────────────────────

  /// Whether the toolbar should show the poll button.
  bool get _showPoll => _formSchema?.toolbar.enablePoll ?? _fallbackShowPoll();

  /// Whether the toolbar should show images button.
  bool get _showImages => _formSchema?.toolbar.enableImages ?? true;

  /// Whether the toolbar should show camera button.
  bool get _showCamera => _formSchema?.toolbar.enableCamera ?? true;

  /// Whether the toolbar should show location button.
  bool get _showLocation => _formSchema?.toolbar.enableLocation ?? true;

  /// Content placeholder from schema.
  String get _contentPlaceholder =>
      _formSchema?.contentConfig.placeholder ?? _fallbackPlaceholder();

  /// Content min lines from schema.
  int get _contentMinLines => _formSchema?.contentConfig.minLines ?? 5;

  /// Whether this category has dynamic form fields.
  bool get _hasDynamicFields => _formSchema != null && _formSchema!.hasFields;

  /// Fallback poll visibility when schema is unavailable.
  bool _fallbackShowPoll() {
    return widget.category != 'Safety Alert' &&
        widget.category != 'Lost & Found' &&
        widget.category != 'For Sale' &&
        widget.category != 'Event';
  }

  /// Fallback placeholder when schema is unavailable.
  String _fallbackPlaceholder() {
    switch (widget.category) {
      case 'Question':
        return 'Ask your neighbors...';
      case 'Safety Alert':
        return 'Describe the safety alert in detail...';
      case 'Lost & Found':
        return 'Provide details about the lost/found item...';
      case 'For Sale':
        return "Describe the item you're selling...";
      case 'Event':
        return 'Tell your neighbors about the event...';
      default:
        return AppStrings.whatIsHappeningNeighbor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreatePostBloc, CreatePostState>(
      listener: (context, state) {
        if (state.status == ApiCallState.success) {
          AppSnackBar.showMessage(
            context,
            widget.postToEdit != null
                ? AppStrings.postUpdatedSuccessfully
                : AppStrings.postCreatedSuccessfully,
            borderColor: AppColors.green,
          );
          Navigator.pop(context, true);
        } else if (state.status == ApiCallState.failure) {
          AppSnackBar.showMessage(
            context,
            state.message ??
                (widget.postToEdit != null
                    ? 'Failed to update post'
                    : 'Failed to create post'),
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
            showBackButton: false,
            showCloseButton: true,
            onClosePressed: () => Navigator.pop(context),
            closeIcon: CustomImageView(
              imagePath: AppAssets.icClose,
              color: AppColors.darkGrey,
              height: 14.r,
              width: 14.r,
            ),
            title: widget.postToEdit != null
                ? AppStrings.editPost
                : AppStrings.createPost,
            centerTitle: true,
            actionButton: isBusy
                ? const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator.adaptive(
                        strokeWidth: 2.0,
                      ),
                    ),
                  )
                : CustomButton.filled(
                    height: 32.h,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    text: widget.postToEdit != null
                        ? AppStrings.apply
                        : AppStrings.post,
                    onPressed: _isPostEnabled
                        ? () => _submitPost(context)
                        : null,
                    textStyle: AppTypography.buttonLabel.copyWith(
                      fontSize: 14.sp,
                    ),
                    backgroundColor: AppColors.primaryBlue,
                    disabledBackgroundColor: AppColors.primaryBlue.withValues(
                      alpha: 0.5,
                    ),
                    borderRadius: 100.r,
                    enableGlow: false,
                    fullWidth: false,
                  ),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(1.0.h),
              child: Container(color: AppColors.borderLight, height: 1.0.h),
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      sh(16),
                      _buildAuthorRow(),
                      sh(16),

                      // Dynamic form fields from schema (above content)
                      if (_isLoadingSchema)
                        _buildSchemaLoading()
                      else if (_schemaError != null)
                        const SizedBox.shrink() // Schema failed — fallback defaults used
                      else if (_hasDynamicFields)
                        _buildDynamicFields(),

                      _buildTextInput(),
                      sh(8),
                      _buildLocationPreview(),
                      sh(8),

                      // Only show poll if schema allows it
                      if (_showPoll) _buildPollPreview(),

                      sh(8),
                      _buildMediaPreviews(),
                      sh(16),
                    ],
                  ),
                ),
              ),
              _buildBottomToolbar(isBusy),
            ],
          ),
        );
      },
    );
  }

  void _submitPost(BuildContext context) {
    // Validate dynamic form fields if they exist
    if (_hasDynamicFields) {
      final validationError = _formBuilderKey.currentState?.validate();
      if (validationError != null) {
        AppSnackBar.showMessage(
          context,
          validationError,
          borderColor: AppColors.red,
        );
        return;
      }
    }

    // Content is required by the backend
    if (_contentController.text.trim().isEmpty) {
      AppSnackBar.showMessage(
        context,
        AppStrings.contentRequired,
        borderColor: AppColors.red,
      );
      return;
    }

    // Get metadata from the dynamic form builder
    final metadata = _formBuilderKey.currentState?.getMetadata();

    final isEditMode = widget.postToEdit != null;

    if (isEditMode) {
      final existingMediaUrls = _mediaPaths
          .where((path) => path.startsWith('http'))
          .toList();
      final newMediaPaths = _mediaPaths
          .where((path) => !path.startsWith('http'))
          .toList();

      context.read<CreatePostBloc>().add(
        EditPostSubmitted(
          postId: widget.postToEdit!.id,
          content: _contentController.text.trim(),
          category: widget.category,
          visibilityRadius: _selectedVisibility,
          maxRadiusMeters: _selectedVisibility == 'Nearby'
              ? _selectedRadius
              : null,
          newMediaPaths: newMediaPaths,
          existingMediaUrls: existingMediaUrls,
          attachedLocation: _selectedLocation,
          poll: _createdPoll,
          metadata: metadata != null && metadata.isNotEmpty ? metadata : null,
        ),
      );
    } else {
      context.read<CreatePostBloc>().add(
        CreatePostSubmitted(
          content: _contentController.text.trim(),
          category: widget.category,
          visibilityRadius: _selectedVisibility,
          maxRadiusMeters: _selectedVisibility == 'Nearby'
              ? _selectedRadius
              : null,
          mediaPaths: _mediaPaths,
          attachedLocation: _selectedLocation,
          poll: _createdPoll,
          metadata: metadata != null && metadata.isNotEmpty ? metadata : null,
        ),
      );
    }
  }

  Widget _buildAuthorRow() {
    final user = sharedPrefGetUser();
    final authorName = user?.fullName ?? AppStrings.neighbor;
    final profilePhoto = user?.profilePhotoUrl ?? '';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          UserAvatarWidget(
            size: 44.r,
            name: authorName,
            imageUrl: profilePhoto,
            isAreaLead: user?.role == 'area_lead',
          ),
          sw(12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                authorName,
                style: AppTypography.cardTitle.copyWith(fontSize: 16.sp),
              ),
              sh(4),
              GestureDetector(
                onTap: _showVisibilityPicker,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(100.r),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Row(
                    children: [
                      CustomImageView(
                        imagePath: AppAssets.icWorld,
                        height: 14.r,
                        width: 14.r,
                        color: AppColors.grey,
                      ),
                      sw(4),
                      CustomText(
                        _getVisibilityLabel(_selectedVisibility),
                        style: AppTypography.caption.copyWith(fontSize: 12.sp),
                      ),
                      sw(4),
                      CustomImageView(
                        imagePath: AppAssets.icDownarrow,
                        color: AppColors.grey,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSchemaLoading() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: List.generate(
          2,
          (index) => Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: Container(
              height: 48.h,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicFields() {
    if (_formSchema == null) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: DynamicFormBuilder(
        key: _formBuilderKey,
        schema: _formSchema!,
        initialValues: widget.postToEdit?.metadata,
      ),
    );
  }

  Widget _buildTextInput() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: TextField(
        controller: _contentController,
        style: AppTypography.bodyText.copyWith(fontSize: 16.sp),
        maxLines: null,
        minLines: _contentMinLines,
        decoration: InputDecoration(
          hintText: _contentPlaceholder,
          hintStyle: AppTypography.bodyText.copyWith(
            fontSize: 16.sp,
            color: AppColors.placeholderText,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildLocationPreview() {
    if (_selectedLocation == null) return const SizedBox.shrink();
    final address = _selectedLocation!['address'] as String? ?? '';
    final lat = _selectedLocation!['latitude'] as double?;
    final lng = _selectedLocation!['longitude'] as double?;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: LocationMapPreviewWidget(
        latitude: lat,
        longitude: lng,
        address: address,
        showCancelButton: true,
        height: 200.h,

        onCancel: () {
          setState(() {
            _selectedLocation = null;
          });
          _validatePostEnabled();
        },
      ),
    );
  }

  Widget _buildPollPreview() {
    if (_createdPoll == null) return const SizedBox.shrink();
    final question = _createdPoll!['question'] as String;
    final options = _createdPoll!['options'] as List<String>;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.poll, color: AppColors.primaryBlue, size: 18.r),
                    sw(6),
                    CustomText(
                      AppStrings.pollAttachment,
                      style: AppTypography.cardTitle.copyWith(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.cancel, color: AppColors.grey),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    setState(() {
                      _createdPoll = null;
                    });
                    _validatePostEnabled();
                  },
                ),
              ],
            ),
            sh(8),
            CustomText(
              question,
              style: AppTypography.bodyText.copyWith(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGrey,
              ),
            ),
            sh(8),
            ...options.map(
              (opt) => Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.circle_outlined,
                        color: AppColors.grey,
                        size: 16.r,
                      ),
                      sw(8),
                      Expanded(
                        child: CustomText(
                          opt,
                          style: AppTypography.bodyText.copyWith(
                            fontSize: 13.sp,
                            color: AppColors.darkGrey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaPreviews() {
    if (_mediaPaths.isEmpty) return const SizedBox.shrink();
    return Container(
      height: 90.h,
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _mediaPaths.length,
        itemBuilder: (context, index) {
          final path = _mediaPaths[index];
          final isNetwork = path.startsWith('http');
          final isVid = _isVideo(path);
          return Stack(
            children: [
              Container(
                margin: EdgeInsets.only(right: 12.w),
                width: 80.w,
                height: 80.h,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: isVid
                      ? _VideoPreviewItem(path: path)
                      : (isNetwork
                          ? CachedNetworkImage(
                              imageUrl: path,
                              fit: BoxFit.cover,
                            )
                          : Image.file(
                              File(path),
                              fit: BoxFit.cover,
                            )),
                ),
              ),
              Positioned(
                top: 0,
                right: 12.w,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _mediaPaths.removeAt(index);
                    });
                    _validatePostEnabled();
                  },
                  child: Container(
                    padding: EdgeInsets.all(4.r),
                    decoration: const BoxDecoration(
                      color: AppColors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      color: AppColors.white,
                      size: 14.r,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBottomToolbar(bool isBusy) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.borderLight)),
      ),
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (_showImages)
              IconButton(
                icon: CustomImageView(
                  imagePath: AppAssets.icGallery,
                  color: AppColors.primaryBlue,
                  height: 24.r,
                  width: 24.r,
                ),
                onPressed: isBusy
                    ? null
                    : () => _pickImages(ImageSource.gallery),
              ),
            if (_showCamera)
              IconButton(
                icon: CustomImageView(
                  imagePath: AppAssets.icCamera,
                  color: AppColors.primaryBlue,
                  height: 24.r,
                  width: 24.r,
                ),
                onPressed: isBusy
                    ? null
                    : () => _pickImages(ImageSource.camera),
              ),
            if (_showLocation)
              IconButton(
                icon: CustomImageView(
                  imagePath: AppAssets.icLocation,
                  color: AppColors.primaryBlue,
                  height: 24.r,
                  width: 24.r,
                ),
                onPressed: isBusy
                    ? null
                    : () async {
                        final loc = await Navigator.push<Map<String, dynamic>>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LocationPickerScreen(),
                          ),
                        );
                        if (loc != null) {
                          setState(() {
                            _selectedLocation = loc;
                          });
                          _validatePostEnabled();
                        }
                      },
              ),
            if (_showPoll)
              IconButton(
                icon: CustomImageView(
                  imagePath: AppAssets.icPoll,
                  color: AppColors.primaryBlue,
                  height: 24.r,
                  width: 24.r,
                ),
                onPressed: isBusy
                    ? null
                    : () async {
                        final poll =
                            await showModalBottomSheet<Map<String, dynamic>>(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: AppColors.transparent,
                              builder: (context) => const CreatePollSheet(),
                            );
                        if (poll != null) {
                          setState(() {
                            _createdPoll = poll;
                          });
                          _validatePostEnabled();
                        }
                      },
              ),
          ],
        ),
      ),
    );
  }
}

class _VideoPreviewItem extends StatefulWidget {
  final String path;
  const _VideoPreviewItem({required this.path});

  @override
  State<_VideoPreviewItem> createState() => _VideoPreviewItemState();
}

class _VideoPreviewItemState extends State<_VideoPreviewItem> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    final isNetwork = widget.path.startsWith('http');
    _controller = isNetwork
        ? VideoPlayerController.networkUrl(Uri.parse(widget.path))
        : VideoPlayerController.file(File(widget.path));

    _controller!.initialize().then((_) {
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    }).catchError((_) {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _controller == null) {
      return Container(
        color: AppColors.background,
        child: const Center(
          child: CircularProgressIndicator.adaptive(),
        ),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            clipBehavior: Clip.hardEdge,
            child: SizedBox(
              width: _controller!.value.size.width,
              height: _controller!.value.size.height,
              child: VideoPlayer(_controller!),
            ),
          ),
        ),
        Icon(
          Icons.play_circle_fill,
          color: AppColors.white.withValues(alpha: 0.8),
          size: 28.r,
        ),
      ],
    );
  }
}
