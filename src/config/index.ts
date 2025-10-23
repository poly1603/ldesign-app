/**
 * 统一配置管理入口
 * 从单一配置文件导出所有配置
 */

export {
  // 基础配置
  APP_NAME,
  APP_VERSION,
  appConfig,

  // Engine 配置
  engineConfig,

  // 各模块配置
  i18nConfig,
  routerConfig,
  storeConfig,
  templateConfig,

  // 插件配置工厂
  createCacheConfig,
  createColorConfig,
  createSizeConfig
} from './app.config'
