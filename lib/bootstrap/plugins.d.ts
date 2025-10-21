/**
 * 插件初始化模块
 * 统一管理所有插件的创建和配置
 */
import type { Ref } from 'vue';
export interface PluginsResult {
    i18nPlugin: any;
    cachePlugin: any;
    colorPlugin: any;
    sizePlugin: any;
    templatePlugin: any;
    localeRef: Ref<string>;
}
/**
 * 初始化所有插件（兼容现有代码）
 */
export declare function initializePlugins(): PluginsResult;
