import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'injection.dart';
import 'presentation/providers/chat_provider.dart';
import 'presentation/providers/conversation_provider.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/screens/home_screen.dart';

class PickleChatApp extends StatelessWidget {
  const PickleChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    final deps = AppDependencies.instance;
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(
            storageRepository: deps.storageRepository,
            apiService: deps.apiService,
          )..loadSettings(),
        ),
        ChangeNotifierProvider(
          create: (_) => ConversationProvider(
            storageRepository: deps.storageRepository,
          )..loadConversations(),
        ),
        ChangeNotifierProxyProvider2<ConversationProvider, SettingsProvider,
            ChatProvider>(
          create: (_) => ChatProvider(
            chatRepository: deps.chatRepository,
            storageRepository: deps.storageRepository,
          ),
          update: (_, conversations, settings, chatProvider) {
            chatProvider ??= ChatProvider(
              chatRepository: deps.chatRepository,
              storageRepository: deps.storageRepository,
            );
            chatProvider
              ..setConversationProvider(conversations)
              ..setSettingsProvider(settings);
            return chatProvider;
          },
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (_, settings, __) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'PickleChat',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.themeMode,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
