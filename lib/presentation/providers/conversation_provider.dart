import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/conversation_model.dart';
import '../../data/models/message_model.dart';
import '../../data/repositories/storage_repository.dart';

class ConversationProvider extends ChangeNotifier {
  ConversationProvider({required StorageRepository storageRepository})
      : _storageRepository = storageRepository;

  final StorageRepository _storageRepository;
  final _uuid = const Uuid();

  List<ConversationModel> _conversations = [];
  String? _selectedConversationId;

  List<ConversationModel> get conversations => _conversations;
  String? get selectedConversationId => _selectedConversationId;

  ConversationModel? get selectedConversation {
    if (_selectedConversationId == null || _conversations.isEmpty) return null;
    for (final conversation in _conversations) {
      if (conversation.id == _selectedConversationId) return conversation;
    }
    return _conversations.first;
  }

  Future<void> loadConversations() async {
    _conversations = await _storageRepository.getConversations();
    _selectedConversationId = _conversations.isNotEmpty ? _conversations.first.id : null;
    notifyListeners();
  }

  Future<ConversationModel> createConversation() async {
    final now = DateTime.now();
    final conversation = ConversationModel(
      id: _uuid.v4(),
      title: 'New Chat',
      messages: [],
      createdAt: now,
      updatedAt: now,
    );
    await _storageRepository.upsertConversation(conversation);
    await loadConversations();
    _selectedConversationId = conversation.id;
    notifyListeners();
    return conversation;
  }

  void selectConversation(String id) {
    _selectedConversationId = id;
    notifyListeners();
  }

  Future<void> saveMessage(String conversationId, MessageModel message) async {
    final existing = _conversations.firstWhere((e) => e.id == conversationId);
    final updatedMessages = [...existing.messages, message];
    final title = existing.messages.isEmpty && message.role == 'user'
        ? ConversationModel.titleFromText(message.content)
        : existing.title;

    await _storageRepository.upsertConversation(
      existing.copyWith(
        title: title,
        messages: updatedMessages,
        updatedAt: DateTime.now(),
      ),
    );
    await loadConversations();
    _selectedConversationId = conversationId;
  }

  Future<void> updateLastAssistantMessage(String conversationId, String content) async {
    final existing = _conversations.firstWhere((e) => e.id == conversationId);
    if (existing.messages.isEmpty) return;

    final updated = [...existing.messages];
    final last = updated.last;
    updated[updated.length - 1] = last.copyWith(content: content);

    await _storageRepository.upsertConversation(
      existing.copyWith(messages: updated, updatedAt: DateTime.now()),
    );
    await loadConversations();
  }

  Future<void> renameConversation(String id, String title) async {
    final existing = _conversations.firstWhere((e) => e.id == id);
    await _storageRepository.upsertConversation(
      existing.copyWith(title: title, updatedAt: DateTime.now()),
    );
    await loadConversations();
  }

  Future<void> deleteConversation(String id) async {
    await _storageRepository.deleteConversation(id);
    await loadConversations();
  }

  Future<void> clearAll() async {
    await _storageRepository.clearConversations();
    await loadConversations();
  }
}
