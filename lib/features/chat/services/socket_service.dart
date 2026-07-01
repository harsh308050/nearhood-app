import 'dart:async';
import 'package:nearhood/core/network/api_urls.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nearhood/features/chat/models/message_model.dart';
import 'package:nearhood/features/chat/models/conversation_model.dart';
import 'package:nearhood/features/chat/models/chat_user.dart';
import 'package:nearhood/core/utils/shared_pref_helper.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  bool _isConnected = false;
  String? _currentUserId;
  String? _connectedFirebaseUid;

  final StreamController<MessageModel> _messageController =
      StreamController<MessageModel>.broadcast();
  final StreamController<List<ConversationModel>> _conversationController =
      StreamController<List<ConversationModel>>.broadcast();
  final StreamController<List<ChatUser>> _userListController =
      StreamController<List<ChatUser>>.broadcast();
  final StreamController<Map<String, dynamic>> _typingController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();
  final StreamController<Map<String, dynamic>> _readReceiptController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _messageDeletedController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<MessageModel> _messageEditedController =
      StreamController<MessageModel>.broadcast();
  final StreamController<String> _messageErrorController =
      StreamController<String>.broadcast();
  final StreamController<Map<String, dynamic>> _postDeletedController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<MessageModel> get messageStream => _messageController.stream;
  Stream<List<ConversationModel>> get conversationStream =>
      _conversationController.stream;
  Stream<List<ChatUser>> get userListStream => _userListController.stream;
  Stream<Map<String, dynamic>> get typingStream => _typingController.stream;
  Stream<bool> get connectionStream => _connectionController.stream;
  Stream<Map<String, dynamic>> get readReceiptStream =>
      _readReceiptController.stream;
  Stream<Map<String, dynamic>> get messageDeletedStream =>
      _messageDeletedController.stream;
  Stream<MessageModel> get messageEditedStream =>
      _messageEditedController.stream;
  Stream<String> get messageErrorStream => _messageErrorController.stream;
  Stream<Map<String, dynamic>> get postDeletedStream =>
      _postDeletedController.stream;

  bool get isConnected => _isConnected;
  String? get currentUserId => _currentUserId;

  Future<void> connect() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('❌ Socket: No Firebase user');
        return;
      }

      // If socket exists but connected as a different user, disconnect first
      if (_socket != null) {
        if (_connectedFirebaseUid == user.uid && _isConnected) {
          return;
        }
        print('🔌 Socket: user changed or stale, reconnecting...');
        disconnect();
      }

      // Use MongoDB _id (not Firebase UID) so message sender checks work correctly
      final storedUser = sharedPrefGetUser();
      _currentUserId = storedUser?.id;

      final token = await user.getIdToken(true); // force refresh
      if (token == null) {
        print('❌ Socket: No Firebase token available');
        return;
      }

      final baseUrl = ApiUrls().baseUrl.replaceFirst(RegExp(r'/api/?$'), '');

      print('🔌 Socket: connecting as firebaseUid=${user.uid}, mongoId=$_currentUserId');

      _socket = IO.io(
        baseUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .enableForceNew()
            .enableReconnection()
            .setReconnectionDelay(1000)
            .setReconnectionAttempts(10)
            .setAuth({'token': token})
            .build(),
      );

      _connectedFirebaseUid = user.uid;
      _setupSocketListeners();
      _socket!.connect();
    } catch (e) {
      print('❌ Socket connection error: $e');
    }
  }

  void _setupSocketListeners() {
    _socket!.onConnect((_) {
      print('✅ Socket connected');
      _isConnected = true;
      _connectionController.add(true);
      _socket!.emit('user:get-all', {});
    });

    _socket!.onDisconnect((_) {
      print('🔌 Socket disconnected');
      _isConnected = false;
      _connectionController.add(false);
    });

    _socket!.onConnectError((error) {
      print('❌ Socket connect error: $error');
      _isConnected = false;
      _connectionController.add(false);
    });

    _socket!.onError((error) {
      print('❌ Socket error: $error');
    });

    _socket!.on('message:new', (data) {
      try {
        print('🔌 SocketService: message:new event received data: $data');
        final message = MessageModel.fromJson(data);
        _messageController.add(message);
        print('🔌 SocketService: message:new parsed successfully: id=${message.id}, conversationId=${message.conversationId}');
      } catch (e, stack) {
        print('❌ SocketService: parse message error: $e');
        print(stack);
      }
    });

    _socket!.on('message:edited', (data) {
      try {
        final message = MessageModel.fromJson(data);
        _messageEditedController.add(message);
      } catch (e) {
        print('❌ SocketService: parse edited message error: $e');
      }
    });

    _socket!.on('conversation:list', (data) {
      try {
        final conversations = (data as List)
            .map((e) => ConversationModel.fromJson(e))
            .toList();
        _conversationController.add(conversations);
      } catch (e) {
        print('❌ Parse conversations error: $e');
      }
    });

    _socket!.on('user:list', (data) {
      try {
        final users = (data as List).map((e) => ChatUser.fromJson(e)).toList();
        _userListController.add(users);
      } catch (e) {
        print('❌ Parse users error: $e');
      }
    });

    _socket!.on('user:typing', (data) {
      try {
        if (data is Map) {
          _typingController.add({...Map<String, dynamic>.from(data), 'isTyping': true});
        }
      } catch (e) {
        print('❌ Parse typing error: $e');
      }
    });

    _socket!.on('user:stop-typing', (data) {
      try {
        if (data is Map) {
          _typingController.add({...Map<String, dynamic>.from(data), 'isTyping': false});
        }
      } catch (e) {
        print('❌ Parse stop-typing error: $e');
      }
    });

    _socket!.on('message:read', (data) {
      print('🔌 SocketService: message:read receipt received: $data');
      _readReceiptController.add(data);
    });

    _socket!.on('message:deleted', (data) {
      try {
        print('🔌 SocketService: message:deleted received: $data');
        if (data is Map) {
          _messageDeletedController.add(Map<String, dynamic>.from(data));
        }
      } catch (e) {
        print('❌ Parse message deleted error: $e');
      }
    });

    _socket!.on('message:error', (data) {
      final errorMsg = data is Map ? (data['error']?.toString() ?? 'Unknown error') : data.toString();
      print('❌ Message error: $errorMsg');
      _messageErrorController.add(errorMsg);
    });

    _socket!.on('post:deleted', (data) {
      try {
        if (data is Map) {
          _postDeletedController.add(Map<String, dynamic>.from(data));
        }
      } catch (e) {
        print('❌ Parse post:deleted error: $e');
      }
    });
  }

  void sendMessage({
    required String receiverId,
    required String content,
    String messageType = 'text',
    String? mediaUrl,
    String? conversationId,
    String? replyToMessageId,
    Map<String, dynamic>? location,
  }) {
    if (!_isConnected || _socket == null) {
      print('❌ Socket not connected');
      return;
    }

    _socket!.emit('message:send', {
      'receiverId': receiverId,
      'content': content,
      'messageType': messageType,
      'mediaUrl': mediaUrl,
      'conversationId': conversationId,
      'replyTo': replyToMessageId,
      if (location != null) 'location': location,
    });
  }

  void editMessage({
    required String messageId,
    required String content,
  }) {
    if (!_isConnected || _socket == null) {
      print('❌ Socket not connected');
      return;
    }

    _socket!.emit('message:edit', {
      'messageId': messageId,
      'content': content,
    });
  }

  void joinConversation(String conversationId) {
    if (!_isConnected || _socket == null) return;
    _socket!.emit('join:conversation', {'conversationId': conversationId});
  }

  void leaveConversation(String conversationId) {
    if (!_isConnected || _socket == null) return;
    _socket!.emit('leave:conversation', {'conversationId': conversationId});
  }

  void startTyping({String? conversationId, required String receiverId}) {
    if (!_isConnected || _socket == null) return;
    _socket!.emit('message:typing', {
      'conversationId': conversationId,
      'receiverId': receiverId,
    });
  }

  void stopTyping({String? conversationId, required String receiverId}) {
    if (!_isConnected || _socket == null) return;
    _socket!.emit('message:stop-typing', {
      'conversationId': conversationId,
      'receiverId': receiverId,
    });
  }

  void markAsRead({
    required String conversationId,
    List<String>? messageIds,
    String? readerId,
  }) {
    if (!_isConnected || _socket == null) return;
    _socket!.emit('message:read', {
      'conversationId': conversationId,
      'messageIds': messageIds,
      'readerId': readerId,
    });
  }

  void deleteMessage({
    required String messageId,
    required String conversationId,
    required String deleteType,
  }) {
    if (!_isConnected || _socket == null) {
      print('❌ Socket not connected');
      return;
    }
    _socket!.emit('message:delete', {
      'messageId': messageId,
      'conversationId': conversationId,
      'deleteType': deleteType,
    });
  }

  void getConversations() {
    if (!_isConnected || _socket == null) return;
    _socket!.emit('conversation:get-list', {});
  }

  void getAllUsers({String? search, int page = 1, int limit = 50}) {
    if (!_isConnected || _socket == null) return;
    _socket!.emit('user:get-all', {
      'search': search,
      'page': page,
      'limit': limit,
    });
  }

  void disconnect() {
    print('🔌 Socket: disconnecting (currentUser=$_currentUserId, firebaseUid=$_connectedFirebaseUid)');
    _socket?.clearListeners();
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _isConnected = false;
    _connectionController.add(false);
  }

  /// Reset state for user switch - call this on logout
  void reset() {
    print('🔌 Socket: resetting for user switch');
    disconnect();
    _currentUserId = null;
    _connectedFirebaseUid = null;
  }
}
