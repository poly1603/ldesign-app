<template>
  <div class="concurrency-demo">
    <div class="demo-header">
      <h1>⚡ 并发控制演示</h1>
      <p>展示 Engine 并发控制工具：信号量、限流器、熔断器、请求批处理</p>
    </div>

    <div class="demo-grid">
      <!-- 并发限制器 -->
      <div class="demo-card">
        <div class="card-header">
          <Gauge class="icon" />
          <h3>并发限制器（Concurrency Limiter）</h3>
        </div>
        <div class="card-content">
          <div class="form-group">
            <label>并发数限制</label>
            <input v-model.number="concurrencyLimit" type="number" min="1" max="10" />
          </div>
          <div class="form-group">
            <label>请求数量</label>
            <input v-model.number="requestCount" type="number" min="1" max="20" />
          </div>
          <div class="button-group">
            <button @click="testConcurrency" :disabled="isTesting" class="btn-primary">
              <Play :size="16" />
              开始测试
            </button>
            <button @click="stopConcurrency" class="btn-danger">
              <Square :size="16" />
              停止
            </button>
          </div>
          <div class="progress-info">
            <div class="progress-bar">
              <div class="progress-fill" :style="{ width: `${concurrencyProgress}%` }"></div>
            </div>
            <div class="progress-text">
              进度: {{ completedRequests }} / {{ requestCount }} ({{ concurrencyProgress }}%)
            </div>
          </div>
        </div>
      </div>

      <!-- 信号量 -->
      <div class="demo-card">
        <div class="card-header">
          <Lock class="icon" />
          <h3>信号量（Semaphore）</h3>
        </div>
        <div class="card-content">
          <div class="form-group">
            <label>信号量容量</label>
            <input v-model.number="semaphoreCapacity" type="number" min="1" max="5" />
          </div>
          <div class="semaphore-status">
            <div class="status-item">
              <span>可用</span>
              <span class="value available">{{ availableSlots }}</span>
            </div>
            <div class="status-item">
              <span>使用中</span>
              <span class="value in-use">{{ usedSlots }}</span>
            </div>
            <div class="status-item">
              <span>等待中</span>
              <span class="value waiting">{{ waitingSlots }}</span>
            </div>
          </div>
          <div class="button-group">
            <button @click="acquireSemaphore" class="btn-primary">
              <Download :size="16" />
              获取许可
            </button>
            <button @click="releaseSemaphore" class="btn-secondary">
              <Upload :size="16" />
              释放许可
            </button>
            <button @click="resetSemaphore" class="btn-danger">
              <RefreshCw :size="16" />
              重置
            </button>
          </div>
        </div>
      </div>

      <!-- 速率限制器 -->
      <div class="demo-card">
        <div class="card-header">
          <Clock class="icon" />
          <h3>速率限制器（Rate Limiter）</h3>
        </div>
        <div class="card-content">
          <div class="form-group">
            <label>速率（请求/秒）</label>
            <input v-model.number="rateLimit" type="number" min="1" max="10" />
          </div>
          <div class="form-group">
            <label>时间窗口（秒）</label>
            <input v-model.number="timeWindow" type="number" min="1" max="60" />
          </div>
          <div class="rate-status">
            <div class="status-bar">
              <div class="bar-fill" :style="{ width: `${rateLimitUsage}%` }"></div>
            </div>
            <div class="status-text">
              当前速率: {{ currentRate }} / {{ rateLimit }} 请求/秒
            </div>
          </div>
          <div class="button-group">
            <button @click="sendRequest" :disabled="isRateLimited" class="btn-primary">
              <Send :size="16" />
              发送请求
            </button>
            <button @click="burstRequests" class="btn-secondary">
              <Zap :size="16" />
              爆发请求（10个）
            </button>
          </div>
          <div v-if="rateLimitMessage" class="message" :class="rateLimitMessageType">
            {{ rateLimitMessage }}
          </div>
        </div>
      </div>

      <!-- 熔断器 -->
      <div class="demo-card">
        <div class="card-header">
          <AlertCircle class="icon" />
          <h3>熔断器（Circuit Breaker）</h3>
        </div>
        <div class="card-content">
          <div class="circuit-status">
            <div class="status-indicator" :class="circuitStatus">
              <div class="status-dot"></div>
              <span>{{ circuitStatusText }}</span>
            </div>
          </div>
          <div class="form-group">
            <label>失败阈值</label>
            <input v-model.number="failureThreshold" type="number" min="1" max="10" />
          </div>
          <div class="circuit-stats">
            <div class="stat">成功: {{ circuitStats.success }}</div>
            <div class="stat">失败: {{ circuitStats.failure }}</div>
            <div class="stat">拒绝: {{ circuitStats.rejected }}</div>
          </div>
          <div class="button-group">
            <button @click="testCircuit(true)" class="btn-success">
              <CheckCircle :size="16" />
              成功请求
            </button>
            <button @click="testCircuit(false)" class="btn-danger">
              <XCircle :size="16" />
              失败请求
            </button>
            <button @click="resetCircuit" class="btn-secondary">
              <RefreshCw :size="16" />
              重置熔断器
            </button>
          </div>
        </div>
      </div>

      <!-- 请求批处理 -->
      <div class="demo-card">
        <div class="card-header">
          <Package class="icon" />
          <h3>请求批处理（Batch）</h3>
        </div>
        <div class="card-content">
          <div class="form-group">
            <label>批处理窗口（毫秒）</label>
            <input v-model.number="batchWindow" type="number" min="100" max="5000" step="100" />
          </div>
          <div class="batch-queue">
            <div class="queue-header">
              <span>队列中的请求（{{ batchQueue.length }}）</span>
            </div>
            <div v-if="batchQueue.length === 0" class="empty">队列为空</div>
            <div v-for="(req, index) in batchQueue" :key="index" class="queue-item">
              <span>请求 #{{ req.id }}</span>
              <span class="queue-time">{{ formatTime(req.time) }}</span>
            </div>
          </div>
          <div class="button-group">
            <button @click="addToBatch" class="btn-primary">
              <Plus :size="16" />
              添加请求
            </button>
            <button @click="executeBatch" class="btn-success">
              <Zap :size="16" />
              执行批处理
            </button>
            <button @click="clearBatch" class="btn-danger">
              <Trash2 :size="16" />
              清空队列
            </button>
          </div>
          <div v-if="batchResult" class="result-box">
            {{ batchResult }}
          </div>
        </div>
      </div>

      <!-- 整体统计 -->
      <div class="demo-card full-width">
        <div class="card-header">
          <BarChart3 class="icon" />
          <h3>整体统计</h3>
        </div>
        <div class="card-content">
          <div class="overall-stats">
            <div class="stat-card">
              <div class="stat-icon">📊</div>
              <div class="stat-label">总请求数</div>
              <div class="stat-value">{{ overallStats.totalRequests }}</div>
            </div>
            <div class="stat-card">
              <div class="stat-icon">✅</div>
              <div class="stat-label">成功请求</div>
              <div class="stat-value">{{ overallStats.successRequests }}</div>
            </div>
            <div class="stat-card">
              <div class="stat-icon">❌</div>
              <div class="stat-label">失败请求</div>
              <div class="stat-value">{{ overallStats.failedRequests }}</div>
            </div>
            <div class="stat-card">
              <div class="stat-icon">⏱️</div>
              <div class="stat-label">平均响应时间</div>
              <div class="stat-value">{{ overallStats.avgResponseTime }}ms</div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onUnmounted } from 'vue'
