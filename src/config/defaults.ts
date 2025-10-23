/**
 * 默认配置
 * 系统默认配置，最低优先级
 */

export const defaults = {
  app: {
    name: 'LDesign Engine Demo',
    version: '1.0.0',
    description: 'LDesign Engine 完整功能演示应用',
    author: 'LDesign Team'
  },

  performance: {
    monitoring: true,
    sampleRate: 1.0,
    slowThreshold: 1000,
    trackMemory: true,
    trackFPS: true
  },

  cache: {
    enabled: true,
    maxSize: 150,
    defaultTTL: 5 * 60 * 1000,
    strategy: 'lru' as const
  },

  storage: {
    prefix: 'ldesign_',
    expire: 7 * 24 * 60 * 60 * 1000
  },

  theme: {
    primaryColor: '#667eea',
    mode: 'light' as 'light' | 'dark' | 'auto'
  },

  i18n: {
    locale: 'zh-CN',
    fallbackLocale: 'zh-CN',
    detectBrowserLanguage: true,
    persistLanguage: true,
    warnOnMissing: false
  },

  router: {
    mode: 'history' as const,
    base: '/',
    preset: 'spa' as const
  },

  api: {
    baseUrl: '/api',
    timeout: 30000,
    retries: 3
  }
} as const

