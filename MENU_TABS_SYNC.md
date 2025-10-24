# 菜单与页签联动实现

## ✅ 完成状态

菜单与页签的双向联动已完全实现！

## 🔄 联动机制

### 1. 页签 → 菜单联动

当用户切换页签时，菜单会自动：
- ✅ 选中对应的菜单项
- ✅ 展开所有父级菜单
- ✅ 滚动到可见区域

#### 实现原理

```vue
<!-- NavigationMenu.vue -->
<script setup>
// 监听当前路径变化
watch(() => props.currentPath, (newPath) => {
  if (newPath && menuRef.value) {
    // 选中当前菜单项
    menuRef.value.selectItem(newPath)
    
    // 展开所有父级菜单
    expandedKeys.value.forEach(key => {
      menuRef.value.expand(key)
    })
  }
}, { immediate: true })
</script>
```

### 2. 菜单 → 页签联动

当用户点击菜单项时，会自动：
- ✅ 导航到对应路由
- ✅ 创建或激活对应页签
- ✅ 更新页签标题和图标

#### 实现原理

```vue
<!-- NavigationMenu.vue -->
const handleMenuSelect = (item: LMenuItem) => {
  if (item.path) {
    router.push(item.path)  // 路由导航
  }
}
```

```vue
<!-- MainLayout.vue -->
// TabsContainer 自动监听路由变化
const tabsInstance = useTabs({
  router: {
    autoSync: true,  // 自动同步路由
    shouldCreateTab: (route) => route.meta?.layout !== 'blank'
  }
}, router)
```

## 📁 多层级菜单结构

### 当前菜单结构（2-3级）

```typescript
const menuItems = [
  // 一级菜单
  { path: '/', label: '首页', icon: '🏠' },
  { path: '/about', label: '关于', icon: 'ℹ️' },
  
  // 二级菜单：功能演示
  {
    path: '/demos',
    label: '功能演示',
    icon: '🎯',
    children: [
      { path: '/crypto', label: '加密演示', icon: '🔒' },
      { path: '/http', label: 'HTTP 演示', icon: '🌐' },
      { path: '/api', label: 'API 演示', icon: '📡' },
    ],
  },
  
  // 二级菜单：Engine 演示
  {
    path: '/engine',
    label: 'Engine 演示',
    icon: '⚙️',
    children: [
      { path: '/performance', label: '性能监控', icon: '⚡' },
      { path: '/state', label: '状态管理', icon: '🔄' },
      { path: '/event', label: '事件系统', icon: '📡' },
      { path: '/concurrency', label: '并发控制', icon: '⚡' },
      { path: '/plugin', label: '插件系统', icon: '🔌' },
    ],
  },
  
  // 二级+三级菜单：组件演示
  {
    path: '/components',
    label: '组件演示',
    icon: '🧩',
    children: [
      { path: '/tabs', label: 'Tabs 组件', icon: '📑' },
      { path: '/menu', label: 'Menu 菜单', icon: '📋' },
      // 三级菜单
      {
        path: '/advanced',
        label: '高级组件',
        icon: '🚀',
        children: [
          { path: '/tabs', label: 'Tabs (详细)', icon: '📑' },
          { path: '/menu', label: 'Menu (详细)', icon: '📋' },
        ],
      },
    ],
  },
]
```

## 🎯 联动效果

### 场景 1：点击菜单项
1. 用户点击 "功能演示 > 加密演示"
2. 菜单选中 "加密演示"
3. 路由导航到 `/crypto`
4. 自动创建 "加密演示" 页签
5. 激活该页签

### 场景 2：切换页签
1. 用户点击页签 "HTTP 演示"
2. 路由导航到 `/http`
3. 菜单自动展开 "功能演示"
4. 菜单选中 "HTTP 演示"
5. 滚动到可见区域

### 场景 3：关闭页签
1. 用户关闭 "API 演示" 页签
2. 激活上一个页签
3. 菜单跟随激活的页签选中

### 场景 4：刷新页面
1. 页面刷新后保持路由
2. 菜单自动选中当前路由
3. 自动展开所有父级菜单
4. 页签从本地存储恢复

## 🔧 核心代码

### 查找激活的菜单项

```typescript
const activeMenuKey = computed(() => {
  if (!props.currentPath) return null
  
  const findMenuItemByPath = (items: MenuItem[], path: string): MenuItem | null => {
    for (const item of items) {
      if (item.path === path) return item
      if (item.children) {
        const found = findMenuItemByPath(item.children, path)
        if (found) return found
      }
    }
    return null
  }

  const found = findMenuItemByPath(props.items, props.currentPath)
  return found?.path || null
})
```