import {
  Gauge, Lock, Clock, AlertCircle, Package, BarChart3,
  Play, Square, Download, Upload, RefreshCw, Send, Zap,
  Plus, Trash2, CheckCircle, XCircle
} from 'lucide-vue-next'

// 并发限制器
const concurrencyLimit = ref(3)
const requestCount = ref(10)
const completedRequests = ref(0)
const isTesting = ref(false)
const concurrencyProgress = computed(() => 
  requestCount.value > 0 ? Math.round((completedRequests.value / requestCount.value) * 100) : 0
)

// 信号量
const semaphoreCapacity = ref(3)
const availableSlots = ref(3)
const usedSlots = computed(() => semaphoreCapacity.value - availableSlots.value)
const waitingSlots = ref(0)

// 速率限制器
const rateLimit = ref(5)
const timeWindow = ref(1)
const currentRate = ref(0)
const rateLimitUsage = computed(() => Math.min((currentRate.value / rateLimit.value) * 100, 100))
const isRateLimited = computed(() => currentRate.value >= rateLimit.value)
const rateLimitMessage = ref('')
const rateLimitMessageType = ref('success')

// 熔断器
const circuitStatus = ref('closed') // closed, open, half-open
const failureThreshold = ref(5)
const circuitStats = ref({
  success: 0,
  failure: 0,
  rejected: 0
})

const circuitStatusText = computed(() => {
  switch (circuitStatus.value) {
    case 'closed': return '关闭（正常）'
    case 'open': return '打开（熔断中）'
    case 'half-open': return '半开（测试中）'
    default: return '未知'
  }
})

// 请求批处理
const batchWindow = ref(1000)
const batchQueue = ref<Array<{ id: number; time: number }>>([])
const batchResult = ref('')
let batchCounter = 0

// 整体统计
const overallStats = ref({
  totalRequests: 0,
  successRequests: 0,
  failedRequests: 0,
  avgResponseTime: 0
})

