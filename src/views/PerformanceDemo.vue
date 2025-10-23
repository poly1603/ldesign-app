<template>
  <div class="performance-demo">
    <div class="demo-header">
      <h1>⚡ 性能监控仪表板</h1>
      <p>实时监控应用性能指标，展示 Engine 的性能监控能力</p>
    </div>

    <div class="metrics-grid">
      <!-- 性能概览 -->
      <div class="metric-card">
        <div class="metric-header">
          <Activity class="metric-icon" />
          <h3>性能概览</h3>
        </div>
        <div class="metric-content">
          <div class="metric-item">
            <span class="label">启动时间</span>
            <span class="value">{{ bootTime }}ms</span>
          </div>
          <div class="metric-item">
            <span class="label">FPS</span>
            <span class="value" :class="fpsClass">{{ fps }}</span>
          </div>
          <div class="metric-item">
            <span class="label">内存使用</span>
            <span class="value">{{ memoryUsage }}MB</span>
          </div>
        </div>
      </div>

      <!-- 性能标记 -->
      <div class="metric-card">
        <div class="metric-header">
          <Clock class="metric-icon" />
          <h3>性能标记</h3>
        </div>
        <div class="metric-content">
          <div class="marks-list">
            <div v-for="mark in performanceMarks.slice(-5)" :key="mark.name" class="mark-item">
              <span class="mark-name">{{ mark.name }}</span>
              <span class="mark-time">{{ mark.duration }}ms</span>
            </div>
          </div>
          <button @click="addPerformanceMark" class="btn-add">
            <Plus :size="16" />
            添加标记
          </button>
        </div>
      </div>

      <!-- 缓存统计 -->
      <div class="metric-card">
        <div class="metric-header">
          <Database class="metric-icon" />
          <h3>缓存统计</h3>
        </div>
        <div class="metric-content">
          <div class="metric-item">
            <span class="label">缓存条目</span>
            <span class="value">{{ cacheStats.count }}</span>
          </div>
          <div class="metric-item">
            <span class="label">命中率</span>
            <span class="value">{{ cacheStats.hitRate }}%</span>
          </div>
          <div class="metric-item">
            <span class="label">缓存大小</span>
            <span class="value">{{ cacheStats.size }}KB</span>
          </div>
        </div>
      </div>

      <!-- 实时性能 -->
      <div class="metric-card">
        <div class="metric-header">
          <Zap class="metric-icon" />
          <h3>实时监控</h3>
        </div>
        <div class="metric-content">
          <div class="chart-container">
            <canvas ref="chartCanvas" width="300" height="150"></canvas>
          </div>
          <button @click="toggleMonitoring" class="btn-toggle">
            {{ isMonitoring ? '停止监控' : '开始监控' }}
          </button>
        </div>
      </div>
    </div>

    <!-- 性能测试工具 -->
    <div class="test-section">
      <h2>🧪 性能测试工具</h2>
      <div class="test-grid">
        <div class="test-card">
          <h3>渲染性能测试</h3>
          <p>测试大量DOM元素的渲染性能</p>
          <div class="test-controls">
            <input v-model.number="renderCount" type="number" min="100" max="10000" step="100" />
            <button @click="testRender" class="btn-test">
              <Play :size="16" />
              开始测试
            </button>
          </div>
          <div v-if="renderTestResult" class="test-result">
            耗时: {{ renderTestResult }}ms
          </div>
        </div>

        <div class="test-card">
          <h3>计算性能测试</h3>
          <p>测试CPU密集型计算性能</p>
          <div class="test-controls">
            <input v-model.number="computeIterations" type="number" min="1000" max="1000000" step="1000" />
            <button @click="testCompute" class="btn-test">
              <Play :size="16" />
              开始测试
            </button>
          </div>
          <div v-if="computeTestResult" class="test-result">
            耗时: {{ computeTestResult }}ms
          </div>
        </div>

        <div class="test-card">
          <h3>内存压力测试</h3>
          <p>测试内存分配和回收性能</p>
          <div class="test-controls">
            <input v-model.number="memorySize" type="number" min="1" max="100" step="1" />
            <button @click="testMemory" class="btn-test">
              <Play :size="16" />
              开始测试
            </button>
          </div>
          <div v-if="memoryTestResult" class="test-result">
            峰值内存: {{ memoryTestResult }}MB
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { Activity, Clock, Database, Zap, Plus, Play } from 'lucide-vue-next'

// 性能指标
const bootTime = ref(0)
const fps = ref(60)
const memoryUsage = ref(0)
const performanceMarks = ref<Array<{ name: string; duration: number }>>([])
const isMonitoring = ref(false)

// 缓存统计
const cacheStats = ref({
  count: 0,
  hitRate: 0,
  size: 0
})

// 测试参数
const renderCount = ref(1000)
const computeIterations = ref(10000)
const memorySize = ref(10)

