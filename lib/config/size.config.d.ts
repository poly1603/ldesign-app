/**
 * Size 插件配置
 */
import type { Ref } from 'vue';
export declare const createSizeConfig: (localeRef: Ref<string>) => {
    locale: Ref<string, string>;
    storageKey: string;
    defaultSize: string;
    presets: {
        name: string;
        label: string;
        description: string;
        baseSize: number;
        category: string;
    }[];
};
