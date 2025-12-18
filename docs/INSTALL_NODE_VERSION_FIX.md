# 安装 Node 版本功能修复

## 问题描述

用户反馈两个问题：
1. **安装日志不完整** - 看不到真实的安装进度和日志
2. **安装后版本列表未更新** - 安装完成后返回主页面，已安装版本列表中看不到新安装的版本

## 问题分析

### 问题 1: 安装日志不完整

**原因**: 之前使用 `Process.run()` 等待进程完成后才返回，无法实时读取输出。

```dart
// ❌ 旧代码 - 无法实时输出
final result = await Process.run('nvm', ['install', version], runInShell: true);
onLog(result.stdout.toString()); // 只能在完成后一次性输出
```

**解决方案**: 改用 `Process.start()` 实时读取 stdout 和 stderr。

```dart
// ✅ 新代码 - 实时输出
final process = await Process.start(command, arguments, runInShell: true);

// 实时读取 stdout
process.stdout.transform(utf8.decoder).listen((data) {
  for (final line in data.split('\n')) {
    if (line.trim().isNotEmpty) {
      onLog(line.trim());
    }
  }
});

// 实时读取 stderr
process.stderr.transform(utf8.decoder).listen((data) {
  for (final line in data.split('\n')) {
    if (line.trim().isNotEmpty) {
      onLog('⚠️ ${line.trim()}');
    }
  }
});

// 等待进程完成
final exitCode = await process.exitCode;
```

### 问题 2: 安装后版本列表未更新

**原因**: 多个时序问题导致刷新不生效：

1. **安装完成后立即关闭对话框** - 版本管理器可能还没完全注册新版本
2. **刷新时机太早** - 主页面接收到返回值后立即刷新，但系统可能还在处理
3. **没有等待刷新完成** - 异步刷新没有正确等待

**解决方案**: 

#### 1. 安装对话框 - 等待版本管理器注册

```dart
if (success) {
  addLog('等待版本管理器注册新版本...');
  await Future.delayed(const Duration(seconds: 2)); // 等待注册完成
  addLog('✅ 安装完成！');
  
  await Future.delayed(const Duration(seconds: 1)); // 让用户看到完成消息
  
  if (context.mounted) {
    Navigator.pop(dialogContext, true); // 返回 true 表示安装成功
  }
}
```

#### 2. 主页面 - 显示刷新进度并等待完成

```dart
if (result == true && context.mounted) {
  // 显示刷新对话框
  unawaited(
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('正在刷新版本列表...'),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  
  // 等待对话框显示
  await Future.delayed(const Duration(milliseconds: 100));
  
  // 刷新环境信息（等待完成）
  await ref.read(nodeEnvironmentProvider.notifier).refresh();
  
  if (context.mounted) {
    // 关闭刷新对话框
    Navigator.of(context, rootNavigator: true).pop();
    
    // 显示成功提示
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ 版本列表已更新'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
```

#### 3. Provider - 添加 mounted 检查

```dart
Future<void> refresh() async {
  state = const AsyncValue.loading();
  try {
    final env = await _systemService.getNodeEnvironment();
    if (mounted) {  // 确保 notifier 还在使用中
      state = AsyncValue.data(env);
    }
  } catch (e, st) {
    if (mounted) {
      state = AsyncValue.error(e, st);
    }
  }
}
```

## 修改的文件

### 1. `lib/data/services/node_migration_service.dart`

**修改**: `installNodeVersion` 方法

- 从 `Process.run()` 改为 `Process.start()`
- 添加实时 stdout/stderr 监听
- 添加详细的日志输出

### 2. `lib/presentation/pages/node/install_node_version_dialog.dart`

**修改**: `_showInstallProgressDialog` 方法

- 安装成功后等待 2 秒让版本管理器注册
- 添加"等待版本管理器注册新版本..."日志
- 添加"✅ 安装完成！"日志
- 等待 1 秒让用户看到完成消息

