import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_toolbox/data/models/project.dart';
import 'package:flutter_toolbox/data/services/project_service.dart';
import 'package:flutter_toolbox/providers/app_providers.dart';

/// 项目服务 Provider
final projectServiceProvider = Provider<ProjectService>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return ProjectServiceImpl(storage);
});

/// 项目列表状态 Provider
final projectListProvider = StateNotifierProvider<ProjectListNotifier, AsyncValue<List<Project>>>((ref) {
  final projectService = ref.watch(projectServiceProvider);
  return ProjectListNotifier(projectService);
});

/// 项目列表状态管理器
class ProjectListNotifier extends StateNotifier<AsyncValue<List<Project>>> {
  final ProjectService _projectService;

  ProjectListNotifier(this._projectService) : super(const AsyncValue.loading()) {
    loadProjects();
  }

  Future<void> loadProjects() async {
    state = const AsyncValue.loading();
    try {
      final projects = await _projectService.getAllProjects();
      state = AsyncValue.data(projects);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addProject(String path) async {
    try {
      final project = await _projectService.analyzeProject(path);
      await _projectService.saveProject(project);
      await loadProjects();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeProject(String id) async {
    await _projectService.deleteProject(id);
    await loadProjects();
  }

  Future<void> updateProjectAccess(String id) async {
    final projects = state.valueOrNull ?? [];
    final index = projects.indexWhere((p) => p.id == id);
    if (index >= 0) {
      final updated = projects[index].updateLastAccessed();
      await _projectService.saveProject(updated);
      await loadProjects();
    }
  }
}

/// 当前选中项目 ID Provider
final selectedProjectIdProvider = StateProvider<String?>((ref) => null);

/// 当前选中项目 Provider
final selectedProjectProvider = Provider<Project?>((ref) {
  final projectId = ref.watch(selectedProjectIdProvider);
  final projectsAsync = ref.watch(projectListProvider);

  if (projectId == null) return null;

  return projectsAsync.whenOrNull(
    data: (projects) {
      try {
        return projects.firstWhere((p) => p.id == projectId);
      } catch (e) {
        return null;
      }
    },
  );
});

/// 项目数量 Provider
final projectCountProvider = Provider<int>((ref) {
  final projectsAsync = ref.watch(projectListProvider);
  return projectsAsync.whenOrNull(data: (projects) => projects.length) ?? 0;
});
