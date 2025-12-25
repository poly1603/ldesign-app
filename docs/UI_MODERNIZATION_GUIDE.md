# UI 现代化指南

## 概述

本指南介绍如何使用 Lucide Icons 和现代化设计系统来美化 Flutter Toolbox 应用。

## Lucide Icons

### 安装

已添加到 `pubspec.yaml`:
```yaml
dependencies:
  lucide_icons: ^0.257.0
```

### 使用方法

```dart
import 'package:lucide_icons/lucide_icons.dart';

// 基本使用
Icon(LucideIcons.home)

// 带大小和颜色
Icon(
  LucideIcons.settings,
  size: 24,
  color: Colors.blue,
)
```

### 常用图标映射

#### 导航图标
- `Icons.home` → `LucideIcons.home`
- `Icons.folder` → `LucideIcons.folder`
- `Icons.settings` → `LucideIcons.settings`
- `Icons.search` → `LucideIcons.search`
- `Icons.menu` → `LucideIcons.menu`

#### 操作图标
- `Icons.add` → `LucideIcons.plus`
- `Icons.edit` → `LucideIcons.pencil`
- `Icons.delete` → `LucideIcons.trash2`
- `Icons.save` → `LucideIcons.save`
- `Icons.refresh` → `LucideIcons.refreshCw`
- `Icons.copy` → `LucideIcons.copy`
- `Icons.download` → `LucideIcons.download`
- `Icons.upload` → `LucideIcons.upload`

#### 状态图标
- `Icons.check` → `LucideIcons.check`
- `Icons.close` → `LucideIcons.x`
- `Icons.error` → `LucideIcons.alertCircle`
- `Icons.warning` → `LucideIcons.alertTriangle`
- `Icons.info` → `LucideIcons.info`
- `Icons.check_circle` → `LucideIcons.checkCircle`

#### 文件和文档
- `Icons.description` → `LucideIcons.fileText`
- `Icons.folder_open` → `LucideIcons.folderOpen`
- `Icons.insert_drive_file` → `LucideIcons.file`
- `Icons.code` → `LucideIcons.code`

#### 开发工具
- `Icons.terminal` → `LucideIcons.terminal`
- `Icons.bug_report` → `LucideIcons.bug`
- `Icons.build` → `LucideIcons.wrench`
- `Icons.package` → `LucideIcons.package`
- `Icons.git` → `LucideIcons.gitBranch`

#### 网络和云
- `Icons.cloud` → `LucideIcons.cloud`
- `Icons.download` → `LucideIcons.cloudDownload`
- `Icons.upload` → `LucideIcons.cloudUpload`
- `Icons.link` → `LucideIcons.link`

## 设计系统

### 颜色方案

#### 主色调
- Primary: `#6366F1` (Indigo)
- Secondary: `#8B5CF6` (Purple)
- Accent: `#06B6D4` (Cyan)

#### 语义颜色
- Success: `#10B981` (Green)
- Warning: `#F59E0B` (Amber)
- Error: `#EF4444` (Red)
- Info: `#3B82F6` (Blue)

### 圆角规范

- 小组件: `8px`
- 卡片/按钮: `12px`
- 大卡片: `16px`
- 对话框/底部表单: `20px`

### 间距规范

- 极小: `4px`
- 小: `8px`
- 中: `16px`
- 大: `24px`
- 极大: `32px`

### 阴影规范

- 无阴影: `elevation: 0`
- 轻微阴影: `elevation: 1-2`
- 中等阴影: `elevation: 4-6`
- 强阴影: `elevation: 8-12`

## 组件样式指南

### Card 组件

```dart
Card(
  elevation: 0,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
    side: BorderSide(
      color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
    ),
  ),
  child: Padding(
    padding: const EdgeInsets.all(20),
    child: // 内容
  ),
)
```

### 按钮样式

```dart
// 主要按钮
FilledButton.icon(
  onPressed: () {},
  icon: Icon(LucideIcons.plus),
  label: Text('添加'),
)

// 次要按钮
OutlinedButton.icon(
  onPressed: () {},
  icon: Icon(LucideIcons.edit),
  label: Text('编辑'),
)

// 文本按钮
TextButton.icon(
  onPressed: () {},
  icon: Icon(LucideIcons.x),
  label: Text('取消'),
)
```

### 输入框样式

