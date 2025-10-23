/**
 * 插件初始化模块
 * 统一管理所有插件的创建和配置
 */

import { watch } from 'vue'
import type { Ref } from 'vue'
import { createI18nEnginePlugin } from '../i18n'
import { createCacheVuePlugin } from '../plugins/cache'
import { createColorPlugin } from '@ldesign/color/plugin'
import { createSizePlugin } from '@ldesign/size/plugin'
import { createTemplatePlugin } from '@ldesign/template'
import {
  i18nConfig,
  createCacheConfig,
  createColorConfig,
  createSizeConfig,
  templateConfig
} from '../config'

export interface PluginsResult {
  i18nPlugin: any
  vuePlugins: any[]
  localeRef: Ref<string>
}

/**
 * 设置所有插件
 * @returns 插件列表和响应式 locale
 */
export async function setupPlugins(): Promise<PluginsResult> {
  // 创建 i18n 插件（createI18nEnginePlugin 会自动加载 locales）
  const i18nPlugin = createI18nEnginePlugin(i18nConfig)
  const localeRef = i18nPlugin.localeRef

  // 监听语言变化并广播事件
  watch(localeRef, (newLocale, oldLocale) => {
    if (typeof window !== 'undefined') {
      window.dispatchEvent(new CustomEvent('app:locale-changed', {
        detail: { locale: newLocale, oldLocale }
      }))
    }
  }, { flush: 'post' })

  // 创建其他插件
  const cachePlugin = createCacheVuePlugin(createCacheConfig(localeRef))
  const templatePlugin = createTemplatePlugin(templateConfig)
  const colorPlugin = createColorPlugin({
    ...createColorConfig(localeRef),
    locale: localeRef
  })
  const sizePlugin = createSizePlugin({
    ...createSizeConfig(localeRef),
    locale: localeRef
  })

  return {
    i18nPlugin,
    vuePlugins: [cachePlugin, templatePlugin, colorPlugin, sizePlugin],
    localeRef
  }
}
