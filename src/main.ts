/**
 * 应用入口
 * 极简启动，所有逻辑在 bootstrap 中处理
 */

// 性能标记 - 应用启动
if (typeof performance !== 'undefined') {
  performance.mark('app-start')
}

// 全局拦截警告和调试日志
if (typeof window !== 'undefined') {
  const originalWarn = console.warn.bind(console)
  console.warn = (...args: any[]) => {
    const message = args[0]
    if (typeof message === 'string') {
      // 拦截 Vue 警告
      if (message.startsWith('[Vue warn]')) {
        return
      }
      // 拦截 i18n 翻译警告
      if (message.includes('[@ldesign/i18n]') || message.includes('Missing translation')) {
        return
      }
    }
    originalWarn(...args)
  }

  const originalDebug = console.debug.bind(console)
  console.debug = (...args: any[]) => {
    const message = args[0]
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

// 注册 Service Worker（仅生产环境）
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

// 启动应用
async function main() {
  try {
    const { bootstrap } = await import('./bootstrap')
    const { showErrorPage } = await import('./bootstrap/error-handler')

    try {
      await bootstrap()
    } catch (error) {
      console.error('[ERROR] 应用启动失败:', error)
      showErrorPage(error as Error)
    }
  } catch (error) {
    console.error('[ERROR] 启动模块加载失败:', error)
  }
}

// 使用 requestIdleCallback 优化启动
if (typeof requestIdleCallback !== 'undefined') {
  requestIdleCallback(() => main(), { timeout: 100 })
} else {
  main()
}
