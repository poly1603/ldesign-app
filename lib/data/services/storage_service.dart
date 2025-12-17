import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// 存储服务接口
abstract class StorageService {
  /// 保存 JSON 数据
  Future<void> saveJson(String key, Map<String, dynamic> data);

  /// 读取 JSON 数据
  Future<Map<String, dynamic>?> loadJson(String key);

  /// 保存 JSON 列表数据
  Future<void> saveJsonList(String key, List<Map<String, dynamic>> data);

  /// 读取 JSON 列表数据
  Future<List<Map<String, dynamic>>?> loadJsonList(String key);

  /// 保存字符串
  Future<void> saveString(String key, String value);

  /// 读取字符串
  Future<String?> loadString(String key);

  /// 保存整数
  Future<void> saveInt(String key, int value);

  /// 读取整数
  Future<int?> loadInt(String key);

  /// 保存布尔值
  Future<void> saveBool(String key, bool value);

  /// 读取布尔值
  Future<bool?> loadBool(String key);

  /// 删除数据
  Future<void> delete(String key);

  /// 清空所有数据
  Future<void> clear();

  /// 检查键是否存在
  Future<bool> containsKey(String key);
}

/// 基于 SharedPreferences 的存储服务实现
class SharedPreferencesStorageService implements StorageService {
  SharedPreferences? _prefs;

  /// 获取 SharedPreferences 实例
  Future<SharedPreferences> get prefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  @override
  Future<void> saveJson(String key, Map<String, dynamic> data) async {
    final p = await prefs;
    final jsonString = jsonEncode(data);
    await p.setString(key, jsonString);
  }

  @override
  Future<Map<String, dynamic>?> loadJson(String key) async {
    final p = await prefs;
    final jsonString = p.getString(key);
    if (jsonString == null) return null;

    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return null;
    } catch (e) {
      // JSON 解析失败，返回 null（优雅降级）
      return null;
    }
  }

  @override
  Future<void> saveJsonList(String key, List<Map<String, dynamic>> data) async {
    final p = await prefs;
    final jsonString = jsonEncode(data);
    await p.setString(key, jsonString);
  }

  @override
  Future<List<Map<String, dynamic>>?> loadJsonList(String key) async {
    final p = await prefs;
    final jsonString = p.getString(key);
    if (jsonString == null) return null;

    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .toList();
      }
      return null;
    } catch (e) {
      // JSON 解析失败，返回 null（优雅降级）
      return null;
    }
  }

  @override
  Future<void> saveString(String key, String value) async {
    final p = await prefs;
    await p.setString(key, value);
  }

  @override
  Future<String?> loadString(String key) async {
    final p = await prefs;
    return p.getString(key);
  }

  @override
  Future<void> saveInt(String key, int value) async {
    final p = await prefs;
    await p.setInt(key, value);
  }

  @override
  Future<int?> loadInt(String key) async {
    final p = await prefs;
    return p.getInt(key);
  }

  @override
  Future<void> saveBool(String key, bool value) async {
    final p = await prefs;
    await p.setBool(key, value);
  }

  @override
  Future<bool?> loadBool(String key) async {
    final p = await prefs;
    return p.getBool(key);
  }

  @override
  Future<void> delete(String key) async {
    final p = await prefs;
    await p.remove(key);
  }

  @override
  Future<void> clear() async {
    final p = await prefs;
    await p.clear();
  }

  @override
  Future<bool> containsKey(String key) async {
    final p = await prefs;
    return p.containsKey(key);
  }
}

/// 用于测试的内存存储服务实现
class InMemoryStorageService implements StorageService {
  final Map<String, dynamic> _storage = {};

  @override
  Future<void> saveJson(String key, Map<String, dynamic> data) async {
    _storage[key] = jsonEncode(data);
  }

  @override
  Future<Map<String, dynamic>?> loadJson(String key) async {
    final jsonString = _storage[key];
    if (jsonString == null || jsonString is! String) return null;

    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveJsonList(String key, List<Map<String, dynamic>> data) async {
    _storage[key] = jsonEncode(data);
  }

  @override
  Future<List<Map<String, dynamic>>?> loadJsonList(String key) async {
    final jsonString = _storage[key];
    if (jsonString == null || jsonString is! String) return null;

    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is List) {
        return decoded.whereType<Map<String, dynamic>>().toList();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveString(String key, String value) async {
    _storage[key] = value;
  }

  @override
  Future<String?> loadString(String key) async {
    final value = _storage[key];
    return value is String ? value : null;
  }

  @override
  Future<void> saveInt(String key, int value) async {
    _storage[key] = value;
  }

  @override
  Future<int?> loadInt(String key) async {
    final value = _storage[key];
    return value is int ? value : null;
  }

  @override
  Future<void> saveBool(String key, bool value) async {
    _storage[key] = value;
  }

  @override
  Future<bool?> loadBool(String key) async {
    final value = _storage[key];
    return value is bool ? value : null;
  }

  @override
  Future<void> delete(String key) async {
    _storage.remove(key);
  }

  @override
  Future<void> clear() async {
    _storage.clear();
  }

  @override
  Future<bool> containsKey(String key) async {
    return _storage.containsKey(key);
  }

  /// 直接设置原始值（用于测试损坏数据场景）
  void setRawValue(String key, dynamic value) {
    _storage[key] = value;
  }
}
