<template>
  <div class="tabs-demo">
    <h1>Tabs 组件演示</h1>

    <div class="demo-section">
      <h2>样式类型切换</h2>
      <div class="controls">
        <label>
          <input type="radio" v-model="styleType" value="chrome" />
          Chrome 风格
        </label>
        <label>
          <input type="radio" v-model="styleType" value="vscode" />
          VSCode 风格
        </label>
        <label>
          <input type="radio" v-model="styleType" value="card" />
          Card 卡片风格
        </label>
        <label>
          <input type="radio" v-model="styleType" value="material" />
          Material 风格
        </label>
      </div>
    </div>

    <div class="demo-section">
      <h2>尺寸大小</h2>
      <div class="controls">
        <label>
          <input type="radio" v-model="size" value="xs" />
          超小 (xs)
        </label>
        <label>
          <input type="radio" v-model="size" value="sm" />
          小 (sm)
        </label>
        <label>
          <input type="radio" v-model="size" value="md" />
          中 (md)
        </label>
        <label>
          <input type="radio" v-model="size" value="lg" />
          大 (lg)
        </label>
        <label>
          <input type="radio" v-model="size" value="xl" />
          超大 (xl)
        </label>
      </div>
    </div>

    <div class="demo-section">
      <h2>宽度模式</h2>
      <div class="controls">
        <label>
          <input type="radio" v-model="widthMode" value="shrink" />
          Shrink 模式（自动缩小）
        </label>
        <label>
          <input type="radio" v-model="widthMode" value="scroll" />
          Scroll 模式（滚动）
        </label>
      </div>
    </div>

    <div class="demo-section">
      <h2>其他选项</h2>
      <div class="controls">
        <label>
          <input type="checkbox" v-model="showIcon" />
          显示图标
        </label>
        <label>
          <input type="checkbox" v-model="enableDrag" />
          启用拖拽
        </label>
        <label>
          <input type="checkbox" v-model="showScrollButtons" />
          显示滚动按钮
        </label>
      </div>
      <div class="controls">
        <button @click="addTab">添加标签</button>
        <button @click="addMultipleTabs">添加多个标签</button>
        <button @click="clearTabs">清空标签</button>
      </div>
    </div>

    <div class="demo-section">
      <h2>预览效果</h2>
      <div class="tabs-preview">
        <TabsContainer :tabs="demoTabs" :active-tab-id="activeTabId" :style-type="styleType" :width-mode="widthMode"
          :size="size" :enable-drag="enableDrag" :show-icon="showIcon" :show-scroll-buttons="showScrollButtons"
          @tab-click="handleTabClick" @tab-close="handleTabClose" @tab-pin="handleTabPin" @tab-unpin="handleTabUnpin" />
      </div>
    </div>

    <div class="demo-section">
      <h2>当前配置</h2>
      <div class="config-display">
        <pre>{{ configInfo }}</pre>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { TabsContainer } from '@ldesign/tabs/vue'
import type { Tab } from '@ldesign/tabs'
import '@ldesign/tabs/styles'

// 配置选项
const styleType = ref<'chrome' | 'vscode' | 'card' | 'material'>('chrome')
const widthMode = ref<'shrink' | 'scroll'>('shrink')
const size = ref<'xs' | 'sm' | 'md' | 'lg' | 'xl'>('md')
const showIcon = ref(true)
const enableDrag = ref(true)
const showScrollButtons = ref(true)

// 标签数据
const demoTabs = ref<Tab[]>([
  {
    id: '1',
    title: '首页',
    path: '/home',
    icon: '🏠',
    closable: false,
  },
  {
    id: '2',
    title: '关于',
    path: '/about',
    icon: 'ℹ️',
    closable: true,
  },
  {
    id: '3',
    title: '设置',
    path: '/settings',
    icon: '⚙️',
    closable: true,
  },
  {
    id: '4',
    title: '用户管理',
    path: '/users',
    icon: '👥',
    closable: true,
  },
  {
    id: '5',
    title: '数据分析',
    path: '/analytics',
    icon: '📊',
    closable: true,
  },
])

const activeTabId = ref('1')
let tabIdCounter = 6

// 事件处理
const handleTabClick = (tab: Tab) => {
  activeTabId.value = tab.id
  console.log('Tab clicked:', tab)
}

