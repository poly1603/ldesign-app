import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Admin System'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @projects.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get projects;

  /// No description provided for @projectList.
  ///
  /// In en, this message translates to:
  /// **'Project List'**
  String get projectList;

  /// No description provided for @createProject.
  ///
  /// In en, this message translates to:
  /// **'Create Project'**
  String get createProject;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @size.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get size;

  /// No description provided for @themeMode.
  ///
  /// In en, this message translates to:
  /// **'Theme Mode'**
  String get themeMode;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @themeColor.
  ///
  /// In en, this message translates to:
  /// **'Theme Color'**
  String get themeColor;

  /// No description provided for @presetColors.
  ///
  /// In en, this message translates to:
  /// **'Preset Colors'**
  String get presetColors;

  /// No description provided for @customColor.
  ///
  /// In en, this message translates to:
  /// **'Custom Color'**
  String get customColor;

  /// No description provided for @globalSize.
  ///
  /// In en, this message translates to:
  /// **'Global Size'**
  String get globalSize;

  /// No description provided for @compact.
  ///
  /// In en, this message translates to:
  /// **'Compact'**
  String get compact;

  /// No description provided for @standard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get standard;

  /// No description provided for @comfortable.
  ///
  /// In en, this message translates to:
  /// **'Comfortable'**
  String get comfortable;

  /// No description provided for @chinese.
  ///
  /// In en, this message translates to:
  /// **'简体中文'**
  String get chinese;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @traditionalChinese.
  ///
  /// In en, this message translates to:
  /// **'繁體中文'**
  String get traditionalChinese;

  /// No description provided for @minimize.
  ///
  /// In en, this message translates to:
  /// **'Minimize'**
  String get minimize;

  /// No description provided for @maximize.
  ///
  /// In en, this message translates to:
  /// **'Maximize'**
  String get maximize;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @collapse.
  ///
  /// In en, this message translates to:
  /// **'Collapse'**
  String get collapse;

  /// No description provided for @expand.
  ///
  /// In en, this message translates to:
  /// **'Expand'**
  String get expand;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcome;

  /// No description provided for @welcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Start managing your projects'**
  String get welcomeMessage;

  /// No description provided for @quickStats.
  ///
  /// In en, this message translates to:
  /// **'Quick Stats'**
  String get quickStats;

  /// No description provided for @totalProjects.
  ///
  /// In en, this message translates to:
  /// **'Total Projects'**
  String get totalProjects;

  /// No description provided for @activeProjects.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activeProjects;

  /// No description provided for @completedProjects.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completedProjects;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// No description provided for @importProject.
  ///
  /// In en, this message translates to:
  /// **'Import Project'**
  String get importProject;

  /// No description provided for @selectDirectory.
  ///
  /// In en, this message translates to:
  /// **'Select Directory'**
  String get selectDirectory;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchProjects.
  ///
  /// In en, this message translates to:
  /// **'Search projects...'**
  String get searchProjects;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort By'**
  String get sortBy;

  /// No description provided for @filterBy.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filterBy;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @webApp.
  ///
  /// In en, this message translates to:
  /// **'Web App'**
  String get webApp;

  /// No description provided for @mobileApp.
  ///
  /// In en, this message translates to:
  /// **'Mobile App'**
  String get mobileApp;

  /// No description provided for @desktopApp.
  ///
  /// In en, this message translates to:
  /// **'Desktop App'**
  String get desktopApp;

  /// No description provided for @backendApp.
  ///
  /// In en, this message translates to:
  /// **'Backend'**
  String get backendApp;

  /// No description provided for @componentLibrary.
  ///
  /// In en, this message translates to:
  /// **'Component Library'**
  String get componentLibrary;

  /// No description provided for @utilityLibrary.
  ///
  /// In en, this message translates to:
  /// **'Utility Library'**
  String get utilityLibrary;

  /// No description provided for @frameworkLibrary.
  ///
  /// In en, this message translates to:
  /// **'Framework Library'**
  String get frameworkLibrary;

  /// No description provided for @nodeLibrary.
  ///
  /// In en, this message translates to:
  /// **'Node Library'**
  String get nodeLibrary;

  /// No description provided for @cliTool.
  ///
  /// In en, this message translates to:
  /// **'CLI Tool'**
  String get cliTool;

  /// No description provided for @monorepo.
  ///
  /// In en, this message translates to:
  /// **'Monorepo'**
  String get monorepo;

  /// No description provided for @projectActions.
  ///
  /// In en, this message translates to:
  /// **'Project Actions'**
  String get projectActions;

  /// No description provided for @startProject.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startProject;

  /// No description provided for @buildProject.
  ///
  /// In en, this message translates to:
  /// **'Build'**
  String get buildProject;

  /// No description provided for @previewProject.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get previewProject;

  /// No description provided for @deployProject.
  ///
  /// In en, this message translates to:
  /// **'Deploy'**
  String get deployProject;

  /// No description provided for @publishProject.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get publishProject;

  /// No description provided for @testProject.
  ///
  /// In en, this message translates to:
  /// **'Test'**
  String get testProject;

  /// No description provided for @sortByName.
  ///
  /// In en, this message translates to:
  /// **'By Name'**
  String get sortByName;

  /// No description provided for @sortByDate.
  ///
  /// In en, this message translates to:
  /// **'By Date'**
  String get sortByDate;

  /// No description provided for @sortByType.
  ///
  /// In en, this message translates to:
  /// **'By Type'**
  String get sortByType;

  /// No description provided for @ascending.
  ///
  /// In en, this message translates to:
  /// **'Ascending'**
  String get ascending;

  /// No description provided for @descending.
  ///
  /// In en, this message translates to:
  /// **'Descending'**
  String get descending;

  /// No description provided for @noProjects.
  ///
  /// In en, this message translates to:
  /// **'No Projects'**
  String get noProjects;

  /// No description provided for @importFirstProject.
  ///
  /// In en, this message translates to:
  /// **'Click the button above to import your first project'**
  String get importFirstProject;

  /// No description provided for @projectType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get projectType;

  /// No description provided for @framework.
  ///
  /// In en, this message translates to:
  /// **'Framework'**
  String get framework;

  /// No description provided for @lastModified.
  ///
  /// In en, this message translates to:
  /// **'Last Modified'**
  String get lastModified;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @openFolder.
  ///
  /// In en, this message translates to:
  /// **'Open Folder'**
  String get openFolder;

  /// No description provided for @projectDetails.
  ///
  /// In en, this message translates to:
  /// **'Project Details'**
  String get projectDetails;

  /// No description provided for @importProjectDialog.
  ///
  /// In en, this message translates to:
  /// **'Import Project'**
  String get importProjectDialog;

  /// No description provided for @selectProjectDirectory.
  ///
  /// In en, this message translates to:
  /// **'Select Project Directory'**
  String get selectProjectDirectory;

  /// No description provided for @analyzingProject.
  ///
  /// In en, this message translates to:
  /// **'Analyzing project...'**
  String get analyzingProject;

  /// No description provided for @projectInfo.
  ///
  /// In en, this message translates to:
  /// **'Project Information'**
  String get projectInfo;

  /// No description provided for @projectName.
  ///
  /// In en, this message translates to:
  /// **'Project Name'**
  String get projectName;

  /// No description provided for @projectVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get projectVersion;

  /// No description provided for @projectDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get projectDescription;

  /// No description provided for @noDescription.
  ///
  /// In en, this message translates to:
  /// **'No description'**
  String get noDescription;

  /// No description provided for @confirmImport.
  ///
  /// In en, this message translates to:
  /// **'Confirm Import'**
  String get confirmImport;

  /// No description provided for @reselect.
  ///
  /// In en, this message translates to:
  /// **'Reselect'**
  String get reselect;

  /// No description provided for @analyzing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing'**
  String get analyzing;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @vite.
  ///
  /// In en, this message translates to:
  /// **'Vite'**
  String get vite;

  /// No description provided for @webpack.
  ///
  /// In en, this message translates to:
  /// **'Webpack'**
  String get webpack;

  /// No description provided for @parcel.
  ///
  /// In en, this message translates to:
  /// **'Parcel'**
  String get parcel;

  /// No description provided for @rollup.
  ///
  /// In en, this message translates to:
  /// **'Rollup'**
  String get rollup;

  /// No description provided for @svelte.
  ///
  /// In en, this message translates to:
  /// **'Svelte'**
  String get svelte;

  /// No description provided for @solidjs.
  ///
  /// In en, this message translates to:
  /// **'Solid.js'**
  String get solidjs;

  /// No description provided for @preact.
  ///
  /// In en, this message translates to:
  /// **'Preact'**
  String get preact;

  /// No description provided for @gatsby.
  ///
  /// In en, this message translates to:
  /// **'Gatsby'**
  String get gatsby;

  /// No description provided for @remix.
  ///
  /// In en, this message translates to:
  /// **'Remix'**
  String get remix;

  /// No description provided for @astro.
  ///
  /// In en, this message translates to:
  /// **'Astro'**
  String get astro;

  /// No description provided for @qwik.
  ///
  /// In en, this message translates to:
  /// **'Qwik'**
  String get qwik;

  /// No description provided for @react_native.
  ///
  /// In en, this message translates to:
  /// **'React Native'**
  String get react_native;

  /// No description provided for @ionic.
  ///
  /// In en, this message translates to:
  /// **'Ionic'**
  String get ionic;

  /// No description provided for @capacitor.
  ///
  /// In en, this message translates to:
  /// **'Capacitor'**
  String get capacitor;

  /// No description provided for @cordova.
  ///
  /// In en, this message translates to:
  /// **'Cordova'**
  String get cordova;

  /// No description provided for @todayLabel.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayLabel;

  /// No description provided for @yesterdayLabel.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterdayLabel;

  /// No description provided for @xDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String xDaysAgo(int count);

  /// No description provided for @xWeeksAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} weeks ago'**
  String xWeeksAgo(int count);

  /// No description provided for @projectImportedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Project \'{name}\' imported successfully'**
  String projectImportedSuccess(String name);

  /// No description provided for @confirmRemoveFromList.
  ///
  /// In en, this message translates to:
  /// **'Remove project \'{name}\' from the list?'**
  String confirmRemoveFromList(String name);

  /// No description provided for @projectRemoved.
  ///
  /// In en, this message translates to:
  /// **'Project \'{name}\' removed'**
  String projectRemoved(String name);

  /// No description provided for @failedToAnalyzeProjectDirectory.
  ///
  /// In en, this message translates to:
  /// **'Failed to analyze project directory'**
  String get failedToAnalyzeProjectDirectory;

  /// No description provided for @errorWithMessage.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String errorWithMessage(String message);

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @projectPath.
  ///
  /// In en, this message translates to:
  /// **'Project Path'**
  String get projectPath;

  /// No description provided for @timeInfo.
  ///
  /// In en, this message translates to:
  /// **'Time Information'**
  String get timeInfo;

  /// No description provided for @addedAt.
  ///
  /// In en, this message translates to:
  /// **'Added At'**
  String get addedAt;

  /// No description provided for @tags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tags;

  /// No description provided for @failedToOpenFolder.
  ///
  /// In en, this message translates to:
  /// **'Failed to open folder'**
  String get failedToOpenFolder;

  /// No description provided for @pageTransition.
  ///
  /// In en, this message translates to:
  /// **'Page Transition Animation'**
  String get pageTransition;

  /// No description provided for @disabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// No description provided for @fadeTransition.
  ///
  /// In en, this message translates to:
  /// **'Fade'**
  String get fadeTransition;

  /// No description provided for @slideLeftTransition.
  ///
  /// In en, this message translates to:
  /// **'Slide Left'**
  String get slideLeftTransition;

  /// No description provided for @slideRightTransition.
  ///
  /// In en, this message translates to:
  /// **'Slide Right'**
  String get slideRightTransition;

  /// No description provided for @slideUpTransition.
  ///
  /// In en, this message translates to:
  /// **'Slide Up'**
  String get slideUpTransition;

  /// No description provided for @slideDownTransition.
  ///
  /// In en, this message translates to:
  /// **'Slide Down'**
  String get slideDownTransition;

  /// No description provided for @scaleTransition.
  ///
  /// In en, this message translates to:
  /// **'Scale'**
  String get scaleTransition;

  /// No description provided for @rotationTransition.
  ///
  /// In en, this message translates to:
  /// **'Rotation'**
  String get rotationTransition;

  /// No description provided for @nodeManager.
  ///
  /// In en, this message translates to:
  /// **'Node Version Manager'**
  String get nodeManager;

  /// No description provided for @nodeManagerDescription.
  ///
  /// In en, this message translates to:
  /// **'Manage Node.js versions and version management tools'**
  String get nodeManagerDescription;

  /// No description provided for @versionManagers.
  ///
  /// In en, this message translates to:
  /// **'Version Managers'**
  String get versionManagers;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @installedVersions.
  ///
  /// In en, this message translates to:
  /// **'Installed Versions'**
  String get installedVersions;

  /// No description provided for @noVersionsInstalled.
  ///
  /// In en, this message translates to:
  /// **'No Node.js versions installed yet'**
  String get noVersionsInstalled;

  /// No description provided for @use.
  ///
  /// In en, this message translates to:
  /// **'Use'**
  String get use;

  /// No description provided for @current.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get current;

  /// No description provided for @installNewVersion.
  ///
  /// In en, this message translates to:
  /// **'Install New Version'**
  String get installNewVersion;

  /// No description provided for @enterVersionNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter version number, e.g., 18.17.0'**
  String get enterVersionNumber;

  /// No description provided for @install.
  ///
  /// In en, this message translates to:
  /// **'Install'**
  String get install;

  /// No description provided for @versionFormatHint.
  ///
  /// In en, this message translates to:
  /// **'Examples: 18.17.0, 20.x, lts'**
  String get versionFormatHint;

  /// No description provided for @uninstall.
  ///
  /// In en, this message translates to:
  /// **'Uninstall'**
  String get uninstall;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @viewWebsite.
  ///
  /// In en, this message translates to:
  /// **'View Website'**
  String get viewWebsite;

  /// No description provided for @installCommand.
  ///
  /// In en, this message translates to:
  /// **'Install Command'**
  String get installCommand;

  /// No description provided for @confirmUninstall.
  ///
  /// In en, this message translates to:
  /// **'Confirm Uninstall'**
  String get confirmUninstall;

  /// No description provided for @confirmUninstallMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to uninstall Node.js {version}?'**
  String confirmUninstallMessage(String version);

  /// No description provided for @confirmInstallManager.
  ///
  /// In en, this message translates to:
  /// **'Install {name}'**
  String confirmInstallManager(String name);

  /// No description provided for @confirmInstallManagerMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to install {name}?'**
  String confirmInstallManagerMessage(String name);

  /// No description provided for @confirmUpdateManager.
  ///
  /// In en, this message translates to:
  /// **'Update {name}'**
  String confirmUpdateManager(String name);

  /// No description provided for @confirmUpdateManagerMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to update {name} to the latest version?'**
  String confirmUpdateManagerMessage(String name);

  /// No description provided for @switchedToManager.
  ///
  /// In en, this message translates to:
  /// **'Switched to {name}'**
  String switchedToManager(String name);

  /// No description provided for @switchFailed.
  ///
  /// In en, this message translates to:
  /// **'Switch failed'**
  String get switchFailed;

  /// No description provided for @switchedToNodeVersion.
  ///
  /// In en, this message translates to:
  /// **'Switched to Node.js {version}'**
  String switchedToNodeVersion(String version);

  /// No description provided for @nodeVersionInstalled.
  ///
  /// In en, this message translates to:
  /// **'Node.js {version} installed successfully'**
  String nodeVersionInstalled(String version);

  /// No description provided for @installFailed.
  ///
  /// In en, this message translates to:
  /// **'Installation failed'**
  String get installFailed;

  /// No description provided for @nodeVersionUninstalled.
  ///
  /// In en, this message translates to:
  /// **'Node.js {version} uninstalled successfully'**
  String nodeVersionUninstalled(String version);

  /// No description provided for @uninstallFailed.
  ///
  /// In en, this message translates to:
  /// **'Uninstall failed'**
  String get uninstallFailed;

  /// No description provided for @managerInstalled.
  ///
  /// In en, this message translates to:
  /// **'{name} installed successfully'**
  String managerInstalled(String name);

  /// No description provided for @managerUpdated.
  ///
  /// In en, this message translates to:
  /// **'{name} updated successfully'**
  String managerUpdated(String name);

  /// No description provided for @updateFailed.
  ///
  /// In en, this message translates to:
  /// **'Update failed'**
  String get updateFailed;

  /// No description provided for @uninstallComplete.
  ///
  /// In en, this message translates to:
  /// **'Uninstall Complete'**
  String get uninstallComplete;

  /// No description provided for @uninstallFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Uninstall Failed'**
  String get uninstallFailedTitle;

  /// No description provided for @preparingUninstall.
  ///
  /// In en, this message translates to:
  /// **'Preparing to uninstall {name}...'**
  String preparingUninstall(String name);

  /// No description provided for @uninstalling.
  ///
  /// In en, this message translates to:
  /// **'Uninstalling {name}'**
  String uninstalling(String name);

  /// No description provided for @failedToOpenFolderWithError.
  ///
  /// In en, this message translates to:
  /// **'Error occurred while opening folder'**
  String get failedToOpenFolderWithError;

  /// No description provided for @currentEnvironmentVersion.
  ///
  /// In en, this message translates to:
  /// **'Current Environment Version'**
  String get currentEnvironmentVersion;

  /// No description provided for @notInstalled.
  ///
  /// In en, this message translates to:
  /// **'Not Installed'**
  String get notInstalled;

  /// No description provided for @installed.
  ///
  /// In en, this message translates to:
  /// **'Installed'**
  String get installed;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @uninstallWarning.
  ///
  /// In en, this message translates to:
  /// **'After uninstalling, all Node.js versions installed with this tool will also be removed. This action cannot be undone.'**
  String get uninstallWarning;

  /// No description provided for @uninstallLog.
  ///
  /// In en, this message translates to:
  /// **'Uninstall Log'**
  String get uninstallLog;

  /// No description provided for @systemInfoOverview.
  ///
  /// In en, this message translates to:
  /// **'System Information Overview'**
  String get systemInfoOverview;

  /// No description provided for @realtimeMonitoring.
  ///
  /// In en, this message translates to:
  /// **'Real-time monitoring of your development environment and system status'**
  String get realtimeMonitoring;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @projectStats.
  ///
  /// In en, this message translates to:
  /// **'Project Statistics'**
  String get projectStats;

  /// No description provided for @runningProjects.
  ///
  /// In en, this message translates to:
  /// **'Running Projects'**
  String get runningProjects;

  /// No description provided for @developmentEnvironment.
  ///
  /// In en, this message translates to:
  /// **'Development Environment'**
  String get developmentEnvironment;

  /// No description provided for @versionManager.
  ///
  /// In en, this message translates to:
  /// **'Version Manager'**
  String get versionManager;

  /// No description provided for @systemInformation.
  ///
  /// In en, this message translates to:
  /// **'System Information'**
  String get systemInformation;

  /// No description provided for @cpu.
  ///
  /// In en, this message translates to:
  /// **'CPU'**
  String get cpu;

  /// No description provided for @battery.
  ///
  /// In en, this message translates to:
  /// **'Battery'**
  String get battery;

  /// No description provided for @storage.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get storage;

  /// No description provided for @network.
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get network;

  /// No description provided for @installedSoftware.
  ///
  /// In en, this message translates to:
  /// **'Installed Software'**
  String get installedSoftware;

  /// No description provided for @codeEditors.
  ///
  /// In en, this message translates to:
  /// **'Code Editors'**
  String get codeEditors;

  /// No description provided for @browsers.
  ///
  /// In en, this message translates to:
  /// **'Browsers'**
  String get browsers;

  /// No description provided for @noEditorsDetected.
  ///
  /// In en, this message translates to:
  /// **'No code editors detected'**
  String get noEditorsDetected;

  /// No description provided for @noBrowsersDetected.
  ///
  /// In en, this message translates to:
  /// **'No browsers detected'**
  String get noBrowsersDetected;

  /// No description provided for @debugTools.
  ///
  /// In en, this message translates to:
  /// **'Debug Tools'**
  String get debugTools;

  /// No description provided for @storageDebugInfo.
  ///
  /// In en, this message translates to:
  /// **'Storage Debug Info'**
  String get storageDebugInfo;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @clearCorruptedData.
  ///
  /// In en, this message translates to:
  /// **'Clear Corrupted Data'**
  String get clearCorruptedData;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @confirmClear.
  ///
  /// In en, this message translates to:
  /// **'Confirm Clear'**
  String get confirmClear;

  /// No description provided for @clearDataWarning.
  ///
  /// In en, this message translates to:
  /// **'This operation will clear all cached data in SharedPreferences and reset all settings to default values.\n\nProject data will not be affected (stored in files).\n\nContinue?'**
  String get clearDataWarning;

  /// No description provided for @clearingData.
  ///
  /// In en, this message translates to:
  /// **'Clearing data...'**
  String get clearingData;

  /// No description provided for @clearSuccess.
  ///
  /// In en, this message translates to:
  /// **'Cleared successfully, settings have been reset to default values.'**
  String get clearSuccess;

  /// No description provided for @clearFailed.
  ///
  /// In en, this message translates to:
  /// **'Clear failed'**
  String get clearFailed;

  /// No description provided for @notInstalledMessage.
  ///
  /// In en, this message translates to:
  /// **'{name} is not installed'**
  String notInstalledMessage(String name);

  /// No description provided for @installFirstMessage.
  ///
  /// In en, this message translates to:
  /// **'Please install this tool first before managing its versions.'**
  String get installFirstMessage;

  /// No description provided for @toolInfo.
  ///
  /// In en, this message translates to:
  /// **'Tool Information'**
  String get toolInfo;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @installPath.
  ///
  /// In en, this message translates to:
  /// **'Install Path'**
  String get installPath;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @visitWebsite.
  ///
  /// In en, this message translates to:
  /// **'Visit Website'**
  String get visitWebsite;

  /// No description provided for @switchedToNode.
  ///
  /// In en, this message translates to:
  /// **'Switched to Node.js {version}'**
  String switchedToNode(String version);

  /// No description provided for @switchToNodeFailed.
  ///
  /// In en, this message translates to:
  /// **'Switch failed'**
  String get switchToNodeFailed;

  /// No description provided for @nodeInstalled.
  ///
  /// In en, this message translates to:
  /// **'Node.js {version} installed successfully'**
  String nodeInstalled(String version);

  /// No description provided for @nodeInstallFailed.
  ///
  /// In en, this message translates to:
  /// **'Installation failed'**
  String get nodeInstallFailed;

  /// No description provided for @nodeUninstalled.
  ///
  /// In en, this message translates to:
  /// **'Node.js {version} uninstalled successfully'**
  String nodeUninstalled(String version);

  /// No description provided for @nodeUninstallFailed.
  ///
  /// In en, this message translates to:
  /// **'Uninstallation failed'**
  String get nodeUninstallFailed;

  /// No description provided for @confirmUninstallNode.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to uninstall Node.js {version}?'**
  String confirmUninstallNode(String version);

  /// No description provided for @developmentEnv.
  ///
  /// In en, this message translates to:
  /// **'Development'**
  String get developmentEnv;

  /// No description provided for @stagingEnv.
  ///
  /// In en, this message translates to:
  /// **'Staging'**
  String get stagingEnv;

  /// No description provided for @productionEnv.
  ///
  /// In en, this message translates to:
  /// **'Production'**
  String get productionEnv;

  /// No description provided for @building.
  ///
  /// In en, this message translates to:
  /// **'Building...'**
  String get building;

  /// No description provided for @startBuild.
  ///
  /// In en, this message translates to:
  /// **'Start Build'**
  String get startBuild;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @stopping.
  ///
  /// In en, this message translates to:
  /// **'Stopping...'**
  String get stopping;

  /// No description provided for @starting.
  ///
  /// In en, this message translates to:
  /// **'Starting...'**
  String get starting;

  /// No description provided for @previewing.
  ///
  /// In en, this message translates to:
  /// **'Previewing...'**
  String get previewing;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// No description provided for @stopService.
  ///
  /// In en, this message translates to:
  /// **'Stop Service'**
  String get stopService;

  /// No description provided for @startDevServer.
  ///
  /// In en, this message translates to:
  /// **'Start Dev Server'**
  String get startDevServer;

  /// No description provided for @startPreviewServer.
  ///
  /// In en, this message translates to:
  /// **'Start Preview Server'**
  String get startPreviewServer;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @serviceUrl.
  ///
  /// In en, this message translates to:
  /// **'Service URL'**
  String get serviceUrl;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @inUse.
  ///
  /// In en, this message translates to:
  /// **'In Use'**
  String get inUse;

  /// No description provided for @manageDependencies.
  ///
  /// In en, this message translates to:
  /// **'Manage Dependencies'**
  String get manageDependencies;

  /// No description provided for @dependencyManagement.
  ///
  /// In en, this message translates to:
  /// **'Dependency Management'**
  String get dependencyManagement;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hant':
            return AppLocalizationsZhHant();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
