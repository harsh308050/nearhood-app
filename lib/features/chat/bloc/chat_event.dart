import 'package:equatable/equatable.dart';
import 'package:nearhood/features/chat/models/message_model.dart';
import 'package:nearhood/features/chat/models/conversation_model.dart';
import 'package:nearhood/features/chat/models/chat_user.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class ConnectSocket extends ChatEvent {}

class DisconnectSocket extends ChatEvent {}

class LoadConversations extends ChatEvent {}

class LoadMessages extends ChatEvent {
  final String conversationId;
  final bool isLoadMore;
  const LoadMessages(this.conversationId, {this.isLoadMore = false});

  @override
  List<Object?> get props => [conversationId, isLoadMore];
}

class LoadAllUsers extends ChatEvent {
  final String? search;
  const LoadAllUsers({this.search});

  @override
  List<Object?> get props => [search];
}

class SearchUsers extends ChatEvent {
  final String query;
  const SearchUsers(this.query);

  @override
  List<Object?> get props => [query];
}

class SendMessage extends ChatEvent {
  final String receiverId;
  final String content;
  final String? conversationId;
  final String messageType;
  final String? mediaUrl;
  final String? replyToMessageId;
  final Map<String, dynamic>? location;
  final String? clientMessageId;
  final int? duration;
  final String? postId;
  final PostSnapshot? postSnapshot;

  const SendMessage({
    required this.receiverId,
    required this.content,
    this.conversationId,
    this.messageType = 'text',
    this.mediaUrl,
    this.replyToMessageId,
    this.location,
    this.clientMessageId,
    this.duration,
    this.postId,
    this.postSnapshot,
  });

  @override
  List<Object?> get props =>
      [receiverId, content, conversationId, messageType, mediaUrl, replyToMessageId, location, clientMessageId, duration, postId, postSnapshot];
}

class CreateConversation extends ChatEvent {
  final String receiverId;
  const CreateConversation(this.receiverId);

  @override
  List<Object?> get props => [receiverId];
}

class JoinConversation extends ChatEvent {
  final String conversationId;
  const JoinConversation(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
}

class LeaveConversation extends ChatEvent {
  final String conversationId;
  const LeaveConversation(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
}

class StartTyping extends ChatEvent {
  final String? conversationId;
  final String receiverId;
  const StartTyping({this.conversationId, required this.receiverId});

  @override
  List<Object?> get props => [conversationId, receiverId];
}

class StopTyping extends ChatEvent {
  final String? conversationId;
  final String receiverId;
  const StopTyping({this.conversationId, required this.receiverId});

  @override
  List<Object?> get props => [conversationId, receiverId];
}

class MarkAsRead extends ChatEvent {
  final String conversationId;
  final List<String>? messageIds;
  final String? readerId;
  const MarkAsRead({required this.conversationId, this.messageIds, this.readerId});

  @override
  List<Object?> get props => [conversationId, messageIds, readerId];
}

class MessageReceived extends ChatEvent {
  final MessageModel message;
  const MessageReceived(this.message);

  @override
  List<Object?> get props => [message];
}

class ConversationsLoaded extends ChatEvent {
  final List<ConversationModel> conversations;
  const ConversationsLoaded(this.conversations);

  @override
  List<Object?> get props => [conversations];
}

class UsersLoaded extends ChatEvent {
  final List<ChatUser> users;
  const UsersLoaded(this.users);

  @override
  List<Object?> get props => [users];
}

class TypingIndicator extends ChatEvent {
  final String userId;
  final String? conversationId;
  final bool isTyping;
  const TypingIndicator({
    required this.userId,
    this.conversationId,
    required this.isTyping,
  });

  @override
  List<Object?> get props => [userId, conversationId, isTyping];
}

class ReadReceiptReceived extends ChatEvent {
  final String conversationId;
  final List<String>? messageIds;
  final String readBy;
  const ReadReceiptReceived({
    required this.conversationId,
    this.messageIds,
    required this.readBy,
  });

  @override
  List<Object?> get props => [conversationId, messageIds, readBy];
}

class ConnectionChanged extends ChatEvent {
  final bool isConnected;
  const ConnectionChanged(this.isConnected);

  @override
  List<Object?> get props => [isConnected];
}

class LoadMoreMessages extends ChatEvent {}

class DeleteMessage extends ChatEvent {
  final String messageId;
  final String conversationId;
  final String deleteType;

  const DeleteMessage({
    required this.messageId,
    required this.conversationId,
    required this.deleteType,
  });

  @override
  List<Object?> get props => [messageId, conversationId, deleteType];
}

class MessageDeleted extends ChatEvent {
  final String messageId;
  final String conversationId;
  final bool? isDeletedForEveryone;
  final bool? deletedForMe;
  final MessageModel? updatedMessage;

  const MessageDeleted({
    required this.messageId,
    required this.conversationId,
    this.isDeletedForEveryone,
    this.deletedForMe,
    this.updatedMessage,
  });

  @override
  List<Object?> get props => [
        messageId,
        conversationId,
        isDeletedForEveryone,
        deletedForMe,
        updatedMessage,
      ];
}

class HideConversation extends ChatEvent {
  final String conversationId;
  const HideConversation(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
}

class UnhideConversation extends ChatEvent {
  final String conversationId;
  const UnhideConversation(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
}

class SetReplyTo extends ChatEvent {
  final MessageModel message;
  const SetReplyTo(this.message);

  @override
  List<Object?> get props => [message];
}

class ClearReplyTo extends ChatEvent {}

class SetSharedPost extends ChatEvent {
  final String postId;
  const SetSharedPost(this.postId);

  @override
  List<Object?> get props => [postId];
}

class ClearSharedPost extends ChatEvent {}

class EditMessage extends ChatEvent {
  final String messageId;
  final String content;
  const EditMessage({required this.messageId, required this.content});

  @override
  List<Object?> get props => [messageId, content];
}

class MessageEdited extends ChatEvent {
  final MessageModel message;
  const MessageEdited(this.message);

  @override
  List<Object?> get props => [message];
}

class SetEditingMessage extends ChatEvent {
  final MessageModel message;
  const SetEditingMessage(this.message);

  @override
  List<Object?> get props => [message];
}

class ClearEditingMessage extends ChatEvent {}

class BlockUser extends ChatEvent {
  final String targetUserId;
  const BlockUser(this.targetUserId);

  @override
  List<Object?> get props => [targetUserId];
}

class UnblockUser extends ChatEvent {
  final String targetUserId;
  const UnblockUser(this.targetUserId);

  @override
  List<Object?> get props => [targetUserId];
}

class MessageError extends ChatEvent {
  final String error;
  const MessageError(this.error);

  @override
  List<Object?> get props => [error];
}

class LoadBlockedUsers extends ChatEvent {}

class MuteConversation extends ChatEvent {
  final String conversationId;
  const MuteConversation(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
}

class AddUploadingMessage extends ChatEvent {
  final MessageModel message;
  const AddUploadingMessage(this.message);

  @override
  List<Object?> get props => [message];
}

class UpdateUploadingMessage extends ChatEvent {
  final String clientMessageId;
  final String? mediaUrl;
  final double? uploadProgress;
  const UpdateUploadingMessage({
    required this.clientMessageId,
    this.mediaUrl,
    this.uploadProgress,
  });

  @override
  List<Object?> get props => [clientMessageId, mediaUrl, uploadProgress];
}

class RemoveUploadingMessage extends ChatEvent {
  final String clientMessageId;
  const RemoveUploadingMessage(this.clientMessageId);

  @override
  List<Object?> get props => [clientMessageId];
}
