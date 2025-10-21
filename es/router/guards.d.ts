/**
 * 路由守卫配置
 * 处理认证、权限和其他导航逻辑
 */
import type { NavigationGuardNext, RouteLocationNormalized } from '@ldesign/router';
/**
 * 设置路由守卫
 * @param routerPlugin - 路由器插件实例
 */
export declare function setupGuards(routerPlugin: any): void;
/**
 * 清理路由守卫
 */
export declare function cleanupRouterGuards(router: any): void;
/**
 * 创建认证守卫
 */
export declare function createAuthGuard(): (to: RouteLocationNormalized, from: RouteLocationNormalized, next: NavigationGuardNext) => void;
/**
 * 创建权限守卫
 */
export declare function createPermissionGuard(): (to: RouteLocationNormalized, from: RouteLocationNormalized, next: NavigationGuardNext) => void;
/**
 * 创建进度条守卫
 */
export declare function createProgressGuard(): {
    before: (to: RouteLocationNormalized, from: RouteLocationNormalized, next: NavigationGuardNext) => void;
    after: () => void;
};
