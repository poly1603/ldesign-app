<template>
  <div class="home-container">
    <div class="hero">
      <h1 class="hero-title">{{ t('home.title') }}</h1>
      <p class="hero-subtitle">
        {{ t('home.subtitle') }}
      </p>
      <p class="hero-description">
        {{ t('home.description') }}
      </p>

      <div class="hero-actions">
        <RouterLink to="/about" class="btn btn-primary">
          {{ t('home.learnMore') }}
        </RouterLink>
        <RouterLink to="/crypto" class="btn btn-secondary">
          {{ t('home.getStarted') }}
        </RouterLink>
      </div>
    </div>

    <!-- Demo Showcase -->
    <div class="demos">
      <h2 class="demos-title">{{ t('home.demos.title') }}</h2>
      <div class="demos-grid">
        <RouterLink to="/crypto" class="demo-card">
          <Lock class="demo-icon" />
          <h3>{{ t('home.demos.crypto.title') }}</h3>
          <p>{{ t('home.demos.crypto.description') }}</p>
        </RouterLink>
        <RouterLink to="/http" class="demo-card">
          <Globe class="demo-icon" />
          <h3>{{ t('home.demos.http.title') }}</h3>
          <p>{{ t('home.demos.http.description') }}</p>
        </RouterLink>
        <RouterLink to="/api" class="demo-card">
          <Server class="demo-icon" />
          <h3>{{ t('home.demos.api.title') }}</h3>
          <p>{{ t('home.demos.api.description') }}</p>
        </RouterLink>
      </div>
    </div>

    <div class="features">
      <h2 class="features-title">{{ t('home.features.title') }}</h2>

      <div class="features-grid">
        <div class="feature-card" v-for="feature in features" :key="feature.key">
          <component :is="feature.icon" class="feature-icon" />
          <h3>{{ feature.title }}</h3>
          <p>{{ feature.description }}</p>
        </div>
      </div>
    </div>

    <div class="stats">
      <div class="stat-item">
        <div class="stat-value">{{ routeCount }}</div>
        <div class="stat-label">{{ t('home.stats.routes') }}</div>
      </div>
      <div class="stat-item">
        <div class="stat-value">{{ visitCount }}</div>
        <div class="stat-label">{{ t('home.stats.visits') }}</div>
      </div>
      <div class="stat-item">
        <div class="stat-value">{{ cacheSize }}KB</div>
        <div class="stat-label">{{ t('home.stats.cacheSize') }}</div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useRouter } from '@ldesign/router'
import { useI18n } from '../i18n'
import { Zap, Package, FileText, Lock, Globe, Server } from 'lucide-vue-next'

const router = useRouter()
const { t } = useI18n()

// Features list with i18n support
const features = computed(() => [
  {
    key: 'performance',
    icon: Zap,
    title: t('home.features.list.performance'),
    description: t('home.features.list.performanceDesc')
  },
  {
    key: 'modular',
    icon: Package,
    title: t('home.features.list.modular'),
    description: t('home.features.list.modularDesc')
  },
  {
    key: 'typescript',
    icon: FileText,
    title: t('home.features.list.typescript'),
    description: t('home.features.list.typescriptDesc')
  }
])

// Statistics data
const routeCount = ref(0)
const visitCount = ref(0)
const cacheSize = ref(0)

onMounted(() => {
  // Get route count
  routeCount.value = router.getRoutes().length

  // Get visit count (from localStorage) - 优化：减少字符串转换
  const currentVisits = parseInt(localStorage.getItem('visitCount') || '0', 10)
  const newVisits = currentVisits + 1
  visitCount.value = newVisits

  // 使用 requestIdleCallback 延迟非关键的 localStorage 写入
  if ('requestIdleCallback' in window) {
    requestIdleCallback(() => {
      localStorage.setItem('visitCount', String(newVisits))
    })
  } else {
    localStorage.setItem('visitCount', String(newVisits))
  }

  // Calculate cache size (example) - 优化：使用更高效的方式计算
  // 避免序列化整个 localStorage，只计算键值对大小
  let totalSize = 0
  for (let i = 0; i < localStorage.length; i++) {
    const key = localStorage.key(i)
    if (key) {
      const value = localStorage.getItem(key) || ''
      totalSize += key.length + value.length
    }
  }
  // 估算为 UTF-16 编码（每个字符 2 字节）
  cacheSize.value = Math.round(totalSize * 2 / 1024)
})
</script>

<style scoped>
.home-container {
  width: 100%;
  margin: 0 auto;
  padding: var(--size-spacing-xl);
}

/* Hero section */
.hero {
  text-align: center;
  padding: var(--size-spacing-4xl) var(--size-spacing-xl);
  background: var(--color-bg-container);
  border-radius: var(--size-radius-2xl);
  box-shadow: var(--shadow-md);
  margin-bottom: var(--size-spacing-4xl);
}

.hero-title {
  font-size: var(--size-font-display2);
  font-weight: var(--size-font-weight-extrabold);
  margin: 0 0 var(--size-spacing-xl) 0;
  color: var(--color-primary-default);
}

