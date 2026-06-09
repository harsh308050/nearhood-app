class AppStrings {
  AppStrings._();

  //FontNames
  static const String satoshi = 'Satoshi';
  static const String clashDisplay = 'ClashDisplay';

  // GetStarted
  static const String appName = 'Nearhood';
  static const String tagline = 'Your Neighborhood, Verified.';
  static const String connectWithNeighbors = 'Discover Your Neighborhood with';
  static const String continueWithGoogle = 'Continue with Google';
  static const String continueWithEmail = 'Continue with email';
  static const String continueOnboarding = 'Continue Onboarding?';
  static const String useDifferentAccount = 'Use Different Account';

  // Get Started Screen Specific
  static const String discoverYourNeighborhoodWith =
      'Discover your\nneighborhood\nwith ';
  static const String agreeToPrivacyPrefix =
      'By continuing with nearhood sign up, you agree to our\n';
  static const String privacyPolicy = 'Privacy Policy';
  static const String cookiePolicy = 'Cookie Policy';
  static const String termsOfService = 'Terms of Service';
  static const String and = ' and ';
  static const String commaSpace = ', ';
  static const String period = '.';
  static const String astrick = '*';

  // Forms & Auth
  static const String fullNameLabel = 'Full name';
  static const String emailAddressLabel = 'Email address';
  static const String passwordLabel = 'Password';

  // Mobile Number & OTP Screens Specific
  static const String verifyYourNumber = 'Verify your number';
  static const String weWillSendOtp =
      "We'll send a 6-digit OTP to confirm it's you";
  static const String mobileNumber = 'Mobile number';
  static const String mobileNumberPlaceholder = '98765 43210';
  static const String oneNumberOneAccount =
      'One number = one account. Prevents fake profiles.';
  static const String enterOtp = 'Enter OTP';
  static const String sentTo = 'Sent to ';
  static const String resendIn = 'Resend in ';
  static const String didntReceiveIt = "Didn't receive it?";
  static const String getViaCallInstead = 'Get via call instead';
  static const String mobileNumberLabel = 'Mobile number';
  static const String sendOtp = 'Send OTP';
  static const String resendOtp = 'Resend OTP';

  // Auth / Login Screen Specific
  static const String welcomeBack = 'Welcome Back!';
  static const String createAccount = 'Create Account';
  static const String namePlaceholder = 'e.g. Harsh Parmar';
  static const String emailPlaceholder = 'e.g. name@example.com';
  static const String passwordPlaceholder = '••••••••';
  static const String forgotPassword = 'Forgot Password?';
  static const String orContinueWith = 'OR CONTINUE WITH';
  static const String dontHaveAccount = "Don't have an account? ";
  static const String signUp = 'Sign up';
  static const String alreadyHaveAccount = 'Already have an account? ';

  // Community Rules Screen Specific
  static const String communityRules = 'Community Rules';
  static const String communityRulesSubtitle =
      'Please agree to our guidelines to keep Nearhood a safe and welcoming space for everyone.';
  static const String rule1Title = 'Be Helpful';
  static const String rule1Desc =
      'Share knowledge, offer assistance, and contribute positively to your neighborhood\'s well-being.';
  static const String rule2Title = 'Lead with Respect';
  static const String rule2Desc =
      'Treat everyone with kindness. Harassment, discrimination, and hate speech are strictly prohibited.';
  static const String rule3Title = 'Do Not Harm';
  static const String rule3Desc =
      'Protect the privacy and safety of others. Do not share personal information without consent.';
  static const String rule4Title = 'All Are Welcome';
  static const String rule4Desc =
      'Embrace diversity. Our community thrives when all voices and backgrounds are represented and valued.';
  static const String agreeToFollowRules = 'I agree to follow these rules';
  static const String accountSuspensionWarning =
      'I understand that violating these guidelines may result in account suspension.';
  static const String joinNearhood = 'Join Nearhood';

  //Location Selection Screen Specific
  static const String whereDoYouLive = 'Where Do you Live?';
  static const String connectToNeibours =
      "We\'ll connect you with verified neighbors nearby";

  static const String localityArea = 'Your locality or area';
  static const String selectYourArea = 'Select your area';
  static const String localityAreaPlaceholder =
      'e.g., Bopal, Koramangala, 380058';
  static const String country = 'Country';
  static const String selectCountry = 'Select your country';
  static const String selectCountryPlaceholder = 'Search country...';
  static const String searchLocalityPlaceholder = 'Search localities...';
  static const String searchPlaceholder = 'Search...';

  // Address Details Screen Specific
  static const String yourAddressDetails = 'Your address details';
  static const String addressDetailsSubtitle =
      'We need this to connect you with neighbors.';
  static const String pinCode = 'PIN Code';
  static const String flatBuildingName = 'Flat / Building Name';
  static const String flatBuildingNamePlaceholder =
      'e.g. A-401, Skyline Apartments';
  static const String streetLandmark = 'Street / Landmark';
  static const String streetLandmarkPlaceholder = 'e.g. Near City Center Mall';
  static const String addressPrivacyNote =
      'Your exact house number is kept private and will never be shared publicly on Nearhood.';
  static const String pincodeIncorrectNote =
      'If the PIN code is incorrect, please go back and search for your area again (you can also search by PIN code).';

  // Actions
  static const String continueButton = 'Continue';
  static const String skipForNow = 'Skip for now';
  static const String login = 'Login';
  static const String typeHere = "Type here...";
  static const String currentLocation = "Current Location";

  //Validation
  static const String emailValidation = 'Please enter a valid email';
  static const String passwordLengthValidation =
      'Password must be at least 6 characters';
  static const String emailRequired = "Email is Required";
  static const String passwordRequired = 'Password is required';
  static const String pleaseEnterLocality = 'Please enter your locality';
  static const String pincodeRequired = 'PIN code is required';
  static const String flatBuildingRequired = 'Flat / Building name is required';
  static const String invalidOtp = 'Invalid OTP. Please try again.';
  static const String fieldRequired = 'This field is required';
  static const String emailRegex =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';

  //Messages
  static const String noResultFound = "No results found";
  static const String noAreasFound = "No areas found";
  static const String tryDiffSearch = "Try a different search term";
  static const String useCurrentLocation = "Use your current location";
  static const String detectLocationAutomatic =
      "We\'ll detect your area automatically";

  // Error Messages
  static const String defaultError = 'Something went wrong. Please try again.';
  static const String googleSignInFailed =
      'Google Sign-In was cancelled or failed. Please try again.';
  static const String credentialExpired =
      'Your session has expired. Please log in again.';
  static const String networkError =
      'Network error. Please check your internet connection.';
  static const String invalidCredentials =
      'Invalid email or password. Please try again.';
  static const String userNotFound = 'No account found with this email.';
  static const String emailAlreadyInUse =
      'An account already exists with this email.';
}
