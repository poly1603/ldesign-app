import 'dart:io';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

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
    windowManager.addListener(this);
    _checkMaximized();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
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

    return Container(
      height: Platform.isMacOS ? 28 : 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.surface,
            theme.colorScheme.surface.withOpacity(0.95),
          ],
        ),
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
          if (Platform.isMacOS) const SizedBox(width: 70),
          
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
                windowManager.startDragging();
              },
              onDoubleTap: () async {
                if (await windowManager.isMaximized()) {
                  windowManager.unmaximize();
                } else {
                  windowManager.maximize();
                }
              },
              child: const SizedBox.expand(),
            ),
          ),
          
          // Windows/Linux 窗口控制按钮 - 右侧
          if (!Platform.isMacOS) ...[
            _WindowButton(
              icon: Icons.minimize,
              onPressed: () {
                windowManager.minimize();
              },
            ),
            _WindowButton(
              icon: _isMaximized ? Icons.fullscreen_exit : Icons.crop_square,
              onPressed: () async {
                if (await windowManager.isMaximized()) {
                  windowManager.unmaximize();
                } else {
                  windowManager.maximize();
                }
              },
            ),
            _WindowButton(
              icon: Icons.close,
              isClose: true,
              onPressed: () {
                windowManager.close();
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _WindowButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isClose;

  const _WindowButton({
    required this.icon,
    required this.onPressed,
    this.isClose = false,
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
          child: Icon(
            widget.icon,
            size: 14,
            color: getIconColor(),
          ),
        ),
      ),
    );
  }
}
