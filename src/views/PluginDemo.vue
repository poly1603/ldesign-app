<template>
  <div class="plugin-demo">
    <div class="demo-header">
      <h1>🔌 插件系统演示</h1>
      <p>展示 Engine 插件系统：动态加载、生命周期、插件通信、依赖管理</p>
    </div>

    <div class="demo-grid">
      <!-- 插件列表 -->
      <div class="demo-card">
        <div class="card-header">
          <Package class="icon" />
          <h3>已注册插件</h3>
        </div>
        <div class="card-content">
          <div class="plugins-list">
            <div v-if="installedPlugins.length === 0" class="empty">暂无已安装插件</div>
            <div v-for="plugin in installedPlugins" :key="plugin.name" class="plugin-item">
              <div class="plugin-info">
                <div class="plugin-name">{{ plugin.name }}</div>
                <div class="plugin-version">v{{ plugin.version }}</div>
              </div>
              <div class="plugin-status" :class="plugin.status">
                {{ statusText(plugin.status) }}
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- 动态加载插件 -->
      <div class="demo-card">
        <div class="card-header">
          <Download class="icon" />
          <h3>动态加载插件</h3>
        </div>
        <div class="card-content">
          <div class="form-group">
            <label>插件名称</label>
            <input v-model="newPluginName" placeholder="my-plugin" />
          </div>
          <div class="form-group">
            <label>插件版本</label>
            <input v-model="newPluginVersion" placeholder="1.0.0" />
          </div>
          <div class="button-group">
            <button @click="loadPlugin" class="btn-primary">
              <Plus :size="16" />
              加载插件
            </button>
            <button @click="unloadPlugin" class="btn-danger">
              <Trash2 :size="16" />
              卸载插件
            </button>
          </div>
          <div v-if="loadResult" class="result-box" :class="loadResultType">
            {{ loadResult }}
          </div>
        </div>
      </div>

      <!-- 插件生命周期 -->
      <div class="demo-card full-width">
        <div class="card-header">
          <Activity class="icon" />
          <h3>插件生命周期</h3>
        </div>
        <div class="card-content">
          <div class="lifecycle-timeline">
            <div 
              v-for="(event, index) in lifecycleEvents" 
              :key="index"
              class="lifecycle-item"
              :class="`lifecycle-${event.stage}`"
            >
              <div class="lifecycle-dot"></div>
              <div class="lifecycle-content">
                <div class="lifecycle-stage">{{ event.stage }}</div>
                <div class="lifecycle-plugin">{{ event.plugin }}</div>
                <div class="lifecycle-time">{{ formatTime(event.time) }}</div>
              </div>
            </div>
          </div>
          <button @click="clearLifecycle" class="btn-secondary">
            <Trash2 :size="16" />
            清空生命周期日志
          </button>
        </div>
      </div>

      <!-- 插件通信 -->
      <div class="demo-card">
        <div class="card-header">
          <MessageSquare class="icon" />
          <h3>插件间通信</h3>
        </div>
        <div class="card-content">
          <div class="form-group">
            <label>源插件</label>
            <select v-model="sourcePlugin">
              <option v-for="plugin in installedPlugins" :key="plugin.name" :value="plugin.name">
                {{ plugin.name }}
              </option>
            </select>
          </div>
          <div class="form-group">
            <label>目标插件</label>
            <select v-model="targetPlugin">
              <option v-for="plugin in installedPlugins" :key="plugin.name" :value="plugin.name">
                {{ plugin.name }}
              </option>
            </select>
          </div>
          <div class="form-group">
            <label>消息内容</label>
            <textarea v-model="communicationMessage" rows="2" placeholder="Hello from plugin A"></textarea>
          </div>
          <div class="button-group">
            <button @click="sendMessage" class="btn-primary">
              <Send :size="16" />
              发送消息
            </button>
          </div>
          <div class="messages-list">
            <div class="list-header">消息历史</div>
            <div v-if="messages.length === 0" class="empty">暂无消息</div>
            <div v-for="(msg, index) in messages" :key="index" class="message-item">
              <div class="message-route">
                {{ msg.from }} → {{ msg.to }}
              </div>
              <div class="message-content">{{ msg.content }}</div>
              <div class="message-time">{{ formatTime(msg.time) }}</div>
            </div>
          </div>
        </div>
      </div>

      <!-- 插件依赖 -->
      <div class="demo-card">
        <div class="card-header">
          <GitBranch class="icon" />
          <h3>插件依赖关系</h3>
        </div>
        <div class="card-content">
          <div class="dependency-graph">
            <div v-for="plugin in installedPlugins" :key="plugin.name" class="dependency-node">
              <div class="node-name">{{ plugin.name }}</div>
              <div v-if="plugin.dependencies && plugin.dependencies.length > 0" class="node-deps">
                依赖: {{ plugin.dependencies.join(', ') }}
              </div>
              <div v-else class="node-deps empty">无依赖</div>
            </div>
          </div>
          <button @click="analyzeDependencies" class="btn-secondary full-width">
            <BarChart3 :size="16" />
            分析依赖关系
          </button>
        </div>
      </div>

      <!-- 创建自定义插件 -->
      <div class="demo-card full-width">
        <div class="card-header">
          <Code class="icon" />
          <h3>创建自定义插件</h3>
        </div>
        <div class="card-content">
          <div class="code-example">
            <pre><code>{{ customPluginCode }}</code></pre>
          </div>
          <button @click="createCustomPlugin" class="btn-primary">
            <Zap :size="16" />
            创建并加载插件
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import {
  Package, Download, Activity, MessageSquare, GitBranch, Code, BarChart3,
  Plus, Trash2, Send, Zap
} from 'lucide-vue-next'

