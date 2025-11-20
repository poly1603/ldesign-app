import 'package:flutter/material.dart';
import '../config/text_styles.dart';

/// 数字文本组件
/// 使用特殊字体显示数字，保持数字对齐和美观
class NumberText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool softWrap;

  const NumberText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap = true,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.withNumberFont(style ?? const TextStyle()),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
    );
  }
}

/// 版本号文本组件
/// 专门用于显示版本号，如 v1.0.0
class VersionText extends StatelessWidget {
  final String version;
  final double? fontSize;
  final Color? color;
  final FontWeight? fontWeight;

  const VersionText(
    this.version, {
    super.key,
    this.fontSize,
    this.color,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return NumberText(
      version,
      style: AppTextStyles.numberStyle(
        fontSize: fontSize,
        color: color,
        fontWeight: fontWeight,
      ),
    );
  }
}
