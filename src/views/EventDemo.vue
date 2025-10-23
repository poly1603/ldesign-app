<template>
  <div class="event-demo">
    <div class="demo-header">
      <h1>📡 事件系统演示</h1>
      <p>展示 Engine 事件系统的强大功能：发布订阅、优先级、事件回放</p>
    </div>

    <div class="demo-grid">
      <!-- 事件发布 -->
      <div class="demo-card">
        <div class="card-header">
          <Send class="icon" />
          <h3>事件发布（Emit）</h3>
        </div>
        <div class="card-content">
          <div class="form-group">
            <label>事件名称</label>
            <input v-model="emitEventName" placeholder="user:login" />
          </div>
          <div class="form-group">
            <label>事件数据（JSON）</label>
            <textarea v-model="emitEventData" rows="3" placeholder='{"userId": "123"}'></textarea>
          </div>
          <div class="button-group">
            <button @click="emitEvent" class="btn-primary">
              <Zap :size="16" />
              发送事件
            </button>
            <button @click="emitEventOnce" class="btn-secondary">
              <PlayCircle :size="16" />
              发送一次
            </button>
          </div>
        </div>
      </div>

      <!-- 事件订阅 -->
      <div class="demo-card">
        <div class="card-header">
          <Radio class="icon" />
          <h3>事件订阅（On）</h3>
        </div>
        <div class="card-content">
          <div class="form-group">
            <label>订阅事件名称</label>
            <input v-model="subscribeEventName" placeholder="user:login" />
          </div>
          <div class="form-group">
            <label>优先级</label>
            <select v-model.number="priority">
              <option :value="100">高（100）</option>
              <option :value="50">中（50）</option>
              <option :value="0">低（0）</option>
            </select>
          </div>
          <div class="button-group">
            <button @click="subscribe" class="btn-primary">
              <Plus :size="16" />
              订阅事件
            </button>
            <button @click="subscribeOnce" class="btn-secondary">
              <Disc :size="16" />
              订阅一次
            </button>
            <button @click="unsubscribeAll" class="btn-danger">
              <X :size="16" />
              取消所有订阅
            </button>
          </div>
          <div class="subscribers-list">
            <div class="list-header">
              <span>当前订阅（{{ subscribers.length }}）</span>
            </div>
            <div v-if="subscribers.length === 0" class="empty">暂无订阅</div>
            <div v-for="(sub, index) in subscribers" :key="index" class="subscriber-item">
              <span>{{ sub.event }}</span>
              <span class="priority-badge">优先级: {{ sub.priority }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- 事件日志 -->
      <div class="demo-card full-width">
        <div class="card-header">
          <FileText class="icon" />
          <h3>事件日志</h3>
        </div>
        <div class="card-content">
          <div class="log-controls">
            <button @click="clearLog" class="btn-small">
              <Trash2 :size="14" />
              清空日志
            </button>
            <button @click="exportLog" class="btn-small">
              <Download :size="14" />
              导出日志
            </button>
          </div>
          <div class="log-container">
            <div v-if="eventLog.length === 0" class="empty">暂无事件日志</div>
            <div v-for="(log, index) in eventLog" :key="index" class="log-item" :class="`log-${log.type}`">
              <span class="log-time">{{ formatTime(log.time) }}</span>
              <span class="log-type">{{ log.type === 'emit' ? '发送' : '接收' }}</span>
              <span class="log-event">{{ log.event }}</span>
              <span class="log-data">{{ log.data }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- 事件回放 -->
      <div class="demo-card">
        <div class="card-header">
          <Repeat class="icon" />
          <h3>事件回放（Replay）</h3>
        </div>
        <div class="card-content">
          <div class="replay-info">
            <div class="info-item">
              <span>录制的事件</span>
              <span class="value">{{ recordedEvents.length }}</span>
            </div>
            <div class="info-item">
              <span>回放状态</span>
              <span class="value" :class="{ active: isReplaying }">
                {{ isReplaying ? '播放中' : '已停止' }}
              </span>
            </div>
          </div>
          <div class="button-group">
            <button @click="startRecording" :disabled="isRecording" class="btn-primary">
              <Circle :size="16" />
              开始录制
            </button>
            <button @click="stopRecording" :disabled="!isRecording" class="btn-danger">
              <Square :size="16" />
              停止录制
            </button>
            <button @click="replayEvents" :disabled="recordedEvents.length === 0 || isReplaying" class="btn-secondary">
              <Play :size="16" />
              回放事件
            </button>
            <button @click="clearRecording" class="btn-danger">
              <Trash2 :size="16" />
              清空录制
            </button>
          </div>
          <div v-if="isRecording" class="recording-indicator">
            <div class="recording-dot"></div>
            <span>录制中...</span>
          </div>
        </div>
      </div>

      <!-- 事件统计 -->
      <div class="demo-card">
        <div class="card-header">
          <BarChart3 class="icon" />
          <h3>事件统计</h3>
        </div>
        <div class="card-content">
          <div class="stats-grid">
            <div class="stat-item">
              <div class="stat-label">总事件数</div>
              <div class="stat-value">{{ eventStats.total }}</div>
            </div>
            <div class="stat-item">
              <div class="stat-label">订阅者数</div>
              <div class="stat-value">{{ eventStats.subscribers }}</div>
            </div>
            <div class="stat-item">
              <div class="stat-label">发送次数</div>
              <div class="stat-value">{{ eventStats.emitted }}</div>
            </div>
            <div class="stat-item">
              <div class="stat-label">接收次数</div>
              <div class="stat-value">{{ eventStats.received }}</div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import {
  Send, Radio, FileText, Repeat, BarChart3,
  Zap, PlayCircle, Plus, Disc, X, Trash2, Download,
  Circle, Square, Play
} from 'lucide-vue-next'

// 事件发布
const emitEventName = ref('user:login')
const emitEventData = ref('{"userId": "123", "username": "admin"}')

// 事件订阅
const subscribeEventName = ref('user:login')
const priority = ref(50)
const subscribers = ref<Array<{ event: string; priority: number }>>([])

// 事件日志
const eventLog = ref<Array<{ time: number; type: string; event: string; data: string }>>([])

// 事件回放
const recordedEvents = ref<Array<{ event: string; data: any; time: number }>>([])
const isRecording = ref(false)
const isReplaying = ref(false)

// 事件统计
const eventStats = ref({
  total: 0,
  subscribers: 0,
  emitted: 0,
  received: 0
})

// 发送事件
function emitEvent() {
  try {
    const data = JSON.parse(emitEventData.value)
    
    // 记录日志
    eventLog.value.push({
      time: Date.now(),
      type: 'emit',
      event: emitEventName.value,
      data: JSON.stringify(data)
    })
    
    // 如果正在录制，记录事件
    if (isRecording.value) {
      recordedEvents.value.push({
        event: emitEventName.value,
        data,
        time: Date.now()
      })
    }
    
    // 触发订阅者
    triggerSubscribers(emitEventName.value, data)
    
    eventStats.value.emitted++
    eventStats.value.total++
  } catch (error) {
    console.error('JSON 解析错误:', error)
  }
}

// 发送一次
function emitEventOnce() {
  emitEvent()
}

// 订阅事件
function subscribe() {
  subscribers.value.push({
    event: subscribeEventName.value,
    priority: priority.value
  })
  
  // 排序（优先级高的在前）
  subscribers.value.sort((a, b) => b.priority - a.priority)
  
  eventStats.value.subscribers = subscribers.value.length
}

// 订阅一次
function subscribeOnce() {
  subscribe()
}

// 取消所有订阅
function unsubscribeAll() {
  subscribers.value = []
  eventStats.value.subscribers = 0
}

// 触发订阅者
function triggerSubscribers(eventName: string, data: any) {
  subscribers.value
    .filter(sub => sub.event === eventName || sub.event === '*')
    .forEach(sub => {
      eventLog.value.push({
        time: Date.now(),
        type: 'receive',
        event: eventName,
        data: `订阅者收到（优先级${sub.priority}）`
      })
      eventStats.value.received++
    })
}

// 清空日志
function clearLog() {
  eventLog.value = []
}

// 导出日志
function exportLog() {
  const json = JSON.stringify(eventLog.value, null, 2)
  const blob = new Blob([json], { type: 'application/json' })
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = `event-log-${Date.now()}.json`
  a.click()
  URL.revokeObjectURL(url)
}

// 开始录制
function startRecording() {
  isRecording.value = true
  recordedEvents.value = []
}

// 停止录制
function stopRecording() {
  isRecording.value = false
}

// 回放事件
async function replayEvents() {
  if (recordedEvents.value.length === 0 || isReplaying.value) return
  
  isReplaying.value = true
  
  for (const event of recordedEvents.value) {
    await new Promise(resolve => setTimeout(resolve, 500))
    
    eventLog.value.push({
      time: Date.now(),
      type: 'emit',
      event: event.event,
      data: `[回放] ${JSON.stringify(event.data)}`
    })
    
    triggerSubscribers(event.event, event.data)
  }
  
  isReplaying.value = false
}

// 清空录制
function clearRecording() {
  recordedEvents.value = []
  isRecording.value = false
  isReplaying.value = false
}

// 格式化时间
function formatTime(timestamp: number) {
  const date = new Date(timestamp)
  return `${String(date.getHours()).padStart(2, '0')}:${String(date.getMinutes()).padStart(2, '0')}:${String(date.getSeconds()).padStart(2, '0')}`
}
</script>

<style scoped>
.event-demo {
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
  grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
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
.form-group textarea,
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

.btn-primary, .btn-secondary, .btn-danger, .btn-small {
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

.btn-primary:hover:not(:disabled) {
  background: var(--color-primary-hover);
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

button:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.btn-small {
  padding: 6px 12px;
  font-size: 12px;
}

.subscribers-list, .log-container {
  border: 1px solid var(--color-border-default);
  border-radius: 6px;
  overflow: hidden;
}

.list-header, .log-controls {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 10px 12px;
  background: var(--color-bg-layout);
  border-bottom: 1px solid var(--color-border-default);
  font-size: 14px;
  font-weight: 500;
}

.log-controls {
  gap: 10px;
}

.empty {
  padding: 20px;
  text-align: center;
  color: var(--color-text-tertiary);
  font-size: 14px;
}

.subscriber-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 10px 12px;
  border-bottom: 1px solid var(--color-border-default);
  font-size: 13px;
}

.subscriber-item:last-child {
  border-bottom: none;
}

.priority-badge {
  padding: 4px 8px;
  background: var(--color-primary-default);
  color: white;
  border-radius: 4px;
  font-size: 12px;
}

.log-container {
  max-height: 300px;
  overflow-y: auto;
}

.log-item {
  display: grid;
  grid-template-columns: 80px 60px 150px 1fr;
  gap: 10px;
  padding: 8px 12px;
  border-bottom: 1px solid var(--color-border-default);
  font-size: 13px;
  font-family: monospace;
}

.log-item:last-child {
  border-bottom: none;
}

.log-emit {
  background: rgba(24, 144, 255, 0.05);
}

.log-receive {
  background: rgba(82, 196, 26, 0.05);
}

.log-time {
  color: var(--color-text-tertiary);
}

.log-type {
  font-weight: 600;
}

.log-emit .log-type {
  color: #1890ff;
}

.log-receive .log-type {
  color: #52c41a;
}

.log-event {
  color: var(--color-primary-default);
}

.log-data {
  color: var(--color-text-secondary);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.replay-info {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 10px;
}

.info-item {
  display: flex;
  justify-content: space-between;
  padding: 10px;
  background: var(--color-bg-layout);
  border-radius: 6px;
}

.info-item .value {
  font-weight: 600;
  color: var(--color-primary-default);
}

.info-item .value.active {
  color: #52c41a;
}

.recording-indicator {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px;
  background: rgba(255, 77, 79, 0.1);
  border-radius: 6px;
  color: #ff4d4f;
  font-weight: 500;
}

.recording-dot {
  width: 10px;
  height: 10px;
  background: #ff4d4f;
  border-radius: 50%;
  animation: pulse 1.5s infinite;
}

@keyframes pulse {
  0%, 100% {
    opacity: 1;
    transform: scale(1);
  }
  50% {
    opacity: 0.5;
    transform: scale(1.2);
  }
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 10px;
}

.stat-item {
  padding: 15px;
  background: var(--color-bg-layout);
  border-radius: 6px;
  text-align: center;
}

.stat-label {
  font-size: 12px;
  color: var(--color-text-tertiary);
  margin-bottom: 8px;
}

.stat-value {
  font-size: 24px;
  font-weight: 700;
  color: var(--color-primary-default);
}
</style>


