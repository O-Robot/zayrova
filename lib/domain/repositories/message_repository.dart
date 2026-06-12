import 'package:zayrova/core/utils/api_result.dart';
import 'package:zayrova/domain/entities/conversation_entity.dart';
import 'package:zayrova/domain/entities/message_entity.dart';

abstract class MessageRepository {
  Future<ApiResult<List<Conversation>>> getConversations();

  Future<ApiResult<List<Message>>> getMessages(String conversationId);

  Future<ApiResult<Message>> sendMessage({
    required String conversationId,
    required String body,
    List<String> attachmentUrls = const [],
  });
}