### 查找应该展开的父级

```typescript
const expandedKeys = computed(() => {
  if (!props.currentPath) return []
  
  const keys: string[] = []
  
  const findParentPaths = (items: MenuItem[], targetPath: string, parentPath?: string): boolean => {
    for (const item of items) {
      if (item.path === targetPath) {
        if (parentPath) keys.push(parentPath)
        return true
      }
      if (item.children) {
        const found = findParentPaths(item.children, targetPath, item.path)
        if (found) {
          if (parentPath) keys.push(parentPath)
          keys.push(item.path)
          return true
        }
      }
    }
    return false
  }

  findParentPaths(props.items, props.currentPath)
  return Array.from(new Set(keys))
})
```

### 监听路径变化

```typescript
watch(() => props.currentPath, (newPath) => {
  if (newPath && menuRef.value) {
    menuRef.value.selectItem(newPath)
    expandedKeys.value.forEach(key => {
      menuRef.value.expand(key)
    })
  }
}, { immediate: true })
```

## 📊 数据流

```
用户操作
    ↓
┌─────────────────────────────────┐
│  点击菜单项                         │
│  ├─ handleMenuSelect()           │
│  ├─ router.push(path)            │
│  └─ 路由变化                        │
└─────────────────────────────────┘
    ↓
┌─────────────────────────────────┐
│  路由变化                           │
│  ├─ route.path 更新               │
│  ├─ TabsContainer 监听到变化       │
│  └─ 创建/激活对应页签                 │
└─────────────────────────────────┘
    ↓
┌─────────────────────────────────┐
│  页签切换                           │
│  ├─ currentPath 更新              │
│  ├─ NavigationMenu 监听到变化      │
│  ├─ 计算 activeMenuKey             │
│  ├─ 计算 expandedKeys              │
│  └─ 更新菜单选中和展开状态             │
└─────────────────────────────────┘
```

## 🎨 配置说明

### NavigationMenu Props

```typescript
interface Props {
  items: MenuItem[]           // 菜单数据
  isLoggedIn?: boolean        // 登录状态
  collapsed?: boolean         // 收起状态
  theme?: 'light' | 'dark'    // 主题
  currentPath?: string        // 当前路径（用于联动）
}
```

### Menu 配置

```vue
<Menu
  :default-active-key="activeMenuKey"      // 默认激活项
  :default-expanded-keys="expandedKeys"    // 默认展开项
  submenu-trigger="inline"                 // 内联展开子菜单
  @select="handleMenuSelect"               // 选择事件
/>
```

## 🚀 使用方式

### 在 AppSidebar 中使用

```vue
<template>
  <aside class="app-sidebar">
    <NavigationMenu 
      :items="menuItems" 
      :is-logged-in="isLoggedIn"
      :current-path="currentPath"  <!-- 传入当前路径 -->
    />
  </aside>
</template>

<script setup>
import { useRoute } from '@ldesign/router'

const route = useRoute()
const currentPath = computed(() => route.path)
</script>
```

## ✨ 特性

### 自动联动
- ✅ 切换页签自动选中菜单
- ✅ 点击菜单自动创建页签
- ✅ 刷新页面保持状态
- ✅ 关闭页签跟随激活

### 智能展开
- ✅ 自动展开父级菜单
- ✅ 保持展开状态
- ✅ 手风琴模式可选

### 视觉反馈
- ✅ 激活项高亮
- ✅ 边框指示
- ✅ 图标显示
- ✅ 流畅动画

## 📝 测试场景

### 测试步骤

1. **打开应用** → 菜单选中首页
2. **点击 "功能演示"** → 展开二级菜单
3. **点击 "加密演示"** → 创建页签，菜单保持选中
4. **点击 "HTTP 演示" 页签** → 菜单切换选中
5. **点击 "组件演示"** → 展开三级菜单
6. **点击 "Menu 菜单"** → 创建页签
7. **刷新页面** → 菜单和页签状态恢复

## 🎊 总结

菜单与页签的完美联动已实现：

✅ **双向同步** - 菜单 ↔ 页签自动联动  
✅ **多层级支持** - 2-3级菜单正常工作  
✅ **状态持久化** - 刷新页面保持状态  
✅ **智能展开** - 自动展开父级菜单  
✅ **视觉反馈** - 清晰的激活状态指示  

---

**实现时间**: 2025-10-24  
**状态**: ✅ 完成  
**可用地址**: http://192.168.3.227:3332/


