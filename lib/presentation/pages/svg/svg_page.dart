import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_toolbox/data/models/svg_asset.dart';
import 'package:flutter_toolbox/data/models/icon_library.dart';
import 'package:flutter_toolbox/providers/svg_providers.dart';
import 'package:flutter_toolbox/providers/icon_library_providers.dart';
import 'package:flutter_toolbox/l10n/app_localizations.dart';
import 'package:flutter_toolbox/data/services/iconfont_service.dart';

/// SVG 管理页面
class SvgPage extends ConsumerStatefulWidget {
  const SvgPage({super.key});

  @override
  ConsumerState<SvgPage> createState() => _SvgPageState();
}

class _SvgPageState extends ConsumerState<SvgPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Set<String> _selectedIconIds = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow,
      body: Stack(
        children: [
          Column(
            children: [
              // 顶部工具栏
              Container(
                color: colorScheme.surface,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(
                      l10n.svgManagement,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 24),
                    // 搜索框
                    Expanded(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: l10n.search,
                            prefixIcon: const Icon(Icons.search),
                            isDense: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onChanged: (value) => ref.read(svgSearchQueryProvider.notifier).state = value,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // 导入按钮
                    FilledButton.icon(
                      onPressed: () => _importAssets(context, ref),
                      icon: const Icon(Icons.upload_file),
                      label: const Text('上传 SVG'),
                    ),
                  ],
                ),
              ),
              // Tab 栏
              Container(
                color: colorScheme.surface,
                child: TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(icon: Icon(Icons.image_outlined), text: 'SVG 图标'),
                    Tab(icon: Icon(Icons.collections_outlined), text: '图标库'),
                  ],
                ),
              ),
              // Tab 内容
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildSvgAssetsTab(context, ref),
                    _buildIconLibrariesTab(context, ref),
                  ],
                ),
              ),
            ],
          ),
          // 底部浮动操作栏 - 批量操作
          if (_selectedIconIds.isNotEmpty)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: colorScheme.primary),
                    const SizedBox(width: 12),
                    Text(
                      '已选择 ${_selectedIconIds.length} 个图标',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    OutlinedButton.icon(
                      onPressed: () => _addToLibrary(context, ref),
                      icon: const Icon(Icons.add_to_photos),
                      label: const Text('添加到图标库'),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: () => _deleteSelected(context, ref),
                      icon: const Icon(Icons.delete),
                      label: const Text('删除'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.error,
                      ),
                    ),
                    const SizedBox(width: 12),
                    TextButton.icon(
                      onPressed: () => setState(() => _selectedIconIds.clear()),
                      icon: const Icon(Icons.clear),
                      label: const Text('取消'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // SVG 图标 Tab
  Widget _buildSvgAssetsTab(BuildContext context, WidgetRef ref) {
    final assetsAsync = ref.watch(filteredSvgAssetsProvider);
    final searchQuery = ref.watch(svgSearchQueryProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return assetsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (assets) {
        if (assets.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image_outlined, size: 80, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                const SizedBox(height: 16),
                Text(
                  searchQuery.isEmpty ? '暂无 SVG 图标' : '未找到匹配的图标',
                  style: TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 8),
                Text(
                  '点击右上角"上传 SVG"按钮导入图标',
                  style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          );
        }
        return GridView.builder(
          padding: const EdgeInsets.all(20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 8,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1,
          ),
          itemCount: assets.length,
          itemBuilder: (context, index) => _SvgGridItem(
            asset: assets[index],
            isSelected: _selectedIconIds.contains(assets[index].id),
            onTap: () => _showIconDetail(context, ref, assets[index]),
            onLongPress: () => _toggleSelection(assets[index].id),
            onSelectionChanged: (selected) {
              setState(() {
                if (selected) {
                  _selectedIconIds.add(assets[index].id);
                } else {
                  _selectedIconIds.remove(assets[index].id);
                }
              });
            },
          ),
        );
      },
    );
  }

  // 图标库 Tab
  Widget _buildIconLibrariesTab(BuildContext context, WidgetRef ref) {
    final librariesAsync = ref.watch(iconLibraryListProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return librariesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (libraries) {
        if (libraries.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.collections_outlined, size: 80, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                const SizedBox(height: 16),
                Text(
                  '暂无图标库',
                  style: TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => _createLibrary(context, ref),
                  icon: const Icon(Icons.add),
                  label: const Text('创建图标库'),
                ),
              ],
            ),
          );
        }
        return Column(
          children: [
            // 创建按钮
            Container(
              padding: const EdgeInsets.all(16),
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: () => _createLibrary(context, ref),
                icon: const Icon(Icons.add),
                label: const Text('创建图标库'),
              ),
            ),
            // 图标库列表
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: libraries.length,
                itemBuilder: (context, index) => _IconLibraryCard(
                  library: libraries[index],
                  onTap: () => _openLibrary(context, ref, libraries[index]),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _toggleSelection(String iconId) {
    setState(() {
      if (_selectedIconIds.contains(iconId)) {
        _selectedIconIds.remove(iconId);
      } else {
        _selectedIconIds.add(iconId);
      }
    });
  }

  Future<void> _importAssets(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['svg'],
      allowMultiple: true,
    );
    
    if (result != null && result.files.isNotEmpty) {
      final filePaths = result.files
          .where((file) => file.path != null)
          .map((file) => file.path!)
          .toList();
      
      if (filePaths.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('未找到有效的文件路径')),
          );
        }
        return;
      }

      // 显示加载对话框
      final dialogContext = context;
      if (!mounted) return;
      
      showDialog(
        context: dialogContext,
        barrierDismissible: false,
        builder: (dialogCtx) => PopScope(
          canPop: false,
          child: const Center(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('正在导入 SVG 文件...'),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      try {
        await ref.read(svgAssetListProvider.notifier).importFromFiles(filePaths);
        
        if (mounted && dialogContext.mounted) {
          Navigator.of(dialogContext).pop(); // 关闭加载对话框
          ScaffoldMessenger.of(dialogContext).showSnackBar(
            SnackBar(content: Text('成功导入 ${filePaths.length} 个 SVG 文件')),
          );
        }
      } catch (e) {
        if (mounted && dialogContext.mounted) {
          Navigator.of(dialogContext).pop(); // 关闭加载对话框
          ScaffoldMessenger.of(dialogContext).showSnackBar(
            SnackBar(content: Text('导入失败: $e')),
          );
        }
      }
    }
  }

  void _showIconDetail(BuildContext context, WidgetRef ref, SvgAsset asset) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _SvgDetailPage(asset: asset),
      ),
    );
  }

  void _addToLibrary(BuildContext context, WidgetRef ref) {
    final librariesAsync = ref.read(iconLibraryListProvider);
    
    librariesAsync.whenData((libraries) {
      if (libraries.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('请先创建图标库')),
        );
        return;
      }

      showDialog(
        context: context,
        builder: (context) => _AddToLibraryDialog(
          selectedIconIds: _selectedIconIds.toList(),
          libraries: libraries,
          onAdd: (libraryId) async {
            for (final iconId in _selectedIconIds) {
              await ref.read(iconLibraryListProvider.notifier).addIconToLibrary(libraryId, iconId);
            }
            setState(() => _selectedIconIds.clear());
            if (context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('已添加到图标库')),
              );
            }
          },
        ),
      );
    });
  }

  void _createLibrary(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => _CreateLibraryDialog(),
    );
  }

  void _openLibrary(BuildContext context, WidgetRef ref, IconLibrary library) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _IconLibraryDetailPage(library: library),
      ),
    );
  }

  void _deleteSelected(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除图标'),
        content: Text('确定要删除选中的 ${_selectedIconIds.length} 个图标吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () async {
              await ref.read(svgAssetListProvider.notifier).deleteMultipleAssets(_selectedIconIds.toList());
              setState(() => _selectedIconIds.clear());
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('已删除选中的图标')),
                );
              }
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}

