import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/app_provider.dart';
import '../config/theme_config.dart';
import '../widgets/debug_storage_dialog.dart';
import '../utils/storage_util.dart';

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
            style: TextStyle(
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
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                      icon: const Icon(Bootstrap.sun, size: 14),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      label: Text(
                        l10n.darkMode,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
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
                        style: TextStyle(
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
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ),
                    ButtonSegment(
                      value: AppSize.standard,
                      label: Text(
                        l10n.standard,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ),
                    ButtonSegment(
                      value: AppSize.comfortable,
                      label: Text(
                        l10n.comfortable,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
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
          const SizedBox(height: 16),
          
          // Debug Settings Card (only in debug mode)
          if (const bool.fromEnvironment('dart.vm.product') == false)
            _buildSettingsCard(
              theme: theme,
              title: '调试工具',
              icon: Bootstrap.bug,
              children: [
                _buildSettingItem(
                  theme: theme,
                  title: '存储调试信息',
                  icon: Bootstrap.database,
                  trailing: ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => const DebugStorageDialog(),
                      );
                    },
                    icon: const Icon(Bootstrap.bug, size: 14),
                    label: const Text('查看'),
                  ),
                ),
                const SizedBox(height: 16),
                _buildSettingItem(
                  theme: theme,
                  title: '清理损坏数据',
                  icon: Bootstrap.trash,
                  trailing: ElevatedButton.icon(
                    onPressed: () => _showClearDataDialog(context),
                    icon: const Icon(Bootstrap.trash, size: 14),
                    label: const Text('清理'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.error,
                      foregroundColor: theme.colorScheme.onError,
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
                  style: TextStyle(
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
              style: TextStyle(
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

  void _showClearDataDialog(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Bootstrap.exclamation_triangle, color: theme.colorScheme.error),
            const SizedBox(width: 12),
            const Text('确认清理'),
          ],
        ),
        content: const Text(
          '此操作将清理所有 SharedPreferences 中的损坏数据，并重置所有设置为默认值。\n\n'
          '项目数据不会受影响（保存在文件中）。\n\n'
          '是否继续？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _clearCorruptedData(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            child: const Text('清理'),
          ),
        ],
      ),
    );
  }

  Future<void> _clearCorruptedData(BuildContext context) async {
    final theme = Theme.of(context);
    final messenger = ScaffoldMessenger.of(context);
    
    try {
      // 显示加载提示
      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.onInverseSurface,
                ),
              ),
              const SizedBox(width: 12),
              const Text('正在清理数据...'),
            ],
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      // 执行清理
      await StorageUtil.resetAllPreferences();

      // 重新加载设置
      if (context.mounted) {
        await context.read<AppProvider>().initialize();
      }

      // 显示成功消息
      messenger.clearSnackBars();
      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Bootstrap.check_circle, color: theme.colorScheme.onPrimary, size: 18),
              const SizedBox(width: 12),
              const Text('清理成功！设置已重置为默认值'),
            ],
          ),
          backgroundColor: theme.colorScheme.primary,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      messenger.clearSnackBars();
      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Bootstrap.exclamation_circle, color: theme.colorScheme.onError, size: 18),
              const SizedBox(width: 12),
              Text('清理失败: $e'),
            ],
          ),
          backgroundColor: theme.colorScheme.error,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
}
