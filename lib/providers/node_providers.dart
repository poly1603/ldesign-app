import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_toolbox/data/models/node_environment.dart';
import 'package:flutter_toolbox/data/services/system_service.dart';

/// 系统服务 Provider
final systemServiceProvider = Provider<SystemService>((ref) {
  return SystemServiceImpl();
});

/// Node 环境状态 Provider
final nodeEnvironmentProvider = StateNotifierProvider<NodeEnvironmentNotifier, AsyncValue<NodeEnvironment>>((ref) {
  final systemService = ref.watch(systemServiceProvider);
  return NodeEnvironmentNotifier(systemService);
});

/// Node 环境状态管理器
class NodeEnvironmentNotifier extends StateNotifier<AsyncValue<NodeEnvironment>> {
  final SystemService _systemService;

  NodeEnvironmentNotifier(this._systemService) : super(const AsyncValue.loading()) {
    refresh();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final env = await _systemService.getNodeEnvironment();
      if (mounted) {
        state = AsyncValue.data(env);
      }
    } catch (e, st) {
      if (mounted) {
        state = AsyncValue.error(e, st);
      }
    }
  }

  /// 更新当前 Node 版本（不刷新整个环境）
  void updateCurrentVersion(String newVersion) {
    state.whenData((env) {
      // 更新已安装版本的激活状态
      final updatedVersions = env.installedVersions.map((v) {
        return NodeVersion(
          version: v.version,
          path: v.path,
          isActive: v.version == newVersion,
          source: v.source,
        );
      }).toList();

      // 使用 copyWith 创建新的环境对象
      final updatedEnv = env.copyWith(
        nodeVersion: newVersion,
        installedVersions: updatedVersions,
      );

      if (mounted) {
        state = AsyncValue.data(updatedEnv);
      }
    });
  }
}

/// Node 是否已安装 Provider
final nodeInstalledProvider = Provider<bool>((ref) {
  final envAsync = ref.watch(nodeEnvironmentProvider);
  return envAsync.whenOrNull(data: (env) => env.isInstalled) ?? false;
});

/// Node 版本 Provider
final nodeVersionProvider = Provider<String?>((ref) {
  final envAsync = ref.watch(nodeEnvironmentProvider);
  return envAsync.whenOrNull(data: (env) => env.nodeVersion);
});
