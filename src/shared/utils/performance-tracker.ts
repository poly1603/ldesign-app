/**
 * 性能追踪器
 * 自动追踪组件渲染、用户交互和页面性能
 */

import type { PerformanceMetrics } from '../../types/enhanced'

export class PerformanceTracker {
  private static instance: PerformanceTracker
  private marks: Map<string, number> = new Map()
  private measures: Map<string, number> = new Map()
  private interactions: Array<{ action: string; timestamp: number; metadata?: any }> = []
  private readonly MAX_INTERACTIONS = 100

  private constructor() {
    // 私有构造函数
  }

  public static getInstance(): PerformanceTracker {
    if (!PerformanceTracker.instance) {
      PerformanceTracker.instance = new PerformanceTracker()
    }
    return PerformanceTracker.instance
  }

  /**
   * 追踪组件渲染时间
   */
  public trackComponent(name: string): () => void {
    const startMark = `${name}-start`
    const endMark = `${name}-end`

    if (typeof performance !== 'undefined') {
      performance.mark(startMark)
      this.marks.set(name, performance.now())
    }

    return () => {
      if (typeof performance !== 'undefined') {
        performance.mark(endMark)

        try {
          performance.measure(name, startMark, endMark)
          const entries = performance.getEntriesByName(name, 'measure')

          if (entries.length > 0) {
            const duration = entries[entries.length - 1].duration
            this.measures.set(name, duration)

            if (import.meta.env.DEV) {
              console.log(`[Performance] ${name}: ${duration.toFixed(2)}ms`)
            }
          }
        } catch (error) {
          console.warn('Performance measure failed:', error)
        }
      }
    }
  }

  /**
   * 追踪用户交互
   */
  public trackInteraction(action: string, metadata?: any): void {
    const interaction = {
      action,
      timestamp: Date.now(),
      metadata
    }

    this.interactions.push(interaction)

    // 限制数组大小
    if (this.interactions.length > this.MAX_INTERACTIONS) {
      this.interactions.shift()
    }

    if (import.meta.env.DEV) {
      console.log('[Interaction]', action, metadata)
    }
  }

  /**
   * 获取核心 Web 指标
   */
  public getCoreWebVitals(): PerformanceMetrics {
    const metrics: PerformanceMetrics = {}

    if (typeof performance === 'undefined') {
      return metrics
    }

    try {
      // FCP - First Contentful Paint
      const fcpEntry = performance.getEntriesByName('first-contentful-paint')[0]
      if (fcpEntry) {
        metrics.fcp = fcpEntry.startTime
      }

      // LCP - Largest Contentful Paint  
      const lcpEntries = performance.getEntriesByType('largest-contentful-paint')
      if (lcpEntries.length > 0) {
        metrics.lcp = lcpEntries[lcpEntries.length - 1].startTime
      }

      // FID - First Input Delay
      const fidEntries = performance.getEntriesByType('first-input')
      if (fidEntries.length > 0) {
        const fidEntry = fidEntries[0] as any
        metrics.fid = fidEntry.processingStart - fidEntry.startTime
      }

      // CLS - Cumulative Layout Shift
      let clsScore = 0
      const clsEntries = performance.getEntriesByType('layout-shift')
      clsEntries.forEach((entry: any) => {
        if (!entry.hadRecentInput) {
          clsScore += entry.value
        }
      })
      metrics.cls = clsScore

      // TTFB - Time to First Byte
      const navigationEntry = performance.getEntriesByType('navigation')[0] as any
      if (navigationEntry) {
        metrics.ttfb = navigationEntry.responseStart - navigationEntry.requestStart
      }
    } catch (error) {
      console.warn('Failed to get core web vitals:', error)
    }

    return metrics
  }

  /**
   * 生成性能报告
   */
  public generateReport(): {
    webVitals: PerformanceMetrics
    components: Record<string, number>
    interactions: Array<{ action: string; timestamp: number; metadata?: any }>
    summary: {
      totalMeasures: number
      totalInteractions: number
      avgComponentTime: number
    }
  } {
    const webVitals = this.getCoreWebVitals()
    const components: Record<string, number> = {}

    this.measures.forEach((duration, name) => {
      components[name] = duration
    })

    const avgComponentTime = this.measures.size > 0
      ? Array.from(this.measures.values()).reduce((a, b) => a + b, 0) / this.measures.size
      : 0

    return {
      webVitals,
      components,
      interactions: [...this.interactions],
      summary: {
        totalMeasures: this.measures.size,
        totalInteractions: this.interactions.length,
        avgComponentTime
      }
    }
  }

  /**
   * 导出报告为 JSON
   */
  public exportReport(): string {
    return JSON.stringify(this.generateReport(), null, 2)
  }

  /**
   * 清除所有数据
   */
  public clear(): void {
    this.marks.clear()
    this.measures.clear()
    this.interactions = []

    if (typeof performance !== 'undefined') {
      performance.clearMarks()
      performance.clearMeasures()
    }
  }

  /**
   * 获取特定组件的性能数据
   */
  public getComponentMetric(name: string): number | undefined {
    return this.measures.get(name)
  }

  /**
   * 获取所有交互记录
   */
  public getInteractions(): Array<{ action: string; timestamp: number; metadata?: any }> {
    return [...this.interactions]
  }

  /**
   * 监听性能指标变化
   */
  public observePerformance(callback: (entry: PerformanceEntry) => void): void {
    if (typeof PerformanceObserver === 'undefined') {
      return
    }

    try {
      const observer = new PerformanceObserver((list) => {
        list.getEntries().forEach(callback)
      })

      // 观察各种性能指标
      observer.observe({
        entryTypes: [
          'measure',
          'navigation',
          'resource',
          'paint',
          'largest-contentful-paint',
          'first-input',
          'layout-shift'
        ]
      })
    } catch (error) {
      console.warn('PerformanceObserver not supported:', error)
    }
  }

  /**
   * 记录自定义性能标记
   */
  public mark(name: string): void {
    if (typeof performance !== 'undefined') {
      performance.mark(name)
      this.marks.set(name, performance.now())
    }
  }

  /**
   * 测量两个标记之间的时间
   */
  public measure(name: string, startMark: string, endMark?: string): number | undefined {
    if (typeof performance === 'undefined') {
      return undefined
    }

    try {
      performance.measure(name, startMark, endMark)
      const entries = performance.getEntriesByName(name, 'measure')

      if (entries.length > 0) {
        const duration = entries[entries.length - 1].duration
        this.measures.set(name, duration)
        return duration
      }
    } catch (error) {
      console.warn('Performance measure failed:', error)
    }

    return undefined
  }
}

// 导出单例实例
export const performanceTracker = PerformanceTracker.getInstance()

// Vue 组合式函数
import { onMounted, onUnmounted } from 'vue'

export function usePerformanceTracker(componentName: string) {
  let endTrack: (() => void) | null = null

  onMounted(() => {
    endTrack = performanceTracker.trackComponent(componentName)
  })

  onUnmounted(() => {
    if (endTrack) {
      endTrack()
    }
  })

  return {
    tracker: performanceTracker,
    trackInteraction: performanceTracker.trackInteraction.bind(performanceTracker),
    mark: performanceTracker.mark.bind(performanceTracker),
    measure: performanceTracker.measure.bind(performanceTracker)
  }
}

