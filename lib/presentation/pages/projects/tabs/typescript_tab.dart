import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_toolbox/data/models/project.dart';
import 'package:path/path.dart' as path;

/// TypeScript 配置 Tab
class TypeScriptTab extends StatefulWidget {
  final Project project;

  const TypeScriptTab({super.key, required this.project});

  @override
  State<TypeScriptTab> createState() => _TypeScriptTabState();
}

class _TypeScriptTabState extends State<TypeScriptTab> {
  bool _isTypeScriptEnabled = false;
  bool _isLoading = true;
  Map<String, dynamic>? _tsConfig;
  String? _currentVersion; // 当前 TypeScript 版本
  List<String> _availableVersions = []; // 可用版本列表

  // TypeScript 配置选项 - 基础
  String _target = 'ES2020';
  String _module = 'ESNext';
  String _moduleResolution = 'node';
  String _jsx = 'react-jsx';
  String? _lib;
  String? _outDir;
  String? _rootDir;
  String? _baseUrl;
  // List<String> _paths = []; // 暂未使用
  
  // 严格模式选项
  bool _strict = true;
  bool _noImplicitAny = true;
  bool _strictNullChecks = true;
  bool _strictFunctionTypes = true;
  bool _strictBindCallApply = true;
  bool _strictPropertyInitialization = true;
  bool _noImplicitThis = true;
  bool _alwaysStrict = true;
  
  // 额外检查
  bool _noUnusedLocals = false;
  bool _noUnusedParameters = false;
  bool _noImplicitReturns = false;
  bool _noFallthroughCasesInSwitch = false;
  bool _noUncheckedIndexedAccess = false;
  bool _noImplicitOverride = false;
  bool _noPropertyAccessFromIndexSignature = false;
  
  // 模块选项
  bool _esModuleInterop = true;
  bool _allowSyntheticDefaultImports = true;
  bool _resolveJsonModule = true;
  bool _isolatedModules = true;
  
  // 输出选项
  bool _declaration = false;
  bool _declarationMap = false;
  bool _sourceMap = false;
  bool _inlineSourceMap = false;
  bool _removeComments = false;
  bool _importHelpers = false;
  bool _downlevelIteration = false;
  
  // 其他选项
  bool _skipLibCheck = true;
  bool _forceConsistentCasingInFileNames = true;
  bool _allowJs = false;
  bool _checkJs = false;
  bool _incremental = false;
  bool _composite = false;
  bool _experimentalDecorators = false;
  bool _emitDecoratorMetadata = false;

  @override
  void initState() {
    super.initState();
    _checkTypeScript();
    _loadAvailableVersions();
  }

  Future<void> _loadAvailableVersions() async {
    // 获取可用的 TypeScript 版本
    _availableVersions = [
      '5.7.2',
      '5.6.3',
      '5.5.4',
      '5.4.5',
      '5.3.3',
      '5.2.2',
      '5.1.6',
      '5.0.4',
      '4.9.5',
      '4.8.4',
      '4.7.4',
    ];
  }

  Future<void> _getCurrentVersion() async {
    try {
      final packageJsonPath = path.join(widget.project.path, 'package.json');
      final file = File(packageJsonPath);
      
      if (await file.exists()) {
        final content = await file.readAsString();
        final packageJson = jsonDecode(content) as Map<String, dynamic>;
        final devDeps = packageJson['devDependencies'] as Map<String, dynamic>?;
        
        if (devDeps != null && devDeps.containsKey('typescript')) {
          final version = devDeps['typescript'] as String;
          setState(() {
            _currentVersion = version.replaceAll('^', '').replaceAll('~', '');
          });
        }
      }
    } catch (e) {
      debugPrint('Error getting TypeScript version: $e');
    }
  }

