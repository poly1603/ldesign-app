/**
 * 事件管理器
 * 统一管理事件监听器，确保正确清理，防止内存泄漏
 */

type EventHandler = (...args: any[]) => void
type CleanupFunction = () => void

export class EventManager {
  private listeners: Set<CleanupFunction> = new Set()
  private namedListeners: Map<string, CleanupFunction> = new Map()

  /**
   * 添加 DOM 事件监听器
   */
  public on<K extends keyof WindowEventMap>(
    target: Window | Document | HTMLElement | EventTarget,
    event: K | string,
    handler: EventHandler,
    options?: boolean | AddEventListenerOptions
  ): void {
    target.addEventListener(event as string, handler, options)

    const cleanup = () => {
      target.removeEventListener(event as string, handler, options)
    }

    this.listeners.add(cleanup)
  }

  /**
   * 添加命名的事件监听器（可按名称删除）
   */
  public onNamed<K extends keyof WindowEventMap>(
    name: string,
    target: Window | Document | HTMLElement | EventTarget,
    event: K | string,
    handler: EventHandler,
    options?: boolean | AddEventListenerOptions
  ): void {
    // 如果已存在同名监听器，先删除
    this.offNamed(name)

    target.addEventListener(event as string, handler, options)

    const cleanup = () => {
      target.removeEventListener(event as string, handler, options)
    }

    this.namedListeners.set(name, cleanup)
  }

  /**
   * 删除命名的事件监听器
   */
  public offNamed(name: string): void {
    const cleanup = this.namedListeners.get(name)
    if (cleanup) {
      cleanup()
      this.namedListeners.delete(name)
    }
  }

  /**
   * 添加定时器
   */
  public setTimeout(handler: TimerHandler, timeout?: number): number {
    const timerId = window.setTimeout(handler, timeout)

    const cleanup = () => {
      window.clearTimeout(timerId)
    }

    this.listeners.add(cleanup)

    return timerId
  }

  /**
   * 添加间隔定时器
   */
  public setInterval(handler: TimerHandler, interval?: number): number {
    const timerId = window.setInterval(handler, interval)

    const cleanup = () => {
      window.clearInterval(timerId)
    }

    this.listeners.add(cleanup)

    return timerId
  }

  /**
   * 添加 requestAnimationFrame
   */
  public requestAnimationFrame(callback: FrameRequestCallback): number {
    const frameId = window.requestAnimationFrame(callback)

    const cleanup = () => {
      window.cancelAnimationFrame(frameId)
    }

    this.listeners.add(cleanup)

    return frameId
  }

  /**
   * 添加 IntersectionObserver
   */
  public observeIntersection(
    target: Element,
    callback: IntersectionObserverCallback,
    options?: IntersectionObserverInit
  ): IntersectionObserver {
    const observer = new IntersectionObserver(callback, options)
    observer.observe(target)

    const cleanup = () => {
      observer.disconnect()
    }

    this.listeners.add(cleanup)

    return observer
  }

  /**
   * 添加 ResizeObserver
   */
  public observeResize(
    target: Element,
    callback: ResizeObserverCallback
  ): ResizeObserver {
    const observer = new ResizeObserver(callback)
    observer.observe(target)

    const cleanup = () => {
      observer.disconnect()
    }

    this.listeners.add(cleanup)

    return observer
  }

  /**
   * 添加 MutationObserver
   */
  public observeMutation(
    target: Node,
    callback: MutationCallback,
    options?: MutationObserverInit
  ): MutationObserver {
    const observer = new MutationObserver(callback)
    observer.observe(target, options)

    const cleanup = () => {
      observer.disconnect()
    }

    this.listeners.add(cleanup)

    return observer
  }

  /**
   * 添加自定义清理函数
   */
  public addCleanup(cleanup: CleanupFunction): void {
    this.listeners.add(cleanup)
  }

  /**
   * 清理所有监听器
   */
  public cleanup(): void {
    // 清理所有匿名监听器
    this.listeners.forEach(cleanup => {
      try {
        cleanup()
      } catch (error) {
        console.error('Error during cleanup:', error)
      }
    })
    this.listeners.clear()

    // 清理所有命名监听器
    this.namedListeners.forEach(cleanup => {
      try {
        cleanup()
      } catch (error) {
        console.error('Error during cleanup:', error)
      }
    })
    this.namedListeners.clear()
  }

  /**
   * 获取监听器数量（用于调试）
   */
  public getListenerCount(): { anonymous: number; named: number; total: number } {
    return {
      anonymous: this.listeners.size,
      named: this.namedListeners.size,
      total: this.listeners.size + this.namedListeners.size
    }
  }
}

/**
 * 创建事件管理器实例
 * 通常在组件的 setup 函数中创建，并在 onBeforeUnmount 中清理
 */
export function createEventManager(): EventManager {
  return new EventManager()
}

/**
 * Vue 3 组合式函数：自动管理事件监听器
 */
import { onBeforeUnmount } from 'vue'

export function useEventManager(): EventManager {
  const manager = new EventManager()

  // 组件卸载前自动清理
  onBeforeUnmount(() => {
    manager.cleanup()
  })

  return manager
}

