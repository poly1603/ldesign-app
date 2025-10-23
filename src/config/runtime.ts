/**
 * 运行时配置
 * 支持动态更新，最高优先级
 */

import { reactive, readonly } from 'vue'
import type { DeepPartial } from '../types/utils'

export interface RuntimeConfig {
  // 性能配置
  performance: {
    monitoring: boolean
    sampleRate: number
    slowThreshold: number
  }

  // 缓存配置
  cache: {
    enabled: boolean
    maxSize: number
  }

  // 主题配置
  theme: {
    primaryColor: string
    mode: 'light' | 'dark' | 'auto'
  }

  // 调试配置
  debug: {
    showPerformanceMarks: boolean
    showStateChanges: boolean
    showRouteTransitions: boolean
  }

  // 实验性功能
  experimental: {
    virtualScroll: boolean
    webWorkers: boolean
    serviceWorker: boolean
  }
}

// 创建响应式运行时配置
const runtimeConfig = reactive<RuntimeConfig>({
  performance: {
    monitoring: true,
    sampleRate: 1.0,
    slowThreshold: 1000
  },

  cache: {
    enabled: true,
    maxSize: 150
  },

  theme: {
    primaryColor: '#667eea',
    mode: 'light'
  },

  debug: {
    showPerformanceMarks: false,
    showStateChanges: false,
    showRouteTransitions: false
  },

  experimental: {
    virtualScroll: false,
    webWorkers: false,
    serviceWorker: false
  }
})

/**
 * 更新运行时配置
 */
export function updateRuntimeConfig(updates: DeepPartial<RuntimeConfig>): void {
  Object.assign(runtimeConfig, updates)

  if (import.meta.env.DEV) {
    console.log('[Config] Runtime config updated:', updates)
  }

  // 触发配置变更事件
  if (typeof window !== 'undefined') {
    window.dispatchEvent(new CustomEvent('app:config-changed', {
      detail: { config: runtimeConfig, updates }
    }))
  }
}

/**
 * 重置运行时配置
 */
export function resetRuntimeConfig(): void {
  Object.keys(runtimeConfig).forEach(key => {
    delete (runtimeConfig as any)[key]
  })

  Object.assign(runtimeConfig, {
    performance: { monitoring: true, sampleRate: 1.0, slowThreshold: 1000 },
    cache: { enabled: true, maxSize: 150 },
    theme: { primaryColor: '#667eea', mode: 'light' },
    debug: { showPerformanceMarks: false, showStateChanges: false, showRouteTransitions: false },
    experimental: { virtualScroll: false, webWorkers: false, serviceWorker: false }
  })
}

/**
 * 导出只读配置（防止意外修改）
 */
export const runtime = readonly(runtimeConfig)

/**
 * 导出可变配置（用于 updateRuntimeConfig）
 */
export { runtimeConfig }

/**
 * Vue 组合式函数
 */
import { computed, watch } from 'vue'

export function useRuntimeConfig() {
  return {
    config: runtime,
    update: updateRuntimeConfig,
    reset: resetRuntimeConfig,

    // 便捷访问器
    performance: computed(() => runtime.performance),
    cache: computed(() => runtime.cache),
    theme: computed(() => runtime.theme),
    debug: computed(() => runtime.debug),
    experimental: computed(() => runtime.experimental)
  }
}

/**
 * 监听配置变化
 */
export function watchRuntimeConfig(
  callback: (config: RuntimeConfig, updates: DeepPartial<RuntimeConfig>) => void
): () => void {
  const handler = (event: CustomEvent) => {
    callback(event.detail.config, event.detail.updates)
  }

  if (typeof window !== 'undefined') {
    window.addEventListener('app:config-changed', handler as EventListener)

    return () => {
      window.removeEventListener('app:config-changed', handler as EventListener)
    }
  }

  return () => { }
}

