/**
 * i18n 配置
 * 使用 @ldesign/i18n 包
 */
import { useVueI18n } from '@ldesign/i18n';
import type { I18nEnginePluginOptions } from '@ldesign/i18n';
export declare const useI18n: typeof useVueI18n;
export declare function createI18nEnginePlugin(options?: I18nEnginePluginOptions): {
    name: string;
    version: string;
    localeRef: import("vue").Ref<string, string>;
    install(context: any): Promise<void>;
    setupVueApp(app: import("vue").App): void;
    api: {
        readonly i18n: import("@ldesign/i18n").I18nInstance;
        readonly vuePlugin: any;
        changeLocale(locale: string): Promise<void>;
        t(key: string, params?: Record<string, any>): string;
        getCurrentLocale(): string;
        getAvailableLocales(): string[];
    };
};
declare const _default: {
    useI18n: typeof useVueI18n;
    createI18nEnginePlugin: typeof createI18nEnginePlugin;
};
export default _default;
