<template>
  <div class="menu-demo-container">
    <h1 class="demo-title">{{ t('menu.demo.title') }}</h1>
    <p class="demo-description">{{ t('menu.demo.description') }}</p>

    <!-- 控制面板 -->
    <div class="control-panel">
      <div class="control-group">
        <label>{{ t('menu.demo.mode') }}:</label>
        <button v-for="m in modes" :key="m" :class="['control-btn', { active: mode === m }]" @click="mode = m">
          {{ t(`menu.demo.mode.${m}`) }}
        </button>
      </div>

      <div class="control-group">
        <label>{{ t('menu.demo.theme') }}:</label>
        <button v-for="th in themes" :key="th" :class="['control-btn', { active: theme === th }]" @click="theme = th">
          {{ t(`menu.demo.theme.${th}`) }}
        </button>
      </div>

      <div class="control-group" v-if="mode === 'vertical'">
        <label>{{ t('menu.demo.collapsed') }}:</label>
        <button class="control-btn" @click="collapsed = !collapsed">
          {{ collapsed ? t('menu.demo.expand') : t('menu.demo.collapse') }}
        </button>
      </div>

      <div class="control-group">
        <label>{{ t('menu.demo.submenuTrigger') }}:</label>
        <button v-for="trigger in submenuTriggers" :key="trigger"
          :class="['control-btn', { active: submenuTrigger === trigger }]" @click="submenuTrigger = trigger">
          {{ t(`menu.demo.trigger.${trigger}`) }}
        </button>
      </div>

      <div class="control-group">
        <label>{{ t('menu.demo.animation') }}:</label>
        <button class="control-btn" @click="animation = !animation">
          {{ animation ? t('menu.demo.enabled') : t('menu.demo.disabled') }}
        </button>
      </div>
    </div>

    <!-- 菜单演示区域 -->
    <div class="demo-area" :class="{ horizontal: mode === 'horizontal' }">
      <div class="menu-container" :class="{ collapsed: collapsed && mode === 'vertical' }">
        <Menu :items="menuItems" :mode="mode" :theme="theme" :collapsed="collapsed" :submenu-trigger="submenuTrigger"
          :animation="animation" @select="handleSelect" @expand="handleExpand" @collapse="handleCollapse"
          class="demo-menu" />
      </div>

      <div class="info-panel">
        <h3>{{ t('menu.demo.info.title') }}</h3>

        <div v-if="selectedItem" class="info-item">
          <h4>{{ t('menu.demo.info.selected') }}</h4>
          <pre>{{ JSON.stringify(selectedItem, null, 2) }}</pre>
        </div>

        <div class="info-item">
          <h4>{{ t('menu.demo.info.config') }}</h4>
          <pre>{{ JSON.stringify({ mode, theme, collapsed, submenuTrigger, animation }, null, 2) }}</pre>
        </div>

        <div class="info-item">
          <h4>{{ t('menu.demo.info.events') }}</h4>
          <ul class="event-list">
            <li v-for="(event, index) in events" :key="index" class="event-item">
              <span class="event-type">{{ event.type }}</span>
              <span class="event-label">{{ event.label }}</span>
              <span class="event-time">{{ event.time }}</span>
            </li>
          </ul>
        </div>
      </div>
    </div>

    <!-- 代码示例 -->
    <div class="code-example">
      <h3>{{ t('menu.demo.code.title') }}</h3>
      <pre><code>{{ codeExample }}</code></pre>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { useI18n } from '@ldesign/i18n'
import { Menu } from '@ldesign/menu/vue'
import type { MenuItem as LMenuItem } from '@ldesign/menu'
import '@ldesign/menu/es/index.css'

const { t } = useI18n()

// 控制状态
const mode = ref<'horizontal' | 'vertical'>('vertical')
const theme = ref<'light' | 'dark'>('light')
const collapsed = ref(false)
const submenuTrigger = ref<'popup' | 'inline'>('popup')
const animation = ref(true)

