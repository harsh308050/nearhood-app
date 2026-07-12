import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearhood/core/network/api_call_state.dart';
import 'package:nearhood/core/utils/custom_import.dart';
import 'package:nearhood/features/market/bloc/marketplace_bloc.dart';
import 'package:nearhood/features/market/bloc/marketplace_event.dart';
import 'package:nearhood/features/market/bloc/marketplace_state.dart';
import 'package:nearhood/features/business/models/business_models.dart';
import 'package:nearhood/common_widget/listing_card_widget.dart';

class MarketScreen extends StatelessWidget {
  const MarketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MarketplaceBloc(),
      child: const _MarketScreenBody(),
    );
  }
}

class _MarketScreenBody extends StatefulWidget {
  const _MarketScreenBody();

  @override
  State<_MarketScreenBody> createState() => _MarketScreenBodyState();
}

class _MarketScreenBodyState extends State<_MarketScreenBody> {
  String _selectedType = 'product'; // 'product' | 'service'
  String _searchQuery = '';
  Timer? _searchDebounce;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetch());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  void _fetch() {
    context.read<MarketplaceBloc>().add(FetchMarketplaceRequested(
      type: _selectedType,
      search: _searchQuery.trim().isEmpty ? null : _searchQuery.trim(),
    ));
  }

  void _onScroll() {
    if (_scrollController.position.pixels < _scrollController.position.maxScrollExtent - 200) return;
    final state = context.read<MarketplaceBloc>().state;
    if (state.hasReachedMax || state.status == ApiCallState.busy) return;
    context.read<MarketplaceBloc>().add(LoadMoreMarketplaceRequested(
      type: _selectedType,
      search: _searchQuery.trim().isEmpty ? null : _searchQuery.trim(),
    ));
  }

  void _onSearchChanged(String query) {
    if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchQuery = query;
      });
      _fetch();
    });
  }

  String _formatPrice(MarketplaceListing item) {
    final l = item.listing;
    if (l.priceType == 'contact') return 'Contact for price';
    if (l.priceType == 'range') {
      final min = l.priceMin != null ? '₹${l.priceMin!.toStringAsFixed(0)}' : '';
      final max = l.priceMax != null ? '₹${l.priceMax!.toStringAsFixed(0)}' : '';
      if (min.isNotEmpty && max.isNotEmpty) return '$min – $max';
      return min.isNotEmpty ? 'From $min' : 'Up to $max';
    }
    if (l.price != null) {
      final unit = l.priceUnit != null ? ' / ${l.priceUnit!.replaceAll('per_', '')}' : '';
      return '₹${l.price!.toStringAsFixed(0)}$unit';
    }
    return '';
  }

  String _distanceText(MarketplaceListing item) {
    final d = item.distance;
    if (d == null) return '';
    if (d < 1000) return '${d.round()}m away';
    return '${(d / 1000).toStringAsFixed(1)} km';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CommonAppBar(
        title: AppStrings.marketplace,
        showBackButton: false,
        showHorizontalMenu: true,
        horizontalMenuIcon: Icon(
          Icons.filter_alt_outlined,
          color: AppColors.darkGrey,
          size: 22.r,
        ),
        onHorizontalMenuPressed: () {
          // Handle filters click
        },
      ),
      body: Column(
        children: [
          sh(12),
          // Search Bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: CustomTextField(
              hint: 'Search products & services...',
              prefixIcon: Icons.search,
              onChanged: _onSearchChanged,
            ),
          ),
          sh(12),
          // Products / Services toggle
          _buildTypeToggle(),
          sh(12),
          // Grid content
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildTypeToggle() {
    final cellWidth = (MediaQuery.of(context).size.width - 48.w - 2) / 2;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Container(
        height: 36.h,
        decoration: BoxDecoration(
          color: AppColors.borderLight.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(100.r),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOutCubic,
              left: (_selectedType == 'service' ? 1 : 0) * cellWidth + 2.r,
              top: 2.r,
              bottom: 2.r,
              width: cellWidth - 4.r,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(100.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.darkGrey.withValues(alpha: 0.08),
                      blurRadius: 4.r,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      if (_selectedType != 'product') {
                        setState(() {
                          _selectedType = 'product';
                        });
                        _fetch();
                      }
                    },
                    borderRadius: BorderRadius.circular(100.r),
                    child: Center(
                      child: CustomText(
                        'Products',
                        style: AppTypography.bodyText.copyWith(
                          fontSize: 13.sp,
                          fontWeight: _selectedType == 'product'
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: _selectedType == 'product'
                              ? AppColors.primaryBlue
                              : AppColors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      if (_selectedType != 'service') {
                        setState(() {
                          _selectedType = 'service';
                        });
                        _fetch();
                      }
                    },
                    borderRadius: BorderRadius.circular(100.r),
                    child: Center(
                      child: CustomText(
                        'Services',
                        style: AppTypography.bodyText.copyWith(
                          fontSize: 13.sp,
                          fontWeight: _selectedType == 'service'
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: _selectedType == 'service'
                              ? AppColors.primaryBlue
                              : AppColors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return BlocBuilder<MarketplaceBloc, MarketplaceState>(
      builder: (context, state) {
        if (state.status == ApiCallState.busy && state.listings.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue));
        }
        if (state.status == ApiCallState.failure && state.listings.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(32.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomImageView(
                    imagePath: AppAssets.icWarning,
                    height: 48.r,
                    width: 48.r,
                    color: AppColors.grey,
                  ),
                  sh(12),
                  CustomText(
                    state.errorMessage ?? 'Something went wrong',
                    style: AppTypography.bodyText.copyWith(color: AppColors.grey),
                    textAlign: TextAlign.center,
                  ),
                  sh(16),
                  TextButton(
                    onPressed: _fetch,
                    child: const CustomText('Retry'),
                  ),
                ],
              ),
            ),
          );
        }
        if (state.listings.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(32.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomImageView(
                    imagePath: AppAssets.icMarket,
                    color: AppColors.placeholderText,
                    height: 56.r,
                    width: 56.r,
                  ),
                  sh(16),
                  CustomText(
                    'No listings yet',
                    style: AppTypography.cardTitle.copyWith(
                      fontSize: 16.sp,
                      color: AppColors.darkGrey,
                    ),
                  ),
                  sh(8),
                  CustomText(
                    'Check back soon for products and services in your area.',
                    style: AppTypography.bodyText.copyWith(color: AppColors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }
        return GridView.builder(
          controller: _scrollController,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12.h,
            crossAxisSpacing: 12.w,
            childAspectRatio: 0.72,
          ),
          itemCount: state.listings.length + (state.hasReachedMax ? 0 : 1),
          itemBuilder: (context, index) {
            if (index == state.listings.length) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: const CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryBlue),
                ),
              );
            }
            final item = state.listings[index];
            final listing = item.listing;
            return ListingCardWidget(
              imageUrl: listing.mediaUrls.isNotEmpty ? listing.mediaUrls.first : '',
              price: _formatPrice(item),
              isFree: listing.price == 0,
              title: listing.title,
              distance: _distanceText(item),
              category: listing.category,
              condition: _selectedType == 'product' ? listing.condition : null,
              serviceArea: _selectedType == 'service' ? listing.serviceArea : null,
              isMyBusiness: false,
              isFavorite: false,
              onFavoriteTap: () {
                // Mock favorite tap
              },
              onTap: () {
                // Navigate to details if needed
              },
            );
          },
        );
      },
    );
  }
}
