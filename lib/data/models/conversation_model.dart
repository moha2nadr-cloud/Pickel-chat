import 'package:hive/hive.dart';

import '../../core/constants/app_constants.dart';
import 'message_model.dart';

class ConversationModel {
  ConversationModel({
    required this.id,
    required this.title,
    required this.messages,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final List<MessageModel> messages;
  final DateTime createdAt;
  final DateTime updatedAt;

  ConversationModel copyWith({
    String? title,
    List<MessageModel>? messages,
    DateTime? updatedAt,
  }) {
    return ConversationModel(
      id: id,
      title: title ?? this.title,
      messages: messages ?? this.messages,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static String titleFromText(String text) {
    final clean = text.trim();
    if (clean.isEmpty) return 'New Chat';
    return clean.length <= AppConstants.conversationTitleMaxLength
        ? clean
        : '${clean.substring(0, AppConstants.conversationTitleMaxLength)}...';
  }
}

class ConversationModelAdapter extends TypeAdapter<ConversationModel> {
  @override
  final int typeId = 1;

  @override
  ConversationModel read(BinaryReader reader) {
    final fields = <int, dynamic>{
      for (int i = 0, count = reader.readByte(); i < count; i++)
        reader.readByte(): reader.read(),
    };
    return ConversationModel(
      id: fields[0] as String,
      title: fields[1] as String,
      messages: (fields[2] as List).cast<MessageModel>(),
      createdAt: fields[3] as DateTime,
      updatedAt: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ConversationModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.messages)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.updatedAt);
  }
}