// 添加到图标库对话框
class _AddToLibraryDialog extends StatefulWidget {
  final List<String> selectedIconIds;
  final List<IconLibrary> libraries;
  final Function(String libraryId) onAdd;

  const _AddToLibraryDialog({
    required this.selectedIconIds,
    required this.libraries,
    required this.onAdd,
  });

  @override
  State<_AddToLibraryDialog> createState() => _AddToLibraryDialogState();
}

class _AddToLibraryDialogState extends State<_AddToLibraryDialog> {
  String? _selectedLibraryId;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('添加 ${widget.selectedIconIds.length} 个图标到图标库'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('选择目标图标库：'),
            const SizedBox(height: 16),
            ...widget.libraries.map((library) => ListTile(
              title: Text(library.name),
              subtitle: Text('${library.iconIds.length} 个图标'),
              leading: Radio<String>(
                value: library.id,
                groupValue: _selectedLibraryId,
                onChanged: (value) => setState(() => _selectedLibraryId = value),
              ),
              onTap: () => setState(() => _selectedLibraryId = library.id),
            )),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: _selectedLibraryId == null
              ? null
              : () => widget.onAdd(_selectedLibraryId!),
          child: const Text('添加'),
        ),
      ],
    );
  }
}

// SVG 网格项
class _SvgGridItem extends StatelessWidget {
  final SvgAsset asset;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final ValueChanged<bool> onSelectionChanged;

