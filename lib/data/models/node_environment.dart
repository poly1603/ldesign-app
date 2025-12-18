/// npm 包模型
class NpmPackage {
  final String name;
  final String version;

  const NpmPackage({
    required this.name,
    required this.version,
  });

  factory NpmPackage.fromJson(Map<String, dynamic> json) {
    return NpmPackage(
      name: json['name'] as String? ?? '',
      version: json['version'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'version': version,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NpmPackage && other.name == name && other.version == version;
  }

  @override
  int get hashCode => name.hashCode ^ version.hashCode;

  @override
  String toString() => 'NpmPackage(name: $name, version: $version)';
}

/// Node 版本信息
class NodeVersion {
  final String version;
  final String path;
  final bool isActive;
  final String? source; // 'system', 'nvm', 'fnm', 'volta', etc.

  const NodeVersion({
    required this.version,
    required this.path,
    this.isActive = false,
    this.source,
  });

  factory NodeVersion.fromJson(Map<String, dynamic> json) {
    return NodeVersion(
      version: json['version'] as String,
      path: json['path'] as String,
      isActive: json['isActive'] as bool? ?? false,
      source: json['source'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'path': path,
      'isActive': isActive,
      'source': source,
    };
  }
}

/// Node 环境信息
class NodeEnvironment {
  final String? nodeVersion;
  final String? nodePath;
  final String? npmVersion;
  final String? pnpmVersion;
  final String? yarnVersion;
  final List<NpmPackage> globalPackages;
  final List<NodeVersion> installedVersions;
  final String? versionManager; // 'nvm', 'fnm', 'volta', 'n', null
  final bool isInstalled;

  const NodeEnvironment({
    this.nodeVersion,
    this.nodePath,
    this.npmVersion,
    this.pnpmVersion,
    this.yarnVersion,
    this.globalPackages = const [],
    this.installedVersions = const [],
    this.versionManager,
    this.isInstalled = false,
  });

  /// 创建未安装状态
  factory NodeEnvironment.notInstalled() => const NodeEnvironment(
        isInstalled: false,
      );

  factory NodeEnvironment.fromJson(Map<String, dynamic> json) {
    return NodeEnvironment(
      nodeVersion: json['nodeVersion'] as String?,
      nodePath: json['nodePath'] as String?,
      npmVersion: json['npmVersion'] as String?,
      pnpmVersion: json['pnpmVersion'] as String?,
      yarnVersion: json['yarnVersion'] as String?,
      globalPackages: (json['globalPackages'] as List<dynamic>?)
              ?.map((e) => NpmPackage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      installedVersions: (json['installedVersions'] as List<dynamic>?)
              ?.map((e) => NodeVersion.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      versionManager: json['versionManager'] as String?,
      isInstalled: json['isInstalled'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nodeVersion': nodeVersion,
      'nodePath': nodePath,
      'npmVersion': npmVersion,
      'pnpmVersion': pnpmVersion,
      'yarnVersion': yarnVersion,
      'globalPackages': globalPackages.map((e) => e.toJson()).toList(),
      'installedVersions': installedVersions.map((e) => e.toJson()).toList(),
      'versionManager': versionManager,
      'isInstalled': isInstalled,
    };
  }

  NodeEnvironment copyWith({
    String? nodeVersion,
    String? nodePath,
    String? npmVersion,
    String? pnpmVersion,
    String? yarnVersion,
    List<NpmPackage>? globalPackages,
    List<NodeVersion>? installedVersions,
    String? versionManager,
    bool? isInstalled,
  }) {
    return NodeEnvironment(
      nodeVersion: nodeVersion ?? this.nodeVersion,
      nodePath: nodePath ?? this.nodePath,
      npmVersion: npmVersion ?? this.npmVersion,
      pnpmVersion: pnpmVersion ?? this.pnpmVersion,
      yarnVersion: yarnVersion ?? this.yarnVersion,
      globalPackages: globalPackages ?? this.globalPackages,
      installedVersions: installedVersions ?? this.installedVersions,
      versionManager: versionManager ?? this.versionManager,
      isInstalled: isInstalled ?? this.isInstalled,
    );
  }

  @override
  String toString() => 'NodeEnvironment(nodeVersion: $nodeVersion, isInstalled: $isInstalled)';
}
