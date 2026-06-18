import 'package:nearhood/core/network/api_result.dart';
import 'package:nearhood/core/network/network_utils.dart';
import 'package:nearhood/features/news/data/news_datasource.dart';
import 'package:nearhood/features/post/data/models/post_model.dart';

class NewsRepository {
  final NewsRemoteDataSource dataSource;

  NewsRepository({required this.dataSource});

  /// Fetches local news posts for the user's city.
  /// Returns a map with 'posts', 'totalCount', and 'mode'.
  Future<ApiResult<Map<String, dynamic>>> getLocalNewsFeed({
    String mode = 'city',
    int page = 1,
    int limit = 20,
    int maxAgeDays = 10,
  }) async {
    final response = await dataSource.getLocalNewsFeed(
      mode: mode,
      page: page,
      limit: limit,
      maxAgeDays: maxAgeDays,
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
}
