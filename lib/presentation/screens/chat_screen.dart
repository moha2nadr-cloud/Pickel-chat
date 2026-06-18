import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../data/models/conversation_model.dart';
import '../providers/chat_provider.dart';
import '../providers/conversation_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/message_bubble.dart';
import '../widgets/typing_indicator.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.conversation});

  final ConversationModel conversation;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _scrollController = ScrollController();
  bool _showFab = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final show = _scrollController.offset <
          (_scrollController.position.maxScrollExtent - 220);
      if (show != _showFab) {
        setState(() => _showFab = show);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<ConversationProvider, ChatProvider, SettingsProvider>(
      builder: (_, conversations, chat, settings, __) {
        final current = conversations.conversations
            .where((e) => e.id == widget.conversation.id)
            .toList();
        if (current.isEmpty) {
          return const Scaffold(body: Center(child: Text('Conversation deleted')));
        }
        final conversation = current.first;

        return Scaffold(
          appBar: AppBar(
            title: GestureDetector(
              onLongPress: () => _renameConversation(context, conversation.id),
              child: Text(conversation.title),
            ),
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) => _onMenu(value, conversation),
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'rename', child: Text('Rename')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                  PopupMenuItem(value: 'share', child: Text('Share')),
                  PopupMenuItem(value: 'export', child: Text('Export as TXT')),
                ],
              )
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(top: 12, bottom: 12),
                  itemCount: conversation.messages.length + (chat.isResponding ? 1 : 0),
                  itemBuilder: (_, index) {
                    if (chat.isResponding && index == conversation.messages.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        child: TypingIndicator(),
                      );
                    }
                    final message = conversation.messages[index];
                    final isStreaming = chat.isResponding &&
                        index == conversation.messages.length - 1 &&
                        message.role == 'assistant';
                    return MessageBubble(
                      message: message,
                      isStreaming: isStreaming,
                      onDelete: () => chat.deleteMessage(conversation.id, message.id),
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
                onSend: chat.sendMessage,
                onStop: chat.cancelStreaming,
              ),
            ],
          ),
          floatingActionButton: _showFab
              ? FloatingActionButton.small(
                  onPressed: () => _scrollController.animateTo(
                    _scrollController.position.maxScrollExtent,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                  ),
                  child: const Icon(Icons.keyboard_arrow_down),
                )
              : null,
        );
      },
    );
  }

  Future<void> _renameConversation(BuildContext context, String id) async {
    final controller = TextEditingController();
    final value = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Rename conversation'),
        content: TextField(controller: controller),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (!context.mounted || value == null || value.isEmpty) return;
    await context.read<ConversationProvider>().renameConversation(id, value);
  }

  Future<void> _onMenu(String value, ConversationModel conversation) async {
    final provider = context.read<ConversationProvider>();
    switch (value) {
      case 'rename':
        await _renameConversation(context, conversation.id);
        break;
      case 'delete':
        await provider.deleteConversation(conversation.id);
        if (mounted) Navigator.pop(context);
        break;
      case 'share':
        await Clipboard.setData(
          ClipboardData(text: _conversationAsText(conversation)),
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Conversation copied to clipboard')),
        );
        break;
      case 'export':
        final dir = await getApplicationDocumentsDirectory();
        final safeTitle = conversation.title.replaceAll(RegExp(r'[^\\w\\s-]'), '_');
        final file = File('${dir.path}/$safeTitle.txt');
        await file.writeAsString(_conversationAsText(conversation));
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Exported to ${file.path}')),
        );
        break;
    }
  }

  String _conversationAsText(ConversationModel conversation) {
    final buffer = StringBuffer();
    for (final message in conversation.messages) {
      buffer.writeln('${message.role.toUpperCase()}: ${message.content}');
      buffer.writeln();
    }
    return buffer.toString();
  }
}
