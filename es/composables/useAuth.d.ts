/**
 * 认证组合式函数
 * 管理用户登录状态、用户信息等
 */
import type { User } from '@/types/user';
/**
 * 用户认证组合式函数
 */
export declare function useAuth(): {
    currentUser: import("vue").Ref<{
        id: string;
        username: string;
        name: string;
        email: string;
        avatar?: string | undefined;
        roles: string[];
        permissions?: string[] | undefined;
        createdAt: string;
        updatedAt?: string | undefined;
    } | null, User | {
        id: string;
        username: string;
        name: string;
        email: string;
        avatar?: string | undefined;
        roles: string[];
        permissions?: string[] | undefined;
        createdAt: string;
        updatedAt?: string | undefined;
    } | null>;
    isLoading: import("vue").Ref<boolean, boolean>;
    isLoggedIn: import("vue").ComputedRef<boolean>;
    userInfo: import("vue").ComputedRef<{
        id: string;
        username: string;
        name: string;
        email: string;
        avatar?: string | undefined;
        roles: string[];
        permissions?: string[] | undefined;
        createdAt: string;
        updatedAt?: string | undefined;
    } | null>;
    userRoles: import("vue").ComputedRef<string[]>;
    initAuth: () => void;
    login: (credentials: {
        username: string;
        password: string;
    }) => Promise<{
        success: boolean;
        error: string;
        user?: undefined;
    } | {
        success: boolean;
        user: User;
        error?: undefined;
    }>;
    logout: () => Promise<{
        success: boolean;
        error?: undefined;
    } | {
        success: boolean;
        error: string;
    }>;
    hasRole: (role: string | string[]) => boolean;
    canAccess: (requiredRoles?: string[]) => boolean;
    updateUserInfo: (updates: Partial<User>) => void;
};
export declare const auth: {
    currentUser: import("vue").Ref<{
        id: string;
        username: string;
        name: string;
        email: string;
        avatar?: string | undefined;
        roles: string[];
        permissions?: string[] | undefined;
        createdAt: string;
        updatedAt?: string | undefined;
    } | null, User | {
        id: string;
        username: string;
        name: string;
        email: string;
        avatar?: string | undefined;
        roles: string[];
        permissions?: string[] | undefined;
        createdAt: string;
        updatedAt?: string | undefined;
    } | null>;
    isLoading: import("vue").Ref<boolean, boolean>;
    isLoggedIn: import("vue").ComputedRef<boolean>;
    userInfo: import("vue").ComputedRef<{
        id: string;
        username: string;
        name: string;
        email: string;
        avatar?: string | undefined;
        roles: string[];
        permissions?: string[] | undefined;
        createdAt: string;
        updatedAt?: string | undefined;
    } | null>;
    userRoles: import("vue").ComputedRef<string[]>;
    initAuth(): void;
    login(credentials: {
        username: string;
        password: string;
    }): Promise<{
        success: boolean;
        error: string;
        user?: undefined;
    } | {
        success: boolean;
        user: User;
        error?: undefined;
    }>;
    logout(): Promise<{
        success: boolean;
        error?: undefined;
    } | {
        success: boolean;
        error: string;
    }>;
    hasRole(role: string | string[]): boolean;
    canAccess(requiredRoles?: string[]): boolean;
    updateUserInfo(updates: Partial<User>): void;
};
