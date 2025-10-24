# Tabs 集成调试指南

## 当前问题

浏览器访问 http://localhost:3330 时报错。

## 可能的原因

1. **TypeScript 类型错误** - 不影响运行，但会在开发时显示
2. **模块路径问题** - alias 配置可能需要重启开发服务器
3. **组件导入问题** - 检查组件是否正确导出

## 解决步骤

### 1. 重启开发服务器

```bash
# 停止当前服务器 (Ctrl+C)
# 然后重新启动
pnpm dev
```

### 2. 检查浏览器控制台错误

打开浏览器开发者工具 (F12)，查看 Console 标签页的错误信息。

### 3. 常见错误及解决方案

#### 错误: Cannot find module '@ldesign/tabs/vue'

**原因**: launcher 的 alias 配置需要重启服务器才能生效

**解决**: 
```bash
# 停止服务器并重启
pnpm dev
```

#### 错误: tabs is not defined / tabs.length

**原因**: useTabs 初始化可能有问题

**解决**: 检查 router 是否正确传入

#### 错误: Failed to resolve component: TabsContainer

**原因**: 组件导入路径或导出有问题

**解决**: 检查组件导出是否正确

### 4. 临时禁用 Tabs（如果需要先让应用运行）

如果需要先让应用运行起来，可以临时注释掉 TabsContainer：

```vue
<!-- MainLayout.vue -->
<template #default>
  <!-- 临时注释掉标签页 -->
  <!-- <TabsContainer ... /> -->
  
  <div class="page-content">
    <RouterView :key="route.fullPath" />
  </div>
</template>
```

### 5. 验证 tabs 构建产物

```bash
cd packages/tabs
ls -la es/  # 检查是否有构建产物
```

应该看到:
- es/core/
- es/types/
- es/utils/
- es/vue/
- es/styles/

### 6. 检查 launcher 配置

确认 `.ldesign/launcher.config.ts` 中有以下配置：

```typescript
{
  find: '@ldesign/tabs/vue',
  replacement: '../../packages/tabs/src/vue',
  stages: ['dev']
},
{
  find: '@ldesign/tabs',
  replacement: '../../packages/tabs/src',
  stages: ['dev']
},
{
  find: '@ldesign/tabs/es/styles/index.css',
  replacement: '../../packages/tabs/src/styles/index.css',
  stages: ['dev', 'build']
}
```

## 获取更多信息

请提供以下信息以便进一步诊断：

1. **浏览器控制台错误**: 完整的错误消息
2. **终端错误**: 开发服务器的错误输出
3. **网络请求**: Network 标签中失败的请求

## 快速测试

访问以下地址测试基础功能：

1. http://localhost:3330/ - 首页
2. http://localhost:3330/about - 关于页
3. 查看是否有标签栏显示

如果看不到标签栏但页面能正常显示，说明 Tabs 组件有问题。
如果整个页面都无法显示，说明是更基础的问题。










