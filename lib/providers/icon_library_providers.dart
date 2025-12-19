import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_toolbox/data/models/icon_library.dart';
import 'package:flutter_toolbox/data/services/icon_library_service.dart';
import 'package:flutter_toolbox/providers/app_providers.dart';

/// 图标库服务 Provider
final iconLibraryServiceProvider = Provider<IconLibraryService>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return IconLibraryServiceImpl(storage);
});

/// 图标库列表状态 Provider
final iconLibraryListProvider = StateNotifierProvider<IconLibraryListNotifier, AsyncValue<List<IconLibrary>>>((ref) {
  final service = ref.watch(iconLibraryServiceProvider);
  return IconLibraryListNotifier(service);
});

/// 图标库列表状态管理器
class IconLibraryListNotifier extends StateNotifier<AsyncValue<List<IconLibrary>>> {
  final IconLibraryService _service;

  IconLibraryListNotifier(this._service) : super(const AsyncValue.loading()) {
    loadLibraries();
  }

  Future<void> loadLibraries() async {
    state = const AsyncValue.loading();
    try {
      final libraries = await _service.getAllLibraries();
      state = AsyncValue.data(libraries);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createLibrary(String name, String description) async {
    final library = IconLibrary.create(name: name, description: description);
    await _service.saveLibrary(library);
    await loadLibraries();
  }

  Future<void> updateLibrary(IconLibrary library) async {
    await _service.saveLibrary(library);
    await loadLibraries();
  }

  Future<void> deleteLibrary(String id) async {
    await _service.deleteLibrary(id);
    await loadLibraries();
  }

  Future<void> addIconToLibrary(String libraryId, String iconId) async {
    final library = await _service.getLibrary(libraryId);
    if (library != null) {
      final updated = library.addIcon(iconId);
      await _service.saveLibrary(updated);
      await loadLibraries();
    }
  }

  Future<void> removeIconFromLibrary(String libraryId, String iconId) async {
    final library = await _service.getLibrary(libraryId);
    if (library != null) {
      final updated = library.removeIcon(iconId);
      await _service.saveLibrary(updated);
      await loadLibraries();
    }
  }
}

/// 选中的图标库 ID Provider
final selectedLibraryIdProvider = StateProvider<String?>((ref) => null);

/// 选中的图标库 Provider
final selectedLibraryProvider = Provider<IconLibrary?>((ref) {
  final libraryId = ref.watch(selectedLibraryIdProvider);
  if (libraryId == null) return null;
  
  final librariesAsync = ref.watch(iconLibraryListProvider);
  return librariesAsync.whenOrNull(
    data: (libraries) => libraries.where((lib) => lib.id == libraryId).firstOrNull,
  );
});
