# NPM 源认证和用户包管理

## 概述

优化了 NPM 源管理功能，支持可选认证、自动登录和用户包过滤。

## 新增功能

### 1. 可选认证信息

#### 公共源
- **不强制要求**认证信息
- 可以选择性填写用户名和密码
- 适用于需要发布包或访问私有包的场景

```
添加 npm 官方源：
- 源名称: npm 官方源
- 源地址: https://registry.npmjs.org/
- 用户名: (可选) 你的 npm 用户名
- 密码: (可选) 你的 npm 密码
```

#### 远程私有源
- 认证信息仍然是可选的
- 建议填写以获得完整功能
- 支持自动登录

```
添加私有源：
- 源名称: 公司私有源
- 源地址: https://npm.company.com/
- 用户名: (可选) 你的用户名
- 密码: (可选) 你的密码
```

### 2. 自动登录

#### 工作流程

```
1. 用户添加源并填写认证信息
   ↓
2. 系统保存源配置
   ↓
3. 自动执行 npm login
   ↓
4. 显示登录结果
```

#### 登录状态提示

**成功**：
```
✅ 已添加 npm 官方源，并已自动登录
```

**失败**：
```
⚠️ 已添加 npm 官方源，但登录失败，请稍后手动登录
```

**未提供认证**：
```
✅ 已添加 npm 官方源
```

### 3. 用户包过滤

#### 智能包列表

当源配置了登录用户时，包列表会自动过滤：

**有登录用户**：
- 只显示该用户发布的包
- 顶部显示用户信息提示
- 空状态显示用户特定提示

**无登录用户**：
- 显示所有可用的包
- 显示通用的包列表

#### 用户信息提示

```
┌─────────────────────────────────────────┐
│ 👤 当前登录用户: your-username          │
│                    显示该用户发布的包    │
└─────────────────────────────────────────┘
```

## 技术实现

### 1. 认证信息验证

```dart
// 公共源和远程私有源都支持可选认证
if (_selectedType != NpmRegistryType.local) {
  TextFormField(
    controller: _usernameController,
    decoration: const InputDecoration(
      labelText: '用户名',
      hintText: '输入用户名（可选）',
    ),
  ),
  // ...
}
```

### 2. 自动登录逻辑

```dart
// 添加源后自动登录
bool loginSuccess = false;
if (registry.username != null && 
    registry.username!.isNotEmpty && 
    registry.password != null && 
    registry.password!.isNotEmpty) {
  try {
    loginSuccess = await widget.ref
        .read(npmRegistryNotifierProvider.notifier)
        .loginToRegistry(registry);
  } catch (e) {
    debugPrint('Auto login failed: $e');
  }
}
```

### 3. 用户包获取

#### 方法1: 使用 npm search API

```dart
Future<List<String>> _loadUserPackages(String baseUrl) async {
  final username = widget.registry.username;
  
  // 搜索用户的包
  final searchUrl = '$baseUrl/-/v1/search?text=maintainer:$username&size=250';
  final response = await http.get(Uri.parse(searchUrl));
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['objects']
        .map((obj) => obj['package']['name'] as String)
        .toList();
  }
}
```

#### 方法2: 过滤所有包

```dart
// 获取所有包
final allPackagesUrl = '$baseUrl/-/all';
final response = await http.get(Uri.parse(allPackagesUrl));

// 过滤出用户的包
for (var entry in data.entries) {
  final maintainers = entry.value['maintainers'];
  final hasUser = maintainers.any((m) => m['name'] == username);
  if (hasUser) {
    userPackages.add(entry.key);
  }
}
```

### 4. 加载优先级

```dart
Future<List<String>> _loadPackagesFromVerdaccioApi() async {
  // 1. 如果有登录用户，优先获取该用户的包
  if (widget.registry.username != null) {
    final userPackages = await _loadUserPackages(baseUrl);
    if (userPackages.isNotEmpty) {
      return userPackages;
    }
  }
  
  // 2. 否则获取所有包
  // ...
}
```

## 使用场景

### 场景1: 公共源只读访问

```
用途：浏览和安装公共包
配置：
- 源名称: npm 官方源
- 源地址: https://registry.npmjs.org/
- 认证信息: 留空

结果：
- 可以浏览所有公共包
- 可以安装包
- 不能发布包
```

### 场景2: 公共源发布包

```
用途：发布自己的包到 npm
配置：
- 源名称: npm 官方源
- 源地址: https://registry.npmjs.org/
- 用户名: your-npm-username
- 密码: your-npm-password

结果：
- 自动登录到 npm
- 只显示你发布的包
- 可以发布新包
```

### 场景3: 私有源团队协作

```
用途：访问公司私有包
配置：
- 源名称: 公司私有源
- 源地址: https://npm.company.com/
- 用户名: your-company-username
- 密码: your-company-password

结果：
- 自动登录到私有源
- 显示你发布的包
- 可以发布和管理包
```

