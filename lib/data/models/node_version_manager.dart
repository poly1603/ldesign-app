/// Node 版本管理工具类型
enum NodeVersionManagerType {
  nvm('nvm', 'NVM for Windows', 'Node Version Manager for Windows'),
  fnm('fnm', 'Fast Node Manager', '快速的 Node 版本管理器'),
  volta('volta', 'Volta', 'JavaScript 工具管理器');

  final String id;
  final String displayName;
  final String description;

  const NodeVersionManagerType(this.id, this.displayName, this.description);

  static NodeVersionManagerType? fromString(String? value) {
    if (value == null) return null;
    try {
      return NodeVersionManagerType.values.firstWhere(
        (e) => e.id.toLowerCase() == value.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }
}

/// 迁移状态
class MigrationState {
  final NodeVersionManagerType? fromTool;
  final NodeVersionManagerType toTool;
  final String? currentNodeVersion;
  final List<String> installedVersions;
  final List<GlobalPackage> globalPackages;
  final DateTime timestamp;

  const MigrationState({
    this.fromTool,
    required this.toTool,
    this.currentNodeVersion,
    this.installedVersions = const [],
    this.globalPackages = const [],
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'fromTool': fromTool?.id,
      'toTool': toTool.id,
      'currentNodeVersion': currentNodeVersion,
      'installedVersions': installedVersions,
      'globalPackages': globalPackages.map((e) => e.toJson()).toList(),
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory MigrationState.fromJson(Map<String, dynamic> json) {
    return MigrationState(
      fromTool: NodeVersionManagerType.fromString(json['fromTool'] as String?),
      toTool: NodeVersionManagerType.fromString(json['toTool'] as String)!,
      currentNodeVersion: json['currentNodeVersion'] as String?,
      installedVersions: (json['installedVersions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      globalPackages: (json['globalPackages'] as List<dynamic>?)
              ?.map((e) => GlobalPackage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

/// 全局包信息
class GlobalPackage {
  final String name;
  final String version;

  const GlobalPackage({
    required this.name,
    required this.version,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'version': version,
    };
  }

  factory GlobalPackage.fromJson(Map<String, dynamic> json) {
    return GlobalPackage(
      name: json['name'] as String,
      version: json['version'] as String,
    );
  }
}
