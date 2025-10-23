<template>
  <nav class="custom-nav-menu">
    <RouterLink v-for="item in menuItems" :key="item.path" :to="item.path" class="nav-item"
      :class="{ active: isActive(item.path) }">
      <span class="icon">{{ item.icon }}</span>
      {{ item.label }}
    </RouterLink>
  </nav>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useRoute, RouterLink } from '@ldesign/router'

export interface MenuItem {
  path: string
  label: string
  icon: string
  requiresAuth?: boolean
}

const props = defineProps<{
  items: MenuItem[]
  isLoggedIn?: boolean
}>()

const route = useRoute()

const menuItems = computed(() => {
  return props.items.filter(item => {
    // 如果需要认证但用户未登录，则不显示
    if (item.requiresAuth && !props.isLoggedIn) {
      return false
    }
    return true
  })
})

const isActive = (path: string) => {
  return route.path === path
}
</script>

<style scoped>
.custom-nav-menu {
  display: flex;
  flex-direction: column;
  padding: var(--size-spacing-xl) 0;
}

.nav-item {
  display: flex;
  align-items: center;
  gap: var(--size-spacing-md);
  padding: var(--size-spacing-lg) var(--size-spacing-2xl);
  color: var(--color-text-secondary);
  text-decoration: none;
  transition: all var(--size-duration-normal);
  border-left: var(--size-border-width-thick) solid transparent;
  font-size: var(--size-font-base);
}

.nav-item:hover {
  color: var(--color-primary-default);
  background: var(--color-bg-component);
  border-left-color: var(--color-primary-default);
}

.nav-item.active {
  color: var(--color-primary-default);
  background: var(--color-bg-component);
  border-left-color: var(--color-primary-default);
  font-weight: var(--size-font-weight-semibold);
}

.icon {
  font-size: 1.2em;
  line-height: 1;
}
</style>