  Future<void> _checkTypeScript() async {
    setState(() => _isLoading = true);

    try {
      final tsConfigPath = path.join(widget.project.path, 'tsconfig.json');
      final file = File(tsConfigPath);

      if (await file.exists()) {
        final content = await file.readAsString();
        final config = jsonDecode(content);
        setState(() {
          _isTypeScriptEnabled = true;
          _tsConfig = config;
          _loadConfigValues(config);
        });
        await _getCurrentVersion();
      } else {
        setState(() => _isTypeScriptEnabled = false);
      }
    } catch (e) {
      debugPrint('Error checking TypeScript: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _loadConfigValues(Map<String, dynamic> config) {
    final compilerOptions = config['compilerOptions'] as Map<String, dynamic>?;
    if (compilerOptions == null) return;
    
    // 基础选项
    _target = compilerOptions['target'] ?? _target;
    _module = compilerOptions['module'] ?? _module;
    _moduleResolution = compilerOptions['moduleResolution'] ?? _moduleResolution;
    _jsx = compilerOptions['jsx'] ?? _jsx;
    _lib = compilerOptions['lib']?.toString();
    _outDir = compilerOptions['outDir'];
    _rootDir = compilerOptions['rootDir'];
    _baseUrl = compilerOptions['baseUrl'];
    
    // 严格模式
    _strict = compilerOptions['strict'] ?? _strict;
    _noImplicitAny = compilerOptions['noImplicitAny'] ?? _noImplicitAny;
    _strictNullChecks = compilerOptions['strictNullChecks'] ?? _strictNullChecks;
    _strictFunctionTypes = compilerOptions['strictFunctionTypes'] ?? _strictFunctionTypes;
    _strictBindCallApply = compilerOptions['strictBindCallApply'] ?? _strictBindCallApply;
    _strictPropertyInitialization = compilerOptions['strictPropertyInitialization'] ?? _strictPropertyInitialization;
    _noImplicitThis = compilerOptions['noImplicitThis'] ?? _noImplicitThis;
    _alwaysStrict = compilerOptions['alwaysStrict'] ?? _alwaysStrict;
    
    // 额外检查
    _noUnusedLocals = compilerOptions['noUnusedLocals'] ?? _noUnusedLocals;
    _noUnusedParameters = compilerOptions['noUnusedParameters'] ?? _noUnusedParameters;
    _noImplicitReturns = compilerOptions['noImplicitReturns'] ?? _noImplicitReturns;
    _noFallthroughCasesInSwitch = compilerOptions['noFallthroughCasesInSwitch'] ?? _noFallthroughCasesInSwitch;
    _noUncheckedIndexedAccess = compilerOptions['noUncheckedIndexedAccess'] ?? _noUncheckedIndexedAccess;
    _noImplicitOverride = compilerOptions['noImplicitOverride'] ?? _noImplicitOverride;
    _noPropertyAccessFromIndexSignature = compilerOptions['noPropertyAccessFromIndexSignature'] ?? _noPropertyAccessFromIndexSignature;
    
    // 模块选项
    _esModuleInterop = compilerOptions['esModuleInterop'] ?? _esModuleInterop;
    _allowSyntheticDefaultImports = compilerOptions['allowSyntheticDefaultImports'] ?? _allowSyntheticDefaultImports;
    _resolveJsonModule = compilerOptions['resolveJsonModule'] ?? _resolveJsonModule;
    _isolatedModules = compilerOptions['isolatedModules'] ?? _isolatedModules;
    
    // 输出选项
    _declaration = compilerOptions['declaration'] ?? _declaration;
    _declarationMap = compilerOptions['declarationMap'] ?? _declarationMap;
    _sourceMap = compilerOptions['sourceMap'] ?? _sourceMap;
    _inlineSourceMap = compilerOptions['inlineSourceMap'] ?? _inlineSourceMap;
    _removeComments = compilerOptions['removeComments'] ?? _removeComments;
    _importHelpers = compilerOptions['importHelpers'] ?? _importHelpers;
    _downlevelIteration = compilerOptions['downlevelIteration'] ?? _downlevelIteration;
    
    // 其他选项
    _skipLibCheck = compilerOptions['skipLibCheck'] ?? _skipLibCheck;
    _forceConsistentCasingInFileNames = compilerOptions['forceConsistentCasingInFileNames'] ?? _forceConsistentCasingInFileNames;
    _allowJs = compilerOptions['allowJs'] ?? _allowJs;
    _checkJs = compilerOptions['checkJs'] ?? _checkJs;
    _incremental = compilerOptions['incremental'] ?? _incremental;
    _composite = compilerOptions['composite'] ?? _composite;
    _experimentalDecorators = compilerOptions['experimentalDecorators'] ?? _experimentalDecorators;
    _emitDecoratorMetadata = compilerOptions['emitDecoratorMetadata'] ?? _emitDecoratorMetadata;
  }

  Future<void> _enableTypeScript() async {
    try {
      // 创建 tsconfig.json
      final tsConfigPath = path.join(widget.project.path, 'tsconfig.json');
      final defaultConfig = _buildConfigObject();

      await File(tsConfigPath).writeAsString(
        const JsonEncoder.withIndent('  ').convert(defaultConfig),
      );

      // 安装 TypeScript（使用最新版本）
      await Process.run(
        'npm',
        ['install', '--save-dev', 'typescript@latest', '@types/node'],
        workingDirectory: widget.project.path,
        runInShell: true,
      );

      await _checkTypeScript();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✓ TypeScript 已启用')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('启用失败: $e')),
        );
      }
    }
  }
  
