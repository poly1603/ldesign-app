import 'dart:convert';

enum ProjectType {
  webApp,           // Web应用
  mobileApp,        // 移动应用
  desktopApp,       // 桌面应用
  backendApp,       // 后端应用
  componentLibrary, // 组件库
  utilityLibrary,   // 工具库
  nodeLibrary,      // Node库
  cliTool,          // 命令行工具
  monorepo,         // Monorepo
  unknown,
}

enum ProjectFramework {
  flutter,
  react,
  vue,
  angular,
  nextjs,
  nuxt,
  svelte,
  solidjs,
  preact,
  gatsby,
  remix,
  astro,
  qwik,
  vite,
  webpack,
  express,
  nestjs,
  koa,
  fastify,
  django,
  fastapi,
  flask,
  spring,
  electron,
  tauri,
  reactNative,
  ionic,
  capacitor,
  cordova,
  unknown,
}

class Project {
  final String id;
  final String name;
  final String path;
  final String? description;
  final ProjectType type;
  final ProjectFramework framework;
  final String? language;
  final String? version;
  final DateTime lastModified;
  final DateTime addedAt;
  final List<String> tags;

  Project({
    required this.id,
    required this.name,
    required this.path,
    this.description,
    required this.type,
    required this.framework,
    this.language,
    this.version,
    required this.lastModified,
    required this.addedAt,
    this.tags = const [],
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as String,
      name: json['name'] as String,
      path: json['path'] as String,
      description: json['description'] as String?,
      type: ProjectType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ProjectType.unknown,
      ),
      framework: ProjectFramework.values.firstWhere(
        (e) => e.name == json['framework'],
        orElse: () => ProjectFramework.unknown,
      ),
      language: json['language'] as String?,
      version: json['version'] as String?,
      lastModified: DateTime.parse(json['lastModified'] as String),
      addedAt: DateTime.parse(json['addedAt'] as String),
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'path': path,
      'description': description,
      'type': type.name,
      'framework': framework.name,
      'language': language,
      'version': version,
      'lastModified': lastModified.toIso8601String(),
      'addedAt': addedAt.toIso8601String(),
      'tags': tags,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  factory Project.fromJsonString(String jsonString) =>
      Project.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);

  Project copyWith({
    String? id,
    String? name,
    String? path,
    String? description,
    ProjectType? type,
    ProjectFramework? framework,
    String? language,
    String? version,
    DateTime? lastModified,
    DateTime? addedAt,
    List<String>? tags,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      description: description ?? this.description,
      type: type ?? this.type,
      framework: framework ?? this.framework,
      language: language ?? this.language,
      version: version ?? this.version,
      lastModified: lastModified ?? this.lastModified,
      addedAt: addedAt ?? this.addedAt,
      tags: tags ?? this.tags,
    );
  }

  String getTypeDisplayName() {
    switch (type) {
      case ProjectType.webApp:
        return 'Web App';
      case ProjectType.mobileApp:
        return 'Mobile App';
      case ProjectType.desktopApp:
        return 'Desktop App';
      case ProjectType.backendApp:
        return 'Backend';
      case ProjectType.componentLibrary:
        return 'Component Library';
      case ProjectType.utilityLibrary:
        return 'Utility Library';
      case ProjectType.nodeLibrary:
        return 'Node Library';
      case ProjectType.cliTool:
        return 'CLI Tool';
      case ProjectType.monorepo:
        return 'Monorepo';
      case ProjectType.unknown:
        return 'Unknown';
    }
  }

  String getFrameworkDisplayName() {
    switch (framework) {
      case ProjectFramework.flutter:
        return 'Flutter';
      case ProjectFramework.react:
        return 'React';
      case ProjectFramework.vue:
        return 'Vue';
      case ProjectFramework.angular:
        return 'Angular';
      case ProjectFramework.nextjs:
        return 'Next.js';
      case ProjectFramework.nuxt:
        return 'Nuxt';
      case ProjectFramework.svelte:
        return 'Svelte';
      case ProjectFramework.solidjs:
        return 'Solid.js';
      case ProjectFramework.preact:
        return 'Preact';
      case ProjectFramework.gatsby:
        return 'Gatsby';
      case ProjectFramework.remix:
        return 'Remix';
      case ProjectFramework.astro:
        return 'Astro';
      case ProjectFramework.qwik:
        return 'Qwik';
      case ProjectFramework.vite:
        return 'Vite';
      case ProjectFramework.webpack:
        return 'Webpack';
      case ProjectFramework.express:
        return 'Express';
      case ProjectFramework.nestjs:
        return 'NestJS';
      case ProjectFramework.koa:
        return 'Koa';
      case ProjectFramework.fastify:
        return 'Fastify';
      case ProjectFramework.django:
        return 'Django';
      case ProjectFramework.fastapi:
        return 'FastAPI';
      case ProjectFramework.flask:
        return 'Flask';
      case ProjectFramework.spring:
        return 'Spring';
      case ProjectFramework.electron:
        return 'Electron';
      case ProjectFramework.tauri:
        return 'Tauri';
      case ProjectFramework.reactNative:
        return 'React Native';
      case ProjectFramework.ionic:
        return 'Ionic';
      case ProjectFramework.capacitor:
        return 'Capacitor';
      case ProjectFramework.cordova:
        return 'Cordova';
      case ProjectFramework.unknown:
        return 'Unknown';
    }
  }
}
