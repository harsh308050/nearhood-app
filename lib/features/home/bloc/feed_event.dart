import 'package:nearhood/features/post/data/models/post_model.dart';

abstract class FeedEvent {
  const FeedEvent();
}

class FetchFeedRequested extends FeedEvent {
  final bool refresh;
  final String? mode;
  final String? category;

  const FetchFeedRequested({
    this.refresh = false,
    this.mode,
    this.category,
  });
}

class UpdatePostRequested extends FeedEvent {
  final PostModel post;

  const UpdatePostRequested(this.post);
}
