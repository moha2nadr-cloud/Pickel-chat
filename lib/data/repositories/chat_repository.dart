import '../models/message_model.dart';
import '../services/api_service.dart';

class ChatRepository {
  ChatRepository(this._apiService);

  final ApiService _apiService;

  Stream<String> streamReply({
    required String apiKey,
    required List<MessageModel> history,
  }) {
    return _apiService.streamChatCompletion(
      apiKey: apiKey,
      messages: history.map((e) => e.toApiJson()).toList(),
    );
  }
}
