/**
 * 性能优化工具函数
 * 减少主线程工作，提升响应性
 */
/**
 * 防抖函数 - 延迟执行
 */
export declare function debounce<T extends (...args: any[]) => any>(func: T, wait: number): (...args: Parameters<T>) => void;
/**
 * 节流函数 - 限制执行频率
 */
export declare function throttle<T extends (...args: any[]) => any>(func: T, limit: number): (...args: Parameters<T>) => void;
/**
 * requestAnimationFrame 节流
 */
export declare function rafThrottle<T extends (...args: any[]) => any>(func: T): (...args: Parameters<T>) => void;
/**
 * 延迟执行 - 使用 requestIdleCallback
 */
export declare function runWhenIdle(callback: IdleRequestCallback, options?: IdleRequestOptions): number;
/**
 * 分片执行 - 将大任务分成小块
 */
export declare function chunk<T>(items: T[], processor: (item: T, index: number) => void | Promise<void>, chunkSize?: number): Promise<void>;
/**
 * 懒加载图片观察器
 */
export declare function createLazyImageObserver(): IntersectionObserver | null;
/**
 * 预加载关键资源
 */
export declare function preloadResource(href: string, as: string): void;
/**
 * 预连接到域名
 */
export declare function preconnect(url: string, crossorigin?: boolean): void;
/**
 * 内存优化 - 清理未使用的对象
 */
export declare function clearUnusedMemory(): void;
/**
 * 使用 Web Worker 执行计算密集型任务
 */
export declare function runInWorker<T>(fn: (...args: any[]) => T, ...args: any[]): Promise<T>;
