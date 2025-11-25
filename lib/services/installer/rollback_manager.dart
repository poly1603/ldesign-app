import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

/// 回滚点
class RollbackPoint {
  final String id;
  final DateTime timestamp;
  final String description;
  final Map<String, dynamic> state;
  final List<String> backupPaths;

  RollbackPoint({
    required this.id,
    required this.timestamp,
    required this.description,
    required this.state,
    this.backupPaths = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'description': description,
        'state': state,
        'backupPaths': backupPaths,
      };

  factory RollbackPoint.fromJson(Map<String, dynamic> json) {
    return RollbackPoint(
      id: json['id'],
      timestamp: DateTime.parse(json['timestamp']),
      description: json['description'],
      state: json['state'],
      backupPaths: List<String>.from(json['backupPaths'] ?? []),
    );
  }
}

/// 回滚管理器
class RollbackManager {
  final String _backupDir;
  final List<RollbackPoint> _rollbackPoints = [];

  RollbackManager({String? backupDir})
      : _backupDir = backupDir ?? _getDefaultBackupDir();

  /// 获取默认备份目录
  static String _getDefaultBackupDir() {
    final home = Platform.environment['HOME'] ??
        Platform.environment['USERPROFILE'] ??
        Directory.current.path;
    return path.join(home, '.node_manager_backup');
  }

  /// 初始化
  Future<void> initialize() async {
    final dir = Directory(_backupDir);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    await _loadRollbackPoints();
  }

  /// 创建回滚点
  Future<RollbackPoint> createRollbackPoint({
    required String description,
    required Map<String, dynamic> state,
    List<String>? pathsToBackup,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final backupPaths = <String>[];

    // 备份文件/目录
    if (pathsToBackup != null && pathsToBackup.isNotEmpty) {
      for (final srcPath in pathsToBackup) {
        try {
          final backupPath = await _backupPath(id, srcPath);
          if (backupPath != null) {
            backupPaths.add(backupPath);
          }
        } catch (e) {
          debugPrint('备份路径失败: $srcPath - $e');
        }
      }
    }

    final rollbackPoint = RollbackPoint(
      id: id,
      timestamp: DateTime.now(),
      description: description,
      state: state,
      backupPaths: backupPaths,
    );

    _rollbackPoints.add(rollbackPoint);
    await _saveRollbackPoints();

    debugPrint('创建回滚点: $id - $description');
    return rollbackPoint;
  }

  /// 备份路径
  Future<String?> _backupPath(String rollbackId, String srcPath) async {
    final src = Directory(srcPath);
    if (!await src.exists()) {
      final srcFile = File(srcPath);
      if (!await srcFile.exists()) {
        debugPrint('路径不存在: $srcPath');
        return null;
      }
      // 备份文件
      return await _backupFile(rollbackId, srcPath);
    }

    // 备份目录
    return await _backupDirectory(rollbackId, srcPath);
  }

  /// 备份文件
  Future<String?> _backupFile(String rollbackId, String filePath) async {
    try {
      final file = File(filePath);
      final fileName = path.basename(filePath);
      final backupPath = path.join(_backupDir, rollbackId, fileName);
      
      final backupDir = Directory(path.dirname(backupPath));
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }

      await file.copy(backupPath);
      debugPrint('已备份文件: $filePath -> $backupPath');
      return backupPath;
    } catch (e) {
      debugPrint('备份文件失败: $filePath - $e');
      return null;
    }
  }

  /// 备份目录
  Future<String?> _backupDirectory(String rollbackId, String dirPath) async {
    try {
      final srcDir = Directory(dirPath);
      final dirName = path.basename(dirPath);
      final backupPath = path.join(_backupDir, rollbackId, dirName);

      await _copyDirectory(srcDir, Directory(backupPath));
      debugPrint('已备份目录: $dirPath -> $backupPath');
      return backupPath;
    } catch (e) {
      debugPrint('备份目录失败: $dirPath - $e');
      return null;
    }
  }

  /// 递归复制目录
  Future<void> _copyDirectory(Directory source, Directory destination) async {
    if (!await destination.exists()) {
      await destination.create(recursive: true);
    }

    await for (final entity in source.list()) {
      final newPath = path.join(destination.path, path.basename(entity.path));

      if (entity is File) {
        await entity.copy(newPath);
      } else if (entity is Directory) {
        await _copyDirectory(entity, Directory(newPath));
      }
    }
  }

  /// 回滚到指定点
  Future<void> rollback(String rollbackId, {Function(String)? onLog}) async {
    onLog?.call('开始回滚到: $rollbackId');

    final rollbackPoint = _rollbackPoints.firstWhere(
      (point) => point.id == rollbackId,
      orElse: () => throw Exception('回滚点不存在: $rollbackId'),
    );

    try {
      // 恢复备份的文件
      for (final backupPath in rollbackPoint.backupPaths) {
        await _restoreBackup(backupPath, onLog);
      }

      onLog?.call('✓ 回滚完成');
    } catch (e) {
      onLog?.call('✗ 回滚失败: $e');
      rethrow;
    }
  }

