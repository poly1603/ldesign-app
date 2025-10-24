<template>
  <aside class="app-sidebar">
    <!-- 导航菜单 -->
    <NavigationMenu :items="menuItems" :is-logged-in="isLoggedIn" :current-path="currentPath" />
  </aside>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import NavigationMenu from './NavigationMenu.vue'
import type { MenuItem } from './NavigationMenu.vue'

const props = defineProps<{
  isLoggedIn: boolean
  t: (key: string) => string
  currentPath?: string
}>()

// 使用传入的 currentPath
const currentPath = computed(() => props.currentPath || '/')

// 多层级菜单结构
const menuItems = computed<MenuItem[]>(() => [
  // 基础导航
  {
    path: '/',
    label: props.t('nav.home'),
    icon: '🏠'
  },
  {
    path: '/about',
    label: props.t('nav.about'),
    icon: 'ℹ️'
  },

  // 功能演示（二级菜单）
  {
    path: '/demos',
    label: props.t('nav.demos'),
    icon: '🎯',
    children: [
      { path: '/crypto', label: props.t('nav.crypto'), icon: '🔒' },
      { path: '/http', label: props.t('nav.http'), icon: '🌐' },
      { path: '/api', label: props.t('nav.api'), icon: '📡' },
    ],
  },

  // Engine 演示（二级菜单）
  {
    path: '/engine',
    label: props.t('nav.engineDemos'),
    icon: '⚙️',
    children: [
      { path: '/performance', label: props.t('nav.performance'), icon: '⚡' },
      { path: '/state', label: props.t('nav.state'), icon: '🔄' },
      { path: '/event', label: props.t('nav.event'), icon: '📡' },
      { path: '/concurrency', label: props.t('nav.concurrency'), icon: '⚡' },
      { path: '/plugin', label: props.t('nav.plugin'), icon: '🔌' },
    ],
  },

  // 组件演示（二级菜单，带三级）
  {
    path: '/components',
    label: props.t('nav.componentDemos'),
    icon: '🧩',
    children: [
      { path: '/tabs', label: props.t('nav.tabs'), icon: '📑' },
      { path: '/menu', label: props.t('nav.menu'), icon: '📋' },
      // 可以添加更多组件演示
      {
        path: '/advanced',
        label: props.t('nav.advancedComponents'),
        icon: '🚀',
        children: [
          { path: '/tabs', label: props.t('nav.tabs') + ' (详细)', icon: '📑' },
          { path: '/menu', label: props.t('nav.menu') + ' (详细)', icon: '📋' },
        ],
      },
    ],
  },

  // 需要登录的页面
  {
    path: '/dashboard',
    label: props.t('nav.dashboard'),
    icon: '📊',
    requiresAuth: true
  },
])
</script>

<style scoped>
.app-sidebar {
  display: flex;
  flex-direction: column;
  height: 100%;
  overflow-y: auto;
}
</style>
