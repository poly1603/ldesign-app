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
  String get nodeLibrary => 'Node库';

  @override
  String get cliTool => '命令行工具';

  @override
  String get monorepo => 'Monorepo';

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
  String get nodeLibrary => 'Node庫';

  @override
  String get cliTool => '命令行工具';

  @override
  String get monorepo => 'Monorepo';

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
}