.hero-subtitle {
  font-size: var(--size-font-xl);
  color: var(--color-text-secondary);
  margin: 0 0 var(--size-spacing-md) 0;
}

.hero-description {
  font-size: var(--size-font-md);
  color: var(--color-text-tertiary);
  margin: 0 0 var(--size-spacing-4xl) 0;
}

.hero-actions {
  display: flex;
  gap: var(--size-spacing-xl);
  justify-content: center;
  flex-wrap: wrap;
}

.btn {
  padding: var(--size-comp-paddingTB-l) var(--size-comp-paddingLR-xl);
  border-radius: var(--size-radius-lg);
  text-decoration: none;
  font-size: var(--size-font-md);
  font-weight: var(--size-font-weight-semibold);
  transition: all var(--size-duration-normal);
  display: inline-block;
}

.btn-primary {
  background: linear-gradient(135deg, var(--color-primary-default) 0%, var(--color-primary-active) 100%);
  color: var(--color-text-inverse);
}

.btn-primary:hover {
  transform: translateY(-2px);
  box-shadow: var(--shadow-lg);
}

.btn-secondary {
  background: var(--color-bg-container);
  color: var(--color-primary-default);
  border: 2px solid var(--color-primary-default);
}

.btn-secondary:hover {
  background: var(--color-primary-default);
  color: var(--color-text-inverse);
}

/* Demo showcase */
.demos {
  margin-bottom: var(--size-spacing-4xl);
}

.demos-title {
  text-align: center;
  font-size: var(--size-font-display3);
  color: var(--color-text-primary);
  margin: 0 0 var(--size-spacing-4xl) 0;
}

.demos-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: var(--size-spacing-2xl);
  margin-bottom: var(--size-spacing-4xl);
}

.demo-card {
  background: var(--color-bg-container);
  padding: var(--size-spacing-3xl);
  border-radius: var(--size-radius-xl);
  box-shadow: var(--shadow-sm);
  text-align: center;
  transition: all var(--size-duration-normal);
  text-decoration: none;
  color: inherit;
  border: var(--size-border-width-medium) solid transparent;
}

.demo-card:hover {
  transform: translateY(-5px);
  box-shadow: var(--shadow-lg);
  border-color: var(--color-primary-default);
}

.demo-icon {
  width: var(--size-icon-giant);
  height: var(--size-icon-giant);
  margin: 0 auto var(--size-spacing-xl);
  color: var(--color-primary-default);
}

.demo-card h3 {
  font-size: var(--size-font-xl);
  color: var(--color-text-primary);
  margin: 0 0 var(--size-spacing-md) 0;
}

.demo-card p {
  color: var(--color-text-secondary);
  margin: 0;
  line-height: var(--size-line-relaxed);
  font-size: var(--size-font-base);
}

/* Features display */
.features {
  margin-bottom: var(--size-spacing-4xl);
}

.features-title {
  text-align: center;
  font-size: var(--size-font-display3);
  color: var(--color-text-primary);
  margin: 0 0 var(--size-spacing-4xl) 0;
}

.features-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
  gap: var(--size-spacing-3xl);
}

.feature-card {
  background: var(--color-bg-container);
  padding: var(--size-spacing-3xl);
  border-radius: var(--size-radius-xl);
  box-shadow: var(--shadow-sm);
  text-align: center;
  transition: all var(--size-duration-normal);
}

.feature-card:hover {
  transform: translateY(-5px);
  box-shadow: var(--shadow-lg);
}

.feature-icon {
  width: var(--size-icon-giant);
  height: var(--size-icon-giant);
  margin: 0 auto var(--size-spacing-xl);
  color: var(--color-primary-default);
}

.feature-card h3 {
  font-size: var(--size-font-xl);
  color: var(--color-text-primary);
  margin: 0 0 var(--size-spacing-md) 0;
}

.feature-card p {
  color: var(--color-text-secondary);
  margin: 0;
  line-height: var(--size-line-relaxed);
}

/* 统计数据 */
.stats {
  background: var(--color-bg-container);
  border-radius: var(--size-radius-xl);
  padding: var(--size-spacing-4xl);
  display: flex;
  justify-content: space-around;
  box-shadow: var(--shadow-sm);
  flex-wrap: wrap;
  gap: var(--size-spacing-3xl);
}

.stat-item {
  text-align: center;
}

.stat-value {
  font-size: var(--size-font-display3);
  font-weight: var(--size-font-weight-extrabold);
  color: var(--color-primary-default);
  margin-bottom: var(--size-spacing-md);
}

.stat-label {
  font-size: var(--size-font-base);
  color: var(--color-text-secondary);
  text-transform: uppercase;
  letter-spacing: var(--size-letter-normal);
}

@media (max-width: 768px) {
  .hero-title {
    font-size: var(--size-font-h1);
  }

  .hero-subtitle {
    font-size: var(--size-font-md);
  }

  .features-grid {
    grid-template-columns: 1fr;
  }
}
</style>