```dart
TextField(
  decoration: InputDecoration(
    labelText: '标签',
    hintText: '提示文本',
    prefixIcon: Icon(LucideIcons.search),
    suffixIcon: IconButton(
      icon: Icon(LucideIcons.x),
      onPressed: () {},
    ),
  ),
)
```

### 列表项样式

```dart
ListTile(
  leading: Container(
    width: 48,
    height: 48,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Icon(
      LucideIcons.folder,
      color: Theme.of(context).colorScheme.onPrimaryContainer,
    ),
  ),
  title: Text('标题'),
  subtitle: Text('副标题'),
  trailing: Icon(LucideIcons.chevronRight),
)
```

### 状态指示器

```dart
// 成功状态
Container(
  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  decoration: BoxDecoration(
    color: Colors.green.withValues(alpha: 0.1),
    borderRadius: BorderRadius.circular(8),
  ),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(LucideIcons.checkCircle, size: 16, color: Colors.green),
      SizedBox(width: 6),
      Text('成功', style: TextStyle(color: Colors.green)),
    ],
  ),
)

// 错误状态
Container(
  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  decoration: BoxDecoration(
    color: Colors.red.withValues(alpha: 0.1),
    borderRadius: BorderRadius.circular(8),
  ),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(LucideIcons.alertCircle, size: 16, color: Colors.red),
      SizedBox(width: 6),
      Text('错误', style: TextStyle(color: Colors.red)),
    ],
  ),
)
```

## 页面布局模式

### 列表页面

```dart
Scaffold(
  appBar: AppBar(
    title: Text('标题'),
    actions: [
      IconButton(
        icon: Icon(LucideIcons.search),
        onPressed: () {},
      ),
      IconButton(
        icon: Icon(LucideIcons.filter),
        onPressed: () {},
      ),
    ],
  ),
  body: ListView.builder(
    padding: EdgeInsets.all(16),
    itemBuilder: (context, index) => Card(
      // 卡片内容
    ),
  ),
  floatingActionButton: FloatingActionButton.extended(
    onPressed: () {},
    icon: Icon(LucideIcons.plus),
    label: Text('添加'),
  ),
)
```

### 详情页面

```dart
Scaffold(
  appBar: AppBar(
    leading: IconButton(
      icon: Icon(LucideIcons.arrowLeft),
      onPressed: () => Navigator.pop(context),
    ),
    title: Text('详情'),
    actions: [
      IconButton(
        icon: Icon(LucideIcons.moreVertical),
        onPressed: () {},
      ),
    ],
  ),
  body: SingleChildScrollView(
    padding: EdgeInsets.all(24),
    child: Column(
      children: [
        // 头部信息卡片
        Card(/* ... */),
        SizedBox(height: 24),
        // 详细信息
        // ...
      ],
    ),
  ),
)
```

## 动画和过渡

### 页面过渡

```dart
Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => NextPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
  ),
)
```

### 组件动画

```dart
AnimatedContainer(
  duration: Duration(milliseconds: 300),
  curve: Curves.easeInOut,
  // 属性
)

AnimatedOpacity(
  duration: Duration(milliseconds: 200),
  opacity: isVisible ? 1.0 : 0.0,
  child: // 子组件
)
```

## 响应式设计

### 断点

- 手机: < 600px
- 平板: 600px - 1024px
- 桌面: > 1024px

### 自适应布局

```dart
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth < 600) {
      return MobileLayout();
    } else if (constraints.maxWidth < 1024) {
      return TabletLayout();
    } else {
      return DesktopLayout();
    }
  },
)
```

## 最佳实践

1. **一致性**: 在整个应用中使用相同的设计模式
2. **可访问性**: 确保足够的对比度和触摸目标大小
3. **性能**: 避免过度使用阴影和复杂动画
4. **反馈**: 为所有交互提供视觉反馈
5. **加载状态**: 始终显示加载指示器
6. **错误处理**: 提供清晰的错误消息和恢复选项

## 迁移清单

- [ ] 更新所有 Material Icons 为 Lucide Icons
- [ ] 应用新的颜色方案
- [ ] 统一圆角和间距
- [ ] 更新卡片样式
- [ ] 更新按钮样式
- [ ] 更新输入框样式
- [ ] 添加适当的动画
- [ ] 优化响应式布局
- [ ] 测试暗色模式
- [ ] 测试可访问性
