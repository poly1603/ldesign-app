import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../config/theme_config.dart';
import '../models/project.dart';

class StorageUtil {
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyPrimaryColor = 'primary_color';
  static const String _keyAppSize = 'app_size';
  static const String _keyLocale = 'locale';
  static const String _keySidebarCollapsed = 'sidebar_collapsed';
  static const String _keyProjects = 'projects';
  static const String _keyProjectsPath = 'projects_path';

  static Future<ThemeMode> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final mode = prefs.getString(_keyThemeMode);
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.light;
    }
  }

  static Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyThemeMode, mode == ThemeMode.light ? 'light' : 'dark');
  }

  static Future<Color> getPrimaryColor() async {
    final prefs = await SharedPreferences.getInstance();
    final colorValue = prefs.getInt(_keyPrimaryColor);
    if (colorValue != null) {
      return Color(colorValue);
    }
    return ThemeConfig.presetColors[0];
  }

  static Future<void> setPrimaryColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyPrimaryColor, color.value);
  }

  static Future<AppSize> getAppSize() async {
    final prefs = await SharedPreferences.getInstance();
    final size = prefs.getString(_keyAppSize);
    switch (size) {
      case 'compact':
        return AppSize.compact;
      case 'standard':
        return AppSize.standard;
      case 'comfortable':
        return AppSize.comfortable;
      default:
        return AppSize.standard;
    }
  }

  static Future<void> setAppSize(AppSize size) async {
    final prefs = await SharedPreferences.getInstance();
    String sizeStr;
    switch (size) {
      case AppSize.compact:
        sizeStr = 'compact';
        break;
      case AppSize.standard:
        sizeStr = 'standard';
        break;
      case AppSize.comfortable:
        sizeStr = 'comfortable';
        break;
    }
    await prefs.setString(_keyAppSize, sizeStr);
  }

  static Future<Locale> getLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final locale = prefs.getString(_keyLocale);
    switch (locale) {
      case 'zh':
        return const Locale('zh');
      case 'en':
        return const Locale('en');
      case 'zh_Hant':
        return const Locale('zh', 'Hant');
      default:
        return const Locale('zh');
    }
  }

  static Future<void> setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    String localeStr;
    if (locale.countryCode == 'Hant') {
      localeStr = 'zh_Hant';
    } else {
      localeStr = locale.languageCode;
    }
    await prefs.setString(_keyLocale, localeStr);
  }

  static Future<bool> getSidebarCollapsed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keySidebarCollapsed) ?? false;
  }

  static Future<void> setSidebarCollapsed(bool collapsed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySidebarCollapsed, collapsed);
  }

  // 默认实体文件路径：优先放到“文档/LDesignManager/projects.json”
  static Future<String> _defaultProjectsPath() async {
    try {
      if (Platform.isWindows) {
        final userProfile = Platform.environment['USERPROFILE'];
        if (userProfile != null && userProfile.isNotEmpty) {
          return p.join(userProfile, 'Documents', 'LDesignManager', 'projects.json');
        }
      } else if (Platform.isMacOS) {
        final home = Platform.environment['HOME'];
        if (home != null) {
          return p.join(home, 'Documents', 'LDesignManager', 'projects.json');
        }
      } else if (Platform.isLinux) {
        final home = Platform.environment['HOME'];
        if (home != null) {
          return p.join(home, 'Documents', 'LDesignManager', 'projects.json');
        }
      }
    } catch (_) {}
    // 回退到应用支持目录
    final fallback = await getApplicationSupportDirectory();
    return p.join(fallback.path, 'LDesignManager', 'projects.json');
  }

  static Future<Directory> _stableDataRoot() async {
    try {
      if (Platform.isWindows) {
        final appData = Platform.environment['APPDATA'];
        if (appData != null && appData.isNotEmpty) {
          return Directory(p.join(appData, 'LDesignManager'));
        }
      } else if (Platform.isMacOS) {
        final home = Platform.environment['HOME'];
        if (home != null) {
          return Directory(p.join(home, 'Library', 'Application Support', 'LDesignManager'));
        }
      } else if (Platform.isLinux) {
        final xdg = Platform.environment['XDG_DATA_HOME'];
        if (xdg != null && xdg.isNotEmpty) {
          return Directory(p.join(xdg, 'ldesign_manager'));
        }
        final home = Platform.environment['HOME'];
        if (home != null) {
          return Directory(p.join(home, '.local', 'share', 'ldesign_manager'));
        }
      }
    } catch (_) {}
    // 回退到 path_provider 的支持目录
    final fallback = await getApplicationSupportDirectory();
    return Directory(p.join(fallback.path, 'LDesignManager'));
  }

  static Future<String> getProjectsPath() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_keyProjectsPath);
      final path = (saved == null || saved.isEmpty) ? await _defaultProjectsPath() : saved;
      final dirPath = p.dirname(path);
      final dir = Directory(dirPath);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      return path;
    } catch (_) {
      return await _defaultProjectsPath();
    }
  }

  static Future<void> setProjectsPath(String pathStr) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyProjectsPath, pathStr);
    } catch (_) {}
  }

  static Future<File> _projectsFile() async {
    final pathStr = await getProjectsPath();
    final file = File(pathStr);
    if (!await file.exists()) {
      final dir = Directory(p.dirname(pathStr));
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      await file.writeAsString('[]', encoding: utf8);
      if (kDebugMode) {
        debugPrint('StorageUtil._projectsFile: Created new projects file at ${file.path}');
      }
    }
    return file;
  }

  static Future<List<Project>> getProjects() async {
    if (kDebugMode) {
      debugPrint('StorageUtil.getProjects: Starting to load projects');
    }

    // 1) 优先从稳定的文件读取
    try {
      final file = await _projectsFile();
      if (kDebugMode) {
        debugPrint('StorageUtil.getProjects: File path: ${file.path}');
        debugPrint('StorageUtil.getProjects: File exists: ${await file.exists()}');
      }
      
      final content = await file.readAsString(encoding: utf8);
      if (kDebugMode) {
        debugPrint('StorageUtil.getProjects: File content length: ${content.length}');
        debugPrint('StorageUtil.getProjects: File content preview: ${content.length > 100 ? content.substring(0, 100) + "..." : content}');
      }
      
      if (content.trim().isEmpty) {
        if (kDebugMode) {
          debugPrint('StorageUtil.getProjects: File is empty, returning empty list');
        }
        return [];
      }
      
      final List<dynamic> decoded = jsonDecode(content);
      final projects = decoded
          .map((json) => Project.fromJson(json as Map<String, dynamic>))
          .toList();
      
      if (kDebugMode) {
        debugPrint('StorageUtil.getProjects: Successfully loaded ${projects.length} projects from file');
      }
      
      // 同步到 SharedPreferences 作为缓存
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_keyProjects, content);
        if (kDebugMode) {
          debugPrint('StorageUtil.getProjects: Synced to SharedPreferences as cache');
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('StorageUtil.getProjects: Failed to sync to SharedPreferences: $e');
        }
      }
      
      return projects;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('StorageUtil.getProjects: File read error: $e');
        debugPrint('StorageUtil.getProjects: Stack trace: $stackTrace');
      }
    }

    // 2) 兜底：从 SharedPreferences 读取
    try {
      final prefs = await SharedPreferences.getInstance();
      final projectsJson = prefs.getString(_keyProjects);
      if (projectsJson != null && projectsJson.isNotEmpty) {
        if (kDebugMode) {
          debugPrint('StorageUtil.getProjects: SharedPreferences content length: ${projectsJson.length}');
          debugPrint('StorageUtil.getProjects: SharedPreferences content preview: ${projectsJson.length > 100 ? projectsJson.substring(0, 100) + "..." : projectsJson}');
        }
        
        final List<dynamic> decoded = jsonDecode(projectsJson);
        final projects = decoded
            .map((json) => Project.fromJson(json as Map<String, dynamic>))
            .toList();
        if (kDebugMode) {
          debugPrint('StorageUtil.getProjects: Fallback loaded ${projects.length} projects from SharedPreferences');
        }
        return projects;
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('StorageUtil.getProjects: SharedPreferences read error: $e');
        debugPrint('StorageUtil.getProjects: SharedPreferences stack trace: $stackTrace');
        // 清理损坏的 SharedPreferences 数据
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove(_keyProjects);
          debugPrint('StorageUtil.getProjects: Cleared corrupted SharedPreferences data');
        } catch (_) {}
      }
    }

    if (kDebugMode) {
      debugPrint('StorageUtil.getProjects: No projects found, returning empty list');
    }
    return [];
  }

  static Future<void> setProjects(List<Project> projects) async {
    final projectsJson = jsonEncode(projects.map((p) => p.toJson()).toList());

    if (kDebugMode) {
      debugPrint('StorageUtil.setProjects: Saving ${projects.length} projects');
    }

    // 优先写入文件，确保数据持久化
    try {
      final file = await _projectsFile();
      await file.writeAsString(projectsJson);
      if (kDebugMode) {
        debugPrint('StorageUtil.setProjects: Successfully wrote ${projects.length} projects to file: ${file.path}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('StorageUtil.setProjects: File write error: $e');
      }
    }

    // 同步写入 SharedPreferences 作为缓存
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyProjects, projectsJson);
      if (kDebugMode) {
        debugPrint('StorageUtil.setProjects: Synced to SharedPreferences cache');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('StorageUtil.setProjects: SharedPreferences write error: $e');
      }
    }
  }
}
