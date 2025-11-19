import 'package:flutter/material.dart';

/// 骨架屏加载组件
class SkeletonLoader extends StatefulWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const SkeletonLoader({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutSine,
    ));
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.grey.shade300,
                Colors.grey.shade100,
                Colors.grey.shade300,
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ].map((stop) => stop.clamp(0.0, 1.0)).toList(),
            ),
          ),
        );
      },
    );
  }
}

/// 骨架屏卡片组件
class SkeletonCard extends StatelessWidget {
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final List<Widget> children;

  const SkeletonCard({
    super.key,
    this.width,
    this.height,
    this.padding,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

/// 骨架屏行组件
class SkeletonRow extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;

  const SkeletonRow({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: children,
    );
  }
}

/// 首页骨架屏
class HomeScreenSkeleton extends StatelessWidget {
  const HomeScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20), // 减少外边距
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight - 40, // 确保不超过可用高度
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // 使用最小尺寸
              children: [
                // Welcome Section Skeleton
                _buildWelcomeSkeleton(),
                const SizedBox(height: 16), // 减少间距
                
                // Project Stats Skeleton
                _buildProjectStatsSkeleton(),
                const SizedBox(height: 16),
                
                // Development Environment Skeleton
                _buildDevelopmentEnvironmentSkeleton(),
                const SizedBox(height: 16),
                
                // System Information Skeleton
                _buildSystemInformationSkeleton(),
                const SizedBox(height: 16),
                
                // Installed Software Skeleton
                _buildInstalledSoftwareSkeleton(),
                const SizedBox(height: 20), // 底部间距
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SkeletonLoader(width: 200, height: 32),
        const SizedBox(height: 8),
        const SkeletonLoader(width: 300, height: 16),
      ],
    );
  }

  Widget _buildProjectStatsSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SkeletonLoader(width: 120, height: 24),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            // 根据可用宽度动态调整列数
            final availableWidth = constraints.maxWidth;
            int columns = 4;
            if (availableWidth < 800) columns = 2;
            if (availableWidth < 600) columns = 1;
            
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: List.generate(4, (index) {
                final cardWidth = (availableWidth - (columns - 1) * 16) / columns;
                return SizedBox(
                  width: cardWidth,
                  child: SkeletonCard(
                    height: 80, // 进一步减少高度
                    padding: const EdgeInsets.all(12), // 减少内边距
                    children: [
                      const SkeletonLoader(width: 28, height: 28, borderRadius: BorderRadius.all(Radius.circular(6))),
                      const SizedBox(height: 6),
                      const SkeletonLoader(width: 40, height: 20),
                      const SizedBox(height: 2),
                      const SkeletonLoader(width: 60, height: 12),
                    ],
                  ),
                );
              }),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDevelopmentEnvironmentSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SkeletonLoader(width: 150, height: 20),
        const SizedBox(height: 8),
        SkeletonCard(
          padding: const EdgeInsets.all(12),
          children: [
            const SkeletonLoader(width: 120, height: 16),
            const SizedBox(height: 8),
            _buildInfoRowSkeleton(),
          ],
        ),
      ],
    );
  }

  Widget _buildSystemInformationSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SkeletonLoader(width: 120, height: 20),
        const SizedBox(height: 8),
        SkeletonCard(
          padding: const EdgeInsets.all(12),
          children: [
            const SkeletonLoader(width: 100, height: 16),
            const SizedBox(height: 8),
            _buildInfoRowSkeleton(),
            const SizedBox(height: 6),
            _buildInfoRowSkeleton(),
          ],
        ),
      ],
    );
  }

  Widget _buildInstalledSoftwareSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SkeletonLoader(width: 120, height: 20),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SkeletonCard(
                padding: const EdgeInsets.all(12),
                children: [
                  SkeletonRow(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SkeletonLoader(width: 70, height: 16),
                      const SkeletonLoader(width: 16, height: 16, borderRadius: BorderRadius.all(Radius.circular(8))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const SkeletonLoader(width: double.infinity, height: 1),
                  const SizedBox(height: 8),
                  _buildSoftwareItemSkeleton(),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SkeletonCard(
                padding: const EdgeInsets.all(12),
                children: [
                  SkeletonRow(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SkeletonLoader(width: 70, height: 16),
                      const SkeletonLoader(width: 16, height: 16, borderRadius: BorderRadius.all(Radius.circular(8))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const SkeletonLoader(width: double.infinity, height: 1),
                  const SizedBox(height: 8),
                  _buildSoftwareItemSkeleton(),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoRowSkeleton() {
    return SkeletonRow(
      children: [
        const SkeletonLoader(width: 20, height: 20, borderRadius: BorderRadius.all(Radius.circular(10))),
        const SizedBox(width: 8),
        const Expanded(child: SkeletonLoader(width: double.infinity, height: 14)),
        const SizedBox(width: 8),
        const SkeletonLoader(width: 80, height: 14),
      ],
    );
  }

  Widget _buildSoftwareItemSkeleton() {
    return SkeletonRow(
      children: [
        const SkeletonLoader(width: 6, height: 6, borderRadius: BorderRadius.all(Radius.circular(3))),
        const SizedBox(width: 6),
        const Expanded(child: SkeletonLoader(width: double.infinity, height: 14)),
      ],
    );
  }
}
