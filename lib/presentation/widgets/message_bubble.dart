import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/utils/markdown_helper.dart';
import '../../data/models/message_model.dart';
import 'markdown_renderer.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.isStreaming,
    required this.onDelete,
  });

  final MessageModel message;
  final bool isStreaming;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';
    final content = MarkdownHelper.appendCursor(message.content, isStreaming && !isUser);

    return GestureDetector(
      onLongPress: () => _showMessageActions(context, content),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment:
              isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!isUser) ...[
              SvgPicture.asset('assets/icons/pickle.svg', width: 20, height: 20),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Container(
                padding: isUser
                    ? const EdgeInsets.symmetric(horizontal: 14, vertical: 10)
                    : EdgeInsets.zero,
                decoration: isUser
                    ? BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF2C2C2E)
                            : const Color(0xFFF7F7F8),
                        borderRadius: BorderRadius.circular(18),
                      )
                    : null,
                child: isUser
                    ? Text(content)
                    : MarkdownRenderer(data: content),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showMessageActions(BuildContext context, String content) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy'),
              onTap: () => Navigator.pop(context, 'copy'),
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete'),
              onTap: () => Navigator.pop(context, 'delete'),
            ),
          ],
        ),
      ),
    );

    if (action == 'copy') {
      await Clipboard.setData(ClipboardData(text: content));
    } else if (action == 'delete') {
      onDelete();
    }
  }
}
