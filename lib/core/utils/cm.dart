import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:nearhood/core/theme/app_colors.dart';

/// Extension on [num] to provide responsive scaling for width, height, radius, and font size.
extension ResponsiveNum on num {
  /// Responsive width scaling relative to design baseline screen width (375.0)
  double get w {
    if (PlatformDispatcher.instance.views.isEmpty) return toDouble();
    final view = PlatformDispatcher.instance.views.first;
    final double screenWidth = view.physicalSize.width / view.devicePixelRatio;
    if (screenWidth == 0) return toDouble();
    return toDouble() * (screenWidth / 375.0);
  }

  /// Responsive height scaling relative to design baseline screen height (812.0)
  double get h {
    if (PlatformDispatcher.instance.views.isEmpty) return toDouble();
    final view = PlatformDispatcher.instance.views.first;
    final double screenHeight =
        view.physicalSize.height / view.devicePixelRatio;
    if (screenHeight == 0) return toDouble();
    return toDouble() * (screenHeight / 812.0);
  }

  /// Responsive radius/size scaling relative to screen width (375.0 baseline)
  double get r {
    if (PlatformDispatcher.instance.views.isEmpty) return toDouble();
    final view = PlatformDispatcher.instance.views.first;
    final double screenWidth = view.physicalSize.width / view.devicePixelRatio;
    if (screenWidth == 0) return toDouble();
    return toDouble() * (screenWidth / 375.0);
  }

  /// Responsive font size scaling relative to screen width (375.0 baseline)
  double get sp {
    if (PlatformDispatcher.instance.views.isEmpty) return toDouble();
    final view = PlatformDispatcher.instance.views.first;
    final double screenWidth = view.physicalSize.width / view.devicePixelRatio;
    if (screenWidth == 0) return toDouble();
    return toDouble() * (screenWidth / 375.0);
  }
}

/// Vertical spacing SizedBox.
///
/// Usage: `sh(16)` — creates a responsive SizedBox with height 16.
SizedBox sh(double height) => SizedBox(height: height.h);

/// Horizontal spacing SizedBox.
///
/// Usage: `sh(16)` — creates a responsive SizedBox with width 16.
SizedBox sw(double width) => SizedBox(width: width.w);

/// Page transition types
enum PageTransitionType {
  rightToLeft,
  leftToRight,
  topToBottom,
  bottomToTop,
  fade,
  none,
}

/// Custom Page Route that transitions page with a slide or fade animation.
class CustomPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final PageTransitionType transitionType;

  CustomPageRoute({
    required this.page,
    this.transitionType = PageTransitionType.rightToLeft,
  }) : super(
         pageBuilder: (context, animation, secondaryAnimation) => page,
         transitionDuration: transitionType == PageTransitionType.none
             ? Duration.zero
             : const Duration(milliseconds: 500),
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           if (transitionType == PageTransitionType.none) {
             return child;
           }
           if (transitionType == PageTransitionType.fade) {
             return FadeTransition(opacity: animation, child: child);
           }

           Offset begin;
           Offset secondaryEnd;
           switch (transitionType) {
             case PageTransitionType.leftToRight:
               begin = const Offset(-1.0, 0.0);
               secondaryEnd = const Offset(0.3, 0.0);
               break;
             case PageTransitionType.topToBottom:
               begin = const Offset(0.0, -1.0);
               secondaryEnd = const Offset(0.0, 0.3);
               break;
             case PageTransitionType.bottomToTop:
               begin = const Offset(0.0, 1.0);
               secondaryEnd = const Offset(0.0, -0.3);
               break;
             case PageTransitionType.rightToLeft:
             default:
               begin = const Offset(1.0, 0.0);
               secondaryEnd = const Offset(-0.3, 0.0);
               break;
           }

           return SlideTransition(
             position: Tween<Offset>(begin: begin, end: Offset.zero).animate(
               CurvedAnimation(parent: animation, curve: Curves.easeOut),
             ),
             child: SlideTransition(
               position: Tween<Offset>(begin: Offset.zero, end: secondaryEnd)
                   .animate(
                     CurvedAnimation(
                       parent: secondaryAnimation,
                       curve: Curves.easeOut,
                     ),
                   ),
               child: child,
             ),
           );
         },
         settings: RouteSettings(name: page.runtimeType.toString()),
       );
}

// Push to next screen
void callNextScreen(
  BuildContext context,
  Widget nextScreen, {
  PageTransitionType transitionType = PageTransitionType.rightToLeft,
}) {
  Navigator.push(
    context,
    CustomPageRoute(page: nextScreen, transitionType: transitionType),
  );
}

void callPreviousScreen(BuildContext context, {dynamic result}) {
  Navigator.pop(context, result);
}

Future callNextScreenWithResult(
  BuildContext context,
  Widget nextScreen, {
  PageTransitionType transitionType = PageTransitionType.rightToLeft,
}) async {
  var action = await Navigator.push(
    context,
    CustomPageRoute(page: nextScreen, transitionType: transitionType),
  );
  return action;
}

void callNextScreenAndClearStack(
  BuildContext context,
  Object nextScreen, {
  PageTransitionType transitionType = PageTransitionType.rightToLeft,
}) {
  if (nextScreen is Route) {
    Navigator.of(context).pushAndRemoveUntil(nextScreen, (_) => false);
  } else if (nextScreen is Widget) {
    Navigator.of(context).pushAndRemoveUntil(
      CustomPageRoute(page: nextScreen, transitionType: transitionType),
      (_) => false,
    );
  }
}

/// Replace the current screen with a new screen without clearing the stack.
/// This removes only the current screen and pushes the new one.
void callReplaceScreen(
  BuildContext context,
  Widget nextScreen, {
  PageTransitionType transitionType = PageTransitionType.rightToLeft,
}) {
  Navigator.pushReplacement(
    context,
    CustomPageRoute(page: nextScreen, transitionType: transitionType),
  );
}

Widget shimmer({required Widget child}) {
  return Shimmer.fromColors(
    baseColor: Colors.grey.withValues(alpha: 0.2),
    highlightColor: AppColors.borderLight,
    child: child,
  );
}

Widget shimmerContainer(double height, double width) {
  return shimmer(
    child: Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(4)),
        color: Colors.grey,
      ),
      height: height,
      width: width,
    ),
  );
}

Widget userItemShimmer({int? itemCount}) {
  return ListView.separated(
    physics: const NeverScrollableScrollPhysics(),
    shrinkWrap: true,
    itemBuilder: (context, index) {
      return Container(
        margin: const EdgeInsets.only(bottom: 10, top: 5),
        child: shimmerContainer(35, 40),
      );
    },
    separatorBuilder: (context, index) => sh(12),
    itemCount: itemCount ?? 1,
  );
}

class SelectedModel<T> {
  final String fromWhere;
  final T? selectedItem;

  SelectedModel({required this.fromWhere, this.selectedItem});
}
