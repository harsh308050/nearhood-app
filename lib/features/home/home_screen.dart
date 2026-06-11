import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearhood/core/utils/custom_import.dart';
import 'package:nearhood/features/post/data/post_datasource.dart';
import 'package:nearhood/features/post/data/post_repository.dart';
import 'package:nearhood/features/home/bloc/feed_bloc.dart';
import 'package:nearhood/features/home/bloc/feed_event.dart';
import 'package:nearhood/features/post/bloc/post_action_bloc.dart';

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

  final List<Widget> _screens = const [
    Homepage(),
    ExploreScreen(),
    ChatScreen(),
    MarketScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _bottomNavIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.borderLight, width: 1.h),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _bottomNavIndex,
        onTap: (index) {
          setState(() {
            _bottomNavIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.grey,
        selectedLabelStyle: AppTypography.caption.copyWith(
          color: AppColors.primaryBlue,
          fontWeight: FontWeight.bold,
          fontSize: 13.sp,
        ),
        unselectedLabelStyle: AppTypography.caption.copyWith(fontSize: 13.sp),
        items: [
          BottomNavigationBarItem(
            icon: CustomImageView(
              imagePath: AppAssets.icHome,
              color: AppColors.grey,
              height: 24.r,
              width: 24.r,
            ),
            activeIcon: CustomImageView(
              imagePath: AppAssets.icHome,
              color: AppColors.primaryBlue,
              height: 24.r,
              width: 24.r,
            ),
            label: AppStrings.home,
          ),
          BottomNavigationBarItem(
            icon: CustomImageView(
              imagePath: AppAssets.icExplore,
              color: AppColors.grey,
              height: 24.r,
              width: 24.r,
            ),
            activeIcon: CustomImageView(
              imagePath: AppAssets.icExplore,
              color: AppColors.primaryBlue,
              height: 24.r,
              width: 24.r,
            ),
            label: AppStrings.explore,
          ),
          BottomNavigationBarItem(
            icon: CustomImageView(
              imagePath: AppAssets.icMessage,
              color: AppColors.grey,
              height: 24.r,
              width: 24.r,
            ),
            activeIcon: CustomImageView(
              imagePath: AppAssets.icMessageFilled,
              color: AppColors.primaryBlue,
              height: 24.r,
              width: 24.r,
            ),
            label: AppStrings.messages,
          ),
          BottomNavigationBarItem(
            icon: CustomImageView(
              imagePath: AppAssets.icMarket,
              color: AppColors.grey,
              height: 24.r,
              width: 24.r,
            ),
            activeIcon: CustomImageView(
              imagePath: AppAssets.icMarket,
              color: AppColors.primaryBlue,
              height: 24.r,
              width: 24.r,
            ),
            label: AppStrings.market,
          ),
        ],
      ),
    );
  }
}