  const _SvgGridItem({
    required this.asset,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: isSelected ? 4 : 1,
      color: isSelected ? colorScheme.primaryContainer : null,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // 主内容
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final size = constraints.maxHeight.clamp(0.0, 64.0);
                          return SvgPicture.string(
                            asset.content,
                            width: size,
                            height: size,
                            fit: BoxFit.contain,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 底部：文件名和选择指示器
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          asset.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => onSelectionChanged(!isSelected),
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: isSelected ? colorScheme.primary : Colors.transparent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? colorScheme.primary : colorScheme.outline,
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? Icon(
                                  Icons.check,
                                  size: 12,
                                  color: colorScheme.onPrimary,
                                )
                              : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // 选中时的边框效果
            if (isSelected)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.primary,
                      width: 2,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// 图标库卡片
class _IconLibraryCard extends StatelessWidget {
  final IconLibrary library;
  final VoidCallback onTap;

  const _IconLibraryCard({
    required this.library,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.collections_outlined,
                  size: 32,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      library.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (library.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        library.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.image, size: 16, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          '${library.iconIds.length} 个图标',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

// 创建图标库对话框
class _CreateLibraryDialog extends ConsumerStatefulWidget {
  @override
  ConsumerState<_CreateLibraryDialog> createState() => _CreateLibraryDialogState();
}

class _CreateLibraryDialogState extends ConsumerState<_CreateLibraryDialog> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('创建图标库'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '图标库名称',
                hintText: '例如：项目图标',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: '描述（可选）',
                hintText: '简要描述这个图标库的用途',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () async {
            if (_nameController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('请输入图标库名称')),
              );
              return;
            }
            await ref.read(iconLibraryListProvider.notifier).createLibrary(
              _nameController.text.trim(),
              _descriptionController.text.trim(),
            );
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text('创建'),
        ),
      ],
    );
  }
}

// SVG 详情页
class _SvgDetailPage extends ConsumerStatefulWidget {
  final SvgAsset asset;

  const _SvgDetailPage({required this.asset});

  @override
  ConsumerState<_SvgDetailPage> createState() => _SvgDetailPageState();
}

class _SvgDetailPageState extends ConsumerState<_SvgDetailPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Color _selectedColor = Colors.black;
  double _selectedSize = 128.0;
  Color _backgroundColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.asset.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.palette),
            tooltip: '自定义颜色',
            onPressed: () => _showColorPicker(context),
          ),
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: '导出',
            onPressed: () => _showExportOptions(context),
          ),
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: '复制 SVG 代码',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: widget.asset.content));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('已复制到剪贴板')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: '删除',
            onPressed: () => _deleteAsset(context, ref),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '预览'),
            Tab(text: '信息'),
            Tab(text: '代码'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPreviewTab(context),
          _buildInfoTab(context),
          _buildCodeTab(context),
        ],
      ),
    );
  }

  // 预览 Tab
  Widget _buildPreviewTab(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 主预览区域
          Center(
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                color: _backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
              ),
              child: Center(
                child: SizedBox(
                  width: _selectedSize,
                  height: _selectedSize,
                  child: SvgPicture.string(
                    _applyColor(widget.asset.content, _selectedColor),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // 尺寸控制
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.photo_size_select_large, size: 20, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        '尺寸控制',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text('${_selectedSize.toInt()}px'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Slider(
                    value: _selectedSize,
                    min: 32,
                    max: 256,
                    divisions: 28,
                    label: '${_selectedSize.toInt()}px',
                    onChanged: (value) => setState(() => _selectedSize = value),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: [16.0, 24.0, 32.0, 48.0, 64.0, 128.0, 256.0].map((size) {
                      return ChoiceChip(
                        label: Text('${size.toInt()}'),
                        selected: _selectedSize == size,
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedSize = size);
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 背景颜色
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.format_color_fill, size: 20, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        '背景颜色',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      Colors.white,
                      Colors.black,
                      Colors.grey.shade200,
                      Colors.grey.shade800,
                      colorScheme.primaryContainer,
                      colorScheme.secondaryContainer,
                    ].map((color) {
                      return InkWell(
                        onTap: () => setState(() => _backgroundColor = color),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _backgroundColor == color
                                  ? colorScheme.primary
                                  : colorScheme.outline.withValues(alpha: 0.2),
                              width: _backgroundColor == color ? 3 : 1,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 多尺寸预览
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.view_module, size: 20, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        '多尺寸预览',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [16.0, 24.0, 32.0, 48.0, 64.0, 96.0, 128.0].map((size) {
                      return Column(
                        children: [
                          Container(
                            width: size + 16,
                            height: size + 16,
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.all(8),
                            child: SvgPicture.string(
                              _applyColor(widget.asset.content, _selectedColor),
                              width: size,
                              height: size,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${size.toInt()}px',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 信息 Tab
  Widget _buildInfoTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '图标信息',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoRow(context, Icons.label, '名称', widget.asset.name),
              _buildInfoRow(context, Icons.storage, '文件大小', widget.asset.formattedSize),
              _buildInfoRow(context, Icons.calendar_today, '导入时间', _formatDate(widget.asset.importedAt)),
              _buildInfoRow(context, Icons.folder, '路径', widget.asset.path),
              _buildInfoRow(context, Icons.fingerprint, 'ID', widget.asset.id, isLast: true),
            ],
          ),
        ),
      ),
    );
  }

  // 代码 Tab
  Widget _buildCodeTab(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'SVG 代码',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    tooltip: '复制',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: widget.asset.content));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('已复制到剪贴板')),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  widget.asset.content,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value, {bool isLast = false}) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _applyColor(String svgContent, Color color) {
    // 简单的颜色替换（实际应用中可能需要更复杂的处理）
    final colorHex = '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
    return svgContent.replaceAll(RegExp(r'fill="[^"]*"'), 'fill="$colorHex"');
  }

  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择颜色'),
        content: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            Colors.black,
            Colors.white,
            Colors.red,
            Colors.pink,
            Colors.purple,
            Colors.deepPurple,
            Colors.indigo,
            Colors.blue,
            Colors.lightBlue,
            Colors.cyan,
            Colors.teal,
            Colors.green,
            Colors.lightGreen,
            Colors.lime,
            Colors.yellow,
            Colors.amber,
            Colors.orange,
            Colors.deepOrange,
            Colors.brown,
            Colors.grey,
          ].map((color) {
            return InkWell(
              onTap: () {
                setState(() => _selectedColor = color);
                Navigator.pop(context);
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _selectedColor == color
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade300,
                    width: _selectedColor == color ? 3 : 1,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  void _showExportOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('导出为 SVG'),
            subtitle: const Text('保存原始 SVG 文件'),
            onTap: () {
              Navigator.pop(context);
              _exportAsSvg();
            },
          ),
          ListTile(
            leading: const Icon(Icons.image),
            title: const Text('导出为 PNG'),
            subtitle: const Text('转换为 PNG 图片（待实现）'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('PNG 导出功能待实现')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.copy),
            title: const Text('复制 SVG 代码'),
            subtitle: const Text('复制到剪贴板'),
            onTap: () {
              Navigator.pop(context);
              Clipboard.setData(ClipboardData(text: widget.asset.content));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('已复制到剪贴板')),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _exportAsSvg() async {
    try {
      // 复制 SVG 内容到剪贴板
      await Clipboard.setData(ClipboardData(text: widget.asset.content));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('SVG 代码已复制到剪贴板'),
            action: SnackBarAction(
              label: '保存文件',
              onPressed: () {
                // TODO: 实现文件保存对话框
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('文件保存功能开发中...')),
                );
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导出失败: $e')),
        );
      }
    }
  }

  void _deleteAsset(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除图标'),
        content: Text('确定要删除 "${widget.asset.name}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () async {
              await ref.read(svgAssetListProvider.notifier).deleteAsset(widget.asset.id);
              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pop(context);
              }
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}

// 图标库详情页
class _IconLibraryDetailPage extends ConsumerWidget {
  final IconLibrary library;

  const _IconLibraryDetailPage({required this.library});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assetsAsync = ref.watch(svgAssetListProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(library.name),
            if (library.description.isNotEmpty)
              Text(
                library.description,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: '导出为 IconFont',
            onPressed: () => _exportToIconFont(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: '编辑',
            onPressed: () => _editLibrary(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: '删除',
            onPressed: () => _deleteLibrary(context, ref),
          ),
        ],
      ),
      body: assetsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (allAssets) {
          final libraryAssets = allAssets.where((asset) => library.iconIds.contains(asset.id)).toList();
          
          if (libraryAssets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 80, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  const Text('该图标库暂无图标'),
                  const SizedBox(height: 8),
                  const Text('请从 SVG 图标页面添加图标到此库'),
                ],
              ),
            );
          }

          return Column(
            children: [
              // 统计信息卡片
              Container(
                padding: const EdgeInsets.all(20),
                color: colorScheme.surface,
                child: Row(
                  children: [
                    _buildStatItem(context, Icons.image, '图标数量', '${libraryAssets.length}', colorScheme.primary),
                    const SizedBox(width: 32),
                    _buildStatItem(context, Icons.storage, '总大小', _calculateTotalSize(libraryAssets), colorScheme.secondary),
                    const SizedBox(width: 32),
                    _buildStatItem(context, Icons.calendar_today, '创建时间', _formatDate(library.createdAt), colorScheme.tertiary),
                    const SizedBox(width: 32),
                    _buildStatItem(context, Icons.update, '更新时间', _formatDate(library.updatedAt), colorScheme.tertiary),
                  ],
                ),
              ),
              // 图标网格
              Expanded(
                child: GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 8,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1,
            ),
            itemCount: libraryAssets.length,
            itemBuilder: (context, index) {
              final asset = libraryAssets[index];
              return Card(
                child: InkWell(
                  onTap: () {},
                  onLongPress: () => _removeIconFromLibrary(context, ref, asset),
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Expanded(
                              child: SvgPicture.string(asset.content, fit: BoxFit.contain),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              asset.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: IconButton(
                          icon: const Icon(Icons.close, size: 16),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => _removeIconFromLibrary(context, ref, asset),
                        ),
                      ),
                    ],
                  ),
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

  Widget _buildStatItem(BuildContext context, IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _calculateTotalSize(List<SvgAsset> assets) {
    final totalBytes = assets.fold<int>(0, (sum, asset) => sum + asset.fileSize);
    if (totalBytes < 1024) {
      return '$totalBytes B';
    } else if (totalBytes < 1024 * 1024) {
      return '${(totalBytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(totalBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _exportToIconFont(BuildContext context, WidgetRef ref) async {
    final assetsAsync = ref.read(svgAssetListProvider);
    
    await assetsAsync.whenOrNull(
      data: (allAssets) async {
        final libraryAssets = allAssets.where((asset) => library.iconIds.contains(asset.id)).toList();
        
        if (libraryAssets.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('图标库中没有图标')),
          );
          return;
        }

        // 显示导出选项对话框
        final result = await showDialog<List<String>>(
          context: context,
          builder: (context) => _ExportIconFontDialog(
            library: library,
            iconCount: libraryAssets.length,
          ),
        );

        if (result != null && result.isNotEmpty && context.mounted) {
          // 开始导出
          _performExport(context, ref, libraryAssets, result);
        }
      },
    );
  }

  Future<void> _performExport(
    BuildContext context,
    WidgetRef ref,
    List<SvgAsset> assets,
    List<String> formats,
  ) async {
    // 1. 让用户选择输出目录
    final outputPath = await FilePicker.platform.getDirectoryPath(
      dialogTitle: '选择 IconFont 输出目录',
    );

    if (outputPath == null) {
      return; // 用户取消
    }

    // 2. 显示带日志的进度对话框
    if (!context.mounted) return;
    
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _IconFontProgressDialog(
        assets: assets,
        fontName: library.name.replaceAll(RegExp(r'[^\w\-]'), '_'),
        outputDir: outputPath,
        formats: formats,
      ),
    );
  }

  Future<void> _exportAsSvgZip(BuildContext context, List<SvgAsset> assets) async {
    // 让用户选择输出目录
    final outputPath = await FilePicker.platform.getDirectoryPath(
      dialogTitle: '选择 SVG 导出目录',
    );

    if (outputPath == null) {
      return; // 用户取消
    }

    if (!context.mounted) return;

    // 显示导出进度
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text('正在导出 ${assets.length} 个 SVG 文件...'),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    try {
      // 导出所有 SVG 文件
      int successCount = 0;
      for (final asset in assets) {
        final fileName = asset.name.endsWith('.svg') ? asset.name : '${asset.name}.svg';
        final filePath = '$outputPath/$fileName';
        final file = File(filePath);
        await file.writeAsString(asset.content);
        successCount++;
      }

      if (!context.mounted) return;
      Navigator.pop(context); // 关闭进度对话框

      // 显示成功消息
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('导出成功'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('已成功导出 $successCount 个 SVG 文件'),
              const SizedBox(height: 16),
              Text('输出目录: $outputPath'),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('完成'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // 关闭进度对话框

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('导出失败: $e')),
      );
    }
  }

  void _editLibrary(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => _EditLibraryDialog(library: library),
    );
  }

  void _deleteLibrary(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除图标库'),
        content: Text('确定要删除 "${library.name}" 吗？\n\n这不会删除图标文件，只会删除图标库。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () async {
              await ref.read(iconLibraryListProvider.notifier).deleteLibrary(library.id);
              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pop(context);
              }
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _removeIconFromLibrary(BuildContext context, WidgetRef ref, SvgAsset asset) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('移除图标'),
        content: Text('确定要从图标库中移除 "${asset.name}" 吗？\n\n这不会删除图标文件。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () async {
              await ref.read(iconLibraryListProvider.notifier).removeIconFromLibrary(library.id, asset.id);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('已从图标库中移除')),
                );
              }
            },
            child: const Text('移除'),
          ),
        ],
      ),
    );
  }
}

// 导出 IconFont 对话框
class _ExportIconFontDialog extends StatefulWidget {
  final IconLibrary library;
  final int iconCount;

  const _ExportIconFontDialog({
    required this.library,
    required this.iconCount,
  });

  @override
  State<_ExportIconFontDialog> createState() => _ExportIconFontDialogState();
}

class _ExportIconFontDialogState extends State<_ExportIconFontDialog> {
  final Set<String> _selectedFormats = {'ttf', 'woff', 'woff2'};
  
  static const List<Map<String, String>> _availableFormats = [
    {'id': 'ttf', 'label': 'TTF', 'desc': 'TrueType Font'},
    {'id': 'woff', 'label': 'WOFF', 'desc': 'Web Open Font Format'},
    {'id': 'woff2', 'label': 'WOFF2', 'desc': 'Web Open Font Format 2'},
    {'id': 'eot', 'label': 'EOT', 'desc': 'Embedded OpenType'},
    {'id': 'svg', 'label': 'SVG', 'desc': 'SVG Font'},
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return AlertDialog(
      title: const Text('导出为 IconFont'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 500),
        child: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // 基本信息
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.collections_outlined, size: 16, color: colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          widget.library.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${widget.iconCount} 个图标',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // 格式选择标题
              Row(
                children: [
                  const Text(
                    '导出格式',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        if (_selectedFormats.length == _availableFormats.length) {
                          _selectedFormats.clear();
                        } else {
                          _selectedFormats.addAll(_availableFormats.map((f) => f['id']!));
                        }
                      });
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      _selectedFormats.length == _availableFormats.length ? '取消全选' : '全选',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // 格式列表 - 紧凑设计
              ..._availableFormats.map((format) {
                final isSelected = _selectedFormats.contains(format['id']);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedFormats.remove(format['id']);
                        } else {
                          _selectedFormats.add(format['id']!);
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? colorScheme.primaryContainer.withValues(alpha: 0.3) : colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isSelected ? colorScheme.primary : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: Checkbox(
                              value: isSelected,
                              onChanged: (value) {
                                setState(() {
                                  if (value == true) {
                                    _selectedFormats.add(format['id']!);
                                  } else {
                                    _selectedFormats.remove(format['id']);
                                  }
                                });
                              },
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Row(
                              children: [
                                Text(
                                  format['label']!,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: isSelected ? colorScheme.primary : null,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    format['desc']!,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 12),
              // 系统要求 - 紧凑设计
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '系统要求',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: Colors.blue.shade900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '需要安装 Node.js 和 svgtofont\nnpm install -g svgtofont',
                            style: TextStyle(fontSize: 11, color: Colors.blue.shade800),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
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
          onPressed: _selectedFormats.isEmpty
              ? null
              : () => Navigator.pop(context, _selectedFormats.toList()),
          child: Text(_selectedFormats.isEmpty ? '请选择格式' : '导出 (${_selectedFormats.length})'),
        ),
      ],
    );
  }


}

// 编辑图标库对话框
class _EditLibraryDialog extends ConsumerStatefulWidget {
  final IconLibrary library;

  const _EditLibraryDialog({required this.library});

  @override
  ConsumerState<_EditLibraryDialog> createState() => _EditLibraryDialogState();
}

class _EditLibraryDialogState extends ConsumerState<_EditLibraryDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.library.name);
    _descriptionController = TextEditingController(text: widget.library.description);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('编辑图标库'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '图标库名称',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: '描述',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () async {
            if (_nameController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('请输入图标库名称')),
              );
              return;
            }
            
            final updated = widget.library.copyWith(
              name: _nameController.text.trim(),
              description: _descriptionController.text.trim(),
              updatedAt: DateTime.now(),
            );
            
            await ref.read(iconLibraryListProvider.notifier).updateLibrary(updated);
            
            if (context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('图标库已更新')),
              );
            }
          },
          child: const Text('保存'),
        ),
      ],
    );
  }
}

