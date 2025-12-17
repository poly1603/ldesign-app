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
      state = AsyncValue.data(env);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
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