const modes = ['horizontal', 'vertical'] as const
const themes = ['light', 'dark'] as const
const submenuTriggers = ['popup', 'inline'] as const

// 选中的菜单项
const selectedItem = ref<LMenuItem | null>(null)

// 事件记录
interface MenuEvent {
  type: string
  label: string
  time: string
}
const events = ref<MenuEvent[]>([])

// 菜单数据
const menuItems = ref<LMenuItem[]>([
  {
    id: '1',
    label: '首页',
    icon: '🏠',
    path: '/',
  },
  {
    id: '2',
    label: '产品',
    icon: '📦',
    children: [
      { id: '2-1', label: '产品 A', icon: '📱' },
      { id: '2-2', label: '产品 B', icon: '💻' },
      {
        id: '2-3',
        label: '产品 C',
        icon: '🖥️',
        children: [
          { id: '2-3-1', label: '子产品 1', icon: '⌨️' },
          { id: '2-3-2', label: '子产品 2', icon: '🖱️' },
          {
            id: '2-3-3',
            label: '子产品 3',
            icon: '🎮',
            children: [
              { id: '2-3-3-1', label: '深层菜单 1', icon: '🎯' },
              { id: '2-3-3-2', label: '深层菜单 2', icon: '🎪' },
            ],
          },
        ],
      },
    ],
  },
  {
    id: '3',
    label: '服务',
    icon: '🛠️',
    children: [
      { id: '3-1', label: '咨询服务', icon: '💼' },
      { id: '3-2', label: '技术支持', icon: '🔧' },
      { id: '3-3', label: '培训服务', icon: '📚' },
    ],
  },
  {
    id: '4',
    label: '文档',
    icon: '📄',
    children: [
      { id: '4-1', label: '快速开始', icon: '🚀' },
      { id: '4-2', label: 'API 文档', icon: '📖' },
      { id: '4-3', label: '示例代码', icon: '💡' },
    ],
  },
  {
    id: '5',
    label: '关于',
    icon: 'ℹ️',
  },
])

// 事件处理
const addEvent = (type: string, item?: LMenuItem) => {
  events.value.unshift({
    type,
    label: item?.label || '-',
    time: new Date().toLocaleTimeString(),
  })
  if (events.value.length > 10) {
    events.value.pop()
  }
}

const handleSelect = (item: LMenuItem) => {
  selectedItem.value = item
  addEvent('select', item)
}

const handleExpand = (item: LMenuItem) => {
  addEvent('expand', item)
}

const handleCollapse = (item: LMenuItem) => {
  addEvent('collapse', item)
}

// 代码示例
const codeExample = computed(() => `
<template>
  <Menu
    :items="menuItems"
    mode="${mode.value}"
    theme="${theme.value}"
    ${collapsed.value ? ':collapsed="true"' : ''}
    submenu-trigger="${submenuTrigger.value}"
    ${!animation.value ? ':animation="false"' : ''}
    @select="handleSelect"
  />
</template>

<script setup>
import { Menu } from '@ldesign/menu/vue'
import '@ldesign/menu/es/styles/index.css'

const menuItems = [
  {
    id: '1',
    label: '首页',
    icon: '🏠',
  },
  {
    id: '2',
    label: '产品',
    icon: '📦',
    children: [...]
  },
  // ...
]

const handleSelect = (item) => {
  console.log('Selected:', item)
}
<\/script>
`.trim())
</script>

<style scoped>
.menu-demo-container {
  padding: var(--size-spacing-2xl);
  max-width: 1400px;
  margin: 0 auto;
}

.demo-title {
  font-size: var(--size-font-2xl);
  font-weight: var(--size-font-weight-bold);
  margin-bottom: var(--size-spacing-md);
  color: var(--color-text-primary);
}

.demo-description {
  color: var(--color-text-secondary);
  margin-bottom: var(--size-spacing-2xl);
}

