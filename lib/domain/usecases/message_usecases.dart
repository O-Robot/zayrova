import 'package:zayrova/core/utils/api_result.dart';
import 'package:zayrova/domain/entities/conversation_entity.dart';
import 'package:zayrova/domain/entities/message_entity.dart';
import 'package:zayrova/domain/repositories/message_repository.dart';

class GetConversationsUseCase {
  const GetConversationsUseCase(this._repository);

  final MessageRepository _repository;

  Future<ApiResult<List<Conversation>>> call() {
    return _repository.getConversations();
  }
}

class GetMessagesUseCase {
  const GetMessagesUseCase(this._repository);

  final MessageRepository _repository;

  Future<ApiResult<List<Message>>> call(String conversationId) {
    return _repository.getMessages(conversationId);
  }
}

class SendMessageUseCase {
  const SendMessageUseCase(this._repository);

  final MessageRepository _repository;

  Future<ApiResult<Message>> call({
    required String conversationId,
    required String body,
    List<String> attachmentUrls = const [],
  }) {
    return _repository.sendMessage(
      conversationId: conversationId,
      body: body,
      attachmentUrls: attachmentUrls,
    );
  }
}
