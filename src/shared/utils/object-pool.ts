/**
 * 对象池 - 复用对象减少内存分配和 GC 压力
 * 适用于频繁创建和销毁的对象
 */

export interface Poolable {
  /** 重置对象状态 */
  reset?(): void
}

export class ObjectPool<T extends Poolable> {
  private pool: T[] = []
  private readonly maxSize: number
  private createFn: () => T
  private resetFn?: (obj: T) => void
  private acquireCount = 0
  private releaseCount = 0

  constructor(
    createFn: () => T,
    options: {
      maxSize?: number
      resetFn?: (obj: T) => void
    } = {}
  ) {
    this.createFn = createFn
    this.maxSize = options.maxSize || 100
    this.resetFn = options.resetFn
  }

  /**
   * 从池中获取对象
   */
  acquire(): T {
    this.acquireCount++

    if (this.pool.length > 0) {
      const obj = this.pool.pop()!
      return obj
    }

    return this.createFn()
  }

  /**
   * 释放对象回池中
   */
  release(obj: T): void {
    this.releaseCount++

    // 达到最大容量，直接丢弃
    if (this.pool.length >= this.maxSize) {
      return
    }

    // 重置对象
    if (this.resetFn) {
      this.resetFn(obj)
    } else if (obj.reset) {
      obj.reset()
    }

    this.pool.push(obj)
  }

  /**
   * 批量释放
   */
  releaseAll(objects: T[]): void {
    objects.forEach(obj => this.release(obj))
  }

  /**
   * 清空池
   */
  clear(): void {
    this.pool = []
  }

  /**
   * 获取池的统计信息
   */
  getStats(): {
    poolSize: number
    maxSize: number
    acquireCount: number
    releaseCount: number
    hitRate: number
  } {
    return {
      poolSize: this.pool.length,
      maxSize: this.maxSize,
      acquireCount: this.acquireCount,
      releaseCount: this.releaseCount,
      hitRate: this.acquireCount > 0
        ? (this.releaseCount / this.acquireCount) * 100
        : 0
    }
  }

  /**
   * 预填充池
   */
  prefill(count: number): void {
    for (let i = 0; i < Math.min(count, this.maxSize); i++) {
      this.pool.push(this.createFn())
    }
  }
}

/**
 * 创建对象池
 */
export function createObjectPool<T extends Poolable>(
  createFn: () => T,
  options?: {
    maxSize?: number
    resetFn?: (obj: T) => void
    prefill?: number
  }
): ObjectPool<T> {
  const pool = new ObjectPool(createFn, options)

  if (options?.prefill) {
    pool.prefill(options.prefill)
  }

  return pool
}

/**
 * 常用对象池示例
 */

// 数组对象池
export const arrayPool = createObjectPool<any[]>(
  () => [],
  {
    maxSize: 50,
    resetFn: (arr) => {
      arr.length = 0
    },
    prefill: 10
  }
)

// 对象池
export const objectPool = createObjectPool<Record<string, any>>(
  () => ({}),
  {
    maxSize: 50,
    resetFn: (obj) => {
      Object.keys(obj).forEach(key => delete obj[key])
    },
    prefill: 10
  }
)

// Set 对象池
export const setPool = createObjectPool<Set<any>>(
  () => new Set(),
  {
    maxSize: 30,
    resetFn: (set) => {
      set.clear()
    },
    prefill: 5
  }
)

// Map 对象池
export const mapPool = createObjectPool<Map<any, any>>(
  () => new Map(),
  {
    maxSize: 30,
    resetFn: (map) => {
      map.clear()
    },
    prefill: 5
  }
)

