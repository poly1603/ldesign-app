/**
 * 日本語言語パック (Japanese Language Pack)
 */

export default {
  // カスタムテーマ
  customThemes: {
    sunset: 'サンセットオレンジ',
    forest: 'フォレストグリーン',
    midnight: 'ミッドナイトブルー',
    lavender: 'ラベンダードリーム',
    coral: 'コーラルリーフ'
  },

  // アプリ情報
  app: {
    name: 'LDesign シンプルアプリ',
    title: 'LDesign シンプルアプリ',
    description: 'LDesign Engine で構築されたサンプルアプリケーション',
    copyright: '© 2024 LDesign. All rights reserved.'
  },

  // ナビゲーションメニュー
  nav: {
    home: 'ホーム',
    about: '概要',
    crypto: '暗号化デモ',
    http: 'HTTPデモ',
    api: 'APIデモ',
    dashboard: 'ダッシュボード',
    login: 'ログイン',
    logout: 'ログアウト',
    language: '言語',
    performance: 'パフォーマンス監視',
    state: '状態管理',
    event: 'イベントシステム',
    concurrency: '並行制御',
    plugin: 'プラグインシステム'
  },

  // ホームページ
  home: {
    title: 'LDesign へようこそ',
    subtitle: 'モダンで高性能なフロントエンド開発フレームワーク',
    description: '@ldesign/engine で構築されたシンプルなアプリケーションの例',
    demos: {
      title: '機能デモ',
      crypto: {
        title: '暗号化デモ',
        description: 'AES、RSA、ハッシュアルゴリズムなどの暗号化機能を体験'
      },
      http: {
        title: 'HTTPデモ',
        description: 'ネットワークリクエスト、インターセプター、キャッシュなどの機能を体験'
      },
      api: {
        title: 'APIデモ',
        description: 'APIエンジン、プラグインシステム、バッチリクエストなどの機能を体験'
      }
    },
    features: {
      title: 'コア機能',
      list: {
        performance: '極限のパフォーマンス',
        performanceDesc: 'Vue 3 ベースで優れた実行時パフォーマンスを提供',
        modular: 'モジュラーアーキテクチャ',
        modularDesc: '柔軟なプラグインシステムとオンデマンドローディング',
        typescript: 'TypeScript サポート',
        typescriptDesc: '完全な型定義で最高の開発体験を提供'
      }
    },
    getStarted: '始める',
    learnMore: '詳細を見る',
    viewDocs: 'ドキュメント',
    currentTime: '現在時刻',
    welcomeMessage: 'こんにちは、{name}さん！LDesign へようこそ。',
    stats: {
      routes: 'ルート数',
      visits: '訪問回数',
      cacheSize: 'キャッシュサイズ'
    }
  },

  // 概要ページ
  about: {
    title: 'LDesign について',
    subtitle: 'このプロジェクトの詳細情報',
    description: 'LDesign は、最高の開発体験とパフォーマンスを提供するモダンなフロントエンドフレームワークです。',
    version: 'バージョン',
    author: '作者',
    license: 'ライセンス',
    repository: 'リポジトリ',
    techStack: '技術スタック',
    goals: {
      title: '私たちの目標',
      api: 'シンプルで強力な API を提供',
      performance: 'パフォーマンスの最適化とメモリ使用量の削減',
      typescript: '完全な TypeScript サポート',
      integration: '@ldesign/engine との深い統合',
      extensible: '豊富な機能拡張'
    },
    features: {
      title: '主な特徴',
      items: {
        vue3: 'Vue 3 ベース',
        vite: 'Vite ビルドツール',
        typescript: 'TypeScript サポート',
        i18n: '国際化対応',
        router: 'スマートルーターシステム',
        engine: '強力なエンジンコア'
      },
      vue3Desc: 'Vue 3 で構築され、優れたパフォーマンスを提供',
      viteDesc: '高速な開発サーバーとビルドツール',
      i18nDesc: '完全な国際化サポート'
    },
    team: {
      title: '開発チーム',
      description: '情熱的な開発者グループによってメンテナンスされています'
    },
    contact: {
      title: 'お問い合わせ',
      email: 'メール',
      github: 'GitHub',
      website: 'ウェブサイト',
      community: 'コミュニティ'
    }
  },

  // ログインページ
  login: {
    title: 'アカウントにログイン',
    subtitle: 'アカウント情報を入力してください',
    username: 'ユーザー名',
    password: 'パスワード',
    usernamePlaceholder: 'ユーザー名を入力',
    passwordPlaceholder: 'パスワードを入力',
    rememberMe: 'ログイン状態を保持',
    forgotPassword: 'パスワードをお忘れですか？',
    submit: 'ログイン',
    submitting: 'ログイン中...',
    noAccount: 'アカウントをお持ちでないですか？',
    register: '今すぐ登録',
    or: 'または',
    loginWith: '{provider} でログイン',
    modes: {
      password: 'パスワード',
      sms: 'SMS',
      qrcode: 'QR コード'
    },
    placeholders: {
      username: 'ユーザー名 / メール',
      password: 'パスワード',
      phone: '電話番号',
      smsCode: '確認コード'
    },
    providers: {
      wechat: 'WeChat',
      github: 'GitHub',
      google: 'Google'
    },
    qrcode: {
      loading: 'QR コード読み込み中...',
      tip: 'モバイルアプリでスキャンしてログイン',
      refresh: 'QR コード更新'
    },
    errors: {
      required: '必須フィールドを入力してください',
      invalid: 'ユーザー名またはパスワードが正しくありません',
      failed: 'ログインに失敗しました。もう一度お試しください',
      phoneRequired: '電話番号を入力してください',
      invalidPhone: '電話番号の形式が正しくありません',
      invalidCode: '確認コードが正しくありません',
      sendCodeFailed: 'コード送信に失敗しました',
      usernameRequired: 'ユーザー名を入力してください',
      passwordRequired: 'パスワードを入力してください',
      minLength: '最低 {min} 文字必要です',
      network: 'ネットワークエラー。後でもう一度お試しください'
    },
    success: 'ログイン成功！'
  },

  // 暗号化デモページ
  crypto: {
    title: '暗号化デモ',
    subtitle: '@ldesign/crypto 暗号化機能を体験',
    aes: {
      title: 'AES 暗号化',
      plaintext: '平文',
      plaintextPlaceholder: '暗号化するテキストを入力',
      key: 'キー',
      keyPlaceholder: 'キーを入力',
      encrypt: '暗号化',
      decrypt: '復号化',
      clear: 'クリア',
      encryptedResult: '暗号化結果',
      decryptedResult: '復号化結果'
    },
    hash: {
      title: 'ハッシュアルゴリズム',
      plaintext: '平文',
      plaintextPlaceholder: 'ハッシュ化するテキストを入力',
      algorithm: 'アルゴリズム',
      compute: 'ハッシュ計算',
      clear: 'クリア',
      result: 'ハッシュ結果'
    },
    hmac: {
      title: 'HMAC メッセージ認証',
      message: 'メッセージ',
      messagePlaceholder: 'メッセージを入力',
      key: 'キー',
      keyPlaceholder: 'キーを入力',
      generate: 'HMAC 生成',
      verify: '検証',
      clear: 'クリア',
      result: 'HMAC 結果',
      verification: '検証結果',
      valid: '有効',
      invalid: '無効'
    },
    rsa: {
      title: 'RSA 暗号化',
      generateKeys: 'キーペア生成',
      publicKey: '公開鍵',
      privateKey: '秘密鍵',
      plaintext: '平文',
      plaintextPlaceholder: '暗号化するテキストを入力',
      encrypt: '暗号化',
      decrypt: '復号化',
      clear: 'クリア',
      encryptedResult: '暗号化結果',
      decryptedResult: '復号化結果'
    },
    base64: {
      title: 'Base64 エンコーディング',
      plaintext: '平文',
      plaintextPlaceholder: 'エンコードするテキストを入力',
      encode: 'エンコード',
      decode: 'デコード',
      clear: 'クリア',
      encodedResult: 'エンコード結果',
      decodedResult: 'デコード結果'
    },
    keyGenerator: {
      title: 'キー生成器',
      keyLength: 'キー長（バイト）',
      bytes16: '16 バイト (128 ビット)',
      bytes24: '24 バイト (192 ビット)',
      bytes32: '32 バイト (256 ビット)',
      generate: 'キー生成',
      copy: 'コピー',
      result: '生成されたキー',
      copied: 'キーがクリップボードにコピーされました',
      copyFailed: 'コピーに失敗しました。手動でコピーしてください'
    },
    passwordStrength: {
      title: 'パスワード強度チェッカー',
      password: 'パスワード',
      passwordPlaceholder: 'パスワードを入力',
      checkStrength: '強度チェック',
      strength: 'パスワード強度',
      result: '強度結果',
      weak: '弱い',
      medium: '中',
      strong: '強い',
      veryStrong: '非常に強い',
      pleaseEnter: 'パスワードを入力してください'
    }
  },

  // HTTP デモページ
  http: {
    title: 'HTTP デモ',
    subtitle: '@ldesign/http ネットワークリクエスト機能を体験',
    get: {
      title: 'GET リクエスト',
      url: 'リクエスト URL',
      urlPlaceholder: 'API アドレスを入力',
      send: 'リクエスト送信',
      sending: '送信中...',
      clear: 'クリア',
      response: 'レスポンス',
      error: 'エラー'
    },
    post: {
      title: 'POST リクエスト',
      url: 'リクエスト URL',
      urlPlaceholder: 'API アドレスを入力',
      data: 'リクエストデータ (JSON)',
      dataPlaceholder: 'JSON データを入力',
      send: 'リクエスト送信',
      sending: '送信中...',
      clear: 'クリア',
      response: 'レスポンス',
      error: 'エラー'
    },
    interceptor: {
      title: 'インターセプター',
      description: 'リクエストとレスポンスをインターセプトし、認証やログ記録などの機能を追加できます。',
      addRequest: 'リクエストインターセプター追加',
      addResponse: 'レスポンスインターセプター追加',
      clear: 'インターセプタークリア',
      logs: 'インターセプターログ'
    },
    cache: {
      title: 'リクエストキャッシュ',
      url: 'キャッシュ URL',
      urlPlaceholder: 'キャッシュする API を入力',
      ttl: 'キャッシュ TTL (秒)',
      fetch: '取得（キャッシュ付き）',
      clearCache: 'キャッシュクリア',
      stats: 'キャッシュ統計',
      hits: 'ヒット',
      misses: 'ミス',
      hitRate: 'ヒット率'
    },
    retry: {
      title: 'リトライメカニズム',
      url: 'リクエスト URL',
      urlPlaceholder: '失敗する可能性のある API を入力',
      maxRetries: '最大リトライ回数',
      retryDelay: 'リトライ遅延 (ミリ秒)',
      sendWithRetry: '送信（リトライ付き）',
      response: 'レスポンス',
      error: 'エラー'
    },
    timeout: {
      title: 'タイムアウト制御',
      url: 'リクエスト URL',
      timeout: 'タイムアウト (ミリ秒)',
      sendWithTimeout: '送信（タイムアウト付き）',
      response: 'レスポンス',
      error: 'エラー'
    }
  },

  // API デモページ
  api: {
    title: 'API デモ',
    subtitle: '@ldesign/api インターフェース管理機能を体験',
    basic: {
      title: 'API Engine 基礎',
      description: 'API Engine は統一されたインターフェース管理機能を提供し、プラグインサポートを備えています。',
      basicCall: '基本呼び出し',
      viewStatus: 'ステータス表示',
      engineStatus: 'Engine ステータス'
    },
    system: {
      title: 'システム API',
      username: 'ユーザー名',
      usernamePlaceholder: 'ユーザー名を入力',
      password: 'パスワード',
      passwordPlaceholder: 'パスワードを入力',
      simulateLogin: 'ログインシミュレート',
      getUserInfo: 'ユーザー情報取得',
      logout: 'ログアウト',
      userInfo: 'ユーザー情報',
      error: 'エラー'
    },
    caching: {
      title: 'キャッシュ戦略',
      method: 'API メソッド名',
      methodPlaceholder: '例: getUser',
      ttl: 'キャッシュ TTL (秒)',
      callWithCache: 'キャッシュ付き呼び出し',
      cacheStats: 'キャッシュ統計',
      clearCache: 'キャッシュクリア',
      items: 'アイテム',
      hitRate: 'ヒット率'
    },
    batch: {
      title: 'バッチリクエスト',
      description: 'バッチリクエストは複数の API 呼び出しを同時に送信して効率を向上させます。',
      api1: 'API 1',
      api2: 'API 2',
      api3: 'API 3',
      sendBatch: 'バッチ送信',
      results: 'バッチ結果',
      error: 'エラー'
    },
    plugin: {
      title: 'プラグインシステム',
      description: 'API Engine はログ、リトライ、キャッシュなどのプラグイン拡張をサポートします。',
      addLogger: 'ログプラグイン追加',
      addRetry: 'リトライプラグイン追加',
      addCache: 'キャッシュプラグイン追加',
      removePlugins: 'すべてのプラグインを削除',
      pluginLogs: 'プラグインログ'
    }
  },

  // パフォーマンス監視ページ
  performance: {
    title: 'パフォーマンスダッシュボード',
    subtitle: 'リアルタイムアプリケーションパフォーマンス監視、Engine 機能を展示',
    overview: {
      title: 'パフォーマンス概要',
      startupTime: '起動時間',
      memoryUsage: 'メモリ使用量',
      ms: 'ミリ秒',
      mb: 'MB'
    },
    marks: {
      title: 'パフォーマンスマーク',
      addMark: 'マーク追加',
      name: 'マーク名',
      namePlaceholder: '例: feature-loaded',
      time: '時間',
      clear: 'すべてクリア'
    },
    cache: {
      title: 'キャッシュ統計',
      entries: 'キャッシュエントリ',
      hitRate: 'ヒット率',
      size: 'キャッシュサイズ',
      kb: 'KB'
    },
    realtime: {
      title: 'リアルタイム監視',
      start: '監視開始',
      stop: '監視停止',
      fps: 'FPS',
      cpu: 'CPU 使用率',
      memory: 'メモリ',
      network: 'ネットワーク'
    },
    testing: {
      title: 'パフォーマンステストツール',
      stressTest: 'ストレステスト',
      memoryTest: 'メモリテスト',
      renderTest: 'レンダリングテスト',
      startTest: 'テスト開始',
      stopTest: 'テスト停止',
      results: 'テスト結果'
    }
  },

  // 状態管理ページ
  state: {
    title: '状態管理デモ',
    subtitle: 'Engine StateManager 機能を展示: CRUD、タイムトラベル、永続化',
    crud: {
      title: '状態 CRUD 操作',
      key: 'キー名',
      keyPlaceholder: '例: user.name',
      value: '値 (JSON)',
      valuePlaceholder: '{"name": "太郎"}',
      setState: '状態設定',
      getState: '状態取得',
      deleteState: '状態削除',
      currentValue: '現在の値'
    },
    watch: {
      title: '状態監視（Watch）',
      key: '監視キー',
      keyPlaceholder: '例: user',
      startWatch: '監視開始',
      stopWatch: '監視停止',
      events: '監視イベント',
      recent: '最近の {count} 件',
      noEvents: 'イベントなし'
    },
    history: {
      title: 'タイムトラベル（履歴）',
      undo: '元に戻す',
      redo: 'やり直す',
      clear: '履歴クリア',
      currentIndex: '現在のインデックス',
      totalSteps: '総ステップ数',
      timeline: 'タイムライン'
    },
    persistence: {
      title: '永続化',
      save: 'LocalStorage に保存',
      load: 'LocalStorage から読み込み',
      clear: '永続化クリア',
      status: '永続化ステータス',
      enabled: '有効',
      disabled: '無効'
    },
    computed: {
      title: '計算状態',
      description: '他の状態から自動的に計算される派生状態',
      fullName: 'フルネーム',
      age: '年齢',
      isAdult: '成人かどうか'
    }
  },

  // イベントシステムページ
  event: {
    title: 'イベントシステムデモ',
    subtitle: 'Engine イベントシステムを展示: Pub/Sub、優先度、イベント再生',
    emit: {
      title: 'イベント発行（Emit）',
      name: 'イベント名',
      namePlaceholder: '例: user:login',
      data: 'イベントデータ (JSON)',
      dataPlaceholder: '{"user": "太郎"}',
      send: 'イベント送信',
      sendOnce: '1回送信',
      broadcast: 'ブロードキャスト'
    },
    subscribe: {
      title: 'イベント購読（On）',
      name: '購読イベント名',
      namePlaceholder: '例: user:*',
      priority: '優先度',
      priorityHigh: '高（100）',
      priorityMedium: '中（50）',
      priorityLow: '低（0）',
      subscribe: '購読',
      subscribeOnce: '1回購読',
      unsubscribeAll: 'すべて購読解除',
      current: '現在の購読',
      count: '{count} 件の購読'
    },
    logs: {
      title: 'イベントログ',
      recent: '最近の {count} 件',
      clear: 'ログクリア',
      noLogs: 'ログなし',
      event: 'イベント',
      data: 'データ',
      time: '時刻'
    },
    replay: {
      title: 'イベント再生',
      description: 'デバッグとテストのために履歴イベントを再生',
      start: '記録開始',
      stop: '記録停止',
      replay: '再生',
      clear: '記録クリア',
      recorded: '{count} 件のイベントを記録'
    },
    wildcard: {
      title: 'ワイルドカード購読',
      description: 'ワイルドカードパターンで複数のイベントを購読',
      pattern: 'イベントパターン',
      patternPlaceholder: '例: user:* または *.created',
      subscribe: 'パターン購読',
      matched: '{count} 件のイベントがマッチ'
    }
  },

  // 並行制御ページ
  concurrency: {
    title: '並行制御デモ',
    subtitle: 'Engine 並行制御機能を展示: レート制限、キュー、優先度スケジューリング',
    queue: {
      title: 'タスクキュー',
      description: '同時実行タスク数を制御してリソース過負荷を回避',
      concurrency: '並行数',
      addTask: 'タスク追加',
      addMultiple: '一括追加',
      pause: 'キュー一時停止',
      resume: 'キュー再開',
      clear: 'キュークリア',
      status: 'キューステータス',
      pending: '待機中',
      running: '実行中',
      completed: '完了',
      failed: '失敗'
    },
    throttle: {
      title: 'スロットル',
      description: '関数実行頻度を制限、指定時間内に1回のみ実行',
      interval: 'スロットル間隔 (ミリ秒)',
      trigger: '関数トリガー',
      count: '実行回数',
      reset: 'カウントリセット'
    },
    debounce: {
      title: 'デバウンス',
      description: '関数実行を遅延、最後の呼び出し後にのみ実行',
      delay: 'デバウンス遅延 (ミリ秒)',
      trigger: '関数トリガー',
      count: '実行回数',
      reset: 'カウントリセット'
    },
    priority: {
      title: '優先度スケジューリング',
      description: 'タスク優先度に基づいて実行をスケジュール',
      taskName: 'タスク名',
      taskNamePlaceholder: '例: データ読み込み',
      priority: '優先度',
      high: '高',
      medium: '中',
      low: '低',
      addTask: 'タスク追加',
      queue: 'タスクキュー',
      noTasks: 'タスクなし'
    },
    semaphore: {
      title: 'セマフォ',
      description: 'リソースへの並行アクセスを制御',
      maxConcurrent: '最大並行数',
      acquire: '取得',
      release: '解放',
      available: '利用可能',
      waiting: '待機キュー'
    }
  },

  // プラグインシステムページ
  plugin: {
    title: 'プラグインシステムデモ',
    subtitle: 'Engine プラグインシステムを展示: 動的ロード、ライフサイクル、通信',
    basic: {
      title: 'プラグイン基礎',
      description: 'Engine は動的ロードとアンロードをサポートする完全なプラグインシステムを提供',
      installed: 'インストール済みプラグイン',
      available: '利用可能なプラグイン',
      install: 'インストール',
      uninstall: 'アンインストール',
      enable: '有効化',
      disable: '無効化',
      configure: '設定'
    },
    lifecycle: {
      title: 'ライフサイクル',
      description: 'プラグインは完全なライフサイクルフックを持っています',
      onInstall: 'インストール時',
      onEnable: '有効化時',
      onDisable: '無効化時',
      onUninstall: 'アンインストール時',
      logs: 'ライフサイクルログ'
    },
    communication: {
      title: 'プラグイン間通信',
      description: 'プラグインはイベントバスを通じて通信できます',
      sender: '送信プラグイン',
      receiver: '受信プラグイン',
      message: 'メッセージ',
      send: 'メッセージ送信',
      logs: '通信ログ'
    },
    custom: {
      title: 'カスタムプラグイン',
      description: 'カスタムプラグインを作成して登録',
      pluginName: 'プラグイン名',
      pluginNamePlaceholder: '例: my-plugin',
      version: 'バージョン',
      versionPlaceholder: '例: 1.0.0',
      author: '作者',
      authorPlaceholder: 'あなたの名前',
      create: 'プラグイン作成',
      register: 'プラグイン登録',
      created: 'プラグイン作成完了'
    }
  },

  // ダッシュボードページ
  dashboard: {
    title: 'ダッシュボード',
    subtitle: 'おかえりなさい、{username}',
    currentRoute: '現在のルート情報',
    engineStatus: 'Engine ステータス',
    appName: 'アプリ名',
    environment: '環境',
    debugMode: 'デバッグモード',
    routeHistory: 'ルート履歴',
    noHistory: '履歴なし',
    performanceMonitor: 'パフォーマンス監視',
    navigationTime: 'ナビゲーション時間',
    cacheHitRate: 'キャッシュヒット率',
    totalNavigations: '総ナビゲーション数',
    memoryUsage: 'メモリ使用量',
    allRoutes: 'すべてのルート',
    auth: '認証',
    requiresAuth: '認証が必要',
    public: '公開',
    history: '履歴',
    errors: {
      loadHistory: 'ルート履歴の読み込みに失敗'
    },
    overview: {
      title: '概要',
      totalUsers: '総ユーザー数',
      activeUsers: 'アクティブユーザー',
      newUsers: '新規ユーザー',
      revenue: '収益',
      totalVisits: '総訪問数',
      orders: '注文数'
    },
    stats: {
      title: '統計データ',
      daily: '日次',
      weekly: '週次',
      monthly: '月次',
      yearly: '年次'
    },
    activity: {
      title: '最近のアクティビティ',
      noActivity: 'アクティビティ記録なし'
    },
    quickActions: {
      title: 'クイックアクション',
      newPost: '新規投稿',
      viewReports: 'レポート表示',
      settings: '設定',
      help: 'ヘルプセンター'
    },
    notifications: {
      title: '通知',
      markAllRead: 'すべて既読にする',
      noNotifications: '新しい通知なし'
    }
  },

  // 共通
  common: {
    loading: '読み込み中...',
    path: 'パス',
    name: '名前',
    params: 'パラメータ',
    query: 'クエリ',
    unnamed: '名前なし',
    on: 'オン',
    off: 'オフ',
    visit: '訪問',
    actions: 'アクション',
    clear: 'クリア',
    guest: 'ゲスト',
    error: 'エラー',
    success: '成功',
    warning: '警告',
    info: '情報',
    confirm: '確認',
    cancel: 'キャンセル',
    save: '保存',
    delete: '削除',
    edit: '編集',
    add: '追加',
    search: '検索',
    filter: 'フィルター',
    export: 'エクスポート',
    import: 'インポート',
    refresh: '更新',
    back: '戻る',
    next: '次へ',
    previous: '前へ',
    finish: '完了',
    close: '閉じる',
    yes: 'はい',
    no: 'いいえ',
    ok: 'OK',
    apply: '適用',
    reset: 'リセット',
    selectAll: 'すべて選択',
    deselectAll: 'すべて解除',
    more: 'もっと',
    less: '少なく',
    showMore: 'もっと表示',
    showLess: '少なく表示',
    noData: 'データなし',
    noResults: '結果が見つかりません',
    tryAgain: '再試行',
    viewDetails: '詳細を表示'
  },

  // エラーメッセージ
  errors: {
    startup: {
      title: 'アプリケーションの起動に失敗',
      message: '不明なエラー',
      action: '再読み込み'
    },
    404: {
      title: 'ページが見つかりません',
      message: '申し訳ございませんが、お探しのページは存在しません。',
      action: 'ホームに戻る',
      back: '前のページに戻る'
    },
    500: {
      title: 'サーバーエラー',
      message: '申し訳ございませんが、サーバーで問題が発生しました。',
      action: 'ページを更新'
    },
    network: {
      title: 'ネットワークエラー',
      message: 'ネットワーク接続を確認してください。',
      action: '再試行'
    },
    unauthorized: {
      title: '未認証',
      message: 'このページにアクセスするにはログインが必要です。',
      action: 'ログインへ'
    },
    forbidden: {
      title: 'アクセス禁止',
      message: 'このページにアクセスする権限がありません。',
      action: '戻る'
    }
  },

  // バリデーションメッセージ
  validation: {
    required: '{field}は必須です',
    email: '有効なメールアドレスを入力してください',
    min: '{field}は最低 {min} 文字必要です',
    max: '{field}は {max} 文字を超えることはできません',
    between: '{field}は {min} から {max} の間である必要があります',
    numeric: '{field}は数字である必要があります',
    alphanumeric: '{field}は文字と数字のみ使用できます',
    pattern: '{field}の形式が正しくありません',
    confirmed: '{field}の確認が一致しません',
    unique: '{field}は既に存在します',
    date: '有効な日付を入力してください',
    dateAfter: '日付は {date} より後である必要があります',
    dateBefore: '日付は {date} より前である必要があります',
    url: '有効な URL を入力してください',
    phone: '有効な電話番号を入力してください'
  },

  // 日時
  datetime: {
    today: '今日',
    yesterday: '昨日',
    tomorrow: '明日',
    thisWeek: '今週',
    lastWeek: '先週',
    nextWeek: '来週',
    thisMonth: '今月',
    lastMonth: '先月',
    nextMonth: '来月',
    thisYear: '今年',
    lastYear: '昨年',
    nextYear: '来年',
    selectDate: '日付を選択',
    selectTime: '時刻を選択',
    selectDateTime: '日時を選択'
  },

  // テーマ設定
  theme: {
    title: 'テーマ',
    selectThemeColor: 'テーマカラーを選択',
    customColor: 'カスタムカラー',
    custom: '現在',
    mode: 'テーマモード',
    light: 'ライト',
    dark: 'ダーク',
    apply: '適用',
    add: '追加',
    remove: '削除',
    searchPlaceholder: 'カラーを検索...',
    presetThemes: 'プリセットテーマ',
    addCustomTheme: 'カスタムテーマを追加',
    themeName: 'テーマ名',
    confirmRemove: 'このテーマを削除しますか？',
    presets: {
      blue: '夜明けのブルー',
      purple: 'パープル',
      cyan: 'シアン',
      green: 'ポーラグリーン',
      magenta: 'マゼンタ',
      red: 'ダストレッド',
      orange: 'サンセットオレンジ',
      yellow: 'サンライズイエロー',
      volcano: 'ボルケーノ',
      geekblue: 'ギークブルー',
      lime: 'ライム',
      gold: 'ゴールド',
      gray: 'ニュートラルグレー',
      'dark-blue': 'ダークブルー',
      'dark-green': 'ダークグリーン',
      // カスタムテーマ
      sunset: 'サンセットオレンジ',
      forest: 'フォレストグリーン',
      midnight: 'ミッドナイトブルー',
      lavender: 'ラベンダードリーム',
      coral: 'コーラルリーフ'
    }
  }
};


