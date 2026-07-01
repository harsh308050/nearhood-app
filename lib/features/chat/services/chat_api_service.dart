import 'package:nearhood/core/network/api_urls.dart';
import 'package:nearhood/core/network/http_actions.dart';
import 'package:http/http.dart' as http;
import 'package:nearhood/features/chat/models/conversation_model.dart';
import 'package:nearhood/features/chat/models/message_model.dart';
import 'package:nearhood/features/chat/models/chat_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nearhood/core/constants/app_strings.dart';

class ChatApiService {
  final ApiUrls _apiUrls = ApiUrls();
  final http.Client _client = http.Client();

  Future<HttpActions> _getHttpActions() async {
    return HttpActions(
      client: _client,
      baseUrl: _apiUrls.baseUrl,
      tokenProvider: () async => FirebaseAuth.instance.currentUser?.getIdToken(),
    );
  }

  Future<List<ConversationModel>> getConversations({
    int page = 1,
    int limit = 20,
  }) async {
    final httpActions = await _getHttpActions();
    final response = await httpActions.get(
      '/chat/conversations',
      queryParameters: {
        'page': page.toString(),
        'limit': limit.toString(),
      },
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      final data = response.data['data'];
      final conversations = (data?['conversations'] as List?) ?? [];
      return conversations.map((e) => ConversationModel.fromJson(e)).toList();
    }
    throw Exception(response.data['message'] ?? AppStrings.chatFailedToLoadConversations);
  }

  Future<List<MessageModel>> getMessages(
    String conversationId, {
    int page = 1,
    int limit = 50,
  }) async {
    final httpActions = await _getHttpActions();
    final response = await httpActions.get(
      '/chat/messages/$conversationId',
      queryParameters: {
        'page': page.toString(),
        'limit': limit.toString(),
      },
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      final data = response.data['data'];
      final messages = (data?['messages'] as List?) ?? [];
      return messages.map((e) => MessageModel.fromJson(e)).toList();
    }
    throw Exception(response.data['message'] ?? AppStrings.chatFailedToLoadMessages);
  }

  Future<List<ChatUser>> getChatUsers({
    String? search,
    int page = 1,
    int limit = 50,
  }) async {
    final httpActions = await _getHttpActions();
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    final response = await httpActions.get(
      '/chat/users',
      queryParameters: queryParams,
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      final data = response.data['data'];
      final users = (data?['users'] as List?) ?? [];
      return users.map((e) => ChatUser.fromJson(e)).toList();
    }
    throw Exception(response.data['message'] ?? AppStrings.chatFailedToLoadUsers);
  }

  Future<ConversationModel> createConversation(String receiverId) async {
    final httpActions = await _getHttpActions();
    final response = await httpActions.post(
      '/chat/conversations',
      body: {'receiverId': receiverId},
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      return ConversationModel.fromJson(response.data['data']['conversation']);
    }
    throw Exception(response.data['message'] ?? AppStrings.chatFailedToCreateConversation);
  }

  Future<MessageModel> sendMessage({
    required String receiverId,
    required String content,
    String? conversationId,
    String messageType = 'text',
    String? mediaUrl,
    String? replyToMessageId,
  }) async {
    final httpActions = await _getHttpActions();
    final response = await httpActions.post(
      '/chat/messages',
      body: {
        'receiverId': receiverId,
        'content': content,
        'conversationId': conversationId,
        'messageType': messageType,
        'mediaUrl': mediaUrl,
        'replyTo': replyToMessageId,
      },
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      return MessageModel.fromJson(response.data['data']['message']);
    }
    throw Exception(response.data['message'] ?? AppStrings.chatFailedToSendMessage);
  }

  Future<void> markAsRead({
    required String conversationId,
    List<String>? messageIds,
  }) async {
    final httpActions = await _getHttpActions();
    final response = await httpActions.put(
      '/chat/messages/read',
      body: {
        'conversationId': conversationId,
        'messageIds': messageIds,
      },
    );

    if (response.statusCode != 200 || response.data['success'] != true) {
      throw Exception(response.data['message'] ?? AppStrings.chatFailedToMarkAsRead);
    }
  }

  Future<int> getUnreadCount() async {
    final httpActions = await _getHttpActions();
    final response = await httpActions.get('/chat/unread-count');

    if (response.statusCode == 200 && response.data['success'] == true) {
      return response.data['data']['unreadCount'] ?? 0;
    }
    throw Exception(response.data['message'] ?? AppStrings.chatFailedToGetUnreadCount);
  }

  Future<void> hideConversation(String conversationId) async {
    final httpActions = await _getHttpActions();
    final response = await httpActions.post(
      '/chat/conversations/hide',
      body: {'conversationId': conversationId},
    );

    if (response.statusCode != 200 || response.data['success'] != true) {
      throw Exception(response.data['message'] ?? AppStrings.chatFailedToHideConversation);
    }
  }

  Future<void> unhideConversation(String conversationId) async {
    final httpActions = await _getHttpActions();
    final response = await httpActions.post(
      '/chat/conversations/unhide',
      body: {'conversationId': conversationId},
    );

    if (response.statusCode != 200 || response.data['success'] != true) {
      throw Exception(response.data['message'] ?? 'Failed to unhide conversation');
    }
  }

  Future<String> blockUser(String targetUserId) async {
    final httpActions = await _getHttpActions();
    final response = await httpActions.post(
      '/chat/block',
      body: {'targetUserId': targetUserId},
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      return response.data['data']['conversationId'] ?? '';
    }
    throw Exception(response.data['message'] ?? AppStrings.chatFailedToBlockUser);
  }

  Future<void> unblockUser(String targetUserId) async {
    final httpActions = await _getHttpActions();
    final response = await httpActions.post(
      '/chat/unblock',
      body: {'targetUserId': targetUserId},
    );

    if (response.statusCode != 200 || response.data['success'] != true) {
      throw Exception(response.data['message'] ?? AppStrings.chatFailedToUnblockUser);
    }
  }

  Future<bool> toggleMute(String conversationId) async {
    final httpActions = await _getHttpActions();
    final response = await httpActions.post(
      '/chat/conversations/mute',
      body: {'conversationId': conversationId},
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      return response.data['data']['isMuted'] ?? false;
    }
    throw Exception(response.data['message'] ?? 'Failed to toggle mute');
  }

  Future<Map<String, String>> uploadChatMedia(String filePath) async {
    final httpActions = await _getHttpActions();
    final file = await http.MultipartFile.fromPath('media', filePath);
    final response = await httpActions.postMultipart(
      '/chat/upload-media',
      files: [file],
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      return {
        'url': response.data['data']['url'] ?? '',
        'thumbnail': response.data['data']['thumbnail'] ?? '',
      };
    }
    throw Exception(response.data['message'] ?? 'Failed to upload media');
  }

  void dispose() {
    _client.close();
  }
}
