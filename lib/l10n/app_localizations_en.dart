// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Flutter Toolbox';

  @override
  String get home => 'Home';

  @override
  String get projects => 'Projects';

  @override
  String get nodeManagement => 'Node';

  @override
  String get gitManagement => 'Git';

  @override
  String get svgManagement => 'SVG';

  @override
  String get fontManagement => 'Fonts';

  @override
  String get settings => 'Settings';

  @override
  String get addProject => 'Add Project';

  @override
  String get removeProject => 'Remove Project';

  @override
  String get projectName => 'Project Name';

  @override
  String get projectPath => 'Path';

  @override
  String get projectVersion => 'Version';

  @override
  String get projectFramework => 'Framework';

  @override
  String get lastAccessed => 'Last Accessed';

  @override
  String get dependencies => 'Dependencies';

  @override
  String get devDependencies => 'Dev Dependencies';

  @override
  String get scripts => 'Scripts';

  @override
  String get nodeVersion => 'Node.js Version';

  @override
  String get npmVersion => 'npm Version';

  @override
  String get pnpmVersion => 'pnpm Version';

  @override
  String get yarnVersion => 'yarn Version';

  @override
  String get installPath => 'Install Path';

  @override
  String get globalPackages => 'Global Packages';

  @override
  String get notInstalled => 'Not Installed';

  @override
  String installGuide(String tool) {
    return 'Please install $tool to use this feature';
  }

  @override
  String get gitVersion => 'Git Version';

  @override
  String get gitUserName => 'User Name';

  @override
  String get gitUserEmail => 'User Email';

  @override
  String get importAssets => 'Import';

  @override
  String get search => 'Search';

  @override
  String get export => 'Export';

  @override
  String get copyToClipboard => 'Copy to Clipboard';

  @override
  String get fileSize => 'File Size';

  @override
  String get importedAt => 'Imported At';

  @override
  String get previewText => 'Preview Text';

  @override
  String get themeColor => 'Theme Color';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get followSystem => 'Follow System';

  @override
  String get language => 'Language';

  @override
  String get general => 'General';

  @override
  String get appearance => 'Appearance';

  @override
  String get resetSettings => 'Reset Settings';

  @override
  String get resetConfirm => 'Are you sure you want to reset all settings?';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get projectCount => 'Projects';

  @override
  String get svgCount => 'SVG Files';

  @override
  String get fontCount => 'Fonts';
}
