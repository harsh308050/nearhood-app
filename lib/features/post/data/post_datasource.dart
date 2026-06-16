import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:nearhood/core/network/api_urls.dart';
import 'package:nearhood/core/network/http_actions.dart';
import 'package:nearhood/core/network/http_response.dart';

class PostRemoteDataSource extends HttpActions {
  final ApiUrls urls;

  PostRemoteDataSource({
    http.Client? client,
    ApiUrls? urls,
    Future<String?> Function()? tokenProvider,
  }) : urls = urls ?? ApiUrls(),
       super(
         client: client ?? http.Client(),
         baseUrl: (urls ?? ApiUrls()).baseUrl,
         tokenProvider:
             tokenProvider ??
             () async => FirebaseAuth.instance.currentUser?.getIdToken(),
       );

  Future<HttpResponse> createPost({
    required String content,
    required String category,
    required String visibilityRadius,
    int? maxRadiusMeters,
    List<String>? mediaPaths,
    Map<String, dynamic>? attachedLocation,
    Map<String, dynamic>? poll,
    Map<String, dynamic>? metadata,
  }) async {
    final Map<String, String> fields = {
      'content': content,
      'category': category,
      'visibilityRadius': visibilityRadius,
      if (maxRadiusMeters != null)
        'maxRadiusMeters': maxRadiusMeters.toString(),
      if (attachedLocation != null)
        'attachedLocation': jsonEncode(attachedLocation),
      if (poll != null) 'poll': jsonEncode(poll),
      if (metadata != null) 'metadata': jsonEncode(metadata),
    };

    final List<http.MultipartFile> files = [];
    if (mediaPaths != null) {
      for (final path in mediaPaths) {
        files.add(await http.MultipartFile.fromPath('media', path));
      }
    }

    return postMultipart('posts', fields: fields, files: files);
  }

  Future<HttpResponse> getFeed({
    required String mode,
    String? category,
    String? userId,
    int radius = 5000,
    int page = 1,
    int limit = 20,
  }) {
    final Map<String, String> queryParameters = {
      'mode': mode,
      'radius': radius.toString(),
      'page': page.toString(),
      'limit': limit.toString(),
      if (category != null && category != 'All Posts' && category != 'All')
        'category': category,
      if (userId != null) 'userId': userId,
    };
    return get('posts/feed', queryParameters: queryParameters);
  }

  Future<HttpResponse> getUserPosts({
    required String userId,
    int page = 1,
    int limit = 100,
  }) {
    final Map<String, String> queryParameters = {
      'page': page.toString(),
      'limit': limit.toString(),
    };
    return get('posts/user/$userId', queryParameters: queryParameters);
  }

  Future<HttpResponse> getPostDetails(String postId) {
    return get('posts/$postId');
  }

  Future<HttpResponse> deletePost(String postId) {
    return delete('posts/$postId');
  }

  Future<HttpResponse> reactToPost(String postId, String reaction) {
    return post('posts/$postId/react', body: {'reaction': reaction});
  }

  Future<HttpResponse> removeReactionFromPost(String postId) {
    return delete('posts/$postId/react');
  }

  Future<HttpResponse> getComments({
    required String postId,
    int page = 1,
    int limit = 50,
  }) {
    final Map<String, String> queryParameters = {
      'page': page.toString(),
      'limit': limit.toString(),
    };
    return get('posts/$postId/comments', queryParameters: queryParameters);
  }

  Future<HttpResponse> addComment({
    required String postId,
    required String content,
    String? parentCommentId,
  }) {
    return post(
      'posts/$postId/comments',
      body: {
        'content': content,
        if (parentCommentId != null) 'parentCommentId': parentCommentId,
      },
    );
  }

  Future<HttpResponse> reactToComment({
    required String postId,
    required String commentId,
    required String reaction,
  }) {
    return post(
      'posts/$postId/comments/$commentId/react',
      body: {'reaction': reaction},
    );
  }

  Future<HttpResponse> removeReactionFromComment({
    required String postId,
    required String commentId,
  }) {
    return delete('posts/$postId/comments/$commentId/react');
  }

  Future<HttpResponse> togglePinComment({
    required String postId,
    required String commentId,
  }) {
    return put('posts/$postId/comments/$commentId/pin');
  }

  Future<HttpResponse> deleteComment({
    required String postId,
    required String commentId,
  }) {
    return delete('posts/$postId/comments/$commentId');
  }

  Future<HttpResponse> votePoll(String postId, String optionId) {
    return post('posts/$postId/poll/vote', body: {'optionId': optionId});
  }

  /// Fetch the SDUI form schema for a given category.
  /// Public endpoint — no auth required.
  Future<HttpResponse> getFormSchema(String category) {
    return get('form-schemas/$category', includeAuth: false);
  }
}
