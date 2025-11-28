# 依赖管理功能 / Dependency Management Feature

## 概述 / Overview

在后台管理系统中为每个项目添加了"依赖管理"按钮，点击后可以查看和管理项目的依赖。

A "Manage Dependencies" button has been added to each project in the backend management system, which opens a dependency management page for that project.

## 修改内容 / Changes Made

### 1. 国际化翻译 / Internationalization

添加了依赖管理相关的翻译键：

- `app_zh.arb` - 简体中文
- `app_en.arb` - 英文  
- `app_zh_Hant.arb` - 繁体中文

新增键值：
- `manageDependencies`: "依赖管理" / "Manage Dependencies" / "依賴管理"
- `dependencyManagement`: "依赖管理" / "Dependency Management" / "依賴管理"

### 2. 项目详情页面 / Project Detail Screen

**文件**: `lib/screens/project_detail_screen.dart`

#### 修改内容：

1. **添加新的操作类型**：
   ```dart
   enum _ActionType {
     start,
     build,
     preview,
     deploy,
     publish,
     test,
     dependencies,  // 新增
   }
   ```

2. **为所有项目类型添加依赖管理按钮**：
   - Web App / Mobile App / Desktop App
   - Backend App
   - Component Library / Utility Library / Framework Library / Node Library
   - CLI Tool
   - Monorepo
   - Unknown

   每个项目类型的操作列表都添加了：
   ```dart
   _ProjectAction(_ActionType.dependencies, l10n.manageDependencies, Bootstrap.box, Colors.indigo)
   ```

3. **处理依赖管理操作**：
   ```dart
   case _ActionType.dependencies:
     appProvider.setCurrentRoute('/project/${project.id}/dependencies');
     break;
   ```

### 3. 依赖管理页面 / Dependency Management Screen

**新文件**: `lib/screens/dependency_management_screen.dart`

创建了一个全新的依赖管理页面，包含：

#### 功能特性：

1. **页面头部**：
   - 返回按钮
   - 图标（📦）
   - 页面标题
   - 项目名称

2. **功能介绍卡片**：
   - 中英文双语介绍
   - 渐变背景设计

3. **功能列表展示**：
   - 📋 查看依赖列表 / View Dependencies
   - ➕ 添加新依赖 / Add Dependencies
   - ⬆️ 升级依赖 / Upgrade Dependencies
   - 🗑️ 删除依赖 / Remove Dependencies
   - ⚙️ .npmrc 配置 / .npmrc Configuration
   - 🌐 源管理 / Registry Management

4. **开发中提示**：
   - 黄色提示卡片
   - 说明功能正在开发中

### 4. 主应用路由 / Main Application Routing

**文件**: `lib/main.dart`

1. **添加导入**：
   ```dart
   import 'screens/dependency_management_screen.dart';
   ```

2. **添加路由处理**：
   ```dart
   if (action == 'dependencies') {
     screen = DependencyManagementScreen(projectId: projectId);
   }
   ```

## 使用方法 / Usage

### 访问依赖管理页面 / Accessing the Page

1. 进入任意项目的详情页面
2. 在"项目操作"（Project Actions）区域找到"📦 依赖管理"按钮
3. 点击按钮进入依赖管理页面

### 路由格式 / Route Format

```
/project/{projectId}/dependencies
```

例如：`/project/abc123/dependencies`

## 界面展示 / UI Features

### 设计元素：

- **主题色**: Indigo（靛蓝色）
- **图标**: 📦 Box icon (Bootstrap.box)
- **卡片布局**: 白色背景，圆角，边框
- **渐变效果**: Indigo to Blue gradient
- **响应式**: 适配不同屏幕尺寸

### 功能卡片：

每个功能都有：
- 彩色图标
- 中英文标题
- 中英文描述
- 圆角卡片设计

## 后续开发 / Future Development

当前页面是一个占位页面，展示了依赖管理功能的介绍。

后续可以在此基础上实现：

1. **实际功能集成**：
   - 读取 package.json / pubspec.yaml
   - 调用包管理器 API（npm, yarn, pnpm）
   - 实时显示依赖列表

2. **依赖操作**：
   - 添加依赖对话框
   - 升级依赖确认
   - 删除依赖警告

3. **.npmrc 配置编辑器**：
   - 可视化配置界面
   - 源地址快速切换
   - Scope 映射管理

4. **依赖分析**：
   - 依赖树可视化
   - 版本冲突检测
   - 安全漏洞扫描

## 文件清单 / File List

### 修改的文件 / Modified Files

1. `lib/l10n/app_zh.arb` - 简体中文翻译
2. `lib/l10n/app_en.arb` - 英文翻译  
3. `lib/l10n/app_zh_Hant.arb` - 繁体中文翻译
4. `lib/screens/project_detail_screen.dart` - 项目详情页面
5. `lib/main.dart` - 主应用路由

### 新增的文件 / New Files

1. `lib/screens/dependency_management_screen.dart` - 依赖管理页面

## 技术栈 / Tech Stack

- **Flutter** - UI framework
- **Provider** - State management
- **icons_plus** - Icon library (Bootstrap icons)
- **国际化** - flutter_localizations

## 测试建议 / Testing Suggestions

1. 测试不同项目类型是否都显示依赖管理按钮
2. 测试按钮点击后是否正确跳转
3. 测试返回按钮功能
4. 测试不同语言环境下的文本显示
5. 测试页面在不同窗口大小下的布局

## 兼容性 / Compatibility

- ✅ Windows
- ✅ macOS  
- ✅ Linux
- ✅ 简体中文
- ✅ 英文
- ✅ 繁体中文
