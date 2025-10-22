import { defineConfig } from '@ldesign/launcher'

export default defineConfig({
  // Vue JSX 插件现在由 SmartPluginManager 自动处理
  // 不需要手动配置

  // Launcher 基础配置
  launcher: {
    preset: 'ldesign',
    mode: 'development',
    logLevel: 'info',
    autoRestart: false,
    debug: false
  },

  // 路径解析配置
  resolve: {
    dedupe: ['vue', 'lucide-vue-next'],
    alias: [
      // 应用内部别名
      { find: '@components', replacement: './src/components', stages: ['dev', 'build', 'preview'] },
      { find: '@utils', replacement: './src/utils', stages: ['dev', 'build', 'preview'] },
      { find: '@assets', replacement: './src/assets', stages: ['dev', 'build', 'preview'] },
      { find: '@styles', replacement: './src/styles', stages: ['dev', 'build', 'preview'] },

      // CSS 样式文件（特殊路径）
      { find: '@ldesign/template/es/index.css', replacement: '../../packages/template/src/styles/index.css', stages: ['dev', 'build'] },
      { find: '@ldesign/i18n/es/index.css', replacement: '../../packages/i18n/src/styles/index.css', stages: ['dev', 'build'] },
      { find: '@ldesign/size/es/index.css', replacement: '../../packages/size/src/styles/index.css', stages: ['dev', 'build'] },
      { find: '@ldesign/color/es/exports/vue.css', replacement: '../../packages/color/es/exports/vue.css', stages: ['dev', 'build'] },
      { find: '@ldesign/color/es/index.css', replacement: '../../packages/color/src/styles/index.css', stages: ['dev', 'build'] },

      // Color 包特殊导出
      { find: '@ldesign/color/plugin', replacement: '../../packages/color/src/plugin', stages: ['dev'] },
      { find: '@ldesign/color/exports/vue', replacement: '../../packages/color/src/exports/vue', stages: ['dev'] },
      { find: '@ldesign/color', replacement: '../../packages/color/src', stages: ['dev'] },

      // Size 包特殊导出
      { find: '@ldesign/size/plugin', replacement: '../../packages/size/src/plugin', stages: ['dev'] },

      // I18n Vue 导出
      { find: '@ldesign/i18n/vue', replacement: '../../packages/i18n/src/vue', stages: ['dev'] },

      // Packages - 核心基础包
      { find: '@ldesign/api', replacement: '../../packages/api/src', stages: ['dev'] },
      { find: '@ldesign/cache', replacement: '../../packages/cache/src', stages: ['dev'] },
      { find: '@ldesign/crypto', replacement: '../../packages/crypto/src', stages: ['dev'] },
      { find: '@ldesign/device', replacement: '../../packages/device/src', stages: ['dev'] },
      { find: '@ldesign/engine', replacement: '../../packages/engine/src', stages: ['dev'] },
      { find: '@ldesign/http', replacement: '../../packages/http/src', stages: ['dev'] },
      { find: '@ldesign/i18n', replacement: '../../packages/i18n/src', stages: ['dev', 'build'] },
      { find: '@ldesign/router', replacement: '../../packages/router/src', stages: ['dev'] },
      { find: '@ldesign/shared', replacement: '../../packages/shared/src', stages: ['dev'] },
      { find: '@ldesign/size', replacement: '../../packages/size/src', stages: ['dev'] },
      { find: '@ldesign/store', replacement: '../../packages/store/src', stages: ['dev'] },
      { find: '@ldesign/template', replacement: '../../packages/template/src', stages: ['dev'] },

      // Libraries - 组件库
      { find: '@ldesign/chart', replacement: '../../libraries/chart/src', stages: ['dev'] },
      { find: '@ldesign/code-editor', replacement: '../../libraries/code-editor/src', stages: ['dev'] },
      { find: '@ldesign/cropper', replacement: '../../libraries/cropper/src', stages: ['dev'] },
      { find: '@ldesign/datepicker', replacement: '../../libraries/datepicker/src', stages: ['dev'] },
      { find: '@ldesign/editor', replacement: '../../libraries/editor/src', stages: ['dev'] },
      { find: '@ldesign/excel', replacement: '../../libraries/excel/src', stages: ['dev'] },
      { find: '@ldesign/flowchart', replacement: '../../libraries/flowchart/src', stages: ['dev'] },
      { find: '@ldesign/form', replacement: '../../libraries/form/src', stages: ['dev'] },
      { find: '@ldesign/grid', replacement: '../../libraries/grid/src', stages: ['dev'] },
      { find: '@ldesign/lottie', replacement: '../../libraries/lottie/src', stages: ['dev'] },
      { find: '@ldesign/lowcode', replacement: '../../libraries/lowcode/src', stages: ['dev'] },
      { find: '@ldesign/map', replacement: '../../libraries/map/src', stages: ['dev'] },
      { find: '@ldesign/office-document', replacement: '../../libraries/office-document/src', stages: ['dev'] },
      { find: '@ldesign/pdf', replacement: '../../libraries/pdf/src', stages: ['dev'] },
      { find: '@ldesign/progress', replacement: '../../libraries/progress/src', stages: ['dev'] },
      { find: '@ldesign/qrcode', replacement: '../../libraries/qrcode/src', stages: ['dev'] },
      { find: '@ldesign/table', replacement: '../../libraries/table/src', stages: ['dev'] },
      { find: '@ldesign/webcomponent', replacement: '../../libraries/webcomponent/src', stages: ['dev'] },
      { find: '@ldesign/word', replacement: '../../libraries/word/src', stages: ['dev'] },

      // Tools - 开发工具
      { find: '@ldesign/builder', replacement: '../../tools/builder/src', stages: ['dev'] },
      { find: '@ldesign/cli', replacement: '../../tools/cli/src', stages: ['dev'] },
      { find: '@ldesign/kit', replacement: '../../tools/kit/src', stages: ['dev'] },
      { find: '@ldesign/launcher', replacement: '../../tools/launcher/src', stages: ['dev'] }
    ]
  },

  // 开发服务器配置
  server: {
    port: 3330,
    host: '0.0.0.0',
    open: false,
    https: false,
    cors: true
  },

  // 预览服务器配置
  preview: {
    port: 4440,
    host: '0.0.0.0',
    open: false,
    https: false,
    cors: true
  },

  // 构建配置
  build: {
    outDir: 'site',
    sourcemap: false,
    minify: 'esbuild',
    target: 'es2020',
    emptyOutDir: true,
    watch: false,
    reportCompressedSize: true,
    commonjsOptions: {
      include: [/lucide-vue-next/, /node_modules/]
    }
  },

  // 依赖优化配置
  optimizeDeps: {
    force: false,
    include: ['lucide-vue-next']
  }
})