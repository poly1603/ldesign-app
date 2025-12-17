import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_toolbox/data/models/git_environment.dart';
import 'package:flutter_toolbox/providers/node_providers.dart';

/// Git 环境状态 Provider
final gitEnvironmentProvider = StateNotifierProvider<GitEnvironmentNotifier, AsyncValue<GitEnvironment>>((ref) {
  final systemService = ref.watch(systemServiceProvider);
  return GitEnvironmentNotifier(systemService);
});

/// Git 环境状态管理器
class GitEnvironmentNotifier extends StateNotifier<AsyncValue<GitEnvironment>> {
  final dynamic _systemService;

  GitEnvironmentNotifier(this._systemService) : super(const AsyncValue.loading()) {
    refresh();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final env = await _systemService.getGitEnvironment();
      state = AsyncValue.data(env);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// Git 是否已安装 Provider
final gitInstalledProvider = Provider<bool>((ref) {
  final envAsync = ref.watch(gitEnvironmentProvider);
  return envAsync.whenOrNull(data: (env) => env.isInstalled) ?? false;
});

/// Git 版本 Provider
final gitVersionProvider = Provider<String?>((ref) {
  final envAsync = ref.watch(gitEnvironmentProvider);
  return envAsync.whenOrNull(data: (env) => env.gitVersion);
});
