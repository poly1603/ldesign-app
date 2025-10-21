/**
 * 应用配置
 */
export declare const APP_NAME = "LDesign Router Demo";
export declare const APP_VERSION = "1.0.0";
/**
 * 应用基础配置
 */
export declare const appConfig: {
    name: string;
    version: string;
    description: string;
    author: string;
    debug: boolean;
    environment: string;
    api: {
        baseUrl: any;
        timeout: number;
        retries: number;
    };
    storage: {
        prefix: string;
        expire: number;
    };
    theme: {
        primaryColor: string;
        mode: string;
    };
};
/**
 * 引擎配置
 */
export declare const engineConfig: {
    name: string;
    version: string;
    debug: boolean;
    environment: string;
    features: {
        enableHotReload: boolean;
        enableDevTools: boolean;
        enablePerformanceMonitoring: boolean;
        enableErrorReporting: boolean;
        enableSecurityProtection: boolean;
        enableCaching: boolean;
        enableNotifications: boolean;
    };
    logger: {
        enabled: boolean;
        level: string;
        maxLogs: number;
        showTimestamp: boolean;
        showContext: boolean;
    };
    cache: {
        enabled: boolean;
        maxSize: number;
        defaultTTL: number;
    };
    performance: {
        enabled: boolean;
        sampleRate: number;
        slowThreshold: number;
    };
};
