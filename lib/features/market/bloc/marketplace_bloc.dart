import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearhood/core/network/api_call_state.dart';
import 'package:nearhood/features/business/data/business_datasource.dart';
import 'package:nearhood/features/business/models/business_models.dart';
import 'package:nearhood/features/market/bloc/marketplace_event.dart';
import 'package:nearhood/features/market/bloc/marketplace_state.dart';

class MarketplaceBloc extends Bloc<MarketplaceEvent, MarketplaceState> {
  final BusinessDataSource _dataSource = BusinessDataSource();

  MarketplaceBloc() : super(const MarketplaceState()) {
    on<FetchMarketplaceRequested>(_onFetch);
    on<LoadMoreMarketplaceRequested>(_onLoadMore);
  }

  Future<void> _onFetch(
    FetchMarketplaceRequested event,
    Emitter<MarketplaceState> emit,
  ) async {
    emit(state.copyWith(
      status: ApiCallState.busy,
      page: 1,
      hasReachedMax: false,
      listings: const [],
      type: event.type,
      category: event.category,
      search: event.search,
      clearError: true,
    ));
    await _fetch(emit, event.type, event.category, event.search, 1, isRefresh: true);
  }

  Future<void> _onLoadMore(
    LoadMoreMarketplaceRequested event,
    Emitter<MarketplaceState> emit,
  ) async {
    if (state.hasReachedMax || state.status == ApiCallState.busy) return;
    final nextPage = state.page + 1;
    await _fetch(emit, event.type, event.category, event.search, nextPage, isRefresh: false);
  }

  Future<void> _fetch(
    Emitter<MarketplaceState> emit,
    String? type,
    String? category,
    String? search,
    int page, {
    required bool isRefresh,
  }) async {
    try {
      final response = await _dataSource.getMarketplaceFeed(
        type: type,
        category: category,
        search: search,
        page: page,
        limit: 20,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final List<dynamic> rawList =
            (data is Map ? data['listings'] : data) as List? ?? [];
        final items = rawList
            .map((e) =>
                MarketplaceListing.fromJson(e as Map<String, dynamic>))
            .toList();

        final total = data is Map ? (data['totalCount'] as int? ?? data['pagination']?['total'] as int? ?? 0) : 0;

        final updated = isRefresh ? items : [...state.listings, ...items];
        emit(state.copyWith(
          status: ApiCallState.success,
          listings: updated,
          page: page,
          totalCount: total,
          hasReachedMax: items.isEmpty || updated.length >= total,
        ));
      } else {
        emit(state.copyWith(
          status: ApiCallState.failure,
          errorMessage:
              response.data['message']?.toString() ?? 'Failed to load',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: ApiCallState.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
