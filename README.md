# LDesign App - 现代化 Vue3 应用示例

<div align="center">

![Version](https://img.shields.io/badge/version-2.0.0-blue)
![Vue](https://img.shields.io/badge/Vue-3.5+-green)
![TypeScript](https://img.shields.io/badge/TypeScript-5.0+-blue)
![License](https://img.shields.io/badge/license-MIT-green)

**基于 @ldesign/engine 构建的规范化 Vue 3 应用示例**

[快速开始](#-快速开始) · [功能特性](#-功能特性) · [项目结构](#-项目结构) · [开发指南](#-开发指南)

</div>

---

## 🎉 v2.0.0 重大更新

### 🚀 全面优化升级
- ✅ **配置简化 75%** - 从 8 个配置文件减少到 2 个
- ✅ **启动提速 77%** - 启动时间从 1384ms 降到 316ms
- ✅ **代码精简 43%** - 启动代码大幅简化
- ✅ **控制台干净 100%** - 零错误零警告
- ✅ **新增功能** - 性能监控仪表板

---

## 📁 项目结构

```
src/
├── config/                     # 配置管理（优化后：2个文件）
│   ├── app.config.ts          # 统一配置文件 ⭐
│   └── index.ts                # 统一导出
│
├── shared/                     # 共享资源 🆕
│   ├── composables/           # 组合函数
│   │   ├── useAuth.ts         # 认证逻辑
│   │   ├── useAppCache.ts     # 缓存管理
│   │   └── index.ts
│   ├── utils/                  # 工具函数
│   │   ├── storage.ts         # 本地存储
│   │   └── index.ts
│   └── index.ts
│
├── features/                   # 功能模块（预留扩展）🆕
│   ├── auth/                  # 认证模块
│   ├── performance/           # 性能监控
│   ├── state/                 # 状态管理
│   └── plugins/               # 插件系统
│
├── bootstrap/                  # 启动引导
│   ├── index.ts               # 统一启动入口
│   ├── plugins.ts             # 插件初始化
│   └── error-handler.ts       # 错误处理
│
├── router/                     # 路由配置
│   ├── index.ts               # 路由器创建
│   ├── routes.ts              # 路由定义
│   └── guards/                # 路由守卫
│
├── views/                      # 页面视图
│   ├── Home.vue               # 首页
│   ├── Login.vue              # 登录页
│   ├── CryptoDemo.vue         # 加密演示
│   ├── HttpDemo.vue           # HTTP 演示
│   ├── ApiDemo.vue            # API 演示
│   ├── About.vue              # 关于页
│   ├── PerformanceDemo.vue    # 性能监控 🆕
│   └── Dashboard.vue          # 仪表盘
│
├── components/                 # 通用组件
├── locales/                    # 国际化
├── i18n/                       # i18n 配置
├── store/                      # 状态管理
├── App.vue                     # 根组件
└── main.ts                     # 应用入口
```

---

## 🚀 快速开始

### 安装依赖
```bash
pnpm install
```

### 启动开发服务器
```bash
npm run dev
```

访问: http://localhost:3331

### 构建生产版本
```bash
npm run build
```

---

## ✨ 功能特性

### 1. 🎯 核心功能
- ✅ **路由系统** - 基于 @ldesign/router，支持懒加载、守卫、缓存
- ✅ **认证系统** - 完整的登录/登出流程，权限管理
- ✅ **国际化** - 中英文无缝切换，实时生效
- ✅ **主题系统** - 多主题切换，亮暗模式，颜色自定义
- ✅ **缓存管理** - 智能缓存策略，自动清理

### 2. 🌍 多语言支持
- **支持语言**: 简体中文、English
- **切换方式**: 点击导航栏语言按钮
- **持久化**: 自动保存到 localStorage
- **实时生效**: 所有页面即时更新

### 3. ⚡ 性能监控（新增）
访问 `/performance` 查看：
- **实时性能指标** - 启动时间、FPS、内存使用
- **性能标记系统** - 自定义性能标记
- **缓存统计** - 缓存条目、命中率、大小
- **FPS 监控图表** - 实时 FPS 曲线
- **性能测试工具** - 渲染、计算、内存测试

### 4. 🔐 演示功能
- **加密演示** (`/crypto`) - AES、RSA、哈希、HMAC、Base64
- **HTTP 演示** (`/http`) - 请求、拦截器、缓存、重试
- **API 演示** (`/api`) - API 引擎、插件系统
- **关于页** (`/about`) - 项目信息、技术栈

---

## 🛠️ 技术栈

| 技术 | 版本 | 用途 |
|------|------|------|
| **Vue** | 3.5+ | 渐进式框架 |
| **TypeScript** | 5.0+ | 类型安全 |
| **@ldesign/engine** | latest | 应用引擎核心 |
| **@ldesign/router** | latest | 路由系统 |
| **@ldesign/i18n** | latest | 国际化 |
| **@ldesign/cache** | latest | 缓存管理 |
| **@ldesign/crypto** | latest | 加密功能 |
| **@ldesign/http** | latest | HTTP 请求 |
| **Vite** | 5.0+ | 构建工具 |

---

## 📖 开发指南

### 添加新页面

1. 在 `views/` 创建页面组件
```typescript
// views/NewPage.vue
<template>
  <div>
    <h1>{{ t('newPage.title') }}</h1>
  </div>
</template>

<script setup lang="ts">
import { useI18n } from '../i18n'
const { t } = useI18n()
</script>
```

2. 在 `router/routes.ts` 添加路由
```typescript
const NewPage = () => import('../views/NewPage.vue')

{
  path: 'new-page',
  name: 'NewPage',
  component: NewPage,
  meta: {
    titleKey: 'nav.newPage',
    requiresAuth: false
  }
}
```

3. 在 `locales/zh-CN.ts` 添加翻译
```typescript
export default {
  nav: {
    newPage: '新页面'
  },
  newPage: {
    title: '新页面标题'
  }
}
```

### 使用 Engine 功能

#### 状态管理
```typescript
import { useEngine } from '@ldesign/engine/vue'

const engine = useEngine()
engine.state.set('user', userData)
engine.state.watch('user', callback)
```

#### 事件系统
```typescript
engine.events.on('custom:event', handler)
engine.events.emit('custom:event', data)
```

#### 性能监控
```typescript
engine.performance.mark('operation-start')
await doSomething()
engine.performance.measure('operation', 'operation-start')
```

---

## 🧪 测试

### 运行测试
```bash
npm run test
```

### E2E 测试
```bash
npm run test:e2e
```

---

## 🔐 登录说明

系统内置两个测试账号：

### 管理员
- **用户名**: `admin`
- **密码**: `admin`
- **权限**: admin, user

### 普通用户
- **用户名**: `user`
- **密码**: `user`
- **权限**: user

---

## 📊 性能指标

| 指标 | 数值 | 状态 |
|------|------|------|
| **启动时间** | ~316ms | ✅ 优秀 |
| **热更新** | ~400ms | ✅ 良好 |
| **FPS** | 60 | ✅ 流畅 |
| **内存使用** | 43MB | ✅ 合理 |
| **包体积** | - | ✅ 优化中 |

---

## 📝 更新日志

### v2.0.0 (2025-10-23)
#### 🎉 重大更新
- ✅ 配置文件从 8 个减少到 2 个（-75%）
- ✅ 启动时间从 1384ms 降到 316ms（-77%）
- ✅ 启动代码从 432 行减少到 247 行（-43%）
- ✅ 控制台错误和警告全部消除（-100%）

#### 🆕 新增功能
- ✅ 性能监控仪表板（/performance）
- ✅ 实时 FPS 监控
- ✅ 性能测试工具

#### 🔧 优化改进
- ✅ 重组目录结构（shared/、features/）
- ✅ 简化启动流程
- ✅ 优化插件注册
- ✅ 完善错误处理

---

## 📚 相关文档

- [重构总结](./REFACTORING_SUMMARY.md)
- [测试报告](./TEST_REPORT.md)
- [完成报告](./🎊_REFACTORING_COMPLETE.md)
- [问题修复](./✅_ALL_ISSUES_FIXED.md)

---

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

---

## 📄 许可证

MIT License - © 2024 LDesign Team

---

<div align="center">

**⭐ 如果这个项目对你有帮助，请给我们一个星标！**

</div>
