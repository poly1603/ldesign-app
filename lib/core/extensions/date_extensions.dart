import 'package:intl/intl.dart';

/// DateTime 扩展方法
extension DateTimeExtensions on DateTime {
  /// 格式化为日期字符串 (yyyy-MM-dd)
  String toDateString() => DateFormat('yyyy-MM-dd').format(this);

  /// 格式化为时间字符串 (HH:mm:ss)
  String toTimeString() => DateFormat('HH:mm:ss').format(this);

  /// 格式化为日期时间字符串 (yyyy-MM-dd HH:mm:ss)
  String toDateTimeString() => DateFormat('yyyy-MM-dd HH:mm:ss').format(this);

  /// 格式化为相对时间（如：刚刚、5分钟前、昨天）
  String toRelativeString() {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inSeconds < 60) {
      return '刚刚';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小时前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}周前';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()}个月前';
    } else {
      return '${(difference.inDays / 365).floor()}年前';
    }
  }

  /// 是否是今天
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// 是否是昨天
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }
}
