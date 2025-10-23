<template>
  <div class="about-container">
    <div class="about-content">
      <h1 class="about-title">{{ t('about.title') }}</h1>

      <div class="about-section">
        <h2>{{ t('about.subtitle') }}</h2>
        <p>{{ t('about.description') }}</p>
      </div>

      <div class="about-section">
        <h2>{{ t('about.goals.title') || '我们的目标' }}</h2>
        <ul>
          <li v-for="(item, index) in goalItems" :key="index">{{ item }}</li>
        </ul>
      </div>

      <div class="about-section">
        <h2>{{ t('about.features.title') }}</h2>
        <div class="feature-list">
          <div class="feature-item" v-for="feature in features" :key="feature.key">
            <h3>{{ feature.title }}</h3>
            <p>{{ feature.desc }}</p>
          </div>
        </div>
      </div>

      <div class="about-section">
        <h2>{{ t('about.techStack') || '技术栈' }}</h2>
        <div class="tech-stack">
          <span class="tech-badge" v-for="tech in techStack" :key="tech">{{ tech }}</span>
        </div>
      </div>

      <div class="about-section">
        <h2>{{ t('about.version') }}</h2>
        <table class="version-table">
          <tbody>
            <tr>
              <td>{{ t('about.version') }}</td>
              <td>v1.0.0</td>
            </tr>
            <tr>
              <td>Vue {{ t('about.version') }}</td>
              <td>v3.4+</td>
            </tr>
            <tr>
              <td>Node {{ t('about.version') }}</td>
              <td>v16+</td>
            </tr>
            <tr>
              <td>{{ t('about.license') }}</td>
              <td>MIT</td>
            </tr>
          </tbody>
        </table>
      </div>

      <div class="about-section">
        <h2>{{ t('about.contact.title') }}</h2>
        <p>{{ t('about.team.description') }}</p>
        <div class="contribute-links">
          <a href="#" class="contribute-link">{{ t('about.repository') }}</a>
          <a href="#" class="contribute-link">{{ t('home.viewDocs') }}</a>
          <a href="#" class="contribute-link">{{ t('about.contact.community') || '讨论区' }}</a>
        </div>
      </div>

      <div class="about-footer">
        <p>{{ t('about.team.title') }}</p>
        <p class="copyright">{{ t('app.copyright') }}</p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { onMounted, computed } from 'vue'
import { useI18n } from '../i18n'

const { t } = useI18n()

// 目标项列表
const goalItems = computed(() => [
  t('about.goals.api') || '提供简洁而强大的 API',
  t('about.goals.performance') || '优化性能，减少内存占用',
  t('about.goals.typescript') || '完善的 TypeScript 支持',
  t('about.goals.integration') || '与 @ldesign/engine 深度集成',
  t('about.goals.extensible') || '丰富的功能扩展'
])

// 特性列表
const features = computed(() => [
  {
    key: 'vue3',
    title: t('about.features.items.vue3'),
    desc: t('about.features.vue3Desc') || '基于 Vue 3 构建，提供出色的性能'
  },
  {
    key: 'typescript',
    title: t('about.features.items.typescript'),
    desc: t('home.features.list.typescriptDesc')
  },
  {
    key: 'vite',
    title: t('about.features.items.vite'),
    desc: t('about.features.viteDesc') || '快速的开发服务器和构建工具'
  },
  {
    key: 'i18n',
    title: t('about.features.items.i18n'),
    desc: t('about.features.i18nDesc') || '完整的国际化支持'
  }
])

// 技术栈
const techStack = ['Vue 3', 'TypeScript', 'Vite', 'Rollup', 'ESBuild', 'i18n']

onMounted(() => {
  // About page mounted
})
</script>

<style scoped>
.about-container {
  width: 100%;
  margin: 0 auto;
  padding: var(--size-spacing-xl);
}

