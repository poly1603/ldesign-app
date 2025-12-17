// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Flutter 工具箱';

  @override
  String get home => '首页';

  @override
  String get projects => '项目管理';

  @override
  String get nodeManagement => 'Node 管理';

  @override
  String get gitManagement => 'Git 管理';

  @override
  String get svgManagement => 'SVG 管理';

  @override
  String get fontManagement => '字体管理';

  @override
  String get settings => '设置';

  @override
  String get addProject => '添加项目';

  @override
  String get removeProject => '移除项目';

  @override
  String get projectName => '项目名称';

  @override
  String get projectPath => '路径';

  @override
  String get projectVersion => '版本';

  @override
  String get projectFramework => '框架';

  @override
  String get lastAccessed => '最后访问';

  @override
  String get dependencies => '依赖';

  @override
  String get devDependencies => '开发依赖';

  @override
  String get scripts => '脚本';

  @override
  String get nodeVersion => 'Node.js 版本';

  @override
  String get npmVersion => 'npm 版本';

  @override
  String get pnpmVersion => 'pnpm 版本';

  @override
  String get yarnVersion => 'yarn 版本';

  @override
  String get installPath => '安装路径';

  @override
  String get globalPackages => '全局包';

  @override
  String get notInstalled => '未安装';

  @override
  String installGuide(String tool) {
    return '请安装 $tool 以使用此功能';
  }

  @override
  String get gitVersion => 'Git 版本';

  @override
  String get gitUserName => '用户名';

  @override
  String get gitUserEmail => '用户邮箱';

  @override
  String get importAssets => '导入';

  @override
  String get search => '搜索';

  @override
  String get export => '导出';

  @override
  String get copyToClipboard => '复制到剪贴板';

  @override
  String get fileSize => '文件大小';

  @override
  String get importedAt => '导入时间';

  @override
  String get previewText => '预览文本';

  @override
  String get themeColor => '主题颜色';

  @override
  String get darkMode => '暗黑模式';

  @override
  String get followSystem => '跟随系统';

  @override
  String get language => '语言';

  @override
  String get general => '通用';

  @override
  String get appearance => '外观';

  @override
  String get resetSettings => '重置设置';

  @override
  String get resetConfirm => '确定要重置所有设置吗？';

  @override
  String get cancel => '取消';

  @override
  String get confirm => '确定';

  @override
  String get projectCount => '项目数';

  @override
  String get svgCount => 'SVG 文件';

  @override
  String get fontCount => '字体数';
}
