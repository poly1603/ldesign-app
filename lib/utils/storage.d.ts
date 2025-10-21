/**
 * 本地存储工具
 * 提供统一的存储接口
 */
declare class Storage {
    private prefix;
    constructor(prefix: string);
    /**
     * 获取完整的键名
     */
    private getKey;
    /**
     * 设置存储项
     */
    set<T = any>(key: string, value: T, ttl?: number): void;
    /**
     * 获取存储项
     */
    get<T = any>(key: string, defaultValue?: T): T | undefined;
    /**
     * 移除存储项
     */
    remove(key: string): void;
    /**
     * 清空所有存储项
     */
    clear(): void;
    /**
     * 检查存储项是否存在
     */
    has(key: string): boolean;
    /**
     * 获取所有存储项的键
     */
    keys(): string[];
}
export declare const storage: Storage;
declare class SessionStorage extends Storage {
    set<T = any>(key: string, value: T, ttl?: number): void;
    get<T = any>(key: string, defaultValue?: T): T | undefined;
    remove(key: string): void;
    clear(): void;
    has(key: string): boolean;
    keys(): string[];
    private getKey;
}
export declare const sessionStorage: SessionStorage;
export {};
