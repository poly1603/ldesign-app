/**
 * LDesign Simple App - Library Export
 *
 * 导出可重用的工具函数和类型定义
 */
/**
 * 应用版本信息
 */
export declare const VERSION = "1.0.0";
/**
 * 应用名称
 */
export declare const APP_NAME = "LDesign Simple App";
/**
 * 应用描述
 */
export declare const APP_DESCRIPTION = "\u73B0\u4EE3\u5316\u524D\u7AEF\u5F00\u53D1\u6846\u67B6\u793A\u4F8B\u5E94\u7528";
/**
 * 格式化文件大小
 */
export declare function formatFileSize(bytes: number): string;
/**
 * 格式化时间
 */
export declare function formatTime(ms: number): string;
/**
 * 深度克隆对象
 */
export declare function deepClone<T>(obj: T): T;
/**
 * 防抖函数
 */
export declare function debounce<T extends (...args: any[]) => any>(func: T, wait: number): (...args: Parameters<T>) => void;
/**
 * 节流函数
 */
export declare function throttle<T extends (...args: any[]) => any>(func: T, limit: number): (...args: Parameters<T>) => void;
/**
 * 应用配置类型
 */
export interface AppConfig {
    name: string;
    version: string;
    description: string;
    apiUrl?: string;
    debug?: boolean;
}
/**
 * 用户类型
 */
export interface User {
    id: string;
    username: string;
    name: string;
    email: string;
    roles: string[];
    avatar?: string;
    createdAt: string;
}
/**
 * 默认导出
 */
declare const _default: {
    VERSION: string;
    APP_NAME: string;
    APP_DESCRIPTION: string;
    formatFileSize: typeof formatFileSize;
    formatTime: typeof formatTime;
    deepClone: typeof deepClone;
    debounce: typeof debounce;
    throttle: typeof throttle;
};
export default _default;
