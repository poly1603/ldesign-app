import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/node_version_manager_service.dart';
import '../l10n/app_localizations.dart';
import '../widgets/number_text.dart';

class NodeManagerDetailScreen extends StatefulWidget {
  final NodeVersionManager manager;
  final NodeVersionManagerService service;

  const NodeManagerDetailScreen({
    super.key,
    required this.manager,
    required this.service,
  });

  @override
  State<NodeManagerDetailScreen> createState() => _NodeManagerDetailScreenState();
}

class _NodeManagerDetailScreenState extends State<NodeManagerDetailScreen> {
  String _newVersionInput = '';

  @override
  void initState() {
    super.initState();
    _loadVersions();
  }

  Future<void> _loadVersions() async {
    if (widget.manager.isInstalled) {
      await widget.service.setActiveManager(widget.manager);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return ChangeNotifierProvider.value(
      value: widget.service,
      child: Scaffold(
        backgroundColor: theme.colorScheme.surfaceContainerLowest,
        body: Consumer<NodeVersionManagerService>(
          builder: (context, service, child) {
            if (!widget.manager.isInstalled) {
              return _buildNotInstalledView(theme, l10n);
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard(theme, l10n),
                  const SizedBox(height: 24),
                  _buildInstalledVersionsSection(theme, l10n, service),
                  const SizedBox(height: 24),
                  _buildInstallNewVersionSection(theme, l10n, service),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNotInstalledView(ThemeData theme, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Bootstrap.exclamation_circle, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            l10n.notInstalledMessage(widget.manager.displayName),
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.installFirstMessage,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Bootstrap.arrow_left),
            label: Text(l10n.back),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(ThemeData theme, AppLocalizations l10n) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              Row(
                children: [
                  Icon(Bootstrap.info_circle, size: 20, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    l10n.toolInfo,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildInfoRow(theme, l10n.name, widget.manager.displayName),
              _buildInfoRow(theme, l10n.version, widget.manager.version ?? l10n.unknown),
              _buildInfoRow(theme, l10n.installPath, widget.manager.installPath ?? l10n.unknown),
              _buildInfoRow(theme, l10n.description, widget.manager.description),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final url = Uri.parse(widget.manager.website);
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        }
                      },
                      icon: const Icon(Bootstrap.globe, size: 16),
                      label: Text(l10n.visitWebsite),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.15),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstalledVersionsSection(
    ThemeData theme,
    AppLocalizations l10n,
    NodeVersionManagerService service,
  ) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Bootstrap.list_ul, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  l10n.installedVersions,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => service.refresh(),
                  icon: const Icon(Bootstrap.arrow_clockwise, size: 16),
                  label: Text(l10n.refresh),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (service.installedVersions.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Bootstrap.inbox, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        l10n.noVersionsInstalled,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...service.installedVersions.map((version) => _buildVersionCard(theme, l10n, version, service)),
          ],
        ),
      ),
    );
  }

  Widget _buildVersionCard(
    ThemeData theme,
    AppLocalizations l10n,
    NodeVersion version,
    NodeVersionManagerService service,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: version.isActive ? theme.colorScheme.primary.withValues(alpha: 0.15) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: version.isActive ? theme.colorScheme.primary : Colors.grey.shade200,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: version.isActive ? theme.colorScheme.primary : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Bootstrap.terminal,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      VersionText(
                        version.version,
                        fontSize: theme.textTheme.titleSmall?.fontSize,
                        fontWeight: FontWeight.w600,
                      ),
                      if (version.isLts) ...{
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'LTS',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ),
                      },
                      if (version.isActive) ...{
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            l10n.current,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      },
                    ],
                  ),
                ],
              ),
            ),
            if (!version.isActive)
              ElevatedButton(
                onPressed: () => _switchVersion(version.version, service),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: Size.zero,
                ),
                child: Text(l10n.use, style: const TextStyle(fontSize: 12)),
              ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => _uninstallVersion(version.version, service),
              icon: const Icon(Bootstrap.trash, size: 14),
              style: IconButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                foregroundColor: Colors.red,
                padding: const EdgeInsets.all(6),
                minimumSize: Size.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstallNewVersionSection(
    ThemeData theme,
    AppLocalizations l10n,
    NodeVersionManagerService service,
  ) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Bootstrap.plus_circle, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  l10n.installNewVersion,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) => setState(() => _newVersionInput = value),
                    decoration: InputDecoration(
                      hintText: l10n.enterVersionNumber,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _newVersionInput.isNotEmpty 
                      ? () => _installVersion(_newVersionInput, service)
                      : null,
                  icon: const Icon(Bootstrap.download, size: 16),
                  label: Text(l10n.install),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              l10n.versionFormatHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getManagerColor() {
    switch (widget.manager.type) {
      case NodeVersionManagerType.nvm:
        return Colors.green;
      case NodeVersionManagerType.fnm:
        return Colors.blue;
      case NodeVersionManagerType.volta:
        return Colors.purple;
      case NodeVersionManagerType.n:
        return Colors.orange;
      case NodeVersionManagerType.nvs:
        return Colors.teal;
    }
  }

  Future<void> _switchVersion(String version, NodeVersionManagerService service) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await service.switchNodeVersion(version);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.switchedToNode(version))),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.switchToNodeFailed}: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _installVersion(String version, NodeVersionManagerService service) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await service.installNodeVersion(version);
      setState(() => _newVersionInput = '');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.nodeInstalled(version))),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.nodeInstallFailed}: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _uninstallVersion(String version, NodeVersionManagerService service) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmUninstall),
        content: Text(l10n.confirmUninstallNode(version)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.uninstall),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await service.uninstallNodeVersion(version);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.nodeUninstalled(version))),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${l10n.nodeUninstallFailed}: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }
}




