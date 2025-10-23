# 模板选择器集成指南

## ✅ 实现方案

采用了**最优雅简单的响应式绑定方案**，让 TemplateRenderer 和 TemplateSelector 自动同步。

## 🎯 核心原理

```
用户点击选择 → TemplateSelector 触发 @select 事件 
→ handleTemplateSelect 更新 currentTemplate 
→ TemplateRenderer 的 :name prop 响应变化 
→ 自动加载并渲染新模板
```

## 📝 实现代码

### Main.vue 完整实现

```vue
<template>
  <TemplateRenderer 
    category="dashboard"
    :name="currentTemplate || undefined"
    @device-change="handleDeviceChange"
    @template-change="handleTemplateSelect"
  >
    <template #header-actions>
      <div class="header-actions">
        <!-- 模板选择器 -->
        <TemplateSelector
          category="dashboard"
          :device="currentDevice"
          :current-template="currentTemplate"
          @select="handleTemplateSelect"
        />
        
        <!-- 其他选择器... -->
      </div>
    </template>
  </TemplateRenderer>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { TemplateRenderer, TemplateSelector } from '@ldesign/template'

// 状态管理
const currentDevice = ref<'desktop' | 'mobile' | 'tablet'>('desktop')
const currentTemplate = ref<string>('')

// 处理模板选择
const handleTemplateSelect = (templateName: string) => {
  // 更新状态，触发 TemplateRenderer 重新渲染
  currentTemplate.value = templateName
  // 保存用户偏好
  localStorage.setItem('preferred-dashboard-template', templateName)
}

// 处理设备变化
const handleDeviceChange = (device: string) => {
  currentDevice.value = device as 'desktop' | 'mobile' | 'tablet'
}

// 初始化：恢复用户上次选择的模板
const savedTemplate = localStorage.getItem('preferred-dashboard-template')
if (savedTemplate) {
  currentTemplate.value = savedTemplate
}

// 其他代码...
</script>
```

## 🔄 数据流

### 初始化流程

```
1. 从 localStorage 读取上次选择 → currentTemplate
2. currentTemplate 传给 TemplateRenderer 的 :name
3. TemplateRenderer 加载指定模板（或默认模板）
4. TemplateRenderer 触发 @template-change 事件
5. handleTemplateSelect 同步 currentTemplate（确保一致）
```

### 用户切换模板流程

```
1. 用户点击 TemplateSelector 中的某个模板
2. TemplateSelector 触发 @select 事件
3. handleTemplateSelect 被调用:
   - 更新 currentTemplate.value
   - 保存到 localStorage
4. TemplateRenderer 的 watch 检测到 :name prop 变化
5. TemplateRenderer 自动加载新模板
6. 页面重新渲染，显示新模板布局
```

## ✨ 方案优势

### 1. 简单优雅
- ✅ 只需 2 个 ref 状态
- ✅ 1 个处理函数
- ✅ 响应式自动同步

### 2. 可靠性
- ✅ 利用 Vue 的响应式系统
- ✅ TemplateRenderer 内部有完整的 watch 监听
- ✅ 无需手动触发重新加载

### 3. 持久化
- ✅ 自动保存用户选择
- ✅ 刷新页面后恢复上次选择
- ✅ 跨会话保持偏好

### 4. 双向同步
- ✅ TemplateSelector → TemplateRenderer (通过 :name)
- ✅ TemplateRenderer → TemplateSelector (通过 @template-change)
- ✅ 状态始终一致

## 🔍 关键代码说明

### `:name="currentTemplate || undefined"`

```typescript
// 空字符串转为 undefined，让 TemplateRenderer 自动加载默认模板
:name="currentTemplate || undefined"
```

**为什么这样写？**
- 初始值 `currentTemplate = ''`
- 空字符串 || undefined → undefined
- TemplateRenderer 收到 undefined 时启用 autoLoadDefault
- 自动选择该分类和设备的默认模板

### `@template-change="handleTemplateSelect"`

```typescript
// TemplateRenderer 内部加载模板后会触发这个事件
// 我们用同一个函数处理，确保状态同步
@template-change="handleTemplateSelect"
```

**双向绑定效果**:
- 用户点击 → handleTemplateSelect → 更新 currentTemplate → TemplateRenderer 加载
- TemplateRenderer 自动加载 → 触发 @template-change → handleTemplateSelect → 同步 currentTemplate

## 📊 状态管理

### 状态变量

| 变量 | 类型 | 用途 | 初始值 |
|------|------|------|--------|
| `currentDevice` | `Ref<DeviceType>` | 当前设备类型 | `'desktop'` |
| `currentTemplate` | `Ref<string>` | 当前模板名称 | `''` (空字符串) |

### 为什么用空字符串？

```typescript
const currentTemplate = ref<string>('')  // ✅ 优雅
// 而不是
const currentTemplate = ref<string>('default')  // ❌ 硬编码
```

**原因**:
1. 不同设备可能有不同的默认模板
2. 让 TemplateRenderer 自己决定默认值
3. 更灵活，支持动态默认模板

## 🎮 用户交互流程

### 场景 1: 首次访问

```
用户访问 → currentTemplate = '' 
→ TemplateRenderer 自动加载 desktop 默认模板
→ 触发 @template-change 事件
→ currentTemplate 更新为实际模板名
→ TemplateSelector 显示当前选中的模板
```

### 场景 2: 切换模板

```
用户点击"现代风格"模板
→ TemplateSelector 触发 @select("modern")
→ handleTemplateSelect("modern") 调用
→ currentTemplate.value = "modern"
→ localStorage 保存偏好
→ TemplateRenderer 检测到 :name 变化
→ 加载 modern 模板
→ 页面布局切换
```

### 场景 3: 刷新页面

```
页面加载 → 读取 localStorage
→ currentTemplate = "modern" (上次选择)
→ TemplateRenderer 收到 :name="modern"
→ 直接加载 modern 模板
→ 用户看到上次选择的布局
```

## 🐛 为什么能解决切换问题？

### 问题原因
之前可能是：
- ❌ TemplateRenderer 没有收到 name prop
- ❌ 或者 name 是固定值，不响应变化
- ❌ 或者缺少 watch 监听

### 解决方案
现在：
- ✅ `:name="currentTemplate || undefined"` - 响应式绑定
- ✅ TemplateRenderer 内部有 watch 监听 props.name 变化
- ✅ 变化时自动更新 currentName.value
- ✅ currentName 改变触发模板重新加载

## 📝 代码对比

### ❌ 错误方式

```vue
<!-- 没有绑定 name -->
<TemplateRenderer category="dashboard" />
<!-- 模板选择器无法切换模板！ -->
```

### ✅ 正确方式

```vue
<!-- 响应式绑定 name -->
<TemplateRenderer 
  category="dashboard"
  :name="currentTemplate || undefined"
/>
<!-- TemplateSelector 的选择会立即生效！ -->
```

## 🎉 总结

这个方案的优雅之处在于：

1. **极简代码** - 只需要绑定一个 prop
2. **自动同步** - 利用 Vue 响应式系统
3. **无副作用** - 不需要手动调用任何方法
4. **可维护** - 清晰的单向数据流

**一行关键代码解决问题**:
```vue
:name="currentTemplate || undefined"
```

---

**实现日期**: 2025-10-23  
**解决方案**: 响应式 prop 绑定  
**代码复杂度**: 极低  
**可靠性**: 极高 ✅

