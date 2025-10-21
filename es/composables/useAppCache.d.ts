/**
 * 应用缓存管理
 * 提供统一的缓存操作接口
 */
import type { SerializableValue } from '@ldesign/cache';
/**
 * 使用应用缓存
 */
export declare function useAppCache(): {
    /**
     * 获取缓存
     */
    get<T extends SerializableValue = SerializableValue>(key: string): Promise<T | null>;
    /**
     * 设置缓存
     */
    set<T extends SerializableValue = SerializableValue>(key: string, value: T, ttl?: number): Promise<void>;
    /**
     * 删除缓存
     */
    remove(key: string): Promise<void>;
    /**
     * 清空缓存
     */
    clear(): Promise<void>;
    /**
     * 检查缓存是否存在
     */
    has(key: string): Promise<boolean>;
    /**
     * 获取所有缓存键
     */
    keys(): Promise<string[]>;
    /**
     * 获取缓存统计信息
     */
    getStats(): Promise<any>;
    /**
     * 记忆函数：如果缓存不存在则执行 fetcher 并缓存结果
     */
    remember<T extends SerializableValue = SerializableValue>(key: string, fetcher: () => Promise<T> | T, ttl?: number): Promise<T>;
    manager: any;
};
