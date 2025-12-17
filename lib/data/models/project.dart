import 'package:uuid/uuid.dart';

/// 框架类型枚举
enum FrameworkType {
  vue('Vue'),
  react('React'),
  angular('Angular'),
  svelte('Svelte'),
  nextjs('Next.js'),
  nuxt('Nuxt'),
  node('Node.js'),
  flutter('Flutter'),
  unknown('Unknown');

  final String displayName;
  const FrameworkType(this.displayName);

  static FrameworkType fromString(String value) {
    return FrameworkType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => FrameworkType.unknown,
    );
  }
}

/// 依赖模型
class Dependency {
  final String name;
  final String version;

  const Dependency({
    required this.name,
    required this.version,
  });

  factory Dependency.fromJson(Map<String, dynamic> json) {
    return Dependency(
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
    return other is Dependency && other.name == name && other.version == version;
  }

  @override
  int get hashCode => name.hashCode ^ version.hashCode;

  @override
  String toString() => 'Dependency(name: $name, version: $version)';
}

/// 项目模型
class Project {
  final String id;
  final String name;
  final String path;
  final String? version;
  final String? description;
  final FrameworkType framework;
  final List<Dependency> dependencies;
  final List<Dependency> devDependencies;
  final Map<String, String> scripts;
  final DateTime createdAt;
  final DateTime lastAccessedAt;

  const Project({
    required this.id,
    required this.name,
    required this.path,
    this.version,
    this.description,
    required this.framework,
    required this.dependencies,
    required this.devDependencies,
    required this.scripts,
    required this.createdAt,
    required this.lastAccessedAt,
  });

  /// 创建新项目
  factory Project.create({
    required String name,
    required String path,
    String? version,
    String? description,
    FrameworkType framework = FrameworkType.unknown,
    List<Dependency> dependencies = const [],
    List<Dependency> devDependencies = const [],
    Map<String, String> scripts = const {},
  }) {
    final now = DateTime.now();
    return Project(
      id: const Uuid().v4(),
      name: name,
      path: path,
      version: version,
      description: description,
      framework: framework,
      dependencies: dependencies,
      devDependencies: devDependencies,
      scripts: scripts,
      createdAt: now,
      lastAccessedAt: now,
    );
  }

  /// 从 JSON 反序列化
  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as String? ?? const Uuid().v4(),
      name: json['name'] as String? ?? '',
      path: json['path'] as String? ?? '',
      version: json['version'] as String?,
      description: json['description'] as String?,
      framework: FrameworkType.fromString(json['framework'] as String? ?? 'unknown'),
      dependencies: (json['dependencies'] as List<dynamic>?)
              ?.map((e) => Dependency.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      devDependencies: (json['devDependencies'] as List<dynamic>?)
              ?.map((e) => Dependency.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      scripts: (json['scripts'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, v.toString()),
          ) ??
          {},
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      lastAccessedAt: json['lastAccessedAt'] != null
          ? DateTime.parse(json['lastAccessedAt'] as String)
          : DateTime.now(),
    );
  }

  /// 序列化为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'path': path,
      'version': version,
      'description': description,
      'framework': framework.name,
      'dependencies': dependencies.map((e) => e.toJson()).toList(),
      'devDependencies': devDependencies.map((e) => e.toJson()).toList(),
      'scripts': scripts,
      'createdAt': createdAt.toIso8601String(),
      'lastAccessedAt': lastAccessedAt.toIso8601String(),
    };
  }

  /// 复制并修改
  Project copyWith({
    String? id,
    String? name,
    String? path,
    String? version,
    String? description,
    FrameworkType? framework,
    List<Dependency>? dependencies,
    List<Dependency>? devDependencies,
    Map<String, String>? scripts,
    DateTime? createdAt,
    DateTime? lastAccessedAt,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      version: version ?? this.version,
      description: description ?? this.description,
      framework: framework ?? this.framework,
      dependencies: dependencies ?? this.dependencies,
      devDependencies: devDependencies ?? this.devDependencies,
      scripts: scripts ?? this.scripts,
      createdAt: createdAt ?? this.createdAt,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
    );
  }

  /// 更新最后访问时间
  Project updateLastAccessed() {
    return copyWith(lastAccessedAt: DateTime.now());
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Project && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Project(id: $id, name: $name, path: $path)';
}
