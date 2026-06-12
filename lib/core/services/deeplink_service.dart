import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nearhood/core/utils/shared_pref_helper.dart';
import 'package:nearhood/core/utils/custom_import.dart';
import 'package:nearhood/features/home/home_screen.dart';
import 'package:nearhood/features/post/screens/post_detail_screen.dart';
import 'package:nearhood/features/getstarted/getstarted_screen.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  static String? pendingPostId;
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  void init() {
    // Handle cold start (app launched from link)
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) {
        _handleDeepLink(uri);
      }
    });

    // Handle warm starts (app in background/foreground)
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    });
  }

  void dispose() {
    _linkSubscription?.cancel();
  }

  void _handleDeepLink(Uri uri) {
    // Parse the post ID from the URI
    // Format: https://nearhood-api.onrender.com/share/posts/<postId>
    final pathSegments = uri.pathSegments;
    if (uri.host == 'nearhood-api.onrender.com' &&
        pathSegments.length >= 3 &&
        pathSegments[0] == 'share' &&
        pathSegments[1] == 'posts') {
      final postId = pathSegments[2];
      _navigateToPost(postId);
    }
  }

  void _navigateToPost(String postId) {
    // Check if user is logged in and onboarding is complete
    final user = FirebaseAuth.instance.currentUser;
    final cachedProfile = sharedPrefGetUser();
    final isLoggedIn =
        user != null &&
        cachedProfile != null &&
        cachedProfile.firebaseUid == user.uid &&
        (cachedProfile.onboarding?.isComplete ?? false);

    if (isLoggedIn) {
      final navigator = navigatorKey.currentState;
      if (navigator != null) {
        // Clear stack, push HomeScreen, and then push PostDetailScreen on top.
        // This keeps HomeScreen at the bottom of the stack for back navigation.
        navigator.pushAndRemoveUntil(
          CustomPageRoute(
            page: const HomeScreen(),
            transitionType: PageTransitionType.none,
          ),
          (_) => false,
        );
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!navigator.mounted) return;
          navigator.push(
            CustomPageRoute(page: PostDetailScreen(postId: postId)),
          );
        });
      } else {
        pendingPostId = postId;
      }
    } else {
      pendingPostId = postId;
      final navigator = navigatorKey.currentState;
      if (navigator != null) {
        callNextScreenAndClearStack(navigator.context, const GetstartedScreen());
      }
    }
  }
}
