# 黑屏问题修复说明

## 问题描述

在安装 yarn 后，应用出现黑屏，控制台显示大量 `_InactiveElements._unmount` 相关的错误。

## 错误原因（已修复2次）

### 第一次错误：ProviderScope.containerOf
在 `ConsumerWidget` 中错误地使用了 `ProviderScope.containerOf(context)` 来获取 `WidgetRef`。

### 第二次错误：Navigator._debugLocked
在 Navigator 正在执行动画时尝试 pop 对话框，导致断言失败。

### 错误代码示例：
```dart
class NodePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ...
  }

  Future<void> _handlePackageManager(BuildContext context, String name, bool isInstalled) async {
    // ❌ 错误：在异步回调中使用 ProviderScope.containerOf
    final ref = ProviderScope.containerOf(context);
    ref.read(nodeEnvironmentProvider.notifier).refresh();
  }
}
```

### 问题分析：

1. **Context 失效**：在异步操作（如 `showDialog`、`Future` 回调）中，原始的 `context` 可能已经失效
2. **ProviderScope.containerOf 不安全**：这个方法在 context 失效时会抛出异常
3. **ConsumerWidget 已有 ref**：`ConsumerWidget` 的 `build` 方法已经提供了 `WidgetRef ref` 参数

## 解决方案

将 `WidgetRef ref` 作为参数传递给所有需要访问 Provider 的方法。

### 修复后的代码：

```dart
class NodePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _buildInstalledState(context, ref, l10n, env, enableAnimations);
  }

  Widget _buildInstalledState(
    BuildContext context,
    WidgetRef ref,  // ✅ 传递 ref
    AppLocalizations l10n,
    NodeEnvironment env,
    bool enableAnimations,
  ) {
    return Column(
      children: [
        _buildPackageManagersCard(context, ref, env),  // ✅ 传递 ref
      ],
    );
  }

  Future<void> _handlePackageManager(
    BuildContext context,
    WidgetRef ref,  // ✅ 接收 ref 参数
    String name,
    bool isInstalled,
  ) async {
    // ...
    if (success) {
      // ✅ 直接使用传入的 ref
      ref.read(nodeEnvironmentProvider.notifier).refresh();
    }
  }
}
```

## 修复的文件

**文件：** `tools/app/lib/presentation/pages/node/node_page.dart`

### 修改的方法签名：

1. `_buildInstalledState` - 添加 `WidgetRef ref` 参数
2. `_buildActiveVersionCard` - 添加 `WidgetRef ref` 参数
3. `_buildVersionsList` - 添加 `WidgetRef ref` 参数
4. `_buildVersionCard` - 添加 `WidgetRef ref` 参数
5. `_switchNodeVersion` - 添加 `WidgetRef ref` 参数
6. `_buildPackageManagersCard` - 添加 `WidgetRef ref` 参数
7. `_buildPackageManagerItem` - 添加 `WidgetRef ref` 参数
8. `_handlePackageManager` - 添加 `WidgetRef ref` 参数
9. `_buildGlobalPackagesCard` - 添加 `WidgetRef ref` 参数
10. `_uninstallGlobalPackage` - 添加 `WidgetRef ref` 参数

### 删除的代码：

所有 `final ref = ProviderScope.containerOf(context);` 语句都已删除。

## 最佳实践

### ✅ 正确做法：

1. **在 ConsumerWidget 中**：
   ```dart
   class MyPage extends ConsumerWidget {
     @override
     Widget build(BuildContext context, WidgetRef ref) {
       // 直接使用 ref
       final data = ref.watch(myProvider);
       return MyWidget(ref: ref);  // 传递给子组件
     }
   }
   ```

2. **在异步方法中**：
   ```dart
   Future<void> myAsyncMethod(BuildContext context, WidgetRef ref) async {
     // 使用传入的 ref，不要从 context 获取
     await someAsyncOperation();
     if (context.mounted) {
       ref.read(myProvider.notifier).update();
     }
   }
   ```

3. **显示加载对话框的正确方式**：
   ```dart
   Future<void> myAsyncMethod(BuildContext context, WidgetRef ref) async {
     // 使用 unawaited 显示对话框
     unawaited(
       showDialog(
         context: context,
         barrierDismissible: false,
         builder: (context) => LoadingDialog(),
       ),
     );
     
     // 等待动画完成
     await Future.delayed(const Duration(milliseconds: 100));
     
     try {
       await someAsyncOperation();
       
       if (context.mounted) {
         // 使用 rootNavigator 关闭对话框
         Navigator.of(context, rootNavigator: true).pop();
       }
     } catch (e) {
       if (context.mounted) {
         Navigator.of(context, rootNavigator: true).pop();
       }
     }
   }
   ```

