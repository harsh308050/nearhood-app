import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearhood/core/utils/custom_import.dart';
import 'package:nearhood/features/location_selection/bloc/location_bloc.dart';
import 'package:nearhood/features/location_selection/model/location_models.dart';

class LocationSearchBottomSheet extends StatefulWidget {
  final String title;
  final String hint;
  final bool isLocality;
  final String? countryCode;
  final String? stateName;
  final String? city;

  const LocationSearchBottomSheet({
    super.key,
    required this.title,
    required this.hint,
    this.isLocality = false,
    this.countryCode,
    this.stateName,
    this.city,
  });

  @override
  State<LocationSearchBottomSheet> createState() =>
      _LocationSearchBottomSheetState();
}

class _LocationSearchBottomSheetState extends State<LocationSearchBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<LocationModel> _filteredItems = [];
  List<LocationModel> _allItems = [];
  Timer? _debounce;

  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Load initial data based on type
    if (!widget.isLocality) {
      if (widget.stateName != null) {
        context.read<LocationBloc>().add(
          FetchCities(stateName: widget.stateName!),
        );
      } else if (widget.countryCode != null) {
        context.read<LocationBloc>().add(FetchStates());
      } else {
        context.read<LocationBloc>().add(FetchCountries());
      }
    } else {
      // Localities can be fetched initially using the city name without an input
      if (widget.city != null && widget.city!.isNotEmpty) {
        _currentPage = 1;
        context.read<LocationBloc>().add(
          SearchLocalities(
            input: '',
            city: widget.city,
            stateName: widget.stateName,
            page: _currentPage,
          ),
        );
      }
    }
  }

  void _onScroll() {
    if (!widget.isLocality) return;
    if (_searchController.text.isNotEmpty)
      return; // Don't paginate when searching

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore) {
        _isLoadingMore = true;
        _currentPage++;
        context.read<LocationBloc>().add(
          SearchLocalities(
            input: '',
            city: widget.city,
            stateName: widget.stateName,
            page: _currentPage,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (widget.isLocality) {
        if (query.isEmpty) {
          _currentPage = 1;
          context.read<LocationBloc>().add(
            SearchLocalities(
              input: '',
              city: widget.city,
              stateName: widget.stateName,
              page: 1,
            ),
          );
        } else {
          context.read<LocationBloc>().add(
            SearchLocalities(
              input: query,
              city: widget.city,
              stateName: widget.stateName,
              page: -1,
            ),
          );
        }
      } else {
        setState(() {
          if (query.isEmpty) {
            _filteredItems = _allItems;
          } else {
            _filteredItems = _allItems
                .where(
                  (item) =>
                      item.name!.toLowerCase().contains(query.toLowerCase()),
                )
                .toList();
          }
        });
      }
    });
  }

  void _onItemSelected(LocationModel item) {
    Navigator.pop(context, item);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LocationBloc, LocationState>(
      listener: (context, state) {
        if (state.status == LocationStatus.success) {
          _isLoadingMore = false;
          setState(() {
            if (widget.isLocality) {
              _allItems = state.localities;
              _filteredItems = _allItems;
            } else {
              if (widget.stateName != null) {
                _allItems = state.cities;
              } else if (widget.countryCode != null) {
                _allItems = state.states;
              } else {
                _allItems = state.countries;
              }
              // Local filtering for non-locality items
              if (_searchController.text.isEmpty) {
                _filteredItems = _allItems;
              } else {
                _filteredItems = _allItems
                    .where(
                      (item) => item.name!.toLowerCase().contains(
                        _searchController.text.toLowerCase(),
                      ),
                    )
                    .toList();
              }
            }
          });
        }
      },
      builder: (context, state) {
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
              _buildHandleBar(),
              _buildTopBar(),
              _buildSearchBar(),
              Container(height: 1.h, color: AppColors.borderLight),
              Expanded(
                child: state.status == LocationStatus.loading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredItems.isEmpty
                    ? _buildEmptyState()
                    : _buildItemsList(),
              ),
            ],
          ),
        );
      },
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
                widget.title,
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
        hint: widget.hint,
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
            : null,
        onChanged: _onSearchChanged,
        autofocus: false,
        backgroundColor: AppColors.background,
        focusedBorderColor: AppColors.primaryBlue,
        variant: CustomTextFieldVariant.outlined,
      ),
    );
  }

  Widget _buildItemsList() {
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.zero,
      itemCount: _filteredItems.length,
      itemBuilder: (context, index) {
        final item = _filteredItems[index];
        return InkWell(
          onTap: () => _onItemSelected(item),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.borderLight, width: 1.h),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40.r,
                  height: 40.r,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: item.flag != null
                        ? EdgeInsets.zero
                        : EdgeInsets.all(10.r),
                    child: item.flag != null
                        ? Center(child: CustomText(item.flag!, fontSize: 24.sp))
                        : CustomImageView(
                            imagePath: AppAssets.icLocation,
                            color: AppColors.darkGrey,
                          ),
                  ),
                ),
                sw(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        item.name ?? '',
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.darkGrey,
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
    if (widget.isLocality &&
        _searchController.text.isEmpty &&
        _filteredItems.isEmpty) {
      return EmptyStateWidget(
        title: 'Search for Locality/Area',
        subtitle: 'Type the name of your area to search',
        showButton: false,
      );
    }

    return EmptyStateWidget(
      title: AppStrings.noAreasFound,
      subtitle: AppStrings.tryDiffSearch,
      showButton: false,
    );
  }
}
