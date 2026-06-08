part of 'location_bloc.dart';

abstract class LocationEvent {}

class FetchCountries extends LocationEvent {}

class FetchStates extends LocationEvent {
  FetchStates();
}

class FetchCities extends LocationEvent {
  final String stateName;
  FetchCities({required this.stateName});
}

class SearchLocalities extends LocationEvent {
  final String input;
  final String? city;
  final String? stateName;
  final int page;
  final int limit;

  SearchLocalities({
    required this.input,
    this.city,
    this.stateName,
    this.page = -1,
    this.limit = 20,
  });
}
