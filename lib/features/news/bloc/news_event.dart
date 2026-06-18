import 'package:nearhood/features/post/data/models/post_model.dart';

abstract class NewsEvent {
  const NewsEvent();
}

class FetchLocalNewsRequested extends NewsEvent {
  final bool refresh;
  final String? mode;
  final int maxAgeDays;

  const FetchLocalNewsRequested({
    this.refresh = false,
    this.mode,
    this.maxAgeDays = 10,
  });
}

class UpdateLocalNewsPostRequested extends NewsEvent {
  final PostModel post;

  const UpdateLocalNewsPostRequested(this.post);
}