  Future<void> _changeTypeScriptVersion(String version) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('切换 TypeScript 版本'),
        content: Text('将切换到 TypeScript $version，这将修改 package.json 并重新安装依赖。确定继续吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('切换'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // 显示加载对话框
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('正在切换版本...'),
              ],
            ),
          ),
        );
      }

      // 更新 package.json
      final packageJsonPath = path.join(widget.project.path, 'package.json');
      final file = File(packageJsonPath);
      final content = await file.readAsString();
      final packageJson = jsonDecode(content) as Map<String, dynamic>;
      
      packageJson['devDependencies'] ??= {};
      (packageJson['devDependencies'] as Map<String, dynamic>)['typescript'] = '^$version';
      
      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(packageJson),
      );

      // 重新安装依赖
      await Process.run(
        'npm',
        ['install'],
        workingDirectory: widget.project.path,
        runInShell: true,
      );
      
      // 根据版本更新 tsconfig.json 配置
      await _updateConfigForVersion(version);

      await _getCurrentVersion();

      if (mounted) {
        Navigator.of(context).pop(); // 关闭加载对话框
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✓ 已切换到 TypeScript $version')),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // 关闭加载对话框
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('切换失败: $e')),
        );
      }
    }
  }
  
  Future<void> _updateConfigForVersion(String version) async {
    // 根据 TypeScript 版本调整配置
    final majorVersion = int.tryParse(version.split('.').first) ?? 5;
    
    // TypeScript 5.0+ 支持的新特性
    if (majorVersion >= 5) {
      // 可以使用所有最新特性
    } else if (majorVersion >= 4) {
      // TypeScript 4.x 不支持某些 5.x 特性
      _noUncheckedIndexedAccess = false;
      _noImplicitOverride = false;
      _noPropertyAccessFromIndexSignature = false;
    }
    
    await _saveConfig();
  }

  Future<void> _disableTypeScript() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('禁用 TypeScript'),
        content: const Text('这将删除 tsconfig.json 文件，但不会卸载 TypeScript 包。确定继续吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('禁用'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final tsConfigPath = path.join(widget.project.path, 'tsconfig.json');
      await File(tsConfigPath).delete();

      await _checkTypeScript();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✓ TypeScript 已禁用')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('禁用失败: $e')),
        );
      }
    }
  }

  Map<String, dynamic> _buildConfigObject() {
    final compilerOptions = <String, dynamic>{
      'target': _target,
      'module': _module,
      'moduleResolution': _moduleResolution,
      'jsx': _jsx,
    };
    
    // 添加可选的基础选项
    if (_lib != null) compilerOptions['lib'] = _lib;
    if (_outDir != null) compilerOptions['outDir'] = _outDir;
    if (_rootDir != null) compilerOptions['rootDir'] = _rootDir;
    if (_baseUrl != null) compilerOptions['baseUrl'] = _baseUrl;
    
    // 严格模式
    compilerOptions['strict'] = _strict;
    if (!_strict) {
      // 如果不是严格模式，单独设置各项
      compilerOptions['noImplicitAny'] = _noImplicitAny;
      compilerOptions['strictNullChecks'] = _strictNullChecks;
      compilerOptions['strictFunctionTypes'] = _strictFunctionTypes;
      compilerOptions['strictBindCallApply'] = _strictBindCallApply;
      compilerOptions['strictPropertyInitialization'] = _strictPropertyInitialization;
      compilerOptions['noImplicitThis'] = _noImplicitThis;
      compilerOptions['alwaysStrict'] = _alwaysStrict;
    }
    
    // 额外检查
    if (_noUnusedLocals) compilerOptions['noUnusedLocals'] = true;
    if (_noUnusedParameters) compilerOptions['noUnusedParameters'] = true;
    if (_noImplicitReturns) compilerOptions['noImplicitReturns'] = true;
    if (_noFallthroughCasesInSwitch) compilerOptions['noFallthroughCasesInSwitch'] = true;
    if (_noUncheckedIndexedAccess) compilerOptions['noUncheckedIndexedAccess'] = true;
    if (_noImplicitOverride) compilerOptions['noImplicitOverride'] = true;
    if (_noPropertyAccessFromIndexSignature) compilerOptions['noPropertyAccessFromIndexSignature'] = true;
    
    // 模块选项
    compilerOptions['esModuleInterop'] = _esModuleInterop;
    if (_allowSyntheticDefaultImports) compilerOptions['allowSyntheticDefaultImports'] = true;
    compilerOptions['resolveJsonModule'] = _resolveJsonModule;
    compilerOptions['isolatedModules'] = _isolatedModules;
    
    // 输出选项
    if (_declaration) compilerOptions['declaration'] = true;
    if (_declarationMap) compilerOptions['declarationMap'] = true;
    if (_sourceMap) compilerOptions['sourceMap'] = true;
    if (_inlineSourceMap) compilerOptions['inlineSourceMap'] = true;
    if (_removeComments) compilerOptions['removeComments'] = true;
    if (_importHelpers) compilerOptions['importHelpers'] = true;
    if (_downlevelIteration) compilerOptions['downlevelIteration'] = true;
    
    // 其他选项
    compilerOptions['skipLibCheck'] = _skipLibCheck;
    compilerOptions['forceConsistentCasingInFileNames'] = _forceConsistentCasingInFileNames;
    if (_allowJs) compilerOptions['allowJs'] = true;
    if (_checkJs) compilerOptions['checkJs'] = true;
    if (_incremental) compilerOptions['incremental'] = true;
    if (_composite) compilerOptions['composite'] = true;
    if (_experimentalDecorators) compilerOptions['experimentalDecorators'] = true;
    if (_emitDecoratorMetadata) compilerOptions['emitDecoratorMetadata'] = true;
    
    return {
      'compilerOptions': compilerOptions,
      'include': _tsConfig?['include'] ?? ['src'],
      'exclude': _tsConfig?['exclude'] ?? ['node_modules'],
    };
  }

  Future<void> _saveConfig() async {
    try {
      final tsConfigPath = path.join(widget.project.path, 'tsconfig.json');
      final config = _buildConfigObject();

      await File(tsConfigPath).writeAsString(
        const JsonEncoder.withIndent('  ').convert(config),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✓ 配置已保存')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_isTypeScriptEnabled) {
      return _buildEnablePrompt(context);
    }

    return _buildConfigEditor(context);
  }

  Widget _buildEnablePrompt(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
                color: Colors.blue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.code,
                size: 64,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'TypeScript 未启用',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'TypeScript 为 JavaScript 添加了类型系统，提供更好的开发体验和代码质量',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _enableTypeScript,
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('启用 TypeScript'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigEditor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 状态卡片
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_circle, color: Colors.green),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TypeScript 已启用',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _currentVersion != null 
                                  ? '当前版本: $_currentVersion'
                                  : 'tsconfig.json 配置文件已存在',
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton(
                        onPressed: _disableTypeScript,
                        child: const Text('禁用'),
                      ),
                    ],
                  ),
                  if (_currentVersion != null) ...[
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.swap_horiz, size: 20),
                        const SizedBox(width: 8),
                        const Text('切换版本:', style: TextStyle(fontWeight: FontWeight.w500)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _availableVersions.contains(_currentVersion) ? _currentVersion : null,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            items: _availableVersions.map((version) {
                              return DropdownMenuItem(
                                value: version,
                                child: Text('TypeScript $version'),
                              );
                            }).toList(),
                            onChanged: (version) {
                              if (version != null && version != _currentVersion) {
                                _changeTypeScriptVersion(version);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // 基础编译选项
          Text(
            '基础编译选项',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildDropdownField(
                    label: 'Target',
                    value: _target,
                    items: ['ES3', 'ES5', 'ES6', 'ES2015', 'ES2016', 'ES2017', 'ES2018', 'ES2019', 'ES2020', 'ES2021', 'ES2022', 'ESNext'],
                    onChanged: (value) => setState(() => _target = value!),
                    hint: '指定 ECMAScript 目标版本',
                  ),
                  const SizedBox(height: 16),
                  _buildDropdownField(
                    label: 'Module',
                    value: _module,
                    items: ['CommonJS', 'AMD', 'UMD', 'System', 'ES6', 'ES2015', 'ES2020', 'ES2022', 'ESNext', 'Node16', 'NodeNext', 'None'],
                    onChanged: (value) => setState(() => _module = value!),
                    hint: '指定模块代码生成方式',
                  ),
                  const SizedBox(height: 16),
                  _buildDropdownField(
                    label: 'Module Resolution',
                    value: _moduleResolution,
                    items: ['node', 'node16', 'nodenext', 'classic', 'bundler'],
                    onChanged: (value) => setState(() => _moduleResolution = value!),
                    hint: '指定模块解析策略',
                  ),
                  const SizedBox(height: 16),
                  _buildDropdownField(
                    label: 'JSX',
                    value: _jsx,
                    items: ['preserve', 'react', 'react-jsx', 'react-jsxdev', 'react-native'],
                    onChanged: (value) => setState(() => _jsx = value!),
                    hint: '指定 JSX 代码生成方式',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // 严格模式选项
          Text(
            '严格类型检查',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildSwitchTile(
                    title: 'Strict',
                    subtitle: '启用所有严格类型检查选项',
                    value: _strict,
                    onChanged: (value) => setState(() => _strict = value),
                  ),
                  if (!_strict) ...[
                    _buildSwitchTile(
                      title: 'No Implicit Any',
                      subtitle: '禁止隐式 any 类型',
                      value: _noImplicitAny,
                      onChanged: (value) => setState(() => _noImplicitAny = value),
                    ),
                    _buildSwitchTile(
                      title: 'Strict Null Checks',
                      subtitle: '启用严格的 null 检查',
                      value: _strictNullChecks,
                      onChanged: (value) => setState(() => _strictNullChecks = value),
                    ),
                    _buildSwitchTile(
                      title: 'Strict Function Types',
                      subtitle: '启用严格的函数类型检查',
                      value: _strictFunctionTypes,
                      onChanged: (value) => setState(() => _strictFunctionTypes = value),
                    ),
                    _buildSwitchTile(
                      title: 'Strict Bind Call Apply',
                      subtitle: '启用严格的 bind/call/apply 检查',
                      value: _strictBindCallApply,
                      onChanged: (value) => setState(() => _strictBindCallApply = value),
                    ),
                    _buildSwitchTile(
                      title: 'Strict Property Initialization',
                      subtitle: '启用严格的属性初始化检查',
                      value: _strictPropertyInitialization,
                      onChanged: (value) => setState(() => _strictPropertyInitialization = value),
                    ),
                    _buildSwitchTile(
                      title: 'No Implicit This',
                      subtitle: '禁止隐式 this 类型',
                      value: _noImplicitThis,
                      onChanged: (value) => setState(() => _noImplicitThis = value),
                    ),
                    _buildSwitchTile(
                      title: 'Always Strict',
                      subtitle: '以严格模式解析并为每个源文件生成 "use strict"',
                      value: _alwaysStrict,
                      onChanged: (value) => setState(() => _alwaysStrict = value),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // 额外检查
          Text(
            '额外检查',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildSwitchTile(
                    title: 'No Unused Locals',
                    subtitle: '报告未使用的局部变量',
                    value: _noUnusedLocals,
                    onChanged: (value) => setState(() => _noUnusedLocals = value),
                  ),
                  _buildSwitchTile(
                    title: 'No Unused Parameters',
                    subtitle: '报告未使用的参数',
                    value: _noUnusedParameters,
                    onChanged: (value) => setState(() => _noUnusedParameters = value),
                  ),
                  _buildSwitchTile(
                    title: 'No Implicit Returns',
                    subtitle: '报告函数中缺少返回语句',
                    value: _noImplicitReturns,
                    onChanged: (value) => setState(() => _noImplicitReturns = value),
                  ),
                  _buildSwitchTile(
                    title: 'No Fallthrough Cases In Switch',
                    subtitle: '报告 switch 语句的 fallthrough 错误',
                    value: _noFallthroughCasesInSwitch,
                    onChanged: (value) => setState(() => _noFallthroughCasesInSwitch = value),
                  ),
                  _buildSwitchTile(
                    title: 'No Unchecked Indexed Access',
                    subtitle: '在索引签名结果中包含 undefined',
                    value: _noUncheckedIndexedAccess,
                    onChanged: (value) => setState(() => _noUncheckedIndexedAccess = value),
                  ),
                  _buildSwitchTile(
                    title: 'No Implicit Override',
                    subtitle: '确保派生类中的覆盖成员标记有 override 修饰符',
                    value: _noImplicitOverride,
                    onChanged: (value) => setState(() => _noImplicitOverride = value),
                  ),
                  _buildSwitchTile(
                    title: 'No Property Access From Index Signature',
                    subtitle: '强制使用索引访问器访问使用索引类型声明的键',
                    value: _noPropertyAccessFromIndexSignature,
                    onChanged: (value) => setState(() => _noPropertyAccessFromIndexSignature = value),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // 模块选项
          Text(
            '模块选项',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildSwitchTile(
                    title: 'ES Module Interop',
                    subtitle: '启用 ES 模块互操作性',
                    value: _esModuleInterop,
                    onChanged: (value) => setState(() => _esModuleInterop = value),
                  ),
                  _buildSwitchTile(
                    title: 'Allow Synthetic Default Imports',
                    subtitle: '允许从没有默认导出的模块中默认导入',
                    value: _allowSyntheticDefaultImports,
                    onChanged: (value) => setState(() => _allowSyntheticDefaultImports = value),
                  ),
                  _buildSwitchTile(
                    title: 'Resolve JSON Module',
                    subtitle: '允许导入 JSON 文件',
                    value: _resolveJsonModule,
                    onChanged: (value) => setState(() => _resolveJsonModule = value),
                  ),
                  _buildSwitchTile(
                    title: 'Isolated Modules',
                    subtitle: '确保每个文件可以独立转译',
                    value: _isolatedModules,
                    onChanged: (value) => setState(() => _isolatedModules = value),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // 输出选项
          Text(
            '输出选项',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildSwitchTile(
                    title: 'Declaration',
                    subtitle: '生成相应的 .d.ts 文件',
                    value: _declaration,
                    onChanged: (value) => setState(() => _declaration = value),
                  ),
                  _buildSwitchTile(
                    title: 'Declaration Map',
                    subtitle: '为 .d.ts 文件生成 sourcemap',
                    value: _declarationMap,
                    onChanged: (value) => setState(() => _declarationMap = value),
                  ),
                  _buildSwitchTile(
                    title: 'Source Map',
                    subtitle: '生成相应的 .map 文件',
                    value: _sourceMap,
                    onChanged: (value) => setState(() => _sourceMap = value),
                  ),
                  _buildSwitchTile(
                    title: 'Inline Source Map',
                    subtitle: '生成单个内联 sourcemap 文件',
                    value: _inlineSourceMap,
                    onChanged: (value) => setState(() => _inlineSourceMap = value),
                  ),
                  _buildSwitchTile(
                    title: 'Remove Comments',
                    subtitle: '删除所有注释',
                    value: _removeComments,
                    onChanged: (value) => setState(() => _removeComments = value),
                  ),
                  _buildSwitchTile(
                    title: 'Import Helpers',
                    subtitle: '从 tslib 导入辅助工具函数',
                    value: _importHelpers,
                    onChanged: (value) => setState(() => _importHelpers = value),
                  ),
                  _buildSwitchTile(
                    title: 'Downlevel Iteration',
                    subtitle: '为迭代器提供完整支持',
                    value: _downlevelIteration,
                    onChanged: (value) => setState(() => _downlevelIteration = value),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // 其他选项
          Text(
            '其他选项',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildSwitchTile(
                    title: 'Skip Lib Check',
                    subtitle: '跳过声明文件的类型检查',
                    value: _skipLibCheck,
                    onChanged: (value) => setState(() => _skipLibCheck = value),
                  ),
                  _buildSwitchTile(
                    title: 'Force Consistent Casing In File Names',
                    subtitle: '强制文件名大小写一致',
                    value: _forceConsistentCasingInFileNames,
                    onChanged: (value) => setState(() => _forceConsistentCasingInFileNames = value),
                  ),
                  _buildSwitchTile(
                    title: 'Allow JS',
                    subtitle: '允许编译 JavaScript 文件',
                    value: _allowJs,
                    onChanged: (value) => setState(() => _allowJs = value),
                  ),
                  _buildSwitchTile(
                    title: 'Check JS',
                    subtitle: '在 .js 文件中报告错误',
                    value: _checkJs,
                    onChanged: (value) => setState(() => _checkJs = value),
                  ),
                  _buildSwitchTile(
                    title: 'Incremental',
                    subtitle: '启用增量编译',
                    value: _incremental,
                    onChanged: (value) => setState(() => _incremental = value),
                  ),
                  _buildSwitchTile(
                    title: 'Composite',
                    subtitle: '启用项目编译的约束',
                    value: _composite,
                    onChanged: (value) => setState(() => _composite = value),
                  ),
                  _buildSwitchTile(
                    title: 'Experimental Decorators',
                    subtitle: '启用实验性的装饰器特性',
                    value: _experimentalDecorators,
                    onChanged: (value) => setState(() => _experimentalDecorators = value),
                  ),
                  _buildSwitchTile(
                    title: 'Emit Decorator Metadata',
                    subtitle: '为装饰器提供元数据支持',
                    value: _emitDecoratorMetadata,
                    onChanged: (value) => setState(() => _emitDecoratorMetadata = value),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // 保存按钮
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _saveConfig,
              icon: const Icon(Icons.save),
              label: const Text('保存配置'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              width: 200,
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: value,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: items.map((item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ],
        ),
        if (hint != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 200),
            child: Text(
              hint,
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12),
      ),
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
    );
  }
}
