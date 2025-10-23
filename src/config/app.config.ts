/**
 * 应用统一配置文件
 * 整合所有配置到一个文件中，便于管理和维护
 */

import type { Ref } from 'vue'

// ==================== 基础配置 ====================

export const APP_NAME = 'LDesign Engine Demo'
export const APP_VERSION = '1.0.0'

/**
 * 应用基础配置
 */
export const appConfig = {
  name: APP_NAME,
  version: APP_VERSION,
  description: 'LDesign Engine 完整功能演示应用',
  author: 'LDesign Team',

  // 开发配置
  debug: import.meta.env.DEV,
  environment: import.meta.env.MODE,

  // API 配置
  api: {
    baseUrl: import.meta.env.VITE_API_BASE_URL || '/api',
    timeout: 30000,
    retries: 3
  },

  // 存储配置
  storage: {
    prefix: 'ldesign_',
    expire: 7 * 24 * 60 * 60 * 1000 // 7天
  },

  // 主题配置
  theme: {
    primaryColor: '#667eea',
    mode: 'light' as 'light' | 'dark'
  }
}

// ==================== Engine 配置 ====================

/**
 * 引擎核心配置
 */
export const engineConfig = {
  name: `${APP_NAME} Engine`,
  version: APP_VERSION,
  debug: appConfig.debug,
  environment: appConfig.environment,

  // 功能特性
  features: {
    enableHotReload: true,
    enableDevTools: import.meta.env.DEV,
    enablePerformanceMonitoring: true, // 启用性能监控
    enableErrorReporting: true,
    enableSecurityProtection: true,
    enableCaching: true,
    enableNotifications: true
  },

  // 日志配置
  logger: {
    enabled: import.meta.env.DEV,
    level: import.meta.env.DEV ? 'debug' : 'error',
    maxLogs: 1000,
    showTimestamp: true,
    showContext: true
  },

  // 缓存配置
  cache: {
    enabled: true,
    maxSize: 150, // 增加缓存大小从100到150
    defaultTTL: 5 * 60 * 1000, // 5分钟
    strategy: 'lru' as const, // 使用 LRU 策略
    // 智能TTL策略
    ttlByType: {
      templates: 10 * 60 * 1000, // 模板缓存10分钟
      locale: Infinity,           // 语言永久缓存
      routes: 5 * 60 * 1000,      // 路由缓存5分钟
      api: 2 * 60 * 1000,         // API缓存2分钟
      static: 30 * 60 * 1000      // 静态资源缓存30分钟
    }
  },

  // 性能监控
  performance: {
    enabled: true,
    sampleRate: 1.0, // 100% 采样（演示用）
    slowThreshold: 1000,
    trackMemory: true,
    trackFPS: true
  },

  // 状态管理
  state: {
    enableTimeTravel: true, // 启用时间旅行
    maxHistory: 50,
    persistence: {
      enabled: true,
      key: 'ldesign-state',
      storage: 'localStorage' as const
    }
  },

  // 事件系统
  events: {
    maxListeners: 100,
    enableDebug: import.meta.env.DEV,
    enableReplay: true,
    enablePersistence: false
  }
}

// ==================== 国际化配置 ====================

/**
 * i18n 配置
 */
export const i18nConfig = {
  locale: 'zh-CN',
  fallbackLocale: 'zh-CN',
  detectBrowserLanguage: true,
  persistLanguage: true,
  warnOnMissing: false // 禁用警告，保持控制台干净
}

// ==================== 路由配置 ====================

/**
 * 路由器配置
 */
export const routerConfig = {
  // 路由模式
  mode: 'history' as const,
  base: '/',

  // 预设配置
  preset: 'spa' as const,

  // 预加载配置
  preload: {
    enabled: true,
    strategy: 'hover' as const,
    delay: 200,
    threshold: 0.5
  },

  // 缓存配置
  cache: {
    enabled: true,
    maxSize: 20,
    strategy: 'memory' as const,
    ttl: 10 * 60 * 1000
  },

  // 动画配置
  animation: {
    enabled: true,
    type: 'fade' as const,
    duration: 300,
    easing: 'ease-in-out'
  },

  // 性能优化
  performance: {
    prefetch: true,
    prerender: false,
    lazyLoad: true
  },

  // 错误处理
  errorHandling: {
    redirect404: '/404',
    redirect403: '/403',
    redirect500: '/500'
  }
}

// ==================== Store 配置 ====================

/**
 * Store 配置
 */
export const storeConfig = {
  // 开发工具
  devtools: {
    enabled: import.meta.env.DEV
  },

  // 持久化配置
  persist: {
    enabled: true,
    key: 'ldesign-store',
    storage: localStorage,
    beforeRestore: (context: any) => {
      // 恢复前的处理
    },
    afterRestore: (context: any) => {
      // 恢复后的处理
    }
  },

  // 性能配置
  performance: {
    monitoring: import.meta.env.DEV,
    slowThreshold: 100
  },

  // 插件配置
  plugins: []
}

// ==================== 插件配置工厂 ====================

