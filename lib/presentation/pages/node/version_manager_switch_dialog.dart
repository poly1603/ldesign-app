import 'package:flutter/material.dart';
import 'package:flutter_toolbox/data/models/node_version_manager.dart';
import 'package:flutter_toolbox/data/services/node_migration_service.dart';

/// 版本管理工具切换对话框
class VersionManagerSwitchDialog extends StatefulWidget {
  final NodeVersionManagerType? currentTool;

  const VersionManagerSwitchDialog({
    super.key,
    this.currentTool,
  });

  @override
  State<VersionManagerSwitchDialog> createState() => _VersionManagerSwitchDialogState();
}

class _VersionManagerSwitchDialogState extends State<VersionManagerSwitchDialog> {
  final _service = NodeMigrationService();
  NodeVersionManagerType? _selectedTool;
  bool _isProcessing = false;
  final List<String> _logs = [];
  String? _currentStep;
  bool _completed = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _selectedTool = widget.currentTool == NodeVersionManagerType.nvm
        ? NodeVersionManagerType.fnm
        : NodeVersionManagerType.volta;
  }

  void _addLog(String message) {
    setState(() {
      _logs.add('[${DateTime.now().toString().substring(11, 19)}] $message');
    });
  }

  Future<void> _startMigration() async {
    if (_selectedTool == null) return;

    setState(() {
      _isProcessing = true;
      _logs.clear();
      _hasError = false;
      _completed = false;
    });

    try {
      // 步骤 1: 检测当前工具
      setState(() => _currentStep = '检测当前环境');
      _addLog('开始迁移流程...');
      
      final currentTool = await _service.detectCurrentTool();
      _addLog('当前工具: ${currentTool?.displayName ?? '无'}');

      // 步骤 2: 保存当前状态
      setState(() => _currentStep = '保存当前状态');
      final currentVersion = await _service.getCurrentNodeVersion();
      _addLog('当前 Node 版本: ${currentVersion ?? '未检测到'}');

      final installedVersions = await _service.getInstalledVersions(currentTool);
      _addLog('已安装版本: ${installedVersions.length} 个');

      final globalPackages = await _service.getGlobalPackages();
      _addLog('全局包: ${globalPackages.length} 个');

      // 保存迁移状态
      final state = MigrationState(
        fromTool: currentTool,
        toTool: _selectedTool!,
        currentNodeVersion: currentVersion,
        installedVersions: installedVersions,
        globalPackages: globalPackages,
        timestamp: DateTime.now(),
      );
      await _service.saveMigrationState(state);
      _addLog('状态已保存');

      // 步骤 3: 卸载当前工具
      if (currentTool != null) {
        setState(() => _currentStep = '卸载 ${currentTool.displayName}');
        final uninstalled = await _service.uninstallTool(currentTool, _addLog);
        if (!uninstalled) {
          throw Exception('卸载失败');
        }
      }

      // 步骤 4: 安装新工具
      setState(() => _currentStep = '安装 ${_selectedTool!.displayName}');
      final installed = await _service.installTool(_selectedTool!, _addLog);
      if (!installed) {
        if (_selectedTool == NodeVersionManagerType.nvm) {
          _addLog('请手动安装 NVM for Windows 后重新运行此工具');
        }
        throw Exception('安装失败');
      }

      // 步骤 5: 恢复 Node 版本
      setState(() => _currentStep = '恢复 Node 版本');
      if (installedVersions.isNotEmpty) {
        _addLog('开始恢复 ${installedVersions.length} 个版本...');
        
        for (final version in installedVersions) {
          final success = await _service.installNodeVersion(_selectedTool!, version, _addLog);
          if (!success) {
            _addLog('警告: 版本 $version 安装失败');
          }
        }
      }

      // 步骤 6: 切换到之前的版本
      if (currentVersion != null) {
        setState(() => _currentStep = '切换到 v$currentVersion');
        await _service.switchNodeVersion(_selectedTool!, currentVersion, _addLog);
      }

      // 完成
      setState(() {
        _currentStep = '完成';
        _completed = true;
      });
      _addLog('✅ 迁移完成！');
      _addLog('请重启终端使环境变量生效');

      // 清除迁移状态
      await _service.clearMigrationState();
    } catch (e) {
      setState(() {
        _hasError = true;
        _currentStep = '失败';
      });
      _addLog('❌ 错误: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      child: Container(
        width: 700,
        height: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Row(
              children: [
                Icon(Icons.swap_horiz_rounded, color: colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  '切换版本管理工具',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _isProcessing ? null : () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 当前工具信息
            if (widget.currentTool != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '当前工具',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            widget.currentTool!.displayName,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 工具选择
            if (!_isProcessing && !_completed) ...[
              Text(
                '选择目标工具',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              ...NodeVersionManagerType.values.map((tool) {
                if (tool == widget.currentTool) return const SizedBox.shrink();
                
                return RadioListTile<NodeVersionManagerType>(
                  value: tool,
                  groupValue: _selectedTool,
                  onChanged: (value) => setState(() => _selectedTool = value),
                  title: Text(tool.displayName),
                  subtitle: Text(tool.description),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              }),
              const SizedBox(height: 24),
            ],

            // 当前步骤
            if (_currentStep != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _hasError
                      ? colorScheme.errorContainer
                      : _completed
                          ? colorScheme.primaryContainer
                          : colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    if (_isProcessing)
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.onSecondaryContainer,
                        ),
                      )
                    else if (_completed)
                      Icon(Icons.check_circle, color: colorScheme.primary, size: 20)
                    else if (_hasError)
                      Icon(Icons.error, color: colorScheme.error, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      _currentStep!,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: _hasError
                            ? colorScheme.onErrorContainer
                            : _completed
                                ? colorScheme.onPrimaryContainer
                                : colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 日志输出
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  itemCount: _logs.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        _logs[index],
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: Colors.greenAccent,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 操作按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!_isProcessing && !_completed)
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('取消'),
                  ),
                const SizedBox(width: 12),
                if (!_isProcessing && !_completed)
                  FilledButton.icon(
                    onPressed: _selectedTool == null ? null : _startMigration,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('开始迁移'),
                  ),
                if (_completed)
                  FilledButton.icon(
                    onPressed: () => Navigator.pop(context, true),
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('完成'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
