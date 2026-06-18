import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:nearhood/core/network/api_urls.dart';
import 'package:nearhood/core/network/http_actions.dart';
import 'package:nearhood/core/network/http_response.dart';

class NewsRemoteDataSource extends HttpActions {
  final ApiUrls urls;

  NewsRemoteDataSource({
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

  /// Fetches the local news feed for the authenticated user.
  ///
  /// The backend auto-syncs fresh news from WorldNewsAPI before returning.
  /// [mode] can be 'city' (default), 'myarea', or 'nearby'.
  Future<HttpResponse> getLocalNewsFeed({
    String mode = 'city',
    int page = 1,
    int limit = 20,
    int maxAgeDays = 10,
  }) {
    final Map<String, String> queryParameters = {
      'mode': mode,
      'page': page.toString(),
      'limit': limit.toString(),
      'maxAgeDays': maxAgeDays.toString(),
    };
    return get('news/feed', queryParameters: queryParameters);
  }
}
