/**
 * Color 插件配置
 */
import type { Ref } from 'vue';
export declare const createColorConfig: (localeRef: Ref<string>) => {
    locale: Ref<string, string>;
    prefix: string;
    storageKey: string;
    persistence: boolean;
    presets: "all";
    autoApply: boolean;
    defaultTheme: string;
    includeSemantics: boolean;
    includeGrays: boolean;
    customThemes: {
        name: string;
        label: string;
        color: string;
        custom: boolean;
        order: number;
    }[];
    hooks: {
        afterChange: (theme: any) => void;
    };
};
