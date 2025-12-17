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
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Flutter Toolbox'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @projects.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get projects;

  /// No description provided for @nodeManagement.
  ///
  /// In en, this message translates to:
  /// **'Node'**
  String get nodeManagement;

  /// No description provided for @gitManagement.
  ///
  /// In en, this message translates to:
  /// **'Git'**
  String get gitManagement;

  /// No description provided for @svgManagement.
  ///
  /// In en, this message translates to:
  /// **'SVG'**
  String get svgManagement;

  /// No description provided for @fontManagement.
  ///
  /// In en, this message translates to:
  /// **'Fonts'**
  String get fontManagement;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @addProject.
  ///
  /// In en, this message translates to:
  /// **'Add Project'**
  String get addProject;

  /// No description provided for @removeProject.
  ///
  /// In en, this message translates to:
  /// **'Remove Project'**
  String get removeProject;

  /// No description provided for @projectName.
  ///
  /// In en, this message translates to:
  /// **'Project Name'**
  String get projectName;

  /// No description provided for @projectPath.
  ///
  /// In en, this message translates to:
  /// **'Path'**
  String get projectPath;

  /// No description provided for @projectVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get projectVersion;

  /// No description provided for @projectFramework.
  ///
  /// In en, this message translates to:
  /// **'Framework'**
  String get projectFramework;

  /// No description provided for @lastAccessed.
  ///
  /// In en, this message translates to:
  /// **'Last Accessed'**
  String get lastAccessed;

  /// No description provided for @dependencies.
  ///
  /// In en, this message translates to:
  /// **'Dependencies'**
  String get dependencies;

  /// No description provided for @devDependencies.
  ///
  /// In en, this message translates to:
  /// **'Dev Dependencies'**
  String get devDependencies;

  /// No description provided for @scripts.
  ///
  /// In en, this message translates to:
  /// **'Scripts'**
  String get scripts;

  /// No description provided for @nodeVersion.
  ///
  /// In en, this message translates to:
  /// **'Node.js Version'**
  String get nodeVersion;

  /// No description provided for @npmVersion.
  ///
  /// In en, this message translates to:
  /// **'npm Version'**
  String get npmVersion;

  /// No description provided for @pnpmVersion.
  ///
  /// In en, this message translates to:
  /// **'pnpm Version'**
  String get pnpmVersion;

  /// No description provided for @yarnVersion.
  ///
  /// In en, this message translates to:
  /// **'yarn Version'**
  String get yarnVersion;

  /// No description provided for @installPath.
  ///
  /// In en, this message translates to:
  /// **'Install Path'**
  String get installPath;

  /// No description provided for @globalPackages.
  ///
  /// In en, this message translates to:
  /// **'Global Packages'**
  String get globalPackages;

  /// No description provided for @notInstalled.
  ///
  /// In en, this message translates to:
  /// **'Not Installed'**
  String get notInstalled;

  /// No description provided for @installGuide.
  ///
  /// In en, this message translates to:
  /// **'Please install {tool} to use this feature'**
  String installGuide(String tool);

  /// No description provided for @gitVersion.
  ///
  /// In en, this message translates to:
  /// **'Git Version'**
  String get gitVersion;

  /// No description provided for @gitUserName.
  ///
  /// In en, this message translates to:
  /// **'User Name'**
  String get gitUserName;

  /// No description provided for @gitUserEmail.
  ///
  /// In en, this message translates to:
  /// **'User Email'**
  String get gitUserEmail;

  /// No description provided for @importAssets.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get importAssets;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @copyToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copy to Clipboard'**
  String get copyToClipboard;

  /// No description provided for @fileSize.
  ///
  /// In en, this message translates to:
  /// **'File Size'**
  String get fileSize;

  /// No description provided for @importedAt.
  ///
  /// In en, this message translates to:
  /// **'Imported At'**
  String get importedAt;

  /// No description provided for @previewText.
  ///
  /// In en, this message translates to:
  /// **'Preview Text'**
  String get previewText;

  /// No description provided for @themeColor.
  ///
  /// In en, this message translates to:
  /// **'Theme Color'**
  String get themeColor;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @followSystem.
  ///
  /// In en, this message translates to:
  /// **'Follow System'**
  String get followSystem;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @resetSettings.
  ///
  /// In en, this message translates to:
  /// **'Reset Settings'**
  String get resetSettings;

  /// No description provided for @resetConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset all settings?'**
  String get resetConfirm;

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

  /// No description provided for @projectCount.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get projectCount;

  /// No description provided for @svgCount.
  ///
  /// In en, this message translates to:
  /// **'SVG Files'**
  String get svgCount;

  /// No description provided for @fontCount.
  ///
  /// In en, this message translates to:
  /// **'Fonts'**
  String get fontCount;
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
