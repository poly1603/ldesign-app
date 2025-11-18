import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/app_provider.dart';
import '../config/theme_config.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final appProvider = context.watch<AppProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            l10n.settings,
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 32),
          
          // Theme Settings Card
          _buildSettingsCard(
            theme: theme,
            title: l10n.theme,
            icon: Bootstrap.palette,
            children: [
              _buildSettingItem(
                theme: theme,
                title: l10n.themeMode,
                icon: Bootstrap.moon_stars,
                trailing: SegmentedButton<ThemeMode>(
                  segments: [
                    ButtonSegment(
                      value: ThemeMode.light,
                      label: Text(
                        l10n.lightMode,
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                      icon: const Icon(Bootstrap.sun, size: 14),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      label: Text(
                        l10n.darkMode,
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                      icon: const Icon(Bootstrap.moon, size: 14),
                    ),
                  ],
                  selected: {appProvider.themeMode},
                  onSelectionChanged: (Set<ThemeMode> newSelection) {
                    appProvider.setThemeMode(newSelection.first);
                  },
                  style: ButtonStyle(
                    padding: WidgetStateProperty.all(
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildSettingItem(
                theme: theme,
                title: l10n.themeColor,
                icon: Bootstrap.droplet,
                trailing: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Language Settings Card
          _buildSettingsCard(
            theme: theme,
            title: l10n.language,
            icon: Bootstrap.translate,
            children: [
              _buildSettingItem(
                theme: theme,
                title: l10n.language,
                icon: Bootstrap.globe,
                trailing: DropdownButton<Locale>(
                  value: appProvider.locale,
                  underline: const SizedBox(),
                  borderRadius: BorderRadius.circular(12),
                  items: const [
                    Locale('zh'),
                    Locale('en'),
                    Locale('zh', 'Hant'),
                  ].map((locale) {
                    String label;
                    switch (locale.languageCode) {
                      case 'zh':
                        label = locale.scriptCode == 'Hant' ? l10n.traditionalChinese : l10n.chinese;
                        break;
                      case 'en':
                        label = l10n.english;
                        break;
                      default:
                        label = locale.languageCode;
                    }
                    return DropdownMenuItem(
                      value: locale,
                      child: Text(
                        label,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (locale) {
                    if (locale != null) {
                      appProvider.setLocale(locale);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Display Settings Card
          _buildSettingsCard(
            theme: theme,
            title: l10n.size,
            icon: Bootstrap.arrows_angle_expand,
            children: [
              _buildSettingItem(
                theme: theme,
                title: l10n.globalSize,
                icon: Bootstrap.phone,
                trailing: SegmentedButton<AppSize>(
                  segments: [
                    ButtonSegment(
                      value: AppSize.compact,
                      label: Text(
                        l10n.compact,
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ),
                    ButtonSegment(
                      value: AppSize.standard,
                      label: Text(
                        l10n.standard,
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ),
                    ButtonSegment(
                      value: AppSize.comfortable,
                      label: Text(
                        l10n.comfortable,
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                  selected: {appProvider.appSize},
                  onSelectionChanged: (Set<AppSize> newSelection) {
                    appProvider.setAppSize(newSelection.first);
                  },
                  style: ButtonStyle(
                    padding: WidgetStateProperty.all(
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard({
    required ThemeData theme,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? theme.colorScheme.surface
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primary.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required ThemeData theme,
    required String title,
    required IconData icon,
    required Widget trailing,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface.withOpacity(0.8),
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
        trailing,
      ],
    );
  }
}
