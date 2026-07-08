import 'package:nearhood/core/network/api_call_state.dart';
import 'package:nearhood/features/business/models/business_models.dart';

class MarketplaceState {
  final ApiCallState status;
  final List<MarketplaceListing> listings;
  final String mode;
  final String? type;
  final String? category;
  final int page;
  final int totalCount;
  final bool hasReachedMax;
  final String? errorMessage;

  const MarketplaceState({
    this.status = ApiCallState.none,
    this.listings = const [],
    this.mode = 'myarea',
    this.type,
    this.category,
    this.page = 1,
    this.totalCount = 0,
    this.hasReachedMax = false,
    this.errorMessage,
  });

  MarketplaceState copyWith({
    ApiCallState? status,
    List<MarketplaceListing>? listings,
    String? mode,
    String? type,
    String? category,
    int? page,
    int? totalCount,
    bool? hasReachedMax,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MarketplaceState(
      status: status ?? this.status,
      listings: listings ?? this.listings,
      mode: mode ?? this.mode,
      type: type ?? this.type,
      category: category ?? this.category,
      page: page ?? this.page,
      totalCount: totalCount ?? this.totalCount,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      errorMessage:
          clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
