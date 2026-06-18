import 'package:flutter/material.dart';

class FileAttachmentChip extends StatelessWidget {
  const FileAttachmentChip({
    super.key,
    required this.fileName,
    required this.onRemove,
  });

  final String fileName;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Chip(
        avatar: const Icon(Icons.attach_file, size: 18),
        label: Text(fileName),
        onDeleted: onRemove,
      ),
    );
  }
}
