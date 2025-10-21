/**
 * 性能监控工具
 * 用于跟踪和报告关键性能指标
 */
export interface WebVitals {
    LCP?: number;
    FID?: number;
    CLS?: number;
    FCP?: number;
    TTFB?: number;
}
declare class PerformanceMonitor {
    private metrics;
    private reported;
    constructor();
    private observePerformance;
    private observePaint;
    private observeLCP;
    private observeCLS;
    private observeFID;
    private report;
    getMetrics(): WebVitals;
}
export declare const performanceMonitor: PerformanceMonitor;
export declare function markPerformance(name: string): void;
export declare function measurePerformance(name: string, startMark: string, endMark: string): void;
export {};
