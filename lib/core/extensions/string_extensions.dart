/// String 扩展方法
extension StringExtensions on String {
  /// 首字母大写
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// 是否为空或仅包含空白字符
  bool get isBlank => trim().isEmpty;

  /// 是否不为空且不仅包含空白字符
  bool get isNotBlank => !isBlank;

  /// 截断字符串
  String truncate(int maxLength, {String suffix = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - suffix.length)}$suffix';
  }
}

/// 可空 String 扩展方法
extension NullableStringExtensions on String? {
  /// 是否为 null 或空
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  /// 是否不为 null 且不为空
  bool get isNotNullOrEmpty => !isNullOrEmpty;

  /// 是否为 null 或仅包含空白字符
  bool get isNullOrBlank => this == null || this!.isBlank;

  /// 返回非空值或默认值
  String orDefault([String defaultValue = '']) => this ?? defaultValue;
}
