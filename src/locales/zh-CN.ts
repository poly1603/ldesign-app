/**
 * 中文语言包
 */

export default {
  // 自定义主题
  customThemes: {
    sunset: '日落橙',
    forest: '森林绿',
    midnight: '午夜蓝',
    lavender: '薰衣草紫',
    coral: '珊瑚红'
  },
  // 应用信息
  app: {
    name: 'LDesign 简单应用',
    title: 'LDesign 简单应用',
    description: '基于 LDesign Engine 的示例应用',
    copyright: '© 2024 LDesign. 保留所有权利。'
  },

  // 导航菜单
  nav: {
    home: '首页',
    about: '关于',
    crypto: '加密演示',
    http: 'HTTP 演示',
    api: 'API 演示',
    dashboard: '仪表盘',
    login: '登录',
    logout: '退出登录',
    language: '语言',
    performance: '性能监控',
    state: '状态管理',
    event: '事件系统',
    concurrency: '并发控制',
    plugin: '插件系统',
    tabs: 'Tabs 组件',
    menu: 'Menu 菜单',
    demos: '功能演示',
    engineDemos: 'Engine 演示',
    componentDemos: '组件演示',
    advancedComponents: '高级组件'
  },

  // 首页
  home: {
    title: '欢迎来到 LDesign',
    subtitle: '现代化、高性能的前端开发框架',
    description: '这是一个基于 @ldesign/engine 构建的简单应用示例',
    demos: {
      title: '功能演示',
      crypto: {
        title: '加密演示',
        description: '体验 AES、RSA、哈希算法等加密功能'
      },
      http: {
        title: 'HTTP 演示',
        description: '体验网络请求、拦截器、缓存等功能'
      },
      api: {
        title: 'API 演示',
        description: '体验 API 引擎、插件系统、批量请求等功能'
      }
    },
    features: {
      title: '核心特性',
      list: {
        performance: '极致性能',
        performanceDesc: '基于 Vue 3 构建，提供卓越的运行时性能',
        modular: '模块化架构',
        modularDesc: '灵活的插件系统，按需加载功能',
        typescript: 'TypeScript 支持',
        typescriptDesc: '完整的类型定义，提供最佳的开发体验'
      }
    },
    getStarted: '开始使用',
    learnMore: '了解更多',
    viewDocs: '查看文档',
    currentTime: '当前时间',
    welcomeMessage: '你好，{name}！欢迎使用 LDesign。',
    stats: {
      routes: '路由数量',
      visits: '访问次数',
      cacheSize: '缓存大小'
    }
  },

  // 关于页面
  about: {
    title: '关于 LDesign',
    subtitle: '了解更多关于这个项目的信息',
    description: 'LDesign 是一个现代化的前端开发框架，旨在提供最佳的开发体验和性能。',
    version: '版本',
    author: '作者',
    license: '许可证',
    repository: '代码仓库',
    techStack: '技术栈',
    goals: {
      title: '我们的目标',
      api: '提供简洁而强大的 API',
      performance: '优化性能，减少内存占用',
      typescript: '完善的 TypeScript 支持',
      integration: '与 @ldesign/engine 深度集成',
      extensible: '丰富的功能扩展'
    },
    features: {
      title: '主要特点',
      items: {
        vue3: '基于 Vue 3',
        vite: 'Vite 构建工具',
        typescript: 'TypeScript 支持',
        i18n: '国际化支持',
        router: '智能路由系统',
        engine: '强大的引擎核心'
      },
      vue3Desc: '基于 Vue 3 构建，提供出色的性能',
      viteDesc: '快速的开发服务器和构建工具',
      i18nDesc: '完整的国际化支持'
    },
    team: {
      title: '开发团队',
      description: '由一群充满激情的开发者共同维护'
    },
    contact: {
      title: '联系我们',
      email: '邮箱',
      github: 'GitHub',
      website: '官网',
      community: '讨论区'
    }
  },

  // 登录页面
  login: {
    title: '登录到您的账户',
    subtitle: '请输入您的凭据以继续',
    username: '用户名',
    password: '密码',
    usernamePlaceholder: '请输入用户名',
    passwordPlaceholder: '请输入密码',
    rememberMe: '记住我',
    forgotPassword: '忘记密码？',
    submit: '登录',
    submitting: '正在登录...',
    noAccount: '还没有账户？',
    register: '立即注册',
    or: '或',
    loginWith: '使用 {provider} 登录',
    errors: {
      required: '此字段是必填的',
      invalid: '用户名或密码错误',
      usernameRequired: '请输入用户名',
      passwordRequired: '请输入密码',
      minLength: '至少需要 {min} 个字符',
      network: '网络错误，请稍后重试'
    },
    success: '登录成功！正在跳转...'
  },

  // 加密演示页面
  crypto: {
    title: '加密演示',
    subtitle: '体验 @ldesign/crypto 加密功能',
    aes: {
      title: 'AES 加密',
      plaintext: '原始文本',
      plaintextPlaceholder: '输入要加密的文本',
      key: '密钥',
      keyPlaceholder: '输入密钥',
      encrypt: '加密',
      decrypt: '解密',
      clear: '清除',
      encryptedResult: '加密结果',
      decryptedResult: '解密结果'
    },
    hash: {
      title: '哈希算法',
      plaintext: '原始文本',
      plaintextPlaceholder: '输入要计算哈希的文本',
      algorithm: '算法',
      compute: '计算哈希',
      clear: '清除',
      result: '哈希结果'
    },
    hmac: {
      title: 'HMAC 消息认证',
      message: '消息内容',
      messagePlaceholder: '输入消息内容',
      key: '密钥',
      keyPlaceholder: '输入密钥',
      generate: '生成 HMAC',
      verify: '验证',
      clear: '清除',
      result: 'HMAC 结果',
      verification: '验证结果',
      valid: '有效',
      invalid: '无效'
    },
    rsa: {
      title: 'RSA 加密',
      generateKeys: '生成密钥对',
      publicKey: '公钥',
      privateKey: '私钥',
      plaintext: '原始文本',
      plaintextPlaceholder: '输入要加密的文本',
      encrypt: '加密',
      decrypt: '解密',
      clear: '清除',
      encryptedResult: '加密结果',
      decryptedResult: '解密结果'
    },
    base64: {
      title: 'Base64 编码',
      plaintext: '原始文本',
      plaintextPlaceholder: '输入要编码的文本',
      encode: '编码',
      decode: '解码',
      clear: '清除',
      encodedResult: '编码结果',
      decodedResult: '解码结果'
    },
    keyGenerator: {
      title: '密钥生成器',
      keyLength: '密钥长度（字节）',
      bytes16: '16 字节 (128 位)',
      bytes24: '24 字节 (192 位)',
      bytes32: '32 字节 (256 位)',
      generate: '生成密钥',
      copy: '复制',
      result: '生成的密钥',
      copied: '密钥已复制到剪贴板',
      copyFailed: '复制失败，请手动复制'
    },
    passwordStrength: {
      title: '密码强度检测',
      password: '密码',
      passwordPlaceholder: '输入密码',
      checkStrength: '检测强度',
      strength: '密码强度',
      result: '强度结果',
      weak: '弱',
      medium: '中',
      strong: '强',
      veryStrong: '非常强',
      pleaseEnter: '请输入密码'
    }
  },

  // HTTP 演示页面
  http: {
    title: 'HTTP 演示',
    subtitle: '体验 @ldesign/http 网络请求功能',
    get: {
      title: 'GET 请求',
      url: '请求 URL',
      urlPlaceholder: '输入 API 地址',
      send: '发送请求',
      sending: '请求中...',
      clear: '清除',
      response: '响应结果',
      error: '错误信息'
    },
    post: {
      title: 'POST 请求',
      url: '请求 URL',
      urlPlaceholder: '输入 API 地址',
      data: '请求数据 (JSON)',
      dataPlaceholder: '输入 JSON 数据',
      send: '发送请求',
      sending: '请求中...',
      clear: '清除',
      response: '响应结果',
      error: '错误信息'
    },
    interceptor: {
      title: '拦截器',
      description: '拦截器可以拦截请求和响应，用于添加认证、日志记录等功能。',
      addRequest: '添加请求拦截器',
      addResponse: '添加响应拦截器',
      clear: '清除拦截器',
      logs: '拦截器日志'
    },
    cache: {
      title: '请求缓存',
      url: '缓存 URL',
      urlPlaceholder: '输入要缓存的 API',
      ttl: '缓存时间 (秒)',
      fetch: '获取（带缓存）',
      clearCache: '清除缓存',
      stats: '缓存统计',
      hits: '命中次数',
      misses: '未命中次数',
      hitRate: '命中率'
    },
    retry: {
      title: '重试机制',
      url: '请求 URL',
      urlPlaceholder: '输入可能失败的 API',
      maxRetries: '最大重试次数',
      retryDelay: '重试延迟 (毫秒)',
      sendWithRetry: '发送（带重试）',
      response: '响应结果',
      error: '错误信息'
    },
    timeout: {
      title: '超时控制',
      url: '请求 URL',
      timeout: '超时时间 (毫秒)',
      sendWithTimeout: '发送（带超时）',
      response: '响应结果',
      error: '错误信息'
    }
  },

  // API 演示页面
  api: {
    title: 'API 演示',
    subtitle: '体验 @ldesign/api 接口管理功能',
    basic: {
      title: 'API Engine 基础',
      description: 'API Engine 提供统一的接口管理能力，支持插件化扩展。',
      basicCall: '基础调用',
      viewStatus: '查看状态',
      engineStatus: 'Engine 状态'
    },
    system: {
      title: '系统 API',
      username: '用户名',
      usernamePlaceholder: '输入用户名',
      password: '密码',
      passwordPlaceholder: '输入密码',
      simulateLogin: '模拟登录',
      getUserInfo: '获取用户信息',
      logout: '登出',
      userInfo: '用户信息',
      error: '错误'
    },
    caching: {
      title: '缓存策略',
      method: 'API 方法名',
      methodPlaceholder: '例如: getUser',
      ttl: '缓存 TTL (秒)',
      callWithCache: '带缓存调用',
      cacheStats: '缓存统计',
      clearCache: '清除缓存',
      items: '缓存项数',
      hitRate: '命中率'
    },
    batch: {
      title: '批量请求',
      description: '批量请求可以同时发送多个 API 调用，提高效率。',
      api1: 'API 1',
      api2: 'API 2',
      api3: 'API 3',
      sendBatch: '发送批量请求',
      results: '批量结果',
      error: '错误'
    },
    plugin: {
      title: '插件系统',
      description: 'API Engine 支持插件扩展，可以添加日志、重试、缓存等功能。',
      addLogger: '添加日志插件',
      addRetry: '添加重试插件',
      addCache: '添加缓存插件',
      removePlugins: '移除所有插件',
      pluginLogs: '插件日志'
    }
  },

  // 性能监控页面
  performance: {
    title: '性能监控仪表板',
    subtitle: '实时监控应用性能指标，展示 Engine 的性能监控能力',
    overview: {
      title: '性能概览',
      startupTime: '启动时间',
      memoryUsage: '内存使用',
      ms: '毫秒',
      mb: 'MB'
    },
    marks: {
      title: '性能标记',
      addMark: '添加标记',
      name: '标记名称',
      namePlaceholder: '例如: feature-loaded',
      time: '时间',
      clear: '清除所有'
    },
    cache: {
      title: '缓存统计',
      entries: '缓存条目',
      hitRate: '命中率',
      size: '缓存大小',
      kb: 'KB'
    },
    realtime: {
      title: '实时监控',
      start: '开始监控',
      stop: '停止监控',
      fps: '帧率',
      cpu: 'CPU 使用率',
      memory: '内存',
      network: '网络'
    },
    testing: {
      title: '性能测试工具',
      stressTest: '压力测试',
      memoryTest: '内存测试',
      renderTest: '渲染测试',
      startTest: '开始测试',
      stopTest: '停止测试',
      results: '测试结果'
    }
  },

  // 状态管理页面
  state: {
    title: '状态管理演示',
    subtitle: '展示 Engine StateManager 的强大功能：状态 CRUD、时间旅行、持久化',
    crud: {
      title: '状态 CRUD 操作',
      key: '键名',
      keyPlaceholder: '例如: user.name',
      value: '值（JSON）',
      valuePlaceholder: '{"name": "张三"}',
      setState: '设置状态',
      getState: '获取状态',
      deleteState: '删除状态',
      currentValue: '当前值'
    },
    watch: {
      title: '状态监听（Watch）',
      key: '监听键名',
      keyPlaceholder: '例如: user',
      startWatch: '开始监听',
      stopWatch: '停止监听',
      events: '监听事件',
      recent: '最近{count}条',
      noEvents: '暂无事件'
    },
    history: {
      title: '时间旅行（History）',
      undo: '撤销',
      redo: '重做',
      clear: '清除历史',
      currentIndex: '当前索引',
      totalSteps: '总步骤',
      timeline: '时间线'
    },
    persistence: {
      title: '持久化',
      save: '保存到 LocalStorage',
      load: '从 LocalStorage 加载',
      clear: '清除持久化',
      status: '持久化状态',
      enabled: '已启用',
      disabled: '未启用'
    },
    computed: {
      title: '计算状态',
      description: '基于其他状态自动计算的派生状态',
      fullName: '全名',
      age: '年龄',
      isAdult: '是否成年'
    }
  },

  // 事件系统页面
  event: {
    title: '事件系统演示',
    subtitle: '展示 Engine 事件系统的强大功能：发布订阅、优先级、事件回放',
    emit: {
      title: '事件发布（Emit）',
      name: '事件名称',
      namePlaceholder: '例如: user:login',
      data: '事件数据（JSON）',
      dataPlaceholder: '{"user": "张三"}',
      send: '发送事件',
      sendOnce: '发送一次',
      broadcast: '广播事件'
    },
    subscribe: {
      title: '事件订阅（On）',
      name: '订阅事件名称',
      namePlaceholder: '例如: user:*',
      priority: '优先级',
      priorityHigh: '高（100）',
      priorityMedium: '中（50）',
      priorityLow: '低（0）',
      subscribe: '订阅事件',
      subscribeOnce: '订阅一次',
      unsubscribeAll: '取消所有订阅',
      current: '当前订阅',
      count: '{count} 个订阅'
    },
    logs: {
      title: '事件日志',
      recent: '最近{count}条',
      clear: '清除日志',
      noLogs: '暂无日志',
      event: '事件',
      data: '数据',
      time: '时间'
    },
    replay: {
      title: '事件回放',
      description: '可以回放历史事件，用于调试和测试',
      start: '开始录制',
      stop: '停止录制',
      replay: '回放',
      clear: '清除记录',
      recorded: '已录制 {count} 个事件'
    },
    wildcard: {
      title: '通配符订阅',
      description: '支持通配符模式订阅多个事件',
      pattern: '事件模式',
      patternPlaceholder: '例如: user:* 或 *.created',
      subscribe: '订阅模式',
      matched: '匹配到 {count} 个事件'
    }
  },

  // 并发控制页面
  concurrency: {
    title: '并发控制演示',
    subtitle: '展示 Engine 并发控制功能：限流、队列、优先级调度',
    queue: {
      title: '任务队列',
      description: '控制同时执行的任务数量，避免资源过载',
      concurrency: '并发数',
      addTask: '添加任务',
      addMultiple: '批量添加',
      pause: '暂停队列',
      resume: '恢复队列',
      clear: '清空队列',
      status: '队列状态',
      pending: '等待中',
      running: '执行中',
      completed: '已完成',
      failed: '失败'
    },
    throttle: {
      title: '节流（Throttle）',
      description: '限制函数执行频率，在指定时间内只执行一次',
      interval: '节流间隔 (毫秒)',
      trigger: '触发函数',
      count: '执行次数',
      reset: '重置计数'
    },
    debounce: {
      title: '防抖（Debounce）',
      description: '延迟函数执行，只在最后一次调用后执行',
      delay: '防抖延迟 (毫秒)',
      trigger: '触发函数',
      count: '执行次数',
      reset: '重置计数'
    },
    priority: {
      title: '优先级调度',
      description: '根据任务优先级进行调度执行',
      taskName: '任务名称',
      taskNamePlaceholder: '例如: 数据加载',
      priority: '优先级',
      high: '高',
      medium: '中',
      low: '低',
      addTask: '添加任务',
      queue: '任务队列',
      noTasks: '暂无任务'
    },
    semaphore: {
      title: '信号量',
      description: '控制并发访问资源的数量',
      maxConcurrent: '最大并发数',
      acquire: '获取许可',
      release: '释放许可',
      available: '可用许可',
      waiting: '等待队列'
    }
  },

  // 插件系统页面
  plugin: {
    title: '插件系统演示',
    subtitle: '展示 Engine 插件系统的强大功能：动态加载、生命周期、通信',
    basic: {
      title: '插件基础',
      description: 'Engine 提供完整的插件系统，支持动态加载和卸载',
      installed: '已安装插件',
      available: '可用插件',
      install: '安装',
      uninstall: '卸载',
      enable: '启用',
      disable: '禁用',
      configure: '配置'
    },
    lifecycle: {
      title: '生命周期',
      description: '插件拥有完整的生命周期钩子',
      onInstall: '安装时',
      onEnable: '启用时',
      onDisable: '禁用时',
      onUninstall: '卸载时',
      logs: '生命周期日志'
    },
    communication: {
      title: '插件间通信',
      description: '插件可以通过事件总线相互通信',
      sender: '发送者插件',
      receiver: '接收者插件',
      message: '消息内容',
      send: '发送消息',
      logs: '通信日志'
    },
    custom: {
      title: '自定义插件',
      description: '创建并注册自定义插件',
      pluginName: '插件名称',
      pluginNamePlaceholder: '例如: my-plugin',
      version: '版本',
      versionPlaceholder: '例如: 1.0.0',
      author: '作者',
      authorPlaceholder: '您的名字',
      create: '创建插件',
      register: '注册插件',
      created: '插件已创建'
    }
  },

  // 仪表盘页面
  dashboard: {
    title: '仪表盘',
    subtitle: '欢迎回来，{username}',
    currentRoute: '当前路由信息',
    engineStatus: 'Engine 状态',
    appName: '应用名称',
    environment: '环境',
    debugMode: '调试模式',
    routeHistory: '路由历史',
    noHistory: '暂无历史记录',
    performanceMonitor: '性能监控',
    navigationTime: '导航时间',
    cacheHitRate: '缓存命中率',
    totalNavigations: '总导航次数',
    memoryUsage: '内存使用',
    allRoutes: '所有路由',
    auth: '认证',
    requiresAuth: '需要认证',
    public: '公开',
    history: '历史',
    errors: {
      loadHistory: '加载路由历史失败'
    },
    overview: {
      title: '概览',
      totalUsers: '总用户数',
      activeUsers: '活跃用户',
      newUsers: '新用户',
      revenue: '收入',
      totalVisits: '总访问量',
      orders: '订单数'
    },
    stats: {
      title: '统计数据',
      daily: '日',
      weekly: '周',
      monthly: '月',
      yearly: '年'
    },
    activity: {
      title: '最近活动',
      noActivity: '暂无活动记录'
    },
    quickActions: {
      title: '快速操作',
      newPost: '发布新内容',
      viewReports: '查看报告',
      settings: '设置',
      help: '帮助中心'
    },
    notifications: {
      title: '通知',
      markAllRead: '全部标记为已读',
      noNotifications: '暂无新通知'
    }
  },

  // 通用
  common: {
    loading: '加载中...',
    path: '路径',
    name: '名称',
    params: '参数',
    query: '查询',
    unnamed: '未命名',
    on: '开启',
    off: '关闭',
    visit: '访问',
    actions: '操作',
    clear: '清除',
    guest: '访客',
    error: '错误',
    success: '成功',
    warning: '警告',
    info: '信息',
    confirm: '确认',
    cancel: '取消',
    save: '保存',
    delete: '删除',
    edit: '编辑',
    add: '添加',
    search: '搜索',
    filter: '筛选',
    export: '导出',
    import: '导入',
    refresh: '刷新',
    back: '返回',
    next: '下一步',
    previous: '上一步',
    finish: '完成',
    close: '关闭',
    yes: '是',
    no: '否',
    ok: '确定',
    apply: '应用',
    reset: '重置',
    selectAll: '全选',
    deselectAll: '取消全选',
    more: '更多',
    less: '收起',
    showMore: '显示更多',
    showLess: '显示更少',
    noData: '暂无数据',
    noResults: '没有找到结果',
    tryAgain: '重试',
    viewDetails: '查看详情'
  },

  // 错误信息
  errors: {
    404: {
      title: '页面未找到',
      message: '抱歉，您访问的页面不存在。',
      action: '返回首页',
      back: '返回上一页'
    },
    500: {
      title: '服务器错误',
      message: '抱歉，服务器遇到了问题。',
      action: '刷新页面'
    },
    network: {
      title: '网络错误',
      message: '请检查您的网络连接。',
      action: '重试'
    },
    unauthorized: {
      title: '未授权',
      message: '您需要登录才能访问此页面。',
      action: '去登录'
    },
    forbidden: {
      title: '禁止访问',
      message: '您没有权限访问此页面。',
      action: '返回'
    }
  },

  // 验证消息
  validation: {
    required: '{field}是必填的',
    email: '请输入有效的邮箱地址',
    min: '{field}至少需要{min}个字符',
    max: '{field}不能超过{max}个字符',
    between: '{field}必须在{min}和{max}之间',
    numeric: '{field}必须是数字',
    alphanumeric: '{field}只能包含字母和数字',
    pattern: '{field}格式不正确',
    confirmed: '{field}确认不匹配',
    unique: '{field}已经存在',
    date: '请输入有效的日期',
    dateAfter: '日期必须在{date}之后',
    dateBefore: '日期必须在{date}之前',
    url: '请输入有效的URL',
    phone: '请输入有效的电话号码'
  },

  // 日期时间
  datetime: {
    today: '今天',
    yesterday: '昨天',
    tomorrow: '明天',
    thisWeek: '本周',
    lastWeek: '上周',
    nextWeek: '下周',
    thisMonth: '本月',
    lastMonth: '上月',
    nextMonth: '下月',
    thisYear: '今年',
    lastYear: '去年',
    nextYear: '明年',
    selectDate: '选择日期',
    selectTime: '选择时间',
    selectDateTime: '选择日期时间'
  },

  // 主题设置
  theme: {
    title: '主题设置',
    selectThemeColor: '选择主题色',
    customColor: '自定义颜色',
    custom: '当前颜色',
    mode: '主题模式',
    light: '浅色',
    dark: '深色',
    apply: '应用',
    add: '添加',
    remove: '删除',
    searchPlaceholder: '搜索颜色...',
    presetThemes: '预设主题',
    addCustomTheme: '添加自定义主题',
    themeName: '主题名称',
    confirmRemove: '确定要删除该主题吗？',
    presets: {
      blue: '拂晓蓝',
      purple: '酱紫',
      cyan: '明青',
      green: '极光绿',
      magenta: '法式洋红',
      red: '薄暮红',
      orange: '日暮橙',
      yellow: '日出黄',
      volcano: '火山橙',
      geekblue: '极客蓝',
      lime: '青柠绿',
      gold: '金盏花',
      gray: '中性灰',
      'dark-blue': '深海蓝',
      'dark-green': '森林绿',
      // 自定义主题
      sunset: '日落橙',
      forest: '森林绿',
      midnight: '午夜蓝',
      lavender: '薰衣草梦',
      coral: '珊瑚礁'
    }
  },

  // 菜单演示
  menu: {
    demo: {
      title: '菜单组件演示',
      description: '体验 @ldesign/menu 的各种功能和配置选项',
      mode: '菜单模式',
      'mode.horizontal': '横向',
      'mode.vertical': '纵向',
      theme: '主题',
      'theme.light': '浅色',
      'theme.dark': '深色',
      collapsed: '收起模式',
      collapse: '收起',
      expand: '展开',
      submenuTrigger: '子菜单触发方式',
      'trigger.popup': 'Popup',
      'trigger.inline': '内联',
      animation: '动画效果',
      enabled: '启用',
      disabled: '禁用',
      info: {
        title: '信息面板',
        selected: '选中的菜单项',
        config: '当前配置',
        events: '事件记录'
      },
      code: {
        title: '代码示例'
      }
    }
  }
};
