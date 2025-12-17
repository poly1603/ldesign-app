/// Git 配置
class GitConfig {
  final String? userName;
  final String? userEmail;

  const GitConfig({
    this.userName,
    this.userEmail,
  });

  factory GitConfig.empty() => const GitConfig();

  factory GitConfig.fromJson(Map<String, dynamic> json) {
    return GitConfig(
      userName: json['userName'] as String?,
      userEmail: json['userEmail'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'userEmail': userEmail,
    };
  }

  GitConfig copyWith({
    String? userName,
    String? userEmail,
  }) {
    return GitConfig(
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GitConfig &&
        other.userName == userName &&
        other.userEmail == userEmail;
  }

  @override
  int get hashCode => userName.hashCode ^ userEmail.hashCode;

  @override
  String toString() => 'GitConfig(userName: $userName, userEmail: $userEmail)';
}

/// Git 环境信息
class GitEnvironment {
  final String? gitVersion;
  final String? gitPath;
  final GitConfig config;
  final bool isInstalled;

  const GitEnvironment({
    this.gitVersion,
    this.gitPath,
    this.config = const GitConfig(),
    this.isInstalled = false,
  });

  /// 创建未安装状态
  factory GitEnvironment.notInstalled() => const GitEnvironment(
        isInstalled: false,
      );

  factory GitEnvironment.fromJson(Map<String, dynamic> json) {
    return GitEnvironment(
      gitVersion: json['gitVersion'] as String?,
      gitPath: json['gitPath'] as String?,
      config: json['config'] != null
          ? GitConfig.fromJson(json['config'] as Map<String, dynamic>)
          : const GitConfig(),
      isInstalled: json['isInstalled'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gitVersion': gitVersion,
      'gitPath': gitPath,
      'config': config.toJson(),
      'isInstalled': isInstalled,
    };
  }

  GitEnvironment copyWith({
    String? gitVersion,
    String? gitPath,
    GitConfig? config,
    bool? isInstalled,
  }) {
    return GitEnvironment(
      gitVersion: gitVersion ?? this.gitVersion,
      gitPath: gitPath ?? this.gitPath,
      config: config ?? this.config,
      isInstalled: isInstalled ?? this.isInstalled,
    );
  }

  @override
  String toString() => 'GitEnvironment(gitVersion: $gitVersion, isInstalled: $isInstalled)';
}