// 测试并发
async function testConcurrency() {
  isTesting.value = true
  completedRequests.value = 0
  
  const requests = Array.from({ length: requestCount.value }, (_, i) => i)
  const executing: Promise<void>[] = []
  
  for (const i of requests) {
    const p = simulateRequest(i).then(() => {
      completedRequests.value++
    })
    
    executing.push(p)
    
    if (executing.length >= concurrencyLimit.value) {
      await Promise.race(executing)
      const index = executing.findIndex(p => p === undefined)
      if (index !== -1) {
        executing.splice(index, 1)
      }
    }
  }
  
  await Promise.all(executing)
  isTesting.value = false
}

function stopConcurrency() {
  isTesting.value = false
}

async function simulateRequest(id: number): Promise<void> {
  await new Promise(resolve => setTimeout(resolve, Math.random() * 1000 + 500))
  overallStats.value.totalRequests++
  overallStats.value.successRequests++
}

// 信号量操作
function acquireSemaphore() {
  if (availableSlots.value > 0) {
    availableSlots.value--
  } else {
    waitingSlots.value++
  }
}

function releaseSemaphore() {
  if (waitingSlots.value > 0) {
    waitingSlots.value--
  } else if (usedSlots.value > 0) {
    availableSlots.value++
  }
}

function resetSemaphore() {
  availableSlots.value = semaphoreCapacity.value
  waitingSlots.value = 0
}

// 速率限制
let rateResetTimer: number | null = null

function sendRequest() {
  if (isRateLimited.value) {
    rateLimitMessage.value = '⚠️ 速率限制：请求被拒绝'
    rateLimitMessageType.value = 'warning'
    return
  }
  
  currentRate.value++
  rateLimitMessage.value = '✅ 请求成功'
  rateLimitMessageType.value = 'success'
  overallStats.value.totalRequests++
  overallStats.value.successRequests++
  
  // 自动重置速率
  if (!rateResetTimer) {
    rateResetTimer = window.setTimeout(() => {
      currentRate.value = 0
      rateResetTimer = null
    }, timeWindow.value * 1000)
  }
  
  setTimeout(() => rateLimitMessage.value = '', 2000)
}

function burstRequests() {
  for (let i = 0; i < 10; i++) {
    setTimeout(() => sendRequest(), i * 100)
  }
}

// 熔断器测试
function testCircuit(success: boolean) {
  if (circuitStatus.value === 'open') {
    circuitStats.value.rejected++
    overallStats.value.failedRequests++
    return
  }
  
  if (success) {
    circuitStats.value.success++
    overallStats.value.successRequests++
    
    // 如果是半开状态，成功后关闭熔断器
    if (circuitStatus.value === 'half-open') {
      circuitStatus.value = 'closed'
      circuitStats.value.failure = 0
    }
  } else {
    circuitStats.value.failure++
    overallStats.value.failedRequests++
    
    // 达到失败阈值，打开熔断器
    if (circuitStats.value.failure >= failureThreshold.value) {
      circuitStatus.value = 'open'
      
      // 30秒后尝试半开
      setTimeout(() => {
        circuitStatus.value = 'half-open'
      }, 30000)
    }
  }
  
  overallStats.value.totalRequests++
}

function resetCircuit() {
  circuitStatus.value = 'closed'
  circuitStats.value = {
    success: 0,
    failure: 0,
    rejected: 0
  }
}

// 批处理
function addToBatch() {
  batchCounter++
  batchQueue.value.push({
    id: batchCounter,
    time: Date.now()
  })
}

async function executeBatch() {
  if (batchQueue.value.length === 0) {
    batchResult.value = '⚠️ 队列为空'
    return
  }
  
  const count = batchQueue.value.length
  batchQueue.value = []
  batchResult.value = `✅ 批量执行 ${count} 个请求`
  
  overallStats.value.totalRequests += count
  overallStats.value.successRequests += count
  
  setTimeout(() => batchResult.value = '', 3000)
}

function clearBatch() {
  batchQueue.value = []
  batchResult.value = ''
}

function formatTime(timestamp: number) {
  const date = new Date(timestamp)
  return `${String(date.getHours()).padStart(2, '0')}:${String(date.getMinutes()).padStart(2, '0')}:${String(date.getSeconds()).padStart(2, '0')}`
}

// 清理
onUnmounted(() => {
  if (rateResetTimer) {
    clearTimeout(rateResetTimer)
  }
})
</script>

<style scoped>
.concurrency-demo {
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

.demo-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(380px, 1fr));
  gap: 20px;
}

.full-width {
  grid-column: 1 / -1;
}

.demo-card {
  background: var(--color-bg-container);
  border-radius: 12px;
  padding: 20px;
  box-shadow: var(--shadow-md);
}

.card-header {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 20px;
  padding-bottom: 15px;
  border-bottom: 2px solid var(--color-border-default);
}

.card-header .icon {
  color: var(--color-primary-default);
  width: 24px;
  height: 24px;
}

