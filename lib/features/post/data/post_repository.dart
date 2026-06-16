import 'package:nearhood/core/network/api_result.dart';
import 'package:nearhood/core/network/network_utils.dart';
import 'package:nearhood/features/post/data/models/comment_model.dart';
import 'package:nearhood/features/post/data/models/form_schema_model.dart';
import 'package:nearhood/features/post/data/models/post_model.dart';
import 'package:nearhood/features/post/data/post_datasource.dart';

class PostRepository {
  final PostRemoteDataSource dataSource;

  PostRepository({required this.dataSource});

  Future<ApiResult<PostModel>> createPost({
    required String content,
    required String category,
    required String visibilityRadius,
    int? maxRadiusMeters,
    List<String>? mediaPaths,
    Map<String, dynamic>? attachedLocation,
    Map<String, dynamic>? poll,
    Map<String, dynamic>? metadata,
  }) async {
    final response = await dataSource.createPost(
      content: content,
      category: category,
      visibilityRadius: visibilityRadius,
      maxRadiusMeters: maxRadiusMeters,
      mediaPaths: mediaPaths,
      attachedLocation: attachedLocation,
      poll: poll,
      metadata: metadata,
    );
    return checkResponseStatusCode<PostModel>(
      response: response,
      dataParser: (data) {
        final map = data as Map<String, dynamic>;
        return PostModel.fromJson(map['post'] as Map<String, dynamic>);
      },
    );
  }

