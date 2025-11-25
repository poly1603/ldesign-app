# Node Manager 增强安装器

这是一个全面的、生产级的 Node.js 版本管理工具自动安装系统，集成到 Flutter 应用中。

## 功能特性

### ✅ 核心功能

1. **跨平台支持**
   - Windows (7/8/10/11)
   - macOS (10.14+)
   - Linux (Ubuntu, Debian, CentOS, Fedora, Arch 等)

2. **自动系统检测**
   - 操作系统类型和版本
   - CPU 架构 (x86, x64, ARM, ARM64)
   - 管理员权限状态
   - 可用包管理器检测

3. **全面预检查**
   - 磁盘空间检查（需要至少 500MB）
   - 网络连接测试
   - 写入权限验证
   - 系统兼容性检查
   - 依赖项检查
   - 代理和防火墙检测

4. **智能下载**
   - 自动代理配置支持
   - 失败自动重试（默认 3 次）
   - 断点续传
   - 文件完整性校验（MD5/SHA256）
   - 本地缓存机制
   - 进度追踪

5. **多种安装策略**
   - Windows: winget, Chocolatey, Scoop, 直接下载
   - macOS: Homebrew, 安装脚本
   - Linux: apt, yum, dnf, pacman, 安装脚本

6. **错误处理和回滚**
   - 安装前自动创建回滚点
   - 失败时自动回滚
   - 手动回滚支持
   - 完整的备份管理

7. **详细日志**
   - 时间戳记录
   - 分阶段进度显示
   - 实时日志输出
   - 错误详情追踪

## 架构

```
lib/services/installer/
├── system_detector.dart       # 系统检测
├── pre_check.dart             # 预检查
├── smart_downloader.dart      # 智能下载器
├── installation_strategy.dart # 安装策略
├── rollback_manager.dart      # 回滚管理
├── enhanced_installer.dart    # 主安装器
└── README.md                  # 本文档
```

## 使用示例

### 基本用法

```dart
import 'package:my_flutter_app/services/node_manager_service.dart';

// 获取服务实例
final service = NodeManagerService();

// 安装 Node 版本管理器
await service.installManager(
  NodeManagerType.nvmWindows,
  'C:\\Program Files\\nvm',
  onLog: (message) {
    print(message);
  },
);
```

### 高级用法

```dart
import 'package:my_flutter_app/services/installer/enhanced_installer.dart';

// 创建增强安装器实例
final installer = EnhancedInstaller();
await installer.initialize();

// 设置进度回调
installer.onProgress = (progress) {
  print('${progress.stage}: ${(progress.progress * 100).toFixed(1)}%');
  print(progress.message);
};

// 设置日志回调
installer.onLog = (log) {
  print(log);
};

// 执行安装
final result = await installer.installManager(
  type: NodeManagerType.fnm,
  installPath: '/usr/local/fnm',
);

if (result.success) {
  print('安装成功！用时: ${result.duration.inSeconds}秒');
  print('日志条数: ${result.logs.length}');
} else {
  print('安装失败: ${result.error}');
}
```

### 系统检测

```dart
import 'package:my_flutter_app/services/installer/system_detector.dart';

// 检测系统信息
final sysInfo = await SystemDetector.detect();
print('平台: ${sysInfo.platform}');
print('架构: ${sysInfo.architecture}');
print('OS版本: ${sysInfo.osVersion}');
print('管理员: ${sysInfo.isAdmin}');

// 检测包管理器
final managers = await SystemDetector.detectPackageManagers();
for (final manager in managers.where((m) => m.isAvailable)) {
  print('${manager.name} ${manager.version}');
}
```

### 预检查

```dart
import 'package:my_flutter_app/services/installer/pre_check.dart';

// 执行预检查
final results = await PreChecker.runAllChecks(
  installPath: '/usr/local/bin',
  requiredSpaceMB: 500,
);

print('可以继续: ${results.canProceed}');
print('错误数: ${results.errors.length}');
print('警告数: ${results.warnings.length}');

// 显示检查结果
for (final result in results.results) {
  final icon = result.success ? '✓' : '✗';
  print('$icon ${result.message}');
  if (result.details != null) {
    print('  ${result.details}');
  }
}
```

### 回滚管理

```dart
import 'package:my_flutter_app/services/installer/rollback_manager.dart';

final rollbackManager = RollbackManager();
await rollbackManager.initialize();

// 创建回滚点
final rollbackPoint = await rollbackManager.createRollbackPoint(
  description: '安装 NVM 前的状态',
  state: {'manager': 'nvm', 'version': '0.39.0'},
  pathsToBackup: ['/usr/local/nvm'],
);

print('回滚点已创建: ${rollbackPoint.id}');

// 执行安装...
try {
  // 安装代码
} catch (e) {
  // 失败时回滚
  await rollbackManager.rollback(
    rollbackPoint.id,
    onLog: (msg) => print(msg),
  );
}

// 查看所有回滚点
final points = rollbackManager.getRollbackPoints();
for (final point in points) {
  print('${point.timestamp}: ${point.description}');
}

// 清理旧回滚点（保留最新 10 个）
await rollbackManager.cleanOldRollbackPoints(keepCount: 10);
```

### 智能下载

