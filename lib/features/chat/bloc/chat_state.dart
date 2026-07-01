import 'package:equatable/equatable.dart';
import 'package:nearhood/features/chat/models/message_model.dart';
import 'package:nearhood/features/chat/models/conversation_model.dart';
import 'package:nearhood/features/chat/models/chat_user.dart';

enum ChatStatus { initial, loading, loaded, error }

class ChatState extends Equatable {
  final ChatStatus status;
  final bool isLoadingConversations;
  final bool isLoadingUsers;
  final bool isLoadingMessages;
  final List<ConversationModel> conversations;
  final List<ChatUser> allUsers;
  final List<ChatUser> filteredUsers;
  final List<MessageModel> messages;
  final List<MessageModel> uploadingMessages;
  final String? currentConversationId;
  final ChatUser? selectedUser;
  final bool isConnected;
  final Map<String, bool> typingUsers;
  final String? error;
  final String? searchQuery;
  final int messagesPage;
  final bool hasMoreMessages;
  final MessageModel? replyToMessage;
  final MessageModel? editingMessage;
  final bool isCurrentConversationBlocked;
  final bool isBlockedByOther;
  final List<ConversationModel> blockedUsers;

  const ChatState({
    this.status = ChatStatus.initial,
    this.isLoadingConversations = false,
    this.isLoadingUsers = false,
    this.isLoadingMessages = false,
    this.conversations = const [],
    this.allUsers = const [],
    this.filteredUsers = const [],
    this.messages = const [],
    this.uploadingMessages = const [],
    this.currentConversationId,
    this.selectedUser,
    this.isConnected = false,
    this.typingUsers = const {},
    this.error,
    this.searchQuery,
    this.messagesPage = 1,
    this.hasMoreMessages = true,
    this.replyToMessage,
    this.editingMessage,
    this.isCurrentConversationBlocked = false,
    this.isBlockedByOther = false,
    this.blockedUsers = const [],
  });

  ChatState copyWith({
    ChatStatus? status,
    bool? isLoadingConversations,
    bool? isLoadingUsers,
    bool? isLoadingMessages,
    List<ConversationModel>? conversations,
    List<ChatUser>? allUsers,
    List<ChatUser>? filteredUsers,
    List<MessageModel>? messages,
    List<MessageModel>? uploadingMessages,
    String? currentConversationId,
    ChatUser? selectedUser,
    bool? isConnected,
    Map<String, bool>? typingUsers,
    String? error,
    String? searchQuery,
    int? messagesPage,
    bool? hasMoreMessages,
    MessageModel? replyToMessage,
    MessageModel? editingMessage,
    bool? isCurrentConversationBlocked,
    bool? isBlockedByOther,
    bool clearSelectedUser = false,
    bool clearError = false,
    bool clearSearchQuery = false,
    bool clearCurrentConversationId = false,
    bool clearReplyToMessage = false,
    bool clearEditingMessage = false,
    List<ConversationModel>? blockedUsers,
  }) {
    return ChatState(
      status: status ?? this.status,
      isLoadingConversations: isLoadingConversations ?? this.isLoadingConversations,
      isLoadingUsers: isLoadingUsers ?? this.isLoadingUsers,
      isLoadingMessages: isLoadingMessages ?? this.isLoadingMessages,
      conversations: conversations ?? this.conversations,
      allUsers: allUsers ?? this.allUsers,
      filteredUsers: filteredUsers ?? this.filteredUsers,
      messages: messages ?? this.messages,
      uploadingMessages: uploadingMessages ?? this.uploadingMessages,
      currentConversationId:
          clearCurrentConversationId ? null : (currentConversationId ?? this.currentConversationId),
      selectedUser: clearSelectedUser ? null : (selectedUser ?? this.selectedUser),
      isConnected: isConnected ?? this.isConnected,
      typingUsers: typingUsers ?? this.typingUsers,
      error: clearError ? null : (error ?? this.error),
      searchQuery: clearSearchQuery ? null : (searchQuery ?? this.searchQuery),
      messagesPage: messagesPage ?? this.messagesPage,
      hasMoreMessages: hasMoreMessages ?? this.hasMoreMessages,
      replyToMessage: clearReplyToMessage ? null : (replyToMessage ?? this.replyToMessage),
      editingMessage: clearEditingMessage ? null : (editingMessage ?? this.editingMessage),
      isCurrentConversationBlocked: isCurrentConversationBlocked ?? this.isCurrentConversationBlocked,
      isBlockedByOther: isBlockedByOther ?? this.isBlockedByOther,
      blockedUsers: blockedUsers ?? this.blockedUsers,
    );
  }

  @override
  List<Object?> get props => [
        status,
        isLoadingConversations,
        isLoadingUsers,
        isLoadingMessages,
        conversations,
        allUsers,
        filteredUsers,
        messages,
        uploadingMessages,
        currentConversationId,
        selectedUser,
        isConnected,
        typingUsers,
        error,
        searchQuery,
        messagesPage,
        hasMoreMessages,
        replyToMessage,
        editingMessage,
        isCurrentConversationBlocked,
        isBlockedByOther,
        blockedUsers,
      ];
}
