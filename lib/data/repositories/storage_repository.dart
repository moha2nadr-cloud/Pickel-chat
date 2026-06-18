import '../models/conversation_model.dart';
import '../models/settings_model.dart';
import '../services/local_storage_service.dart';

class StorageRepository {
  StorageRepository(this._storageService);

  final LocalStorageService _storageService;

  Future<List<ConversationModel>> getConversations() async {
    final list = _storageService.conversationsBox.values.toList();
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  Future<void> upsertConversation(ConversationModel conversation) async {
    await _storageService.conversationsBox.put(conversation.id, conversation);
  }

  Future<void> deleteConversation(String id) async {
    await _storageService.conversationsBox.delete(id);
  }

  Future<void> clearConversations() async {
    await _storageService.conversationsBox.clear();
  }

  SettingsModel getSettings() {
    return _storageService.settingsBox.get('settings') ?? SettingsModel();
  }

  Future<void> saveSettings(SettingsModel settings) async {
    await _storageService.settingsBox.put('settings', settings);
  }
}
