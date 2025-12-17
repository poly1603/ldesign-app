import 'package:flutter_toolbox/core/constants/app_constants.dart';
import 'package:flutter_toolbox/data/models/app_settings.dart';
import 'package:flutter_toolbox/data/services/storage_service.dart';

/// 设置服务接口
abstract class SettingsService {
  Future<AppSettings> getSettings();
  Future<void> saveSettings(AppSettings settings);
  Future<void> resetToDefaults();
  Future<T?> getSetting<T>(String key);
  Future<void> setSetting<T>(String key, T value);
}

/// 设置服务实现
class SettingsServiceImpl implements SettingsService {
  final StorageService _storage;

  SettingsServiceImpl(this._storage);

  @override
  Future<AppSettings> getSettings() async {
    final json = await _storage.loadJson(StorageKeys.settings);
    if (json == null) {
      return AppSettings.defaults;
    }
    return AppSettings.fromJson(json);
  }

  @override
  Future<void> saveSettings(AppSettings settings) async {
    await _storage.saveJson(StorageKeys.settings, settings.toJson());
  }

  @override
  Future<void> resetToDefaults() async {
    await saveSettings(AppSettings.defaults);
  }

  @override
  Future<T?> getSetting<T>(String key) async {
    final settings = await getSettings();
    final json = settings.toJson();
    final value = json[key];
    if (value is T) {
      return value;
    }
    return null;
  }

  @override
  Future<void> setSetting<T>(String key, T value) async {
    final settings = await getSettings();
    final json = settings.toJson();
    json[key] = value;
    await saveSettings(AppSettings.fromJson(json));
  }
}
