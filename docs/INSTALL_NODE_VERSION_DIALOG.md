# 安装 Node 版本对话框功能说明

## 功能概述

提供一个强大的 Node.js 版本安装对话框，支持搜索、查看详细信息、实时安装进度和日志显示。

## 主要功能

### 1. 版本搜索

**实时搜索**：输入关键词即时过滤版本列表
- 支持版本号搜索：`20.19`, `18.17`
- 支持 LTS 名称搜索：`Iron`, `Hydrogen`
- 防抖处理：300ms 延迟，避免频繁过滤

**搜索示例**：
```
输入 "20" → 显示所有 20.x.x 版本
输入 "lts" → 显示所有 LTS 版本
输入 "Iron" → 显示 Iron LTS 版本
```

### 2. 详细版本信息

每个版本显示完整信息：

```
┌────────────────────────────────────────────────────────────┐
│ v20.19.5  [LTS] [Iron] [已安装]                            │
│ 📅 2024-12-18  📦 npm 10.8.2  💻 V8 11.3.244.8            │
│                                              [安装] ───────│
└────────────────────────────────────────────────────────────┘
```

**显示内容**：
- ✅ 版本号（v20.19.5）
- ✅ 标签（LTS、Security、Current）
- ✅ LTS 代号（Iron、Hydrogen 等）
- ✅ 发布日期
- ✅ npm 版本
- ✅ V8 引擎版本
- ✅ 安装状态

### 3. 版本标签

**LTS（长期支持版）**：
- 绿色标签
- 推荐用于生产环境
- 代号：Iron, Hydrogen, Gallium 等

**Security（安全更新）**：
- 红色标签
- 包含安全修复
- 建议及时更新

**Current（当前版本）**：
- 灰色标签
- 最新功能
- 适合开发测试

**已安装**：
- 蓝色标签 + 对勾图标
- 表示已安装此版本

### 4. 实时安装进度

点击"安装"按钮后，显示详细的安装进度对话框：

```
┌─────────────────────────────────────────┐
│ 📥 安装 Node.js v20.19.5          ⟳   │
├─────────────────────────────────────────┤
│ [14:30:15] 安装 Node 版本...          │
│ [14:30:16] 执行: nvm install 20.19.5  │
│ [14:30:17] Downloading...             │
│ [14:30:20] Installing...              │
│ [14:30:25] ✅ 安装成功                │
└─────────────────────────────────────────┘
```

**特性**：
- 实时日志输出
- 彩色日志（成功/错误/警告）
- 进度指示器
- 自动关闭（成功后 1 秒）

### 5. 智能状态管理

**已安装版本**：
- 显示"已安装"标签
- 禁用安装按钮
- 避免重复安装

**安装成功后**：
- 自动更新列表状态
- 标记为"已安装"
- 关闭对话框后刷新主页面

## UI 设计

### 对话框布局

```
┌──────────────────────────────────────────────────────────┐
│ ➕ 安装新版本                                      ✕    │
├──────────────────────────────────────────────────────────┤
│ 🔍 [搜索版本号或 LTS 名称...]                    [×]    │
├──────────────────────────────────────────────────────────┤
│                                                          │
│  v20.19.5  [LTS] [Iron]                    [安装] ─────│
│  📅 2024-12-18  📦 npm 10.8.2  💻 V8 11.3.244.8        │
│  ─────────────────────────────────────────────────────  │
│  v20.19.4  [LTS] [Iron] [已安装]           [已安装] ───│
│  📅 2024-12-10  📦 npm 10.8.2  💻 V8 11.3.244.8        │
│  ─────────────────────────────────────────────────────  │
│  v18.17.0  [LTS] [Hydrogen]                [安装] ─────│
│  📅 2023-08-08  📦 npm 9.6.7   💻 V8 10.2.154.26       │
│  ─────────────────────────────────────────────────────  │
│  ...                                                     │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

### 安装进度对话框

```
┌─────────────────────────────────────────┐
│ 📥 安装 Node.js v20.19.5          ⟳   │
├─────────────────────────────────────────┤
│ ┌─────────────────────────────────────┐ │
│ │ [14:30:15] 安装 Node 版本...       │ │
│ │ [14:30:16] 执行: nvm install...    │ │
│ │ [14:30:17] Downloading...          │ │  ← 黑色终端
│ │ [14:30:20] Installing...           │ │    样式
│ │ [14:30:25] ✅ 安装成功             │ │
│ └─────────────────────────────────────┘ │
│                                         │
│                        [关闭] ──────────│  ← 失败时显示
└─────────────────────────────────────────┘
```

## 技术实现

### 1. 数据获取

从 Node.js 官方 API 获取版本列表：

```dart
Future<List<dynamic>> fetchAvailableNodeVersions() async {
  final client = HttpClient();
  final request = await client.getUrl(
    Uri.parse('https://nodejs.org/dist/index.json')
  );
  final response = await request.close();
  
  if (response.statusCode == 200) {
    final responseBody = await response.transform(utf8.decoder).join();
    return jsonDecode(responseBody);
  }
  
  return [];
}
```

### 2. 数据模型

```dart
class NodeVersionInfo {
  final String version;        // 版本号
  final DateTime date;         // 发布日期
  final String? npm;           // npm 版本
  final String? v8;            // V8 版本
  final bool lts;              // 是否 LTS
  final String? ltsName;       // LTS 代号
  final bool security;         // 是否安全更新
  