// 测试结果
const renderTestResult = ref<number | null>(null)
const computeTestResult = ref<number | null>(null)
const memoryTestResult = ref<number | null>(null)

// 图表
const chartCanvas = ref<HTMLCanvasElement | null>(null)
let chartContext: CanvasRenderingContext2D | null = null
const fpsHistory = ref<number[]>([])

// FPS 样式
const fpsClass = computed(() => {
  if (fps.value >= 50) return 'good'
  if (fps.value >= 30) return 'warning'
  return 'bad'
})

// 监控定时器
let monitoringInterval: number | null = null
let fpsInterval: number | null = null
let lastFrameTime = 0
let frameCount = 0

// 初始化
onMounted(() => {
  // 获取启动时间
  try {
    const entries = performance.getEntriesByName('app-boot-time')
    if (entries.length > 0) {
      bootTime.value = Math.round(entries[0].duration)
    }
  } catch (e) {
    console.warn('无法获取启动时间:', e)
  }

  // 初始化图表
  if (chartCanvas.value) {
    chartContext = chartCanvas.value.getContext('2d')
  }

  // 更新内存使用
  updateMemoryUsage()

  // 更新缓存统计
  updateCacheStats()

  // 开始FPS监控
  startFPSMonitoring()
})

onUnmounted(() => {
  stopMonitoring()
  stopFPSMonitoring()
})

// 更新内存使用
function updateMemoryUsage() {
  if ('memory' in performance) {
    const memory = (performance as any).memory
    memoryUsage.value = Math.round(memory.usedJSHeapSize / 1024 / 1024)
  }
}

// 更新缓存统计
function updateCacheStats() {
  try {
    // 模拟缓存统计
    let totalSize = 0
    let count = 0
    
    for (let i = 0; i < localStorage.length; i++) {
      const key = localStorage.key(i)
      if (key?.startsWith('ldesign_')) {
        const value = localStorage.getItem(key) || ''
        totalSize += (key.length + value.length) * 2 // UTF-16
        count++
      }
    }
    
    cacheStats.value = {
      count,
      hitRate: Math.round(Math.random() * 30 + 70), // 模拟命中率
      size: Math.round(totalSize / 1024)
    }
  } catch (e) {
    console.warn('无法获取缓存统计:', e)
  }
}

// FPS 监控
function startFPSMonitoring() {
  let frames = 0
  let lastTime = performance.now()

  function countFrame() {
    frames++
    const currentTime = performance.now()
    
    if (currentTime >= lastTime + 1000) {
      fps.value = Math.round((frames * 1000) / (currentTime - lastTime))
      fpsHistory.value.push(fps.value)
      if (fpsHistory.value.length > 60) {
        fpsHistory.value.shift()
      }
      
      updateChart()
      frames = 0
      lastTime = currentTime
    }
    
    fpsInterval = requestAnimationFrame(countFrame)
  }
  
  fpsInterval = requestAnimationFrame(countFrame)
}

function stopFPSMonitoring() {
  if (fpsInterval) {
    cancelAnimationFrame(fpsInterval)
    fpsInterval = null
  }
}

// 图表绘制
function updateChart() {
  if (!chartContext || !chartCanvas.value) return
  
  const canvas = chartCanvas.value
  const ctx = chartContext
  const width = canvas.width
  const height = canvas.height
  
  // 清空画布
  ctx.clearRect(0, 0, width, height)
  
  // 绘制背景网格
  ctx.strokeStyle = '#e0e0e0'
  ctx.lineWidth = 1
  for (let i = 0; i <= 60; i += 10) {
    const y = height - (i / 60) * height
    ctx.beginPath()
    ctx.moveTo(0, y)
    ctx.lineTo(width, y)
    ctx.stroke()
  }
  
  // 绘制FPS曲线
  if (fpsHistory.value.length > 1) {
    ctx.strokeStyle = '#667eea'
    ctx.lineWidth = 2
    ctx.beginPath()
    
    const step = width / (fpsHistory.value.length - 1)
    fpsHistory.value.forEach((value, index) => {
      const x = index * step
      const y = height - (value / 60) * height
      
      if (index === 0) {
        ctx.moveTo(x, y)
      } else {
        ctx.lineTo(x, y)
      }
    })
    
    ctx.stroke()
  }
}

// 添加性能标记
function addPerformanceMark() {
  const markName = `custom-mark-${Date.now()}`
  performance.mark(markName)
  
  const entries = performance.getEntriesByName(markName)
  if (entries.length > 0) {
    performanceMarks.value.push({
      name: markName,
      duration: Math.round(entries[0].startTime)
    })
  }
}

// 切换监控状态
function toggleMonitoring() {
  if (isMonitoring.value) {
    stopMonitoring()
  } else {
    startMonitoring()
  }
}

function startMonitoring() {
  isMonitoring.value = true
  monitoringInterval = window.setInterval(() => {
    updateMemoryUsage()
    updateCacheStats()
  }, 1000)
}

