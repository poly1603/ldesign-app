/**
 * 路由器配置
 */
export declare const routerConfig: {
    mode: "history";
    base: string;
    preset: "spa";
    preload: {
        enabled: boolean;
        strategy: "hover";
        delay: number;
        threshold: number;
    };
    cache: {
        enabled: boolean;
        maxSize: number;
        strategy: "memory";
        ttl: number;
    };
    animation: {
        enabled: boolean;
        type: "fade";
        duration: number;
        easing: string;
    };
    performance: {
        prefetch: boolean;
        prerender: boolean;
        lazyLoad: boolean;
    };
    errorHandling: {
        redirect404: string;
        redirect403: string;
        redirect500: string;
    };
};