  Future<ApiResult<Map<String, dynamic>>> getFeed({
    required String mode,
    String? category,
    String? userId,
    int radius = 5000,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await dataSource.getFeed(
      mode: mode,
      category: category,
      userId: userId,
      radius: radius,
      page: page,
      limit: limit,
    );
    return checkResponseStatusCode<Map<String, dynamic>>(
      response: response,
      dataParser: (data) {
        final map = data as Map<String, dynamic>;
        final postsList =
            (map['posts'] as List?)
                ?.map((e) => PostModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [];
        return {
          'posts': postsList,
          'totalCount': map['totalCount'] ?? 0,
          'mode': map['mode'] ?? mode,
        };
      },
    );
  }

  Future<ApiResult<List<PostModel>>> getUserPosts({
    required String userId,
    int page = 1,
    int limit = 100,
  }) async {
    final response = await dataSource.getUserPosts(
      userId: userId,
      page: page,
      limit: limit,
    );
    return checkResponseStatusCode<List<PostModel>>(
      response: response,
      dataParser: (data) {
        final map = data as Map<String, dynamic>;
        final postsList =
            (map['posts'] as List?)
                ?.map((e) => PostModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [];
        return postsList;
      },
    );
  }

  Future<ApiResult<PostModel>> getPostDetails(String postId) async {
    final response = await dataSource.getPostDetails(postId);
    return checkResponseStatusCode<PostModel>(
      response: response,
      dataParser: (data) {
        final map = data as Map<String, dynamic>;
        return PostModel.fromJson(map['post'] as Map<String, dynamic>);
      },
    );
  }

  Future<ApiResult<bool>> deletePost(String postId) async {
    final response = await dataSource.deletePost(postId);
    return checkResponseStatusCode<bool>(
      response: response,
      dataParser: (data) => true,
    );
  }

  Future<ApiResult<List<PostReaction>>> reactToPost(
    String postId,
    String reaction,
  ) async {
    final response = await dataSource.reactToPost(postId, reaction);
    return checkResponseStatusCode<List<PostReaction>>(
      response: response,
      dataParser: (data) {
        final map = data as Map<String, dynamic>;
        return (map['reactions'] as List?)
                ?.map((e) => PostReaction.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [];
      },
    );
  }

  Future<ApiResult<List<PostReaction>>> removeReactionFromPost(
    String postId,
  ) async {
    final response = await dataSource.removeReactionFromPost(postId);
    return checkResponseStatusCode<List<PostReaction>>(
      response: response,
      dataParser: (data) {
        final map = data as Map<String, dynamic>;
        return (map['reactions'] as List?)
                ?.map((e) => PostReaction.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [];
      },
    );
  }

  Future<ApiResult<Map<String, dynamic>>> getComments({
    required String postId,
    int page = 1,
    int limit = 50,
  }) async {
    final response = await dataSource.getComments(
      postId: postId,
      page: page,
      limit: limit,
    );
    return checkResponseStatusCode<Map<String, dynamic>>(
      response: response,
      dataParser: (data) {
        final map = data as Map<String, dynamic>;
        final commentList =
            (map['comments'] as List?)
                ?.map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [];
        return {'comments': commentList, 'totalCount': map['totalCount'] ?? 0};
      },
    );
  }

  Future<ApiResult<CommentModel>> addComment({
    required String postId,
    required String content,
    String? parentCommentId,
  }) async {
    final response = await dataSource.addComment(
      postId: postId,
      content: content,
      parentCommentId: parentCommentId,
    );
    return checkResponseStatusCode<CommentModel>(
      response: response,
      dataParser: (data) {
        final map = data as Map<String, dynamic>;
        return CommentModel.fromJson(map['comment'] as Map<String, dynamic>);
      },
    );
  }

  Future<ApiResult<List<CommentReaction>>> reactToComment({
    required String postId,
    required String commentId,
    required String reaction,
  }) async {
    final response = await dataSource.reactToComment(
      postId: postId,
      commentId: commentId,
      reaction: reaction,
    );
    return checkResponseStatusCode<List<CommentReaction>>(
      response: response,
      dataParser: (data) {
        final map = data as Map<String, dynamic>;
        return (map['reactions'] as List?)
                ?.map(
                  (e) => CommentReaction.fromJson(e as Map<String, dynamic>),
                )
                .toList() ??
            [];
      },
    );
  }

  Future<ApiResult<List<CommentReaction>>> removeReactionFromComment({
    required String postId,
    required String commentId,
  }) async {
    final response = await dataSource.removeReactionFromComment(
      postId: postId,
      commentId: commentId,
    );
    return checkResponseStatusCode<List<CommentReaction>>(
      response: response,
      dataParser: (data) {
        final map = data as Map<String, dynamic>;
        return (map['reactions'] as List?)
                ?.map(
                  (e) => CommentReaction.fromJson(e as Map<String, dynamic>),
                )
                .toList() ??
            [];
      },
    );
  }

  Future<ApiResult<CommentModel>> togglePinComment({
    required String postId,
    required String commentId,
  }) async {
    final response = await dataSource.togglePinComment(
      postId: postId,
      commentId: commentId,
    );
    return checkResponseStatusCode<CommentModel>(
      response: response,
      dataParser: (data) {
        final map = data as Map<String, dynamic>;
        return CommentModel.fromJson(map['comment'] as Map<String, dynamic>);
      },
    );
  }

  Future<ApiResult<void>> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    final response = await dataSource.deleteComment(
      postId: postId,
      commentId: commentId,
    );
    return checkResponseStatusCode<void>(
      response: response,
      dataParser: (_) {},
    );
  }

  Future<ApiResult<PostModel>> votePoll(String postId, String optionId) async {
    final response = await dataSource.votePoll(postId, optionId);
    return checkResponseStatusCode<PostModel>(
      response: response,
      dataParser: (data) {
        final map = data as Map<String, dynamic>;
        return PostModel.fromJson(map['post'] as Map<String, dynamic>);
      },
    );
  }

  Future<ApiResult<PostModel>> updatePost({
    required String postId,
    required String content,
    required String visibilityRadius,
    int? maxRadiusMeters,
    List<String>? newMediaPaths,
    List<String>? existingMediaUrls,
    Map<String, dynamic>? attachedLocation,
    Map<String, dynamic>? poll,
    Map<String, dynamic>? metadata,
  }) async {
    final response = await dataSource.updatePost(
      postId: postId,
      content: content,
      visibilityRadius: visibilityRadius,
      maxRadiusMeters: maxRadiusMeters,
      newMediaPaths: newMediaPaths,
      existingMediaUrls: existingMediaUrls,
      attachedLocation: attachedLocation,
      poll: poll,
      metadata: metadata,
    );
    return checkResponseStatusCode<PostModel>(
      response: response,
      dataParser: (data) {
        final map = data as Map<String, dynamic>;
        return PostModel.fromJson(map['post'] as Map<String, dynamic>);
      },
    );
  }

  /// Fetch the SDUI form schema for a given post category.
  Future<ApiResult<FormSchemaModel>> getFormSchema(String category) async {
    final response = await dataSource.getFormSchema(category);
    return checkResponseStatusCode<FormSchemaModel>(
      response: response,
      dataParser: (data) {
        final map = data as Map<String, dynamic>;
        return FormSchemaModel.fromJson(map['schema'] as Map<String, dynamic>);
      },
    );
  }
}
