/**
 * 应用入口
 * 性能优化版本 - 最小化启动时间
 */

// 性能标记 - 应用启动
if (typeof performance !== 'undefined') {
  performance.mark('app-start')
}

// 全局拦截警告和调试日志，保持控制台完全干净
// 优化：只在开发环境拦截，并缓存原始引用
if (typeof window !== 'undefined' && import.meta.env.DEV) {
  // 拦截 console.warn
  const originalWarn = console.warn.bind(console)
  console.warn = (...args: any[]) => {
    const message = args[0]
    if (typeof message === 'string' && message.startsWith('[Vue warn]')) {
      return
    }
    originalWarn(...args)
  }

  // 拦截 console.debug - 过滤 Vite 的调试消息
  const originalDebug = console.debug.bind(console)
  console.debug = (...args: any[]) => {
    const message = args[0]
    // 过滤 Vite 的连接消息
    if (typeof message === 'string' && (
      message.includes('[vite]') ||
      message.includes('connecting...') ||
      message.includes('connected.')
    )) {
      return
    }
    originalDebug(...args)
  }
}

import { auth } from './composables/useAuth'

// 注册 Service Worker（仅在生产环境）
if ('serviceWorker' in navigator && import.meta.env.PROD) {
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('/sw.js')
      .then((registration) => {
        console.log('SW registered:', registration)
      })
      .catch((err) => {
        console.log('SW registration failed:', err)
      })
  })
}

// 主启动函数
async function main() {
  try {
    // 初始化认证
    auth.initAuth()

    // 启动应用
    const { bootstrap } = await import('./bootstrap')
    const { showErrorPage } = await import('./bootstrap/error-handler')

    try {
      await bootstrap()
    } catch (error) {
      console.error('[ERROR] 应用启动失败:', error)
      showErrorPage(error as Error)
    }

    // 性能标记 - 应用就绪
    if (typeof performance !== 'undefined') {
      performance.mark('app-ready')
      try {
        performance.measure('app-boot-time', 'app-start', 'app-ready')
        const measure = performance.getEntriesByName('app-boot-time')[0]
        if (import.meta.env.DEV) {
          console.log(`[INFO] App boot time: ${Math.round(measure.duration)}ms`)
        }
      } catch (e) {
        // Ignore
      }
    }

    // 启动性能监控
    if (import.meta.env.DEV) {
      import('./utils/performance').then(({ performanceMonitor }) => {
        // 监控器已自动初始化
      })
    }
  } catch (error) {
    console.error('[ERROR] 启动失败:', error)
  }
}

// 启动 - 使用 requestIdleCallback 延迟非关键任务
if (typeof requestIdleCallback !== 'undefined') {
  requestIdleCallback(() => main(), { timeout: 100 })
} else {
  main()
}
