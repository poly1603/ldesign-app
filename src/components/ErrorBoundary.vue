<template>
  <div v-if="error" class="error-boundary">
    <div class="error-content">
      <div class="error-icon">⚠️</div>
      <h2 class="error-title">{{ title }}</h2>
      <p class="error-message">{{ errorMessage }}</p>

      <div v-if="showDetails && import.meta.env.DEV" class="error-details">
        <pre>{{ errorStack }}</pre>
      </div>

      <div class="error-actions">
        <button @click="retry" class="btn btn-primary">
          {{ retryText }}
        </button>
        <button v-if="showFallback" @click="useFallback" class="btn btn-secondary">
          {{ fallbackText }}
        </button>
        <button @click="goHome" class="btn btn-text">
          {{ homeText }}
        </button>
      </div>
    </div>
  </div>

  <Suspense v-else @pending="onPending" @resolve="onResolve" @fallback="onFallback">
    <template #default>
      <slot />
    </template>
    <template #fallback>
      <div class="loading-container">
        <div class="loading-spinner"></div>
        <p>{{ loadingText }}</p>
      </div>
    </template>
  </Suspense>
</template>

<script setup lang="ts">
import { ref, computed, onErrorCaptured } from 'vue'
import { useRouter } from '@ldesign/router'

interface Props {
  title?: string
  retryText?: string
  fallbackText?: string
  homeText?: string
  loadingText?: string
  showDetails?: boolean
  showFallback?: boolean
  onError?: (error: Error) => void
  onRetry?: () => void
  onFallback?: () => void
}

const props = withDefaults(defineProps<Props>(), {
  title: '组件加载失败',
  retryText: '重试',
  fallbackText: '使用备用方案',
  homeText: '返回首页',
  loadingText: '加载中...',
  showDetails: true,
  showFallback: true
})

const router = useRouter()
const error = ref<Error | null>(null)
const retryCount = ref(0)
const MAX_RETRIES = 3

// 错误信息
const errorMessage = computed(() => {
  if (!error.value) return ''
  return error.value.message || '未知错误'
})

// 错误堆栈
const errorStack = computed(() => {
  if (!error.value) return ''
  return error.value.stack || ''
})

// 捕获错误
onErrorCaptured((err: Error, instance, info) => {
  console.error('Error captured:', err, info)
  error.value = err

  // 调用错误回调
  if (props.onError) {
    props.onError(err)
  }

  // 上报错误到监控系统
  if (typeof window !== 'undefined' && (window as any).__ERROR_TRACKER__) {
    (window as any).__ERROR_TRACKER__.report({
      error: err,
      component: instance,
      info
    })
  }

  // 返回 false 阻止错误继续传播
  return false
})

// 重试
const retry = () => {
  if (retryCount.value >= MAX_RETRIES) {
    alert(`已重试 ${MAX_RETRIES} 次，请联系技术支持`)
    return
  }

  retryCount.value++
  error.value = null

  if (props.onRetry) {
    props.onRetry()
  }

  // 强制重新渲染
  setTimeout(() => {
    if (error.value) {
      console.warn('Retry failed')
    }
  }, 100)
}

// 使用备用方案
const useFallback = () => {
  error.value = null

  if (props.onFallback) {
    props.onFallback()
  }
}

// 返回首页
const goHome = () => {
  router.push('/')
}

// 加载状态
const onPending = () => {
  if (import.meta.env.DEV) {
    console.log('[ErrorBoundary] Loading...')
  }
}

const onResolve = () => {
  if (import.meta.env.DEV) {
    console.log('[ErrorBoundary] Loaded successfully')
  }
  error.value = null
  retryCount.value = 0
}

const onFallback = () => {
  if (import.meta.env.DEV) {
    console.log('[ErrorBoundary] Showing fallback')
  }
}
</script>

<style scoped>
.error-boundary {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 400px;
  padding: var(--size-spacing-4xl);
}

.error-content {
  max-width: 600px;
  text-align: center;
}

.error-icon {
  font-size: 64px;
  margin-bottom: var(--size-spacing-xl);
}

.error-title {
  font-size: var(--size-font-h2);
  font-weight: var(--size-font-weight-bold);
  color: var(--color-danger-default);
  margin-bottom: var(--size-spacing-md);
}

.error-message {
  font-size: var(--size-font-lg);
  color: var(--color-text-secondary);
  margin-bottom: var(--size-spacing-2xl);
}

.error-details {
  background: var(--color-bg-component);
  border: var(--size-border-width-thin) solid var(--color-border);
  border-radius: var(--size-radius-md);
  padding: var(--size-spacing-lg);
  margin-bottom: var(--size-spacing-2xl);
  max-height: 300px;
  overflow: auto;
  text-align: left;
}

.error-details pre {
  margin: 0;
  font-size: var(--size-font-sm);
  color: var(--color-text-tertiary);
  white-space: pre-wrap;
  word-wrap: break-word;
}

.error-actions {
  display: flex;
  gap: var(--size-spacing-md);
  justify-content: center;
  flex-wrap: wrap;
}

.loading-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 200px;
  padding: var(--size-spacing-4xl);
}

.loading-spinner {
  width: 48px;
  height: 48px;
  border: 4px solid var(--color-border);
  border-top-color: var(--color-primary-default);
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
  margin-bottom: var(--size-spacing-xl);
}

@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}

.loading-container p {
  color: var(--color-text-secondary);
  font-size: var(--size-font-lg);
}
</style>
