import 'package:flutter/material.dart';

import '../../data/models/settings_model.dart';
import '../../data/repositories/storage_repository.dart';
import '../../data/services/api_service.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider({
    required StorageRepository storageRepository,
    required ApiService apiService,
  })  : _storageRepository = storageRepository,
        _apiService = apiService;

  final StorageRepository _storageRepository;
  final ApiService _apiService;

  SettingsModel _settings = SettingsModel();
  bool _isLoading = false;

  SettingsModel get settings => _settings;
  ThemeMode get themeMode => _settings.themeMode;
  String get apiKey => _settings.apiKey;
  String get language => _settings.language;
  bool get isLoading => _isLoading;

  Future<void> loadSettings() async {
    _settings = _storageRepository.getSettings();
    notifyListeners();
  }

  Future<void> updateApiKey(String value) async {
    _settings = _settings.copyWith(apiKey: value);
    await _storageRepository.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> updateTheme(String value) async {
    _settings = _settings.copyWith(themeModeValue: value);
    await _storageRepository.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> updateLanguage(String value) async {
    _settings = _settings.copyWith(language: value);
    await _storageRepository.saveSettings(_settings);
    notifyListeners();
  }

  Future<bool> testConnection() async {
    _isLoading = true;
    notifyListeners();
    try {
      return await _apiService.testConnection(_settings.apiKey);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
