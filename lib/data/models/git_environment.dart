/// Git 配置
class GitConfig {
  // 用户信息
  final String? userName;
  final String? userEmail;
  
  // 核心配置
  final String? editor;
  final String? defaultBranch;
  final bool? autoSetupRemote;
  
  // 行为配置
  final bool? autoCorrect;
  final String? pullRebase;
  final bool? pushDefault;
  
  // 显示配置
  final bool? colorUi;
  final String? diffTool;
  final String? mergeTool;
  
  // 安全配置
  final bool? sslVerify;
  final String? credentialHelper;

  const GitConfig({
    this.userName,
    this.userEmail,
    this.editor,
    this.defaultBranch,
    this.autoSetupRemote,
    this.autoCorrect,
    this.pullRebase,
    this.pushDefault,
    this.colorUi,
    this.diffTool,
    this.mergeTool,
    this.sslVerify,
    this.credentialHelper,
  });

  factory GitConfig.empty() => const GitConfig();

  factory GitConfig.fromJson(Map<String, dynamic> json) {
    return GitConfig(
      userName: json['userName'] as String?,
      userEmail: json['userEmail'] as String?,
      editor: json['editor'] as String?,
      defaultBranch: json['defaultBranch'] as String?,
      autoSetupRemote: json['autoSetupRemote'] as bool?,
      autoCorrect: json['autoCorrect'] as bool?,
      pullRebase: json['pullRebase'] as String?,
      pushDefault: json['pushDefault'] as bool?,
      colorUi: json['colorUi'] as bool?,
      diffTool: json['diffTool'] as String?,
      mergeTool: json['mergeTool'] as String?,
      sslVerify: json['sslVerify'] as bool?,
      credentialHelper: json['credentialHelper'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'userEmail': userEmail,
      'editor': editor,
      'defaultBranch': defaultBranch,
      'autoSetupRemote': autoSetupRemote,
      'autoCorrect': autoCorrect,
      'pullRebase': pullRebase,
      'pushDefault': pushDefault,
      'colorUi': colorUi,
      'diffTool': diffTool,
      'mergeTool': mergeTool,
      'sslVerify': sslVerify,
      'credentialHelper': credentialHelper,
    };
  }

  GitConfig copyWith({
    String? userName,
    String? userEmail,
    String? editor,
    String? defaultBranch,
    bool? autoSetupRemote,
    bool? autoCorrect,
    String? pullRebase,
    bool? pushDefault,
    bool? colorUi,
    String? diffTool,
    String? mergeTool,
    bool? sslVerify,
    String? credentialHelper,
  }) {
    return GitConfig(
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      editor: editor ?? this.editor,
      defaultBranch: defaultBranch ?? this.defaultBranch,
      autoSetupRemote: autoSetupRemote ?? this.autoSetupRemote,
      autoCorrect: autoCorrect ?? this.autoCorrect,
      pullRebase: pullRebase ?? this.pullRebase,
      pushDefault: pushDefault ?? this.pushDefault,
      colorUi: colorUi ?? this.colorUi,
      diffTool: diffTool ?? this.diffTool,
      mergeTool: mergeTool ?? this.mergeTool,
      sslVerify: sslVerify ?? this.sslVerify,
      credentialHelper: credentialHelper ?? this.credentialHelper,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GitConfig &&
        other.userName == userName &&
        other.userEmail == userEmail &&
        other.editor == editor &&
        other.defaultBranch == defaultBranch &&
        other.autoSetupRemote == autoSetupRemote &&
        other.autoCorrect == autoCorrect &&
        other.pullRebase == pullRebase &&
        other.pushDefault == pushDefault &&
        other.colorUi == colorUi &&
        other.diffTool == diffTool &&
        other.mergeTool == mergeTool &&
        other.sslVerify == sslVerify &&
        other.credentialHelper == credentialHelper;
  }

  @override
  int get hashCode => Object.hash(
        userName,
        userEmail,
        editor,
        defaultBranch,
        autoSetupRemote,
        autoCorrect,
        pullRebase,
        pushDefault,
        colorUi,
        diffTool,
        mergeTool,
        sslVerify,
        credentialHelper,
      );

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
