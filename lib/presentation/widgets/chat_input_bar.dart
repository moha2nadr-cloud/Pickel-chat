import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../core/utils/file_reader.dart';
import 'file_attachment_chip.dart';

class ChatInputBar extends StatefulWidget {
  const ChatInputBar({
    super.key,
    required this.isResponding,
    required this.onSend,
    required this.onStop,
    required this.onFileAttached,
    this.attachedFileName,
    required this.onAttachmentRemove,
  });

  final bool isResponding;
  final Future<void> Function(String text) onSend;
  final VoidCallback onStop;
  final Future<void> Function(String name, String content) onFileAttached;
  final String? attachedFileName;
  final VoidCallback onAttachmentRemove;

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canSend = _controller.text.trim().isNotEmpty;
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.attachedFileName != null)
              FileAttachmentChip(
                fileName: widget.attachedFileName!,
                onRemove: widget.onAttachmentRemove,
              ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: _pickFile,
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    minLines: 1,
                    maxLines: 6,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText: 'اكتب رسالة...',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: canSend || widget.isResponding
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).disabledColor,
                  child: IconButton(
                    onPressed: widget.isResponding
                        ? widget.onStop
                        : canSend
                            ? () async {
                                final text = _controller.text;
                                _controller.clear();
                                setState(() {});
                                await widget.onSend(text);
                              }
                            : null,
                    icon: Icon(widget.isResponding ? Icons.stop : Icons.arrow_upward,
                        color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null || result.files.single.path == null) return;
    final file = result.files.single;
    final content = await FileReader.readFileAsText(file.path!);
    await widget.onFileAttached(file.name, content);
  }
}
