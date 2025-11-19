import 'package:flutter/material.dart';

/// 页面切换动画类型
enum PageTransitionType {
  fade,           // 淡入淡出
  slideLeft,      // 从右向左滑动
  slideRight,     // 从左向右滑动
  slideUp,        // 从下向上滑动
  slideDown,      // 从上向下滑动
  scale,          // 缩放
  rotation,       // 旋转
}

/// 页面切换动画组件
class PageTransition extends StatelessWidget {
  final Widget child;
  final PageTransitionType type;
  final Duration duration;
  final Curve curve;
  final bool enabled;

  const PageTransition({
    super.key,
    required this.child,
    this.type = PageTransitionType.slideLeft,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return child;
    }

    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: curve,
      switchOutCurve: curve,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return _buildTransition(child, animation);
      },
      layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
        return Stack(
          children: <Widget>[
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
        );
      },
      child: child,
    );
  }

  Widget _buildTransition(Widget child, Animation<double> animation) {
    switch (type) {
      case PageTransitionType.fade:
        return FadeTransition(
          opacity: animation,
          child: child,
        );

      case PageTransitionType.slideLeft:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );

      case PageTransitionType.slideRight:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1.0, 0.0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );

      case PageTransitionType.slideUp:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );

      case PageTransitionType.slideDown:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, -1.0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );

      case PageTransitionType.scale:
        return ScaleTransition(
          scale: Tween<double>(
            begin: 0.8,
            end: 1.0,
          ).animate(animation),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );

      case PageTransitionType.rotation:
        return RotationTransition(
          turns: Tween<double>(
            begin: 0.1,
            end: 0.0,
          ).animate(animation),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
    }
  }
}

/// 页面切换动画包装器
/// 用于包装整个页面内容，提供统一的动画效果
class PageTransitionWrapper extends StatefulWidget {
  final Widget child;
  final PageTransitionType type;
  final Duration duration;
  final Curve curve;
  final bool enabled;

  const PageTransitionWrapper({
    super.key,
    required this.child,
    this.type = PageTransitionType.slideLeft,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.enabled = true,
  });

  @override
  State<PageTransitionWrapper> createState() => _PageTransitionWrapperState();
}

class _PageTransitionWrapperState extends State<PageTransitionWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );

    // 启动动画
    if (widget.enabled) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(PageTransitionWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 如果子组件发生变化，重新播放动画
    if (widget.child != oldWidget.child && widget.enabled) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return _buildTransition(widget.child, _animation);
      },
    );
  }

  Widget _buildTransition(Widget child, Animation<double> animation) {
    switch (widget.type) {
      case PageTransitionType.fade:
        return FadeTransition(
          opacity: animation,
          child: child,
        );

      case PageTransitionType.slideLeft:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );

      case PageTransitionType.slideRight:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1.0, 0.0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );

      case PageTransitionType.slideUp:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );

      case PageTransitionType.slideDown:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, -1.0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );

      case PageTransitionType.scale:
        return ScaleTransition(
          scale: Tween<double>(
            begin: 0.8,
            end: 1.0,
          ).animate(animation),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );

      case PageTransitionType.rotation:
        return RotationTransition(
          turns: Tween<double>(
            begin: 0.1,
            end: 0.0,
          ).animate(animation),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
    }
  }
}
