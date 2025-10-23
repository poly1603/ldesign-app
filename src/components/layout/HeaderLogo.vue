<template>
  <div class="nav-brand">
    <Rocket class="logo" />
    <span class="brand-text">{{ title }}</span>
  </div>
</template>

<script setup lang="ts">
import { Rocket } from 'lucide-vue-next'

defineProps<{
  title: string
}>()
</script>

<style scoped>
.nav-brand {
  display: flex;
  align-items: center;
  gap: var(--size-spacing-md);
}

.logo {
  width: var(--size-icon-large);
  height: var(--size-icon-large);
  color: var(--color-primary-default);
}

.brand-text {
  font-size: var(--size-font-xl);
  font-weight: var(--size-font-weight-semibold);
  color: var(--color-text-primary);
}
</style>
