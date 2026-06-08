import 'package:firebase_auth/firebase_auth.dart';
import 'package:nearhood/core/constants/shared_pref_keys.dart';
import 'package:nearhood/core/utils/custom_import.dart';
import 'package:nearhood/core/utils/shared_pref_helper.dart';
import 'package:nearhood/features/getstarted/getstarted_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomText(
                  AppStrings.appName,
                  style: AppTypography.heroTitle.copyWith(
                    color: AppColors.primaryBlue,
                  ),
                ),
                sh(10),
                CustomButton(
                  text: "Logout",
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    await sharedPrefsaveData(SharedPrefKeys.userDataKey, null);
                    if (mounted) {
                      callNextScreenAndClearStack(
                        context,
                        const GetstartedScreen(),
                        transitionType: PageTransitionType.fade,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
