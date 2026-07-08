import 'package:equatable/equatable.dart';

abstract class MarketplaceEvent extends Equatable {
  const MarketplaceEvent();

  @override
  List<Object?> get props => [];
}

class FetchMarketplaceRequested extends MarketplaceEvent {
  final double lat;
  final double lng;
  final String mode; // 'myarea' | 'nearby' | 'city'
  final String? type; // 'product' | 'service'
  final String? category;
  final bool refresh;

  const FetchMarketplaceRequested({
    required this.lat,
    required this.lng,
    required this.mode,
    this.type,
    this.category,
    this.refresh = false,
  });

  @override
  List<Object?> get props => [lat, lng, mode, type, category, refresh];
}

class LoadMoreMarketplaceRequested extends MarketplaceEvent {
  final double lat;
  final double lng;
  final String mode;
  final String? type;
  final String? category;

  const LoadMoreMarketplaceRequested({
    required this.lat,
    required this.lng,
    required this.mode,
    this.type,
    this.category,
  });

  @override
  List<Object?> get props => [lat, lng, mode, type, category];
}