### 3. `lib/presentation/pages/node/node_page.dart`

**修改**: `_showInstallNodeVersionDialog` 方法

- 显示刷新进度对话框
- 使用 `await` 等待 `refresh()` 完成
- 刷新完成后关闭对话框并显示成功提示

### 4. `lib/providers/node_providers.dart`

**修改**: `NodeEnvironmentNotifier.refresh` 方法

- 添加 `mounted` 检查，避免在 notifier 销毁后更新状态

## 测试流程

1. **打开 Node 管理页面**
2. **点击"安装新版本"按钮**
3. **搜索并选择一个版本**
4. **点击"安装"按钮**
5. **验证日志输出**:
   - ✅ 应该看到实时的安装进度
   - ✅ 应该看到详细的命令输出
   - ✅ 应该看到"等待版本管理器注册新版本..."
   - ✅ 应该看到"✅ 安装完成！"
6. **等待对话框自动关闭**
7. **验证刷新过程**:
   - ✅ 应该看到"正在刷新版本列表..."对话框
   - ✅ 对话框应该在刷新完成后自动关闭
   - ✅ 应该看到"✅ 版本列表已更新"提示
8. **验证版本列表**:
   - ✅ 新安装的版本应该出现在"已安装版本"列表中
   - ✅ 版本卡片应该正确显示版本号和状态

## 技术要点

### 1. 实时进程输出

使用 `Process.start()` 而不是 `Process.run()`:

```dart
// Process.run() - 等待完成后一次性返回
final result = await Process.run('command', ['args']);

// Process.start() - 可以实时读取输出
final process = await Process.start('command', ['args']);
process.stdout.transform(utf8.decoder).listen((data) {
  // 实时处理输出
});
```

### 2. 异步对话框管理

使用 `unawaited()` 启动对话框，然后等待一下确保对话框已显示：

```dart
unawaited(showDialog(...));
await Future.delayed(const Duration(milliseconds: 100));
// 现在可以安全地执行异步操作
```

### 3. 状态刷新时序

确保按正确顺序执行：
1. 安装完成 → 等待版本管理器注册
2. 关闭安装对话框 → 返回 true
3. 显示刷新对话框
4. 执行刷新 → **等待完成**
5. 关闭刷新对话框
6. 显示成功提示

### 4. Provider 生命周期

在 StateNotifier 中使用 `mounted` 检查：

```dart
if (mounted) {
  state = AsyncValue.data(env);
}
```

## 预期效果

### 安装过程

```
[14:23:45] 开始安装 Node.js v20.10.0...
[14:23:45] 执行命令: nvm install 20.10.0
[14:23:46] Downloading node.js version 20.10.0 (64-bit)...
[14:23:50] Creating C:\Users\...\nvm\v20.10.0
[14:23:51] Extracting...
[14:23:55] Installation complete.
[14:23:55] ✅ Node.js v20.10.0 安装成功
[14:23:55] 等待版本管理器注册新版本...
[14:23:57] ✅ 安装完成！
```

### 刷新过程

1. 安装对话框自动关闭
2. 显示"正在刷新版本列表..."对话框
3. 后台执行刷新（约 1-2 秒）
4. 刷新对话框自动关闭
5. 显示"✅ 版本列表已更新"
6. 新版本出现在列表中

## 总结

通过以下改进解决了问题：

1. ✅ **实时日志输出** - 使用 `Process.start()` 实时读取进程输出
2. ✅ **等待版本注册** - 安装完成后等待 2 秒让版本管理器注册
3. ✅ **显示刷新进度** - 用对话框告知用户正在刷新
4. ✅ **等待刷新完成** - 使用 `await` 确保刷新完成后再继续
5. ✅ **生命周期管理** - 添加 `mounted` 检查避免状态更新错误

现在用户可以：
- 看到完整的安装进度和日志
- 安装完成后立即在列表中看到新版本
- 了解整个过程的每个步骤
