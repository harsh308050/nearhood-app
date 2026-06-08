part of 'location_bloc.dart';

enum LocationStatus { initial, loading, success, failure }

class LocationState {
  final LocationStatus status;
  final List<LocationModel> countries;
  final List<LocationModel> states;
  final List<LocationModel> cities;
  final List<LocationModel> localities;
  final String? errorMessage;

  const LocationState({
    this.status = LocationStatus.initial,
    this.countries = const [],
    this.states = const [],
    this.cities = const [],
    this.localities = const [],
    this.errorMessage,
  });

  LocationState copyWith({
    LocationStatus? status,
    List<LocationModel>? countries,
    List<LocationModel>? states,
    List<LocationModel>? cities,
    List<LocationModel>? localities,
    String? errorMessage,
  }) {
    return LocationState(
      status: status ?? this.status,
      countries: countries ?? this.countries,
      states: states ?? this.states,
      cities: cities ?? this.cities,
      localities: localities ?? this.localities,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
