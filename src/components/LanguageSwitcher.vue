<template>
  <div class="language-switcher">
    <button ref="triggerRef" class="language-button" :title="t('nav.language')" :aria-expanded="state.isOpen"
      @click="actions.toggle">
      <span class="flag">{{ currentLocaleFlag }}</span>
      <span class="name">{{ currentLocaleName }}</span>
      <svg class="arrow" :class="{ open: state.isOpen }" width="16" height="16" viewBox="0 0 24 24" fill="none"
        stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
        <path d="m6 9 6 6 6-6" />
      </svg>
    </button>

    <Teleport to="body">
      <transition name="selector-panel">
        <div v-if="state.isOpen" ref="panelRef" class="language-dropdown"
          :class="{ 'language-dropdown-dialog': currentMode === 'dialog' }" :style="popupStyle" @click.stop>
          <button v-for="(option, index) in state.filteredOptions" :key="option.value" class="language-option" :class="{
            'active': state.selectedValue === option.value,
            'hover': state.activeIndex === index
          }" @click="actions.select(option.value)" @mouseenter="activeIndexRef = index">
            <span class="flag">{{ option.icon }}</span>
            <span class="name">{{ option.label }}</span>
            <svg v-if="state.selectedValue === option.value" class="check" width="16" height="16" viewBox="0 0 24 24"
              fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M20 6 9 17l-5-5" />
            </svg>
          </button>
        </div>
      </transition>
    </Teleport>
  </div>
</template>

<script setup lang="ts">
/**
 * LanguageSwitcher - 基于无头逻辑层重构
 * 使用 @ldesign/shared 的协议和逻辑层
 */
import { computed } from 'vue'
import type { SelectorConfig, SelectorOption } from '@ldesign/shared/protocols'
import { useHeadlessSelector, useResponsivePopup } from '@ldesign/shared/composables'
import { useI18n } from '../i18n'
import { availableLocales } from '../locales'

const { locale, setLocale, t } = useI18n()

// 选择器配置（遵循协议）
const config: SelectorConfig = {
  icon: 'Languages',
  popupMode: 'auto',
  listStyle: 'simple',
  searchable: false,
  breakpoint: 768
}

// 转换为 SelectorOption 格式
const options = computed<SelectorOption[]>(() => {
  return availableLocales.map(loc => ({
    value: loc.code,
    label: loc.name,
    icon: loc.flag,
    metadata: {
      flag: loc.flag
    }
  }))
})

// 当前语言信息
const currentLocale = computed(() => locale.value)
const currentLocaleData = computed(() =>
  availableLocales.find(l => l.code === currentLocale.value) || availableLocales[0]
)
const currentLocaleName = computed(() => currentLocaleData.value.name)
const currentLocaleFlag = computed(() => currentLocaleData.value.flag)

// 处理语言切换
const handleSelect = async (value: string) => {
  await setLocale(value)
}

// 使用无头选择器
const { state, actions, triggerRef, panelRef, activeIndexRef } = useHeadlessSelector({
  options,
  modelValue: locale,
  searchable: config.searchable,
  onSelect: handleSelect
})

// 使用响应式弹出
const { currentMode, popupStyle } = useResponsivePopup({
  mode: config.popupMode,
  triggerRef,
  panelRef,
  placement: 'bottom-end',
  breakpoint: config.breakpoint,
  isOpen: computed(() => state.value.isOpen)
})
</script>

<style scoped>
.language-switcher {
  position: relative;
  display: inline-block;
}

/* 触发按钮 - 使用 CSS 变量统一样式 */
.language-button {
  display: inline-flex;
  align-items: center;
  gap: var(--size-spacing-md);
  padding: var(--size-spacing-md) var(--size-spacing-lg);
  background: var(--color-bg-container);
  border: var(--size-border-width-thin) solid var(--color-border-light);
  border-radius: var(--size-radius-lg);
  color: var(--color-text-primary);
  font-size: var(--size-font-base);
  font-weight: var(--size-font-weight-medium);
  cursor: pointer;
  transition: all var(--size-duration-fast) var(--size-ease-out);
  white-space: nowrap;
  min-width: 120px;
}

.language-button:hover {
  background: var(--color-bg-component-hover);
  border-color: var(--color-border);
}

.language-button[aria-expanded="true"] {
  border-color: var(--color-primary-default);
  box-shadow: 0 0 0 2px var(--color-primary-lighter);
}

.flag {
  font-size: 18px;
  line-height: 1;
}

.name {
  flex: 1;
}

.arrow {
  transition: transform 0.2s ease;
  color: #666;
  flex-shrink: 0;
}

.arrow.open {
  transform: rotate(180deg);
}

/* 下拉面板 - 使用 CSS 变量统一样式 */
.language-dropdown {
  min-width: 200px;
  background: var(--color-bg-container);
  border: var(--size-border-width-thin) solid var(--color-border-lighter);
  border-radius: var(--size-radius-xl);
  box-shadow: var(--shadow-lg);
  overflow: hidden;
  padding: var(--size-spacing-xs);
}

.language-dropdown-dialog {
  max-width: 90vw;
  max-height: 80vh;
}

/* 选项样式 - 使用 CSS 变量统一样式 */
.language-option {
  display: flex;
  align-items: center;
  gap: var(--size-spacing-lg);
  width: 100%;
  padding: var(--size-spacing-lg) var(--size-spacing-xl);
  background: transparent;
  border: var(--size-border-width-medium) solid transparent;
  color: var(--color-text-primary);
  font-size: var(--size-font-base);
  cursor: pointer;
  transition: all var(--size-duration-fast) var(--size-ease-out);
  text-align: left;
  border-radius: var(--size-radius-md);
  white-space: nowrap;
}

.language-option:hover,
.language-option.hover {
  background: var(--color-bg-component-hover);
}

.language-option.active {
  background: color-mix(in srgb, var(--color-primary-default) 8%, transparent);
  border-color: color-mix(in srgb, var(--color-primary-default) 30%, transparent);
  color: var(--color-primary-default);
  font-weight: var(--size-font-weight-semibold);
}

.language-option .flag {
  font-size: 18px;
  line-height: 1;
}

.language-option .name {
  flex: 1;
}

.check {
  color: #667eea;
  margin-left: auto;
  flex-shrink: 0;
}

/* 过渡动画 - 统一标准 */
.selector-panel-enter-active {
  transition: all 0.25s cubic-bezier(0.34, 1.56, 0.64, 1);
}

.selector-panel-leave-active {
  transition: all 0.2s cubic-bezier(0.4, 0, 1, 1);
}

.selector-panel-enter-from {
  opacity: 0;
  transform: translateY(-8px) scale(0.96);
}

.selector-panel-leave-to {
  opacity: 0;
  transform: translateY(-4px);
}

/* 深色模式会自动通过 CSS 变量切换,无需额外定义 */
/* CSS 变量在 :root[data-theme-mode='dark'] 下会自动更新 */
</style>