function stopMonitoring() {
  isMonitoring.value = false
  if (monitoringInterval) {
    clearInterval(monitoringInterval)
    monitoringInterval = null
  }
}

// 性能测试
function testRender() {
  const startTime = performance.now()
  
  // 创建大量DOM元素
  const container = document.createElement('div')
  for (let i = 0; i < renderCount.value; i++) {
    const div = document.createElement('div')
    div.textContent = `Item ${i}`
    container.appendChild(div)
  }
  
  const endTime = performance.now()
  renderTestResult.value = Math.round(endTime - startTime)
}

function testCompute() {
  const startTime = performance.now()
  
  // CPU密集型计算
  let result = 0
  for (let i = 0; i < computeIterations.value; i++) {
    result += Math.sqrt(i) * Math.sin(i)
  }
  
  const endTime = performance.now()
  computeTestResult.value = Math.round(endTime - startTime)
}

function testMemory() {
  const arrays: any[] = []
  const initialMemory = ('memory' in performance) 
    ? (performance as any).memory.usedJSHeapSize / 1024 / 1024
    : 0
  
  // 分配内存
  for (let i = 0; i < memorySize.value; i++) {
    arrays.push(new Array(100000).fill(Math.random()))
  }
  
  const peakMemory = ('memory' in performance)
    ? (performance as any).memory.usedJSHeapSize / 1024 / 1024
    : 0
  
  memoryTestResult.value = Math.round(peakMemory - initialMemory)
  
  // 清理
  arrays.length = 0
}
</script>

<style scoped>
.performance-demo {
  padding: 20px;
  max-width: 1400px;
  margin: 0 auto;
}

.demo-header {
  text-align: center;
  margin-bottom: 40px;
}

.demo-header h1 {
  font-size: 36px;
  color: var(--color-text-primary);
  margin: 0 0 10px 0;
}

.demo-header p {
  color: var(--color-text-secondary);
  font-size: 16px;
}

.metrics-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 20px;
  margin-bottom: 40px;
}

.metric-card {
  background: var(--color-bg-container);
  border-radius: 12px;
  padding: 20px;
  box-shadow: var(--shadow-md);
}

.metric-header {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 20px;
}

.metric-icon {
  color: var(--color-primary-default);
  width: 24px;
  height: 24px;
}

.metric-header h3 {
  margin: 0;
  font-size: 18px;
  color: var(--color-text-primary);
}

.metric-content {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.metric-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 0;
  border-bottom: 1px solid var(--color-border-default);
}

.metric-item:last-child {
  border-bottom: none;
}

.label {
  color: var(--color-text-secondary);
  font-size: 14px;
}

.value {
  font-size: 20px;
  font-weight: 600;
  color: var(--color-text-primary);
}

.value.good {
  color: #52c41a;
}

.value.warning {
  color: #faad14;
}

.value.bad {
  color: #ff4d4f;
}

.marks-list {
  max-height: 150px;
  overflow-y: auto;
}

.mark-item {
  display: flex;
  justify-content: space-between;
  padding: 8px 0;
  font-size: 14px;
}

.mark-name {
  color: var(--color-text-secondary);
  flex: 1;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.mark-time {
  color: var(--color-primary-default);
  font-weight: 600;
  margin-left: 10px;
}

.btn-add, .btn-toggle, .btn-test {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
  padding: 8px 16px;
  background: var(--color-primary-default);
  color: white;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-size: 14px;
  transition: all 0.3s;
}

.btn-add:hover, .btn-toggle:hover, .btn-test:hover {
  background: var(--color-primary-hover);
  transform: translateY(-2px);
}

.chart-container {
  width: 100%;
  height: 150px;
  border: 1px solid var(--color-border-default);
  border-radius: 8px;
  overflow: hidden;
}

.chart-container canvas {
  display: block;
  width: 100%;
  height: 100%;
}

.test-section {
  margin-top: 40px;
}

.test-section h2 {
  text-align: center;
  font-size: 28px;
  color: var(--color-text-primary);
  margin-bottom: 30px;
}

.test-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 20px;
}

.test-card {
  background: var(--color-bg-container);
  border-radius: 12px;
  padding: 20px;
  box-shadow: var(--shadow-md);
}

.test-card h3 {
  font-size: 18px;
  color: var(--color-text-primary);
  margin: 0 0 10px 0;
}

.test-card p {
  color: var(--color-text-secondary);
  font-size: 14px;
  margin: 0 0 20px 0;
}

.test-controls {
  display: flex;
  gap: 10px;
  margin-bottom: 15px;
}

.test-controls input {
  flex: 1;
  padding: 8px 12px;
  border: 1px solid var(--color-border-default);
  border-radius: 6px;
  font-size: 14px;
}

.test-result {
  padding: 10px;
  background: var(--color-bg-layout);
  border-radius: 6px;
  text-align: center;
  font-weight: 600;
  color: var(--color-primary-default);
}
</style>


