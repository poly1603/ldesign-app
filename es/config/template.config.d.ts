/**
 * Template 插件配置
 */
export declare const templateConfig: {
    autoInit: boolean;
    autoDetect: boolean;
    defaultDevice: string;
    cache: {
        enabled: boolean;
        ttl: number;
        maxSize: number;
    };
    rememberPreferences: boolean;
    preferencesKey: string;
    preload: boolean;
    preloadStrategy: string;
    ui: {
        defaultStyle: string;
        display: {
            preview: boolean;
            description: boolean;
            metadata: boolean;
            aspectRatio: string;
        };
        styleByCategory: {
            login: string;
            dashboard: string;
            profile: string;
            settings: string;
        };
        features: {
            search: boolean;
            filter: boolean;
            groupBy: string;
        };
    };
    animation: {
        defaultAnimation: string;
        transitionMode: string;
        duration: number;
        customAnimations: {
            'login/default->login/split': string;
            'login/split->login/default': string;
            'dashboard/default->dashboard/sidebar': string;
            'dashboard/sidebar->dashboard/tabs': string;
        };
        animationByCategory: {
            login: string;
            dashboard: string;
            profile: string;
            settings: string;
        };
        animationByDevice: {
            mobile: string;
            tablet: string;
            desktop: string;
        };
    };
    hooks: {
        beforeLoad: (templatePath: string) => Promise<void>;
        afterLoad: (templatePath: string, component: any) => Promise<void>;
        beforeTransition: (from: string, to: string) => void;
        afterTransition: (from: string, to: string) => void;
        onError: (error: Error) => void;
    };
    performance: boolean;
};
