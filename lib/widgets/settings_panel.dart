import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import '../providers/app_provider.dart';
import '../config/theme_config.dart';
import '../l10n/app_localizations.dart';

class SettingsPanel extends StatelessWidget {
  const SettingsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final theme = Theme.of(context);
    final size = appProvider.appSize;
    final l10n = AppLocalizations.of(context)!;
    final spacing = ThemeConfig.getSpacing(size);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(spacing * 2),
          child: Row(
            children: [
              Icon(Icons.settings, color: theme.colorScheme.primary),
              SizedBox(width: spacing),
              Text(
                l10n.settings,
                style: theme.textTheme.headlineSmall,
              ),
            ],
          ),
        ),
        Divider(height: 1, color: theme.dividerColor),
        Expanded(
          child: ListView(
            padding: EdgeInsets.all(spacing * 2),
            children: [
              _buildSection(
                context,
                title: l10n.themeMode,
                child: SwitchListTile(
                  title: Text(l10n.darkMode),
                  subtitle: Text(
                    appProvider.isDarkMode ? l10n.darkMode : l10n.lightMode,
                  ),
                  value: appProvider.isDarkMode,
                  onChanged: (_) {
                    appProvider.toggleThemeMode();
                  },
                  secondary: Icon(
                    appProvider.isDarkMode
                        ? Icons.dark_mode
                        : Icons.light_mode,
                  ),
                ),
              ),
              SizedBox(height: spacing * 2),
              _buildSection(
                context,
                title: l10n.themeColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: spacing,
                        vertical: spacing / 2,
                      ),
                      child: Text(
                        l10n.presetColors,
                        style: theme.textTheme.titleSmall,
                      ),
                    ),
                    Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      children: ThemeConfig.presetColors.map((color) {
                        final isSelected =
                            color.value == appProvider.primaryColor.value;
                        return InkWell(
                          onTap: () {
                            appProvider.setPrimaryColor(color);
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : Colors.transparent,
                                width: 3,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: spacing),
                    ListTile(
                      leading: const Icon(Icons.color_lens),
                      title: Text(l10n.customColor),
                      trailing: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: appProvider.primaryColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: theme.dividerColor,
                            width: 1,
                          ),
                        ),
                      ),
                      onTap: () async {
                        final selectedColor = await showColorPickerDialog(
                          context,
                          appProvider.primaryColor,
                          title: Text(l10n.customColor),
                          pickersEnabled: const {
                            ColorPickerType.wheel: true,
                            ColorPickerType.primary: true,
                            ColorPickerType.accent: false,
                          },
                        );
                        appProvider.setPrimaryColor(selectedColor);
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: spacing * 2),
              _buildSection(
                context,
                title: l10n.globalSize,
                child: Column(
                  children: [
                    RadioListTile<AppSize>(
                      title: Text(l10n.compact),
                      value: AppSize.compact,
                      groupValue: appProvider.appSize,
                      onChanged: (value) {
                        if (value != null) {
                          appProvider.setAppSize(value);
                        }
                      },
                    ),
                    RadioListTile<AppSize>(
                      title: Text(l10n.standard),
                      value: AppSize.standard,
                      groupValue: appProvider.appSize,
                      onChanged: (value) {
                        if (value != null) {
                          appProvider.setAppSize(value);
                        }
                      },
                    ),
                    RadioListTile<AppSize>(
                      title: Text(l10n.comfortable),
                      value: AppSize.comfortable,
                      groupValue: appProvider.appSize,
                      onChanged: (value) {
                        if (value != null) {
                          appProvider.setAppSize(value);
                        }
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: spacing * 2),
              _buildSection(
                context,
                title: l10n.language,
                child: Column(
                  children: [
                    RadioListTile<Locale>(
                      title: Text(l10n.chinese),
                      value: const Locale('zh'),
                      groupValue: appProvider.locale,
                      onChanged: (value) {
                        if (value != null) {
                          appProvider.setLocale(value);
                        }
                      },
                    ),
                    RadioListTile<Locale>(
                      title: Text(l10n.english),
                      value: const Locale('en'),
                      groupValue: appProvider.locale,
                      onChanged: (value) {
                        if (value != null) {
                          appProvider.setLocale(value);
                        }
                      },
                    ),
                    RadioListTile<Locale>(
                      title: Text(l10n.traditionalChinese),
                      value: const Locale('zh', 'Hant'),
                      groupValue: appProvider.locale,
                      onChanged: (value) {
                        if (value != null) {
                          appProvider.setLocale(value);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Card(
          child: child,
        ),
      ],
    );
  }
}
