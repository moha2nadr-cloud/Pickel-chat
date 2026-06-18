import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../providers/chat_provider.dart';
import '../providers/conversation_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/conversation_drawer.dart';
import 'chat_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _drawerKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Consumer3<ConversationProvider, ChatProvider, SettingsProvider>(
      builder: (_, conversations, chat, settings, __) {
        return Scaffold(
          key: _drawerKey,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => _drawerKey.currentState?.openDrawer(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  final c = await conversations.createConversation();
                  if (!context.mounted) return;
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ChatScreen(conversation: c)),
                  );
                },
              )
            ],
          ),
          drawer: ConversationDrawer(
            conversations: conversations.conversations,
            selectedId: conversations.selectedConversationId,
            onSelect: (id) async {
              conversations.selectConversation(id);
              final conversation = conversations.conversations.firstWhere((e) => e.id == id);
              Navigator.pop(context);
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ChatScreen(conversation: conversation)),
              );
            },
            onNewChat: () async {
              Navigator.pop(context);
              final c = await conversations.createConversation();
              if (!context.mounted) return;
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ChatScreen(conversation: c)),
              );
            },
            onSettings: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          body: Column(
            children: [
              Expanded(
                child: conversations.conversations.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset('assets/icons/pickle.svg', width: 54, height: 54),
                            const SizedBox(height: 14),
                            Text(
                              AppConstants.emptyStateArabic,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: conversations.conversations.length,
                        itemBuilder: (_, index) {
                          final item = conversations.conversations[index];
                          return ListTile(
                            title: Text(item.title),
                            subtitle: Text('${item.messages.length} messages'),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatScreen(conversation: item),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              ChatInputBar(
                isResponding: chat.isResponding,
                attachedFileName: chat.attachedFileName,
                onAttachmentRemove: chat.clearAttachment,
                placeholderText:
                    settings.language == 'ar' ? 'اكتب رسالة...' : 'Write a message...',
                onFileAttached: (name, content) =>
                    chat.attachFile(fileName: name, content: content),
                onSend: (text) async {
                  final conversation = await conversations.createConversation();
                  conversations.selectConversation(conversation.id);
                  if (!context.mounted) return;
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ChatScreen(conversation: conversation)),
                  );
                  await chat.sendMessage(text);
                },
                onStop: chat.cancelStreaming,
              ),
            ],
          ),
        );
      },
    );
  }
}
