import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/conversation_model.dart';

class ConversationDrawer extends StatelessWidget {
  const ConversationDrawer({
    super.key,
    required this.conversations,
    required this.selectedId,
    required this.onSelect,
    required this.onNewChat,
    required this.onSettings,
  });

  final List<ConversationModel> conversations;
  final String? selectedId;
  final ValueChanged<String> onSelect;
  final VoidCallback onNewChat;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          const DrawerHeader(
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text('PickleChat', style: TextStyle(fontSize: 22)),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('New chat'),
            onTap: onNewChat,
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: onSettings,
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: conversations.length,
              itemBuilder: (_, index) {
                final item = conversations[index];
                return ListTile(
                  selected: item.id == selectedId,
                  title: Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(DateFormat.yMd().add_jm().format(item.updatedAt)),
                  onTap: () => onSelect(item.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
