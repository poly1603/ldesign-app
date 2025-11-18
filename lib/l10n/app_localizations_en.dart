// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Admin System';

  @override
  String get home => 'Home';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get projects => 'Projects';

  @override
  String get projectList => 'Project List';

  @override
  String get createProject => 'Create Project';

  @override
  String get settings => 'Settings';

  @override
  String get theme => 'Theme';

  @override
  String get language => 'Language';

  @override
  String get size => 'Size';

  @override
  String get themeMode => 'Theme Mode';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get themeColor => 'Theme Color';

  @override
  String get presetColors => 'Preset Colors';

  @override
  String get customColor => 'Custom Color';

  @override
  String get globalSize => 'Global Size';

  @override
  String get compact => 'Compact';

  @override
  String get standard => 'Standard';

  @override
  String get comfortable => 'Comfortable';

  @override
  String get chinese => '简体中文';

  @override
  String get english => 'English';

  @override
  String get traditionalChinese => '繁體中文';

  @override
  String get minimize => 'Minimize';

  @override
  String get maximize => 'Maximize';

  @override
  String get restore => 'Restore';

  @override
  String get close => 'Close';

  @override
  String get collapse => 'Collapse';

  @override
  String get expand => 'Expand';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get welcome => 'Welcome Back';

  @override
  String get welcomeMessage => 'Start managing your projects';

  @override
  String get quickStats => 'Quick Stats';

  @override
  String get totalProjects => 'Total Projects';

  @override
  String get activeProjects => 'Active';

  @override
  String get completedProjects => 'Completed';

  @override
  String get recentActivity => 'Recent Activity';

  @override
  String get importProject => 'Import Project';

  @override
  String get selectDirectory => 'Select Directory';

  @override
  String get search => 'Search';

  @override
  String get searchProjects => 'Search projects...';

  @override
  String get sortBy => 'Sort By';

  @override
  String get filterBy => 'Filter';

  @override
  String get all => 'All';

  @override
  String get webApp => 'Web App';

  @override
  String get mobileApp => 'Mobile App';

  @override
  String get desktopApp => 'Desktop App';

  @override
  String get backendApp => 'Backend';

  @override
  String get componentLibrary => 'Component Library';

  @override
  String get utilityLibrary => 'Utility Library';

  @override
  String get nodeLibrary => 'Node Library';

  @override
  String get cliTool => 'CLI Tool';

  @override
  String get monorepo => 'Monorepo';

  @override
  String get sortByName => 'By Name';

  @override
  String get sortByDate => 'By Date';

  @override
  String get sortByType => 'By Type';

  @override
  String get ascending => 'Ascending';

  @override
  String get descending => 'Descending';

  @override
  String get noProjects => 'No Projects';

  @override
  String get importFirstProject =>
      'Click the button above to import your first project';

  @override
  String get projectType => 'Type';

  @override
  String get framework => 'Framework';

  @override
  String get lastModified => 'Last Modified';

  @override
  String get delete => 'Delete';

  @override
  String get openFolder => 'Open Folder';

  @override
  String get projectDetails => 'Project Details';

  @override
  String get importProjectDialog => 'Import Project';

  @override
  String get selectProjectDirectory => 'Select Project Directory';

  @override
  String get analyzingProject => 'Analyzing project...';

  @override
  String get projectInfo => 'Project Information';

  @override
  String get projectName => 'Project Name';

  @override
  String get projectVersion => 'Version';

  @override
  String get projectDescription => 'Description';

  @override
  String get noDescription => 'No description';

  @override
  String get confirmImport => 'Confirm Import';

  @override
  String get reselect => 'Reselect';

  @override
  String get analyzing => 'Analyzing';

  @override
  String get unknown => 'Unknown';

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
  String get todayLabel => 'Today';

  @override
  String get yesterdayLabel => 'Yesterday';

  @override
  String xDaysAgo(int count) {
    return '$count days ago';
  }

  @override
  String xWeeksAgo(int count) {
    return '$count weeks ago';
  }

  @override
  String projectImportedSuccess(String name) {
    return 'Project \'$name\' imported successfully';
  }

  @override
  String confirmRemoveFromList(String name) {
    return 'Remove project \'$name\' from the list?';
  }

  @override
  String projectRemoved(String name) {
    return 'Project \'$name\' removed';
  }

  @override
  String get failedToAnalyzeProjectDirectory =>
      'Failed to analyze project directory';

  @override
  String errorWithMessage(String message) {
    return 'Error: $message';
  }
}
