<template>
  <div class="state-demo">
    <div class="demo-header">
      <h1>🔄 状态管理演示</h1>
      <p>展示 Engine StateManager 的强大功能：状态 CRUD、时间旅行、持久化</p>
    </div>

    <div class="demo-grid">
      <!-- 状态 CRUD 操作 -->
      <div class="demo-card">
        <div class="card-header">
          <Database class="icon" />
          <h3>状态 CRUD 操作</h3>
        </div>
        <div class="card-content">
          <div class="form-group">
            <label>键名</label>
            <input v-model="stateKey" placeholder="例如: user.name" />
          </div>
          <div class="form-group">
            <label>值（JSON）</label>
            <textarea v-model="stateValue" placeholder='{"name": "张三"}' rows="3"></textarea>
          </div>
          <div class="button-group">
            <button @click="setState" class="btn-primary">
              <Plus :size="16" />
              设置状态
            </button>
            <button @click="getState" class="btn-secondary">
              <Search :size="16" />
              获取状态
            </button>
            <button @click="removeState" class="btn-danger">
              <Trash2 :size="16" />
              删除状态
            </button>
          </div>
          <div v-if="currentState" class="result-box">
            <strong>当前值:</strong>
            <pre>{{ currentState }}</pre>
          </div>
        </div>
      </div>

      <!-- 状态监听 -->
      <div class="demo-card">
        <div class="card-header">
          <Bell class="icon" />
          <h3>状态监听（Watch）</h3>
        </div>
        <div class="card-content">
          <div class="form-group">
            <label>监听键名</label>
            <input v-model="watchKey" placeholder="例如: user" />
          </div>
          <div class="button-group">
            <button @click="startWatch" class="btn-primary">
              <Play :size="16" />
              开始监听
            </button>
            <button @click="stopWatch" class="btn-danger">
              <StopCircle :size="16" />
              停止监听
            </button>
          </div>
          <div class="events-list">
            <div class="list-header">
              <span>监听事件（最近5条）</span>
              <button @click="clearEvents" class="btn-small">
                <X :size="14" />
              </button>
            </div>
            <div v-if="watchEvents.length === 0" class="empty">暂无监听事件</div>
            <div v-for="(event, index) in watchEvents.slice(-5)" :key="index" class="event-item">
              <span class="event-time">{{ formatTime(event.time) }}</span>
              <span class="event-data">{{ event.data }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- 时间旅行 -->
      <div class="demo-card">
        <div class="card-header">
          <History class="icon" />
          <h3>时间旅行（Time Travel）</h3>
        </div>
        <div class="card-content">
          <div class="history-info">
            <div class="info-item">
              <span>历史记录</span>
              <span class="value">{{ historyCount }}</span>
            </div>
            <div class="info-item">
              <span>当前位置</span>
              <span class="value">{{ currentIndex + 1 }} / {{ historyCount }}</span>
            </div>
          </div>
          <div class="button-group">
            <button @click="undo" :disabled="!canUndo" class="btn-secondary">
              <Undo :size="16" />
              撤销
            </button>
            <button @click="redo" :disabled="!canRedo" class="btn-secondary">
              <Redo :size="16" />
              重做
            </button>
            <button @click="clearHistory" class="btn-danger">
              <Trash2 :size="16" />
              清空历史
            </button>
          </div>
          <div class="timeline">
            <div 
              v-for="(item, index) in history" 
              :key="index"
              class="timeline-item"
              :class="{ active: index === currentIndex }"
            >
              <div class="timeline-dot"></div>
              <div class="timeline-content">
                <div class="timeline-title">{{ item.action }}</div>
                <div class="timeline-time">{{ formatTime(item.time) }}</div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- 状态持久化 -->
      <div class="demo-card">
        <div class="card-header">
          <Save class="icon" />
          <h3>状态持久化</h3>
        </div>
        <div class="card-content">
          <div class="form-group">
            <label>持久化键名</label>
            <input v-model="persistKey" placeholder="user.settings" />
          </div>
          <div class="form-group">
            <label>持久化数据</label>
            <textarea v-model="persistData" placeholder='{"theme": "dark"}' rows="3"></textarea>
          </div>
          <div class="button-group">
            <button @click="saveToStorage" class="btn-primary">
              <Download :size="16" />
              保存到 LocalStorage
            </button>
            <button @click="loadFromStorage" class="btn-secondary">
              <Upload :size="16" />
              从 LocalStorage 加载
            </button>
            <button @click="clearStorage" class="btn-danger">
              <Trash2 :size="16" />
              清除存储
            </button>
          </div>
          <div v-if="persistResult" class="result-box">
            <strong>{{ persistResult }}</strong>
          </div>
        </div>
      </div>

      <!-- 批量操作 -->
      <div class="demo-card">
        <div class="card-header">
          <Layers class="icon" />
          <h3>批量操作</h3>
        </div>
        <div class="card-content">
          <div class="form-group">
            <label>批量数据（JSON）</label>
            <textarea v-model="batchData" rows="5" placeholder='{
  "user.name": "张三",
  "user.age": 25,
  "user.role": "admin"
}'></textarea>
          </div>
          <div class="button-group">
            <button @click="batchSet" class="btn-primary">
              <Zap :size="16" />
              批量设置
            </button>
            <button @click="batchGet" class="btn-secondary">
              <Package :size="16" />
              批量获取
            </button>
            <button @click="getAllStates" class="btn-info">
              <List :size="16" />
              查看所有状态
            </button>
          </div>
          <div v-if="allStates" class="result-box">
            <strong>所有状态:</strong>
            <pre>{{ allStates }}</pre>
          </div>
        </div>
      </div>

      <!-- 状态统计 -->
      <div class="demo-card">
        <div class="card-header">
          <BarChart3 class="icon" />
          <h3>状态统计</h3>
        </div>
        <div class="card-content">
          <div class="stats-grid">
            <div class="stat-item">
              <div class="stat-label">状态总数</div>
              <div class="stat-value">{{ stats.total }}</div>
            </div>
            <div class="stat-item">
              <div class="stat-label">监听器数量</div>
              <div class="stat-value">{{ stats.watchers }}</div>
            </div>
            <div class="stat-item">
              <div class="stat-label">更新次数</div>
              <div class="stat-value">{{ stats.updates }}</div>
            </div>
            <div class="stat-item">
              <div class="stat-label">内存占用</div>
              <div class="stat-value">{{ stats.memory }}KB</div>
            </div>
          </div>
          <button @click="refreshStats" class="btn-secondary full-width">
            <RefreshCw :size="16" />
            刷新统计
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { 
  Database, Bell, History, Save, Layers, BarChart3,
  Plus, Search, Trash2, Play, StopCircle, X,
  Undo, Redo, Download, Upload, Zap, Package, List, RefreshCw
} from 'lucide-vue-next'