/**
 * Cache 插件配置工厂
 */
export const createCacheConfig = (localeRef: Ref<string>) => ({
  globalPropertyName: '$cache',
  defaultEngine: 'localStorage',
  defaultTTL: 24 * 60 * 60 * 1000, // 24小时
  namespace: 'ldesign-app',
  security: {
    encryption: {
      enabled: false
    },
    obfuscation: {
      enabled: false
    },
  },
  engines: {
    memory: {
      maxSize: 10 * 1024 * 1024 // 10MB
    },
    localStorage: {
      maxSize: 5 * 1024 * 1024 // 5MB
    }
  },
  version: {
    current: '1.0.0',
    compatibleVersions: ['1.0.0']
  }
})

/**
 * Color 插件配置工厂
 */
export const createColorConfig = (localeRef: Ref<string>) => ({
  locale: localeRef,
  prefix: 'ld',
  storageKey: 'ldesign-theme',
  persistence: true,
  presets: 'all' as const,
  autoApply: true,
  defaultTheme: 'blue',
  includeSemantics: true,
  includeGrays: true,
  customThemes: [
    {
      name: 'sunset',
      label: 'Sunset Orange',
      color: '#ff6b35',
      custom: true,
      order: 100
    },
    {
      name: 'forest',
      label: 'Forest Green',
      color: '#2d6a4f',
      custom: true,
      order: 101
    },
    {
      name: 'midnight',
      label: 'Midnight Blue',
      color: '#1a1b41',
      custom: true,
      order: 102
    },
    {
      name: 'lavender',
      label: 'Lavender Dream',
      color: '#9b59b6',
      custom: true,
      order: 103
    },
    {
      name: 'coral',
      label: 'Coral Reef',
      color: '#ff7f50',
      custom: true,
      order: 104
    }
  ],
  hooks: {
    afterChange: (theme: any) => {
      if (import.meta.env.DEV) {
        console.log('[Color] Theme changed:', theme)
      }
    }
  }
})

/**
 * Size 插件配置工厂
 */
export const createSizeConfig = (localeRef: Ref<string>) => ({
  locale: localeRef,
  storageKey: 'ldesign-size',
  defaultSize: 'default',
  presets: [
    {
      name: 'extra-compact',
      label: 'Extra Compact',
      description: 'Very high density for maximum content',
      baseSize: 12,
      category: 'high-density'
    },
    {
      name: 'extra-spacious',
      label: 'Extra Spacious',
      description: 'Very low density for enhanced readability',
      baseSize: 20,
      category: 'low-density'
    }
  ]
})

/**
 * Template 插件配置
 */
export const templateConfig = {
  // 基础配置
  autoInit: true,
  autoDetect: true,
  defaultDevice: 'desktop',

  // 缓存配置
  cache: {
    enabled: true,
    ttl: 600000, // 10分钟
    maxSize: 100
  },

  // 用户偏好持久化
  rememberPreferences: true,
  preferencesKey: 'app-template-prefs',

  // 预加载策略
  preload: false,
  preloadStrategy: 'lazy',

  // UI 配置
  ui: {
    defaultStyle: 'cards',
    display: {
      preview: true,
      description: true,
      metadata: true,
      aspectRatio: '3/2'
    },
    styleByCategory: {
      'login': 'cards',
      'dashboard': 'grid',
      'profile': 'list',
      'settings': 'compact'
    },
    features: {
      search: false,
      filter: false,
      groupBy: 'none'
    }
  },

  // 动画配置
  animation: {
    defaultAnimation: 'fade-slide',
    transitionMode: 'out-in',
    duration: 300,
    customAnimations: {
      'login/default->login/split': 'flip',
      'login/split->login/default': 'flip',
      'dashboard/default->dashboard/sidebar': 'slide',
      'dashboard/sidebar->dashboard/tabs': 'fade'
    },
    animationByCategory: {
      'login': 'scale',
      'dashboard': 'slide',
      'profile': 'fade',
      'settings': 'none'
    },
    animationByDevice: {
      'mobile': 'slide',
      'tablet': 'fade-slide',
      'desktop': 'fade'
    }
  },

  // 钩子函数
  hooks: {
    beforeLoad: async (templatePath: string) => {
      if (import.meta.env.DEV) {
        console.log(`[Template] Loading: ${templatePath}`)
      }
    },
    afterLoad: async (templatePath: string, component: any) => {
      if (import.meta.env.DEV) {
        console.log(`[Template] Loaded: ${templatePath}`, component)
      }
    },
    beforeTransition: (from: string, to: string) => {
      if (import.meta.env.DEV) {
        console.log(`[Template] Transition: ${from} -> ${to}`)
      }
    },
    afterTransition: (from: string, to: string) => {
      if (import.meta.env.DEV) {
        console.log(`[Template] Transitioned: ${from} -> ${to}`)
      }
    },
    onError: (error: Error) => {
      console.error('[Template] Error:', error)
    }
  },

  // 性能监控
  performance: import.meta.env.DEV
}
