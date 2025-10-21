/**
 * 路由配置
 * 集中管理所有路由定义
 */
import type { RouteRecordRaw } from '@ldesign/router';
/**
 * 公开路由
 * 不需要认证即可访问
 */
export declare const publicRoutes: RouteRecordRaw[];
/**
 * 认证路由
 * 需要登录后才能访问
 */
export declare const authRoutes: RouteRecordRaw[];
/**
 * 错误页面路由
 */
export declare const errorRoutes: RouteRecordRaw[];
/**
 * 所有路由
 */
export declare const routes: RouteRecordRaw[];
export default routes;
