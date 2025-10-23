<template>
  <div class="app-container">
    <!-- 对于blank布局，只渲染路由内容 -->
    <template v-if="$route.meta?.layout === 'blank'">
      <RouterView :key="$route.fullPath" transition="fade" />
    </template>

    <!-- 默认布局 - 使用 TemplateRenderer 渲染 Dashboard 模板 -->
    <template v-else>
      <TemplateRenderer category="dashboard" :name="currentTemplate || undefined" :component-props="templateProps"
        @device-change="handleDeviceChange" @template-change="handleTemplateSelect">
        <!-- Logo 插槽 -->
        <template #logo>
          <HeaderLogo :title="t('app.name')" />
        </template>

        <!-- Header 右侧功能区插槽 -->
        <template #header-actions>
          <HeaderActions :device="currentDevice" :current-template="currentTemplate" :is-logged-in="isLoggedIn"
            :username="username" :login-text="t('nav.login')" :logout-text="t('nav.logout')"
            @template-select="handleTemplateSelect" @login="goToLogin" @logout="handleLogout" />
        </template>

        <!-- 侧边栏导航插槽 -->
        <template #sidebar>
          <AppSidebar :is-logged-in="isLoggedIn" :t="t" />
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
          <AppFooter :copyright-text="t('app.copyright')" />
        </template>
      </TemplateRenderer>
    </template>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { useRoute, useRouter, RouterView } from '@ldesign/router'
import { useI18n } from '../i18n'
import { auth } from '../shared/composables/useAuth'
import { TemplateRenderer } from '@ldesign/template'

// 所有组件使用同步加载，确保功能立即可用
import HeaderLogo from '../components/layout/HeaderLogo.vue'
import HeaderActions from '../components/layout/HeaderActions.vue'
import AppSidebar from '../components/layout/AppSidebar.vue'
import AppFooter from '../components/layout/AppFooter.vue'

const route = useRoute()
const router = useRouter()
const { t } = useI18n()

// 模板选择器状态
const currentDevice = ref<'desktop' | 'mobile' | 'tablet'>('desktop')
const currentTemplate = ref<string>('')

// 使用认证模块的状态
const isLoggedIn = computed(() => auth.isLoggedIn.value)
const username = computed(() => auth.userInfo.value?.username || '')

// 应用统计数据（传递给 dashboard 模板）
const templateProps = computed(() => ({
  title: t('app.name'),
  username: isLoggedIn.value ? username.value : t('common.guest'),
  stats: {
    visits: localStorage.getItem('visitCount') || '0',
    users: '1,234',
    orders: '567',
    revenue: '89,012'
  }
}))

// 跳转到登录页
const goToLogin = () => {
  router.push('/login')
}

// 退出登录
const handleLogout = async () => {
  const result = await auth.logout()

  if (result.success) {
    // 如果在需要认证的页面，跳转到首页
    if (route.meta?.requiresAuth) {
      await router.push('/')
    }
  }
}

// 处理模板选择
const handleTemplateSelect = (templateName: string) => {
  currentTemplate.value = templateName
  localStorage.setItem('preferred-dashboard-template', templateName)
}

// 处理设备变化
const handleDeviceChange = (device: string) => {
  currentDevice.value = device as 'desktop' | 'mobile' | 'tablet'
}

// 初始化时恢复保存的模板偏好
const savedTemplate = localStorage.getItem('preferred-dashboard-template')
if (savedTemplate) {
  currentTemplate.value = savedTemplate
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

.page-content {
  width: 100%;
  min-height: 400px;
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
