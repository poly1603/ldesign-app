/**
 * 认证服务 - 单例模式
 * 统一管理用户登录状态、用户信息等
 */

import { ref, computed } from 'vue'
import type { Ref, ComputedRef } from 'vue'
import type { User } from '../../types/user'
import { storage } from '../utils/storage'

/**
 * 认证服务类 - 单例实现
 */
class AuthService {
  private static instance: AuthService

  // 私有状态
  private currentUser: Ref<User | null>
  private isLoading: Ref<boolean>

  // 计算属性
  public readonly isLoggedIn: ComputedRef<boolean>
  public readonly userInfo: ComputedRef<User | null>
  public readonly userRoles: ComputedRef<string[]>

  private constructor() {
    // 初始化状态
    this.currentUser = ref<User | null>(null)
    this.isLoading = ref(false)

    // 初始化计算属性
    this.isLoggedIn = computed(() => !!this.currentUser.value)
    this.userInfo = computed(() => this.currentUser.value)
    this.userRoles = computed(() => this.currentUser.value?.roles || [])
  }

  /**
   * 获取单例实例
   */
  public static getInstance(): AuthService {
    if (!AuthService.instance) {
      AuthService.instance = new AuthService()
    }
    return AuthService.instance
  }

  /**
   * 初始化认证状态
   * 从本地存储恢复用户信息
   */
  public initAuth(): void {
    const storedUser = storage.get('user')
    const token = storage.get('token')

    if (storedUser && token) {
      this.currentUser.value = storedUser
    }
  }

  /**
   * 登录
   */
  public async login(credentials: { username: string; password: string }): Promise<{
    success: boolean
    error?: string
    user?: User
  }> {
    this.isLoading.value = true

    try {
      // 模拟登录请求
      await new Promise(resolve => setTimeout(resolve, 1000))

      // 验证凭据
      const validCredentials = [
        { username: 'admin', password: 'admin' },
        { username: 'user', password: 'user' }
      ]

      const isValid = validCredentials.some(
        cred => cred.username === credentials.username && cred.password === credentials.password
      )

      if (!isValid) {
        return { success: false, error: '用户名或密码错误' }
      }

      // 模拟用户数据
      const userData: User = {
        id: '1',
        username: credentials.username,
        name: credentials.username === 'admin' ? '管理员' : '普通用户',
        email: `${credentials.username}@example.com`,
        roles: credentials.username === 'admin' ? ['admin', 'user'] : ['user'],
        avatar: `https://api.dicebear.com/7.x/avataaars/svg?seed=${credentials.username}`,
        createdAt: new Date().toISOString()
      }

      // 模拟token
      const token = btoa(`${credentials.username}:${Date.now()}`)

      // 保存到状态和本地存储
      this.currentUser.value = userData
      storage.set('user', userData)
      storage.set('token', token)
      storage.set('isLoggedIn', true)

      return { success: true, user: userData }
    } catch (error) {
      console.error('登录失败:', error)
      return { success: false, error: '登录失败' }
    } finally {
      this.isLoading.value = false
    }
  }

  /**
   * 退出登录
   */
  public async logout(): Promise<{ success: boolean; error?: string }> {
    try {
      // 清除用户状态
      this.currentUser.value = null

      // 清除本地存储
      storage.remove('user')
      storage.remove('token')
      storage.remove('isLoggedIn')

      return { success: true }
    } catch (error) {
      console.error('退出登录失败:', error)
      return { success: false, error: '退出失败' }
    }
  }

  /**
   * 检查权限
   */
  public hasRole(role: string | string[]): boolean {
    if (!this.currentUser.value) return false

    const roles = Array.isArray(role) ? role : [role]
    return roles.some(r => this.userRoles.value.includes(r))
  }

  /**
   * 检查是否有权限访问
   */
  public canAccess(requiredRoles?: string[]): boolean {
    if (!requiredRoles || requiredRoles.length === 0) {
      return true
    }

    if (!this.isLoggedIn.value) {
      return false
    }

    return this.hasRole(requiredRoles)
  }

  /**
   * 更新用户信息
   */
  public updateUserInfo(updates: Partial<User>): void {
    if (this.currentUser.value) {
      this.currentUser.value = {
        ...this.currentUser.value,
        ...updates
      }
      storage.set('user', this.currentUser.value)
    }
  }

  /**
   * 获取加载状态（用于响应式绑定）
   */
  public get loading(): Ref<boolean> {
    return this.isLoading
  }
}

// 导出单例实例
export const auth = AuthService.getInstance()

// 导出类型
export type { User }

