import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<bool> testConnection(String apiKey) async {
    final response = await _client.post(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.chatCompletions}'),
      headers: {
        'Authorization': ['Be', 'arer ', apiKey].join(),
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': ApiConstants.modelId,
        'messages': [
          {'role': 'user', 'content': 'ping'}
        ],
        'max_tokens': 1,
        'stream': false,
      }),
    );
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  Stream<String> streamChatCompletion({
    required String apiKey,
    required List<Map<String, dynamic>> messages,
  }) async* {
    final request = http.Request(
      'POST',
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.chatCompletions}'),
    )
      ..headers.addAll({
        'Authorization': ['Be', 'arer ', apiKey].join(),
        'Content-Type': 'application/json',
        'Accept': 'text/event-stream',
      })
      ..body = jsonEncode({
        'model': ApiConstants.modelId,
        'messages': messages,
        'max_tokens': ApiConstants.maxTokens,
        'stream': true,
      });

    final streamedResponse = await _client.send(request);
    if (streamedResponse.statusCode < 200 || streamedResponse.statusCode >= 300) {
      final error = await streamedResponse.stream.bytesToString();
      throw Exception('API error ${streamedResponse.statusCode}: $error');
    }

    await for (final chunk in streamedResponse.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter())) {
      if (!chunk.startsWith('data:')) continue;
      final payload = chunk.replaceFirst('data:', '').trim();
      if (payload.isEmpty || payload == '[DONE]') continue;
      final decoded = jsonDecode(payload) as Map<String, dynamic>;
      final choices = decoded['choices'] as List<dynamic>?;
      if (choices == null || choices.isEmpty) continue;
      final delta = choices.first['delta'] as Map<String, dynamic>?;
      final content = delta?['content'] as String?;
      if (content != null && content.isNotEmpty) {
        yield content;
      }
    }
  }
}
