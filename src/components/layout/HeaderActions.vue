<template>
  <div class="header-actions">
    <!-- 模板选择器 -->
    <TemplateSelector category="dashboard" :device="device" :current-template="currentTemplate"
      @select="$emit('template-select', $event)" />

    <!-- 语言切换器 -->
    <LanguageSwitcher />

    <!-- 主题模式切换器（亮/暗/跟随系统） -->
    <VueThemeModeSwitcher />

    <!-- 主题颜色切换器 -->
    <VueThemePicker />

    <!-- 尺寸管理器 -->
    <SizeSelector />

    <!-- 登录/用户菜单 -->
    <button v-if="!isLoggedIn" @click="$emit('login')" class="nav-button login">
      {{ loginText }}
    </button>
    <div v-else class="user-menu">
      <span class="username-tag">{{ username }}</span>
      <button @click="$emit('logout')" class="nav-button logout">
        {{ logoutText }}
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
// 所有组件使用同步导入，确保立即可用
import { TemplateSelector } from '@ldesign/template'
import LanguageSwitcher from '../LanguageSwitcher.vue'
import { VueThemePicker, VueThemeModeSwitcher } from '@ldesign/color/vue'
import { SizeSelector } from '@ldesign/size/vue'

defineProps<{
  device: 'desktop' | 'mobile' | 'tablet'
  currentTemplate: string
  isLoggedIn: boolean
  username: string
  loginText: string
  logoutText: string
}>()

defineEmits<{
  'template-select': [templateName: string]
  'login': []
  'logout': []
}>()
</script>

<style scoped>
.header-actions {
  display: flex;
  align-items: center;
  gap: var(--size-spacing-lg);
}

.nav-button {
  padding: var(--size-spacing-md) var(--size-spacing-xl);
  border: none;
  border-radius: var(--size-radius-md);
  font-size: var(--size-font-base);
  font-weight: var(--size-font-weight-semibold);
  cursor: pointer;
  transition: all var(--size-duration-normal);
}

.nav-button.login {
  background: linear-gradient(135deg, var(--color-primary-default) 0%, var(--color-primary-active) 100%);
  color: var(--color-text-inverse);
}

.nav-button.login:hover {
  transform: translateY(-2px);
  box-shadow: var(--shadow-lg);
}

.nav-button.logout {
  background: var(--color-danger-default);
  color: var(--color-text-inverse);
}

.nav-button.logout:hover {
  background: var(--color-danger-hover);
}

.user-menu {
  display: flex;
  align-items: center;
  gap: var(--size-spacing-md);
}

.username-tag {
  padding: var(--size-spacing-sm) var(--size-spacing-lg);
  background: color-mix(in srgb, var(--color-primary-default) 10%, transparent);
  color: var(--color-primary-default);
  border-radius: var(--size-radius-md);
  font-size: var(--size-font-base);
  font-weight: var(--size-font-weight-semibold);
}
</style>
