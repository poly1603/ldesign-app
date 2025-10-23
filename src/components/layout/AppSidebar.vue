<template>
  <aside class="app-sidebar">
    <!-- 导航菜单 -->
    <NavigationMenu :items="menuItems" :is-logged-in="isLoggedIn" />
  </aside>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import NavigationMenu from './NavigationMenu.vue'
import type { MenuItem } from './NavigationMenu.vue'

const props = defineProps<{
  isLoggedIn: boolean
  t: (key: string) => string
}>()

const menuItems = computed<MenuItem[]>(() => [
  // 基础导航
  { path: '/', label: props.t('nav.home'), icon: '🏠' },
  { path: '/about', label: props.t('nav.about'), icon: 'ℹ️' },

  // 演示功能
  { path: '/crypto', label: props.t('nav.crypto'), icon: '🔒' },
  { path: '/http', label: props.t('nav.http'), icon: '🌐' },
  { path: '/api', label: props.t('nav.api'), icon: '📡' },

  // Engine 演示
  { path: '/performance', label: props.t('nav.performance'), icon: '⚡' },
  { path: '/state', label: props.t('nav.state'), icon: '🔄' },
  { path: '/event', label: props.t('nav.event'), icon: '📡' },
  { path: '/concurrency', label: props.t('nav.concurrency'), icon: '⚡' },
  { path: '/plugin', label: props.t('nav.plugin'), icon: '🔌' },

  // 需要登录的页面
  { path: '/dashboard', label: props.t('nav.dashboard'), icon: '📊', requiresAuth: true }
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
