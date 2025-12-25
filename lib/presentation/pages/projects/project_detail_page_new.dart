import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_toolbox/data/models/project.dart';
import 'package:flutter_toolbox/providers/project_providers.dart';
import 'package:flutter_toolbox/presentation/pages/projects/tabs/dependencies_tab.dart';
import 'package:flutter_toolbox/presentation/pages/projects/tabs/scripts_tab.dart';
import 'package:flutter_toolbox/presentation/pages/projects/tabs/package_json_tab.dart';
import 'package:flutter_toolbox/presentation/pages/projects/tabs/typescript_tab.dart';
import 'package:flutter_toolbox/presentation/pages/projects/tabs/file_browser_tab.dart';
import 'package:flutter_toolbox/presentation/pages/projects/tabs/config_files_tab.dart';
import 'package:path/path.dart' as path;

/// 增强版项目详情页面
class EnhancedProjectDetailPage extends ConsumerStatefulWidget {
  final String projectId;

  const EnhancedProjectDetailPage({super.key, required this.projectId});

  @override
  ConsumerState<EnhancedProjectDetailPage> createState() => _EnhancedProjectDetailPageState();
}

class _EnhancedProjectDetailPageState extends ConsumerState<EnhancedProjectDetailPage> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // README 内容
  String? _readmeContent;
  bool _isLoadingReadme = false;
  
  // package.json 内容
  Map<String, dynamic>? _packageJson;
  
  // 依赖信息
  Map<String, DependencyInfo> _dependenciesInfo = {};
  bool _isCheckingUpdates = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    _loadProjectData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProjectData() async {
    final project = ref.read(selectedProjectProvider);
    if (project == null) return;
    
    await Future.wait([
      _loadReadme(project),
      _loadPackageJson(project),
    ]);
  }

  Future<void> _loadReadme(Project project) async {
    setState(() => _isLoadingReadme = true);
    
    try {
      final readmePath = path.join(project.path, 'README.md');
      final file = File(readmePath);
      
      if (await file.exists()) {
        final content = await file.readAsString();
        setState(() => _readmeContent = content);
      }
    } catch (e) {
      debugPrint('Error loading README: $e');
    } finally {
      setState(() => _isLoadingReadme = false);
    }
  }

  Future<void> _loadPackageJson(Project project) async {
    try {
      final packageJsonPath = path.join(project.path, 'package.json');
      final file = File(packageJsonPath);
      
      if (await file.exists()) {
        final content = await file.readAsString();
        setState(() => _packageJson = jsonDecode(content));
      }
    } catch (e) {
      debugPrint('Error loading package.json: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final project = ref.watch(selectedProjectProvider);
    final colorScheme = Theme.of(context).colorScheme;

    if (project == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('项目未找到')),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow,
      body: Column(
        children: [
          _buildHeader(context, project),
          Container(
            color: colorScheme.surface,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: const [
                Tab(icon: Icon(Icons.description_outlined), text: 'README'),
                Tab(icon: Icon(Icons.inventory_2_outlined), text: '依赖管理'),
                Tab(icon: Icon(Icons.play_circle_outline), text: '脚本'),
                Tab(icon: Icon(Icons.settings_outlined), text: 'package.json'),
                Tab(icon: Icon(Icons.code_outlined), text: 'TypeScript'),
                Tab(icon: Icon(Icons.folder_outlined), text: '文件浏览'),
                Tab(icon: Icon(Icons.tune_outlined), text: '配置文件'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildReadmeTab(context, project),
                DependenciesTab(project: project),
                ScriptsTab(project: project),
                PackageJsonTab(project: project),
                TypeScriptTab(project: project),
                FileBrowserTab(project: project),
                ConfigFilesTab(project: project),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Project project) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      color: colorScheme.surface,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 16),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getFrameworkIcon(project.framework),
              size: 32,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  project.path,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: '刷新',
            onPressed: _loadProjectData,
          ),
        ],
      ),
    );
  }

  // README Tab
  Widget _buildReadmeTab(BuildContext context, Project project) {
    if (_isLoadingReadme) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_readmeContent == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            const Text('未找到 README.md 文件'),
          ],
        ),
      );
    }

    return Markdown(
      data: _readmeContent!,
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        p: const TextStyle(fontSize: 14, height: 1.6),
        h1: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        h2: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        h3: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}

/// 依赖信息
class DependencyInfo {
  final String name;
  final String currentVersion;
  final String? latestVersion;
  final bool hasUpdate;

  DependencyInfo({
    required this.name,
    required this.currentVersion,
    this.latestVersion,
    required this.hasUpdate,
  });
}

/// 获取框架图标
IconData _getFrameworkIcon(FrameworkType framework) {
  switch (framework) {
    case FrameworkType.vue:
      return Icons.web;
    case FrameworkType.react:
      return Icons.web;
    case FrameworkType.angular:
      return Icons.web;
    case FrameworkType.svelte:
      return Icons.web;
    case FrameworkType.nextjs:
      return Icons.web;
    case FrameworkType.nuxt:
      return Icons.web;
    case FrameworkType.node:
      return Icons.dns;
    case FrameworkType.flutter:
      return Icons.flutter_dash;
    case FrameworkType.unknown:
      return Icons.folder;
  }
}