.card-header h3 {
  margin: 0;
  font-size: 18px;
  color: var(--color-text-primary);
}

.card-content {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.form-group label {
  font-size: 14px;
  font-weight: 500;
  color: var(--color-text-secondary);
}

.form-group input,
.form-group select {
  padding: 10px 12px;
  border: 1px solid var(--color-border-default);
  border-radius: 6px;
  font-size: 14px;
}

.button-group {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
}

.btn-primary, .btn-secondary, .btn-danger, .btn-success {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 10px 16px;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-size: 14px;
  transition: all 0.3s;
}

.btn-primary {
  background: var(--color-primary-default);
  color: white;
}

.btn-secondary {
  background: var(--color-bg-layout);
  color: var(--color-text-primary);
  border: 1px solid var(--color-border-default);
}

.btn-danger {
  background: #ff4d4f;
  color: white;
}

.btn-success {
  background: #52c41a;
  color: white;
}

button:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.progress-info {
  margin-top: 10px;
}

.progress-bar {
  height: 8px;
  background: var(--color-bg-layout);
  border-radius: 4px;
  overflow: hidden;
  margin-bottom: 8px;
}

.progress-fill {
  height: 100%;
  background: linear-gradient(90deg, var(--color-primary-default), var(--color-primary-active));
  transition: width 0.3s;
}

.progress-text {
  font-size: 13px;
  color: var(--color-text-secondary);
  text-align: center;
}

.semaphore-status {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 10px;
}

.status-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 15px;
  background: var(--color-bg-layout);
  border-radius: 6px;
}

.status-item .value {
  font-size: 28px;
  font-weight: 700;
  margin-top: 8px;
}

.value.available {
  color: #52c41a;
}

.value.in-use {
  color: #1890ff;
}

.value.waiting {
  color: #faad14;
}

.rate-status {
  padding: 15px;
  background: var(--color-bg-layout);
  border-radius: 6px;
}

.status-bar {
  height: 12px;
  background: var(--color-border-default);
  border-radius: 6px;
  overflow: hidden;
  margin-bottom: 10px;
}

.bar-fill {
  height: 100%;
  background: linear-gradient(90deg, #52c41a, #faad14, #ff4d4f);
  transition: width 0.3s;
}

.status-text {
  font-size: 14px;
  color: var(--color-text-secondary);
  text-align: center;
}

.message {
  padding: 10px;
  border-radius: 6px;
  font-size: 14px;
  text-align: center;
}

.message.success {
  background: rgba(82, 196, 26, 0.1);
  color: #52c41a;
}

.message.warning {
  background: rgba(250, 173, 20, 0.1);
  color: #faad14;
}

.circuit-status {
  padding: 20px;
  background: var(--color-bg-layout);
  border-radius: 6px;
  text-align: center;
}

.status-indicator {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
  font-size: 16px;
  font-weight: 600;
}

.status-indicator.closed {
  color: #52c41a;
}

.status-indicator.open {
  color: #ff4d4f;
}

.status-indicator.half-open {
  color: #faad14;
}

.status-dot {
  width: 12px;
  height: 12px;
  border-radius: 50%;
  background: currentColor;
}

.circuit-stats {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 10px;
}

.circuit-stats .stat {
  padding: 10px;
  background: var(--color-bg-layout);
  border-radius: 6px;
  text-align: center;
  font-size: 14px;
}

.batch-queue {
  border: 1px solid var(--color-border-default);
  border-radius: 6px;
  max-height: 200px;
  overflow-y: auto;
}

.queue-header {
  padding: 10px 12px;
  background: var(--color-bg-layout);
  border-bottom: 1px solid var(--color-border-default);
  font-size: 14px;
  font-weight: 500;
}

.queue-item {
  display: flex;
  justify-content: space-between;
  padding: 8px 12px;
  border-bottom: 1px solid var(--color-border-default);
  font-size: 13px;
}

.queue-item:last-child {
  border-bottom: none;
}

.queue-time {
  color: var(--color-text-tertiary);
  font-family: monospace;
  font-size: 12px;
}

.result-box {
  padding: 12px;
  background: var(--color-bg-layout);
  border-radius: 6px;
  text-align: center;
  font-weight: 500;
}

.overall-stats {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 20px;
}

.stat-card {
  padding: 20px;
  background: var(--color-bg-layout);
  border-radius: 8px;
  text-align: center;
}

.stat-icon {
  font-size: 32px;
  margin-bottom: 10px;
}

.stat-label {
  font-size: 14px;
  color: var(--color-text-secondary);
  margin-bottom: 10px;
}

.stat-value {
  font-size: 28px;
  font-weight: 700;
  color: var(--color-primary-default);
}

.empty {
  padding: 20px;
  text-align: center;
  color: var(--color-text-tertiary);
  font-size: 14px;
}
</style>


