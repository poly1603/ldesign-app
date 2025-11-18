import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../config/theme_config.dart';
import 'settings_panel.dart';
import '../l10n/app_localizations.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final theme = Theme.of(context);
    final size = appProvider.appSize;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor,
            width: 1,
          ),
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: ThemeConfig.getSpacing(size),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              appProvider.sidebarCollapsed
                  ? Icons.menu_open
                  : Icons.menu,
              size: ThemeConfig.getIconSize(size),
            ),
            onPressed: () {
              appProvider.toggleSidebar();
            },
            tooltip: appProvider.sidebarCollapsed ? l10n.expand : l10n.collapse,
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              Icons.settings,
              size: ThemeConfig.getIconSize(size),
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const SettingsDialog(),
              );
            },
            tooltip: l10n.settings,
          ),
        ],
      ),
    );
  }
}

class SettingsDialog extends StatelessWidget {
  const SettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 500,
        constraints: const BoxConstraints(maxHeight: 600),
        child: const SettingsPanel(),
      ),
    );
  }
}
