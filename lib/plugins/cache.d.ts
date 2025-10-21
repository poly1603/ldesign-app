/**
 * Cache 插件 - Vue 直接集成
 */
import type { App } from 'vue';
import type { CacheOptions } from '@ldesign/cache';
export interface CachePluginOptions extends CacheOptions {
    globalPropertyName?: string;
}
/**
 * 创建 Cache Vue 插件
 */
export declare function createCacheVuePlugin(options?: CachePluginOptions): {
    install(app: App): void;
};
