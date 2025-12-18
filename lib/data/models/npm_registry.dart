import 'package:flutter/material.dart';

/// NPM 源类型
enum NpmRegistryType {
  public,    // 公共源
  remote,    // 远程私有源
  local,     // 本地私有源（Verdaccio）
}

/// NPM 源配置
class NpmRegistry {
  final String id;
  final String name;
  final String url;
  final NpmRegistryType type;
  final bool isDefault;
  final String? username;
  final String? password;
  final String? email;
  
  // Verdaccio 本地源特有配置
  final int? port;
  final String? storagePath;
  final bool? isRunning;
  final int? pid;

  const NpmRegistry({
    required this.id,
    required this.name,
    required this.url,
    required this.type,
    this.isDefault = false,
    this.username,
    this.password,
    this.email,
    this.port,
    this.storagePath,
    this.isRunning,
    this.pid,
  });

  factory NpmRegistry.fromJson(Map<String, dynamic> json) {
    return NpmRegistry(
      id: json['id'] as String,
      name: json['name'] as String,
      url: json['url'] as String,
      type: NpmRegistryType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NpmRegistryType.public,
      ),
      isDefault: json['isDefault'] as bool? ?? false,
      username: json['username'] as String?,
      password: json['password'] as String?,
      email: json['email'] as String?,
      port: json['port'] as int?,
      storagePath: json['storagePath'] as String?,
      isRunning: json['isRunning'] as bool?,
      pid: json['pid'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'type': type.name,
      'isDefault': isDefault,
      'username': username,
      'password': password,
      'email': email,
      'port': port,
      'storagePath': storagePath,
      'isRunning': isRunning,
      'pid': pid,
    };
  }

  NpmRegistry copyWith({
    String? id,
    String? name,
    String? url,
    NpmRegistryType? type,
    bool? isDefault,
    String? username,
    String? password,
    String? email,
    int? port,
    String? storagePath,
    bool? isRunning,
    int? pid,
  }) {
    return NpmRegistry(
      id: id ?? this.id,
      name: name ?? this.name,
      url: url ?? this.url,
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
      username: username ?? this.username,
      password: password ?? this.password,
      email: email ?? this.email,
      port: port ?? this.port,
      storagePath: storagePath ?? this.storagePath,
      isRunning: isRunning ?? this.isRunning,
      pid: pid ?? this.pid,
    );
  }

  /// 获取类型显示名称
  String get typeDisplayName {
    switch (type) {
      case NpmRegistryType.public:
        return '公共源';
      case NpmRegistryType.remote:
        return '远程私有源';
      case NpmRegistryType.local:
        return '本地私有源';
    }
  }

  /// 获取类型图标
  IconData get typeIcon {
    switch (type) {
      case NpmRegistryType.public:
        return Icons.public_rounded;
      case NpmRegistryType.remote:
        return Icons.cloud_rounded;
      case NpmRegistryType.local:
        return Icons.computer_rounded;
    }
  }

  /// 获取类型颜色
  Color getTypeColor(BuildContext context) {
    switch (type) {
      case NpmRegistryType.public:
        return Colors.blue;
      case NpmRegistryType.remote:
        return Colors.purple;
      case NpmRegistryType.local:
        return Colors.green;
    }
  }
}

// 预设的公共 NPM 源
class PresetRegistries {
  static const List<Map<String, dynamic>> publicRegistries = [
    {
      'name': 'npm 官方源',
      'url': 'https://registry.npmjs.org/',
      'supportsAuth': true,
      'authType': 'npm', // npm 标准认证
      'authDescription': '支持 npm 账号登录，可发布包和访问私有包',
      'requiresEmail': true,
    },
    {
      'name': '淘宝镜像',
      'url': 'https://registry.npmmirror.com/',
      'supportsAuth': false,
      'authType': 'none',
      'authDescription': '只读镜像源，不支持认证和发布',
      'requiresEmail': false,
    },
    {
      'name': '腾讯云镜像',
      'url': 'https://mirrors.cloud.tencent.com/npm/',
      'supportsAuth': false,
      'authType': 'none',
      'authDescription': '只读镜像源，不支持认证和发布',
      'requiresEmail': false,
    },
    {
      'name': '华为云镜像',
      'url': 'https://mirrors.huaweicloud.com/repository/npm/',
      'supportsAuth': false,
      'authType': 'none',
      'authDescription': '只读镜像源，不支持认证和发布',
      'requiresEmail': false,
    },
    {
      'name': 'cnpm 镜像',
      'url': 'https://r.cnpmjs.org/',
      'supportsAuth': false,
      'authType': 'none',
      'authDescription': '只读镜像源，不支持认证和发布',
      'requiresEmail': false,
    },
    {
      'name': 'GitHub Package Registry',
      'url': 'https://npm.pkg.github.com/',
      'supportsAuth': true,
      'authType': 'token', // Token 认证
      'authDescription': '使用 GitHub Personal Access Token 认证',
      'requiresEmail': false,
    },
    {
      'name': 'Yarn Registry',
      'url': 'https://registry.yarnpkg.com/',
      'supportsAuth': true,
      'authType': 'npm',
      'authDescription': '支持 npm 账号登录',
      'requiresEmail': true,
    },
  ];
  
  /// 获取预设源的认证信息
  static Map<String, dynamic>? getAuthInfo(String name) {
    try {
      return publicRegistries.firstWhere((r) => r['name'] == name);
    } catch (e) {
      return null;
    }
  }
  
  /// 检查源是否支持认证
  static bool supportsAuth(String name) {
    final info = getAuthInfo(name);
    return info?['supportsAuth'] == true;
  }
  
  /// 获取认证类型
  static String getAuthType(String name) {
    final info = getAuthInfo(name);
    return info?['authType'] ?? 'none';
  }
}
