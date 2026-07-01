import 'package:nearhood/core/network/api_urls.dart';
import 'package:nearhood/core/network/http_actions.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nearhood/core/constants/app_strings.dart';

class ReportApiService {
  final ApiUrls _apiUrls = ApiUrls();
  final http.Client _client = http.Client();

  Future<HttpActions> _getHttpActions() async {
    return HttpActions(
      client: _client,
      baseUrl: _apiUrls.baseUrl,
      tokenProvider: () async => FirebaseAuth.instance.currentUser?.getIdToken(),
    );
  }

  /// Report content (post, comment, message, or user).
  Future<void> report({
    required String targetType,
    required String targetId,
    required String reason,
    String? details,
    String? parentPostId,
    String? parentConversationId,
  }) async {
    final httpActions = await _getHttpActions();
    final response = await httpActions.post(
      '/reports',
      body: {
        'targetType': targetType,
        'targetId': targetId,
        'reason': reason,
        if (details != null) 'details': details,
        if (parentPostId != null) 'parentPostId': parentPostId,
        if (parentConversationId != null) 'parentConversationId': parentConversationId,
      },
    );

    if (response.statusCode == 201 && response.data['success'] == true) {
      return;
    }

    final message = response.data['message'] ?? '';
    if (message.contains('already reported')) {
      throw Exception(AppStrings.alreadyReported);
    }
    throw Exception(message.isNotEmpty ? message : AppStrings.reportFailed);
  }

  void dispose() {
    _client.close();
  }
}