// 模拟的状态存储（实际应该使用 engine.state）
const stateStore = ref<Record<string, any>>({})

// 表单数据
const stateKey = ref('user.name')
const stateValue = ref('{"name": "张三", "age": 25}')
const currentState = ref<any>(null)

// 监听相关
const watchKey = ref('user')
const watchEvents = ref<Array<{ time: number; data: string }>>([])
let unwatchFn: (() => void) | null = null

// 时间旅行
const history = ref<Array<{ action: string; time: number; state: any }>>([])
const currentIndex = ref(-1)

const canUndo = computed(() => currentIndex.value > 0)
const canRedo = computed(() => currentIndex.value < history.value.length - 1)
const historyCount = computed(() => history.value.length)

// 持久化
const persistKey = ref('app.settings')
const persistData = ref('{"theme": "dark", "lang": "zh-CN"}')
const persistResult = ref('')

// 批量操作
const batchData = ref(`{
  "user.name": "李四",
  "user.age": 30,
  "user.role": "admin"
}`)
const allStates = ref<string>('')

// 统计信息
const stats = ref({
  total: 0,
  watchers: 0,
  updates: 0,
  memory: 0
})

// 设置状态
function setState() {
  try {
    const value = JSON.parse(stateValue.value)
    setNestedValue(stateStore.value, stateKey.value, value)
    currentState.value = value
    
    // 添加到历史
    addToHistory('设置状态: ' + stateKey.value, stateStore.value)
    
    // 触发监听
    triggerWatchers(stateKey.value, value)
    
    stats.value.updates++
  } catch (error) {
    console.error('JSON 解析错误:', error)
    currentState.value = '错误: JSON 格式不正确'
  }
}

// 获取状态
function getState() {
  const value = getNestedValue(stateStore.value, stateKey.value)
  currentState.value = value !== undefined ? value : '未找到该状态'
}

// 删除状态
function removeState() {
  deleteNestedValue(stateStore.value, stateKey.value)
  currentState.value = '已删除'
  addToHistory('删除状态: ' + stateKey.value, stateStore.value)
  stats.value.updates++
}

