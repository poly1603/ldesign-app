/**
 * StorageOptimizer - localStorage 批量操作优化器
 * 使用 requestIdleCallback 批量写入，减少主线程阻塞
 */

type RequestIdleCallbackHandle = number
type RequestIdleCallbackOptions = {
  timeout: number
}
type RequestIdleCallbackDeadline = {
  readonly didTimeout: boolean
  timeRemaining: () => number
}

// 兼容性处理
declare global {
  interface Window {
    requestIdleCallback: (
      callback: (deadline: RequestIdleCallbackDeadline) => void,
      opts?: RequestIdleCallbackOptions,
    ) => RequestIdleCallbackHandle
    cancelIdleCallback: (handle: RequestIdleCallbackHandle) => void
  }
}

export class StorageOptimizer {
  private static instance: StorageOptimizer
  private queue: Map<string, any> = new Map()
  private removeQueue: Set<string> = new Set()
  private timer: RequestIdleCallbackHandle | null = null
  private readonly FLUSH_TIMEOUT = 1000 // 1秒超时

  private constructor() {
    // 私有构造函数，强制使用单例
  }

  /**
   * 获取单例实例
   */
  public static getInstance(): StorageOptimizer {
    if (!StorageOptimizer.instance) {
      StorageOptimizer.instance = new StorageOptimizer()
    }
    return StorageOptimizer.instance
  }

  /**
   * 设置值（批量写入）
   */
  public set(key: string, value: any): void {
    // 从删除队列中移除（如果存在）
    this.removeQueue.delete(key)

    // 添加到写入队列
    this.queue.set(key, value)

    // 调度刷新
    this.scheduleFlush()
  }

  /**
   * 获取值（立即读取）
   */
  public get(key: string): any {
    // 优先从队列中获取
    if (this.queue.has(key)) {
      return this.queue.get(key)
    }

    // 如果在删除队列中，返回 null
    if (this.removeQueue.has(key)) {
      return null
    }

    // 从 localStorage 读取
    try {
      const item = localStorage.getItem(key)
      return item ? JSON.parse(item) : null
    } catch (error) {
      console.error(`Error reading from localStorage: ${key}`, error)
      return null
    }
  }

  /**
   * 删除值（延迟删除）
   */
  public remove(key: string): void {
    // 从写入队列中移除
    this.queue.delete(key)

    // 添加到删除队列
    this.removeQueue.add(key)

    // 调度刷新
    this.scheduleFlush()
  }

  /**
   * 清空所有
   */
  public clear(): void {
    this.queue.clear()
    this.removeQueue.clear()

    if (this.timer) {
      this.cancelFlush()
    }

    localStorage.clear()
  }

  /**
   * 立即刷新（同步写入）
   */
  public flushSync(): void {
    if (this.timer) {
      this.cancelFlush()
    }
    this.flush()
  }

  /**
   * 调度刷新
   */
  private scheduleFlush(): void {
    // 如果已经调度，跳过
    if (this.timer) return

    // 使用 requestIdleCallback 或 setTimeout
    if (typeof window !== 'undefined' && window.requestIdleCallback) {
      this.timer = window.requestIdleCallback(
        () => {
          this.flush()
          this.timer = null
        },
        { timeout: this.FLUSH_TIMEOUT }
      )
    } else {
      this.timer = setTimeout(() => {
        this.flush()
        this.timer = null
      }, this.FLUSH_TIMEOUT) as unknown as RequestIdleCallbackHandle
    }
  }

  /**
   * 取消刷新
   */
  private cancelFlush(): void {
    if (this.timer) {
      if (typeof window !== 'undefined' && window.cancelIdleCallback) {
        window.cancelIdleCallback(this.timer)
      } else {
        clearTimeout(this.timer as unknown as number)
      }
      this.timer = null
    }
  }

  /**
   * 执行刷新
   */
  private flush(): void {
    try {
      // 批量写入
      this.queue.forEach((value, key) => {
        try {
          localStorage.setItem(key, JSON.stringify(value))
        } catch (error) {
          console.error(`Error writing to localStorage: ${key}`, error)
        }
      })

      // 批量删除
      this.removeQueue.forEach(key => {
        try {
          localStorage.removeItem(key)
        } catch (error) {
          console.error(`Error removing from localStorage: ${key}`, error)
        }
      })

      // 清空队列
      this.queue.clear()
      this.removeQueue.clear()
    } catch (error) {
      console.error('Error flushing storage:', error)
    }
  }

  /**
   * 获取队列大小（用于监控）
   */
  public getQueueSize(): { writes: number; removes: number } {
    return {
      writes: this.queue.size,
      removes: this.removeQueue.size
    }
  }

  /**
   * 检查是否有待处理的操作
   */
  public hasPendingOperations(): boolean {
    return this.queue.size > 0 || this.removeQueue.size > 0
  }
}

// 导出单例实例
export const storageOptimizer = StorageOptimizer.getInstance()

// 在页面卸载时强制刷新
if (typeof window !== 'undefined') {
  window.addEventListener('beforeunload', () => {
    storageOptimizer.flushSync()
  })
}

