import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:nearhood/core/network/api_call_state.dart';
import 'package:nearhood/core/utils/custom_import.dart';
import 'package:nearhood/features/business/bloc/business_bloc.dart';
import 'package:nearhood/features/business/bloc/business_event.dart';
import 'package:nearhood/features/business/data/business_datasource.dart';
import 'package:nearhood/features/business/models/business_models.dart';

const _conditions = ['New', 'Like New', 'Good', 'Fair'];

const _priceUnits = [
  ('per_piece', 'Per Piece'),
  ('per_kg', 'Per Kg'),
  ('per_dozen', 'Per Dozen'),
  ('per_litre', 'Per Litre'),
  ('per_set', 'Per Set'),
];

const _servicePriceTypes = [
  ('fixed', 'Fixed Price'),
  ('range', 'Price Range'),
  ('contact', 'Contact for Price'),
];

class AddEditListingScreen extends StatelessWidget {
  final String type;
  final BusinessListing? listing;
  final BusinessBloc bloc;
  const AddEditListingScreen({
    super.key,
    required this.type,
    required this.bloc,
    this.listing,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: bloc,
      child: _AddEditListingBody(type: type, listing: listing),
    );
  }
}

class _AddEditListingBody extends StatefulWidget {
  final String type;
  final BusinessListing? listing;
  const _AddEditListingBody({required this.type, this.listing});

  @override
  State<_AddEditListingBody> createState() => _AddEditListingBodyState();
}