// 插件列表
const installedPlugins = ref([
  { name: 'router', version: '1.0.0', status: 'active', dependencies: [] },
  { name: 'i18n', version: '3.0.0', status: 'active', dependencies: [] },
  { name: 'cache', version: '1.0.0', status: 'active', dependencies: [] },
  { name: 'color', version: '1.0.0', status: 'active', dependencies: ['i18n'] },
  { name: 'size', version: '1.0.0', status: 'active', dependencies: ['i18n'] },
  { name: 'template', version: '1.0.0', status: 'active', dependencies: [] }
])

// 动态加载
const newPluginName = ref('')
const newPluginVersion = ref('1.0.0')
const loadResult = ref('')
const loadResultType = ref('success')

// 生命周期事件
const lifecycleEvents = ref<Array<{ stage: string; plugin: string; time: number }>>([
  { stage: 'beforeInstall', plugin: 'router', time: Date.now() - 5000 },
  { stage: 'install', plugin: 'router', time: Date.now() - 4900 },
  { stage: 'afterInstall', plugin: 'router', time: Date.now() - 4800 },
  { stage: 'beforeInstall', plugin: 'i18n', time: Date.now() - 4700 },
  { stage: 'install', plugin: 'i18n', time: Date.now() - 4600 }
])

// 插件通信
const sourcePlugin = ref('router')
const targetPlugin = ref('i18n')
const communicationMessage = ref('Hello from router plugin!')
const messages = ref<Array<{ from: string; to: string; content: string; time: number }>>([])

// 自定义插件代码
const customPluginCode = `const myPlugin = {
  name: 'my-custom-plugin',
  version: '1.0.0',
  
  install(engine) {
    console.log('插件安装')
    
    // 添加自定义功能
    engine.myFeature = {
      sayHello() {
        return 'Hello from my plugin!'
      }
    }
  },
  
  uninstall(engine) {
    console.log('插件卸载')
    delete engine.myFeature
  }
}`

// 加载插件
function loadPlugin() {
  if (!newPluginName.value) {
    loadResult.value = '❌ 请输入插件名称'
    loadResultType.value = 'error'
    return
  }
  
  const exists = installedPlugins.value.find(p => p.name === newPluginName.value)
  if (exists) {
    loadResult.value = '⚠️ 插件已存在'
    loadResultType.value = 'warning'
    return
  }
  
  installedPlugins.value.push({
    name: newPluginName.value,
    version: newPluginVersion.value,
    status: 'active',
    dependencies: []
  })
  
  // 添加生命周期事件
  addLifecycleEvent('beforeInstall', newPluginName.value)
  setTimeout(() => addLifecycleEvent('install', newPluginName.value), 100)
  setTimeout(() => addLifecycleEvent('afterInstall', newPluginName.value), 200)
  
  loadResult.value = '✅ 插件加载成功'
  loadResultType.value = 'success'
  
  setTimeout(() => loadResult.value = '', 3000)
}