4. **在 StatefulWidget 中**：
   ```dart
   class MyPage extends ConsumerStatefulWidget {
     @override
     ConsumerState<MyPage> createState() => _MyPageState();
   }

   class _MyPageState extends ConsumerState<MyPage> {
     void myMethod() {
       // 使用 ref（ConsumerState 提供）
       ref.read(myProvider.notifier).update();
     }
   }
   ```

### ❌ 错误做法：

1. **不要在异步回调中使用 ProviderScope.containerOf**：
   ```dart
   // ❌ 错误
   Future<void> myMethod(BuildContext context) async {
     await someAsyncOperation();
     final ref = ProviderScope.containerOf(context);  // 可能崩溃
   }
   ```

2. **不要在 dispose 后使用 context**：
   ```dart
   // ❌ 错误
   Future<void> myMethod(BuildContext context) async {
     await Future.delayed(Duration(seconds: 1));
     // context 可能已经失效
     final ref = ProviderScope.containerOf(context);
   }
   ```

3. **不要在 Navigator 动画期间 pop**：
   ```dart
   // ❌ 错误
   showDialog(context: context, builder: ...);  // 没有 await
   
   try {
     await someAsyncOperation();
     Navigator.pop(context);  // 可能在动画期间执行
   }
   ```

4. **不要忘记检查 context.mounted**：
   ```dart
   // ❌ 错误
   Future<void> myMethod(BuildContext context) async {
     await someAsyncOperation();
     Navigator.pop(context);  // context 可能已失效
   }
   
   // ✅ 正确
   Future<void> myMethod(BuildContext context) async {
     await someAsyncOperation();
     if (context.mounted) {
       Navigator.of(context, rootNavigator: true).pop();
     }
   }
   ```

## 第二次修复：Navigator 锁定问题

### 错误信息：
```
'package:flutter/src/widgets/navigator.dart': Failed assertion: line 5574 pos 12: '!_debugLocked': is not true.
#4 NodePage._handlePackageManager
```

### 问题分析：

1. **showDialog 没有 await**：直接调用 `showDialog()` 后立即执行异步操作
2. **Navigator 动画未完成**：在对话框动画还在进行时就尝试 `Navigator.pop()`
3. **时序问题**：异步操作完成太快，Navigator 还在 locked 状态

### 错误代码：
```dart
// ❌ 错误：没有等待对话框显示完成
showDialog(context: context, builder: ...);

try {
  final success = await someAsyncOperation();
  Navigator.pop(context); // 可能在动画期间执行，导致崩溃
}
```

### 修复方案：

使用 `unawaited` + 延迟 + `rootNavigator`：

```dart
// ✅ 正确：使用 unawaited 并等待动画完成
unawaited(
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => LoadingDialog(),
  ),
);

// 等待对话框动画完成
await Future.delayed(const Duration(milliseconds: 100));

try {
  final success = await someAsyncOperation();
  
  if (context.mounted) {
    // 使用 rootNavigator 确保关闭正确的对话框
    Navigator.of(context, rootNavigator: true).pop();
  }
}
```

### 关键改动：

1. **使用 `unawaited`**：明确表示不等待 showDialog 完成
2. **添加延迟**：`await Future.delayed(const Duration(milliseconds: 100))` 确保动画完成
3. **使用 rootNavigator**：`Navigator.of(context, rootNavigator: true).pop()` 确保关闭正确的对话框
4. **添加 import**：`import 'dart:async'` 以使用 `unawaited`

## 验证修复

修复后，应用应该能够：
1. ✅ 正常安装 yarn
2. ✅ 正常更新 pnpm
3. ✅ 正常切换 Node 版本
4. ✅ 正常卸载全局包
5. ✅ 不再出现黑屏
6. ✅ 不再有 `_InactiveElements._unmount` 错误
7. ✅ 不再有 `Navigator._debugLocked` 错误

## 相关资源

- [Riverpod 官方文档 - ConsumerWidget](https://riverpod.dev/docs/concepts/reading#consumerwidget)
- [Flutter 官方文档 - BuildContext](https://api.flutter.dev/flutter/widgets/BuildContext-class.html)
- [Riverpod 最佳实践](https://riverpod.dev/docs/concepts/reading#dont-use-ref-in-async-callbacks)

---

**修复完成！** ✅
