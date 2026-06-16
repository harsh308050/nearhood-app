import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearhood/core/utils/custom_import.dart';
import 'package:nearhood/features/post/data/post_datasource.dart';
import 'package:nearhood/features/post/data/post_repository.dart';
import 'package:nearhood/features/home/bloc/feed_bloc.dart';
import 'package:nearhood/features/home/bloc/feed_event.dart';
import 'package:nearhood/features/post/bloc/post_action_bloc.dart';
import 'package:nearhood/core/services/deeplink_service.dart';
import 'package:nearhood/features/post/screens/post_detail_screen.dart';
import 'package:nearhood/common_widget/profile_drawer.dart';

import 'package:nearhood/features/home/screens/homepage.dart';
import 'package:nearhood/features/explore/explore_screen.dart';
import 'package:nearhood/features/chat/chat_screen.dart';
import 'package:nearhood/features/market/market_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final postRepository = PostRepository(dataSource: PostRemoteDataSource());

    return MultiBlocProvider(
      providers: [
        BlocProvider<FeedBloc>(
          create: (context) =>
              FeedBloc(repository: postRepository)
                ..add(const FetchFeedRequested(refresh: true)),
        ),
        BlocProvider<PostActionBloc>(
          create: (context) => PostActionBloc(repository: postRepository),
        ),
      ],
      child: const HomeScreenBody(),
    );
  }
}

class HomeScreenBody extends StatefulWidget {
  const HomeScreenBody({super.key});

  @override
  State<HomeScreenBody> createState() => _HomeScreenBodyState();
}

class _HomeScreenBodyState extends State<HomeScreenBody> {
  int _bottomNavIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      Homepage(onProfileTap: () => _scaffoldKey.currentState?.openEndDrawer()),
      const ExploreScreen(),
      const ChatScreen(),
      const MarketScreen(),
    ];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (DeepLinkService.pendingPostId != null) {
        final postId = DeepLinkService.pendingPostId!;
        DeepLinkService.pendingPostId = null;
        callNextScreen(context, PostDetailScreen(postId: postId));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      extendBody: true,
      backgroundColor: AppColors.background,
      endDrawer: const ProfileDrawer(),
      body: IndexedStack(index: _bottomNavIndex, children: _screens),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return SafeArea(
      bottom: true,
      child: Container(
        margin: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 15.r,
              spreadRadius: 1.r,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
            child: Container(
              height: 64.h,
              decoration: BoxDecoration(
                color: Colors.white.withValues(
                  alpha: 0.2,
                ), // Ultra-transparent glass
                borderRadius: BorderRadius.circular(30.r),
                border: Border.all(
                  color: Colors.white.withValues(
                    alpha: 0.25,
                  ), // Thin soft glass border
                  width: 1.2.w,
                ),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final double barWidth = constraints.maxWidth;
                  final double itemWidth = barWidth / 4;

                  final double pillHeight = 46.h;
                  final double pillWidth = 68.w;
                  final double topInset = (64.h - 1.2.w * 2 - pillHeight) / 2;
                  final double leftInset =
                      (_bottomNavIndex * itemWidth) +
                      (itemWidth - pillWidth) / 2;

                  return Stack(
                    children: [
                      // Animated sliding capsule background for active item
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOutCubic,
                        left: leftInset,
                        top: topInset,
                        width: pillWidth,
                        height: pillHeight,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withValues(
                              alpha: 0.15,
                            ),
                            borderRadius: BorderRadius.circular(40.r),
                          ),
                        ),
                      ),

                      // Row of navigation icons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildNavItem(
                            0,
                            Icons.home_outlined,
                            Icons.home_rounded,
                            AppStrings.home,
                          ),
                          _buildNavItem(
                            1,
                            Icons.explore_outlined,
                            Icons.explore,
                            AppStrings.explore,
                          ),
                          _buildNavItem(
                            2,
                            null,
                            null,
                            AppStrings.messages,
                            customSvgPath: AppAssets.icMessage,
                            customActiveSvgPath: AppAssets.icMessageFilled,
                          ),
                          _buildNavItem(
                            3,
                            Icons.storefront_outlined,
                            Icons.storefront_rounded,
                            AppStrings.market,
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData? inactiveIcon,
    IconData? activeIcon,
    String label, {
    String? customSvgPath,
    String? customActiveSvgPath,
  }) {
    final bool isActive = _bottomNavIndex == index;
    final Color color = isActive ? AppColors.primaryBlue : AppColors.grey;

    return Expanded(
      child: Tooltip(
        message: label,
        preferBelow: false,
        verticalOffset: 24.h,
        triggerMode: TooltipTriggerMode.longPress,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            setState(() {
              _bottomNavIndex = index;
            });
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 40.h,
                width: 56.w,
                alignment: Alignment.center,
                child: customSvgPath != null
                    ? CustomImageView(
                        imagePath: isActive
                            ? customActiveSvgPath!
                            : customSvgPath,
                        color: color,
                        height: 24.r,
                        width: 24.r,
                      )
                    : Icon(
                        isActive ? activeIcon : inactiveIcon,
                        color: color,
                        size: 30.r,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