.control-panel {
  background: var(--color-bg-container);
  padding: var(--size-spacing-xl);
  border-radius: var(--size-radius-lg);
  margin-bottom: var(--size-spacing-2xl);
  box-shadow: var(--shadow-sm);
}

.control-group {
  display: flex;
  align-items: center;
  gap: var(--size-spacing-md);
  margin-bottom: var(--size-spacing-lg);
}

.control-group:last-child {
  margin-bottom: 0;
}

.control-group label {
  min-width: 120px;
  font-weight: var(--size-font-weight-medium);
  color: var(--color-text-primary);
}

.control-btn {
  padding: var(--size-spacing-sm) var(--size-spacing-lg);
  border: 1px solid var(--color-border);
  background: var(--color-bg-container);
  border-radius: var(--size-radius-md);
  cursor: pointer;
  transition: all var(--size-duration-normal);
  color: var(--color-text-secondary);
}

.control-btn:hover {
  border-color: var(--color-primary-default);
  color: var(--color-primary-default);
}

.control-btn.active {
  background: var(--color-primary-default);
  border-color: var(--color-primary-default);
  color: white;
}

.demo-area {
  display: flex;
  gap: var(--size-spacing-xl);
  margin-bottom: var(--size-spacing-2xl);
}

.demo-area.horizontal {
  flex-direction: column;
}

.menu-container {
  background: var(--color-bg-container);
  border-radius: var(--size-radius-lg);
  box-shadow: var(--shadow-md);
  overflow: hidden;
  transition: width var(--size-duration-normal);
}

.demo-area:not(.horizontal) .menu-container {
  width: 240px;
  height: 600px;
}

.demo-area:not(.horizontal) .menu-container.collapsed {
  width: 64px;
}

.demo-area.horizontal .menu-container {
  width: 100%;
  height: auto;
}

.demo-menu {
  height: 100%;
}

.info-panel {
  flex: 1;
  background: var(--color-bg-container);
  padding: var(--size-spacing-xl);
  border-radius: var(--size-radius-lg);
  box-shadow: var(--shadow-sm);
  overflow: auto;
  max-height: 600px;
}

.info-panel h3 {
  margin-bottom: var(--size-spacing-lg);
  color: var(--color-text-primary);
}

.info-panel h4 {
  margin-bottom: var(--size-spacing-sm);
  color: var(--color-text-secondary);
  font-size: var(--size-font-sm);
}

.info-item {
  margin-bottom: var(--size-spacing-xl);
}

.info-item pre {
  background: var(--color-bg-component);
  padding: var(--size-spacing-md);
  border-radius: var(--size-radius-sm);
  overflow: auto;
  font-size: var(--size-font-sm);
  color: var(--color-text-primary);
}

.event-list {
  list-style: none;
  padding: 0;
  margin: 0;
}

.event-item {
  display: flex;
  gap: var(--size-spacing-md);
  padding: var(--size-spacing-sm) 0;
  border-bottom: 1px solid var(--color-border-light);
  font-size: var(--size-font-sm);
}

.event-type {
  color: var(--color-primary-default);
  font-weight: var(--size-font-weight-medium);
  min-width: 60px;
}

.event-label {
  flex: 1;
  color: var(--color-text-primary);
}

.event-time {
  color: var(--color-text-tertiary);
  font-size: var(--size-font-xs);
}

.code-example {
  background: var(--color-bg-container);
  padding: var(--size-spacing-xl);
  border-radius: var(--size-radius-lg);
  box-shadow: var(--shadow-sm);
}

.code-example h3 {
  margin-bottom: var(--size-spacing-lg);
  color: var(--color-text-primary);
}

.code-example pre {
  background: var(--color-bg-component);
  padding: var(--size-spacing-lg);
  border-radius: var(--size-radius-md);
  overflow: auto;
  font-size: var(--size-font-sm);
  line-height: 1.6;
  color: var(--color-text-primary);
}

.code-example code {
  font-family: var(--size-font-family-mono);
}
</style>
