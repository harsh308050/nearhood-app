import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearhood/core/theme/app_colors.dart';
import 'package:nearhood/features/location_selection/bloc/location_bloc.dart';
import 'package:nearhood/features/location_selection/model/location_models.dart';
import 'package:nearhood/features/location_selection/helper/location_search_bottom_sheet.dart';

Future<LocationModel?> showLocationSearchBottomSheet(
  BuildContext context, {
  required LocationBloc bloc,
  required String title,
  required String hint,
  bool isLocality = false,
  String? countryCode,
  String? stateName,
  String? city,
}) {
  return showModalBottomSheet<LocationModel?>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.transparent,
    builder: (ctx) => BlocProvider.value(
      value: bloc,
      child: LocationSearchBottomSheet(
        title: title,
        hint: hint,
        isLocality: isLocality,
        countryCode: countryCode,
        stateName: stateName,
        city: city,
      ),
    ),
  );
}
