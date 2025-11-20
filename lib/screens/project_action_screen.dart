import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'dart:convert';
import '../l10n/app_localizations.dart';
import '../models/project.dart';
import '../providers/app_provider.dart';
import '../services/project_service_manager.dart';

class ProjectActionScreen extends StatefulWidget {
  final String projectId;
  final String action;

  const ProjectActionScreen({
    super.key,
    required this.projectId,
    required this.action,
  });

  @override
  State<ProjectActionScreen> createState() => _ProjectActionScreenState();
}

class _ProjectActionScreenState extends State<ProjectActionScreen> with TickerProviderStateMixin {
  Environment _selectedEnvironment = Environment.development;
  final ScrollController _logScrollController = ScrollController();
  late AnimationController _cursorAnimationController;

  @override
  void initState() {
    super.initState();
    _cursorAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _logScrollController.dispose();
    _cursorAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final appProvider = context.watch<AppProvider>();
    
    // 鏌ユ壘椤圭洰
    final project = appProvider.allProjects.firstWhere(
      (p) => p.id == widget.projectId,
      orElse: () => throw Exception('Project not found'),
    );

    return ChangeNotifierProvider.value(
      value: ProjectServiceManager(),
      child: Consumer<ProjectServiceManager>(
        builder: (context, serviceManager, child) {
          final serviceInfo = serviceManager.getServiceInfo(widget.projectId, widget.action);
          final actionInfo = _getActionInfo(widget.action, l10n);

          return Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                color: Colors.white,
                child: Row(
                  children: [
                    // 杩斿洖鎸夐挳
                    IconButton(
                      icon: const Icon(Bootstrap.arrow_left, size: 20),
                      onPressed: () => appProvider.setCurrentRoute('/project-detail', params: {'projectId': widget.projectId}),
                      tooltip: l10n.back,
                    ),
                    const SizedBox(width: 12),
                    // 椤圭洰淇℃伅
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            project.name,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            actionInfo.label,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: actionInfo.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // 鎺у埗鍖哄煙锛堢Щ鍒板彸渚э級
                    Flexible(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // 鐜閫夋嫨
                          _buildEnvironmentSelector(theme),
                          const SizedBox(width: 8),
                          // 鎿嶄綔鎸夐挳
                          _buildActionButton(context, theme, serviceInfo, actionInfo, project, serviceManager),
                          // 鏈嶅姟鍦板潃鎸夐挳锛堝彧鏈夎繍琛屼腑鎵嶆樉绀猴級
                          if (serviceInfo?.status == ServiceStatus.running && serviceInfo?.url != null) ...[
                            const SizedBox(width: 8),
                            _buildServiceUrlButton(context, theme, serviceInfo!.url!),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // 鍛戒护琛岀獥鍙ｅ尯鍩?
              Expanded(
                child: Consumer<AppProvider>(
                  builder: (context, appProvider, child) {
                    final isTerminalDarkTheme = appProvider.terminalDarkTheme;
                    final isLogDisplayDarkTheme = appProvider.logDisplayDarkTheme;
                    final windowBg = isLogDisplayDarkTheme ? const Color(0xFF0C0C0C) : const Color(0xFFF5F5F5);
                    final titleBarBg = isTerminalDarkTheme ? const Color(0xFF2D2D30) : const Color(0xFFE1E1E1);
                    
                    return Container(
                      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      decoration: BoxDecoration(
                        color: windowBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade400, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 绐楀彛鏍囬鏍忥紙妯℃嫙鐪熷疄绯荤粺锛?
                      Container(
                        height: 32,
                        decoration: BoxDecoration(
                          color: titleBarBg,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 12),
                            // 绐楀彛鍥炬爣
                            Icon(
                              Bootstrap.terminal,
                              size: 14,
                              color: isTerminalDarkTheme ? Colors.grey.shade300 : Colors.grey.shade700,
                            ),
                            const SizedBox(width: 8),
                            // 绐楀彛鏍囬
                            Text(
                              isTerminalDarkTheme ? 'Windows PowerShell' : 'Command Prompt',
                              style: TextStyle(
                                fontSize: 12,
                                color: isTerminalDarkTheme ? Colors.grey.shade300 : Colors.grey.shade700,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const Spacer(),
                            // 鏃ュ織鎿嶄綔鎸夐挳
                            Row(
                              children: [
                                // 娓呯┖鏃ュ織鎸夐挳
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(4),
                                    onTap: () => _clearLogs(serviceManager),
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      child: Icon(
                                        Bootstrap.trash,
                                        size: 12,
                                        color: isTerminalDarkTheme ? Colors.grey.shade300 : Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                // 瀵煎嚭鏃ュ織鎸夐挳
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(4),
                                    onTap: () => _exportLogs(serviceInfo?.logs ?? []),
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      child: Icon(
                                        Bootstrap.download,
                                        size: 12,
                                        color: isTerminalDarkTheme ? Colors.grey.shade300 : Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                            ),
                            // 绐楀彛鎺у埗鎸夐挳
                            Row(
                              children: [
                                _buildWindowButton(Icons.minimize, Colors.grey.shade400),
                                _buildWindowButton(Icons.crop_square, Colors.grey.shade400),
                                _buildWindowButton(Icons.close, Colors.red.shade400),
                              ],
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ),
                      // 鍛戒护琛屽唴瀹瑰尯鍩?
                      Expanded(
                        child: _buildTerminalArea(serviceInfo?.logs ?? [], project.path),
                      ),
                    ],
                  ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // 鑾峰彇鎿嶄綔淇℃伅
  _ActionInfo _getActionInfo(String action, AppLocalizations l10n) {
    switch (action) {
      case 'start':
        return _ActionInfo(l10n.startProject, Bootstrap.play_fill, Colors.green);
      case 'build':
        return _ActionInfo(l10n.buildProject, Bootstrap.hammer, Colors.blue);
      case 'preview':
        return _ActionInfo(l10n.previewProject, Bootstrap.eye, Colors.purple);
      case 'deploy':
        return _ActionInfo(l10n.deployProject, Bootstrap.cloud_upload, Colors.orange);
      case 'publish':
        return _ActionInfo(l10n.publishProject, Bootstrap.box_arrow_up, Colors.teal);
      case 'test':
        return _ActionInfo(l10n.testProject, Bootstrap.check_circle, Colors.green);
      default:
        return _ActionInfo('未知操作', Bootstrap.question_circle, Colors.grey);
    }
  }

  // 鏋勫缓鐜閫夋嫨鍣?
  Widget _buildEnvironmentSelector(ThemeData theme) {
    return IntrinsicWidth(
      child: Container(
        height: 36,
        constraints: const BoxConstraints(minWidth: 80),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(6),
          color: Colors.white,
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<Environment>(
            value: _selectedEnvironment,
            isExpanded: true,
            onChanged: (Environment? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedEnvironment = newValue;
                });
              }
            },
            items: Environment.values.map<DropdownMenuItem<Environment>>((Environment value) {
              return DropdownMenuItem<Environment>(
                value: value,
                child: Text(
                  _getEnvironmentLabel(value),
                  style: const TextStyle(fontSize: 14),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  // 获取环境标签
  String _getEnvironmentLabel(Environment env) {
    final l10n = AppLocalizations.of(context)!;
    switch (env) {
      case Environment.development:
        return l10n.developmentEnv;
      case Environment.staging:
        return l10n.stagingEnv;
      case Environment.production:
        return l10n.productionEnv;
    }
  }

  // 鏋勫缓鎿嶄綔鎸夐挳
  Widget _buildActionButton(
    BuildContext context,
    ThemeData theme,
    ServiceInfo? serviceInfo,
    _ActionInfo actionInfo,
    Project project,
    ProjectServiceManager serviceManager,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final isRunning = serviceInfo?.status == ServiceStatus.running;
    final isStarting = serviceInfo?.status == ServiceStatus.starting;
    final isStopping = serviceInfo?.status == ServiceStatus.stopping;
    final hasError = serviceInfo?.status == ServiceStatus.error;

    // 对于构建操作，不需要停止按钮
    if (widget.action == 'build') {
      return SizedBox(
        height: 36, // 减小高度
        child: ElevatedButton.icon(
          onPressed: isStarting ? null : () => _startAction(serviceManager, project),
          icon: isStarting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(actionInfo.icon, size: 18),
          label: Text(isStarting ? l10n.building : l10n.startBuild),
          style: ElevatedButton.styleFrom(
            backgroundColor: actionInfo.color,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
      );
    }

    // 瀵逛簬鍚姩鍜岄瑙堟搷浣滐紝鏀寔鍚姩/鍋滄鍒囨崲
    return SizedBox(
      height: 36,
      child: ElevatedButton.icon(
        onPressed: (isStarting || isStopping) ? null : () {
          if (isRunning) {
            _stopAction(serviceManager);
          } else {
            _startAction(serviceManager, project);
          }
        },
        icon: (isStarting || isStopping)
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(
                isRunning ? Bootstrap.stop_fill : actionInfo.icon,
                size: 18,
              ),
        label: Text(_getButtonLabel(isRunning, isStarting, isStopping, hasError)),
        style: ElevatedButton.styleFrom(
          backgroundColor: isRunning ? Colors.red : actionInfo.color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
    );
  }

  // 获取按钮标签
  String _getButtonLabel(bool isRunning, bool isStarting, bool isStopping, bool hasError) {
    final l10n = AppLocalizations.of(context)!;
    if (hasError) return l10n.retry;
    if (isStopping) return l10n.stopping;
    if (isStarting) {
      switch (widget.action) {
        case 'start':
          return l10n.starting;
        case 'preview':
          return l10n.previewing;
        default:
          return l10n.processing;
      }
    }
    if (isRunning) return l10n.stopService;
    
    switch (widget.action) {
      case 'start':
        return l10n.startDevServer;
      case 'preview':
        return l10n.startPreviewServer;
      default:
        return l10n.start;
    }
  }


  // 鏋勫缓鏈嶅姟鍦板潃鎸夐挳
  Widget _buildServiceUrlButton(BuildContext context, ThemeData theme, String url) {
    return Container(
      height: 36,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _showServiceUrlDialog(context, url),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.green.shade400,
                  Colors.green.shade600,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.shade200,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Bootstrap.globe,
                  size: 15,
                  color: Colors.white,
                ),
                const SizedBox(width: 6),
                Text(
                  AppLocalizations.of(context)!.serviceUrl,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Bootstrap.chevron_down,
                  size: 10,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 鏄剧ず鏈嶅姟鍦板潃瀵硅瘽妗?
  void _showServiceUrlDialog(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 鏍囬
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green.shade400, Colors.green.shade600],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Bootstrap.globe,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    '服务地址',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // 鍦板潃鍒楄〃
              _buildUrlCard('鏈湴璁块棶', url, Bootstrap.laptop, Colors.blue),
              const SizedBox(height: 12),
              FutureBuilder<String>(
                future: _getNetworkUrl(url),
                builder: (context, snapshot) {
                  final networkUrl = snapshot.data ?? url;
                  return Column(
                    children: [
                      _buildUrlCard('灞€鍩熺綉璁块棶', networkUrl, Bootstrap.wifi, Colors.orange),
                      const SizedBox(height: 20),
                      // 浜岀淮鐮?
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: QrImageView(
                                data: networkUrl,
                                version: QrVersions.auto,
                                size: 120,
                                backgroundColor: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '鎵爜璁块棶',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 鏋勫缓鏈嶅姟鍦板潃寮圭獥鍐呭锛堝凡寮冪敤锛屼繚鐣欎互闃茬紪璇戦敊璇級
  Widget _buildServiceUrlPopup(String url) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '服务地址',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 12),
          // 鏈湴鍦板潃
          _buildUrlItem('鏈湴璁块棶', url, Bootstrap.laptop),
          const SizedBox(height: 8),
          // 灞€鍩熺綉鍦板潃
          FutureBuilder<String>(
            future: _getNetworkUrl(url),
            builder: (context, snapshot) {
              final networkUrl = snapshot.data ?? url;
              return Column(
                children: [
                  _buildUrlItem('灞€鍩熺綉璁块棶', networkUrl, Bootstrap.wifi),
                  const SizedBox(height: 12),
                  // 浜岀淮鐮?
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      children: [
                        QrImageView(
                          data: networkUrl,
                          version: QrVersions.auto,
                          size: 120,
                          backgroundColor: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '鎵爜璁块棶',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // 鏋勫缓URL鍗＄墖
  Widget _buildUrlCard(String label, String url, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  url,
                  style: TextStyle(
                    fontSize: 13,
                    color: color,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(6),
                  onTap: () => _copyUrl(url),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Bootstrap.clipboard,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(6),
                  onTap: () => _openUrl(url),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Bootstrap.box_arrow_up_right,
                      size: 16,
                      color: Colors.grey.shade600,
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

  // 鏋勫缓URL椤圭洰锛堟棫鐗堟湰锛屼繚鐣欎互闃茬紪璇戦敊璇級
  Widget _buildUrlItem(String label, String url, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.blue.shade600),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              url,
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue.shade600,
                fontFamily: 'monospace',
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () => _copyUrl(url),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Bootstrap.clipboard,
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              InkWell(
                onTap: () => _openUrl(url),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Bootstrap.box_arrow_up_right,
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 鑾峰彇缃戠粶鍦板潃
  Future<String> _getNetworkUrl(String localUrl) async {
    try {
      final interfaces = await NetworkInterface.list();
      for (final interface in interfaces) {
        for (final addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
            final uri = Uri.parse(localUrl);
            return 'http://${addr.address}:${uri.port}';
          }
        }
      }
    } catch (e) {
      // 濡傛灉鑾峰彇澶辫触锛岃繑鍥炲師鍦板潃
    }
    return localUrl;
  }

  // 澶嶅埗URL
  void _copyUrl(String url) {
    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('宸插鍒跺埌鍓创鏉? $url'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // 鎵撳紑URL
  void _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  // 鏋勫缓绐楀彛鎺у埗鎸夐挳
  Widget _buildWindowButton(IconData icon, Color color) {
    return Container(
      width: 24,
      height: 24,
      margin: const EdgeInsets.only(left: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(2),
          onTap: icon == Icons.close ? () => _clearLogs(ProjectServiceManager()) : null,
          child: Icon(
            icon,
            size: 12,
            color: color,
          ),
        ),
      ),
    );
  }

  // 鏋勫缓缁堢鍖哄煙
  Widget _buildTerminalArea(List<String> logs, String projectPath) {
    final appProvider = context.watch<AppProvider>();
    final isTerminalDarkTheme = appProvider.terminalDarkTheme;
    final isLogDisplayDarkTheme = appProvider.logDisplayDarkTheme;
    // 褰撴棩蹇楁洿鏂版椂鑷姩婊氬姩鍒板簳閮?
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_logScrollController.hasClients && logs.isNotEmpty) {
        _logScrollController.animateTo(
          _logScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    // 瀹氫箟涓婚棰滆壊 - 浣跨敤鏃ュ織灞曠ず涓婚璁剧疆
    final backgroundColor = isLogDisplayDarkTheme ? const Color(0xFF0C0C0C) : const Color(0xFFF5F5F5);
    final textColor = isLogDisplayDarkTheme ? Colors.white : const Color(0xFF333333);
    final promptColor = isLogDisplayDarkTheme ? Colors.yellow.shade300 : Colors.blue.shade700;
    final infoColor = isLogDisplayDarkTheme ? Colors.grey.shade400 : Colors.grey.shade600;
    final cursorColor = isLogDisplayDarkTheme ? Colors.white : const Color(0xFF333333);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 鏄剧ず褰撳墠璺緞锛堟ā鎷熺湡瀹炲懡浠よ锛?
          if (logs.isEmpty) ...[
            Text(
              isLogDisplayDarkTheme ? 'Windows PowerShell' : 'Command Prompt',
              style: TextStyle(
                fontFamily: 'Consolas',
                fontSize: 13,
                color: infoColor,
                height: 1.4,
              ),
            ),
            Text(
              'Copyright (C) Microsoft Corporation. All rights reserved.',
              style: TextStyle(
                fontFamily: 'Consolas',
                fontSize: 13,
                color: infoColor,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: isLogDisplayDarkTheme ? 'PS ' : 'C:\\>',
                    style: TextStyle(
                      fontFamily: 'Consolas',
                      fontSize: 13,
                      color: promptColor,
                      height: 1.4,
                    ),
                  ),
                  if (isLogDisplayDarkTheme) ...[
                    TextSpan(
                      text: projectPath,
                      style: TextStyle(
                        fontFamily: 'Consolas',
                        fontSize: 13,
                        color: textColor,
                        height: 1.4,
                      ),
                    ),
                    TextSpan(
                      text: '> ',
                      style: TextStyle(
                        fontFamily: 'Consolas',
                        fontSize: 13,
                        color: promptColor,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
          // 鏃ュ織鍐呭
          Expanded(
            child: SingleChildScrollView(
              controller: _logScrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (logs.isNotEmpty) ...[
                    // 鏄剧ず鍛戒护鎻愮ず绗﹀拰璺緞
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: isLogDisplayDarkTheme ? 'PS ' : 'C:\\>',
                            style: TextStyle(
                              fontFamily: 'Consolas',
                              fontSize: 13,
                              color: promptColor,
                              height: 1.4,
                            ),
                          ),
                          if (isLogDisplayDarkTheme) ...[
                            TextSpan(
                              text: projectPath,
                              style: TextStyle(
                                fontFamily: 'Consolas',
                                fontSize: 13,
                                color: textColor,
                                height: 1.4,
                              ),
                            ),
                            TextSpan(
                              text: '> ',
                              style: TextStyle(
                                fontFamily: 'Consolas',
                                fontSize: 13,
                                color: promptColor,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // 鏄剧ず鏃ュ織
                    SelectableText(
                      logs.join('\n'),
                      style: TextStyle(
                        fontFamily: 'Consolas',
                        fontSize: 13,
                        color: textColor,
                        height: 1.4,
                      ),
                    ),
                  ],
                  // 鍏夋爣锛堟ā鎷熺湡瀹炲懡浠よ锛?
                  AnimatedBuilder(
                    animation: _cursorAnimationController,
                    builder: (context, child) {
                      return Container(
                        width: 8,
                        height: 16,
                        margin: const EdgeInsets.only(top: 4),
                        decoration: BoxDecoration(
                          color: cursorColor.withValues(alpha: _cursorAnimationController.value),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 鍚姩鎿嶄綔
  void _startAction(ProjectServiceManager serviceManager, Project project) {
    serviceManager.startService(
      widget.projectId,
      project.path,
      widget.action,
      _selectedEnvironment,
      (log) {
        serviceManager.addLog(widget.projectId, widget.action, log);
        // 鑷姩婊氬姩鍒板簳閮?
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_logScrollController.hasClients) {
            _logScrollController.animateTo(
              _logScrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      },
    );
  }

  // 鍋滄鎿嶄綔
  void _stopAction(ProjectServiceManager serviceManager) {
    serviceManager.stopService(widget.projectId, widget.action);
  }

  // 娓呯┖鏃ュ織
  void _clearLogs(ProjectServiceManager serviceManager) {
    serviceManager.addLog(widget.projectId, widget.action, '');
  }

  // 瀵煎嚭鏃ュ織
  void _exportLogs(List<String> logs) async {
    if (logs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('当前没有可导出的日志'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      // 鐢熸垚鏃ュ織鍐呭
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final projectName = widget.projectId.split('/').last;
      final fileName = '${projectName}_${widget.action}_$timestamp.log';
      
      final logContent = [
        '# ${projectName} - ${widget.action} 日志',
        '# 导出时间: ${DateTime.now()}',
        '# ==========================================',
        '',
        ...logs,
      ].join('\n');

      // 使用文件选择器保存日志文件
      final result = await FilePicker.platform.saveFile(
        dialogTitle: '导出日志文件',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['log', 'txt'],
      );

      if (result != null) {
        final file = File(result);
        await file.writeAsString(logContent, encoding: utf8);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('日志已导出到: ${result}'),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('导出失败: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

}

// 鎿嶄綔淇℃伅鏁版嵁绫?
class _ActionInfo {
  final String label;
  final IconData icon;
  final Color color;

  _ActionInfo(this.label, this.icon, this.color);
}
