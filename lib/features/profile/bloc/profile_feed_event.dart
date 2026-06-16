abstract class ProfileFeedEvent {
  const ProfileFeedEvent();
}

class FetchProfilePostsRequested extends ProfileFeedEvent {
  final String userId;
  final String mode; // 'all' | 'myarea' | 'nearby' | 'city'
  final bool refresh;

  const FetchProfilePostsRequested({
    required this.userId,
    required this.mode,
    this.refresh = true,
  });
}
