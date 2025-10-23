<template>
  <footer class="custom-footer">
    <p>{{ copyrightText }}</p>
  </footer>
</template>

<script setup lang="ts">
defineProps<{
  copyrightText: string
}>()
</script>

<style scoped>
.custom-footer {
  margin-top: var(--size-spacing-4xl);
  padding: var(--size-spacing-xl);
  text-align: center;
  color: var(--color-text-tertiary);
  font-size: var(--size-font-base);
  border-top: var(--size-border-width-thin) solid var(--color-border);
}

.custom-footer p {
  margin: 0;
}
</style>