const handleTabClose = (tab: Tab) => {
  const index = demoTabs.value.findIndex(t => t.id === tab.id)
  if (index !== -1) {
    demoTabs.value.splice(index, 1)
    if (activeTabId.value === tab.id && demoTabs.value.length > 0) {
      activeTabId.value = demoTabs.value[Math.max(0, index - 1)].id
    }
  }
}

const handleTabPin = (tab: Tab) => {
  const target = demoTabs.value.find(t => t.id === tab.id)
  if (target) {
    target.pinned = true
  }
}

const handleTabUnpin = (tab: Tab) => {
  const target = demoTabs.value.find(t => t.id === tab.id)
  if (target) {
    target.pinned = false
  }
}

// 操作按钮
const addTab = () => {
  const icons = ['📝', '🔍', '🎨', '📁', '🔧', '💡', '📈', '🌐', '🔒', '⚡']
  const newTab: Tab = {
    id: String(tabIdCounter++),
    title: `新标签 ${tabIdCounter - 1}`,
    path: `/tab-${tabIdCounter - 1}`,
    icon: icons[Math.floor(Math.random() * icons.length)],
    closable: true,
  }
  demoTabs.value.push(newTab)
  activeTabId.value = newTab.id
}

const addMultipleTabs = () => {
  for (let i = 0; i < 5; i++) {
    addTab()
  }
}

const clearTabs = () => {
  // 保留第一个不可关闭的标签
  demoTabs.value = demoTabs.value.filter(t => !t.closable)
  activeTabId.value = demoTabs.value[0]?.id || ''
}

// 配置信息
const configInfo = computed(() => {
  return JSON.stringify({
    styleType: styleType.value,
    widthMode: widthMode.value,
    size: size.value,
    showIcon: showIcon.value,
    enableDrag: enableDrag.value,
    showScrollButtons: showScrollButtons.value,
    tabsCount: demoTabs.value.length,
    activeTab: demoTabs.value.find(t => t.id === activeTabId.value)?.title,
  }, null, 2)
})
</script>

<style scoped>
.tabs-demo {
  padding: var(--size-spacing-2xl, 24px);
  max-width: 1400px;
  margin: 0 auto;
}

h1 {
  font-size: var(--size-font-2xl, 24px);
  margin-bottom: var(--size-spacing-2xl, 24px);
  color: var(--color-text-primary);
}

h2 {
  font-size: var(--size-font-lg, 18px);
  margin-bottom: var(--size-spacing-lg, 12px);
  color: var(--color-text-secondary);
}

.demo-section {
  margin-bottom: var(--size-spacing-3xl, 32px);
  padding: var(--size-spacing-xl, 16px);
  background-color: var(--color-bg-component);
  border-radius: var(--size-radius-md, 6px);
  border: 1px solid var(--color-border);
}

.controls {
  display: flex;
  flex-wrap: wrap;
  gap: var(--size-spacing-lg, 12px);
  margin-bottom: var(--size-spacing-md, 8px);
}

.controls label {
  display: flex;
  align-items: center;
  gap: var(--size-spacing-xs, 4px);
  cursor: pointer;
  padding: var(--size-spacing-sm, 6px) var(--size-spacing-md, 8px);
  background-color: var(--color-bg-subtle);
  border-radius: var(--size-radius-sm, 4px);
  transition: background-color 0.2s;
}

.controls label:hover {
  background-color: var(--color-bg-hover);
}

.controls button {
  padding: var(--size-spacing-md, 8px) var(--size-spacing-lg, 12px);
  background-color: var(--color-primary-default);
  color: white;
  border: none;
  border-radius: var(--size-radius-sm, 4px);
  cursor: pointer;
  font-size: var(--size-font-sm, 12px);
  transition: background-color 0.2s;
}

.controls button:hover {
  background-color: var(--color-primary-hover);
}

.tabs-preview {
  background-color: var(--color-bg-layout);
  border-radius: var(--size-radius-md, 6px);
  padding: var(--size-spacing-xl, 16px);
  min-height: 100px;
}

.config-display {
  background-color: var(--color-bg-subtle);
  border-radius: var(--size-radius-sm, 4px);
  padding: var(--size-spacing-lg, 12px);
  overflow-x: auto;
}

.config-display pre {
  margin: 0;
  font-family: 'Courier New', monospace;
  font-size: var(--size-font-sm, 12px);
  color: var(--color-text-primary);
}
</style>