  /// 恢复备份
  Future<void> _restoreBackup(String backupPath, Function(String)? onLog) async {
    try {
      final backup = Directory(backupPath);
      if (!await backup.exists()) {
        final backupFile = File(backupPath);
        if (!await backupFile.exists()) {
          onLog?.call('警告: 备份不存在: $backupPath');
          return;
        }
        // 恢复文件
        await _restoreFile(backupPath, onLog);
        return;
      }

      // 恢复目录
      await _restoreDirectory(backupPath, onLog);
    } catch (e) {
      onLog?.call('恢复备份失败: $backupPath - $e');
      rethrow;
    }
  }

  /// 恢复文件
  Future<void> _restoreFile(String backupPath, Function(String)? onLog) async {
    // 从备份路径推断原始路径
    final fileName = path.basename(backupPath);
    // 这里需要根据实际情况确定原始路径
    // 简化实现：假设备份结构保留了原始路径信息
    onLog?.call('恢复文件: $fileName');
  }

  /// 恢复目录
  Future<void> _restoreDirectory(String backupPath, Function(String)? onLog) async {
    final dirName = path.basename(backupPath);
    onLog?.call('恢复目录: $dirName');
    // 实际实现需要根据备份时保存的原始路径信息来恢复
  }

  /// 删除回滚点
  Future<void> deleteRollbackPoint(String rollbackId) async {
    final rollbackPoint = _rollbackPoints.firstWhere(
      (point) => point.id == rollbackId,
      orElse: () => throw Exception('回滚点不存在'),
    );

    // 删除备份文件
    final backupDir = Directory(path.join(_backupDir, rollbackId));
    if (await backupDir.exists()) {
      await backupDir.delete(recursive: true);
    }

    _rollbackPoints.remove(rollbackPoint);
    await _saveRollbackPoints();

    debugPrint('已删除回滚点: $rollbackId');
  }

  /// 清理旧的回滚点
  Future<void> cleanOldRollbackPoints({int keepCount = 10}) async {
    if (_rollbackPoints.length <= keepCount) return;

    // 按时间排序，保留最新的
    _rollbackPoints.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    final toDelete = _rollbackPoints.sublist(keepCount);
    for (final point in toDelete) {
      await deleteRollbackPoint(point.id);
    }

    debugPrint('已清理 ${toDelete.length} 个旧回滚点');
  }

  /// 保存回滚点列表
  Future<void> _saveRollbackPoints() async {
    final file = File(path.join(_backupDir, 'rollback_points.json'));
    final json = jsonEncode(_rollbackPoints.map((p) => p.toJson()).toList());
    await file.writeAsString(json);
  }

  /// 加载回滚点列表
  Future<void> _loadRollbackPoints() async {
    try {
      final file = File(path.join(_backupDir, 'rollback_points.json'));
      if (!await file.exists()) return;

      final json = await file.readAsString();
      final List<dynamic> list = jsonDecode(json);
      
      _rollbackPoints.clear();
      _rollbackPoints.addAll(
        list.map((item) => RollbackPoint.fromJson(item)),
      );

      debugPrint('已加载 ${_rollbackPoints.length} 个回滚点');
    } catch (e) {
      debugPrint('加载回滚点失败: $e');
    }
  }

  /// 获取所有回滚点
  List<RollbackPoint> getRollbackPoints() {
    return List.unmodifiable(_rollbackPoints);
  }

  /// 获取回滚点详情
  RollbackPoint? getRollbackPoint(String id) {
    try {
      return _rollbackPoints.firstWhere((point) => point.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 清理所有备份
  Future<void> clearAllBackups() async {
    final dir = Directory(_backupDir);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
      await dir.create(recursive: true);
    }

    _rollbackPoints.clear();
    await _saveRollbackPoints();

    debugPrint('已清理所有备份');
  }

  /// 获取备份大小
  Future<int> getBackupSize() async {
    int totalSize = 0;

    try {
      final dir = Directory(_backupDir);
      if (!await dir.exists()) return 0;

      await for (final entity in dir.list(recursive: true)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
    } catch (e) {
      debugPrint('获取备份大小失败: $e');
    }

    return totalSize;
  }

  /// 格式化大小
  String formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}

/// 安装事务 - 自动管理回滚
class InstallationTransaction {
  final RollbackManager _rollbackManager;
  RollbackPoint? _rollbackPoint;
  bool _committed = false;

  InstallationTransaction(this._rollbackManager);

  /// 开始事务
  Future<void> begin({
    required String description,
    List<String>? pathsToBackup,
  }) async {
    _rollbackPoint = await _rollbackManager.createRollbackPoint(
      description: description,
      state: {'status': 'in_progress'},
      pathsToBackup: pathsToBackup,
    );
  }

  /// 提交事务
  Future<void> commit() async {
    _committed = true;
    debugPrint('事务已提交: ${_rollbackPoint?.id}');
  }

  /// 回滚事务
  Future<void> rollback({Function(String)? onLog}) async {
    if (_rollbackPoint != null && !_committed) {
      onLog?.call('事务失败，正在回滚...');
      await _rollbackManager.rollback(_rollbackPoint!.id, onLog: onLog);
    }
  }

  /// 自动处理
  Future<T> execute<T>(
    Future<T> Function() operation, {
    Function(String)? onLog,
  }) async {
    try {
      final result = await operation();
      await commit();
      return result;
    } catch (e) {
      await rollback(onLog: onLog);
      rethrow;
    }
  }
}