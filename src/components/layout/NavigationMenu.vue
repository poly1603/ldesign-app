<template>
  <div class="navigation-menu-wrapper">
    <Menu ref="menuRef" :items="lMenuItems" mode="vertical" :collapsed="collapsed" :theme="theme"
      :default-active-key="activeMenuKey" :default-expanded-keys="expandedKeys" submenu-trigger="inline"
      @select="handleMenuSelect" class="app-navigation-menu" />
  </div>
</template>

<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import { useRouter } from '@ldesign/router'
import { Menu } from '@ldesign/menu/vue'
import type { MenuItem as LMenuItem } from '@ldesign/menu'
import '@ldesign/menu/es/index.css'

export interface MenuItem {
  path: string
  label: string
  icon: string
  requiresAuth?: boolean
  children?: MenuItem[]
}

const props = withDefaults(defineProps<{
  items: MenuItem[]
  isLoggedIn?: boolean
  collapsed?: boolean
  theme?: 'light' | 'dark'
  currentPath?: string
}>(), {
  collapsed: false,
  theme: 'light',
})

const router = useRouter()
const menuRef = ref()

// 转换菜单项为 @ldesign/menu 格式
const lMenuItems = computed<LMenuItem[]>(() => {
  const convertItem = (item: MenuItem): LMenuItem | null => {
    // 如果需要认证但用户未登录，则不显示
    if (item.requiresAuth && !props.isLoggedIn) {
      return null
    }

    const menuItem: LMenuItem = {
      id: item.path,
      label: item.label,
      icon: item.icon,
      path: item.path,
    }

    // 递归处理子菜单
    if (item.children && item.children.length > 0) {
      const children = item.children
        .map(child => convertItem(child))
        .filter((child): child is LMenuItem => child !== null)

      if (children.length > 0) {
        menuItem.children = children
      }
    }

    return menuItem
  }

  return props.items
    .map(item => convertItem(item))
    .filter((item): item is LMenuItem => item !== null)
})

// 根据当前路径查找应该激活的菜单项
const activeMenuKey = computed(() => {
  if (!props.currentPath) return null

  // 查找完全匹配的路径
  const findMenuItemByPath = (items: MenuItem[], path: string): MenuItem | null => {
    for (const item of items) {
      if (item.path === path) {
        return item
      }
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

// 根据当前路径查找应该展开的父级菜单
const expandedKeys = computed(() => {
  if (!props.currentPath) return []

  const keys: string[] = []

  const findParentPaths = (items: MenuItem[], targetPath: string, parentPath?: string): boolean => {
    for (const item of items) {
      if (item.path === targetPath) {
        if (parentPath) {
          keys.push(parentPath)
        }
        return true
      }
      if (item.children) {
        const found = findParentPaths(item.children, targetPath, item.path)
        if (found) {
          if (parentPath) {
            keys.push(parentPath)
          }
          keys.push(item.path)
          return true
        }
      }
    }
    return false
  }

  findParentPaths(props.items, props.currentPath)
  return Array.from(new Set(keys)) // 去重
})

// 处理菜单选择 - 导航到对应路由
const handleMenuSelect = (item: LMenuItem) => {
  if (item.path) {
    router.push(item.path)
  }
}

// 监听当前路径变化，自动选中和展开对应菜单
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

<style scoped>
.navigation-menu-wrapper {
  height: 100%;
}

.app-navigation-menu {
  height: 100%;
}

/* 自定义菜单样式以匹配现有设计 */
:deep(.ldesign-menu-item__content) {
  border-left: var(--size-border-width-thick) solid transparent;
}

:deep(.ldesign-menu-item__content:hover) {
  border-left-color: var(--color-primary-default);
}

:deep(.ldesign-menu-item--active > .ldesign-menu-item__content) {
  border-left-color: var(--color-primary-default);
  font-weight: var(--size-font-weight-semibold);
}

:deep(.ldesign-menu-item__icon) {
  font-size: 1.2em;
}
</style>
