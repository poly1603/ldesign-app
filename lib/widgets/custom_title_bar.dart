﻿﻿﻿﻿﻿﻿import 'package:flutter/material.dart';
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
    // 浠呭湪妗岄潰骞冲彴娣诲姞绐楀彛浜嬩欢鐩戝惉锛圵indows/macOS/Linux锛?
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
            color: theme.dividerColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 1),
            blurRadius: 3,
          ),
        ],
      ),
      child: Row(
        children: [
          // macOS 宸︿晶浜ら€氱伅鎸夐挳鍗犱綅
          if (isMacOS) const SizedBox(width: 70),
          
          // 搴旂敤鍚嶇О - 宸︿晶瀵归綈
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: widget.title ?? const SizedBox.shrink(),
          ),
          
          // 鍙嫋鎷藉尯鍩?
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
          
          // Windows/Linux 绐楀彛鎺у埗鎸夐挳 - 鍙充晶
          if (!isMacOS) ...[
            // 鏈€灏忓寲鎸夐挳锛氫娇鐢ㄥ畼鏂?FluentUI 鍥炬爣
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
            const SizedBox(width: 2), // 绐楀彛鎺у埗鎸夐挳闂磋窛锛屼繚鎸佷竴鑷存€?
            // 鏈€澶у寲/杩樺師鎸夐挳锛氫娇鐢ㄥ畼鏂?FluentUI 鍥炬爣
            _WindowButton(
              iconBuilder: (color) => Icon(
                _isMaximized 
                  ? FluentIcons.square_multiple_20_regular // 杩樺師鍥炬爣
                  : FluentIcons.maximize_20_regular, // 鏈€澶у寲鍥炬爣
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
  // 鑷畾涔夊浘鏍囨瀯寤哄櫒锛岀敤浜庢敮鎸?Windows 椋庢牸鐨勫浘鏍囷紙鍙牴鎹鑹茶嚜閫傚簲锛?
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
    
    // 瀹氫箟鎮仠鍜屾寜涓嬬姸鎬佺殑棰滆壊
    Color getBackgroundColor() {
      if (_isPressed) {
        if (widget.isClose) {
          return const Color(0xFFE81123).withValues(alpha: 0.9);
        }
        return theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.8);
      }
      if (_isHovering) {
        if (widget.isClose) {
          return const Color(0xFFE81123);
        }
        return theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5);
      }
      return Colors.transparent;
    }

    Color getIconColor() {
      if (widget.isClose && (_isHovering || _isPressed)) {
        return Colors.white;
      }
      if (_isHovering || _isPressed) {
        // 闈炲叧闂寜閽湪 hover/active 鏃舵彁鍗囧姣斿害
        return theme.colorScheme.onSurface;
      }
      return theme.colorScheme.onSurface.withValues(alpha: 0.8);
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
          // 浣跨敤灞呬腑甯冨眬纭繚鍥炬爣鍦ㄥ瀭鐩翠笌姘村钩涓婂畬缇庡眳涓?
          child: Center(
            child: widget.iconBuilder(getIconColor()),
          ),
        ),
      ),
    );
  }
}
