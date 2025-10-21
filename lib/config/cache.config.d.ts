/**
 * Cache 插件配置
 */
import type { Ref } from 'vue';
import type { CacheOptions } from '@ldesign/cache';
export declare const createCacheConfig: (localeRef: Ref<string>) => CacheOptions & {
    globalPropertyName: string;
};
