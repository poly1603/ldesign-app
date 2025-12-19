import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_toolbox/data/models/npm_registry.dart';
import 'package:flutter_toolbox/providers/npm_registry_providers.dart';
import 'package:flutter_toolbox/core/utils/platform_utils.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';

/// NPM 源管理页面
class NpmPage extends ConsumerWidget {
  const NpmPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registriesAsync = ref.watch(npmRegistryNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('NPM 源管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: '刷新',
            onPressed: () {
              ref.read(npmRegistryNotifierProvider.notifier).loadRegistries();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: registriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _buildErrorState(context, e.toString()),
        data: (registries) {
          if (registries.isEmpty) {
            return _buildEmptyState(context, ref);
          }
          return _buildRegistryList(context, ref, registries);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddRegistryDialog(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('添加源'),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text('加载失败', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(error, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '暂无 NPM 源',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              '点击下方按钮添加公共源、远程私有源或本地私有源',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => _showAddRegistryDialog(context, ref),
              icon: const Icon(Icons.add_rounded),
              label: const Text('添加第一个源'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegistryList(
    BuildContext context,
    WidgetRef ref,
    List<NpmRegistry> registries,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(24).copyWith(bottom: 100),
      itemCount: registries.length,
      itemBuilder: (context, index) {
        return _buildRegistryCard(context, ref, registries[index]);
      },
    );
  }

  Widget _buildRegistryCard(
    BuildContext context,
    WidgetRef ref,
    NpmRegistry registry,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final typeColor = registry.getTypeColor(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showPackageList(context, ref, registry),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    registry.typeIcon,
                    color: typeColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            registry.name,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          if (registry.isDefault) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '默认',
                                style: TextStyle(
                                  color: colorScheme.onPrimaryContainer,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                          if (registry.type == NpmRegistryType.local &&
                              registry.isRunning == true) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    '运行中',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        registry.typeDisplayName,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: typeColor,
                            ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded),
                  onSelected: (value) {
                    switch (value) {
                      case 'setDefault':
                        _setDefaultRegistry(context, ref, registry);
                        break;
                      case 'test':
                        _testConnection(context, ref, registry);
                        break;
                      case 'login':
                        _loginToRegistry(context, ref, registry);
                        break;
                      case 'start':
                        _startVerdaccio(context, ref, registry);
                        break;
                      case 'stop':
                        _stopVerdaccio(context, ref, registry);
                        break;
                      case 'delete':
                        _deleteRegistry(context, ref, registry);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    if (!registry.isDefault)
                      const PopupMenuItem(
                        value: 'setDefault',
                        child: Row(
                          children: [
                            Icon(Icons.check_circle_outline_rounded),
                            SizedBox(width: 12),
                            Text('设为默认'),
                          ],
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'test',
                      child: Row(
                        children: [
                          Icon(Icons.network_check_rounded),
                          SizedBox(width: 12),
                          Text('测试连接'),
                        ],
                      ),
                    ),
                    if (registry.username != null && registry.password != null)
                      const PopupMenuItem(
                        value: 'login',
                        child: Row(
                          children: [
                            Icon(Icons.login_rounded),
                            SizedBox(width: 12),
                            Text('重新登录'),
                          ],
                        ),
                      ),
                    if (registry.type == NpmRegistryType.local) ...[
                      if (registry.isRunning != true)
                        const PopupMenuItem(
                          value: 'start',
                          child: Row(
                            children: [
                              Icon(Icons.play_arrow_rounded),
                              SizedBox(width: 12),
                              Text('启动服务'),
                            ],
                          ),
                        )
                      else
                        const PopupMenuItem(
                          value: 'stop',
                          child: Row(
                            children: [
                              Icon(Icons.stop_rounded),
                              SizedBox(width: 12),
                              Text('停止服务'),
                            ],
                          ),
                        ),
                    ],
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline_rounded, color: Colors.red),
                          SizedBox(width: 12),
                          Text('删除', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      registry.url,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    tooltip: '复制地址',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: registry.url));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('已复制到剪贴板')),
                      );
                    },
                  ),
                ],
              ),
            ),
            // 显示用户名或认证状态
            if (registry.username != null && registry.username!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    registry.username == '_token_' 
                        ? Icons.vpn_key_rounded 
                        : Icons.person_rounded,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    registry.username == '_token_'
                        ? '已配置 Token 认证'
                        : '登录用户: ${registry.username}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ],
            // 本地源信息
            if (registry.type == NpmRegistryType.local) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.storage_rounded,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '端口: ${registry.port ?? 4873}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (registry.pid != null) ...[
                    const SizedBox(width: 16),
                    Icon(
                      Icons.memory_rounded,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'PID: ${registry.pid}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ],
            // 点击提示
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.touch_app_rounded,
                  size: 14,
                  color: colorScheme.primary.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 6),
                Text(
                  '点击查看包列表',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary.withValues(alpha: 0.8),
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }

  void _showAddRegistryDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => _AddRegistryDialog(ref: ref),
    );
  }

  Future<void> _setDefaultRegistry(
    BuildContext context,
    WidgetRef ref,
    NpmRegistry registry,
  ) async {
    await ref.read(npmRegistryNotifierProvider.notifier).setDefaultRegistry(registry.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已将 ${registry.name} 设为默认源')),
      );
    }
  }

  Future<void> _testConnection(
    BuildContext context,
    WidgetRef ref,
    NpmRegistry registry,
  ) async {
    // 显示加载对话框
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          content: SizedBox(
            width: 200,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 20),
                Text(
                  '正在测试连接...',
                  style: Theme.of(dialogContext).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // 执行测试连接
      final success = await ref
          .read(npmRegistryNotifierProvider.notifier)
          .testConnection(registry.url)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => false,
          );

      // 关闭对话框
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        
        // 显示结果
        await Future.delayed(const Duration(milliseconds: 100));
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    success ? Icons.check_circle : Icons.error,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  Text(success ? '连接成功' : '连接失败'),
                ],
              ),
              backgroundColor: success ? Colors.green : Colors.red,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      }
    } catch (e) {
      // 关闭对话框
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        
        await Future.delayed(const Duration(milliseconds: 100));
        
        // 显示错误
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('测试失败: ${e.toString()}'),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      }
    }
  }

  Future<void> _loginToRegistry(
    BuildContext context,
    WidgetRef ref,
    NpmRegistry registry,
  ) async {
    final dialogContext = context;
    
    showDialog(
      context: dialogContext,
      barrierDismissible: false,
      builder: (BuildContext dialogCtx) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                '正在登录...',
                style: Theme.of(dialogCtx).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );

    try {
      final success = await ref
          .read(npmRegistryNotifierProvider.notifier)
          .loginToRegistry(registry);

      if (dialogContext.mounted) {
        Navigator.of(dialogContext).pop();
        
        if (dialogContext.mounted) {
          ScaffoldMessenger.of(dialogContext).showSnackBar(
            SnackBar(
              content: Text(success ? '✓ 登录成功' : '✗ 登录失败，请检查用户名和密码'),
              backgroundColor: success ? Colors.green : Colors.red,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (dialogContext.mounted) {
        Navigator.of(dialogContext).pop();
        
        if (dialogContext.mounted) {
          ScaffoldMessenger.of(dialogContext).showSnackBar(
            SnackBar(
              content: Text('登录失败: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  void _showPackageList(
    BuildContext context,
    WidgetRef ref,
    NpmRegistry registry,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NpmPackageListPage(registry: registry),
      ),
    );
  }

  Future<void> _startVerdaccio(
    BuildContext context,
    WidgetRef ref,
    NpmRegistry registry,
  ) async {
    final dialogContext = context;
    
    showDialog(
      context: dialogContext,
      barrierDismissible: false,
      builder: (BuildContext dialogCtx) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                '正在启动 Verdaccio...',
                style: Theme.of(dialogCtx).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );

    try {
      final success = await ref
          .read(npmRegistryNotifierProvider.notifier)
          .startVerdaccio(registry);

      if (dialogContext.mounted) {
        Navigator.of(dialogContext).pop();
        
        if (dialogContext.mounted) {
          ScaffoldMessenger.of(dialogContext).showSnackBar(
            SnackBar(
              content: Text(success ? '✓ Verdaccio 启动成功' : '✗ 启动失败'),
              backgroundColor: success ? Colors.green : Colors.red,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (dialogContext.mounted) {
        Navigator.of(dialogContext).pop();
        
        if (dialogContext.mounted) {
          ScaffoldMessenger.of(dialogContext).showSnackBar(
            SnackBar(
              content: Text('启动失败: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Future<void> _stopVerdaccio(
    BuildContext context,
    WidgetRef ref,
    NpmRegistry registry,
  ) async {
    final success = await ref
        .read(npmRegistryNotifierProvider.notifier)
        .stopVerdaccio(registry.id);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Verdaccio 已停止' : '停止失败'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteRegistry(
    BuildContext context,
    WidgetRef ref,
    NpmRegistry registry,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除 ${registry.name} 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(npmRegistryNotifierProvider.notifier).deleteRegistry(registry.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已删除 ${registry.name}')),
        );
      }
    }
  }
}

/// 添加源对话框
class _AddRegistryDialog extends StatefulWidget {
  final WidgetRef ref;

  const _AddRegistryDialog({required this.ref});

  @override
  State<_AddRegistryDialog> createState() => _AddRegistryDialogState();
}

class _AddRegistryDialogState extends State<_AddRegistryDialog> {
  final _formKey = GlobalKey<FormState>();
  NpmRegistryType _selectedType = NpmRegistryType.public;
  String? _selectedPreset;
  bool _showAuthFields = false; // 是否显示认证字段
  String _authType = 'none'; // 认证类型：none, npm, token
  String _authDescription = ''; // 认证说明
  bool _requiresEmail = false; // 是否需要邮箱
  
  final _nameController = TextEditingController();
  final _urlController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  final _tokenController = TextEditingController(); // Token 认证
  final _portController = TextEditingController(text: '4873');
  final _storagePathController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _tokenController.dispose();
    _portController.dispose();
    _storagePathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('添加 NPM 源'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 源类型选择
                Text(
                  '源类型',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                SegmentedButton<NpmRegistryType>(
                  segments: const [
                    ButtonSegment(
                      value: NpmRegistryType.public,
                      label: Text('公共源'),
                      icon: Icon(Icons.public_rounded),
                    ),
                    ButtonSegment(
                      value: NpmRegistryType.remote,
                      label: Text('远程私有源'),
                      icon: Icon(Icons.cloud_rounded),
                    ),
                    ButtonSegment(
                      value: NpmRegistryType.local,
                      label: Text('本地私有源'),
                      icon: Icon(Icons.computer_rounded),
                    ),
                  ],
                  selected: {_selectedType},
                  onSelectionChanged: (Set<NpmRegistryType> newSelection) {
                    setState(() {
                      _selectedType = newSelection.first;
                      _selectedPreset = null;
                      _nameController.clear();
                      _urlController.clear();
                    });
                  },
                ),
                const SizedBox(height: 16),

                // 公共源预设选择
                if (_selectedType == NpmRegistryType.public) ...[
                  Text(
                    '选择预设源',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedPreset,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: '选择一个预设源',
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('自定义'),
                      ),
                      ...PresetRegistries.publicRegistries.map((preset) {
                        return DropdownMenuItem(
                          value: preset['name'],
                          child: Text(preset['name'] as String),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedPreset = value;
                        if (value != null) {
                          final preset = PresetRegistries.publicRegistries
                              .firstWhere((p) => p['name'] == value);
                          _nameController.text = preset['name'] as String;
                          _urlController.text = preset['url'] as String;
                          
                          // 更新认证信息
                          _authType = preset['authType'] as String? ?? 'none';
                          _authDescription = preset['authDescription'] as String? ?? '';
                          _requiresEmail = preset['requiresEmail'] as bool? ?? false;
                          _showAuthFields = false; // 默认不显示，让用户选择
                          
                          // 清空认证字段
                          _usernameController.clear();
                          _passwordController.clear();
                          _emailController.clear();
                          _tokenController.clear();
                        } else {
                          _authType = 'npm'; // 自定义默认使用 npm 认证
                          _authDescription = '';
                          _requiresEmail = true;
                          _showAuthFields = false;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                // 源名称
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: '源名称 *',
                    border: OutlineInputBorder(),
                    hintText: '例如：淘宝镜像',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入源名称';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 源地址
                if (_selectedType != NpmRegistryType.local)
                  TextFormField(
                    controller: _urlController,
                    decoration: const InputDecoration(
                      labelText: '源地址 *',
                      border: OutlineInputBorder(),
                      hintText: 'https://registry.npmjs.org/',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入源地址';
                      }
                      if (!value.startsWith('http://') && !value.startsWith('https://')) {
                        return '请输入有效的 URL';
                      }
                      return null;
                    },
                  ),
                if (_selectedType != NpmRegistryType.local) const SizedBox(height: 16),

                // 认证信息（公共源和远程私有源都可以选择性填写）
                if (_selectedType != NpmRegistryType.local) ...[
                  // 认证说明和开关
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '认证信息',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            if (_authDescription.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                _authDescription,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (_authType != 'none') ...[
                        const SizedBox(width: 12),
                        Switch(
                          value: _showAuthFields,
                          onChanged: (value) {
                            setState(() {
                              _showAuthFields = value;
                              if (!value) {
                                // 清空认证字段
                                _usernameController.clear();
                                _passwordController.clear();
                                _emailController.clear();
                                _tokenController.clear();
                              }
                            });
                          },
                        ),
                      ],
                    ],
                  ),
                  
                  // 如果不支持认证，显示提示
                  if (_authType == 'none') ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 20,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '该源为只读镜像，不支持认证和发布包',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // 认证字段
                  if (_showAuthFields && _authType != 'none') ...[
                    const SizedBox(height: 12),
                    
                    // Token 认证
                    if (_authType == 'token') ...[
                      TextFormField(
                        controller: _tokenController,
                        decoration: InputDecoration(
                          labelText: 'Access Token *',
                          border: const OutlineInputBorder(),
                          hintText: '输入 Personal Access Token',
                          helperText: _selectedPreset == 'GitHub Package Registry'
                              ? '需要 read:packages 和 write:packages 权限'
                              : null,
                        ),
                        validator: (value) {
                          if (_showAuthFields && (value == null || value.isEmpty)) {
                            return '请输入 Access Token';
                          }
                          return null;
                        },
                      ),
                    ]
                    // npm 标准认证
                    else if (_authType == 'npm') ...[
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: '用户名 *',
                          border: OutlineInputBorder(),
                          hintText: '输入用户名',
                        ),
                        validator: (value) {
                          if (_showAuthFields && (value == null || value.isEmpty)) {
                            return '请输入用户名';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: '密码 *',
                          border: OutlineInputBorder(),
                          hintText: '输入密码',
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (_showAuthFields && (value == null || value.isEmpty)) {
                            return '请输入密码';
                          }
                          return null;
                        },
                      ),
                      if (_requiresEmail) ...[
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: '邮箱 *',
                            border: OutlineInputBorder(),
                            hintText: '输入邮箱',
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (_showAuthFields && _requiresEmail && (value == null || value.isEmpty)) {
                              return '请输入邮箱';
                            }
                            if (_showAuthFields && value != null && value.isNotEmpty && !value.contains('@')) {
                              return '请输入有效的邮箱地址';
                            }
                            return null;
                          },
                        ),
                      ],
                    ],
                    const SizedBox(height: 16),
                  ],
                  
                  // 远程私有源始终显示认证字段
                  if (_selectedType == NpmRegistryType.remote && !_showAuthFields) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lock_outline_rounded,
                            size: 20,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '私有源通常需要认证才能访问，建议开启认证',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ],

                // 本地私有源配置
                if (_selectedType == NpmRegistryType.local) ...[
                  Text(
                    'Verdaccio 配置',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _portController,
                    decoration: const InputDecoration(
                      labelText: '端口 *',
                      border: OutlineInputBorder(),
                      hintText: '4873',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入端口号';
                      }
                      final port = int.tryParse(value);
                      if (port == null || port < 1 || port > 65535) {
                        return '请输入有效的端口号 (1-65535)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _storagePathController,
                    decoration: InputDecoration(
                      labelText: '存储路径（可选）',
                      border: const OutlineInputBorder(),
                      hintText: '留空使用默认路径',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.folder_open_rounded),
                        tooltip: '选择文件夹',
                        onPressed: _selectStoragePath,
                      ),
                    ),
                    readOnly: true,
                    onTap: _selectStoragePath,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: _addRegistry,
          child: const Text('添加'),
        ),
      ],
    );
  }

  Future<void> _selectStoragePath() async {
    try {
      final result = await FilePicker.platform.getDirectoryPath(
        dialogTitle: '选择 Verdaccio 存储路径',
      );

      if (result != null) {
        setState(() {
          _storagePathController.text = result;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('选择文件夹失败: $e')),
        );
      }
    }
  }

  Future<void> _addRegistry() async {
    if (!_formKey.currentState!.validate()) return;

    // 显示加载对话框
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('正在添加源...'),
              ],
            ),
          ),
        ),
      ),
    );

    final uuid = const Uuid();
    
    // 处理认证信息
    String? username;
    String? password;
    String? email;
    
    if (_showAuthFields) {
      if (_authType == 'token') {
        // Token 认证：将 token 存储在 password 字段，username 设为特殊标识
        username = '_token_';
        password = _tokenController.text.trim();
      } else if (_authType == 'npm') {
        username = _usernameController.text.trim().isEmpty
            ? null
            : _usernameController.text.trim();
        password = _passwordController.text.trim().isEmpty
            ? null
            : _passwordController.text.trim();
        email = _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim();
      }
    }
    
    final registry = NpmRegistry(
      id: uuid.v4(),
      name: _nameController.text.trim(),
      url: _selectedType == NpmRegistryType.local
          ? 'http://localhost:${_portController.text.trim()}/'
          : _urlController.text.trim(),
      type: _selectedType,
      username: username,
      password: password,
      email: email,
      port: _selectedType == NpmRegistryType.local
          ? int.parse(_portController.text.trim())
          : null,
      storagePath: _storagePathController.text.trim().isEmpty
          ? null
          : _storagePathController.text.trim(),
    );

    await widget.ref.read(npmRegistryNotifierProvider.notifier).addRegistry(registry);

    // 如果提供了认证信息，自动登录
    bool loginSuccess = false;
    if (registry.username != null && 
        registry.username!.isNotEmpty && 
        registry.password != null && 
        registry.password!.isNotEmpty) {
      try {
        loginSuccess = await widget.ref
            .read(npmRegistryNotifierProvider.notifier)
            .loginToRegistry(registry);
      } catch (e) {
        debugPrint('Auto login failed: $e');
      }
    }

    if (mounted) {
      Navigator.pop(context); // 关闭加载对话框
      Navigator.pop(context); // 关闭添加对话框
      
      String message = '已添加 ${registry.name}';
      if (registry.username != null && registry.username!.isNotEmpty) {
        if (loginSuccess) {
          message += '，并已自动登录';
        } else {
          message += '，但登录失败，请稍后手动登录';
        }
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: loginSuccess || registry.username == null || registry.username!.isEmpty
              ? null
              : Colors.orange,
        ),
      );
    }
  }
}


/// NPM 包列表页面
class NpmPackageListPage extends StatefulWidget {
  final NpmRegistry registry;

  const NpmPackageListPage({super.key, required this.registry});

  @override
  State<NpmPackageListPage> createState() => _NpmPackageListPageState();
}

class _NpmPackageListPageState extends State<NpmPackageListPage> {
  List<String> _packages = [];
  Map<String, Map<String, dynamic>> _packageDetails = {}; // 存储包的详细信息
  bool _isLoading = true;
  bool _isLoadingDetails = false; // 是否正在加载详细信息
  String _searchQuery = '';
  String _sortBy = 'name'; // name, version, date
  
  // 分页相关
  static const int _pageSize = 20; // 每页加载的包数量
  int _currentPage = 0; // 当前页码
  bool _hasMore = true; // 是否还有更多数据
  final ScrollController _scrollController = ScrollController();
  
  // 缓存相关
  static final Map<String, Map<String, Map<String, dynamic>>> _detailsCache = {}; // registryId -> packageName -> details
  static final Map<String, DateTime> _cacheTimestamps = {}; // registryId -> timestamp
  static const Duration _cacheDuration = Duration(minutes: 10); // 缓存有效期 10 分钟

  @override
  void initState() {
    super.initState();
    _loadPackages();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8) {
      // 滚动到底部 80% 时加载更多
      _loadMorePackageDetails();
    }
  }

  Future<void> _loadPackages() async {
    setState(() => _isLoading = true);
    
    try {
      List<String> packages = [];
      
      // 方法1: 尝试使用 Verdaccio API 获取包列表
      packages = await _loadPackagesFromVerdaccioApi();
      
      // 方法2: 如果 API 失败，尝试使用 npm search
      if (packages.isEmpty) {
        packages = await _loadPackagesFromNpmSearch();
      }
      
      // 排序包列表
      packages.sort();
      
      setState(() {
        _packages = packages;
        _isLoading = false;
      });
      
      // 检查缓存是否有效
      final registryId = widget.registry.id;
      final cacheTimestamp = _cacheTimestamps[registryId];
      final isCacheValid = cacheTimestamp != null && 
          DateTime.now().difference(cacheTimestamp) < _cacheDuration;
      
      if (isCacheValid && _detailsCache.containsKey(registryId)) {
        // 使用缓存
        setState(() {
          _packageDetails = Map.from(_detailsCache[registryId]!);
          _hasMore = false; // 缓存已全部加载
        });
      } else {
        // 分页加载第一页的包详细信息
        _currentPage = 0;
        _hasMore = true;
        _loadMorePackageDetails();
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }
  
  /// 分页加载更多包的详细信息
  Future<void> _loadMorePackageDetails() async {
    if (_isLoadingDetails || !_hasMore) return;
    
    setState(() {
      _isLoadingDetails = true;
    });
    
    final startIndex = _currentPage * _pageSize;
    final endIndex = (startIndex + _pageSize).clamp(0, _packages.length);
    
    if (startIndex >= _packages.length) {
      setState(() {
        _isLoadingDetails = false;
        _hasMore = false;
      });
      return;
    }
    
    final packagesToLoad = _packages.sublist(startIndex, endIndex);
    
    for (final packageName in packagesToLoad) {
      try {
        final details = await _fetchPackageInfo(packageName);
        if (mounted && details != null) {
          setState(() {
            _packageDetails[packageName] = details;
          });
        }
      } catch (e) {
        // 忽略单个包的加载失败
        debugPrint('Failed to load details for $packageName: $e');
      }
    }
    
    // 保存到缓存
    if (mounted) {
      final registryId = widget.registry.id;
      _detailsCache[registryId] = Map.from(_packageDetails);
      _cacheTimestamps[registryId] = DateTime.now();
      
      setState(() {
        _currentPage++;
        _hasMore = endIndex < _packages.length;
        _isLoadingDetails = false;
      });
    }
  }
  
  /// 异步加载包的详细信息（全量加载，用于刷新）
  Future<void> _loadPackageDetails(List<String> packages, {bool useCache = true}) async {
    setState(() {
      _isLoadingDetails = true;
      if (!useCache) {
        _packageDetails.clear();
        _currentPage = 0;
        _hasMore = true;
      }
    });
    
    for (final packageName in packages) {
      try {
        final details = await _fetchPackageInfo(packageName);
        if (mounted && details != null) {
          setState(() {
            _packageDetails[packageName] = details;
          });
        }
      } catch (e) {
        // 忽略单个包的加载失败
        debugPrint('Failed to load details for $packageName: $e');
      }
    }
    
    // 保存到缓存
    if (mounted) {
      final registryId = widget.registry.id;
      _detailsCache[registryId] = Map.from(_packageDetails);
      _cacheTimestamps[registryId] = DateTime.now();
      
      setState(() {
        _isLoadingDetails = false;
        _hasMore = false;
      });
    }
  }
  
  /// 刷新包详细信息
  Future<void> _refreshPackageDetails() async {
    if (_packages.isEmpty) return;
    
    // 显示确认对话框
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('刷新包详细信息'),
        content: const Text('将重新获取所有包的最新信息，这可能需要一些时间。确定继续吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('刷新'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      await _loadPackageDetails(_packages, useCache: false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('包详细信息已更新'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
  
  /// 获取单个包的信息
  Future<Map<String, dynamic>?> _fetchPackageInfo(String packageName) async {
    try {
      final baseUrl = widget.registry.url.endsWith('/')
          ? widget.registry.url.substring(0, widget.registry.url.length - 1)
          : widget.registry.url;
      final apiUrl = '$baseUrl/${Uri.encodeComponent(packageName)}';

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: _getAuthHeaders(),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final latestVersion = data['dist-tags']?['latest'] ?? data['version'];
        final versions = data['versions'] as Map<String, dynamic>?;
        final versionInfo = versions?[latestVersion] ?? data;
        final timeMap = data['time'] as Map<String, dynamic>?;
        
        // 提取关键信息
        return {
          'name': packageName,
          'version': latestVersion,
          'description': versionInfo['description'] ?? data['description'],
          'author': _extractAuthor(versionInfo['author'] ?? data['author']),
          'license': versionInfo['license'] ?? data['license'],
          'keywords': versionInfo['keywords'] ?? data['keywords'],
          'versionCount': versions?.length ?? 1,
          'created': timeMap?['created'],
          'modified': timeMap?['modified'] ?? timeMap?[latestVersion],
        };
      }
    } catch (e) {
      debugPrint('Error fetching package info for $packageName: $e');
    }
    return null;
  }
  
  String? _extractAuthor(dynamic author) {
    if (author == null) return null;
    if (author is String) return author;
    if (author is Map && author['name'] != null) return author['name'];
    return null;
  }

  /// 从 Verdaccio API 获取包列表
  Future<List<String>> _loadPackagesFromVerdaccioApi() async {
    final baseUrl = widget.registry.url.endsWith('/')
        ? widget.registry.url.substring(0, widget.registry.url.length - 1)
        : widget.registry.url;
    
    // 如果有登录用户，优先获取该用户发布的包
    if (widget.registry.username != null && widget.registry.username!.isNotEmpty) {
      try {
        final userPackages = await _loadUserPackages(baseUrl);
        if (userPackages.isNotEmpty) {
          return userPackages;
        }
      } catch (e) {
        debugPrint('Error loading user packages: $e');
        // 如果获取用户包失败，继续尝试获取所有包
      }
    }
    
    // 方法1: 尝试 Verdaccio 的 data/packages 端点（只返回本地发布的包）
    try {
      final apiUrl = '$baseUrl/-/verdaccio/data/packages';
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: _getAuthHeaders(),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final dynamic packagesData = jsonDecode(response.body);
        if (packagesData is List) {
          final packages = packagesData
              .map((p) {
                if (p is Map<String, dynamic> && p.containsKey('name')) {
                  return p['name'] as String;
                }
                return null;
              })
              .whereType<String>()
              .toList();
          if (packages.isNotEmpty) {
            return packages;
          }
        } else if (packagesData is Map) {
          // 如果返回的是 Map，检查是否有 packages 数组
          if (packagesData.containsKey('packages') && packagesData['packages'] is List) {
            final packagesList = packagesData['packages'] as List;
            final packages = packagesList
                .map((p) {
                  if (p is Map<String, dynamic> && p.containsKey('name')) {
                    return p['name'] as String;
                  }
                  return null;
                })
                .whereType<String>()
                .toList();
            if (packages.isNotEmpty) {
              return packages;
            }
          }
          // 否则尝试将 keys 作为包名
          final packages = packagesData.keys
              .where((key) => key != '_updated' && !key.startsWith('_'))
              .toList()
              .cast<String>();
          if (packages.isNotEmpty) {
            return packages;
          }
        }
      }
    } catch (e) {
      // 打印错误信息用于调试
      debugPrint('Error loading from /-/verdaccio/data/packages: $e');
    }
    
    // 方法2: 尝试 Verdaccio 的 packages 端点（只返回本地发布的包）
    try {
      final apiUrl = '$baseUrl/-/verdaccio/packages';
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: _getAuthHeaders(),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final dynamic packagesData = jsonDecode(response.body);
        if (packagesData is List) {
          final packages = packagesData.map((p) => p['name'] as String).toList();
          if (packages.isNotEmpty) {
            return packages;
          }
        } else if (packagesData is Map) {
          final packages = packagesData.keys.toList().cast<String>();
          if (packages.isNotEmpty) {
            return packages;
          }
        }
      }
    } catch (e) {
      // 继续尝试其他方法
    }
    
    // 方法3: 尝试使用 /-/all 端点，但只获取本地包
    // 注意：这个端点会返回所有包（包括代理的），需要过滤
    try {
      final apiUrl = '$baseUrl/-/all';
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: _getAuthHeaders(),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        // 过滤出本地包：检查 _attachments 字段或其他标识
        final packages = <String>[];
        for (var entry in data.entries) {
          final key = entry.key;
          if (key == '_updated' || key.startsWith('_')) continue;
          
          final value = entry.value;
          if (value is Map<String, dynamic>) {
            // 检查是否有本地版本信息
            // Verdaccio 本地包通常会有 versions 字段
            if (value.containsKey('versions') && value['versions'] is Map) {
              packages.add(key);
            }
          }
        }
        if (packages.isNotEmpty) {
          return packages;
        }
      }
    } catch (e) {
      // 继续尝试其他方法
    }
    
    // 方法4: 尝试 /-/v1/search 端点（npm registry v1 search API）
    // 使用 from=0 参数来限制只返回本地包
    try {
      final apiUrl = '$baseUrl/-/v1/search?text=&size=250&from=0';
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: _getAuthHeaders(),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic>? objects = data['objects'];
        if (objects != null && objects.isNotEmpty) {
          return objects
              .map((obj) => obj['package']['name'] as String)
              .toList();
        }
      }
    } catch (e) {
      // API 调用失败
    }
    
    return [];
  }

  /// 获取当前登录用户发布的包
  Future<List<String>> _loadUserPackages(String baseUrl) async {
    final username = widget.registry.username;
    if (username == null || username.isEmpty) {
      return [];
    }

    // 方法1: 尝试使用 npm search 搜索用户的包
    try {
      final searchUrl = '$baseUrl/-/v1/search?text=maintainer:$username&size=250';
      final response = await http.get(
        Uri.parse(searchUrl),
        headers: _getAuthHeaders(),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final objects = data['objects'] as List<dynamic>?;
        if (objects != null && objects.isNotEmpty) {
          return objects
              .map((obj) => obj['package']['name'] as String)
              .toList();
        }
      }
    } catch (e) {
      debugPrint('Error searching user packages: $e');
    }

    // 方法2: 获取所有包，然后过滤出用户的包
    try {
      final allPackagesUrl = '$baseUrl/-/all';
      final response = await http.get(
        Uri.parse(allPackagesUrl),
        headers: _getAuthHeaders(),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final userPackages = <String>[];
        
        for (var entry in data.entries) {
          final key = entry.key;
          if (key == '_updated' || key.startsWith('_')) continue;
          
          final value = entry.value;
          if (value is Map<String, dynamic>) {
            // 检查维护者信息
            final maintainers = value['maintainers'] as List<dynamic>?;
            if (maintainers != null) {
              final hasUser = maintainers.any((m) {
                if (m is Map<String, dynamic>) {
                  return m['name'] == username;
                }
                return false;
              });
              if (hasUser) {
                userPackages.add(key);
              }
            }
          }
        }
        
        if (userPackages.isNotEmpty) {
          return userPackages;
        }
      }
    } catch (e) {
      debugPrint('Error filtering user packages: $e');
    }

    return [];
  }

  /// 获取认证头（如果有用户名和密码）
  Map<String, String> _getAuthHeaders() {
    final headers = <String, String>{
      'Accept': 'application/json',
    };
    
    if (widget.registry.username != null && widget.registry.password != null) {
      final auth = base64Encode(
        utf8.encode('${widget.registry.username}:${widget.registry.password}'),
      );
      headers['Authorization'] = 'Basic $auth';
    }
    
    return headers;
  }

  /// 从 npm search 获取包列表（使用通配符）
  Future<List<String>> _loadPackagesFromNpmSearch() async {
    try {
      // 方法1: 尝试使用 npm search 搜索所有包（某些源支持）
      final result = await PlatformUtils.runCommand(
        'npm',
        arguments: ['search', '.', '--json', '--registry', widget.registry.url],
      );

      if (result.success && result.output != null && result.output!.trim().isNotEmpty) {
        try {
          final List<dynamic> packages = jsonDecode(result.output!);
          if (packages.isNotEmpty) {
            return packages.map((p) => p['name'] as String).toList();
          }
        } catch (e) {
          // JSON 解析失败，继续尝试其他方法
        }
      }
    } catch (e) {
      // 搜索失败，继续尝试其他方法
    }
    
    // 方法2: 尝试使用 npm view 获取包信息（适用于已知包名的情况）
    // 这个方法不适用于获取所有包列表，所以跳过
    
    return [];
  }

  List<String> get _filteredPackages {
    if (_searchQuery.isEmpty) return _packages;
    return _packages
        .where((pkg) => pkg.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final typeColor = widget.registry.getTypeColor(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.registry.name),
            Text(
              '${_packages.length} 个包',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: '刷新',
            onPressed: _loadPackages,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // 用户信息提示
          if (widget.registry.username != null && widget.registry.username!.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                border: Border(
                  bottom: BorderSide(
                    color: colorScheme.outlineVariant,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    widget.registry.username == '_token_' 
                        ? Icons.vpn_key_rounded 
                        : Icons.person_rounded,
                    size: 20,
                    color: colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.registry.username == '_token_'
                          ? '已使用 Token 认证'
                          : '当前登录用户: ${widget.registry.username}',
                      style: TextStyle(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    widget.registry.username == '_token_'
                        ? '显示已认证的包'
                        : '显示该用户发布的包',
                    style: TextStyle(
                      color: colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          // 搜索栏和排序
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: colorScheme.outlineVariant,
                ),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: '搜索包...',
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded),
                                  onPressed: () => setState(() => _searchQuery = ''),
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        onChanged: (value) => setState(() => _searchQuery = value),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: colorScheme.outline),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButton<String>(
                        value: _sortBy,
                        underline: const SizedBox(),
                        icon: const Icon(Icons.sort_rounded),
                        items: const [
                          DropdownMenuItem(
                            value: 'name',
                            child: Row(
                              children: [
                                Icon(Icons.sort_by_alpha_rounded, size: 18),
                                SizedBox(width: 8),
                                Text('按名称'),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'version',
                            child: Row(
                              children: [
                                Icon(Icons.tag_rounded, size: 18),
                                SizedBox(width: 8),
                                Text('按版本'),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'modified',
                            child: Row(
                              children: [
                                Icon(Icons.update_rounded, size: 18),
                                SizedBox(width: 8),
                                Text('按更新时间'),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'created',
                            child: Row(
                              children: [
                                Icon(Icons.add_circle_outline_rounded, size: 18),
                                SizedBox(width: 8),
                                Text('按创建时间'),
                              ],
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _sortBy = value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // 只在加载中时显示进度
                    if (_isLoadingDetails) ...[
                      Icon(
                        Icons.info_outline_rounded,
                        size: 14,
                        color: colorScheme.primary.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '正在加载包详细信息...',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.primary.withValues(alpha: 0.8),
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_packageDetails.length}/${_packages.length}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ] else ...[
                      // 加载完成后显示刷新按钮
                      Icon(
                        Icons.check_circle_rounded,
                        size: 14,
                        color: Colors.green.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '已加载 ${_packageDetails.length} 个包的详细信息',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: _refreshPackageDetails,
                        icon: const Icon(Icons.refresh_rounded, size: 16),
                        label: const Text('刷新详细信息'),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // 包列表
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _packages.isEmpty
                    ? _buildEmptyState(context)
                    : _buildPackageList(context, typeColor),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final hasUser = widget.registry.username != null && widget.registry.username!.isNotEmpty;
    
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasUser ? Icons.person_off_rounded : Icons.inventory_2_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              hasUser ? '该用户暂无发布的包' : '暂无包',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              hasUser
                  ? '用户 ${widget.registry.username} 还没有发布任何包到该源'
                  : '该源中还没有发布任何包，或者无法获取包列表',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _loadPackages,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('重新加载'),
            ),
            if (!hasUser) ...[
              const SizedBox(height: 12),
              Text(
                '提示：某些私有源可能需要特殊的 API 配置才能获取包列表',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPackageList(BuildContext context, Color typeColor) {
    final filteredPackages = _filteredPackages;
    final primaryColor = Theme.of(context).colorScheme.primary;

    if (filteredPackages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              '未找到匹配的包',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    // 排序包列表
    final sortedPackages = List<String>.from(filteredPackages);
    sortedPackages.sort((a, b) {
      final detailsA = _packageDetails[a];
      final detailsB = _packageDetails[b];
      
      switch (_sortBy) {
        case 'name':
          return a.compareTo(b);
        case 'version':
          if (detailsA == null && detailsB == null) return 0;
          if (detailsA == null) return 1;
          if (detailsB == null) return -1;
          final versionA = detailsA['version'] ?? '';
          final versionB = detailsB['version'] ?? '';
          return versionB.compareTo(versionA);
        case 'modified':
          if (detailsA == null && detailsB == null) return 0;
          if (detailsA == null) return 1;
          if (detailsB == null) return -1;
          final modifiedA = detailsA['modified'] ?? '';
          final modifiedB = detailsB['modified'] ?? '';
          return modifiedB.compareTo(modifiedA);
        case 'created':
          if (detailsA == null && detailsB == null) return 0;
          if (detailsA == null) return 1;
          if (detailsB == null) return -1;
          final createdA = detailsA['created'] ?? '';
          final createdB = detailsB['created'] ?? '';
          return createdB.compareTo(createdA);
        default:
          return a.compareTo(b);
      }
    });

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: sortedPackages.length + (_hasMore && _isLoadingDetails ? 1 : 0),
      itemBuilder: (context, index) {
        // 显示加载指示器
        if (index == sortedPackages.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        final packageName = sortedPackages[index];
        final details = _packageDetails[packageName];
        final isLoading = details == null;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => _navigateToPackageDetail(context, packageName),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.inventory_2_rounded,
                          color: primaryColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    packageName,
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (!isLoading && details['version'] != null) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: primaryColor.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'v${details['version']}',
                                      style: TextStyle(
                                        color: primaryColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            if (isLoading) ...[
                              const SizedBox(height: 4),
                              SizedBox(
                                height: 12,
                                width: 12,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ] else if (details['description'] != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                details['description'],
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy_rounded, size: 18),
                        tooltip: '复制包名',
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: packageName));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('已复制到剪贴板')),
                          );
                        },
                      ),
                    ],
                  ),
                  if (!isLoading) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      children: [
                        if (details['author'] != null)
                          _buildInfoChip(
                            context,
                            Icons.person_rounded,
                            details['author'],
                            primaryColor,
                          ),
                        if (details['license'] != null)
                          _buildInfoChip(
                            context,
                            Icons.gavel_rounded,
                            details['license'],
                            primaryColor.withValues(alpha: 0.8),
                          ),
                        if (details['versionCount'] != null)
                          _buildInfoChip(
                            context,
                            Icons.history_rounded,
                            '${details['versionCount']} 个版本',
                            primaryColor.withValues(alpha: 0.6),
                          ),
                      ],
                    ),
                    if (details['created'] != null || details['modified'] != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (details['created'] != null) ...[
                            Icon(
                              Icons.add_circle_outline_rounded,
                              size: 14,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '创建: ${_formatDate(details['created'])}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                          if (details['created'] != null && details['modified'] != null)
                            const SizedBox(width: 16),
                          if (details['modified'] != null) ...[
                            Icon(
                              Icons.update_rounded,
                              size: 14,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '更新: ${_formatDate(details['modified'])}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ],
                    if (details['keywords'] != null && details['keywords'] is List) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: (details['keywords'] as List).take(5).map((keyword) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              keyword.toString(),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontSize: 11,
                                  ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildInfoChip(BuildContext context, IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
  
  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }

  void _navigateToPackageDetail(BuildContext context, String packageName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NpmPackageDetailPage(
          packageName: packageName,
          registry: widget.registry,
        ),
      ),
    );
  }

}

/// NPM 包详情页面
class NpmPackageDetailPage extends StatefulWidget {
  final String packageName;
  final NpmRegistry registry;

  const NpmPackageDetailPage({
    super.key,
    required this.packageName,
    required this.registry,
  });

  @override
  State<NpmPackageDetailPage> createState() => _NpmPackageDetailPageState();
}

class _NpmPackageDetailPageState extends State<NpmPackageDetailPage>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _packageInfo;
  String? _readme;
  bool _isLoading = true;
  String? _error;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadPackageInfo();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPackageInfo() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // 方法1: 使用 Verdaccio API
      final baseUrl = widget.registry.url.endsWith('/')
          ? widget.registry.url.substring(0, widget.registry.url.length - 1)
          : widget.registry.url;
      final apiUrl = '$baseUrl/${Uri.encodeComponent(widget.packageName)}';

      final headers = <String, String>{
        'Accept': 'application/json',
      };
      
      if (widget.registry.username != null && widget.registry.password != null) {
        final auth = base64Encode(
          utf8.encode('${widget.registry.username}:${widget.registry.password}'),
        );
        headers['Authorization'] = 'Basic $auth';
      }

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final packageData = jsonDecode(response.body);
        setState(() {
          _packageInfo = packageData;
          _isLoading = false;
        });
        
        // 加载 README
        _loadReadme(packageData);
        return;
      }
    } catch (e) {
      // API 失败，尝试 npm view
    }

    // 方法2: 使用 npm view 命令
    try {
      final result = await PlatformUtils.runCommand(
        'npm',
        arguments: ['view', widget.packageName, '--json', '--registry', widget.registry.url],
      );

      if (result.success && result.output != null) {
        final packageData = jsonDecode(result.output!);
        setState(() {
          _packageInfo = packageData;
          _isLoading = false;
        });
        
        // 加载 README
        _loadReadme(packageData);
      } else {
        setState(() {
          _error = '获取包信息失败';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = '错误: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadReadme(Map<String, dynamic> packageData) async {
    try {
      // 尝试从包数据中获取 README
      if (packageData.containsKey('readme')) {
        setState(() {
          _readme = packageData['readme'];
        });
        return;
      }

      // 尝试从最新版本中获取 README
      final latestVersion = packageData['dist-tags']?['latest'] ?? packageData['version'];
      final versions = packageData['versions'] as Map<String, dynamic>?;
      final latestVersionInfo = versions?[latestVersion];
      
      if (latestVersionInfo != null && latestVersionInfo['readme'] != null) {
        setState(() {
          _readme = latestVersionInfo['readme'];
        });
      }
    } catch (e) {
      // README 加载失败，不影响主要功能
      debugPrint('Failed to load README: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = widget.registry.getTypeColor(context);

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState(context)
              : _buildPackageDetail(context, typeColor),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            _error!,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _loadPackageInfo,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('重试'),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageDetail(BuildContext context, Color typeColor) {
    if (_packageInfo == null) return const SizedBox();

    final latestVersion = _packageInfo!['dist-tags']?['latest'] ?? _packageInfo!['version'];
    final versions = _packageInfo!['versions'] as Map<String, dynamic>?;
    final latestVersionInfo = versions?[latestVersion] ?? _packageInfo!;

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          // App Bar
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildPackageHeader(context, typeColor, latestVersion, latestVersionInfo),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                tooltip: '刷新',
                onPressed: _loadPackageInfo,
              ),
              IconButton(
                icon: const Icon(Icons.copy_rounded),
                tooltip: '复制包名',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: widget.packageName));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('已复制到剪贴板')),
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          // Tab Bar
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverTabBarDelegate(
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(icon: Icon(Icons.description_rounded), text: 'README'),
                  Tab(icon: Icon(Icons.info_rounded), text: '详情'),
                  Tab(icon: Icon(Icons.history_rounded), text: '版本'),
                  Tab(icon: Icon(Icons.download_rounded), text: '安装'),
                ],
              ),
            ),
          ),
        ];
      },
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReadmeTab(context),
          _buildDetailsTab(context, latestVersionInfo, typeColor),
          _buildVersionsTab(context, versions, typeColor),
          _buildInstallTab(context, typeColor),
        ],
      ),
    );
  }



  Widget _buildSectionTitle(BuildContext context, String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDependenciesCard(BuildContext context, Map<String, dynamic> dependencies) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: dependencies.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    entry.key,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  entry.value,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // 新的标签页构建方法
  Widget _buildReadmeTab(BuildContext context) {
    if (_readme == null || _readme!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              '暂无 README',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return Markdown(
      data: _readme!,
      selectable: true,
      onTapLink: (text, href, title) {
        if (href != null) {
          launchUrl(Uri.parse(href));
        }
      },
      styleSheet: MarkdownStyleSheet(
        p: Theme.of(context).textTheme.bodyMedium,
        h1: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
        h2: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
        h3: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
        code: TextStyle(
          fontFamily: 'monospace',
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        codeblockDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildDetailsTab(BuildContext context, Map<String, dynamic> versionInfo, Color typeColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 描述卡片
          if (versionInfo['description'] != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    typeColor.withValues(alpha: 0.1),
                    typeColor.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: typeColor.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.description_rounded,
                        color: typeColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '包描述',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: typeColor,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    versionInfo['description'],
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          height: 1.5,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // 基本信息网格
          _buildSectionTitle(context, '基本信息'),
          const SizedBox(height: 16),
          _buildInfoGrid(context, typeColor, [
            if (versionInfo['license'] != null)
              _buildInfoGridItem(
                context,
                Icons.gavel_rounded,
                '许可证',
                versionInfo['license'],
                Colors.blue,
              ),
            if (versionInfo['author'] != null)
              _buildInfoGridItem(
                context,
                Icons.person_rounded,
                '作者',
                versionInfo['author'] is String
                    ? versionInfo['author']
                    : versionInfo['author']['name'] ?? '-',
                Colors.purple,
              ),
            if (versionInfo['version'] != null)
              _buildInfoGridItem(
                context,
                Icons.tag_rounded,
                '当前版本',
                versionInfo['version'],
                Colors.green,
              ),
          ]),
          const SizedBox(height: 24),

          // 关键词标签
          if (versionInfo['keywords'] != null && versionInfo['keywords'] is List) ...[
            _buildSectionTitle(context, '关键词'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (versionInfo['keywords'] as List).map((keyword) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: typeColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    keyword.toString(),
                    style: TextStyle(
                      color: typeColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],

          // 链接卡片
          if (versionInfo['homepage'] != null ||
              versionInfo['repository'] != null ||
              versionInfo['bugs'] != null) ...[
            _buildSectionTitle(context, '相关链接'),
            const SizedBox(height: 12),
            Column(
              children: [
                if (versionInfo['homepage'] != null)
                  _buildLinkCard(
                    context,
                    Icons.home_rounded,
                    '项目主页',
                    versionInfo['homepage'],
                    Colors.blue,
                  ),
                if (versionInfo['repository'] != null)
                  _buildLinkCard(
                    context,
                    Icons.code_rounded,
                    '源代码仓库',
                    versionInfo['repository'] is String
                        ? versionInfo['repository']
                        : versionInfo['repository']['url'] ?? '-',
                    Colors.orange,
                  ),
                if (versionInfo['bugs'] != null)
                  _buildLinkCard(
                    context,
                    Icons.bug_report_rounded,
                    'Issues',
                    versionInfo['bugs'] is String
                        ? versionInfo['bugs']
                        : versionInfo['bugs']['url'] ?? '-',
                    Colors.red,
                  ),
              ],
            ),
            const SizedBox(height: 24),
          ],

          // 依赖部分
          if (versionInfo['dependencies'] != null) ...[
            _buildDependencySection(
              context,
              '生产依赖',
              versionInfo['dependencies'],
              Icons.inventory_2_rounded,
              Colors.green,
            ),
            const SizedBox(height: 24),
          ],

          if (versionInfo['devDependencies'] != null) ...[
            _buildDependencySection(
              context,
              '开发依赖',
              versionInfo['devDependencies'],
              Icons.build_rounded,
              Colors.orange,
            ),
            const SizedBox(height: 24),
          ],

          if (versionInfo['peerDependencies'] != null) ...[
            _buildDependencySection(
              context,
              'Peer 依赖',
              versionInfo['peerDependencies'],
              Icons.people_rounded,
              Colors.purple,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVersionsTab(BuildContext context, Map<String, dynamic>? versions, Color typeColor) {
    if (versions == null || versions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              '暂无版本信息',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    final versionList = versions.keys.toList()..sort((a, b) => b.compareTo(a));
    final timeMap = _packageInfo!['time'] as Map<String, dynamic>?;

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: versionList.length,
      itemBuilder: (context, index) {
        final version = versionList[index];
        final versionData = versions[version];
        final isLatest = version == _packageInfo!['dist-tags']?['latest'];
        final publishTime = timeMap?[version];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isLatest
                  ? typeColor.withValues(alpha: 0.3)
                  : Theme.of(context).colorScheme.outlineVariant,
              width: isLatest ? 2 : 1,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: isLatest
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          typeColor.withValues(alpha: 0.3),
                          typeColor.withValues(alpha: 0.1),
                        ],
                      )
                    : null,
                color: isLatest ? null : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isLatest ? Icons.star_rounded : Icons.tag_rounded,
                color: isLatest ? typeColor : Theme.of(context).colorScheme.onSurfaceVariant,
                size: 24,
              ),
            ),
            title: Row(
              children: [
                Text(
                  version,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: isLatest ? typeColor : null,
                  ),
                ),
                if (isLatest) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          typeColor.withValues(alpha: 0.3),
                          typeColor.withValues(alpha: 0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'LATEST',
                      style: TextStyle(
                        color: typeColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            subtitle: publishTime != null
                ? Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '发布于 ${_formatDate(publishTime)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  )
                : null,
            trailing: IconButton(
              icon: const Icon(Icons.copy_rounded, size: 20),
              tooltip: '复制版本号',
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: version));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('已复制到剪贴板')),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildInstallTab(BuildContext context, Color typeColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(context, '安装命令'),
          const SizedBox(height: 16),
          _buildInstallCommands(context),
          const SizedBox(height: 32),
          _buildSectionTitle(context, '使用说明'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '1. 选择合适的包管理器执行上方安装命令',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  '2. 在项目中导入并使用该包',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  '3. 查看 README 标签页了解详细使用方法',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageHeader(
    BuildContext context,
    Color typeColor,
    String? version,
    Map<String, dynamic> versionInfo,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            typeColor.withValues(alpha: 0.3),
            typeColor.withValues(alpha: 0.1),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.inventory_2_rounded,
                    color: typeColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.packageName,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                              color: Colors.white,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (version != null) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'v$version',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (versionInfo['description'] != null) ...[
              const SizedBox(height: 12),
              Text(
                versionInfo['description'],
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLinkRow(BuildContext context, String label, String url) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () => launchUrl(Uri.parse(url)),
              child: Text(
                url,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      decoration: TextDecoration.underline,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }

  Widget _buildInstallCommands(BuildContext context) {
    final commands = [
      'npm install ${widget.packageName} --registry ${widget.registry.url}',
      'yarn add ${widget.packageName} --registry ${widget.registry.url}',
      'pnpm add ${widget.packageName} --registry ${widget.registry.url}',
    ];

    return Column(
      children: commands.map((cmd) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: SelectableText(
                  cmd,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy_rounded, size: 18),
                tooltip: '复制命令',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: cmd));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('已复制到剪贴板')),
                  );
                },
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // 新的辅助构建方法
  Widget _buildInfoGrid(BuildContext context, Color typeColor, List<Widget> items) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: items,
    );
  }

  Widget _buildInfoGridItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkCard(
    BuildContext context,
    IconData icon,
    String label,
    String url,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            try {
              launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('无法打开链接: $e')),
              );
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        url,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.open_in_new_rounded,
                  size: 20,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDependencySection(
    BuildContext context,
    String title,
    Map<String, dynamic> dependencies,
    IconData icon,
    Color color,
  ) {
    final depCount = dependencies.length;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$depCount',
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: dependencies.entries.map((entry) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant,
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.key,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        entry.value.toString(),
                        style: TextStyle(
                          fontFamily: 'monospace',
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// TabBar Delegate for SliverPersistentHeader
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}
