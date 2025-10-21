/**
 * 应用设置模块
 * 负责配置 Vue 应用实例
 */
import type { App } from 'vue';
import type { Ref } from 'vue';
interface SetupOptions {
    localeRef: Ref<string>;
    i18nPlugin: any;
    cachePlugin?: any;
    colorPlugin: any;
    sizePlugin: any;
    templatePlugin: any;
}
/**
 * 设置 Vue 应用
 */
export declare function setupVueApp(app: App, options: SetupOptions): void;
/**
 * 设置引擎就绪后的钩子
 */
export declare function setupEngineReady(engine: any, localeRef: Ref<string>, i18nPlugin: any, cachePlugin: any, colorPlugin: any, sizePlugin: any): void;
/**
 * 清理引擎相关的资源
 */
export declare function cleanupEngineReady(engine: any): void;
export {};
