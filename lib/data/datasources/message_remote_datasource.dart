import 'package:zayrova/core/services/network/api_client.dart';
import 'package:zayrova/data/models/conversation_model.dart';
import 'package:zayrova/data/models/message_model.dart';

class MessageRemoteDatasource {
  const MessageRemoteDatasource(
    this._apiClient, {
    this.endpoint = '/messages',
  });

  final ApiClient _apiClient;
  final String endpoint;

  Future<List<ConversationModel>> getConversations() async {
    // TODO: Wire to the real conversations endpoint when backend support exists.
    final response = await _apiClient.get('$endpoint/conversations');
    final source = response is Map<String, dynamic>
        ? response['conversations']
        : response;

    if (source is! List) {
      return const [];
    }

    return source
        .whereType<Map<String, dynamic>>()
        .map(ConversationModel.fromJson)
        .toList();
  }

  Future<List<MessageModel>> getMessages(String conversationId) async {
    // TODO: Confirm final message endpoint shape with the backend.
    final response = await _apiClient.get(
      '$endpoint/conversations/$conversationId/messages',
    );
    final source = response is Map<String, dynamic>
        ? response['messages']
        : response;

    if (source is! List) {
      return const [];
    }

    return source
        .whereType<Map<String, dynamic>>()
        .map(MessageModel.fromJson)
        .toList();
  }

  Future<MessageModel> sendMessage({
    required String conversationId,
    required String body,
    List<String> attachmentUrls = const [],
  }) async {
    // TODO: Confirm final send-message endpoint shape with the backend.
    final response = await _apiClient.post(
      '$endpoint/conversations/$conversationId/messages',
      body: {'body': body, 'attachmentUrls': attachmentUrls},
    );

    if (response is Map<String, dynamic>) {
      return MessageModel.fromJson(response);
    }

    return MessageModel.fromJson(const <String, dynamic>{});
  }
}