// 卸载插件
function unloadPlugin() {
  if (!newPluginName.value) {
    loadResult.value = '❌ 请输入插件名称'
    loadResultType.value = 'error'
    return
  }
  
  const index = installedPlugins.value.findIndex(p => p.name === newPluginName.value)
  if (index === -1) {
    loadResult.value = '⚠️ 插件不存在'
    loadResultType.value = 'warning'
    return
  }
  
  installedPlugins.value.splice(index, 1)
  addLifecycleEvent('uninstall', newPluginName.value)
  
  loadResult.value = '✅ 插件卸载成功'
  loadResultType.value = 'success'
  
  setTimeout(() => loadResult.value = '', 3000)
}

// 添加生命周期事件
function addLifecycleEvent(stage: string, plugin: string) {
  lifecycleEvents.value.push({
    stage,
    plugin,
    time: Date.now()
  })
  
  // 限制数量
  if (lifecycleEvents.value.length > 20) {
    lifecycleEvents.value.shift()
  }
}

// 清空生命周期
function clearLifecycle() {
  lifecycleEvents.value = []
}

// 发送消息
function sendMessage() {
  if (!sourcePlugin.value || !targetPlugin.value) {
    return
  }
  
  messages.value.push({
    from: sourcePlugin.value,
    to: targetPlugin.value,
    content: communicationMessage.value,
    time: Date.now()
  })
  
  // 限制数量
  if (messages.value.length > 10) {
    messages.value.shift()
  }
}

// 分析依赖
function analyzeDependencies() {
  alert('依赖关系分析:\n\n' + 
    installedPlugins.value
      .map(p => `${p.name}: ${p.dependencies.length > 0 ? p.dependencies.join(', ') : '无依赖'}`)
      .join('\n')
  )
}

// 创建自定义插件
function createCustomPlugin() {
  const plugin = {
    name: 'custom-plugin-' + Date.now(),
    version: '1.0.0',
    status: 'active',
    dependencies: []
  }
  
  installedPlugins.value.push(plugin)
  addLifecycleEvent('beforeInstall', plugin.name)
  addLifecycleEvent('install', plugin.name)
  addLifecycleEvent('afterInstall', plugin.name)
  
  alert(`✅ 自定义插件 "${plugin.name}" 创建成功！`)
}

// 状态文本
function statusText(status: string) {
  const map: Record<string, string> = {
    active: '运行中',
    inactive: '已停用',
    loading: '加载中',
    error: '错误'
  }
  return map[status] || status
}

// 格式化时间
function formatTime(timestamp: number) {
  const date = new Date(timestamp)
  return `${String(date.getHours()).padStart(2, '0')}:${String(date.getMinutes()).padStart(2, '0')}:${String(date.getSeconds()).padStart(2, '0')}.${String(date.getMilliseconds()).padStart(3, '0')}`
}
</script>

