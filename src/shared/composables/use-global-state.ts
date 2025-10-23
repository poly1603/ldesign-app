/**
 * 全局状态管理
 * 支持自动持久化和跨标签同步
 */

import { ref, watch, onUnmounted } from 'vue'
import type { Ref } from 'vue'
import { storageOptimizer } from '../utils/storage-optimizer'

export interface GlobalStateOptions<T> {
  /** 存储键名 */
  key: string
  /** 初始值 */
  initialValue: T
  /** 是否持久化 */
  persist?: boolean
  /** 是否跨标签同步 */
  syncTabs?: boolean
  /** 自定义序列化 */
  serializer?: {
    read: (raw: string) => T
    write: (value: T) => string
  }
  /** 值变化回调 */
  onChange?: (value: T, oldValue: T) => void
}

/**
 * 创建全局状态
 */
export function createGlobalState<T>(options: GlobalStateOptions<T>): Ref<T> {
  const {
    key,
    initialValue,
    persist = true,
    syncTabs = true,
    serializer = {
      read: (raw) => JSON.parse(raw),
      write: (value) => JSON.stringify(value)
    },
    onChange
  } = options

  // 从持久化存储恢复状态
  let storedValue = initialValue
  if (persist) {
    try {
      const raw = storageOptimizer.get(key)
      if (raw !== null && raw !== undefined) {
        storedValue = serializer.read(raw)
      }
    } catch (error) {
      console.warn(`Failed to read persisted state for key "${key}":`, error)
    }
  }

  // 创建响应式状态
  const state = ref<T>(storedValue) as Ref<T>

  // 监听状态变化并持久化
  if (persist) {
    watch(
      state,
      (newValue, oldValue) => {
        try {
          storageOptimizer.set(key, serializer.write(newValue))

          if (onChange) {
            onChange(newValue, oldValue)
          }
        } catch (error) {
          console.warn(`Failed to persist state for key "${key}":`, error)
        }
      },
      { deep: true }
    )
  }

  // 跨标签同步
  if (syncTabs && typeof window !== 'undefined') {
    const handleStorageChange = (event: StorageEvent) => {
      if (event.key === key && event.newValue !== null) {
        try {
          const newValue = serializer.read(event.newValue)
          state.value = newValue
        } catch (error) {
          console.warn(`Failed to sync state from another tab for key "${key}":`, error)
        }
      }
    }

    window.addEventListener('storage', handleStorageChange)

    // 清理函数（在 Vue 3 中，ref 不会自动清理，需要手动处理）
    if (typeof window !== 'undefined') {
      // 使用 FinalizationRegistry 或在适当时机手动清理
      const cleanup = () => {
        window.removeEventListener('storage', handleStorageChange)
      }

        // 导出清理函数供外部使用
        ; (state as any).__cleanup = cleanup
    }
  }

  return state
}

/**
 * Vue 组合式函数版本（自动清理）
 */
export function useGlobalState<T>(options: GlobalStateOptions<T>): Ref<T> {
  const state = createGlobalState(options)

  // 组件卸载时清理
  onUnmounted(() => {
    if ((state as any).__cleanup) {
      (state as any).__cleanup()
    }
  })

  return state
}

/**
 * 预定义的全局状态
 */

// 主题状态
export const useThemeState = () => {
  return useGlobalState({
    key: 'app-theme',
    initialValue: 'light' as 'light' | 'dark' | 'auto',
    persist: true,
    syncTabs: true
  })
}

// 语言状态
export const useLocaleState = () => {
  return useGlobalState({
    key: 'app-locale',
    initialValue: 'zh-CN',
    persist: true,
    syncTabs: true
  })
}

// 用户偏好
export const usePreferencesState = () => {
  return useGlobalState({
    key: 'app-preferences',
    initialValue: {
      sidebarCollapsed: false,
      fontSize: 'default',
      animations: true
    },
    persist: true,
    syncTabs: true
  })
}

/**
 * 批量清理全局状态
 */
export function cleanupGlobalStates(): void {
  if (typeof window !== 'undefined') {
    // 强制刷新所有待写入的状态
    storageOptimizer.flushSync()
  }
}

