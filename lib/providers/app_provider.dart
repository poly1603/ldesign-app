import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../config/theme_config.dart';
import '../utils/storage_util.dart';
import '../models/project.dart';

class AppProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  Color _primaryColor = ThemeConfig.presetColors[0];
  AppSize _appSize = AppSize.standard;
  Locale _locale = const Locale('zh');
  bool _sidebarCollapsed = false;
  String _currentRoute = '/';
  Map<String, dynamic> _routeParams = {};
  List<Project> _projects = [];
  String _projectsPath = '';
  String _searchQuery = '';
  ProjectType? _filterType;
  String _sortBy = 'name'; // name, date, type
  bool _sortAscending = true;

  ThemeMode get themeMode => _themeMode;
  Color get primaryColor => _primaryColor;
  AppSize get appSize => _appSize;
  Locale get locale => _locale;
  bool get sidebarCollapsed => _sidebarCollapsed;
  String get currentRoute => _currentRoute;
  Map<String, dynamic> get routeParams => _routeParams;
  List<Project> get projects => _getFilteredProjects();
  List<Project> get allProjects => _projects;
  String get projectsPath => _projectsPath;
  String get searchQuery => _searchQuery;
  ProjectType? get filterType => _filterType;
  String get sortBy => _sortBy;
  bool get sortAscending => _sortAscending;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  AppProvider();

  Future<void> initialize() async {
    await _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      if (kDebugMode) {
        debugPrint('AppProvider._loadPreferences: Starting to load preferences');
      }
      
      try {
        _themeMode = await StorageUtil.getThemeMode();
      } catch (e) {
        if (kDebugMode) {
          debugPrint('AppProvider._loadPreferences: Error loading theme mode: $e');
        }
        _themeMode = ThemeMode.light;
      }
      
      try {
        _primaryColor = await StorageUtil.getPrimaryColor();
      } catch (e) {
        if (kDebugMode) {
          debugPrint('AppProvider._loadPreferences: Error loading primary color: $e');
        }
        _primaryColor = ThemeConfig.presetColors[0];
      }
      
      try {
        _appSize = await StorageUtil.getAppSize();
      } catch (e) {
        if (kDebugMode) {
          debugPrint('AppProvider._loadPreferences: Error loading app size: $e');
        }
        _appSize = AppSize.standard;
      }
      
      try {
        _locale = await StorageUtil.getLocale();
      } catch (e) {
        if (kDebugMode) {
          debugPrint('AppProvider._loadPreferences: Error loading locale: $e');
        }
        _locale = const Locale('zh');
      }
      
      try {
        _sidebarCollapsed = await StorageUtil.getSidebarCollapsed();
      } catch (e) {
        if (kDebugMode) {
          debugPrint('AppProvider._loadPreferences: Error loading sidebar state: $e');
        }
        _sidebarCollapsed = false;
      }
      
      try {
        _projectsPath = await StorageUtil.getProjectsPath();
      } catch (e) {
        if (kDebugMode) {
          debugPrint('AppProvider._loadPreferences: Error loading projects path: $e');
        }
      }
      
      if (kDebugMode) {
        debugPrint('AppProvider._loadPreferences: Projects file path: $_projectsPath');
      }
      
      try {
        _projects = await StorageUtil.getProjects();
        
        if (kDebugMode) {
          debugPrint('AppProvider._loadPreferences: Successfully loaded ${_projects.length} projects');
          if (_projects.isNotEmpty) {
            debugPrint('AppProvider._loadPreferences: First project: ${_projects[0].name}');
          }
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('AppProvider._loadPreferences: Error loading projects: $e');
        }
        _projects = [];
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('AppProvider._loadPreferences: Error loading preferences: $e');
        debugPrint('AppProvider._loadPreferences: Stack trace: $stackTrace');
      }
      // 确保有默认值，避免应用崩溃
      _projects = [];
    }
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    StorageUtil.setThemeMode(mode);
    notifyListeners();
  }

  void toggleThemeMode() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    StorageUtil.setThemeMode(_themeMode);
    notifyListeners();
  }

  void setPrimaryColor(Color color) {
    _primaryColor = color;
    StorageUtil.setPrimaryColor(color);
    notifyListeners();
  }

  void setAppSize(AppSize size) {
    _appSize = size;
    StorageUtil.setAppSize(size);
    notifyListeners();
  }

  void setLocale(Locale locale) {
    _locale = locale;
    StorageUtil.setLocale(locale);
    notifyListeners();
  }

  void toggleSidebar() {
    _sidebarCollapsed = !_sidebarCollapsed;
    StorageUtil.setSidebarCollapsed(_sidebarCollapsed);
    notifyListeners();
  }

  void setSidebarCollapsed(bool collapsed) {
    _sidebarCollapsed = collapsed;
    StorageUtil.setSidebarCollapsed(collapsed);
    notifyListeners();
  }

  void setCurrentRoute(String route, {Map<String, dynamic>? params}) {
    _currentRoute = route;
    _routeParams = params ?? {};
    notifyListeners();
  }

  void navigateToProjectDetail(String projectId) {
    setCurrentRoute('/project-detail', params: {'projectId': projectId});
  }

  ThemeData getLightTheme() {
    return ThemeConfig.getLightTheme(_primaryColor, _appSize);
  }

  ThemeData getDarkTheme() {
    return ThemeConfig.getDarkTheme(_primaryColor, _appSize);
  }

  // Project management
  Future<void> addProject(Project project) async {
    _projects.add(project);
    
    if (kDebugMode) {
      debugPrint('AppProvider.addProject: Adding project: ${project.name}');
      debugPrint('AppProvider.addProject: Total projects count: ${_projects.length}');
    }
    
    // 先通知 UI，确保列表即时刷新；再异步持久化
    notifyListeners();
    
    try {
      await StorageUtil.setProjects(_projects);
      if (kDebugMode) {
        debugPrint('AppProvider.addProject: Successfully saved ${_projects.length} projects to storage');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AppProvider.addProject: Error saving projects: $e');
      }
    }
  }

  Future<void> setProjectsPath(String path) async {
    _projectsPath = path;
    await StorageUtil.setProjectsPath(path);
    // 立刻把当前内存数据写入新位置
    await StorageUtil.setProjects(_projects);
    notifyListeners();
  }

  Future<void> removeProject(String projectId) async {
    _projects.removeWhere((p) => p.id == projectId);
    // 先通知 UI，确保列表即时刷新；再异步持久化
    notifyListeners();
    await StorageUtil.setProjects(_projects);
  }

  Future<void> updateProject(Project project) async {
    final index = _projects.indexWhere((p) => p.id == project.id);
    if (index != -1) {
      _projects[index] = project;
      // 先通知 UI，确保列表即时刷新；再异步持久化
      notifyListeners();
      await StorageUtil.setProjects(_projects);
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilterType(ProjectType? type) {
    _filterType = type;
    notifyListeners();
  }

  void setSortBy(String sortBy) {
    _sortBy = sortBy;
    notifyListeners();
  }

  void toggleSortOrder() {
    _sortAscending = !_sortAscending;
    notifyListeners();
  }

  List<Project> _getFilteredProjects() {
    var filtered = _projects.where((project) {
      // Filter by search query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!project.name.toLowerCase().contains(query) &&
            !(project.description?.toLowerCase().contains(query) ?? false) &&
            !project.getFrameworkDisplayName().toLowerCase().contains(query)) {
          return false;
        }
      }

      // Filter by type
      if (_filterType != null && project.type != _filterType) {
        return false;
      }

      return true;
    }).toList();

    // Sort
    filtered.sort((a, b) {
      int comparison;
      switch (_sortBy) {
        case 'date':
          comparison = a.lastModified.compareTo(b.lastModified);
          break;
        case 'type':
          comparison = a.type.index.compareTo(b.type.index);
          break;
        case 'name':
        default:
          comparison = a.name.toLowerCase().compareTo(b.name.toLowerCase());
      }
      return _sortAscending ? comparison : -comparison;
    });

    return filtered;
  }
}
