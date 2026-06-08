import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearhood/features/location_selection/data/location_datasource.dart';
import 'package:nearhood/features/location_selection/model/location_models.dart';

part 'location_event.dart';
part 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final LocationRemoteDataSource dataSource;

  // Cache tracking variables
  String? _lastFetchedStateNameForCities;
  String? _lastFetchedCityForLocalities;
  String? _lastFetchedInputForLocalities;

  LocationBloc({required this.dataSource}) : super(const LocationState()) {
    on<FetchCountries>(_onFetchCountries);
    on<FetchStates>(_onFetchStates);
    on<FetchCities>(_onFetchCities);
    on<SearchLocalities>(_onSearchLocalities);
  }

  Future<void> _onFetchCountries(
    FetchCountries event,
    Emitter<LocationState> emit,
  ) async {
    if (state.countries.isNotEmpty) {
      emit(state.copyWith(status: LocationStatus.success));
      return;
    }
    emit(state.copyWith(status: LocationStatus.loading));
    try {
      final items = await dataSource.getCountries();
      emit(state.copyWith(status: LocationStatus.success, countries: items));
    } catch (e) {
      emit(
        state.copyWith(
          status: LocationStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onFetchStates(
    FetchStates event,
    Emitter<LocationState> emit,
  ) async {
    if (state.states.isNotEmpty) {
      emit(state.copyWith(status: LocationStatus.success));
      return;
    }
    emit(state.copyWith(status: LocationStatus.loading));
    try {
      final items = await dataSource.getStates();
      emit(state.copyWith(status: LocationStatus.success, states: items));
    } catch (e) {
      emit(
        state.copyWith(
          status: LocationStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onFetchCities(
    FetchCities event,
    Emitter<LocationState> emit,
  ) async {
    if (state.cities.isNotEmpty &&
        _lastFetchedStateNameForCities == event.stateName) {
      emit(state.copyWith(status: LocationStatus.success));
      return;
    }
    emit(state.copyWith(status: LocationStatus.loading));
    try {
      final items = await dataSource.getCities(stateName: event.stateName);
      _lastFetchedStateNameForCities = event.stateName;
      emit(state.copyWith(status: LocationStatus.success, cities: items));
    } catch (e) {
      emit(
        state.copyWith(
          status: LocationStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onSearchLocalities(
    SearchLocalities event,
    Emitter<LocationState> emit,
  ) async {
    // We only skip if page == 1 and we already have it. If page > 1, we want to fetch and append.
    if ((event.page == 1 || event.page == -1) &&
        state.localities.isNotEmpty &&
        _lastFetchedCityForLocalities == event.city &&
        _lastFetchedInputForLocalities == event.input) {
      emit(state.copyWith(status: LocationStatus.success));
      return;
    }

    // Only show loading if it's the first page or full search, not for pagination
    if (event.page <= 1) {
      emit(state.copyWith(status: LocationStatus.loading));
    }

    try {
      final items = await dataSource.searchLocalities(
        input: event.input,
        city: event.city,
        stateName: event.stateName,
        page: event.page,
        limit: event.limit,
      );
      _lastFetchedCityForLocalities = event.city;
      _lastFetchedInputForLocalities = event.input;

      final updatedLocalities = event.page > 1
          ? [...state.localities, ...items]
          : items;

      emit(
        state.copyWith(
          status: LocationStatus.success,
          localities: updatedLocalities,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: LocationStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
