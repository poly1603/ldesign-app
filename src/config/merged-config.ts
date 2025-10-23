/**
 * 配置合并
 * 按优先级合并：运行时 > 环境变量 > 默认配置
 */

import { defaults } from './defaults'
import { environment } from './environment'
import { runtime } from './runtime'

/**
 * 深度合并对象
 */
function deepMerge<T extends Record<string, any>>(
  target: T,
  ...sources: Partial<T>[]
): T {
  if (!sources.length) return target

  const source = sources.shift()
  if (!source) return target

  for (const key in source) {
    const sourceValue = source[key]
    const targetValue = target[key]

    if (sourceValue && typeof sourceValue === 'object' && !Array.isArray(sourceValue)) {
      if (!targetValue || typeof targetValue !== 'object') {
        target[key] = {} as any
      }
      deepMerge(target[key], sourceValue)
    } else if (sourceValue !== undefined) {
      target[key] = sourceValue as any
    }
  }

  return deepMerge(target, ...sources)
}

/**
 * 合并所有配置
 */
export const config = deepMerge(
  { ...defaults },
  environment as any,
  runtime as any
)

/**
 * 导出合并后的配置
 */
export default config

/**
 * 获取配置值
 */
export function getConfig<K extends keyof typeof config>(key: K): typeof config[K] {
  return config[key]
}

/**
 * 检查功能是否启用
 */
export function isFeatureEnabled(feature: string): boolean {
  const features = (config as any).features || environment.features
  return features[feature] ?? false
}

/**
 * 获取 API 配置
 */
export function getApiConfig() {
  return config.api
}

/**
 * 获取主题配置
 */
export function getThemeConfig() {
  return config.theme
}

/**
 * 获取缓存配置
 */
export function getCacheConfig() {
  return config.cache
}

