import 'package:nearhood/core/utils/custom_import.dart';
import 'package:nearhood/features/auth/model/auth_response_models.dart';
import 'package:nearhood/features/getstarted/getstarted_screen.dart';
import 'package:nearhood/features/home/home_screen.dart';
import 'package:nearhood/features/location_selection/screeens/location_selection_screen.dart';
import 'package:nearhood/features/location_selection/screeens/address_details_screen.dart';
import 'package:nearhood/features/auth/screens/auth_phone/mobile_number_screen.dart';
import 'package:nearhood/features/community_rules/community_rules_screen.dart';

void routeUserBasedOnProfile(BuildContext context, UserProfile profile) {
  final currentStep = profile.onboarding?.currentStep ?? 1;
  final isComplete = profile.onboarding?.isComplete ?? false;

  if (isComplete) {
    callNextScreenAndClearStack(context, const HomeScreen());
    return;
  }

  switch (currentStep) {
    case 1:
      callNextScreenAndClearStack(context, const LocationSelectionScreen());
      break;
    case 2:
      callNextScreenAndClearStack(
        context,
        LocationSelectionScreen(prefilledProfile: profile),
        transitionType: PageTransitionType.none,
      );
      callNextScreen(
        context,
        AddressDetailsScreen(
          locationName: profile.location?.locality?.name ?? '',
          subLocation: profile.location?.city?.name ?? '',
          pincode: profile.location?.pinCode,
        ),
      );
      break;
    case 3:
      callNextScreenAndClearStack(context, const MobileNumberScreen());
      break;
    case 4:
      callNextScreenAndClearStack(context, const CommunityRulesScreen());
      break;
    default:
      callNextScreenAndClearStack(context, const GetstartedScreen());
  }
}