// 开始监听
function startWatch() {
  if (unwatchFn) {
    unwatchFn()
  }
  
  // 模拟监听
  unwatchFn = () => {
    console.log('停止监听:', watchKey.value)
  }
  
  watchEvents.value.push({
    time: Date.now(),
    data: `开始监听 ${watchKey.value}`
  })
  
  stats.value.watchers++
}

// 停止监听
function stopWatch() {
  if (unwatchFn) {
    unwatchFn()
    unwatchFn = null
  }
  
  watchEvents.value.push({
    time: Date.now(),
    data: `停止监听 ${watchKey.value}`
  })
  
  stats.value.watchers = Math.max(0, stats.value.watchers - 1)
}

// 清除事件
function clearEvents() {
  watchEvents.value = []
}

// 触发监听器（模拟）
function triggerWatchers(key: string, value: any) {
  if (watchKey.value && key.startsWith(watchKey.value)) {
    watchEvents.value.push({
      time: Date.now(),
      data: `${key} 变更为: ${JSON.stringify(value)}`
    })
  }
}

// 时间旅行 - 撤销
function undo() {
  if (canUndo.value) {
    currentIndex.value--
    restoreState(history.value[currentIndex.value].state)
  }
}

// 时间旅行 - 重做
function redo() {
  if (canRedo.value) {
    currentIndex.value++
    restoreState(history.value[currentIndex.value].state)
  }
}

// 清空历史
function clearHistory() {
  history.value = []
  currentIndex.value = -1
}

// 添加到历史
function addToHistory(action: string, state: any) {
  // 如果不在最新位置，删除后面的历史
  if (currentIndex.value < history.value.length - 1) {
    history.value = history.value.slice(0, currentIndex.value + 1)
  }
  
  history.value.push({
    action,
    time: Date.now(),
    state: JSON.parse(JSON.stringify(state))
  })
  
  currentIndex.value = history.value.length - 1
  
  // 限制历史记录数量
  if (history.value.length > 50) {
    history.value.shift()
    currentIndex.value--
  }
}

// 恢复状态
function restoreState(state: any) {
  stateStore.value = JSON.parse(JSON.stringify(state))
}

// 保存到 LocalStorage
function saveToStorage() {
  try {
    const data = JSON.parse(persistData.value)
    localStorage.setItem(`ldesign_state_${persistKey.value}`, JSON.stringify(data))
    persistResult.value = '✅ 保存成功'
    setTimeout(() => persistResult.value = '', 2000)
  } catch (error) {
    persistResult.value = '❌ JSON 格式错误'
  }
}

// 从 LocalStorage 加载
function loadFromStorage() {
  const data = localStorage.getItem(`ldesign_state_${persistKey.value}`)
  if (data) {
    persistData.value = data
    persistResult.value = '✅ 加载成功'
    setTimeout(() => persistResult.value = '', 2000)
  } else {
    persistResult.value = '❌ 未找到数据'
  }
}

// 清除存储
function clearStorage() {
  localStorage.removeItem(`ldesign_state_${persistKey.value}`)
  persistResult.value = '✅ 已清除'
  setTimeout(() => persistResult.value = '', 2000)
}

// 批量设置
function batchSet() {
  try {
    const data = JSON.parse(batchData.value)
    Object.entries(data).forEach(([key, value]) => {
      setNestedValue(stateStore.value, key, value)
    })
    addToHistory('批量设置状态', stateStore.value)
    stats.value.updates += Object.keys(data).length
    allStates.value = '✅ 批量设置成功'
  } catch (error) {
    allStates.value = '❌ JSON 格式错误'
  }
}

// 批量获取
function batchGet() {
  try {
    const keys = Object.keys(JSON.parse(batchData.value))
    const result: Record<string, any> = {}
    keys.forEach(key => {
      result[key] = getNestedValue(stateStore.value, key)
    })
    allStates.value = JSON.stringify(result, null, 2)
  } catch (error) {
    allStates.value = '❌ JSON 格式错误'
  }
}

// 获取所有状态
function getAllStates() {
  allStates.value = JSON.stringify(stateStore.value, null, 2)
}

// 刷新统计
function refreshStats() {
  stats.value.total = Object.keys(flattenObject(stateStore.value)).length
  stats.value.memory = Math.round(JSON.stringify(stateStore.value).length / 1024)
}

// 工具函数
function setNestedValue(obj: any, path: string, value: any) {
  const keys = path.split('.')
  let current = obj
  
  for (let i = 0; i < keys.length - 1; i++) {
    if (!(keys[i] in current)) {
      current[keys[i]] = {}
    }
    current = current[keys[i]]
  }
  
  current[keys[keys.length - 1]] = value
}

