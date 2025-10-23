<template>
  <div class="app-container">
    <!-- 对于blank布局，只渲染路由内容 -->
    <template v-if="$route.meta?.layout === 'blank'">
      <RouterView :key="$route.fullPath" transition="fade" />
    </template>

    <!-- 默认布局 - 使用 TemplateRenderer 渲染 Dashboard 模板 -->
    <template v-else>
      <TemplateRenderer category="dashboard" :component-props="{
        title: t('app.name'),
        username: isLoggedIn ? username : t('common.guest'),
        stats: appStats
      }">

        <!-- Logo 插槽 - 自定义品牌 -->
        <template #logo>
          <div class="nav-brand">
            <Rocket class="logo" />
            <span class="brand-text">{{ t('app.name') }}</span>
          </div>
        </template>

        <!-- Header 右侧功能区插槽 -->
        <template #header-actions>
          <div class="header-actions">
            <!-- 语言切换器 -->
            <LanguageSwitcher />

            <!-- 主题模式切换器（亮/暗/跟随系统） -->
            <VueThemeModeSwitcher />

            <!-- 主题颜色切换器 -->
            <VueThemePicker />

            <!-- 尺寸管理器 -->
            <SizeSelector />

            <!-- 登录/用户菜单 -->
            <button v-if="!isLoggedIn" @click="goToLogin" class="nav-button login">
              {{ t('nav.login') }}
            </button>
            <div v-else class="user-menu">
              <span class="username-tag">{{ username }}</span>
              <button @click="logout" class="nav-button logout">
                {{ t('nav.logout') }}
              </button>
            </div>
          </div>
        </template>

        <!-- 侧边栏导航插槽 -->
        <template #sidebar>
          <nav class="custom-nav-menu">
            <RouterLink to="/" class="nav-item" :class="{ active: $route.path === '/' }">
              🏠 {{ t('nav.home') }}
            </RouterLink>
            <RouterLink to="/about" class="nav-item" :class="{ active: $route.path === '/about' }">
              ℹ️ {{ t('nav.about') }}
            </RouterLink>

            <div class="nav-divider">{{ t('nav.demos') }}</div>

            <RouterLink to="/crypto" class="nav-item" :class="{ active: $route.path === '/crypto' }">
              🔒 {{ t('nav.crypto') }}
            </RouterLink>
            <RouterLink to="/http" class="nav-item" :class="{ active: $route.path === '/http' }">
              🌐 {{ t('nav.http') }}
            </RouterLink>
            <RouterLink to="/api" class="nav-item" :class="{ active: $route.path === '/api' }">
              📡 {{ t('nav.api') }}
            </RouterLink>

            <div class="nav-divider">{{ t('nav.engineDemos') }}</div>

            <RouterLink to="/performance" class="nav-item" :class="{ active: $route.path === '/performance' }">
              ⚡ {{ t('nav.performance') }}
            </RouterLink>
            <RouterLink to="/state" class="nav-item" :class="{ active: $route.path === '/state' }">
              🔄 {{ t('nav.state') }}
            </RouterLink>
            <RouterLink to="/event" class="nav-item" :class="{ active: $route.path === '/event' }">
              📡 {{ t('nav.event') }}
            </RouterLink>
            <RouterLink to="/concurrency" class="nav-item" :class="{ active: $route.path === '/concurrency' }">
              ⚡ {{ t('nav.concurrency') }}
            </RouterLink>
            <RouterLink to="/plugin" class="nav-item" :class="{ active: $route.path === '/plugin' }">
              🔌 {{ t('nav.plugin') }}
            </RouterLink>

            <RouterLink v-if="isLoggedIn" to="/dashboard" class="nav-item"
              :class="{ active: $route.path === '/dashboard' }">
              📊 {{ t('nav.dashboard') }}
            </RouterLink>
          </nav>
        </template>

        <!-- 隐藏默认的统计卡片 -->
        <template #stats>
          <!-- 空的，不显示默认统计 -->
        </template>

        <!-- 默认插槽 - 主要内容 -->
        <template #default>
          <div class="page-content">
            <RouterView :key="$route.fullPath" transition="fade" />
          </div>

          <!-- 页脚 -->
          <footer class="custom-footer">
            <p>{{ t('app.copyright') }}</p>
          </footer>
        </template>
      </TemplateRenderer>
    </template>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted } from 'vue'
import { useRoute, useRouter, RouterView, RouterLink } from '@ldesign/router'
import { useI18n } from '../i18n'
import { auth } from '../shared/composables/useAuth'
import { TemplateRenderer } from '@ldesign/template'
import LanguageSwitcher from '../components/LanguageSwitcher.vue'
import { VueThemePicker, VueThemeModeSwitcher } from '@ldesign/color/vue'
import { SizeSelector } from '@ldesign/size/vue'
import { Rocket } from 'lucide-vue-next'

const route = useRoute()
const router = useRouter()
const { t } = useI18n()

// 使用认证模块的状态
const isLoggedIn = computed(() => auth.isLoggedIn.value)
const username = computed(() => auth.userInfo.value?.username || '')

// 应用统计数据（传递给 dashboard 模板）
const appStats = computed(() => ({
  visits: localStorage.getItem('visitCount') || '0',
  users: '1,234',
  orders: '567',
  revenue: '89,012'
}))

// 跳转到登录页
const goToLogin = () => {
  router.push('/login')
}

// 退出登录
const logout = async () => {
  const result = await auth.logout()

  if (result.success) {
    // 如果在需要认证的页面，跳转到首页
    if (route.meta?.requiresAuth) {
      await router.push('/')
    }
  }
}

onMounted(() => {
  // 初始化认证状态
  auth.initAuth()
})
</script>

<style scoped>
.app-container {
  min-height: 100vh;
  width: 100%;
}

/* Logo 和品牌样式 */
.nav-brand {
  display: flex;
  align-items: center;
  gap: var(--size-spacing-md);
}

.logo {
  width: var(--size-icon-large);
  height: var(--size-icon-large);
  color: var(--color-primary-default);
}

.brand-text {
  font-size: var(--size-font-xl);
  font-weight: var(--size-font-weight-semibold);
  color: var(--color-text-primary);
}

/* Header 右侧功能区 */
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

/* 自定义导航菜单 */
.custom-nav-menu {
  display: flex;
  flex-direction: column;
  padding: var(--size-spacing-xl) 0;
}

.nav-item {
  display: block;
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

.nav-divider {
  margin: var(--size-spacing-xl) var(--size-spacing-2xl) var(--size-spacing-md);
  padding-bottom: var(--size-spacing-md);
  font-size: var(--size-font-sm);
  font-weight: var(--size-font-weight-semibold);
  color: var(--color-text-tertiary);
  text-transform: uppercase;
  letter-spacing: var(--size-letter-normal);
  border-bottom: var(--size-border-width-thin) solid var(--color-border);
}

/* 页面内容 */
.page-content {
  width: 100%;
  min-height: 400px;
}

/* 自定义页脚 */
.custom-footer {
  margin-top: var(--size-spacing-4xl);
  padding: var(--size-spacing-xl);
  text-align: center;
  color: var(--color-text-tertiary);
  font-size: var(--size-font-base);
  border-top: var(--size-border-width-thin) solid var(--color-border);
}

.custom-footer p {
  margin: 0;
}

/* 过渡动画 */
.fade-enter-active,
.fade-leave-active {
  transition: opacity var(--size-duration-normal) ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>
