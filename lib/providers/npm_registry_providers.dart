import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_toolbox/data/models/npm_registry.dart';
import 'package:flutter_toolbox/data/services/npm_registry_service.dart';

/// NPM 源服务 Provider
final npmRegistryServiceProvider = Provider<NpmRegistryService>((ref) {
  return NpmRegistryServiceImpl();
});

/// NPM 源列表 Provider
final npmRegistriesProvider = FutureProvider<List<NpmRegistry>>((ref) async {
  final service = ref.watch(npmRegistryServiceProvider);
  return service.getRegistries();
});

/// 当前使用的 NPM 源 Provider
final currentNpmRegistryProvider = FutureProvider<NpmRegistry?>((ref) async {
  final service = ref.watch(npmRegistryServiceProvider);
  return service.getCurrentRegistry();
});

/// NPM 源列表状态管理
class NpmRegistryNotifier extends StateNotifier<AsyncValue<List<NpmRegistry>>> {
  final NpmRegistryService _service;

  NpmRegistryNotifier(this._service) : super(const AsyncValue.loading()) {
    loadRegistries();
  }

  Future<void> loadRegistries() async {
    state = const AsyncValue.loading();
    try {
      final registries = await _service.getRegistries();
      state = AsyncValue.data(registries);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addRegistry(NpmRegistry registry) async {
    await _service.addRegistry(registry);
    await loadRegistries();
  }

  Future<void> updateRegistry(NpmRegistry registry) async {
    await _service.updateRegistry(registry);
    await loadRegistries();
  }

  Future<void> deleteRegistry(String id) async {
    await _service.deleteRegistry(id);
    await loadRegistries();
  }

  Future<void> setDefaultRegistry(String id) async {
    await _service.setDefaultRegistry(id);
    await loadRegistries();
  }

  Future<bool> startVerdaccio(NpmRegistry registry) async {
    final success = await _service.startVerdaccio(registry);
    if (success) {
      await loadRegistries();
    }
    return success;
  }

  Future<bool> stopVerdaccio(String id) async {
    final success = await _service.stopVerdaccio(id);
    if (success) {
      await loadRegistries();
    }
    return success;
  }

  Future<bool> testConnection(String url) async {
    return _service.testConnection(url);
  }

  Future<bool> loginToRegistry(NpmRegistry registry) async {
    return _service.loginToRegistry(registry);
  }
}

/// NPM 源列表状态 Provider
final npmRegistryNotifierProvider =
    StateNotifierProvider<NpmRegistryNotifier, AsyncValue<List<NpmRegistry>>>((ref) {
  final service = ref.watch(npmRegistryServiceProvider);
  return NpmRegistryNotifier(service);
});
