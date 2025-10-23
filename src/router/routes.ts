/**
 * 路由配置
 * 集中管理所有路由定义
 */

import type { RouteRecordRaw } from '@ldesign/router'

// 路由懒加载 - 使用分组和预加载优化

// 核心布局（立即加载）
const MainLayout = () => import(/* webpackChunkName: "layout" */ '../views/MainLayout.vue')

// 首页（预加载）
const Home = () => import(
  /* webpackChunkName: "home" */
  /* webpackPrefetch: true */
  '../views/Home.vue'
)

// 登录和仪表盘（关键页面）
const Login = () => import(
  /* webpackChunkName: "auth" */
  /* webpackPrefetch: true */
  '../views/Login.vue'
)
const Dashboard = () => import(
  /* webpackChunkName: "auth" */
  '../views/Dashboard.vue'
)

// 基础页面（按需加载）
const About = () => import(
  /* webpackChunkName: "pages" */
  '../views/About.vue'
)

// Demo页面分组（低优先级，按需加载）
const CryptoDemo = () => import(
  /* webpackChunkName: "demos-basic" */
  '../views/CryptoDemo.vue'
)
const HttpDemo = () => import(
  /* webpackChunkName: "demos-basic" */
  '../views/HttpDemo.vue'
)
const ApiDemo = () => import(
  /* webpackChunkName: "demos-basic" */
  '../views/ApiDemo.vue'
)

// Engine Demo页面分组（低优先级，按需加载）
const PerformanceDemo = () => import(
  /* webpackChunkName: "demos-engine" */
  '../views/PerformanceDemo.vue'
)
const StateDemo = () => import(
  /* webpackChunkName: "demos-engine" */
  '../views/StateDemo.vue'
)
const EventDemo = () => import(
  /* webpackChunkName: "demos-engine" */
  '../views/EventDemo.vue'
)
const ConcurrencyDemo = () => import(
  /* webpackChunkName: "demos-engine" */
  '../views/ConcurrencyDemo.vue'
)
const PluginDemo = () => import(
  /* webpackChunkName: "demos-engine" */
  '../views/PluginDemo.vue'
)

/**
 * 公开路由
 * 不需要认证即可访问
 */
export const publicRoutes: RouteRecordRaw[] = [
  {
    path: '/',
    name: 'home',
    component: MainLayout,
    meta: {
      titleKey: 'nav.home',
      requiresAuth: false,
      layout: 'default'
    },
    children: [
      {
        path: '',
        name: 'Home',
        component: Home,
        meta: {
          titleKey: 'nav.home',
          requiresAuth: false,
          layout: 'default'
        }
      },
      {
        path: 'about',
        name: 'About',
        component: About,
        meta: {
          titleKey: 'nav.about',
          requiresAuth: false,
          layout: 'default'
        }
      },
      {
        path: 'crypto',
        name: 'CryptoDemo',
        component: CryptoDemo,
        meta: {
          titleKey: 'nav.crypto',
          requiresAuth: false,
          layout: 'default'
        }
      },
      {
        path: 'http',
        name: 'HttpDemo',
        component: HttpDemo,
        meta: {
          titleKey: 'nav.http',
          requiresAuth: false,
          layout: 'default'
        }
      },
      {
        path: 'api',
        name: 'ApiDemo',
        component: ApiDemo,
        meta: {
          titleKey: 'nav.api',
          requiresAuth: false,
          layout: 'default'
        }
      },
      {
        path: 'performance',
        name: 'PerformanceDemo',
        component: PerformanceDemo,
        meta: {
          titleKey: 'nav.performance',
          requiresAuth: false,
          layout: 'default'
        }
      },
      {
        path: 'state',
        name: 'StateDemo',
        component: StateDemo,
        meta: {
          titleKey: 'nav.state',
          requiresAuth: false,
          layout: 'default'
        }
      },
      {
        path: 'event',
        name: 'EventDemo',
        component: EventDemo,
        meta: {
          titleKey: 'nav.event',
          requiresAuth: false,
          layout: 'default'
        }
      },
      {
        path: 'concurrency',
        name: 'ConcurrencyDemo',
        component: ConcurrencyDemo,
        meta: {
          titleKey: 'nav.concurrency',
          requiresAuth: false,
          layout: 'default'
        }
      },
      {
        path: 'plugin',
        name: 'PluginDemo',
        component: PluginDemo,
        meta: {
          titleKey: 'nav.plugin',
          requiresAuth: false,
          layout: 'default'
        }
      },
    ]
  },
  {
    path: '/login',
    name: 'login',
    component: Login, // 使用原始登录页
    meta: {
      titleKey: 'nav.login',
      requiresAuth: false,
      layout: 'blank'  // 登录页面使用全屏布局，不显示导航栏和页脚
    }
  },
]

/**
 * 认证路由
 * 需要登录后才能访问
 */
export const authRoutes: RouteRecordRaw[] = [
  {
    path: '/dashboard',
    name: 'dashboard',
    component: Dashboard,
    meta: {
      titleKey: 'nav.dashboard',
      requiresAuth: false,  // 暂时禁用认证要求以便测试
      layout: 'default',
      roles: ['user', 'admin'] // 角色权限
    }
  }
]

/**
 * 错误页面路由
 */
export const errorRoutes: RouteRecordRaw[] = [
  {
    path: '/:pathMatch(.*)*',
    name: 'not-found',
    component: () => import('../views/errors/NotFound.vue'),
    meta: {
      titleKey: 'errors.404.title',
      layout: 'blank'
    }
  }
]

/**
 * 所有路由  
 */
export const routes: RouteRecordRaw[] = [
  ...publicRoutes,
  ...authRoutes,
  ...errorRoutes
]

export default routes