import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
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
            // 最小化按钮：自定义 Windows 11 风格，确保垂直居中
            _WindowButton(
              iconBuilder: (color) => Win11MinimizeIcon(color: color),
              onPressed: () {
                if (isDesktop) {
                  windowManager.minimize();
                }
              },
            ),
            const SizedBox(width: 2), // 窗口控制按钮间距，保持一致性
            // 最大化/还原按钮：Windows 11 风格的重叠方形图标
            _WindowButton(
              iconBuilder: (color) => Win11MaximizeIcon(
                isMaximized: _isMaximized,
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
              icon: Icons.close,
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
  final IconData? icon;
  final VoidCallback onPressed;
  final bool isClose;
  // 自定义图标构建器，用于支持 Windows 风格的图标（可根据颜色自适应）
  final Widget Function(Color color)? iconBuilder;

  const _WindowButton({
    this.icon,
    required this.onPressed,
    this.isClose = false,
    this.iconBuilder,
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
            child: widget.iconBuilder != null
                ? widget.iconBuilder!(getIconColor())
                : Icon(
                    widget.icon!,
                    size: 14,
                    color: getIconColor(),
                  ),
          ),
        ),
      ),
    );
  }
}

/// Windows 11 风格的最小化图标
/// 使用自定义绘制确保在所有 DPI 下垂直居中显示
class Win11MinimizeIcon extends StatelessWidget {
  final Color color;
  final double size;

  const Win11MinimizeIcon({super.key, required this.color, this.size = 14});

  @override
  Widget build(BuildContext context) {
    // 通过 CustomPaint 绘制一条居中的水平线，避免默认 Icon 偏移问题
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _MinimizeIconPainter(color: color),
      ),
    );
  }
}

class _MinimizeIconPainter extends CustomPainter {
  final Color color;
  _MinimizeIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      // 选择适中的线宽以适配不同 DPI，Flutter 使用逻辑像素无需手动缩放
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.square;

    final double padding = 3; // 两端留白，符合 Windows 视觉规范
    final double y = size.height / 2; // 垂直居中
    canvas.drawLine(Offset(padding, y), Offset(size.width - padding, y), paint);
  }

  @override
  bool shouldRepaint(covariant _MinimizeIconPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

/// Windows 11 风格的最大化/还原图标
/// 未最大化：单个方形；已最大化：两个重叠方形
class Win11MaximizeIcon extends StatelessWidget {
  final bool isMaximized;
  final Color color;
  final double size;

  const Win11MaximizeIcon({
    super.key,
    required this.isMaximized,
    required this.color,
    this.size = 14,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _MaximizeIconPainter(isMaximized: isMaximized, color: color),
      ),
    );
  }
}

class _MaximizeIconPainter extends CustomPainter {
  final bool isMaximized;
  final Color color;

  _MaximizeIconPainter({required this.isMaximized, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeJoin = StrokeJoin.miter;

    if (!isMaximized) {
      // 单个方形（未最大化）
      final double inset = 2.5;
      final rect = Rect.fromLTWH(inset, inset, size.width - inset * 2, size.height - inset * 2);
      canvas.drawRect(rect, paint);
    } else {
      // 两个重叠方形（已最大化 → 还原图标）
      final double inset = 2.5;
      final double overlap = 3.0; // 两个方形的偏移量

      // 后方方形（顶部右侧）
      final Rect back = Rect.fromLTWH(inset + overlap, inset, size.width - inset * 2 - overlap, size.height - inset * 2 - overlap);
      // 前方方形（底部左侧）
      final Rect front = Rect.fromLTWH(inset, inset + overlap, size.width - inset * 2 - overlap, size.height - inset * 2 - overlap);

      canvas.drawRect(back, paint);
      canvas.drawRect(front, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _MaximizeIconPainter oldDelegate) {
    return oldDelegate.isMaximized != isMaximized || oldDelegate.color != color;
  }
}