<style scoped>
.plugin-demo {
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
.form-group select {
  padding: 10px 12px;
  border: 1px solid var(--color-border-default);
  border-radius: 6px;
  font-size: 14px;
}

.form-group textarea {
  padding: 10px 12px;
  border: 1px solid var(--color-border-default);
  border-radius: 6px;
  font-size: 14px;
  font-family: monospace;
}

.button-group {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
}

.btn-primary, .btn-secondary, .btn-danger {
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

.full-width {
  width: 100%;
  justify-content: center;
}

.plugins-list {
  border: 1px solid var(--color-border-default);
  border-radius: 6px;
  overflow: hidden;
}

.empty {
  padding: 20px;
  text-align: center;
  color: var(--color-text-tertiary);
  font-size: 14px;
}

.plugin-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px;
  border-bottom: 1px solid var(--color-border-default);
}

.plugin-item:last-child {
  border-bottom: none;
}

.plugin-info {
  display: flex;
  align-items: baseline;
  gap: 10px;
}

.plugin-name {
  font-size: 15px;
  font-weight: 500;
  color: var(--color-text-primary);
}

.plugin-version {
  font-size: 12px;
  color: var(--color-text-tertiary);
  font-family: monospace;
}

.plugin-status {
  padding: 4px 12px;
  border-radius: 4px;
  font-size: 12px;
  font-weight: 500;
}

.plugin-status.active {
  background: rgba(82, 196, 26, 0.1);
  color: #52c41a;
}

.plugin-status.inactive {
  background: rgba(0, 0, 0, 0.1);
  color: var(--color-text-tertiary);
}

.result-box {
  padding: 12px;
  border-radius: 6px;
  text-align: center;
  font-weight: 500;
}

.result-box.success {
  background: rgba(82, 196, 26, 0.1);
  color: #52c41a;
}

.result-box.error {
  background: rgba(255, 77, 79, 0.1);
  color: #ff4d4f;
}

.result-box.warning {
  background: rgba(250, 173, 20, 0.1);
  color: #faad14;
}

.lifecycle-timeline {
  border: 1px solid var(--color-border-default);
  border-radius: 6px;
  max-height: 400px;
  overflow-y: auto;
  padding: 15px;
  background: var(--color-bg-layout);
}

.lifecycle-item {
  display: flex;
  gap: 15px;
  margin-bottom: 20px;
  padding: 12px;
  background: white;
  border-radius: 6px;
  border-left: 3px solid var(--color-border-default);
}

.lifecycle-item.lifecycle-install {
  border-left-color: #52c41a;
}

.lifecycle-item.lifecycle-uninstall {
  border-left-color: #ff4d4f;
}

.lifecycle-dot {
  width: 10px;
  height: 10px;
  background: var(--color-primary-default);
  border-radius: 50%;
  margin-top: 5px;
  flex-shrink: 0;
}

.lifecycle-content {
  flex: 1;
}

.lifecycle-stage {
  font-weight: 600;
  color: var(--color-text-primary);
  margin-bottom: 4px;
}

.lifecycle-plugin {
  font-size: 13px;
  color: var(--color-text-secondary);
  margin-bottom: 4px;
}

.lifecycle-time {
  font-size: 12px;
  color: var(--color-text-tertiary);
  font-family: monospace;
}

.messages-list {
  border: 1px solid var(--color-border-default);
  border-radius: 6px;
  max-height: 200px;
  overflow-y: auto;
}

.list-header {
  padding: 10px 12px;
  background: var(--color-bg-layout);
  border-bottom: 1px solid var(--color-border-default);
  font-size: 14px;
  font-weight: 500;
}

.message-item {
  padding: 10px 12px;
  border-bottom: 1px solid var(--color-border-default);
}

.message-item:last-child {
  border-bottom: none;
}

.message-route {
  font-size: 12px;
  color: var(--color-primary-default);
  margin-bottom: 4px;
  font-family: monospace;
}

.message-content {
  font-size: 13px;
  color: var(--color-text-secondary);
  margin-bottom: 4px;
}

.message-time {
  font-size: 11px;
  color: var(--color-text-tertiary);
  font-family: monospace;
}

.dependency-graph {
  border: 1px solid var(--color-border-default);
  border-radius: 6px;
  padding: 15px;
  background: var(--color-bg-layout);
}

.dependency-node {
  padding: 12px;
  background: white;
  border-radius: 6px;
  margin-bottom: 10px;
  border-left: 3px solid var(--color-primary-default);
}

.dependency-node:last-child {
  margin-bottom: 0;
}

.node-name {
  font-weight: 600;
  color: var(--color-text-primary);
  margin-bottom: 6px;
}

.node-deps {
  font-size: 13px;
  color: var(--color-text-secondary);
}

.node-deps.empty {
  color: var(--color-text-tertiary);
  font-style: italic;
}

.code-example {
  background: #1e1e1e;
  border-radius: 8px;
  padding: 20px;
  overflow-x: auto;
}

.code-example pre {
  margin: 0;
  color: #d4d4d4;
  font-family: 'Courier New', monospace;
  font-size: 13px;
  line-height: 1.6;
}

.code-example code {
  color: #d4d4d4;
}
</style>