### 场景4: 本地开发测试

```
用途：本地 Verdaccio 测试
配置：
- 源类型: 本地私有源
- 端口: 4873
- 认证信息: 不需要

结果：
- 启动本地 Verdaccio
- 显示所有本地包
- 快速测试发布流程
```

## UI 改进

### 1. 添加源对话框

**之前**：
- 远程私有源强制要求用户名密码
- 公共源不显示认证选项

**现在**：
- 所有源类型都支持可选认证
- 清晰的提示说明何时需要认证
- 统一的用户体验

### 2. 包列表页面

**之前**：
- 显示所有包，无法区分用户
- 没有用户信息提示

**现在**：
- 智能过滤用户的包
- 顶部显示当前登录用户
- 空状态显示用户特定提示

### 3. 状态反馈

**登录成功**：
```
┌─────────────────────────────────────┐
│ ✅ 已添加 npm 官方源，并已自动登录  │
└─────────────────────────────────────┘
```

**登录失败**：
```
┌─────────────────────────────────────┐
│ ⚠️ 已添加 npm 官方源，但登录失败    │
│    请稍后手动登录                    │
└─────────────────────────────────────┘
```

## 错误处理

### 1. 自动登录失败

```dart
try {
  loginSuccess = await loginToRegistry(registry);
} catch (e) {
  debugPrint('Auto login failed: $e');
  // 不影响源的添加，只是登录失败
}
```

### 2. 用户包获取失败

```dart
try {
  final userPackages = await _loadUserPackages(baseUrl);
  if (userPackages.isNotEmpty) {
    return userPackages;
  }
} catch (e) {
  debugPrint('Error loading user packages: $e');
  // 降级到获取所有包
}
```

### 3. API 不支持

```
如果源不支持用户包查询：
1. 尝试 search API
2. 尝试过滤所有包
3. 降级到显示所有包
```

## 兼容性

### 支持的源类型

| 源类型 | 可选认证 | 自动登录 | 用户包过滤 |
|--------|----------|----------|------------|
| 公共源 | ✅ | ✅ | ✅ |
| 远程私有源 | ✅ | ✅ | ✅ |
| 本地私有源 | ❌ | ❌ | ✅ |

### 支持的 API

| API | 用途 | 支持度 |
|-----|------|--------|
| `/-/v1/search?text=maintainer:user` | 搜索用户包 | npm, Verdaccio |
| `/-/all` | 获取所有包 | npm, Verdaccio |
| `/-/verdaccio/data/packages` | Verdaccio 包列表 | Verdaccio |

## 最佳实践

### 1. 公共源使用

```
推荐配置：
- 只读访问：不填写认证信息
- 发布包：填写认证信息

优点：
- 安全性更高
- 按需授权
- 清晰的权限管理
```

### 2. 私有源使用

```
推荐配置：
- 始终填写认证信息
- 使用强密码
- 定期更新密码

优点：
- 自动登录
- 用户包过滤
- 更好的协作体验
```

### 3. 本地源使用

```
推荐配置：
- 不需要认证信息
- 使用默认端口
- 快速测试

优点：
- 快速启动
- 无需配置
- 适合开发测试
```

## 安全考虑

### 1. 密码存储

```
- 密码以明文存储在本地配置文件
- 建议使用应用专用密码
- 不要使用主账号密码
```

### 2. 自动登录

```
- 只在添加源时自动登录一次
- 登录失败不影响源的添加
- 可以稍后手动重新登录
```

### 3. 用户包访问

```
- 使用认证头访问 API
- 只显示有权限的包
- 遵循源的访问控制
```

## 未来改进

### 计划功能

1. **Token 认证**
   - 支持 npm token
   - 更安全的认证方式
   - 避免存储密码

2. **多用户支持**
   - 同一源支持多个用户
   - 快速切换用户
   - 用户配置管理

3. **包权限管理**
   - 查看包的访问权限
   - 管理协作者
   - 权限可视化

4. **离线模式**
   - 缓存用户包列表
   - 离线浏览
   - 同步机制

## 总结

### 主要改进

1. ✅ **可选认证** - 公共源不强制要求认证
2. ✅ **自动登录** - 添加源时自动登录
3. ✅ **用户包过滤** - 只显示当前用户的包
4. ✅ **智能降级** - API 失败时自动降级
5. ✅ **清晰反馈** - 详细的状态提示

### 用户价值

- 🎯 **更灵活** - 按需配置认证
- ⚡ **更快捷** - 自动登录省时间
- 🎨 **更清晰** - 只看自己的包
- 🛡️ **更安全** - 可选的认证方式
- 😊 **更友好** - 清晰的提示和反馈

---

**现在你可以更灵活地管理 NPM 源，享受更好的开发体验！** 🎉