class _AddEditListingBodyState extends State<_AddEditListingBody> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _priceMinController = TextEditingController();
  final _priceMaxController = TextEditingController();
  final _brandController = TextEditingController();
  final _quantityController = TextEditingController();
  final _durationController = TextEditingController();
  final _picker = ImagePicker();

  String? _selectedCategory;
  String? _selectedCondition;
  String? _selectedPriceUnit;
  String _priceType = 'fixed';
  String? _selectedServiceArea;
  bool _isAvailable = true;
  List<_MediaItem> _mediaItems = [];
  bool _isSubmitting = false;

  bool get _isEditing => widget.listing != null;
  bool get _isProduct => widget.type == 'product';

  String get _appBarTitle {
    final prefix = _isEditing ? 'Edit' : 'Add';
    final suffix = _isProduct ? 'Product' : 'Service';
    return '$prefix $suffix';
  }

  @override
  void initState() {
    super.initState();
    if (_isEditing) _prefillFromListing();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bloc = context.read<BusinessBloc>();
      if (bloc.state.productCategories.isEmpty &&
          bloc.state.serviceCategories.isEmpty) {
        bloc.add(FetchListingCategories());
      }
    });
  }

  void _prefillFromListing() {
    final l = widget.listing!;
    _titleController.text = l.title;
    _descController.text = l.description ?? '';
    _selectedCategory = l.category;
    _isAvailable = l.isAvailable;
    _mediaItems = l.mediaUrls
        .map((url) => _MediaItem(url: url, isNetwork: true))
        .toList();

    if (_isProduct) {
      _selectedCondition = l.condition;
      _selectedPriceUnit = l.priceUnit;
      _brandController.text = l.brand ?? '';
      if (l.quantityAvailable != null) {
        _quantityController.text = l.quantityAvailable.toString();
      }
      if (l.price != null) _priceController.text = l.price!.toStringAsFixed(0);
      _priceType = l.priceType ?? 'fixed';
    } else {
      _selectedServiceArea = l.serviceArea;
      _durationController.text = l.duration ?? '';
      _priceType = l.priceType ?? 'fixed';
      if (l.price != null) _priceController.text = l.price!.toStringAsFixed(0);
      if (l.priceMin != null)
        _priceMinController.text = l.priceMin!.toStringAsFixed(0);
      if (l.priceMax != null)
        _priceMaxController.text = l.priceMax!.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _priceMinController.dispose();
    _priceMaxController.dispose();
    _brandController.dispose();
    _quantityController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  // ─── Image picking ──────────────────────────────────────────────────────────

  int get _maxPhotos => 5;

  Future<void> _pickImage() async {
    if (_mediaItems.length >= _maxPhotos) {
      AppSnackBar.showMessage(
        context,
        'Max $_maxPhotos images allowed.',
        borderColor: AppColors.red,
      );
      return;
    }
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
              sh(16),
              ListTile(
                leading: CustomImageView(
                  imagePath: AppAssets.icCamera,
                  color: AppColors.primaryBlue,
                  height: 20.r,
                  width: 20.r,
                ),
                title: const CustomText(AppStrings.businessTakePhoto),
                onTap: () async {
                  Navigator.pop(ctx);
                  final photo = await _picker.pickImage(
                    source: ImageSource.camera,
                    maxWidth: 800,
                    maxHeight: 800,
                    imageQuality: 85,
                  );
                  if (photo != null)
                    setState(
                      () => _mediaItems.add(
                        _MediaItem(path: photo.path, isNetwork: false),
                      ),
                    );
                },
              ),
              ListTile(
                leading: CustomImageView(
                  imagePath: AppAssets.icGallery,
                  color: AppColors.primaryBlue,
                  height: 20.r,
                  width: 20.r,
                ),
                title: const CustomText(AppStrings.businessChooseFromGallery),
                onTap: () async {
                  Navigator.pop(ctx);
                  final remaining = _maxPhotos - _mediaItems.length;
                  final photos = await _picker.pickMultiImage(
                    maxWidth: 800,
                    maxHeight: 800,
                    imageQuality: 85,
                  );
                  if (photos.isNotEmpty && mounted) {
                    setState(
                      () => _mediaItems.addAll(
                        photos
                            .take(remaining)
                            .map(
                              (p) => _MediaItem(path: p.path, isNetwork: false),
                            ),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _removeImage(int index) => setState(() => _mediaItems.removeAt(index));

  // ─── Upload & Submit ────────────────────────────────────────────────────────

  Future<List<String>> _uploadLocalImages(String bizId) async {
    final urls = <String>[];
    final ds = BusinessDataSource();
    try {
      for (final item in _mediaItems) {
        if (item.isNetwork) {
          urls.add(item.url!);
        } else {
          final resp = await ds.uploadMedia(item.path!, 'media');
          if (resp.statusCode == 200 && resp.data['success'] == true) {
            urls.add(resp.data['data']['url'] as String? ?? '');
          } else {
            throw Exception('Image upload failed');
          }
        }
      }
    } finally {
      ds.dispose();
    }
    return urls.where((u) => u.isNotEmpty).toList();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    // Validate required pickers
    if (_selectedCategory == null) {
      AppSnackBar.showMessage(
        context,
        'Please select a category.',
        borderColor: AppColors.red,
      );
      return;
    }
    if (_isProduct && _selectedCondition == null) {
      AppSnackBar.showMessage(
        context,
        'Please select a condition.',
        borderColor: AppColors.red,
      );
      return;
    }
    if (!_isProduct && _selectedServiceArea == null) {
      AppSnackBar.showMessage(
        context,
        'Please select a service area.',
        borderColor: AppColors.red,
      );
      return;
    }

    // Validate photos (min 1 for products)
    if (_isProduct && _mediaItems.isEmpty) {
      AppSnackBar.showMessage(
        context,
        'Please add at least one photo.',
        borderColor: AppColors.red,
      );
      return;
    }

    // Validate service price
    if (!_isProduct) {
      if (_priceType == 'fixed' && _priceController.text.trim().isEmpty) {
        AppSnackBar.showMessage(
          context,
          'Please enter a price.',
          borderColor: AppColors.red,
        );
        return;
      }
      if (_priceType == 'range' &&
          (_priceMinController.text.trim().isEmpty ||
              _priceMaxController.text.trim().isEmpty)) {
        AppSnackBar.showMessage(
          context,
          'Please enter both min and max price.',
          borderColor: AppColors.red,
        );
        return;
      }
    }

    setState(() => _isSubmitting = true);
    FocusScope.of(context).unfocus();

    final bloc = context.read<BusinessBloc>();
    final bizId = bloc.state.businessProfile?.id;

    try {
      final mediaUrls = await _uploadLocalImages(bizId!);

      if (_isProduct) {
        final price = double.tryParse(_priceController.text.trim());
        final qty = int.tryParse(_quantityController.text.trim());
        if (_isEditing) {
          bloc.add(
            UpdateListing(
              listingId: widget.listing!.id!,
              title: _titleController.text.trim(),
              description: _descController.text.trim().isEmpty
                  ? null
                  : _descController.text.trim(),
              mediaUrls: mediaUrls,
              price: _priceType == 'contact' ? null : price,
              priceType: _priceType,
              isAvailable: _isAvailable,
              category: _selectedCategory,
              condition: _selectedCondition,
              brand: _brandController.text.trim().isEmpty
                  ? null
                  : _brandController.text.trim(),
              priceUnit: _selectedPriceUnit,
              quantityAvailable: qty,
            ),
          );
        } else {
          bloc.add(
            AddListing(
              type: 'product',
              title: _titleController.text.trim(),
              description: _descController.text.trim().isEmpty
                  ? null
                  : _descController.text.trim(),
              mediaUrls: mediaUrls,
              price: _priceType == 'contact' ? null : price,
              priceType: _priceType,
              isAvailable: _isAvailable,
              category: _selectedCategory,
              condition: _selectedCondition,
              brand: _brandController.text.trim().isEmpty
                  ? null
                  : _brandController.text.trim(),
              priceUnit: _selectedPriceUnit,
              quantityAvailable: qty,
            ),
          );
        }
      } else {
        double? price;
        double? priceMin;
        double? priceMax;
        if (_priceType == 'fixed') {
          price = double.tryParse(_priceController.text.trim());
        } else if (_priceType == 'range') {
          priceMin = double.tryParse(_priceMinController.text.trim());
          priceMax = double.tryParse(_priceMaxController.text.trim());
        }

        if (_isEditing) {
          bloc.add(
            UpdateListing(
              listingId: widget.listing!.id!,
              title: _titleController.text.trim(),
              description: _descController.text.trim().isEmpty
                  ? null
                  : _descController.text.trim(),
              mediaUrls: mediaUrls,
              price: _priceType == 'contact' ? null : price,
              priceType: _priceType,
              priceMin: _priceType == 'range' ? priceMin : null,
              priceMax: _priceType == 'range' ? priceMax : null,
              isAvailable: _isAvailable,
              category: _selectedCategory,
              serviceArea: _selectedServiceArea,
              duration: _durationController.text.trim().isEmpty
                  ? null
                  : _durationController.text.trim(),
            ),
          );
        } else {
          bloc.add(
            AddListing(
              type: 'service',
              title: _titleController.text.trim(),
              description: _descController.text.trim().isEmpty
                  ? null
                  : _descController.text.trim(),
              mediaUrls: mediaUrls,
              price: _priceType == 'contact' ? null : price,
              priceType: _priceType,
              priceMin: _priceType == 'range' ? priceMin : null,
              priceMax: _priceType == 'range' ? priceMax : null,
              isAvailable: _isAvailable,
              category: _selectedCategory,
              serviceArea: _selectedServiceArea,
              duration: _durationController.text.trim().isEmpty
                  ? null
                  : _durationController.text.trim(),
            ),
          );
        }
      }

      await bloc.stream.firstWhere(
        (s) =>
            s.listingsStatus == ApiCallState.success ||
            s.listingsStatus == ApiCallState.failure,
      );

      if (!mounted) return;
      setState(() => _isSubmitting = false);

      if (bloc.state.listingsStatus == ApiCallState.success) {
        AppSnackBar.showMessage(
          context,
          _isEditing
              ? AppStrings.listingUpdated
              : (_isProduct
                    ? AppStrings.productAdded
                    : AppStrings.serviceAdded),
        );
        Navigator.pop(context);
      } else {
        AppSnackBar.showMessage(
          context,
          AppStrings.defaultError,
          borderColor: AppColors.red,
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      AppSnackBar.showMessage(
        context,
        'Upload failed. Please try again.',
        borderColor: AppColors.red,
      );
    }
  }

  // ─── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CommonAppBar(title: _appBarTitle, showBackButton: true),
      body: Listener(
        onPointerDown: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16.w),
                  child: _isProduct ? _buildProductForm() : _buildServiceForm(),
                ),
              ),
              _buildSubmitBar(),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Product Form ──────────────────────────────────────────────────────────

  Widget _buildProductForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitleField(),
        sh(16),
        _buildCategoryPicker(),
        sh(16),
        _buildConditionPicker(),
        sh(16),
        _buildPriceSection(),
        sh(16),
        _buildPriceUnitPicker(),
        sh(16),
        _buildOptionalField(
          label: 'Brand / Model',
          hint: 'e.g. Samsung, IKEA',
          controller: _brandController,
        ),
        sh(16),
        _buildOptionalNumberField(
          label: 'Quantity Available',
          hint: 'e.g. 10',
          controller: _quantityController,
        ),
        sh(16),
        _buildDescriptionField(),
        sh(16),
        _buildMediaSection(),
        sh(16),
        _buildAvailabilitySection(),
      ],
    );
  }

  // ─── Service Form ──────────────────────────────────────────────────────────

  Widget _buildServiceForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitleField(),
        sh(16),
        _buildCategoryPicker(),
        sh(16),
        _buildServicePriceSection(),
        sh(16),
        _buildDescriptionField(),
        sh(16),
        _buildServiceAreaPicker(),
        sh(16),
        _buildOptionalField(
          label: 'Duration',
          hint: 'e.g. 45 minutes, 2-3 hours',
          controller: _durationController,
        ),
        sh(16),
        _buildMediaSection(),
        sh(16),
        _buildAvailabilitySection(),
      ],
    );
  }

  // ─── Shared Fields ─────────────────────────────────────────────────────────

  Widget _buildTitleField() {
    return CustomTextField(
      controller: _titleController,
      label: _isProduct ? 'Product Name' : 'Service Name',
      hint: _isProduct
          ? 'e.g. Handmade Pottery Vase'
          : 'e.g. Home Plumbing Repair',
      isRequired: true,
      maxLength: 80,
      textInputAction: TextInputAction.next,
      emptyErrorMessage: AppStrings.fieldRequired,
    );
  }

  Widget _buildDescriptionField() {
    return CustomTextField.multiline(
      controller: _descController,
      label: 'Description',
      hint: 'Describe your ${_isProduct ? "product" : "service"}...',
      maxLength: 500,
      isRequired: true,
      emptyErrorMessage: AppStrings.fieldRequired,
    );
  }

  Widget _buildCategoryPicker() {
    final bloc = context.watch<BusinessBloc>();
    final categories = _isProduct
        ? bloc.state.productCategories
        : bloc.state.serviceCategories;
    final isLoading = bloc.state.categoriesStatus == ApiCallState.busy;

    return _buildTappableField(
      label: AppStrings.businessCategory,
      isRequired: true,
      value: _selectedCategory,
      hint: isLoading
          ? AppStrings.loadingCategories
          : AppStrings.selectCategory,
      onTap: () {
        if (isLoading) {
          AppSnackBar.showMessage(
            context,
            AppStrings.loadingCategoriesFromServer,
          );
          return;
        }
        if (categories.isEmpty) {
          bloc.add(FetchListingCategories());
          AppSnackBar.showMessage(context, AppStrings.fetchingCategoriesRetry);
          return;
        }
        _showCategoryPickerSheet(
          categories: categories,
          selected: _selectedCategory,
          onSelected: (v) => setState(() => _selectedCategory = v),
        );
      },
    );
  }

  Widget _buildConditionPicker() {
    return _buildTappableField(
      label: 'Condition',
      isRequired: true,
      value: _selectedCondition,
      hint: 'Select condition',
      onTap: () => _showOptionsSheet(
        title: 'Select Condition',
        options: _conditions,
        selected: _selectedCondition,
        onSelected: (v) => setState(() => _selectedCondition = v),
      ),
    );
  }

  Widget _buildPriceUnitPicker() {
    return _buildTappableField(
      label: 'Unit of Price',
      isRequired: false,
      value: _priceUnits
          .where((u) => u.$1 == _selectedPriceUnit)
          .map((u) => u.$2)
          .firstOrNull,
      hint: 'Per Piece (default)',
      onTap: () => _showOptionsSheet(
        title: 'Select Unit',
        options: _priceUnits.map((u) => u.$2).toList(),
        selected: _priceUnits
            .where((u) => u.$1 == _selectedPriceUnit)
            .map((u) => u.$2)
            .firstOrNull,
        onSelected: (v) {
          final match = _priceUnits.where((u) => u.$2 == v).firstOrNull;
          setState(() => _selectedPriceUnit = match?.$1);
        },
      ),
    );
  }

  Widget _buildServiceAreaPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          'Service Area',
          style: AppTypography.bodyText.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.grey,
            fontSize: 15.sp,
          ),
        ),
        sh(8),
        Row(
          children: [
            Expanded(
              child: _buildServiceAreaOption(
                'at_location',
                'At Your Location',
                Icons.store_outlined,
              ),
            ),
            sw(8),
            Expanded(
              child: _buildServiceAreaOption(
                'home_visit',
                'Home Visit',
                Icons.home_outlined,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildServiceAreaOption(String value, String label, IconData icon) {
    final isSelected = _selectedServiceArea == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedServiceArea = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryBlue.withValues(alpha: 0.08)
              : AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : AppColors.borderLight,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18.r,
              color: isSelected ? AppColors.primaryBlue : AppColors.grey,
            ),
            sw(6),
            CustomText(
              label,
              style: AppTypography.bodyText.copyWith(
                fontSize: 13.sp,
                color: isSelected ? AppColors.primaryBlue : AppColors.darkGrey,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Price Sections ────────────────────────────────────────────────────────

  Widget _buildPriceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          'Price',
          style: AppTypography.sectionHeader.copyWith(fontSize: 16.sp),
        ),
        sh(8),
        CustomTextField(
          controller: _priceController,
          hint: '0',
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          prefix: Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: CustomText(
              '₹',
              style: AppTypography.bodyText.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.darkGrey,
              ),
            ),
          ),
          enabled: _priceType != 'contact',
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        sh(10),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: [
            _buildPriceChip('fixed', 'Fixed'),
            _buildPriceChip('contact', 'Contact for Price'),
          ],
        ),
      ],
    );
  }

  Widget _buildServicePriceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          'Price',
          style: AppTypography.sectionHeader.copyWith(fontSize: 16.sp),
        ),
        sh(8),
        if (_priceType == 'fixed') ...[
          CustomTextField(
            controller: _priceController,
            hint: '0',
            keyboardType: TextInputType.number,
            prefix: Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: CustomText(
                '₹',
                style: AppTypography.bodyText.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkGrey,
                ),
              ),
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        ] else if (_priceType == 'range') ...[
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _priceMinController,
                  hint: 'Min',
                  keyboardType: TextInputType.number,
                  prefix: Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: CustomText(
                      '₹',
                      style: AppTypography.bodyText.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkGrey,
                      ),
                    ),
                  ),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
              sw(8),
              CustomText(
                'to',
                style: AppTypography.bodyText.copyWith(color: AppColors.grey),
              ),
              sw(8),
              Expanded(
                child: CustomTextField(
                  controller: _priceMaxController,
                  hint: 'Max',
                  keyboardType: TextInputType.number,
                  prefix: Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: CustomText(
                      '₹',
                      style: AppTypography.bodyText.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkGrey,
                      ),
                    ),
                  ),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
            ],
          ),
        ],
        if (_priceType != 'contact') ...[
          sh(10),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: _servicePriceTypes
                .map((pt) => _buildPriceChip(pt.$1, pt.$2))
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildPriceChip(String value, String label) {
    final isSelected = _priceType == value;
    return GestureDetector(
      onTap: () => setState(() => _priceType = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryBlue.withValues(alpha: 0.08)
              : AppColors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : AppColors.borderLight,
          ),
        ),
        child: CustomText(
          label,
          style: AppTypography.bodyText.copyWith(
            fontSize: 13.sp,
            color: isSelected ? AppColors.primaryBlue : AppColors.darkGrey,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  // ─── Optional Fields ───────────────────────────────────────────────────────

  Widget _buildOptionalField({
    required String label,
    required String hint,
    required TextEditingController controller,
  }) {
    return CustomTextField(
      controller: controller,
      label: label,
      hint: hint,
      maxLength: 80,
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildOptionalNumberField({
    required String label,
    required String hint,
    required TextEditingController controller,
  }) {
    return CustomTextField(
      controller: controller,
      label: label,
      hint: hint,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      textInputAction: TextInputAction.next,
    );
  }

  // ─── Media ─────────────────────────────────────────────────────────────────

  Widget _buildMediaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text.rich(
              TextSpan(
                text: 'Photos',
                style: AppTypography.bodyText.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.grey,
                  fontSize: 15.sp,
                ),
                children: _isProduct
                    ? [
                        TextSpan(
                          text: ' *',
                          style: TextStyle(
                            color: AppColors.red,
                            fontSize: 15.sp,
                          ),
                        ),
                      ]
                    : null,
              ),
            ),
            CustomText(
              '${_mediaItems.length}/$_maxPhotos',
              style: AppTypography.caption.copyWith(fontSize: 12.sp),
            ),
          ],
        ),
        sh(8),
        SizedBox(
          height: 100.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _mediaItems.length + 1,
            separatorBuilder: (_, idx) => sw(8),
            itemBuilder: (context, index) {
              if (index == _mediaItems.length) return _buildAddImageButton();
              return _buildMediaThumbnail(index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAddImageButton() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: 100.r,
        height: 100.r,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo_outlined, color: AppColors.grey, size: 24.r),
            sh(4),
            CustomText(
              'Add',
              style: AppTypography.caption.copyWith(fontSize: 11.sp),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaThumbnail(int index) {
    final item = _mediaItems[index];
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 100.r,
          height: 100.r,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.r)),
          clipBehavior: Clip.antiAlias,
          child: item.isNetwork
              ? CachedNetworkImage(
                  imageUrl: item.url!,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => _buildImagePlaceholder(),
                )
              : Image.file(
                  File(item.path!),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                ),
        ),
        Positioned(
          top: -4.h,
          right: -4.w,
          child: GestureDetector(
            onTap: () => _removeImage(index),
            child: Container(
              width: 22.r,
              height: 22.r,
              decoration: BoxDecoration(
                color: AppColors.red,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, color: AppColors.white, size: 14.r),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: AppColors.background,
      child: Center(
        child: Icon(Icons.image_outlined, color: AppColors.grey, size: 24.r),
      ),
    );
  }

  // ─── Availability ──────────────────────────────────────────────────────────

  Widget _buildAvailabilitySection() {
    return _buildCard(
      child: Row(
        children: [
          _isAvailable
              ? CustomImageView(
                  imagePath: AppAssets.icCheckRoundFilled,
                  color: AppColors.green,
                  height: 22.r,
                  width: 22.r,
                )
              : Icon(Icons.cancel_outlined, color: AppColors.grey, size: 22.r),
          sw(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  _isAvailable ? 'Available' : 'Out of Stock',
                  style: AppTypography.bodyText.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                CustomText(
                  _isAvailable
                      ? 'This listing is visible to neighbors'
                      : 'This listing is hidden from view',
                  style: AppTypography.caption.copyWith(fontSize: 11.sp),
                ),
              ],
            ),
          ),
          Switch(
            value: _isAvailable,
            onChanged: (val) => setState(() => _isAvailable = val),
            activeThumbColor: AppColors.primaryBlue,
          ),
        ],
      ),
    );
  }

  // ─── Submit Bar ────────────────────────────────────────────────────────────

  Widget _buildSubmitBar() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: CustomButton.filled(
          text: _isEditing ? 'Update Listing' : 'Add Listing',
          isLoading: _isSubmitting,
          onPressed: _submit,
          height: 52.h,
          borderRadius: 12.r,
        ),
      ),
    );
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  Widget _buildTappableField({
    required String label,
    required bool isRequired,
    required String? value,
    required String hint,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              text: label,
              style: AppTypography.bodyText.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.grey,
                fontSize: 15.sp,
              ),
              children: isRequired
                  ? [
                      TextSpan(
                        text: ' *',
                        style: TextStyle(color: AppColors.red, fontSize: 15.sp),
                      ),
                    ]
                  : null,
            ),
          ),
          sh(8),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: value != null
                    ? AppColors.primaryBlue
                    : AppColors.borderLight,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: CustomText(
                    value ?? hint,
                    style: AppTypography.bodyText.copyWith(
                      fontSize: 14.sp,
                      color: value != null
                          ? AppColors.darkGrey
                          : AppColors.grey,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right, color: AppColors.grey, size: 20.r),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCategoryPickerSheet({
    required List<ListingCategory> categories,
    required String? selected,
    required ValueChanged<String> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _CategoryPickerSheetContent(
        categories: categories,
        selected: selected,
        onSelected: onSelected,
      ),
    );
  }

  void _showOptionsSheet({
    required String title,
    required List<String> options,
    required String? selected,
    required ValueChanged<String> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.transparent,
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(ctx).size.height * 0.6,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.only(top: 12.h),
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: CustomText(
                title,
                style: AppTypography.sectionHeader.copyWith(fontSize: 18.sp),
              ),
            ),
            const Divider(height: 1, color: AppColors.borderLight),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (ctx, i) {
                  final opt = options[i];
                  final isSelected = opt == selected;
                  return ListTile(
                    title: CustomText(
                      opt,
                      style: AppTypography.bodyText.copyWith(
                        fontSize: 15.sp,
                        color: isSelected
                            ? AppColors.primaryBlue
                            : AppColors.darkGrey,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                    trailing: isSelected
                        ? CustomImageView(
                            imagePath: AppAssets.icCheckRoundFilled,
                            color: AppColors.primaryBlue,
                            height: 20.r,
                            width: 20.r,
                          )
                        : null,
                    onTap: () {
                      onSelected(opt);
                      Navigator.pop(ctx);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _MediaItem {
  final String? path;
  final String? url;
  final bool isNetwork;
  const _MediaItem({this.path, this.url, required this.isNetwork});
}

class _CategoryPickerSheetContent extends StatefulWidget {
  final List<ListingCategory> categories;
  final String? selected;
  final ValueChanged<String> onSelected;

  const _CategoryPickerSheetContent({
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  @override
  State<_CategoryPickerSheetContent> createState() =>
      _CategoryPickerSheetContentState();
}

class _CategoryPickerSheetContentState
    extends State<_CategoryPickerSheetContent> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = _searchController.text.trim().toLowerCase();
    // Filter categories based on search query
    final filteredCategories = widget.categories
        .map((cat) {
          if (searchQuery.isEmpty) return cat;

          final matchesCategory = cat.name.toLowerCase().contains(searchQuery);
          if (matchesCategory)
            return cat; // Return category with all subcategories

          final matchedSubs = cat.subcategories
              .where((sub) => sub.name.toLowerCase().contains(searchQuery))
              .toList();

          return ListingCategory(
            name: cat.name,
            slug: cat.slug,
            icon: cat.icon,
            subcategories: matchedSubs,
          );
        })
        .where((cat) => cat.subcategories.isNotEmpty)
        .toList();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            margin: EdgeInsets.only(top: 12.h),
            decoration: BoxDecoration(
              color: AppColors.borderLight,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: CustomText(
              AppStrings.businessCategory,
              style: AppTypography.sectionHeader.copyWith(fontSize: 18.sp),
            ),
          ),
          // Search Bar
          // Padding(
          //   padding: EdgeInsets.symmetric(
          //     horizontal: 16.w,
          //     vertical: 12.h,
          //   ),
          //   child: Container(
          //     decoration: BoxDecoration(
          //       color: AppColors.background,
          //       borderRadius: BorderRadius.circular(10.r),
          //       border: Border.all(color: AppColors.borderLight),
          //     ),
          //     padding: EdgeInsets.symmetric(horizontal: 12.w),
          //     child: Row(
          //       children: [
          //         Icon(Icons.search, color: AppColors.grey, size: 20.r),
          //         sw(8),
          //         Expanded(
          //           child: TextField(
          //             controller: _searchController,
          //             onChanged: (val) {
          //               setState(() {});
          //             },
          //             decoration: InputDecoration(
          //               hintText: AppStrings.searchCategoriesPlaceholder,
          //               hintStyle: TextStyle(
          //                 color: AppColors.grey,
          //                 fontSize: 14.sp,
          //               ),
          //               border: InputBorder.none,
          //               isDense: true,
          //               contentPadding: EdgeInsets.symmetric(
          //                 vertical: 10.h,
          //               ),
          //             ),
          //             style: TextStyle(
          //               fontSize: 14.sp,
          //               color: AppColors.darkGrey,
          //             ),
          //           ),
          //         ),
          //         if (_searchController.text.isNotEmpty)
          //           GestureDetector(
          //             onTap: () {
          //               _searchController.clear();
          //               setState(() {});
          //             },
          //             child: Icon(
          //               Icons.clear,
          //               color: AppColors.grey,
          //               size: 18.r,
          //             ),
          //           ),
          //       ],
          //     ),
          //   ),
          // ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: CustomTextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {});
              },
              hint: AppStrings.searchCategoriesPlaceholder,
              prefixIcon: CustomImageView(
                imagePath: AppAssets.icSearch,
                color: AppColors.grey,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        setState(() {});
                      },
                      child: CustomImageView(
                        imagePath: AppAssets.icClose,
                        width: 12.w,
                        height: 12.h,
                        color: AppColors.grey,
                      ),
                    )
                  : null,
            ),
          ),
          const Divider(height: 1, color: AppColors.borderLight),
          Expanded(
            child: filteredCategories.isEmpty
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.r),
                      child: CustomText(
                        AppStrings.noCategoriesFound,
                        style: AppTypography.bodyText.copyWith(
                          color: AppColors.grey,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredCategories.length,
                    itemBuilder: (ctx, i) {
                      final cat = filteredCategories[i];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 6.h),
                            child: CustomText(
                              cat.name,
                              style: AppTypography.bodyText.copyWith(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.grey,
                              ),
                            ),
                          ),
                          ...cat.subcategories.map((sub) {
                            final isSelected = sub.name == widget.selected;
                            return ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 24.w,
                              ),
                              title: CustomText(
                                sub.name,
                                style: AppTypography.bodyText.copyWith(
                                  fontSize: 15.sp,
                                  color: isSelected
                                      ? AppColors.primaryBlue
                                      : AppColors.darkGrey,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                              trailing: isSelected
                                  ? CustomImageView(
                                      imagePath: AppAssets.icCheckRoundFilled,
                                      color: AppColors.primaryBlue,
                                      height: 20.r,
                                      width: 20.r,
                                    )
                                  : null,
                              onTap: () {
                                widget.onSelected(sub.name);
                                Navigator.pop(ctx);
                              },
                            );
                          }),
                          const Divider(
                            height: 1,
                            color: AppColors.borderLight,
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
