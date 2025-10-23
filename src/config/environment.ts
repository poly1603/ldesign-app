/**
 * 环境变量配置
 * 从环境变量读取配置，覆盖默认配置
 */

export const environment = {
  // 从环境变量读取
  isDev: import.meta.env.DEV,
  isProd: import.meta.env.PROD,
  mode: import.meta.env.MODE,

  // API 配置
  api: {
    baseUrl: import.meta.env.VITE_API_BASE_URL || '/api',
    timeout: Number(import.meta.env.VITE_API_TIMEOUT) || 30000
  },

  // 功能开关
  features: {
    enableDevTools: import.meta.env.DEV,
    enablePerformanceMonitoring: import.meta.env.VITE_ENABLE_MONITORING !== 'false',
    enableHotReload: import.meta.env.DEV
  },

  // 日志配置
  logger: {
    enabled: import.meta.env.DEV,
    level: import.meta.env.VITE_LOG_LEVEL || (import.meta.env.DEV ? 'debug' : 'error')
  }
} as const

