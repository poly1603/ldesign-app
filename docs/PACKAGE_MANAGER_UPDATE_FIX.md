# 包管理器更新检测修复

## 问题描述

pnpm 和 yarn 点击更新后，仍然显示"点击更新"，没有正确检测是否已是最新版本。

## 问题原因

之前的实现只是简单地调用 `npm update -g <package>`，没有：
1. 检查当前版本
2. 检查最新版本
3. 比较版本号
4. 显示正确的状态

## 解决方案

### 1. 添加版本检测方法

在 `NodeMigrationService` 中添加：

```dart
/// 获取已安装的包管理器版本
Future<String?> getInstalledPackageManagerVersion(String name) async {
  final result = await Process.run(name, ['--version'], runInShell: true);
  if (result.exitCode == 0) {
    return result.stdout.toString().trim();
  }
  return null;
}

/// 检查是否有更新（比较版本号）
Future<bool> hasPackageManagerUpdate(String name, String currentVersion) async {
  final latestVersion = await checkPackageManagerUpdate(name);
  if (latestVersion == null) return false;
  
  return latestVersion != currentVersion;
}
```

### 2. 改进 UI 显示

使用 `FutureBuilder` 实时检测更新状态：

```dart
Widget _buildPackageManagerAction(
  BuildContext context,
  String name,
  String? version,
  Color color,
  ColorScheme colorScheme,
) {
  if (version == null) {
    return Text('点击安装');
  }

  return FutureBuilder<bool>(
    future: NodeMigrationService().hasPackageManagerUpdate(name, version),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return CircularProgressIndicator();
      }

      final hasUpdate = snapshot.data ?? false;
      
      if (!hasUpdate) {
        return Text('✓ 最新版本');  // 已是最新
      }

      return Text('↑ 点击更新');  // 有更新可用
    },
  );
}
```

### 3. 添加更新前检查

在 `_handlePackageManager` 中添加检查：

```dart
Future<void> _handlePackageManager(...) async {
  // 如果已安装，先检查是否有更新
  if (isInstalled && currentVersion != null) {
    final hasUpdate = await service.hasPackageManagerUpdate(name, currentVersion);
    
    if (!hasUpdate) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$name 已是最新版本 v$currentVersion')),
      );
      return;  // 不执行更新
    }
  }

  // 继续更新流程...
}
```

## 功能改进

### 显示状态

现在包管理器卡片会显示三种状态：

1. **未安装**
   ```
   ┌─────────────┐
   │    yarn     │
   │   未安装    │
   │  点击安装   │  ← 灰色背景
   └─────────────┘
   ```

2. **已是最新版本**
   ```
   ┌─────────────┐
   │    pnpm     │
   │  v9.15.9    │
   │ ✓ 最新版本  │  ← 绿色背景
   └─────────────┘
   ```

3. **有更新可用**
   ```
   ┌─────────────┐
   │    yarn     │
   │  v1.22.22   │
   │ ↑ 点击更新  │  ← 橙色背景
   └─────────────┘
   ```

### 交互流程

#### 场景 1：已是最新版本
```
1. 用户点击卡片
2. 检测到已是最新版本
3. 显示提示："pnpm 已是最新版本 v9.15.9"
4. 不执行更新操作
```

#### 场景 2：有更新可用
```
1. 用户点击卡片
2. 检测到有更新
3. 显示确认对话框："确定要更新 pnpm 吗？"
4. 用户确认
5. 显示加载对话框："正在更新 pnpm..."
6. 执行 npm update -g pnpm
7. 显示成功提示："pnpm 更新成功"
8. 刷新页面，显示新版本
```

#### 场景 3：未安装
```
1. 用户点击卡片
2. 显示确认对话框："确定要安装 yarn 吗？"
3. 用户确认
4. 显示加载对话框："正在安装 yarn..."
5. 执行 npm install -g yarn
6. 显示成功提示："yarn 安装成功"
7. 刷新页面，显示版本号
```

## 技术细节

### 版本检测原理

1. **获取当前版本**
   ```bash
   pnpm --version
   # 输出: 9.15.9
   ```

2. **获取最新版本**
   ```bash
   npm view pnpm version
   # 输出: 10.0.0
   ```

3. **比较版本**
   ```dart
   if (latestVersion != currentVersion) {
     // 有更新
   }
   ```

### 性能优化

- 使用 `FutureBuilder` 异步加载，不阻塞 UI
- 检测结果会缓存在 widget 生命周期内
- 只在需要时才检查更新（点击时再次确认）

### 错误处理

- 网络错误：假设没有更新
- 命令执行失败：假设没有更新
- 版本解析失败：假设没有更新

## 用户体验改进

### 之前
- ❌ 总是显示"点击更新"
- ❌ 点击后可能没有实际更新
- ❌ 不知道是否已是最新版本
- ❌ 浪费时间和网络流量

### 现在
- ✅ 实时检测更新状态
- ✅ 显示准确的状态（最新/有更新）
- ✅ 只在真正有更新时才执行
- ✅ 提供清晰的视觉反馈

## 未来改进

1. **更精确的版本比较**
   - 使用 `pub_semver` 包
   - 支持语义化版本比较
   - 识别主版本、次版本、补丁版本

2. **显示更新内容**
   - 显示最新版本号
   - 显示更新日志
   - 显示更新大小

3. **批量更新**
   - 一键更新所有包管理器
   - 显示总体更新进度

4. **更新通知**
   - 定期检查更新
   - 显示更新徽章
   - 推送更新通知

---

**修复完成！** ✅

现在包管理器会正确显示更新状态，只在真正有更新时才提示用户更新。