function getNestedValue(obj: any, path: string) {
  const keys = path.split('.')
  let current = obj
  
  for (const key of keys) {
    if (current === undefined || current === null) {
      return undefined
    }
    current = current[key]
  }
  
  return current
}

function deleteNestedValue(obj: any, path: string) {
  const keys = path.split('.')
  let current = obj
  
  for (let i = 0; i < keys.length - 1; i++) {
    if (!(keys[i] in current)) {
      return
    }
    current = current[keys[i]]
  }
  
  delete current[keys[keys.length - 1]]
}

function flattenObject(obj: any, prefix = ''): Record<string, any> {
  const result: Record<string, any> = {}
  
  for (const key in obj) {
    const fullKey = prefix ? `${prefix}.${key}` : key
    if (typeof obj[key] === 'object' && obj[key] !== null && !Array.isArray(obj[key])) {
      Object.assign(result, flattenObject(obj[key], fullKey))
    } else {
      result[fullKey] = obj[key]
    }
  }
  
  return result
}

function formatTime(timestamp: number) {
  const date = new Date(timestamp)
  return `${date.getHours()}:${date.getMinutes()}:${date.getSeconds()}`
}

// 初始化
onMounted(() => {
  refreshStats()
  
  // 添加初始历史记录
  addToHistory('初始状态', stateStore.value)
})

// 清理
onUnmounted(() => {
  if (unwatchFn) {
    unwatchFn()
  }
})
</script>

<style scoped>
.state-demo {
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
.form-group textarea {
  padding: 10px 12px;
  border: 1px solid var(--color-border-default);
  border-radius: 6px;
  font-size: 14px;
  font-family: 'Courier New', monospace;
}

.button-group {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
}

.btn-primary, .btn-secondary, .btn-danger, .btn-info, .btn-small {
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

.btn-secondary:hover:not(:disabled) {
  border-color: var(--color-primary-default);
  color: var(--color-primary-default);
}

.btn-danger {
  background: #ff4d4f;
  color: white;
}

.btn-danger:hover:not(:disabled) {
  background: #ff7875;
}

.btn-info {
  background: #1890ff;
  color: white;
}

.btn-small {
  padding: 4px 8px;
  font-size: 12px;
}

button:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.full-width {
  width: 100%;
  justify-content: center;
}

.result-box {
  padding: 12px;
  background: var(--color-bg-layout);
  border-radius: 6px;
  border-left: 3px solid var(--color-primary-default);
}

.result-box pre {
  margin: 5px 0 0 0;
  font-size: 13px;
  font-family: 'Courier New', monospace;
  color: var(--color-text-secondary);
  white-space: pre-wrap;
  word-break: break-all;
}

.events-list {
  border: 1px solid var(--color-border-default);
  border-radius: 6px;
  overflow: hidden;
}

.list-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 10px 12px;
  background: var(--color-bg-layout);
  border-bottom: 1px solid var(--color-border-default);
  font-size: 14px;
  font-weight: 500;
}

.empty {
  padding: 20px;
  text-align: center;
  color: var(--color-text-tertiary);
  font-size: 14px;
}

.event-item {
  display: flex;
  justify-content: space-between;
  padding: 10px 12px;
  border-bottom: 1px solid var(--color-border-default);
  font-size: 13px;
}

.event-item:last-child {
  border-bottom: none;
}

.event-time {
  color: var(--color-text-tertiary);
  font-family: monospace;
}

.event-data {
  color: var(--color-text-secondary);
  flex: 1;
  margin-left: 10px;
}

.history-info {
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

.timeline {
  max-height: 200px;
  overflow-y: auto;
  padding: 10px;
  background: var(--color-bg-layout);
  border-radius: 6px;
}

.timeline-item {
  display: flex;
  gap: 10px;
  margin-bottom: 15px;
  opacity: 0.5;
  transition: opacity 0.3s;
}

.timeline-item.active {
  opacity: 1;
}

.timeline-dot {
  width: 10px;
  height: 10px;
  background: var(--color-border-default);
  border-radius: 50%;
  margin-top: 5px;
  flex-shrink: 0;
}

.timeline-item.active .timeline-dot {
  background: var(--color-primary-default);
  box-shadow: 0 0 0 4px rgba(102, 126, 234, 0.2);
}

.timeline-content {
  flex: 1;
}

.timeline-title {
  font-size: 14px;
  color: var(--color-text-primary);
  margin-bottom: 4px;
}

.timeline-time {
  font-size: 12px;
  color: var(--color-text-tertiary);
  font-family: monospace;
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


