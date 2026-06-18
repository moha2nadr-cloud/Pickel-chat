import 'package:hive/hive.dart';

class MessageModel {
  MessageModel({
    required this.id,
    required this.role,
    required this.content,
    this.attachedFileName,
    this.attachedFileContent,
    required this.timestamp,
    this.isError = false,
  });

  final String id;
  final String role;
  final String content;
  final String? attachedFileName;
  final String? attachedFileContent;
  final DateTime timestamp;
  final bool isError;

  MessageModel copyWith({String? content, bool? isError}) {
    return MessageModel(
      id: id,
      role: role,
      content: content ?? this.content,
      attachedFileName: attachedFileName,
      attachedFileContent: attachedFileContent,
      timestamp: timestamp,
      isError: isError ?? this.isError,
    );
  }

  Map<String, dynamic> toApiJson() => {'role': role, 'content': content};
}

class MessageModelAdapter extends TypeAdapter<MessageModel> {
  @override
  final int typeId = 0;

  @override
  MessageModel read(BinaryReader reader) {
    final fields = <int, dynamic>{
      for (int i = 0, count = reader.readByte(); i < count; i++)
        reader.readByte(): reader.read(),
    };
    return MessageModel(
      id: fields[0] as String,
      role: fields[1] as String,
      content: fields[2] as String,
      attachedFileName: fields[3] as String?,
      attachedFileContent: fields[4] as String?,
      timestamp: fields[5] as DateTime,
      isError: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, MessageModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.role)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.attachedFileName)
      ..writeByte(4)
      ..write(obj.attachedFileContent)
      ..writeByte(5)
      ..write(obj.timestamp)
      ..writeByte(6)
      ..write(obj.isError);
  }
}
