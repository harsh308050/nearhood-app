import 'package:equatable/equatable.dart';

abstract class MarketplaceEvent extends Equatable {
  const MarketplaceEvent();

  @override
  List<Object?> get props => [];
}

class FetchMarketplaceRequested extends MarketplaceEvent {
  final String? type; // 'product' | 'service'
  final String? category;
  final String? search;
  final bool refresh;

  const FetchMarketplaceRequested({
    this.type,
    this.category,
    this.search,
    this.refresh = false,
  });

  @override
  List<Object?> get props => [type, category, search, refresh];
}

class LoadMoreMarketplaceRequested extends MarketplaceEvent {
  final String? type;
  final String? category;
  final String? search;

  const LoadMoreMarketplaceRequested({
    this.type,
    this.category,
    this.search,
  });

  @override
  List<Object?> get props => [type, category, search];
}