  // 计算属性
  String get displayVersion => 'v$version';
  int get majorVersion => ...;
  bool get isStable => majorVersion % 2 == 0;
  List<String> get tags => [...];
}
```

### 3. 搜索过滤

使用防抖处理，避免频繁过滤：

```dart
Timer? _debounce;

void _onSearchChanged() {
  if (_debounce?.isActive ?? false) _debounce!.cancel();
  _debounce = Timer(const Duration(milliseconds: 300), () {
    _filterVersions(_searchController.text);
  });
}

void _filterVersions(String query) {
  _filteredVersions = _allVersions.where((version) {
    return version.version.contains(query) ||
           version.displayVersion.contains(query) ||
           (version.ltsName?.toLowerCase().contains(query.toLowerCase()) ?? false);
  }).toList();
}
```

### 4. 安装流程

```dart
Future<void> _installVersion(NodeVersionInfo version) async {
  // 1. 显示进度对话框
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => InstallProgressDialog(...),
  );
  
  // 2. 执行安装
  final success = await _service.installNodeVersion(
    currentTool,
    version.version,
    (log) => addLog(log),  // 实时日志回调
  );
  
  // 3. 安装成功后自动关闭
  if (success) {
    await Future.delayed(const Duration(seconds: 1));
    Navigator.pop(context, true);
  }
}
```

### 5. 状态同步

```dart
// 安装完成后
if (result == true) {
  // 更新对话框内的状态
  setState(() {
    // 标记为已安装
  });
  
  // 关闭对话框后刷新主页面
  ref.read(nodeEnvironmentProvider.notifier).refresh();
}
```

## 使用流程

### 完整流程

```
1. 点击"安装新版本"按钮
   ↓
2. 显示版本列表对话框
   ├─ 加载所有可用版本
   ├─ 显示版本详细信息
   └─ 标记已安装版本
   ↓
3. 搜索/浏览版本
   ├─ 输入搜索关键词
   ├─ 实时过滤列表
   └─ 查看版本详情
   ↓
4. 点击"安装"按钮
   ├─ 显示安装进度对话框
   ├─ 实时显示安装日志
   └─ 显示进度指示器
   ↓
5. 安装完成
   ├─ 显示成功消息
   ├─ 1 秒后自动关闭
   └─ 更新列表状态
   ↓
6. 关闭对话框
   ├─ 刷新主页面
   └─ 显示新安装的版本
```

### 搜索示例

**搜索 LTS 版本**：
```
输入: "lts"
结果: 显示所有带 [LTS] 标签的版本
```

**搜索特定版本**：
```
输入: "20.19"
结果: v20.19.5, v20.19.4, v20.19.3...
```

**搜索 LTS 代号**：
```
输入: "Iron"
结果: 显示所有 Iron LTS 版本（Node 20.x）
```

## 版本标签说明

### LTS 版本代号

- **Iron** (v20.x) - 2023-10 至 2026-04
- **Hydrogen** (v18.x) - 2022-10 至 2025-04
- **Gallium** (v16.x) - 2021-10 至 2024-04
- **Fermium** (v14.x) - 2020-10 至 2023-04

### 版本类型

**偶数版本（稳定版）**：
- v20.x, v18.x, v16.x
- 推荐用于生产环境
- 长期支持

**奇数版本（当前版）**：
- v21.x, v19.x, v17.x
- 最新功能
- 短期支持

## 错误处理

### 网络错误

```
┌─────────────────────────────────┐
│ ⚠️ 加载失败                     │
│                                 │
│ 加载失败: SocketException...   │
│                                 │
│          [重试] ────────────────│
└─────────────────────────────────┘
```

### 安装失败

```
[14:30:15] 安装 Node 版本...
[14:30:16] 执行: nvm install 20.19.5
[14:30:17] ❌ 错误: 网络连接失败
[14:30:17] ❌ 安装失败

                    [关闭] ────────
```

## 性能优化

1. **防抖搜索**：300ms 延迟，减少过滤次数
2. **虚拟滚动**：使用 ListView.builder，只渲染可见项
3. **异步加载**：版本列表异步加载，不阻塞 UI
4. **状态缓存**：已安装状态缓存，避免重复检查

## 未来改进

1. **版本推荐**：智能推荐合适的版本
2. **批量安装**：一次安装多个版本
3. **版本对比**：对比不同版本的差异
4. **下载进度**：显示下载百分比
5. **离线缓存**：缓存版本列表，支持离线浏览

---

**功能完成！** ✅

现在用户可以方便地搜索、浏览和安装任何 Node.js 版本，并实时查看安装进度。
