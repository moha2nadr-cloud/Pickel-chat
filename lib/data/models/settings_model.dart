import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class SettingsModel {
  SettingsModel({
    this.apiKey = '',
    this.themeModeValue = 'system',
    this.language = 'ar',
  });

  final String apiKey;
  final String themeModeValue;
  final String language;

  ThemeMode get themeMode {
    switch (themeModeValue) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  SettingsModel copyWith({String? apiKey, String? themeModeValue, String? language}) {
    return SettingsModel(
      apiKey: apiKey ?? this.apiKey,
      themeModeValue: themeModeValue ?? this.themeModeValue,
      language: language ?? this.language,
    );
  }
}

class SettingsModelAdapter extends TypeAdapter<SettingsModel> {
  @override
  final int typeId = 2;

  @override
  SettingsModel read(BinaryReader reader) {
    final fields = <int, dynamic>{
      for (int i = 0, count = reader.readByte(); i < count; i++)
        reader.readByte(): reader.read(),
    };
    return SettingsModel(
      apiKey: fields[0] as String,
      themeModeValue: fields[1] as String,
      language: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SettingsModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.apiKey)
      ..writeByte(1)
      ..write(obj.themeModeValue)
      ..writeByte(2)
      ..write(obj.language);
  }
}