```dart
import 'package:my_flutter_app/services/installer/smart_downloader.dart';

final downloader = SmartDownloader();

// 配置下载
final config = DownloadConfig(
  url: 'https://github.com/example/file.zip',
  savePath: '/tmp/file.zip',
  checksum: 'abc123...',
  checksumType: 'sha256',
  maxRetries: 5,
  timeout: Duration(minutes: 10),
  useCache: true,
);

// 下载文件
final result = await downloader.download(
  config,
  onProgress: (received, total) {
    final percent = (received / total * 100).toStringAsFixed(1);
    print('下载进度: $percent%');
  },
  onLog: (msg) => print(msg),
);

if (result.success) {
  print('下载成功: ${result.filePath}');
  print('文件大小: ${result.fileSize} 字节');
  print('来自缓存: ${result.fromCache}');
} else {
  print('下载失败: ${result.error}');
}

// 清理缓存
await downloader.clearCache();
```

## 支持的版本管理工具

### Windows
- ✅ **NVM for Windows** - 最流行的 Windows Node 版本管理器
- ✅ **fnm** - 快速的跨平台版本管理器
- ✅ **Volta** - JavaScript 工具链管理器
- ✅ **nvs** - Node 版本切换器

### macOS
- ✅ **nvm** - 最流行的 Node 版本管理器
- ✅ **fnm** - 快速的版本管理器
- ✅ **Volta** - JavaScript 工具链管理器
- ✅ **n** - 简单的交互式管理器
- ✅ **nodenv** - 类似 rbenv 的管理器
- ✅ **asdf** - 通用版本管理器

### Linux
- ✅ **nvm** - 最流行的 Node 版本管理器
- ✅ **fnm** - 快速的版本管理器
- ✅ **Volta** - JavaScript 工具链管理器
- ✅ **n** - 简单的交互式管理器
- ✅ **nodenv** - 类似 rbenv 的管理器
- ✅ **asdf** - 通用版本管理器

## 安装流程

1. **系统检测** (10%)
   - 检测操作系统、架构、版本
   - 检查管理员权限
   - 识别可用的包管理器

2. **预检查** (20%)
   - 验证磁盘空间
   - 测试网络连接
   - 检查写入权限
   - 验证系统兼容性
   - 检查依赖项

3. **准备安装** (30%)
   - 创建回滚点
   - 备份相关文件/目录
   - 准备安装路径

4. **执行安装** (40-70%)
   - 根据系统选择最佳安装策略
   - 自动处理依赖
   - 配置环境变量
   - 处理权限问题

5. **验证安装** (80%)
   - 验证工具可执行
   - 检查版本信息
   - 确认配置正确

6. **完成** (100%)
   - 清理临时文件
   - 记录安装日志
   - 通知用户结果

## 错误处理

系统会自动处理以下错误场景：

1. **网络错误**
   - 自动重试（最多 3 次）
   - 支持代理配置
   - 断点续传

2. **权限错误**
   - Windows: 提示以管理员身份运行
   - Unix: 提示使用 sudo
   - 自动请求权限提升

3. **磁盘空间不足**
   - 预检查阶段拦截
   - 提供清理建议

4. **安装失败**
   - 自动回滚到安装前状态
   - 保留详细错误日志
   - 提供手动安装指南

## 配置

### 环境变量支持

系统会自动检测和使用以下环境变量：

- `HTTP_PROXY` / `http_proxy` - HTTP 代理
- `HTTPS_PROXY` / `https_proxy` - HTTPS 代理
- `NO_PROXY` / `no_proxy` - 不使用代理的域名
- `HOME` / `USERPROFILE` - 用户主目录

### 缓存配置

默认缓存位置：`~/.node_manager_cache/`

可以通过构造函数自定义：

```dart
final downloader = SmartDownloader(
  cacheDir: '/custom/cache/path',
);
```

### 备份配置

默认备份位置：`~/.node_manager_backup/`

可以通过构造函数自定义：

```dart
final rollbackManager = RollbackManager(
  backupDir: '/custom/backup/path',
);
```

## 性能优化

1. **并发下载** - 使用 Dio 的并发特性
2. **缓存机制** - 避免重复下载
3. **增量备份** - 只备份必要的文件
4. **异步操作** - 不阻塞 UI 线程

## 安全考虑

1. **文件校验** - SHA256/MD5 校验和验证
2. **HTTPS** - 所有下载使用安全连接
3. **权限检查** - 安装前验证权限
4. **沙箱隔离** - 回滚点独立存储

## 故障排查

### 安装失败

1. 检查网络连接
2. 确认有足够的磁盘空间
3. 验证用户权限
4. 查看详细日志

### 代理问题

```bash
# 设置代理
export HTTP_PROXY=http://proxy.example.com:8080
export HTTPS_PROXY=http://proxy.example.com:8080
```

### 权限问题

Windows:
```powershell
# 以管理员身份运行应用
```

Unix:
```bash
# 使用 sudo 或修改目录权限
sudo chown -R $USER /usr/local/bin
```

## 依赖

```yaml
dependencies:
  dio: ^5.7.0          # HTTP 客户端
  crypto: ^3.0.3       # 加密和校验
  path: ^1.9.0         # 路径处理
  archive: ^3.6.1      # 压缩文件处理
```

## 许可证

本项目遵循 MIT 许可证。

## 贡献

欢迎提交 Issue 和 Pull Request！

## 更新日志

### v1.0.0 (2024-11-24)
- ✅ 初始版本发布
- ✅ 支持 8 种 Node 版本管理工具
- ✅ 跨平台支持（Windows/macOS/Linux）
- ✅ 完整的预检查机制
- ✅ 智能下载和缓存
- ✅ 自动回滚功能
- ✅ 详细的进度跟踪和日志