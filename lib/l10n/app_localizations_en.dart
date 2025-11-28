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
  String get frameworkLibrary => 'Framework Library';

  @override
  String get nodeLibrary => 'Node Library';

  @override
  String get cliTool => 'CLI Tool';

  @override
  String get monorepo => 'Monorepo';

  @override
  String get projectActions => 'Project Actions';

  @override
  String get startProject => 'Start';

  @override
  String get buildProject => 'Build';

  @override
  String get previewProject => 'Preview';

  @override
  String get deployProject => 'Deploy';

  @override
  String get publishProject => 'Publish';

  @override
  String get testProject => 'Test';

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

  @override
  String get back => 'Back';

  @override
  String get projectPath => 'Project Path';

  @override
  String get timeInfo => 'Time Information';

  @override
  String get addedAt => 'Added At';

  @override
  String get tags => 'Tags';

  @override
  String get failedToOpenFolder => 'Failed to open folder';

  @override
  String get pageTransition => 'Page Transition Animation';

  @override
  String get disabled => 'Disabled';

  @override
  String get fadeTransition => 'Fade';

  @override
  String get slideLeftTransition => 'Slide Left';

  @override
  String get slideRightTransition => 'Slide Right';

  @override
  String get slideUpTransition => 'Slide Up';

  @override
  String get slideDownTransition => 'Slide Down';

  @override
  String get scaleTransition => 'Scale';

  @override
  String get rotationTransition => 'Rotation';

  @override
  String get nodeManager => 'Node Version Manager';

  @override
  String get nodeManagerDescription =>
      'Manage Node.js versions and version management tools';

  @override
  String get versionManagers => 'Version Managers';

  @override
  String get refresh => 'Refresh';

  @override
  String get installedVersions => 'Installed Versions';

  @override
  String get noVersionsInstalled => 'No Node.js versions installed yet';

  @override
  String get use => 'Use';

  @override
  String get current => 'Current';

  @override
  String get installNewVersion => 'Install New Version';

  @override
  String get enterVersionNumber => 'Enter version number, e.g., 18.17.0';

  @override
  String get install => 'Install';

  @override
  String get versionFormatHint => 'Examples: 18.17.0, 20.x, lts';

  @override
  String get uninstall => 'Uninstall';

  @override
  String get update => 'Update';

  @override
  String get viewWebsite => 'View Website';

  @override
  String get installCommand => 'Install Command';

  @override
  String get confirmUninstall => 'Confirm Uninstall';

  @override
  String confirmUninstallMessage(String version) {
    return 'Are you sure you want to uninstall Node.js $version?';
  }

  @override
  String confirmInstallManager(String name) {
    return 'Install $name';
  }

  @override
  String confirmInstallManagerMessage(String name) {
    return 'Are you sure you want to install $name?';
  }

  @override
  String confirmUpdateManager(String name) {
    return 'Update $name';
  }

  @override
  String confirmUpdateManagerMessage(String name) {
    return 'Are you sure you want to update $name to the latest version?';
  }

  @override
  String switchedToManager(String name) {
    return 'Switched to $name';
  }

  @override
  String get switchFailed => 'Switch failed';

  @override
  String switchedToNodeVersion(String version) {
    return 'Switched to Node.js $version';
  }

  @override
  String nodeVersionInstalled(String version) {
    return 'Node.js $version installed successfully';
  }

  @override
  String get installFailed => 'Installation failed';

  @override
  String nodeVersionUninstalled(String version) {
    return 'Node.js $version uninstalled successfully';
  }

  @override
  String get uninstallFailed => 'Uninstall failed';

  @override
  String managerInstalled(String name) {
    return '$name installed successfully';
  }

  @override
  String managerUpdated(String name) {
    return '$name updated successfully';
  }

  @override
  String get updateFailed => 'Update failed';

  @override
  String get uninstallComplete => 'Uninstall Complete';

  @override
  String get uninstallFailedTitle => 'Uninstall Failed';

  @override
  String preparingUninstall(String name) {
    return 'Preparing to uninstall $name...';
  }

  @override
  String uninstalling(String name) {
    return 'Uninstalling $name';
  }

  @override
  String get failedToOpenFolderWithError =>
      'Error occurred while opening folder';

  @override
  String get currentEnvironmentVersion => 'Current Environment Version';

  @override
  String get notInstalled => 'Not Installed';

  @override
  String get installed => 'Installed';

  @override
  String get active => 'Active';

  @override
  String get uninstallWarning =>
      'After uninstalling, all Node.js versions installed with this tool will also be removed. This action cannot be undone.';

  @override
  String get uninstallLog => 'Uninstall Log';

  @override
  String get systemInfoOverview => 'System Information Overview';

  @override
  String get realtimeMonitoring =>
      'Real-time monitoring of your development environment and system status';

  @override
  String get online => 'Online';

  @override
  String get offline => 'Offline';

  @override
  String get projectStats => 'Project Statistics';

  @override
  String get runningProjects => 'Running Projects';

  @override
  String get developmentEnvironment => 'Development Environment';

  @override
  String get versionManager => 'Version Manager';

  @override
  String get systemInformation => 'System Information';

  @override
  String get cpu => 'CPU';

  @override
  String get battery => 'Battery';

  @override
  String get storage => 'Storage';

  @override
  String get network => 'Network';

  @override
  String get installedSoftware => 'Installed Software';

  @override
  String get codeEditors => 'Code Editors';

  @override
  String get browsers => 'Browsers';

  @override
  String get noEditorsDetected => 'No code editors detected';

  @override
  String get noBrowsersDetected => 'No browsers detected';

  @override
  String get debugTools => 'Debug Tools';

  @override
  String get storageDebugInfo => 'Storage Debug Info';

  @override
  String get view => 'View';

  @override
  String get clearCorruptedData => 'Clear Corrupted Data';

  @override
  String get clear => 'Clear';

  @override
  String get confirmClear => 'Confirm Clear';

  @override
  String get clearDataWarning =>
      'This operation will clear all cached data in SharedPreferences and reset all settings to default values.\n\nProject data will not be affected (stored in files).\n\nContinue?';

  @override
  String get clearingData => 'Clearing data...';

  @override
  String get clearSuccess =>
      'Cleared successfully, settings have been reset to default values.';

  @override
  String get clearFailed => 'Clear failed';

  @override
  String notInstalledMessage(String name) {
    return '$name is not installed';
  }

  @override
  String get installFirstMessage =>
      'Please install this tool first before managing its versions.';

  @override
  String get toolInfo => 'Tool Information';

  @override
  String get name => 'Name';

  @override
  String get version => 'Version';

  @override
  String get installPath => 'Install Path';

  @override
  String get description => 'Description';

  @override
  String get visitWebsite => 'Visit Website';

  @override
  String switchedToNode(String version) {
    return 'Switched to Node.js $version';
  }

  @override
  String get switchToNodeFailed => 'Switch failed';

  @override
  String nodeInstalled(String version) {
    return 'Node.js $version installed successfully';
  }

  @override
  String get nodeInstallFailed => 'Installation failed';

  @override
  String nodeUninstalled(String version) {
    return 'Node.js $version uninstalled successfully';
  }

  @override
  String get nodeUninstallFailed => 'Uninstallation failed';

  @override
  String confirmUninstallNode(String version) {
    return 'Are you sure you want to uninstall Node.js $version?';
  }

  @override
  String get developmentEnv => 'Development';

  @override
  String get stagingEnv => 'Staging';

  @override
  String get productionEnv => 'Production';

  @override
  String get building => 'Building...';

  @override
  String get startBuild => 'Start Build';

  @override
  String get retry => 'Retry';

  @override
  String get stopping => 'Stopping...';

  @override
  String get starting => 'Starting...';

  @override
  String get previewing => 'Previewing...';

  @override
  String get processing => 'Processing...';

  @override
  String get stopService => 'Stop Service';

  @override
  String get startDevServer => 'Start Dev Server';

  @override
  String get startPreviewServer => 'Start Preview Server';

  @override
  String get start => 'Start';

  @override
  String get serviceUrl => 'Service URL';

  @override
  String get details => 'Details';

  @override
  String get inUse => 'In Use';

  @override
  String get manageDependencies => 'Manage Dependencies';

  @override
  String get dependencyManagement => 'Dependency Management';
}
