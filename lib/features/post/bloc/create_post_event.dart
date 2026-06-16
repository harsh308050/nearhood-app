abstract class CreatePostEvent {
  const CreatePostEvent();
}

class CreatePostSubmitted extends CreatePostEvent {
  final String content;
  final String category;
  final String visibilityRadius;
  final int? maxRadiusMeters;
  final List<String>? mediaPaths;
  final Map<String, dynamic>? attachedLocation;
  final Map<String, dynamic>? poll;
  final Map<String, dynamic>? metadata;

  const CreatePostSubmitted({
    required this.content,
    required this.category,
    required this.visibilityRadius,
    this.maxRadiusMeters,
    this.mediaPaths,
    this.attachedLocation,
    this.poll,
    this.metadata,
  });
}

class EditPostSubmitted extends CreatePostEvent {
  final String postId;
  final String content;
  final String category;
  final String visibilityRadius;
  final int? maxRadiusMeters;
  final List<String>? newMediaPaths;
  final List<String>? existingMediaUrls;
  final Map<String, dynamic>? attachedLocation;
  final Map<String, dynamic>? poll;
  final Map<String, dynamic>? metadata;

  const EditPostSubmitted({
    required this.postId,
    required this.content,
    required this.category,
    required this.visibilityRadius,
    this.maxRadiusMeters,
    this.newMediaPaths,
    this.existingMediaUrls,
    this.attachedLocation,
    this.poll,
    this.metadata,
  });
}
