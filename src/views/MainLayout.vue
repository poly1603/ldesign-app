<template>
  <div class="app-container">
    <!-- 对于blank布局，只渲染路由内容 -->
    <template v-if="route.meta?.layout === 'blank'">
      <RouterView :key="route.fullPath" transition="fade" />
    </template>

    <!-- 默认布局 - 使用 TemplateRenderer 渲染 Dashboard 模板 -->
    <template v-else>
      <div class="layout-wrapper">
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
            <AppSidebar :is-logged-in="isLoggedIn" :t="t" :current-path="route.path" />
          </template>

          <!-- 隐藏默认的统计卡片 -->
          <template #stats>
            <!-- 空的，不显示默认统计 -->
          </template>

          <!-- 默认插槽 - 主要内容 -->
          <template #default>
            <!-- 标签页容器 - 在内容区域顶部 -->
            <TabsContainer
              v-if="tabs.length > 0"
              :tabs="tabs"
              :active-tab-id="activeTabId"
              :enable-drag="true"
              :show-icon="true"
              :show-scroll-buttons="true"
              @tab-click="handleTabClick"
              @tab-close="handleTabClose"
              @tab-pin="handleTabPin"
              @tab-unpin="handleTabUnpin"
              @tab-reorder="handleTabReorder"
              @close-others="handleCloseOthers"
              @close-right="handleCloseRight"
              @close-left="handleCloseLeft"
              @close-all="handleCloseAll"
            />

            <div class="page-content">
              <RouterView :key="route.fullPath" transition="fade" />
            </div>

            <!-- 页脚 -->
            <AppFooter :copyright-text="t('app.copyright')" />
          </template>
        </TemplateRenderer>
      </div>
    </template>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { useRoute, useRouter, RouterView } from '@ldesign/router'
import { useI18n } from '../i18n'
import { auth } from '../shared/composables/useAuth'
import { TemplateRenderer } from '@ldesign/template'
import { TabsContainer, useTabs } from '@ldesign/tabs/vue'
import '@ldesign/tabs/es/styles/index.css'

// 所有组件使用同步加载，确保功能立即可用
import HeaderLogo from '../components/layout/HeaderLogo.vue'
import HeaderActions from '../components/layout/HeaderActions.vue'
import AppSidebar from '../components/layout/AppSidebar.vue'
import AppFooter from '../components/layout/AppFooter.vue'

const route = useRoute()
const router = useRouter()
const { t } = useI18n()

// 初始化标签页系统
const tabsInstance = useTabs({
  maxTabs: 10,
  persist: true,
  persistKey: 'ldesign-app-tabs',
  autoActivate: true,
  router: {
    autoSync: true,
    getTabTitle: (route: any) => {
      const titleKey = route.meta?.titleKey || route.meta?.title
      return titleKey ? t(titleKey as string) : route.path.split('/').filter(Boolean).pop() || t('nav.home')
    },
    getTabIcon: (route: any) => route.meta?.icon,
    shouldCreateTab: (route: any) => route.meta?.layout !== 'blank',
    shouldPinTab: (route: any) => route.path === '/',
  },
  shortcuts: {
    enabled: true,
  },
}, router)

const { tabs, activeTabId, activateTab, removeTab, pinTab, unpinTab, reorderTabs, closeOtherTabs, closeAllTabs, closeTabsToRight, closeTabsToLeft } = tabsInstance

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

// 标签页事件处理
const handleTabClick = (tab: any) => {
  activateTab(tab.id)
  router.push(tab.path)
}

const handleTabClose = (tab: any) => {
  removeTab(tab.id)
}

const handleTabPin = (tab: any) => {
  pinTab(tab.id)
}

const handleTabUnpin = (tab: any) => {
  unpinTab(tab.id)
}

const handleTabReorder = (fromIndex: number, toIndex: number) => {
  reorderTabs(fromIndex, toIndex)
}

const handleCloseOthers = (tab: any) => {
  closeOtherTabs(tab.id)
}

const handleCloseRight = (tab: any) => {
  closeTabsToRight(tab.id)
}

const handleCloseLeft = (tab: any) => {
  closeTabsToLeft(tab.id)
}

const handleCloseAll = () => {
  closeAllTabs()
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

.layout-wrapper {
  display: flex;
  flex-direction: column;
  min-height: 100vh;
}

.page-content {
  width: 100%;
  min-height: 400px;
  flex: 1;
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
