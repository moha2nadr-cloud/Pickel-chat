import 'dart:async';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/message_model.dart';
import '../../data/repositories/chat_repository.dart';
import '../../data/repositories/storage_repository.dart';
import 'conversation_provider.dart';
import 'settings_provider.dart';

class ChatProvider extends ChangeNotifier {
  ChatProvider({
    required ChatRepository chatRepository,
    required StorageRepository storageRepository,
  })  : _chatRepository = chatRepository,
        _storageRepository = storageRepository;

  final ChatRepository _chatRepository;
  final StorageRepository _storageRepository;
  final _uuid = const Uuid();

  ConversationProvider? _conversationProvider;
  SettingsProvider? _settingsProvider;

  bool _isResponding = false;
  String? _attachedFileName;
  String? _attachedFileContent;
  StreamSubscription<String>? _streamSubscription;

  bool get isResponding => _isResponding;
  String? get attachedFileName => _attachedFileName;
  String? get attachedFileContent => _attachedFileContent;

  void setConversationProvider(ConversationProvider provider) {
    _conversationProvider = provider;
  }

  void setSettingsProvider(SettingsProvider provider) {
    _settingsProvider = provider;
  }

  Future<void> attachFile({required String fileName, required String content}) async {
    _attachedFileName = fileName;
    _attachedFileContent = content;
    notifyListeners();
  }

  void clearAttachment() {
    _attachedFileName = null;
    _attachedFileContent = null;
    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    final conversationProvider = _conversationProvider;
    final settingsProvider = _settingsProvider;
    if (conversationProvider == null || settingsProvider == null || text.trim().isEmpty) {
      return;
    }

    if (settingsProvider.apiKey.isEmpty) {
      throw Exception('Please set API key in Settings');
    }

    final conversation = conversationProvider.selectedConversation ??
        await conversationProvider.createConversation();

    final userMessage = MessageModel(
      id: _uuid.v4(),
      role: 'user',
      content: text.trim(),
      attachedFileName: _attachedFileName,
      attachedFileContent: _attachedFileContent,
      timestamp: DateTime.now(),
    );
    await conversationProvider.saveMessage(conversation.id, userMessage);

    final assistantMessage = MessageModel(
      id: _uuid.v4(),
      role: 'assistant',
      content: '',
      timestamp: DateTime.now(),
    );
    await conversationProvider.saveMessage(conversation.id, assistantMessage);

    _isResponding = true;
    clearAttachment();

    final history = conversationProvider.selectedConversation?.messages ?? [];
    final buffer = StringBuffer();

    _streamSubscription = _chatRepository
        .streamReply(apiKey: settingsProvider.apiKey, history: history)
        .listen((chunk) async {
      buffer.write(chunk);
      await conversationProvider.updateLastAssistantMessage(
        conversation.id,
        buffer.toString(),
      );
      notifyListeners();
    }, onError: (error) async {
      await conversationProvider.updateLastAssistantMessage(
        conversation.id,
        'حدث خطأ. حاول مرة أخرى.\n$error',
      );
      _isResponding = false;
      notifyListeners();
    }, onDone: () {
      _isResponding = false;
      notifyListeners();
    });
  }

  Future<void> cancelStreaming() async {
    await _streamSubscription?.cancel();
    _streamSubscription = null;
    _isResponding = false;
    notifyListeners();
  }

  Future<void> deleteMessage(String conversationId, String messageId) async {
    final conversation = _conversationProvider?.selectedConversation;
    if (conversation == null) return;
    final updated = conversation.messages.where((m) => m.id != messageId).toList();
    await _storageRepository.upsertConversation(
      conversation.copyWith(messages: updated, updatedAt: DateTime.now()),
    );
    await _conversationProvider?.loadConversations();
  }
}
