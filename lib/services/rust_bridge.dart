import 'dart:ffi';
import 'dart:io';
import 'package:flutter/foundation.dart';

/// Rust 桥接服务
/// 
/// 负责加载 Rust 动态库并提供统一的访问接口
class RustBridge {
  static DynamicLibrary? _lib;
  static bool _initialized = false;

  /// 初始化 Rust 桥接
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      _lib = _loadLibrary();
      _initialized = true;
      debugPrint('✅ Rust bridge initialized successfully');
    } catch (e) {
      debugPrint('❌ Failed to initialize Rust bridge: $e');
      rethrow;
    }
  }

  /// 加载 Rust 动态库
  static DynamicLibrary _loadLibrary() {
    const libName = 'rust_core';

    if (Platform.isWindows) {
      return DynamicLibrary.open('$libName.dll');
    } else if (Platform.isMacOS) {
      return DynamicLibrary.open('lib$libName.dylib');
    } else if (Platform.isLinux) {
      return DynamicLibrary.open('lib$libName.so');
    } else {
      throw UnsupportedError('Unsupported platform: ${Platform.operatingSystem}');
    }
  }

  /// 获取动态库实例
  static DynamicLibrary get lib {
    if (!_initialized || _lib == null) {
      throw StateError('Rust bridge not initialized. Call initialize() first.');
    }
    return _lib!;
  }

  /// 检查是否已初始化
  static bool get isInitialized => _initialized;
}

/// Rust 错误类
class RustError implements Exception {
  final String message;
  final String? details;

  RustError(this.message, [this.details]);

  @override
  String toString() {
    if (details != null) {
      return 'RustError: $message\nDetails: $details';
    }
    return 'RustError: $message';
  }
}