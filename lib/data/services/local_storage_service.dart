import 'package:hive_flutter/hive_flutter.dart';

import '../models/conversation_model.dart';
import '../models/message_model.dart';
import '../models/settings_model.dart';

class LocalStorageService {
  static const String conversationsBoxName = 'conversations';
  static const String settingsBoxName = 'settings';

  Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(MessageModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ConversationModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(SettingsModelAdapter());
    }
    await Hive.openBox<ConversationModel>(conversationsBoxName);
    await Hive.openBox<SettingsModel>(settingsBoxName);
  }

  Box<ConversationModel> get conversationsBox =>
      Hive.box<ConversationModel>(conversationsBoxName);

  Box<SettingsModel> get settingsBox => Hive.box<SettingsModel>(settingsBoxName);
}
