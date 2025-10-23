/**
 * 认证组合式函数
 * 重新导出 auth 服务以保持向后兼容
 */

import { auth } from '../services/auth.service'

export { auth }

/**
 * 组合式函数形式（可选使用）
 * 提供与之前相同的 API
 */
export function useAuth() {
  return {
    // 状态
    currentUser: auth.userInfo,
    isLoading: auth.loading,
    isLoggedIn: auth.isLoggedIn,
    userInfo: auth.userInfo,
    userRoles: auth.userRoles,

    // 方法
    initAuth: () => auth.initAuth(),
    login: (credentials: { username: string; password: string }) => auth.login(credentials),
    logout: () => auth.logout(),
    hasRole: (role: string | string[]) => auth.hasRole(role),
    canAccess: (requiredRoles?: string[]) => auth.canAccess(requiredRoles),
    updateUserInfo: (updates: any) => auth.updateUserInfo(updates)
  }
}
