/**
 * 应用启动引导模块
 * 统一管理应用的初始化和启动流程
 */

import { createEngineApp } from '@ldesign/engine'
import type { Engine } from '@ldesign/engine'
import App from '../App.vue'
import { createRouter } from '../router'
import { engineConfig } from '../config'
import { setupPlugins } from './plugins'
import { setupErrorHandling } from './error-handler'
import { auth } from '../shared/composables/useAuth'

/**
 * 应用启动函数
 * 统一的启动入口，负责所有初始化工作
 */
export async function bootstrap(): Promise<Engine> {
  try {
    // 1. 初始化认证状态
    auth.initAuth()

    // 2. 创建路由插件
    const routerPlugin = createRouter()

    // 3. 初始化其他插件
    const { i18nPlugin, vuePlugins, localeRef } = await setupPlugins()

    // 4. 创建并配置引擎应用
    const engine = await createEngineApp({
      // 根组件和挂载点
      rootComponent: App,
      mountElement: '#app',

      // 引擎配置
      config: engineConfig,

      // 注册 Engine 插件（只注册支持 Engine 的插件）
      plugins: [routerPlugin, i18nPlugin],

      // Vue 应用配置
      setupApp: async (vueApp) => {
        // 禁用 Vue 警告（保持控制台干净）
        vueApp.config.warnHandler = () => { /* 静默处理 */ }

        // 安装 i18n Vue 插件（必须先安装，才能使用翻译）
        if (i18nPlugin.setupVueApp) {
          i18nPlugin.setupVueApp(vueApp)
        }

        // 安装其他 Vue 插件
        vuePlugins.forEach(plugin => {
          vueApp.use(plugin)
        })

        // 提供全局响应式 locale
        vueApp.provide('locale', localeRef)
        vueApp.provide('app-locale', localeRef)

        // 设置全局语言切换方法
        vueApp.config.globalProperties.$getLocale = () => localeRef.value
        vueApp.config.globalProperties.$setLocale = (locale: string) => {
          localeRef.value = locale
        }

        // 开发环境：暴露实例到全局
        if (import.meta.env.DEV && typeof window !== 'undefined') {
          (window as any).__APP__ = vueApp
        }
      },

      // 错误处理
      onError: (error) => {
        console.error('❌ 应用错误:', error)
        setupErrorHandling(error)
      },

      // 引擎就绪回调
      onReady: (engine) => {
        try {
          // 同步 locale 到 engine state
          if (engine?.state) {
            engine.state.set('locale', localeRef.value)
          }

          // 开发环境：暴露引擎到全局
          if (import.meta.env.DEV && typeof window !== 'undefined') {
            (window as any).__ENGINE__ = engine;
            (window as any).__LOCALE__ = localeRef
          }

          // 启动性能监控
          if (engine?.performance && engineConfig.features.enablePerformanceMonitoring) {
            try {
              engine.performance.startMonitoring()
            } catch (e) {
              console.warn('性能监控启动失败:', e)
            }
          }

          console.log('✅ 应用启动成功')
        } catch (error) {
          console.error('onReady 回调错误:', error)
        }
      },

      // 应用挂载完成
      onMounted: () => {
        // 记录启动性能
        if (typeof performance !== 'undefined') {
          try {
            performance.mark('app-ready')
            performance.measure('app-boot-time', 'app-start', 'app-ready')
            const measure = performance.getEntriesByName('app-boot-time')[0]
            if (import.meta.env.DEV) {
              console.log(`⚡ 应用启动时间: ${Math.round(measure.duration)}ms`)
            }
          } catch (e) {
            // 忽略性能API错误
          }
        }
      }
    })

    return engine
  } catch (error) {
    console.error('❌ 应用启动失败:', error)
    throw error
  }
}
