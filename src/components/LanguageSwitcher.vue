<template>
  <div class="language-switcher">
    <button @click="toggleDropdown" class="language-button" :title="t('nav.language')">
      <span class="flag">{{ currentLocaleFlag }}</span>
      <span class="name">{{ currentLocaleName }}</span>
      <ChevronDown class="arrow" :class="{ open: isOpen }" />
    </button>
    <transition name="dropdown">
      <div v-if="isOpen" class="language-dropdown" @click.stop>
        <button
          v-for="locale in availableLocales"
          :key="locale.code"
          @click="changeLocale(locale.code)"
          class="language-option"
          :class="{ active: currentLocale === locale.code }"
        >
          <span class="flag">{{ locale.flag }}</span>
          <span class="name">{{ locale.name }}</span>
          <Check v-if="currentLocale === locale.code" class="check" />
        </button>
      </div>
    </transition>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useI18n } from '../i18n'
import { availableLocales } from '../locales'
import { ChevronDown, Check } from 'lucide-vue-next'

const { locale, setLocale, t } = useI18n()
const isOpen = ref(false)

const currentLocale = computed(() => locale.value)
const currentLocaleData = computed(() => 
  availableLocales.find(l => l.code === currentLocale.value) || availableLocales[0]
)
const currentLocaleName = computed(() => currentLocaleData.value.name)
const currentLocaleFlag = computed(() => currentLocaleData.value.flag)

const toggleDropdown = () => {
  isOpen.value = !isOpen.value
}

const changeLocale = async (newLocale: string) => {
  await setLocale(newLocale)
  isOpen.value = false
}

const handleClickOutside = (event: MouseEvent) => {
  const target = event.target as HTMLElement
  if (!target.closest('.language-switcher')) {
    isOpen.value = false
  }
}

onMounted(() => {
  document.addEventListener('click', handleClickOutside)
})

onUnmounted(() => {
  document.removeEventListener('click', handleClickOutside)
})
</script>

<style scoped>
.language-switcher {
  position: relative;
}

.language-button {
  display: flex;
  align-items: center;
  gap: var(--size-spacing-md);
  padding: var(--size-spacing-md) var(--size-spacing-lg);
  background: var(--color-primary-lighter);
  border: var(--size-border-width-thin) solid var(--color-primary-light);
  border-radius: var(--size-radius-lg);
  color: var(--color-text-primary);
  font-size: var(--size-font-base);
  font-weight: var(--size-font-weight-medium);
  cursor: pointer;
  transition: all var(--size-duration-normal);
}

.language-button:hover {
  background: var(--color-primary-light);
  border-color: var(--color-primary-default);
}

.flag {
  font-size: var(--size-font-lg);
}

.arrow {
  width: var(--size-icon-medium);
  height: var(--size-icon-medium);
  transition: transform var(--size-duration-normal);
}

.arrow.open {
  transform: rotate(180deg);
}

.language-dropdown {
  position: absolute;
  top: 100%;
  right: 0;
  margin-top: var(--size-spacing-md);
  background: var(--color-bg-container);
  border: var(--size-border-width-thin) solid var(--color-border-light);
  border-radius: var(--size-radius-lg);
  box-shadow: var(--shadow-lg);
  overflow: hidden;
  z-index: var(--z-index-dropdown);
  min-width: 160px;
}

.language-option {
  display: flex;
  align-items: center;
  gap: var(--size-spacing-md);
  width: 100%;
  padding: var(--size-spacing-md) var(--size-spacing-xl);
  background: none;
  border: none;
  color: var(--color-text-primary);
  font-size: var(--size-font-base);
  cursor: pointer;
  transition: background var(--size-duration-fast);
  text-align: left;
}

.language-option:hover {
  background: var(--color-bg-component-hover);
}

.language-option.active {
  background: var(--color-primary-lighter);
  color: var(--color-primary-default);
  font-weight: var(--size-font-weight-semibold);
}

.language-option .name {
  flex: 1;
}

.check {
  width: var(--size-icon-medium);
  height: var(--size-icon-medium);
  color: var(--color-primary-default);
}

/* Dropdown animation */
.dropdown-enter-active,
.dropdown-leave-active {
  transition: opacity var(--size-duration-normal), transform var(--size-duration-normal);
}

.dropdown-enter-from,
.dropdown-leave-to {
  opacity: 0;
  transform: translateY(-10px);
}
</style>