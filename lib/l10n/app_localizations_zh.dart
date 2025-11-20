// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '后台管理系统';

  @override
  String get home => '首页';

  @override
  String get dashboard => '仪表盘';

  @override
  String get projects => '项目管理';

  @override
  String get projectList => '项目列表';

  @override
  String get createProject => '创建项目';

  @override
  String get settings => '设置';

  @override
  String get theme => '主题';

  @override
  String get language => '语言';

  @override
  String get size => '尺寸';

  @override
  String get themeMode => '主题模式';

  @override
  String get lightMode => '亮色模式';

  @override
  String get darkMode => '暗黑模式';

  @override
  String get themeColor => '主题色';

  @override
  String get presetColors => '预设颜色';

  @override
  String get customColor => '自定义颜色';

  @override
  String get globalSize => '全局尺寸';

  @override
  String get compact => '紧凑';

  @override
  String get standard => '标准';

  @override
  String get comfortable => '宽松';

  @override
  String get chinese => '简体中文';

  @override
  String get english => 'English';

  @override
  String get traditionalChinese => '繁體中文';

  @override
  String get minimize => '最小化';

  @override
  String get maximize => '最大化';

  @override
  String get restore => '还原';

  @override
  String get close => '关闭';

  @override
  String get collapse => '折叠';

  @override
  String get expand => '展开';

  @override
  String get save => '保存';

  @override
  String get cancel => '取消';

  @override
  String get confirm => '确认';

  @override
  String get welcome => '欢迎回来';

  @override
  String get welcomeMessage => '开始管理您的项目';

  @override
  String get quickStats => '快速统计';

  @override
  String get totalProjects => '项目总数';

  @override
  String get activeProjects => '进行中';

  @override
  String get completedProjects => '已完成';

  @override
  String get recentActivity => '最近活动';

  @override
  String get importProject => '导入项目';

  @override
  String get selectDirectory => '选择目录';

  @override
  String get search => '搜索';

  @override
  String get searchProjects => '搜索项目...';

  @override
  String get sortBy => '排序方式';

  @override
  String get filterBy => '筛选';

  @override
  String get all => '全部';

  @override
  String get webApp => 'Web应用';

  @override
  String get mobileApp => '移动应用';

  @override
  String get desktopApp => '桌面应用';

  @override
  String get backendApp => '后端应用';

  @override
  String get componentLibrary => '组件库';

  @override
  String get utilityLibrary => '工具库';

  @override
  String get frameworkLibrary => '框架库';

  @override
  String get nodeLibrary => 'Node库';

  @override
  String get cliTool => '命令行工具';

  @override
  String get monorepo => 'Monorepo';

  @override
  String get projectActions => '项目操作';

  @override
  String get startProject => '启动';

  @override
  String get buildProject => '构建';

  @override
  String get previewProject => '预览';

  @override
  String get deployProject => '部署';

  @override
  String get publishProject => '发布';

  @override
  String get testProject => '测试';

  @override
  String get sortByName => '按名称';

  @override
  String get sortByDate => '按日期';

  @override
  String get sortByType => '按类型';

  @override
  String get ascending => '升序';

  @override
  String get descending => '降序';

  @override
  String get noProjects => '暂无项目';

  @override
  String get importFirstProject => '点击上方按钮导入您的第一个项目';

  @override
  String get projectType => '项目类型';

  @override
  String get framework => '框架';

  @override
  String get lastModified => '最后修改';

  @override
  String get delete => '删除';

  @override
  String get openFolder => '打开文件夹';

  @override
  String get projectDetails => '项目详情';

  @override
  String get importProjectDialog => '导入项目';

  @override
  String get selectProjectDirectory => '选择项目目录';

  @override
  String get analyzingProject => '正在分析项目...';

  @override
  String get projectInfo => '项目信息';

  @override
  String get projectName => '项目名称';

  @override
  String get projectVersion => '版本号';

  @override
  String get projectDescription => '项目描述';

  @override
  String get noDescription => '无描述';

  @override
  String get confirmImport => '确认导入';

  @override
  String get reselect => '重新选择';

  @override
  String get analyzing => '分析中';

  @override
  String get unknown => '未知';

  @override
  String get vite => 'Vite';

  @override
  String get webpack => 'Webpack';

  @override
  String get parcel => 'Parcel';

  @override
  String get rollup => 'Rollup';

  @override
  String get svelte => 'Svelte';

  @override
  String get solidjs => 'Solid.js';

  @override
  String get preact => 'Preact';

  @override
  String get gatsby => 'Gatsby';

  @override
  String get remix => 'Remix';

  @override
  String get astro => 'Astro';

  @override
  String get qwik => 'Qwik';

  @override
  String get react_native => 'React Native';

  @override
  String get ionic => 'Ionic';

  @override
  String get capacitor => 'Capacitor';

  @override
  String get cordova => 'Cordova';

  @override
  String get todayLabel => '今天';

  @override
  String get yesterdayLabel => '昨天';

  @override
  String xDaysAgo(int count) {
    return '$count天前';
  }

  @override
  String xWeeksAgo(int count) {
    return '$count周前';
  }

  @override
  String projectImportedSuccess(String name) {
    return '项目\'$name\'导入成功';
  }

  @override
  String confirmRemoveFromList(String name) {
    return '确认从列表中移除项目\'$name\'？';
  }

  @override
  String projectRemoved(String name) {
    return '项目\'$name\'已移除';
  }

  @override
  String get failedToAnalyzeProjectDirectory => '分析项目目录失败';

  @override
  String errorWithMessage(String message) {
    return '错误：$message';
  }

  @override
  String get back => '返回';

  @override
  String get projectPath => '项目路径';

  @override
  String get timeInfo => '时间信息';

  @override
  String get addedAt => '添加时间';

  @override
  String get tags => '标签';

  @override
  String get failedToOpenFolder => '无法打开文件夹';

  @override
  String get pageTransition => '页面切换动画';

  @override
  String get disabled => '禁用';

  @override
  String get fadeTransition => '淡入淡出';

  @override
  String get slideLeftTransition => '向左滑动';

  @override
  String get slideRightTransition => '向右滑动';

  @override
  String get slideUpTransition => '向上滑动';

  @override
  String get slideDownTransition => '向下滑动';

  @override
  String get scaleTransition => '缩放';

  @override
  String get rotationTransition => '旋转';

  @override
  String get nodeManager => 'Node 版本管理';

  @override
  String get nodeManagerDescription => '管理 Node.js 版本和版本管理工具';

  @override
  String get versionManagers => '版本管理器';

  @override
  String get refresh => '刷新';

  @override
  String get installedVersions => '已安装版本';

  @override
  String get noVersionsInstalled => '暂无已安装的 Node.js 版本';

  @override
  String get use => '使用';

  @override
  String get current => '当前';

  @override
  String get installNewVersion => '安装新版本';

  @override
  String get enterVersionNumber => '输入版本号，如 18.17.0';

  @override
  String get install => '安装';

  @override
  String get versionFormatHint => '示例：18.17.0, 20.x, lts';

  @override
  String get uninstall => '卸载';

  @override
  String get update => '更新';

  @override
  String get viewWebsite => '查看官网';

  @override
  String get installCommand => '安装命令';

  @override
  String get confirmUninstall => '确认卸载';

  @override
  String confirmUninstallMessage(String version) {
    return '确定要卸载 Node.js $version 吗？';
  }

  @override
  String confirmInstallManager(String name) {
    return '安装 $name';
  }

  @override
  String confirmInstallManagerMessage(String name) {
    return '确定要安装 $name 吗？';
  }

  @override
  String confirmUpdateManager(String name) {
    return '更新 $name';
  }

  @override
  String confirmUpdateManagerMessage(String name) {
    return '确定要将 $name 更新到最新版本吗？';
  }

  @override
  String switchedToManager(String name) {
    return '已切换到 $name';
  }

  @override
  String get switchFailed => '切换失败';

  @override
  String switchedToNodeVersion(String version) {
    return '已切换到 Node.js $version';
  }

  @override
  String nodeVersionInstalled(String version) {
    return 'Node.js $version 安装成功';
  }

  @override
  String get installFailed => '安装失败';

  @override
  String nodeVersionUninstalled(String version) {
    return 'Node.js $version 卸载成功';
  }

  @override
  String get uninstallFailed => '卸载失败';

  @override
  String managerInstalled(String name) {
    return '$name 安装成功';
  }

  @override
  String managerUpdated(String name) {
    return '$name 更新成功';
  }

  @override
  String get updateFailed => '更新失败';

  @override
  String get uninstallComplete => '卸载完成';

  @override
  String get uninstallFailedTitle => '卸载失败';

  @override
  String preparingUninstall(String name) {
    return '准备卸载 $name...';
  }

  @override
  String uninstalling(String name) {
    return '正在卸载 $name';
  }

  @override
  String get failedToOpenFolderWithError => '打开文件夹时发生错误';

  @override
  String get currentEnvironmentVersion => '当前环境版本';

  @override
  String get notInstalled => '未安装';

  @override
  String get installed => '已安装';

  @override
  String get active => '当前使用';

  @override
  String get uninstallWarning => '卸载后，使用此工具安装的所有 Node.js 版本也会被删除，此操作不可撤除。';

  @override
  String get uninstallLog => '卸载日志';

  @override
  String get systemInfoOverview => '系统信息总览';

  @override
  String get realtimeMonitoring => '实时监控你的开发环境和系统状态';

  @override
  String get online => '在线';

  @override
  String get offline => '离线';

  @override
  String get projectStats => '移动目统计窗口';

  @override
  String get runningProjects => '运行中项目';

  @override
  String get developmentEnvironment => '开发环境';

  @override
  String get versionManager => '版本管理器';

  @override
  String get systemInformation => '系统信息统计窗口';

  @override
  String get cpu => 'CPU';

  @override
  String get battery => '电池';

  @override
  String get storage => '存储';

  @override
  String get network => '网络';

  @override
  String get installedSoftware => '已安装软件';

  @override
  String get codeEditors => '代码编辑器';

  @override
  String get browsers => '浏览器';

  @override
  String get noEditorsDetected => '未检测到代码编辑器';

  @override
  String get noBrowsersDetected => '未检测到浏览器';

  @override
  String get debugTools => '调试工具';

  @override
  String get storageDebugInfo => '存储调试信息';

  @override
  String get view => '查看';

  @override
  String get clearCorruptedData => '清理损坏数据';

  @override
  String get clear => '清理';

  @override
  String get confirmClear => '确认清理';

  @override
  String get clearDataWarning =>
      '本操作将清理所有 SharedPreferences 中的缓存数据，并重置所有设置为默认值。\n\n项目数据不会受影响（保存在文件中）。\n\n是否继续？';

  @override
  String get clearingData => '正在清理数据...';

  @override
  String get clearSuccess => '清理成功，设置已重置为默认值。';

  @override
  String get clearFailed => '清理失败';

  @override
  String notInstalledMessage(String name) {
    return '$name 未安装';
  }

  @override
  String get installFirstMessage => '请先安装此工具后再管理其版本。';

  @override
  String get toolInfo => '工具信息';

  @override
  String get name => '名称';

  @override
  String get version => '版本';

  @override
  String get installPath => '安装路径';

  @override
  String get description => '描述';

  @override
  String get visitWebsite => '访问官网';

  @override
  String switchedToNode(String version) {
    return '已切换到 Node.js $version';
  }

  @override
  String get switchToNodeFailed => '切换失败';

  @override
  String nodeInstalled(String version) {
    return 'Node.js $version 安装成功';
  }

  @override
  String get nodeInstallFailed => '安装失败';

  @override
  String nodeUninstalled(String version) {
    return 'Node.js $version 卸载成功';
  }

  @override
  String get nodeUninstallFailed => '卸载失败';

  @override
  String confirmUninstallNode(String version) {
    return '确定要卸载 Node.js $version 吗？';
  }

  @override
  String get developmentEnv => '开发环境';

  @override
  String get stagingEnv => '测试环境';

  @override
  String get productionEnv => '生产环境';

  @override
  String get building => '构建中...';

  @override
  String get startBuild => '开始构建';

  @override
  String get retry => '重试';

  @override
  String get stopping => '停止中...';

  @override
  String get starting => '启动中...';

  @override
  String get previewing => '预览中...';

  @override
  String get processing => '处理中...';

  @override
  String get stopService => '停止服务';

  @override
  String get startDevServer => '启动开发服务器';

  @override
  String get startPreviewServer => '启动预览服务器';

  @override
  String get start => '开始';

  @override
  String get serviceUrl => '服务地址';

  @override
  String get details => '详情';

  @override
  String get inUse => '使用';
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class AppLocalizationsZhHant extends AppLocalizationsZh {
  AppLocalizationsZhHant() : super('zh_Hant');

  @override
  String get appTitle => '後臺管理系統';

  @override
  String get home => '首頁';

  @override
  String get dashboard => '儀表盤';

  @override
  String get projects => '項目管理';

  @override
  String get projectList => '項目列表';

  @override
  String get createProject => '創建項目';

  @override
  String get settings => '設置';

  @override
  String get theme => '主題';

  @override
  String get language => '語言';

  @override
  String get size => '尺寸';

  @override
  String get themeMode => '主題模式';

  @override
  String get lightMode => '亮色模式';

  @override
  String get darkMode => '暗黑模式';

  @override
  String get themeColor => '主題色';

  @override
  String get presetColors => '預設顏色';

  @override
  String get customColor => '自定義顏色';

  @override
  String get globalSize => '全局尺寸';

  @override
  String get compact => '緊湊';

  @override
  String get standard => '標準';

  @override
  String get comfortable => '寬鬆';

  @override
  String get chinese => '简体中文';

  @override
  String get english => 'English';

  @override
  String get traditionalChinese => '繁體中文';

  @override
  String get minimize => '最小化';

  @override
  String get maximize => '最大化';

  @override
  String get restore => '還原';

  @override
  String get close => '關閉';

  @override
  String get collapse => '折疊';

  @override
  String get expand => '展開';

  @override
  String get save => '保存';

  @override
  String get cancel => '取消';

  @override
  String get confirm => '確認';

  @override
  String get welcome => '歡迎回來';

  @override
  String get welcomeMessage => '開始管理您的項目';

  @override
  String get quickStats => '快速統計';

  @override
  String get totalProjects => '項目總數';

  @override
  String get activeProjects => '進行中';

  @override
  String get completedProjects => '已完成';

  @override
  String get recentActivity => '最近活動';

  @override
  String get importProject => '導入項目';

  @override
  String get selectDirectory => '選擇目錄';

  @override
  String get search => '搜索';

  @override
  String get searchProjects => '搜索項目...';

  @override
  String get sortBy => '排序方式';

  @override
  String get filterBy => '篩選';

  @override
  String get all => '全部';

  @override
  String get webApp => 'Web應用';

  @override
  String get mobileApp => '移動應用';

  @override
  String get desktopApp => '桌面應用';

  @override
  String get backendApp => '後端應用';

  @override
  String get componentLibrary => '組件庫';

  @override
  String get utilityLibrary => '工具庫';

  @override
  String get frameworkLibrary => '框架庫';

  @override
  String get nodeLibrary => 'Node庫';

  @override
  String get cliTool => '命令行工具';

  @override
  String get monorepo => 'Monorepo';

  @override
  String get projectActions => '專案操作';

  @override
  String get startProject => '啟動';

  @override
  String get buildProject => '構建';

  @override
  String get previewProject => '預覽';

  @override
  String get deployProject => '部署';

  @override
  String get publishProject => '發布';

  @override
  String get testProject => '測試';

  @override
  String get sortByName => '按名稱';

  @override
  String get sortByDate => '按日期';

  @override
  String get sortByType => '按類型';

  @override
  String get ascending => '升序';

  @override
  String get descending => '降序';

  @override
  String get noProjects => '暫無項目';

  @override
  String get importFirstProject => '點擊上方按鈕導入您的第一個項目';

  @override
  String get projectType => '項目類型';

  @override
  String get framework => '框架';

  @override
  String get lastModified => '最後修改';

  @override
  String get delete => '刪除';

  @override
  String get openFolder => '打開文件夾';

  @override
  String get projectDetails => '項目詳情';

  @override
  String get importProjectDialog => '導入項目';

  @override
  String get selectProjectDirectory => '選擇項目目錄';

  @override
  String get analyzingProject => '正在分析項目...';

  @override
  String get projectInfo => '項目信息';

  @override
  String get projectName => '項目名稱';

  @override
  String get projectVersion => '版本號';

  @override
  String get projectDescription => '項目描述';

  @override
  String get noDescription => '無描述';

  @override
  String get confirmImport => '確認導入';

  @override
  String get reselect => '重新選擇';

  @override
  String get analyzing => '分析中';

  @override
  String get unknown => '未知';

  @override
  String get vite => 'Vite';

  @override
  String get webpack => 'Webpack';

  @override
  String get parcel => 'Parcel';

  @override
  String get rollup => 'Rollup';

  @override
  String get svelte => 'Svelte';

  @override
  String get solidjs => 'Solid.js';

  @override
  String get preact => 'Preact';

  @override
  String get gatsby => 'Gatsby';

  @override
  String get remix => 'Remix';

  @override
  String get astro => 'Astro';

  @override
  String get qwik => 'Qwik';

  @override
  String get react_native => 'React Native';

  @override
  String get ionic => 'Ionic';

  @override
  String get capacitor => 'Capacitor';

  @override
  String get cordova => 'Cordova';

  @override
  String get todayLabel => '今天';

  @override
  String get yesterdayLabel => '昨天';

  @override
  String xDaysAgo(int count) {
    return '$count天前';
  }

  @override
  String xWeeksAgo(int count) {
    return '$count週前';
  }

  @override
  String projectImportedSuccess(String name) {
    return '項目\'$name\'導入成功';
  }

  @override
  String confirmRemoveFromList(String name) {
    return '確認從列表中移除項目\'$name\'？';
  }

  @override
  String projectRemoved(String name) {
    return '項目\'$name\'已移除';
  }

  @override
  String get failedToAnalyzeProjectDirectory => '分析項目目錄失敗';

  @override
  String errorWithMessage(String message) {
    return '錯誤：$message';
  }

  @override
  String get back => '返回';

  @override
  String get projectPath => '項目路徑';

  @override
  String get timeInfo => '時間信息';

  @override
  String get addedAt => '添加時間';

  @override
  String get tags => '標籤';

  @override
  String get failedToOpenFolder => '無法打開文件夾';

  @override
  String get pageTransition => '頁面切換動畫';

  @override
  String get disabled => '禁用';

  @override
  String get fadeTransition => '淡入淡出';

  @override
  String get slideLeftTransition => '向左滑動';

  @override
  String get slideRightTransition => '向右滑動';

  @override
  String get slideUpTransition => '向上滑動';

  @override
  String get slideDownTransition => '向下滑動';

  @override
  String get scaleTransition => '縮放';

  @override
  String get rotationTransition => '旋轉';

  @override
  String get nodeManager => 'Node 版本管理';

  @override
  String get nodeManagerDescription => '管理 Node.js 版本和版本管理工具';

  @override
  String get versionManagers => '版本管理器';

  @override
  String get refresh => '刷新';

  @override
  String get installedVersions => '已安裝版本';

  @override
  String get noVersionsInstalled => '暫無已安裝的 Node.js 版本';

  @override
  String get use => '使用';

  @override
  String get current => '當前';

  @override
  String get installNewVersion => '安裝新版本';

  @override
  String get enterVersionNumber => '輸入版本號，如 18.17.0';

  @override
  String get install => '安裝';

  @override
  String get versionFormatHint => '示例：18.17.0, 20.x, lts';

  @override
  String get uninstall => '卸載';

  @override
  String get update => '更新';

  @override
  String get viewWebsite => '查看官網';

  @override
  String get installCommand => '安裝命令';

  @override
  String get confirmUninstall => '確認卸載';

  @override
  String confirmUninstallMessage(String version) {
    return '確定要卸載 Node.js $version 嗎？';
  }

  @override
  String confirmInstallManager(String name) {
    return '安裝 $name';
  }

  @override
  String confirmInstallManagerMessage(String name) {
    return '確定要安裝 $name 嗎？';
  }

  @override
  String confirmUpdateManager(String name) {
    return '更新 $name';
  }

  @override
  String confirmUpdateManagerMessage(String name) {
    return '確定要將 $name 更新到最新版本嗎？';
  }

  @override
  String switchedToManager(String name) {
    return '已切換到 $name';
  }

  @override
  String get switchFailed => '切換失敗';

  @override
  String switchedToNodeVersion(String version) {
    return '已切換到 Node.js $version';
  }

  @override
  String nodeVersionInstalled(String version) {
    return 'Node.js $version 安裝成功';
  }

  @override
  String get installFailed => '安裝失敗';

  @override
  String nodeVersionUninstalled(String version) {
    return 'Node.js $version 卸載成功';
  }

  @override
  String get uninstallFailed => '卸載失敗';

  @override
  String managerInstalled(String name) {
    return '$name 安裝成功';
  }

  @override
  String managerUpdated(String name) {
    return '$name 更新成功';
  }

  @override
  String get updateFailed => '更新失敗';

  @override
  String get uninstallComplete => '卸載完成';

  @override
  String get uninstallFailedTitle => '卸載失敗';

  @override
  String preparingUninstall(String name) {
    return '準備卸載 $name...';
  }

  @override
  String uninstalling(String name) {
    return '正在卸載 $name';
  }

  @override
  String get failedToOpenFolderWithError => '打開文件夾時發生錯誤';

  @override
  String get currentEnvironmentVersion => '當前環境版本';

  @override
  String get notInstalled => '未安裝';

  @override
  String get installed => '已安裝';

  @override
  String get active => '當前使用';

  @override
  String get uninstallWarning => '卸載後，使用此工具安裝的所有 Node.js 版本也會被刪除，此操作不可撤銷。';

  @override
  String get uninstallLog => '卸載日誌';

  @override
  String get systemInfoOverview => '系統信息總覽';

  @override
  String get realtimeMonitoring => '實時監控你的開發環境和系統狀態';

  @override
  String get online => '在線';

  @override
  String get offline => '離線';

  @override
  String get projectStats => '項目統計';

  @override
  String get runningProjects => '運行中項目';

  @override
  String get developmentEnvironment => '開發環境';

  @override
  String get versionManager => '版本管理器';

  @override
  String get systemInformation => '系統信息';

  @override
  String get cpu => 'CPU';

  @override
  String get battery => '電池';

  @override
  String get storage => '存储';

  @override
  String get network => '網絡';

  @override
  String get installedSoftware => '已安裝軟件';

  @override
  String get codeEditors => '代碼編輯器';

  @override
  String get browsers => '瀏覽器';

  @override
  String get noEditorsDetected => '未檢測到代碼編輯器';

  @override
  String get noBrowsersDetected => '未檢測到瀏覽器';

  @override
  String get debugTools => '調試工具';

  @override
  String get storageDebugInfo => '存儲調試信息';

  @override
  String get view => '查看';

  @override
  String get clearCorruptedData => '清理損壞數據';

  @override
  String get clear => '清理';

  @override
  String get confirmClear => '確認清理';

  @override
  String get clearDataWarning =>
      '本操作將清理所有 SharedPreferences 中的緩存數據，並重置所有設置為默認值。\n\n項目數據不會受影響（保存在文件中）。\n\n是否繼續？';

  @override
  String get clearingData => '正在清理數據...';

  @override
  String get clearSuccess => '清理成功，設置已重置為默認值。';

  @override
  String get clearFailed => '清理失敗';

  @override
  String notInstalledMessage(String name) {
    return '$name 未安裝';
  }

  @override
  String get installFirstMessage => '請先安裝此工具後再管理其版本。';

  @override
  String get toolInfo => '工具信息';

  @override
  String get name => '名稱';

  @override
  String get version => '版本';

  @override
  String get installPath => '安裝路徑';

  @override
  String get description => '描述';

  @override
  String get visitWebsite => '訪問官網';

  @override
  String switchedToNode(String version) {
    return '已切換到 Node.js $version';
  }

  @override
  String get switchToNodeFailed => '切換失敗';

  @override
  String nodeInstalled(String version) {
    return 'Node.js $version 安裝成功';
  }

  @override
  String get nodeInstallFailed => '安裝失敗';

  @override
  String nodeUninstalled(String version) {
    return 'Node.js $version 卸載成功';
  }

  @override
  String get nodeUninstallFailed => '卸載失敗';

  @override
  String confirmUninstallNode(String version) {
    return '確定要卸載 Node.js $version 嗎？';
  }

  @override
  String get developmentEnv => '開發環境';

  @override
  String get stagingEnv => '測試環境';

  @override
  String get productionEnv => '生產環境';

  @override
  String get building => '構建中...';

  @override
  String get startBuild => '開始構建';

  @override
  String get retry => '重試';

  @override
  String get stopping => '停止中...';

  @override
  String get starting => '启动中...';

  @override
  String get previewing => '預覽中...';

  @override
  String get processing => '處理中...';

  @override
  String get stopService => '停止服務';

  @override
  String get startDevServer => '启动開發服務器';

  @override
  String get startPreviewServer => '启动預覽服務器';

  @override
  String get start => '開始';

  @override
  String get serviceUrl => '服務地址';

  @override
  String get details => '詳情';

  @override
  String get inUse => '使用';
}
