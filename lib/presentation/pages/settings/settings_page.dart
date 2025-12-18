import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_toolbox/providers/app_providers.dart';
import 'package:flutter_toolbox/providers/settings_providers.dart';
import 'package:flutter_toolbox/l10n/app_localizations.dart';

/// 设置页面
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppearanceSection(context, ref, l10n),
            const SizedBox(height: 24),
            _buildLanguageSection(context, ref, l10n),
            const SizedBox(height: 24),
            _buildResetSection(context, ref, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildAppearanceSection(
      BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final themeMode = ref.watch(themeModeProvider);
    final primaryColor = ref.watch(primaryColorProvider);
    final enableAnimations = ref.watch(enableAnimationsProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.appearance,
                style: Theme.of(context).textTheme.titleMedium),
            const Divider(),
            // 暗黑模式切换
            SwitchListTile(
              title: Text(l10n.darkMode),
              subtitle: Text(l10n.followSystem),
              value: themeMode == ThemeMode.dark,
              onChanged: (value) {
                ref.read(appSettingsProvider.notifier).setThemeMode(
                    value ? ThemeMode.dark : ThemeMode.light);
              },
            ),
            const Divider(),
            // 动画效果开关
            SwitchListTile(
              title: const Text('动画效果'),
              subtitle: const Text('开启或关闭应用中的所有动画效果'),
              value: enableAnimations,
              onChanged: (value) {
                ref.read(appSettingsProvider.notifier).setEnableAnimations(value);
              },
            ),
            const Divider(),
            // 主题色选择
            ListTile(
              title: Text(l10n.themeColor),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ColorButton(
                    color: Colors.blue,
                    isSelected: primaryColor == Colors.blue,
                    onTap: () =>
                        ref.read(appSettingsProvider.notifier).setPrimaryColor(Colors.blue),
                  ),
                  _ColorButton(
                    color: Colors.green,
                    isSelected: primaryColor == Colors.green,
                    onTap: () =>
                        ref.read(appSettingsProvider.notifier).setPrimaryColor(Colors.green),
                  ),
                  _ColorButton(
                    color: Colors.purple,
                    isSelected: primaryColor == Colors.purple,
                    onTap: () =>
                        ref.read(appSettingsProvider.notifier).setPrimaryColor(Colors.purple),
                  ),
                  _ColorButton(
                    color: Colors.orange,
                    isSelected: primaryColor == Colors.orange,
                    onTap: () =>
                        ref.read(appSettingsProvider.notifier).setPrimaryColor(Colors.orange),
                  ),
                  _ColorButton(
                    color: Colors.teal,
                    isSelected: primaryColor == Colors.teal,
                    onTap: () =>
                        ref.read(appSettingsProvider.notifier).setPrimaryColor(Colors.teal),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSection(
      BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final locale = ref.watch(localeProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.general, style: Theme.of(context).textTheme.titleMedium),
            const Divider(),
            ListTile(
              title: Text(l10n.language),
              trailing: DropdownButton<Locale>(
                value: locale,
                items: const [
                  DropdownMenuItem(
                    value: Locale('en'),
                    child: Text('English'),
                  ),
                  DropdownMenuItem(
                    value: Locale('zh'),
                    child: Text('中文'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    ref.read(appSettingsProvider.notifier).setLocale(value);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResetSection(
      BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.resetSettings,
                style: Theme.of(context).textTheme.titleMedium),
            const Divider(),
            ListTile(
              title: Text(l10n.resetSettings),
              subtitle: Text(l10n.resetConfirm),
              trailing: FilledButton(
                onPressed: () => _confirmReset(context, ref, l10n),
                child: Text(l10n.resetSettings),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmReset(
      BuildContext context, WidgetRef ref, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.resetSettings),
        content: Text(l10n.resetConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      // 重置所有设置
      ref.read(appSettingsProvider.notifier).resetToDefaults();
    }
  }
}

class _ColorButton extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorButton({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: isSelected
                ? Border.all(color: Colors.white, width: 3)
                : null,
            boxShadow: isSelected
                ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 8)]
                : null,
          ),
        ),
      ),
    );
  }
}
