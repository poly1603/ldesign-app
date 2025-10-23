/**
 * English Language Pack
 */

export default {
  // Custom themes
  customThemes: {
    sunset: 'Sunset Orange',
    forest: 'Forest Green',
    midnight: 'Midnight Blue',
    lavender: 'Lavender Dream',
    coral: 'Coral Reef'
  },
  // App Info
  app: {
    name: 'LDesign Simple App',
    title: 'LDesign Simple App',
    description: 'Sample application built with LDesign Engine',
    copyright: '© 2024 LDesign. All rights reserved.'
  },

  // Navigation Menu
  nav: {
    home: 'Home',
    about: 'About',
    crypto: 'Crypto Demo',
    http: 'HTTP Demo',
    api: 'API Demo',
    dashboard: 'Dashboard',
    login: 'Login',
    logout: 'Logout',
    language: 'Language',
    performance: 'Performance',
    state: 'State',
    event: 'Events',
    concurrency: 'Concurrency',
    plugin: 'Plugins',
    demos: 'Feature Demos',
    engineDemos: 'Engine Demos'
  },

  // Home Page
  home: {
    title: 'Welcome to LDesign',
    subtitle: 'Modern, High-Performance Frontend Framework',
    description: 'This is a simple application example built with @ldesign/engine',
    demos: {
      title: 'Feature Demos',
      crypto: {
        title: 'Crypto Demo',
        description: 'Experience AES, RSA, hash algorithms and other encryption features'
      },
      http: {
        title: 'HTTP Demo',
        description: 'Experience network requests, interceptors, caching and other features'
      },
      api: {
        title: 'API Demo',
        description: 'Experience API engine, plugin system, batch requests and other features'
      }
    },
    features: {
      title: 'Core Features',
      list: {
        performance: 'Extreme Performance',
        performanceDesc: 'Built on Vue 3, providing excellent runtime performance',
        modular: 'Modular Architecture',
        modularDesc: 'Flexible plugin system with on-demand loading',
        typescript: 'TypeScript Support',
        typescriptDesc: 'Complete type definitions for the best development experience'
      }
    },
    getStarted: 'Get Started',
    learnMore: 'Learn More',
    viewDocs: 'View Docs',
    currentTime: 'Current Time',
    welcomeMessage: 'Hello, {name}! Welcome to LDesign.',
    stats: {
      routes: 'Routes',
      visits: 'Visits',
      cacheSize: 'Cache Size'
    }
  },

  // About Page
  about: {
    title: 'About LDesign',
    subtitle: 'Learn more about this project',
    description: 'LDesign is a modern frontend framework designed to provide the best development experience and performance.',
    version: 'Version',
    author: 'Author',
    license: 'License',
    repository: 'Repository',
    techStack: 'Tech Stack',
    goals: {
      title: 'Our Goals',
      api: 'Provide simple yet powerful API',
      performance: 'Optimize performance, reduce memory usage',
      typescript: 'Complete TypeScript support',
      integration: 'Deep integration with @ldesign/engine',
      extensible: 'Rich feature extensions'
    },
    features: {
      title: 'Key Features',
      items: {
        vue3: 'Based on Vue 3',
        vite: 'Vite Build Tool',
        typescript: 'TypeScript Support',
        i18n: 'Internationalization',
        router: 'Smart Router System',
        engine: 'Powerful Engine Core'
      },
      vue3Desc: 'Built on Vue 3, providing excellent performance',
      viteDesc: 'Fast development server and build tool',
      i18nDesc: 'Complete internationalization support'
    },
    team: {
      title: 'Development Team',
      description: 'Maintained by a group of passionate developers'
    },
    contact: {
      title: 'Contact Us',
      email: 'Email',
      github: 'GitHub',
      website: 'Website',
      community: 'Community'
    }
  },

  // Login Page
  login: {
    title: 'Welcome Back',
    subtitle: 'Please enter your account information',
    username: 'Username',
    password: 'Password',
    usernamePlaceholder: 'Enter your username',
    passwordPlaceholder: 'Enter your password',
    noAccount: "Don't have an account?",
    registerNow: 'Register Now',
    orContinueWith: 'Or continue with',
    forgotPassword: 'Forgot Password?',
    rememberMe: 'Remember Me',
    submit: 'Login',
    submitting: 'Logging in...',
    success: 'Login successful',
    sendCode: 'Get Code',
    resendIn: 'Resend in {{seconds}}s',
    codeSent: 'Code sent',
    help: 'Help Center',
    register: 'Register now',
    or: 'or',
    loginWith: 'Login with {provider}',
    modes: {
      password: 'Password',
      sms: 'SMS',
      qrcode: 'QR Code'
    },
    placeholders: {
      username: 'Username / Email',
      password: 'Password',
      phone: 'Phone Number',
      smsCode: 'Verification Code'
    },
    providers: {
      wechat: 'WeChat',
      github: 'GitHub',
      google: 'Google'
    },
    qrcode: {
      loading: 'Loading QR Code...',
      tip: 'Scan with mobile app to login',
      refresh: 'Refresh QR Code'
    },
    errors: {
      required: 'Please fill in required fields',
      invalid: 'Invalid username or password',
      failed: 'Login failed, please try again',
      phoneRequired: 'Please enter phone number',
      invalidPhone: 'Invalid phone number format',
      invalidCode: 'Invalid verification code',
      sendCodeFailed: 'Failed to send code',
      usernameRequired: 'Please enter username',
      passwordRequired: 'Please enter password',
      minLength: 'At least {min} characters required',
      network: 'Network error, please try again later'
    }
  },

  // Crypto Demo Page
  crypto: {
    title: 'Crypto Demo',
    subtitle: 'Experience @ldesign/crypto encryption features',
    aes: {
      title: 'AES Encryption',
      plaintext: 'Plain Text',
      plaintextPlaceholder: 'Enter text to encrypt',
      key: 'Key',
      keyPlaceholder: 'Enter key',
      encrypt: 'Encrypt',
      decrypt: 'Decrypt',
      clear: 'Clear',
      encryptedResult: 'Encrypted Result',
      decryptedResult: 'Decrypted Result'
    },
    hash: {
      title: 'Hash Algorithm',
      plaintext: 'Plain Text',
      plaintextPlaceholder: 'Enter text to hash',
      algorithm: 'Algorithm',
      compute: 'Compute Hash',
      clear: 'Clear',
      result: 'Hash Result'
    },
    hmac: {
      title: 'HMAC Authentication',
      message: 'Message',
      messagePlaceholder: 'Enter message',
      key: 'Key',
      keyPlaceholder: 'Enter key',
      generate: 'Generate HMAC',
      verify: 'Verify',
      clear: 'Clear',
      result: 'HMAC Result',
      verification: 'Verification Result',
      valid: 'Valid',
      invalid: 'Invalid'
    },
    rsa: {
      title: 'RSA Encryption',
      generateKeys: 'Generate Key Pair',
      publicKey: 'Public Key',
      privateKey: 'Private Key',
      plaintext: 'Plain Text',
      plaintextPlaceholder: 'Enter text to encrypt',
      encrypt: 'Encrypt',
      decrypt: 'Decrypt',
      clear: 'Clear',
      encryptedResult: 'Encrypted Result',
      decryptedResult: 'Decrypted Result'
    },
    base64: {
      title: 'Base64 Encoding',
      plaintext: 'Plain Text',
      plaintextPlaceholder: 'Enter text to encode',
      encode: 'Encode',
      decode: 'Decode',
      clear: 'Clear',
      encodedResult: 'Encoded Result',
      decodedResult: 'Decoded Result'
    },
    keyGenerator: {
      title: 'Key Generator',
      keyLength: 'Key Length (bytes)',
      bytes16: '16 bytes (128 bits)',
      bytes24: '24 bytes (192 bits)',
      bytes32: '32 bytes (256 bits)',
      generate: 'Generate Key',
      copy: 'Copy',
      result: 'Generated Key',
      copied: 'Key copied to clipboard',
      copyFailed: 'Copy failed, please copy manually'
    },
    passwordStrength: {
      title: 'Password Strength Checker',
      password: 'Password',
      passwordPlaceholder: 'Enter password',
      checkStrength: 'Check Strength',
      strength: 'Password Strength',
      result: 'Strength Result',
      weak: 'Weak',
      medium: 'Medium',
      strong: 'Strong',
      veryStrong: 'Very Strong',
      pleaseEnter: 'Please enter password'
    }
  },

  // HTTP Demo Page
  http: {
    title: 'HTTP Demo',
    subtitle: 'Experience @ldesign/http network request features',
    get: {
      title: 'GET Request',
      url: 'Request URL',
      urlPlaceholder: 'Enter API address',
      send: 'Send Request',
      sending: 'Sending...',
      clear: 'Clear',
      response: 'Response',
      error: 'Error'
    },
    post: {
      title: 'POST Request',
      url: 'Request URL',
      urlPlaceholder: 'Enter API address',
      data: 'Request Data (JSON)',
      dataPlaceholder: 'Enter JSON data',
      send: 'Send Request',
      sending: 'Sending...',
      clear: 'Clear',
      response: 'Response',
      error: 'Error'
    },
    interceptor: {
      title: 'Interceptor',
      description: 'Interceptors can intercept requests and responses for authentication, logging, etc.',
      addRequest: 'Add Request Interceptor',
      addResponse: 'Add Response Interceptor',
      clear: 'Clear Interceptors',
      logs: 'Interceptor Logs'
    },
    cache: {
      title: 'Request Cache',
      url: 'Cache URL',
      urlPlaceholder: 'Enter API to cache',
      ttl: 'Cache TTL (seconds)',
      fetch: 'Fetch (with cache)',
      clearCache: 'Clear Cache',
      stats: 'Cache Stats',
      hits: 'Hits',
      misses: 'Misses',
      hitRate: 'Hit Rate'
    },
    retry: {
      title: 'Retry Mechanism',
      url: 'Request URL',
      urlPlaceholder: 'Enter potentially failing API',
      maxRetries: 'Max Retries',
      retryDelay: 'Retry Delay (ms)',
      sendWithRetry: 'Send (with retry)',
      response: 'Response',
      error: 'Error'
    },
    timeout: {
      title: 'Timeout Control',
      url: 'Request URL',
      timeout: 'Timeout (ms)',
      sendWithTimeout: 'Send (with timeout)',
      response: 'Response',
      error: 'Error'
    }
  },

  // API Demo Page
  api: {
    title: 'API Demo',
    subtitle: 'Experience @ldesign/api interface management features',
    basic: {
      title: 'API Engine Basics',
      description: 'API Engine provides unified interface management with plugin support.',
      basicCall: 'Basic Call',
      viewStatus: 'View Status',
      engineStatus: 'Engine Status'
    },
    system: {
      title: 'System API',
      username: 'Username',
      usernamePlaceholder: 'Enter username',
      password: 'Password',
      passwordPlaceholder: 'Enter password',
      simulateLogin: 'Simulate Login',
      getUserInfo: 'Get User Info',
      logout: 'Logout',
      userInfo: 'User Info',
      error: 'Error'
    },
    caching: {
      title: 'Caching Strategy',
      method: 'API Method Name',
      methodPlaceholder: 'e.g.: getUser',
      ttl: 'Cache TTL (seconds)',
      callWithCache: 'Call with Cache',
      cacheStats: 'Cache Stats',
      clearCache: 'Clear Cache',
      items: 'Items',
      hitRate: 'Hit Rate'
    },
    batch: {
      title: 'Batch Requests',
      description: 'Batch requests can send multiple API calls simultaneously for better efficiency.',
      api1: 'API 1',
      api2: 'API 2',
      api3: 'API 3',
      sendBatch: 'Send Batch',
      results: 'Batch Results',
      error: 'Error'
    },
    plugin: {
      title: 'Plugin System',
      description: 'API Engine supports plugin extensions for logging, retry, caching, etc.',
      addLogger: 'Add Logger Plugin',
      addRetry: 'Add Retry Plugin',
      addCache: 'Add Cache Plugin',
      removePlugins: 'Remove All Plugins',
      pluginLogs: 'Plugin Logs'
    }
  },

  // Performance Monitor Page
  performance: {
    title: 'Performance Dashboard',
    subtitle: 'Real-time application performance monitoring, showcasing Engine capabilities',
    overview: {
      title: 'Performance Overview',
      startupTime: 'Startup Time',
      memoryUsage: 'Memory Usage',
      ms: 'ms',
      mb: 'MB'
    },
    marks: {
      title: 'Performance Marks',
      addMark: 'Add Mark',
      name: 'Mark Name',
      namePlaceholder: 'e.g.: feature-loaded',
      time: 'Time',
      clear: 'Clear All'
    },
    cache: {
      title: 'Cache Statistics',
      entries: 'Cache Entries',
      hitRate: 'Hit Rate',
      size: 'Cache Size',
      kb: 'KB'
    },
    realtime: {
      title: 'Real-time Monitoring',
      start: 'Start Monitoring',
      stop: 'Stop Monitoring',
      fps: 'FPS',
      cpu: 'CPU Usage',
      memory: 'Memory',
      network: 'Network'
    },
    testing: {
      title: 'Performance Testing Tools',
      stressTest: 'Stress Test',
      memoryTest: 'Memory Test',
      renderTest: 'Render Test',
      startTest: 'Start Test',
      stopTest: 'Stop Test',
      results: 'Test Results'
    }
  },

  // State Management Page
  state: {
    title: 'State Management Demo',
    subtitle: 'Showcasing Engine StateManager features: CRUD, Time Travel, Persistence',
    crud: {
      title: 'State CRUD Operations',
      key: 'Key Name',
      keyPlaceholder: 'e.g.: user.name',
      value: 'Value (JSON)',
      valuePlaceholder: '{"name": "John"}',
      setState: 'Set State',
      getState: 'Get State',
      deleteState: 'Delete State',
      currentValue: 'Current Value'
    },
    watch: {
      title: 'State Watch',
      key: 'Watch Key',
      keyPlaceholder: 'e.g.: user',
      startWatch: 'Start Watching',
      stopWatch: 'Stop Watching',
      events: 'Watch Events',
      recent: 'Recent {count}',
      noEvents: 'No events'
    },
    history: {
      title: 'Time Travel (History)',
      undo: 'Undo',
      redo: 'Redo',
      clear: 'Clear History',
      currentIndex: 'Current Index',
      totalSteps: 'Total Steps',
      timeline: 'Timeline'
    },
    persistence: {
      title: 'Persistence',
      save: 'Save to LocalStorage',
      load: 'Load from LocalStorage',
      clear: 'Clear Persistence',
      status: 'Persistence Status',
      enabled: 'Enabled',
      disabled: 'Disabled'
    },
    computed: {
      title: 'Computed State',
      description: 'Derived state automatically computed from other states',
      fullName: 'Full Name',
      age: 'Age',
      isAdult: 'Is Adult'
    }
  },

  // Event System Page
  event: {
    title: 'Event System Demo',
    subtitle: 'Showcasing Engine event system: Pub/Sub, Priority, Event Replay',
    emit: {
      title: 'Event Emit',
      name: 'Event Name',
      namePlaceholder: 'e.g.: user:login',
      data: 'Event Data (JSON)',
      dataPlaceholder: '{"user": "John"}',
      send: 'Send Event',
      sendOnce: 'Send Once',
      broadcast: 'Broadcast'
    },
    subscribe: {
      title: 'Event Subscribe (On)',
      name: 'Subscribe Event Name',
      namePlaceholder: 'e.g.: user:*',
      priority: 'Priority',
      priorityHigh: 'High (100)',
      priorityMedium: 'Medium (50)',
      priorityLow: 'Low (0)',
      subscribe: 'Subscribe',
      subscribeOnce: 'Subscribe Once',
      unsubscribeAll: 'Unsubscribe All',
      current: 'Current Subscriptions',
      count: '{count} subscriptions'
    },
    logs: {
      title: 'Event Logs',
      recent: 'Recent {count}',
      clear: 'Clear Logs',
      noLogs: 'No logs',
      event: 'Event',
      data: 'Data',
      time: 'Time'
    },
    replay: {
      title: 'Event Replay',
      description: 'Replay historical events for debugging and testing',
      start: 'Start Recording',
      stop: 'Stop Recording',
      replay: 'Replay',
      clear: 'Clear Records',
      recorded: 'Recorded {count} events'
    },
    wildcard: {
      title: 'Wildcard Subscription',
      description: 'Subscribe to multiple events using wildcard patterns',
      pattern: 'Event Pattern',
      patternPlaceholder: 'e.g.: user:* or *.created',
      subscribe: 'Subscribe Pattern',
      matched: 'Matched {count} events'
    }
  },

  // Concurrency Control Page
  concurrency: {
    title: 'Concurrency Control Demo',
    subtitle: 'Showcasing Engine concurrency features: Rate Limiting, Queue, Priority Scheduling',
    queue: {
      title: 'Task Queue',
      description: 'Control concurrent task execution to avoid resource overload',
      concurrency: 'Concurrency',
      addTask: 'Add Task',
      addMultiple: 'Add Multiple',
      pause: 'Pause Queue',
      resume: 'Resume Queue',
      clear: 'Clear Queue',
      status: 'Queue Status',
      pending: 'Pending',
      running: 'Running',
      completed: 'Completed',
      failed: 'Failed'
    },
    throttle: {
      title: 'Throttle',
      description: 'Limit function execution frequency, execute once within specified time',
      interval: 'Throttle Interval (ms)',
      trigger: 'Trigger Function',
      count: 'Execution Count',
      reset: 'Reset Count'
    },
    debounce: {
      title: 'Debounce',
      description: 'Delay function execution, execute only after last call',
      delay: 'Debounce Delay (ms)',
      trigger: 'Trigger Function',
      count: 'Execution Count',
      reset: 'Reset Count'
    },
    priority: {
      title: 'Priority Scheduling',
      description: 'Schedule task execution based on priority',
      taskName: 'Task Name',
      taskNamePlaceholder: 'e.g.: data-loading',
      priority: 'Priority',
      high: 'High',
      medium: 'Medium',
      low: 'Low',
      addTask: 'Add Task',
      queue: 'Task Queue',
      noTasks: 'No tasks'
    },
    semaphore: {
      title: 'Semaphore',
      description: 'Control concurrent access to resources',
      maxConcurrent: 'Max Concurrent',
      acquire: 'Acquire',
      release: 'Release',
      available: 'Available',
      waiting: 'Waiting Queue'
    }
  },

  // Plugin System Page
  plugin: {
    title: 'Plugin System Demo',
    subtitle: 'Showcasing Engine plugin system: Dynamic Loading, Lifecycle, Communication',
    basic: {
      title: 'Plugin Basics',
      description: 'Engine provides complete plugin system with dynamic loading and unloading',
      installed: 'Installed Plugins',
      available: 'Available Plugins',
      install: 'Install',
      uninstall: 'Uninstall',
      enable: 'Enable',
      disable: 'Disable',
      configure: 'Configure'
    },
    lifecycle: {
      title: 'Lifecycle',
      description: 'Plugins have complete lifecycle hooks',
      onInstall: 'On Install',
      onEnable: 'On Enable',
      onDisable: 'On Disable',
      onUninstall: 'On Uninstall',
      logs: 'Lifecycle Logs'
    },
    communication: {
      title: 'Plugin Communication',
      description: 'Plugins can communicate through event bus',
      sender: 'Sender Plugin',
      receiver: 'Receiver Plugin',
      message: 'Message',
      send: 'Send Message',
      logs: 'Communication Logs'
    },
    custom: {
      title: 'Custom Plugin',
      description: 'Create and register custom plugins',
      pluginName: 'Plugin Name',
      pluginNamePlaceholder: 'e.g.: my-plugin',
      version: 'Version',
      versionPlaceholder: 'e.g.: 1.0.0',
      author: 'Author',
      authorPlaceholder: 'Your name',
      create: 'Create Plugin',
      register: 'Register Plugin',
      created: 'Plugin Created'
    }
  },

  // Dashboard Page
  dashboard: {
    title: 'Dashboard',
    subtitle: 'Welcome back, {username}',
    currentRoute: 'Current Route Info',
    engineStatus: 'Engine Status',
    appName: 'App Name',
    environment: 'Environment',
    debugMode: 'Debug Mode',
    routeHistory: 'Route History',
    noHistory: 'No history records',
    performanceMonitor: 'Performance Monitor',
    navigationTime: 'Navigation Time',
    cacheHitRate: 'Cache Hit Rate',
    totalNavigations: 'Total Navigations',
    memoryUsage: 'Memory Usage',
    allRoutes: 'All Routes',
    auth: 'Auth',
    requiresAuth: 'Requires Auth',
    public: 'Public',
    history: 'History',
    errors: {
      loadHistory: 'Failed to load route history'
    },
    overview: {
      title: 'Overview',
      totalUsers: 'Total Users',
      activeUsers: 'Active Users',
      newUsers: 'New Users',
      revenue: 'Revenue',
      totalVisits: 'Total Visits',
      orders: 'Orders'
    },
    stats: {
      title: 'Statistics',
      daily: 'Daily',
      weekly: 'Weekly',
      monthly: 'Monthly',
      yearly: 'Yearly'
    },
    activity: {
      title: 'Recent Activity',
      noActivity: 'No activity records'
    },
    quickActions: {
      title: 'Quick Actions',
      newPost: 'New Post',
      viewReports: 'View Reports',
      settings: 'Settings',
      help: 'Help Center'
    },
    notifications: {
      title: 'Notifications',
      markAllRead: 'Mark all as read',
      noNotifications: 'No new notifications'
    }
  },

  // Common
  common: {
    loading: 'Loading...',
    path: 'Path',
    name: 'Name',
    params: 'Params',
    query: 'Query',
    unnamed: 'unnamed',
    on: 'On',
    off: 'Off',
    visit: 'Visit',
    actions: 'Actions',
    clear: 'Clear',
    guest: 'Guest',
    error: 'Error',
    success: 'Success',
    warning: 'Warning',
    info: 'Info',
    confirm: 'Confirm',
    cancel: 'Cancel',
    save: 'Save',
    delete: 'Delete',
    edit: 'Edit',
    add: 'Add',
    search: 'Search',
    filter: 'Filter',
    export: 'Export',
    import: 'Import',
    refresh: 'Refresh',
    back: 'Back',
    next: 'Next',
    previous: 'Previous',
    finish: 'Finish',
    close: 'Close',
    yes: 'Yes',
    no: 'No',
    ok: 'OK',
    apply: 'Apply',
    reset: 'Reset',
    selectAll: 'Select All',
    deselectAll: 'Deselect All',
    more: 'More',
    less: 'Less',
    showMore: 'Show More',
    showLess: 'Show Less',
    noData: 'No Data',
    noResults: 'No Results Found',
    tryAgain: 'Try Again',
    viewDetails: 'View Details'
  },

  // Error Messages
  errors: {
    startup: {
      title: 'Application Failed to Start',
      message: 'Unknown error',
      action: 'Reload'
    },
    404: {
      title: 'Page Not Found',
      message: 'Sorry, the page you are looking for does not exist.',
      action: 'Go Home',
      back: 'Go Back'
    },
    500: {
      title: 'Server Error',
      message: 'Sorry, the server encountered a problem.',
      action: 'Refresh Page'
    },
    network: {
      title: 'Network Error',
      message: 'Please check your network connection.',
      action: 'Retry'
    },
    unauthorized: {
      title: 'Unauthorized',
      message: 'You need to login to access this page.',
      action: 'Go to Login'
    },
    forbidden: {
      title: 'Access Forbidden',
      message: 'You do not have permission to access this page.',
      action: 'Go Back'
    }
  },

  // Validation Messages
  validation: {
    required: '{field} is required',
    email: 'Please enter a valid email address',
    min: '{field} must be at least {min} characters',
    max: '{field} cannot exceed {max} characters',
    between: '{field} must be between {min} and {max}',
    numeric: '{field} must be a number',
    alphanumeric: '{field} can only contain letters and numbers',
    pattern: '{field} format is incorrect',
    confirmed: '{field} confirmation does not match',
    unique: '{field} already exists',
    date: 'Please enter a valid date',
    dateAfter: 'Date must be after {date}',
    dateBefore: 'Date must be before {date}',
    url: 'Please enter a valid URL',
    phone: 'Please enter a valid phone number'
  },

  // Date and Time
  datetime: {
    today: 'Today',
    yesterday: 'Yesterday',
    tomorrow: 'Tomorrow',
    thisWeek: 'This Week',
    lastWeek: 'Last Week',
    nextWeek: 'Next Week',
    thisMonth: 'This Month',
    lastMonth: 'Last Month',
    nextMonth: 'Next Month',
    thisYear: 'This Year',
    lastYear: 'Last Year',
    nextYear: 'Next Year',
    selectDate: 'Select Date',
    selectTime: 'Select Time',
    selectDateTime: 'Select Date Time'
  },

  // Theme Settings
  theme: {
    title: 'Theme',
    selectThemeColor: 'Select Theme Color',
    customColor: 'Custom Color',
    custom: 'Current',
    mode: 'Theme Mode',
    light: 'Light',
    dark: 'Dark',
    apply: 'Apply',
    add: 'Add',
    remove: 'Remove',
    searchPlaceholder: 'Search colors...',
    presetThemes: 'Preset Themes',
    addCustomTheme: 'Add Custom Theme',
    themeName: 'Theme name',
    confirmRemove: 'Remove this theme?',
    presets: {
      blue: 'Daybreak Blue',
      purple: 'Purple',
      cyan: 'Cyan',
      green: 'Polar Green',
      magenta: 'Magenta',
      red: 'Dust Red',
      orange: 'Sunset Orange',
      yellow: 'Sunrise Yellow',
      volcano: 'Volcano',
      geekblue: 'Geek Blue',
      lime: 'Lime',
      gold: 'Gold',
      gray: 'Neutral Gray',
      'dark-blue': 'Dark Blue',
      'dark-green': 'Dark Green',
      // Custom themes
      sunset: 'Sunset Orange',
      forest: 'Forest Green',
      midnight: 'Midnight Blue',
      lavender: 'Lavender Dream',
      coral: 'Coral Reef'
    }
  }
};