.about-content {
  background: var(--color-bg-container);
  border-radius: var(--size-radius-2xl);
  box-shadow: var(--shadow-lg);
  padding: var(--size-spacing-4xl);
}

.about-title {
  font-size: var(--size-font-display3);
  color: var(--color-text-primary);
  margin: 0 0 var(--size-spacing-4xl) 0;
  text-align: center;
}

.about-section {
  margin-bottom: var(--size-spacing-4xl);
}

.about-section h2 {
  font-size: var(--size-font-2xl);
  color: var(--color-text-primary);
  margin: 0 0 var(--size-spacing-xl) 0;
  padding-bottom: var(--size-spacing-md);
  border-bottom: var(--size-border-width-medium) solid var(--color-border-light);
}

.about-section p {
  color: var(--color-text-secondary);
  line-height: var(--size-line-loose);
  margin: 0 0 var(--size-spacing-lg) 0;
}

.about-section ul {
  color: var(--color-text-secondary);
  line-height: var(--size-line-loose);
  padding-left: var(--size-spacing-xl);
}

.about-section li {
  margin-bottom: var(--size-spacing-md);
}

/* 功能列表 */
.feature-list {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: var(--size-spacing-xl);
}

.feature-item {
  padding: var(--size-spacing-xl);
  background: var(--color-bg-container-secondary);
  border-radius: var(--size-radius-lg);
}

.feature-item h3 {
  color: var(--color-primary-default);
  font-size: var(--size-font-lg);
  margin: 0 0 var(--size-spacing-md) 0;
}

.feature-item p {
  color: var(--color-text-secondary);
  font-size: var(--size-font-base);
  margin: 0;
}

/* 技术栈 */
.tech-stack {
  display: flex;
  flex-wrap: wrap;
  gap: var(--size-spacing-md);
}

.tech-badge {
  display: inline-block;
  padding: var(--size-spacing-md) var(--size-spacing-xl);
  background: linear-gradient(135deg, var(--color-primary-default) 0%, var(--color-primary-active) 100%);
  color: var(--color-text-inverse);
  border-radius: var(--size-radius-full);
  font-size: var(--size-font-base);
  font-weight: var(--size-font-weight-semibold);
}

/* 版本表格 */
.version-table {
  width: 100%;
  border-collapse: collapse;
}

.version-table tr {
  border-bottom: var(--size-border-width-thin) solid var(--color-border-light);
}

.version-table td {
  padding: var(--size-spacing-lg);
  color: var(--color-text-secondary);
}

.version-table td:first-child {
  font-weight: var(--size-font-weight-semibold);
  width: 40%;
}

/* 贡献链接 */
.contribute-links {
  display: flex;
  gap: var(--size-spacing-xl);
  margin-top: var(--size-spacing-xl);
}

.contribute-link {
  padding: var(--size-spacing-md) var(--size-spacing-xl);
  background: var(--color-bg-container);
  color: var(--color-primary-default);
  border: var(--size-border-width-medium) solid var(--color-primary-default);
  border-radius: var(--size-radius-md);
  text-decoration: none;
  font-weight: var(--size-font-weight-semibold);
  transition: all var(--size-duration-normal);
}

.contribute-link:hover {
  background: var(--color-primary-default);
  color: var(--color-text-inverse);
}

/* 页脚 */
.about-footer {
  text-align: center;
  margin-top: var(--size-spacing-4xl);
  padding-top: var(--size-spacing-xl);
  border-top: var(--size-border-width-thin) solid var(--color-border-light);
}

.about-footer p {
  color: var(--color-text-tertiary);
  margin: var(--size-spacing-sm) 0;
}

.copyright {
  font-size: var(--size-font-sm);
}

@media (max-width: 768px) {
  .about-content {
    padding: var(--size-spacing-xl);
  }

  .about-title {
    font-size: var(--size-font-h1);
  }

  .feature-list {
    grid-template-columns: 1fr;
  }

  .contribute-links {
    flex-direction: column;
  }
}
</style>