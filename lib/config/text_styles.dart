import 'package:flutter/material.dart';

/// 统一的文本样式配置
/// 
/// 使用规范：
/// - 常规文本使用 FontWeight.w400 (normal)
/// - 标题使用 FontWeight.w600 (semibold)
/// - 数字使用 UniveconBold 字体
class AppTextStyles {
  AppTextStyles._();

  // 数字字体
  static const String numberFontFamily = 'UniveconBold';

  // 标准字重
  static const FontWeight normalWeight = FontWeight.w400;
  static const FontWeight mediumWeight = FontWeight.w500;
  static const FontWeight semiboldWeight = FontWeight.w600;

  /// 为包含数字的文本创建样式
  /// 如果文本包含数字，使用 UniveconBold 字体
  static TextStyle withNumberFont(TextStyle base) {
    return base.copyWith(
      fontFamily: numberFontFamily,
      fontFeatures: [const FontFeature.tabularFigures()],
    );
  }

  /// 为纯数字文本创建样式
  static TextStyle numberStyle({
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontFamily: numberFontFamily,
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight ?? normalWeight,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  /// 标题样式（用于卡片标题、区块标题等）
  static TextStyle titleStyle(BuildContext context, {
    double? fontSize,
    Color? color,
  }) {
    final theme = Theme.of(context);
    return TextStyle(
      fontSize: fontSize ?? 16,
      fontWeight: semiboldWeight,
      color: color ?? theme.colorScheme.onSurface,
      letterSpacing: -0.3,
    );
  }

  /// 正文样式
  static TextStyle bodyStyle(BuildContext context, {
    double? fontSize,
    Color? color,
  }) {
    final theme = Theme.of(context);
    return TextStyle(
      fontSize: fontSize ?? 14,
      fontWeight: normalWeight,
      color: color ?? theme.colorScheme.onSurface.withValues(alpha: 0.87),
    );
  }

  /// 次要文本样式（灰色小字）
  static TextStyle captionStyle(BuildContext context, {
    double? fontSize,
    Color? color,
  }) {
    final theme = Theme.of(context);
    return TextStyle(
      fontSize: fontSize ?? 12,
      fontWeight: normalWeight,
      color: color ?? theme.colorScheme.onSurface.withValues(alpha: 0.6),
    );
  }

  /// 按钮文本样式
  static TextStyle buttonStyle({
    double? fontSize,
    Color? color,
  }) {
    return TextStyle(
      fontSize: fontSize ?? 14,
      fontWeight: mediumWeight,
      color: color,
      letterSpacing: 0.1,
    );
  }
}

/// 为 Text Widget 添加便捷扩展
extension TextStyleExtension on Text {
  /// 应用数字字体
  Text asNumber() {
    return Text(
      data ?? '',
      style: style?.copyWith(
        fontFamily: AppTextStyles.numberFontFamily,
        fontFeatures: [const FontFeature.tabularFigures()],
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