// IconFont 生成进度对话框
class _IconFontProgressDialog extends StatefulWidget {
  final List<SvgAsset> assets;
  final String fontName;
  final String outputDir;
  final List<String> formats;

  const _IconFontProgressDialog({
    required this.assets,
    required this.fontName,
    required this.outputDir,
    required this.formats,
  });

  @override
  State<_IconFontProgressDialog> createState() => _IconFontProgressDialogState();
}

class _IconFontProgressDialogState extends State<_IconFontProgressDialog> {
  final List<String> _logs = [];
  final ScrollController _scrollController = ScrollController();
  String _currentMessage = '准备开始...';
  double _progress = 0.0;
  bool _isCompleted = false;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _startGeneration();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _startGeneration() async {
    try {
      final iconFontService = IconFontService();
      final result = await iconFontService.generateIconFont(
        assets: widget.assets,
        fontName: widget.fontName,
        outputDir: widget.outputDir,
        formats: widget.formats,
        onProgress: (message, progress) {
          if (mounted) {
            setState(() {
              _currentMessage = message;
              _progress = progress;
              _logs.add(message);
            });
            // 自动滚动到底部
            WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
          }
        },
      );

      if (mounted) {
        setState(() {
          _isCompleted = true;
          _isSuccess = result.success;
          _logs.addAll(result.logs);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCompleted = true;
          _isSuccess = false;
          _logs.add('错误: $e');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: _isCompleted,
      child: AlertDialog(
        title: Row(
          children: [
            if (!_isCompleted)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Icon(
                _isSuccess ? Icons.check_circle : Icons.error,
                color: _isSuccess ? Colors.green : Colors.red,
              ),
            const SizedBox(width: 12),
            Text(_isCompleted
                ? (_isSuccess ? '生成成功' : '生成失败')
                : '正在生成 IconFont'),
          ],
        ),
        content: SizedBox(
          width: 600,
          height: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 进度信息
              if (!_isCompleted) ...[
                LinearProgressIndicator(value: _progress),
                const SizedBox(height: 12),
                Text(
                  _currentMessage,
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              // 日志标题
              Row(
                children: [
                  Icon(Icons.terminal, size: 16, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    '执行日志',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_logs.length} 条',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // 日志内容
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade700),
                  ),
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: _logs.length,
                    itemBuilder: (context, index) {
                      final log = _logs[index];
                      Color textColor = Colors.grey.shade300;
                      
                      if (log.startsWith('✓')) {
                        textColor = Colors.green.shade300;
                      } else if (log.startsWith('✗') || log.contains('错误') || log.contains('失败')) {
                        textColor = Colors.red.shade300;
                      } else if (log.startsWith('[')) {
                        textColor = Colors.blue.shade300;
                      }
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          log,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            color: textColor,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          if (_isCompleted) ...[
            if (!_isSuccess)
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // 可以在这里触发导出 SVG 的备选方案
                },
                child: const Text('改为导出 SVG'),
              ),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: Text(_isSuccess ? '完成' : '关闭'),
            ),
          ] else ...[
            TextButton(
              onPressed: null,
              child: const Text('请等待...'),
            ),
          ],
        ],
      ),
    );
  }
}
