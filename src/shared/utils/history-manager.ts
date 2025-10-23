/**
 * 历史数据管理器
 * 限制历史数据量，防止内存无限增长
 */

export interface HistoryOptions {
  /** 最大历史记录数 */
  maxSize?: number
  /** 是否循环覆盖 */
  circular?: boolean
  /** 数据变更回调 */
  onChange?: (size: number) => void
}

export class HistoryManager<T> {
  private history: T[] = []
  private readonly maxSize: number
  private readonly circular: boolean
  private onChange?: (size: number) => void

  constructor(options: HistoryOptions = {}) {
    this.maxSize = options.maxSize || 100
    this.circular = options.circular ?? true
    this.onChange = options.onChange
  }

  /**
   * 添加历史记录
   */
  add(item: T): void {
    this.history.push(item)

    // 限制大小
    if (this.history.length > this.maxSize) {
      if (this.circular) {
        // 移除最旧的记录
        this.history.shift()
      } else {
        // 不允许添加更多
        this.history.pop()
      }
    }

    this.triggerChange()
  }

  /**
   * 批量添加
   */
  addAll(items: T[]): void {
    items.forEach(item => this.add(item))
  }

  /**
   * 获取所有历史记录
   */
  getAll(): T[] {
    return [...this.history]
  }

  /**
   * 获取最近 N 条记录
   */
  getRecent(count: number): T[] {
    return this.history.slice(-count)
  }

  /**
   * 获取最旧 N 条记录
   */
  getOldest(count: number): T[] {
    return this.history.slice(0, count)
  }

  /**
   * 获取指定范围的记录
   */
  getRange(start: number, end: number): T[] {
    return this.history.slice(start, end)
  }

  /**
   * 清空历史记录
   */
  clear(): void {
    this.history = []
    this.triggerChange()
  }

  /**
   * 移除最旧的 N 条记录
   */
  removeOldest(count: number): T[] {
    const removed = this.history.splice(0, count)
    this.triggerChange()
    return removed
  }

  /**
   * 移除最新的 N 条记录
   */
  removeRecent(count: number): T[] {
    const removed = this.history.splice(-count)
    this.triggerChange()
    return removed
  }

  /**
   * 获取历史记录数量
   */
  size(): number {
    return this.history.length
  }

  /**
   * 是否已满
   */
  isFull(): boolean {
    return this.history.length >= this.maxSize
  }

  /**
   * 是否为空
   */
  isEmpty(): boolean {
    return this.history.length === 0
  }

  /**
   * 获取剩余容量
   */
  remaining(): number {
    return this.maxSize - this.history.length
  }

  /**
   * 压缩历史记录（保留指定比例）
   */
  compact(ratio: number = 0.5): void {
    const targetSize = Math.floor(this.maxSize * ratio)
    if (this.history.length > targetSize) {
      // 保留最新的记录
      this.history = this.history.slice(-targetSize)
      this.triggerChange()
    }
  }

  /**
   * 触发变更回调
   */
  private triggerChange(): void {
    if (this.onChange) {
      this.onChange(this.history.length)
    }
  }

  /**
   * 统计信息
   */
  getStats(): {
    size: number
    maxSize: number
    usage: number
    remaining: number
  } {
    return {
      size: this.history.length,
      maxSize: this.maxSize,
      usage: (this.history.length / this.maxSize) * 100,
      remaining: this.remaining()
    }
  }
}

/**
 * 创建历史管理器
 */
export function createHistoryManager<T>(options?: HistoryOptions): HistoryManager<T> {
  return new HistoryManager<T>(options)
}

/**
 * Vue 组合式函数
 */
import { ref, computed, onBeforeUnmount } from 'vue'
import type { Ref, ComputedRef } from 'vue'

export function useHistoryManager<T>(options?: HistoryOptions): {
  history: ComputedRef<T[]>
  add: (item: T) => void
  clear: () => void
  getRecent: (count: number) => T[]
  size: ComputedRef<number>
  isFull: ComputedRef<boolean>
  stats: ComputedRef<ReturnType<HistoryManager<T>['getStats']>>
} {
  const manager = new HistoryManager<T>(options)
  const trigger = ref(0)

  const add = (item: T) => {
    manager.add(item)
    trigger.value++
  }

  const clear = () => {
    manager.clear()
    trigger.value++
  }

  const history = computed(() => {
    trigger.value // 触发响应式
    return manager.getAll()
  })

  const size = computed(() => {
    trigger.value
    return manager.size()
  })

  const isFull = computed(() => {
    trigger.value
    return manager.isFull()
  })

  const stats = computed(() => {
    trigger.value
    return manager.getStats()
  })

  // 组件卸载时自动清空（可选）
  onBeforeUnmount(() => {
    if (options?.maxSize && manager.size() > options.maxSize) {
      manager.compact(0.5)
    }
  })

  return {
    history,
    add,
    clear,
    getRecent: (count: number) => manager.getRecent(count),
    size,
    isFull,
    stats
  }
}

