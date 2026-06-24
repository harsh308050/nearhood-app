import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearhood/features/chat/bloc/chat_event.dart';
import 'package:nearhood/features/chat/bloc/chat_state.dart';
import 'package:nearhood/features/chat/models/message_model.dart';
import 'package:nearhood/features/chat/models/conversation_model.dart';
import 'package:nearhood/features/chat/services/socket_service.dart';
import 'package:nearhood/features/chat/services/chat_api_service.dart';
import 'package:nearhood/core/constants/app_strings.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final SocketService _socketService;
  final ChatApiService _chatApiService;
  StreamSubscription? _messageSubscription;
  StreamSubscription? _conversationSubscription;
  StreamSubscription? _userListSubscription;
  StreamSubscription? _typingSubscription;
  StreamSubscription? _connectionSubscription;
  StreamSubscription? _readReceiptSubscription;
  StreamSubscription? _messageDeletedSubscription;
  StreamSubscription? _messageEditedSubscription;
  StreamSubscription? _messageErrorSubscription;

  ChatBloc({SocketService? socketService, ChatApiService? chatApiService})
    : _socketService = socketService ?? SocketService(),
      _chatApiService = chatApiService ?? ChatApiService(),
      super(const ChatState()) {
    on<ConnectSocket>(_onConnectSocket);
    on<DisconnectSocket>(_onDisconnectSocket);
    on<LoadConversations>(_onLoadConversations);
    on<LoadMessages>(_onLoadMessages);
    on<LoadAllUsers>(_onLoadAllUsers);
    on<SearchUsers>(_onSearchUsers);
    on<SendMessage>(_onSendMessage);
    on<CreateConversation>(_onCreateConversation);
    on<JoinConversation>(_onJoinConversation);
    on<LeaveConversation>(_onLeaveConversation);
    on<StartTyping>(_onStartTyping);
    on<StopTyping>(_onStopTyping);
    on<MarkAsRead>(_onMarkAsRead);
    on<MessageReceived>(_onMessageReceived);
    on<ConversationsLoaded>(_onConversationsLoaded);
    on<UsersLoaded>(_onUsersLoaded);
    on<TypingIndicator>(_onTypingIndicator);
    on<ReadReceiptReceived>(_onReadReceiptReceived);
    on<ConnectionChanged>(_onConnectionChanged);
    on<LoadMoreMessages>(_onLoadMoreMessages);
    on<DeleteMessage>(_onDeleteMessage);
    on<MessageDeleted>(_onMessageDeleted);
    on<HideConversation>(_onHideConversation);
    on<SetReplyTo>(_onSetReplyTo);
    on<ClearReplyTo>(_onClearReplyTo);
    on<EditMessage>(_onEditMessage);
    on<MessageEdited>(_onMessageEdited);
    on<SetEditingMessage>(_onSetEditingMessage);
    on<ClearEditingMessage>(_onClearEditingMessage);
    on<BlockUser>(_onBlockUser);
    on<UnblockUser>(_onUnblockUser);
    on<MessageError>(_onMessageError);
    on<LoadBlockedUsers>(_onLoadBlockedUsers);

    _setupSocketListeners();
  }

  void _setupSocketListeners() {
    _messageSubscription = _socketService.messageStream.listen((message) {
      add(MessageReceived(message));
    });

    _conversationSubscription = _socketService.conversationStream.listen((
      conversations,
    ) {
      add(ConversationsLoaded(conversations));
    });

    _userListSubscription = _socketService.userListStream.listen((users) {
      add(UsersLoaded(users));
    });

    _typingSubscription = _socketService.typingStream.listen((data) {
      add(
        TypingIndicator(
          userId: data['userId'],
          conversationId: data['conversationId'],
          isTyping: data['isTyping'],
        ),
      );
    });

    _connectionSubscription = _socketService.connectionStream.listen((
      connected,
    ) {
      add(ConnectionChanged(connected));
    });

    _messageEditedSubscription = _socketService.messageEditedStream.listen((message) {
      add(MessageEdited(message));
    });

    _messageErrorSubscription = _socketService.messageErrorStream.listen((error) {
      add(MessageError(error));
    });

    _readReceiptSubscription = _socketService.readReceiptStream.listen((data) {
      add(
        ReadReceiptReceived(
          conversationId: data['conversationId'],
          messageIds: data['messageIds'],
          readBy: data['readBy'],
        ),
      );
    });

    _messageDeletedSubscription = _socketService.messageDeletedStream.listen((data) {
      add(
        MessageDeleted(
          messageId: data['messageId'],
          conversationId: data['conversationId'],
          isDeletedForEveryone: data['isDeleted'],
          deletedForMe: data['deletedForMe'],
          updatedMessage: data['message'] != null
              ? MessageModel.fromJson(data['message'])
              : null,
        ),
      );
    });
  }

  Future<void> _onConnectSocket(
    ConnectSocket event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await _socketService.connect();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onDisconnectSocket(
    DisconnectSocket event,
    Emitter<ChatState> emit,
  ) async {
    _socketService.disconnect();
    emit(state.copyWith(isConnected: false));
  }

  Future<void> _onLoadConversations(
    LoadConversations event,
    Emitter<ChatState> emit,
  ) async {
    emit(state.copyWith(isLoadingConversations: true, clearError: true));
    try {
      final conversations = await _chatApiService.getConversations();
      emit(
        state.copyWith(
          isLoadingConversations: false,
          conversations: conversations,
        ),
      );
    } catch (e) {
      emit(state.copyWith(
        isLoadingConversations: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onLoadMessages(
    LoadMessages event,
    Emitter<ChatState> emit,
  ) async {
    final isNewConversation = !event.isLoadMore;
    if (state.isLoadingMessages) return;

    emit(state.copyWith(
      isLoadingMessages: true,
      clearError: true,
      messages: isNewConversation ? const [] : state.messages,
      messagesPage: isNewConversation ? 1 : state.messagesPage,
    ));
    try {
      final page = isNewConversation ? 1 : state.messagesPage;
      final messages = await _chatApiService.getMessages(
        event.conversationId,
        page: page,
      );
      final allMessages = page == 1
          ? messages
          : [...messages, ...state.messages];
      emit(
        state.copyWith(
          isLoadingMessages: false,
          messages: allMessages,
          currentConversationId: event.conversationId,
          messagesPage: page,
          hasMoreMessages: messages.length >= 50,
        ),
      );
    } catch (e) {
      emit(state.copyWith(
        isLoadingMessages: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onLoadAllUsers(
    LoadAllUsers event,
    Emitter<ChatState> emit,
  ) async {
    emit(state.copyWith(isLoadingUsers: true, clearError: true));
    try {
      final users = await _chatApiService.getChatUsers(search: event.search);
      emit(
        state.copyWith(
          isLoadingUsers: false,
          allUsers: users,
          filteredUsers: users,
        ),
      );
    } catch (e) {
      emit(state.copyWith(
        isLoadingUsers: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onSearchUsers(
    SearchUsers event,
    Emitter<ChatState> emit,
  ) async {
    final query = event.query.toLowerCase();
    if (query.isEmpty) {
      emit(state.copyWith(filteredUsers: state.allUsers, clearSearchQuery: true));
    } else {
      final filtered = state.allUsers.where((user) {
        return user.fullName.toLowerCase().contains(query) ||
            user.locality.toLowerCase().contains(query);
      }).toList();
      emit(state.copyWith(filteredUsers: filtered, searchQuery: event.query));
    }
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    try {
      print('💬 ChatBloc: sending message: receiverId=${event.receiverId}, conversationId=${event.conversationId}');
      _socketService.sendMessage(
        receiverId: event.receiverId,
        content: event.content,
        messageType: event.messageType,
        mediaUrl: event.mediaUrl,
        conversationId: event.conversationId,
        replyToMessageId: event.replyToMessageId,
      );
      emit(state.copyWith(clearReplyToMessage: true));
    } catch (e) {
      print('❌ ChatBloc: send message error: $e');
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onCreateConversation(
    CreateConversation event,
    Emitter<ChatState> emit,
  ) async {
    emit(state.copyWith(status: ChatStatus.loading, clearError: true));
    try {
      final conversation = await _chatApiService.createConversation(
        event.receiverId,
      );
      emit(
        state.copyWith(
          status: ChatStatus.loaded,
          currentConversationId: conversation.id,
          selectedUser: conversation.otherUser,
          clearSelectedUser: false,
          isCurrentConversationBlocked: conversation.isBlocked,
          isBlockedByOther: conversation.blockedByOther,
        ),
      );
    } catch (e) {
      emit(state.copyWith(
        status: ChatStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onJoinConversation(
    JoinConversation event,
    Emitter<ChatState> emit,
  ) async {
    _socketService.joinConversation(event.conversationId);

    // Look up block state from conversations list
    final conv = state.conversations.where((c) => c.id == event.conversationId).firstOrNull;
    emit(state.copyWith(
      currentConversationId: event.conversationId,
      isCurrentConversationBlocked: conv?.isBlocked ?? false,
      isBlockedByOther: conv?.blockedByOther ?? false,
    ));
  }

  Future<void> _onLeaveConversation(
    LeaveConversation event,
    Emitter<ChatState> emit,
  ) async {
    _socketService.leaveConversation(event.conversationId);
    emit(state.copyWith(
      clearCurrentConversationId: true,
      clearSelectedUser: true,
      messages: const [],
      messagesPage: 1,
      hasMoreMessages: true,
      typingUsers: const {},
      isCurrentConversationBlocked: false,
      isBlockedByOther: false,
    ));
  }

  Future<void> _onStartTyping(
    StartTyping event,
    Emitter<ChatState> emit,
  ) async {
    _socketService.startTyping(
      conversationId: event.conversationId,
      receiverId: event.receiverId,
    );
  }

  Future<void> _onStopTyping(StopTyping event, Emitter<ChatState> emit) async {
    _socketService.stopTyping(
      conversationId: event.conversationId,
      receiverId: event.receiverId,
    );
  }

  Future<void> _onMarkAsRead(MarkAsRead event, Emitter<ChatState> emit) async {
    _socketService.markAsRead(
      conversationId: event.conversationId,
      messageIds: event.messageIds,
      readerId: event.readerId,
    );
  }

  void _onMessageReceived(MessageReceived event, Emitter<ChatState> emit) {
    final message = event.message;
    final currentUserId = _socketService.currentUserId;
    print('💬 ChatBloc: message:new received in Bloc: messageId=${message.id}, conversationId=${message.conversationId}, state.currentConversationId=${state.currentConversationId}');

    if (state.currentConversationId == message.conversationId) {
      final updatedMessages = List<MessageModel>.from(state.messages);
      if (!updatedMessages.any((m) => m.id == message.id)) {
        updatedMessages.add(message);
        emit(state.copyWith(messages: updatedMessages));
        print('💬 ChatBloc: message added to active DM messages list. New length: ${updatedMessages.length}');
      }
    } else {
      print('💬 ChatBloc: message ignored in DM (not active conversation)');
    }

    final updatedConversations = List<ConversationModel>.from(state.conversations);
    final convIndex = updatedConversations.indexWhere((c) => c.id == message.conversationId);
    if (convIndex >= 0) {
      final conv = updatedConversations[convIndex];
      final isFromMe = message.senderId == currentUserId;
      final updatedConv = conv.copyWith(
        lastMessage: MessagePreview(
          content: message.content,
          sender: message.senderId,
          createdAt: message.createdAt,
        ),
        unreadCount: isFromMe ? conv.unreadCount : conv.unreadCount + 1,
        updatedAt: message.createdAt,
      );
      updatedConversations.removeAt(convIndex);
      updatedConversations.insert(0, updatedConv);
      emit(state.copyWith(conversations: updatedConversations));
      print('💬 ChatBloc: conversation list updated. unreadCount=${updatedConv.unreadCount}');
    } else {
      // Conversation not in list (was hidden or new), reload from API
      add(LoadConversations());
    }
  }

  void _onConversationsLoaded(
    ConversationsLoaded event,
    Emitter<ChatState> emit,
  ) {
    emit(state.copyWith(
      conversations: event.conversations,
      isLoadingConversations: false,
    ));
  }

  void _onUsersLoaded(UsersLoaded event, Emitter<ChatState> emit) {
    emit(state.copyWith(
      allUsers: event.users,
      filteredUsers: event.users,
      isLoadingUsers: false,
    ));
  }

  void _onTypingIndicator(TypingIndicator event, Emitter<ChatState> emit) {
    final updatedTyping = Map<String, bool>.from(state.typingUsers);
    updatedTyping[event.userId] = event.isTyping;
    emit(state.copyWith(typingUsers: updatedTyping));
  }

  void _onReadReceiptReceived(
    ReadReceiptReceived event,
    Emitter<ChatState> emit,
  ) {
    final updatedMessages = state.messages.map((msg) {
      if (event.messageIds?.contains(msg.id) == true) {
        return msg.copyWith(isRead: true, readAt: DateTime.now());
      }
      return msg;
    }).toList();
    emit(state.copyWith(messages: updatedMessages));
  }

  void _onConnectionChanged(
    ConnectionChanged event,
    Emitter<ChatState> emit,
  ) {
    emit(state.copyWith(isConnected: event.isConnected));
  }

  void _onLoadMoreMessages(
    LoadMoreMessages event,
    Emitter<ChatState> emit,
  ) {
    if (!state.hasMoreMessages || state.isLoadingMessages) return;
    emit(state.copyWith(messagesPage: state.messagesPage + 1));
    if (state.currentConversationId != null) {
      add(LoadMessages(state.currentConversationId!, isLoadMore: true));
    }
  }

  Future<void> _onDeleteMessage(
    DeleteMessage event,
    Emitter<ChatState> emit,
  ) async {
    try {
      _socketService.deleteMessage(
        messageId: event.messageId,
        conversationId: event.conversationId,
        deleteType: event.deleteType,
      );
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  void _onMessageDeleted(MessageDeleted event, Emitter<ChatState> emit) {
    if (state.currentConversationId == event.conversationId) {
      final updatedMessages = List<MessageModel>.from(state.messages);

      if (event.deletedForMe == true) {
        updatedMessages.removeWhere((m) => m.id == event.messageId);
        emit(state.copyWith(messages: updatedMessages));
      } else if (event.isDeletedForEveryone == true && event.updatedMessage != null) {
        final index = updatedMessages.indexWhere((m) => m.id == event.messageId);
        if (index >= 0) {
          updatedMessages[index] = event.updatedMessage!;
          emit(state.copyWith(messages: updatedMessages));
        }
      }
    }

    final updatedConversations = List<ConversationModel>.from(state.conversations);
    final convIndex = updatedConversations.indexWhere((c) => c.id == event.conversationId);
    if (convIndex >= 0) {
      final conv = updatedConversations[convIndex];
      if (event.isDeletedForEveryone == true) {
        final updatedConv = conv.copyWith(
          lastMessage: MessagePreview(
            content: AppStrings.chatMessageWasDeleted,
            sender: event.updatedMessage?.senderId ?? conv.lastMessage?.sender ?? '',
            createdAt: event.updatedMessage?.createdAt ?? conv.lastMessage?.createdAt ?? DateTime.now(),
          ),
        );
        updatedConversations[convIndex] = updatedConv;
        emit(state.copyWith(conversations: updatedConversations));
      }
    }
  }

  void _onHideConversation(
    HideConversation event,
    Emitter<ChatState> emit,
  ) async {
    final updatedConversations = List<ConversationModel>.from(state.conversations);
    updatedConversations.removeWhere((c) => c.id == event.conversationId);
    emit(state.copyWith(conversations: updatedConversations));

    try {
      await _chatApiService.hideConversation(event.conversationId);
    } catch (e) {
      // If API fails, reload to restore the conversation
      add(LoadConversations());
    }
  }

  void _onSetReplyTo(SetReplyTo event, Emitter<ChatState> emit) {
    emit(state.copyWith(replyToMessage: event.message));
  }

  void _onClearReplyTo(ClearReplyTo event, Emitter<ChatState> emit) {
    emit(state.copyWith(clearReplyToMessage: true));
  }

  void _onEditMessage(EditMessage event, Emitter<ChatState> emit) async {
    try {
      _socketService.editMessage(
        messageId: event.messageId,
        content: event.content,
      );
      emit(state.copyWith(clearEditingMessage: true));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  void _onMessageEdited(MessageEdited event, Emitter<ChatState> emit) {
    final updatedMessages = List<MessageModel>.from(state.messages);
    final index = updatedMessages.indexWhere((m) => m.id == event.message.id);
    if (index >= 0) {
      updatedMessages[index] = event.message;
      emit(state.copyWith(messages: updatedMessages));
    }
  }

  void _onSetEditingMessage(SetEditingMessage event, Emitter<ChatState> emit) {
    emit(state.copyWith(editingMessage: event.message));
  }

  void _onClearEditingMessage(ClearEditingMessage event, Emitter<ChatState> emit) {
    emit(state.copyWith(clearEditingMessage: true));
  }

  Future<void> _onBlockUser(BlockUser event, Emitter<ChatState> emit) async {
    try {
      // Emit immediately so the UI hides the input and shows the banner
      final updatedConversations = List<ConversationModel>.from(state.conversations);
      final convIndex = updatedConversations.indexWhere(
        (c) => c.otherUser?.id == event.targetUserId
      );
      if (convIndex >= 0) {
        updatedConversations[convIndex] = updatedConversations[convIndex].copyWith(isBlocked: true);
      }
      emit(state.copyWith(
        conversations: updatedConversations,
        isCurrentConversationBlocked: true,
      ));

      await _chatApiService.blockUser(event.targetUserId);
    } catch (e) {
      // If API fails, revert
      add(LoadConversations());
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onUnblockUser(UnblockUser event, Emitter<ChatState> emit) async {
    try {
      // Emit immediately so the UI restores the input
      final updatedConversations = List<ConversationModel>.from(state.conversations);
      final convIndex = updatedConversations.indexWhere(
        (c) => c.otherUser?.id == event.targetUserId
      );
      if (convIndex >= 0) {
        updatedConversations[convIndex] = updatedConversations[convIndex].copyWith(isBlocked: false);
      }
      emit(state.copyWith(
        conversations: updatedConversations,
        isCurrentConversationBlocked: false,
      ));

      await _chatApiService.unblockUser(event.targetUserId);
    } catch (e) {
      add(LoadConversations());
      emit(state.copyWith(error: e.toString()));
    }
  }

  void _onMessageError(MessageError event, Emitter<ChatState> emit) {
    emit(state.copyWith(error: event.error));
  }

  void _onLoadBlockedUsers(LoadBlockedUsers event, Emitter<ChatState> emit) {
    final blocked = state.conversations.where((c) => c.isBlocked).toList();
    emit(state.copyWith(blockedUsers: blocked));
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    _conversationSubscription?.cancel();
    _userListSubscription?.cancel();
    _typingSubscription?.cancel();
    _connectionSubscription?.cancel();
    _readReceiptSubscription?.cancel();
    _messageDeletedSubscription?.cancel();
    _messageEditedSubscription?.cancel();
    _messageErrorSubscription?.cancel();
    return super.close();
  }
}
