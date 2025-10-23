/**
 * 插件加载器
 * 支持按需加载和热重载
 */

export interface PluginMeta {
  name: string
  version: string
  dependencies?: string[]
  lazy?: boolean
}

export interface LoadedPlugin {
  meta: PluginMeta
  module: any
  instance?: any
  loadedAt: number
}

export class PluginLoader {
  private static instance: PluginLoader
  private plugins = new Map<string, LoadedPlugin>()
  private loading = new Set<string>()

  private constructor() {
    // 私有构造函数
  }

  public static getInstance(): PluginLoader {
    if (!PluginLoader.instance) {
      PluginLoader.instance = new PluginLoader()
    }
    return PluginLoader.instance
  }

  /**
   * 加载插件
   */
  async load(name: string, lazy = true): Promise<any> {
    // 已加载，直接返回
    if (this.plugins.has(name)) {
      return this.plugins.get(name)!.module
    }

    // 正在加载，等待
    if (this.loading.has(name)) {
      return this.waitForPlugin(name)
    }

    this.loading.add(name)

    try {
      // 动态导入插件
      const module = await import(`../../plugins/${name}`)
      const plugin = module.default || module

      const loadedPlugin: LoadedPlugin = {
        meta: {
          name,
          version: plugin.version || '1.0.0',
          dependencies: plugin.dependencies || [],
          lazy
        },
        module: plugin,
        loadedAt: Date.now()
      }

      this.plugins.set(name, loadedPlugin)

      if (import.meta.env.DEV) {
        console.log(`[PluginLoader] Loaded: ${name}`)
      }

      return plugin
    } catch (error) {
      console.error(`[PluginLoader] Failed to load plugin "${name}":`, error)
      throw error
    } finally {
      this.loading.delete(name)
    }
  }

  /**
   * 等待插件加载完成
   */
  private async waitForPlugin(name: string): Promise<any> {
    return new Promise((resolve, reject) => {
      const checkInterval = setInterval(() => {
        if (this.plugins.has(name)) {
          clearInterval(checkInterval)
          resolve(this.plugins.get(name)!.module)
        } else if (!this.loading.has(name)) {
          clearInterval(checkInterval)
          reject(new Error(`Plugin "${name}" failed to load`))
        }
      }, 50)

      // 超时处理
      setTimeout(() => {
        if (this.loading.has(name)) {
          clearInterval(checkInterval)
          reject(new Error(`Plugin "${name}" load timeout`))
        }
      }, 10000)
    })
  }

  /**
   * 卸载插件
   */
  async unload(name: string): Promise<void> {
    const plugin = this.plugins.get(name)

    if (!plugin) {
      console.warn(`[PluginLoader] Plugin "${name}" not found`)
      return
    }

    try {
      // 调用卸载方法
      if (plugin.module.uninstall) {
        await plugin.module.uninstall()
      }

      this.plugins.delete(name)

      if (import.meta.env.DEV) {
        console.log(`[PluginLoader] Unloaded: ${name}`)
      }
    } catch (error) {
      console.error(`[PluginLoader] Failed to unload plugin "${name}":`, error)
      throw error
    }
  }

  /**
   * 重载插件（热重载）
   */
  async reload(name: string): Promise<any> {
    await this.unload(name)
    return this.load(name, false)
  }

  /**
   * 批量加载插件
   */
  async loadAll(names: string[], parallel = true): Promise<any[]> {
    if (parallel) {
      return Promise.all(names.map(name => this.load(name)))
    } else {
      const results: any[] = []
      for (const name of names) {
        results.push(await this.load(name))
      }
      return results
    }
  }

  /**
   * 检查插件是否已加载
   */
  isLoaded(name: string): boolean {
    return this.plugins.has(name)
  }

  /**
   * 获取插件信息
   */
  getPlugin(name: string): LoadedPlugin | undefined {
    return this.plugins.get(name)
  }

  /**
   * 获取所有已加载的插件
   */
  getAllPlugins(): LoadedPlugin[] {
    return Array.from(this.plugins.values())
  }

  /**
   * 获取插件统计信息
   */
  getStats(): {
    total: number
    loaded: LoadedPlugin[]
    loading: string[]
  } {
    return {
      total: this.plugins.size,
      loaded: this.getAllPlugins(),
      loading: Array.from(this.loading)
    }
  }

  /**
   * 清空所有插件
   */
  async clearAll(): Promise<void> {
    const names = Array.from(this.plugins.keys())

    for (const name of names) {
      await this.unload(name)
    }
  }

  /**
   * 预加载插件
   */
  async preload(names: string[]): Promise<void> {
    // 使用 requestIdleCallback 在空闲时预加载
    if (typeof requestIdleCallback !== 'undefined') {
      requestIdleCallback(() => {
        this.loadAll(names, true).catch(error => {
          console.warn('[PluginLoader] Preload failed:', error)
        })
      })
    } else {
      setTimeout(() => {
        this.loadAll(names, true).catch(error => {
          console.warn('[PluginLoader] Preload failed:', error)
        })
      }, 1000)
    }
  }
}

// 导出单例实例
export const pluginLoader = PluginLoader.getInstance()

/**
 * Vue 组合式函数
 */
import { onMounted } from 'vue'

export function usePluginLoader(pluginName: string) {
  const plugin = ref<any>(null)
  const loading = ref(false)
  const error = ref<Error | null>(null)

  onMounted(async () => {
    loading.value = true
    error.value = null

    try {
      plugin.value = await pluginLoader.load(pluginName)
    } catch (err) {
      error.value = err as Error
      console.error(`Failed to load plugin "${pluginName}":`, err)
    } finally {
      loading.value = false
    }
  })

  return {
    plugin,
    loading,
    error,
    reload: () => pluginLoader.reload(pluginName)
  }
}

