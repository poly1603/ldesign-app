/**
 * 增强的类型定义
 * 提供更好的类型安全和 IDE 智能提示
 */

/**
 * 统一的组件 Props 接口
 */
export interface EnhancedComponentProps<T = any> {
  /** 加载状态 */
  loading?: boolean
  /** 错误信息 */
  error?: Error | null
  /** 数据 */
  data?: T
  /** 是否禁用 */
  disabled?: boolean
}

/**
 * 缓存配置
 */
export interface CacheConfig {
  /** 是否启用缓存 */
  enabled: boolean
  /** 缓存策略 */
  strategy: 'lru' | 'lfu' | 'fifo'
  /** 最大缓存时间（毫秒） */
  maxAge: number
  /** 依赖项 */
  dependencies?: string[]
}

/**
 * 增强路由元信息
 */
declare module '@ldesign/router' {
  interface RouteMeta {
    /** 页面标题 */
    title?: string
    /** 国际化标题键 */
    titleKey?: string
    /** 是否需要认证 */
    requiresAuth?: boolean
    /** 所需角色 */
    roles?: string[]
    /** 布局类型 */
    layout?: 'default' | 'blank'
    /** 缓存配置 */
    cache?: boolean | CacheConfig
    /** 是否预加载 */
    preload?: boolean
    /** 页面图标 */
    icon?: string
    /** 是否在菜单中隐藏 */
    hideInMenu?: boolean
    /** 排序顺序 */
    order?: number
  }
}

/**
 * 存储项数据结构
 */
export interface StorageData<T = any> {
  /** 实际值 */
  value: T
  /** 时间戳 */
  timestamp: number
  /** 过期时间 */
  expire?: number
  /** 版本号 */
  version?: string
}

/**
 * 事件监听器选项
 */
export interface EventListenerOptions extends AddEventListenerOptions {
  /** 监听器名称（用于管理） */
  name?: string
  /** 优先级 */
  priority?: 'high' | 'normal' | 'low'
}

/**
 * 性能指标
 */
export interface PerformanceMetrics {
  /** First Contentful Paint */
  fcp?: number
  /** Largest Contentful Paint */
  lcp?: number
  /** First Input Delay */
  fid?: number
  /** Cumulative Layout Shift */
  cls?: number
  /** Time to First Byte */
  ttfb?: number
  /** 总阻塞时间 */
  tbt?: number
  /** 交互时间 */
  tti?: number
}

/**
 * 用户信息扩展
 */
declare module '@/types/user' {
  interface User {
    /** 用户偏好设置 */
    preferences?: {
      theme?: string
      locale?: string
      fontSize?: string
    }
    /** 最后登录时间 */
    lastLoginAt?: string
    /** 用户状态 */
    status?: 'active' | 'inactive' | 'banned'
  }
}

/**
 * 全局属性扩展
 */
declare module '@vue/runtime-core' {
  interface ComponentCustomProperties {
    /** 获取当前语言 */
    $getLocale: () => string
    /** 设置语言 */
    $setLocale: (locale: string) => void
    /** 缓存实例 */
    $cache?: any
  }
}

/**
 * API 响应包装
 */
export interface ApiResponse<T = any> {
  /** 是否成功 */
  success: boolean
  /** 数据 */
  data?: T
  /** 错误信息 */
  error?: string
  /** 错误代码 */
  code?: string | number
  /** 时间戳 */
  timestamp?: number
}

/**
 * 分页数据
 */
export interface PaginatedData<T = any> {
  /** 数据列表 */
  items: T[]
  /** 总数 */
  total: number
  /** 当前页 */
  page: number
  /** 每页数量 */
  pageSize: number
  /** 是否有下一页 */
  hasNext: boolean
}

/**
 * 表单验证规则
 */
export interface ValidationRule {
  /** 是否必填 */
  required?: boolean
  /** 最小长度 */
  minLength?: number
  /** 最大长度 */
  maxLength?: number
  /** 正则表达式 */
  pattern?: RegExp
  /** 自定义验证函数 */
  validator?: (value: any) => boolean | Promise<boolean>
  /** 错误消息 */
  message?: string
}

/**
 * 主题配置
 */
export interface ThemeConfig {
  /** 主题名称 */
  name: string
  /** 主题颜色 */
  primaryColor: string
  /** 模式 */
  mode: 'light' | 'dark' | 'auto'
  /** 自定义变量 */
  variables?: Record<string, string>
}

/**
 * 插件接口
 */
export interface Plugin {
  /** 插件名称 */
  name: string
  /** 插件版本 */
  version: string
  /** 安装函数 */
  install: (app: any, options?: any) => void | Promise<void>
  /** 卸载函数 */
  uninstall?: () => void | Promise<void>
  /** 依赖项 */
  dependencies?: string[]
}

/**
 * 导出所有类型
 */
export * from './user'

