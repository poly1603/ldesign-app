import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:window_manager/window_manager.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

class CustomTitleBar extends StatefulWidget {
  final Widget? title;
  
  const CustomTitleBar({super.key, this.title});

  @override
  State<CustomTitleBar> createState() => _CustomTitleBarState();
}

class _CustomTitleBarState extends State<CustomTitleBar> with WindowListener {
  bool _isMaximized = false;

  @override
  void initState() {
    super.initState();
    // 仅在桌面平台添加窗口事件监听（Windows/macOS/Linux）
    final bool isDesktop = !kIsWeb && (
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.linux
    );
    if (isDesktop) {
      windowManager.addListener(this);
      _checkMaximized();
    }
  }

  @override
  void dispose() {
    final bool isDesktop = !kIsWeb && (
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.linux
    );
    if (isDesktop) {
      windowManager.removeListener(this);
    }
    super.dispose();
  }

  Future<void> _checkMaximized() async {
    final isMaximized = await windowManager.isMaximized();
    if (mounted) {
      setState(() {
        _isMaximized = isMaximized;
      });
    }
  }

  @override
  void onWindowMaximize() {
    setState(() {
      _isMaximized = true;
    });
  }

  @override
  void onWindowUnmaximize() {
    setState(() {
      _isMaximized = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isMacOS = defaultTargetPlatform == TargetPlatform.macOS;
    final bool isDesktop = !kIsWeb && (
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.linux
    );

    return Container(
      height: isMacOS ? 28 : 40,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 1),
            blurRadius: 3,
          ),
        ],
      ),
      child: Row(
        children: [
          // macOS 左侧交通灯按钮占位
          if (isMacOS) const SizedBox(width: 70),
          
          // 应用名称 - 左侧对齐
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: widget.title ?? const SizedBox.shrink(),
          ),
          
          // 可拖拽区域
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onPanStart: (_) {
                if (isDesktop) {
                  windowManager.startDragging();
                }
              },
              onDoubleTap: () async {
                if (isDesktop) {
                  if (await windowManager.isMaximized()) {
                    windowManager.unmaximize();
                  } else {
                    windowManager.maximize();
                  }
                }
              },
              child: const SizedBox.expand(),
            ),
          ),
          
          // Windows/Linux 窗口控制按钮 - 右侧
          if (!isMacOS) ...[
            // 最小化按钮：使用官方 FluentUI 图标
            _WindowButton(
              iconBuilder: (color) => Icon(
                FluentIcons.subtract_20_regular,
                size: 20,
                color: color,
              ),
              onPressed: () {
                if (isDesktop) {
                  windowManager.minimize();
                }
              },
            ),
            const SizedBox(width: 2), // 窗口控制按钮间距，保持一致性
            // 最大化/还原按钮：使用官方 FluentUI 图标
            _WindowButton(
              iconBuilder: (color) => Icon(
                _isMaximized 
                  ? FluentIcons.square_multiple_20_regular // 还原图标
                  : FluentIcons.maximize_20_regular, // 最大化图标
                size: 20,
                color: color,
              ),
              onPressed: () async {
                if (isDesktop) {
                  if (await windowManager.isMaximized()) {
                    windowManager.unmaximize();
                  } else {
                    windowManager.maximize();
                  }
                }
              },
            ),
            const SizedBox(width: 2),
            _WindowButton(
              iconBuilder: (color) => Icon(
                FluentIcons.dismiss_20_regular,
                size: 20,
                color: color,
              ),
              isClose: true,
              onPressed: () {
                if (isDesktop) {
                  windowManager.close();
                }
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _WindowButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isClose;
  // 自定义图标构建器，用于支持 Windows 风格的图标（可根据颜色自适应）
  final Widget Function(Color color) iconBuilder;

  const _WindowButton({
    required this.onPressed,
    this.isClose = false,
    required this.iconBuilder,
  });

  @override
  State<_WindowButton> createState() => _WindowButtonState();
}

class _WindowButtonState extends State<_WindowButton> {
  bool _isHovering = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // 定义悬停和按下状态的颜色
    Color getBackgroundColor() {
      if (_isPressed) {
        if (widget.isClose) {
          return const Color(0xFFE81123).withOpacity(0.9);
        }
        return theme.colorScheme.surfaceContainerHighest.withOpacity(0.8);
      }
      if (_isHovering) {
        if (widget.isClose) {
          return const Color(0xFFE81123);
        }
        return theme.colorScheme.surfaceContainerHighest.withOpacity(0.5);
      }
      return Colors.transparent;
    }

    Color getIconColor() {
      if (widget.isClose && (_isHovering || _isPressed)) {
        return Colors.white;
      }
      if (_isHovering || _isPressed) {
        // 非关闭按钮在 hover/active 时提升对比度
        return theme.colorScheme.onSurface;
      }
      return theme.colorScheme.onSurface.withOpacity(0.8);
    }
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() {
        _isHovering = false;
        _isPressed = false;
      }),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          width: 46,
          height: 40,
          decoration: BoxDecoration(
            color: getBackgroundColor(),
          ),
          // 使用居中布局确保图标在垂直与水平上完美居中
          child: Center(
            child: widget.iconBuilder(getIconColor()),
          ),
        ),
      ),
    );
  }
}
