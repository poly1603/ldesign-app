import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

/// 统一的弹窗工具类
class DialogUtils {
  /// 显示确认对话框
  static Future<bool> showConfirmDialog({
    required BuildContext context,
    required String title,
    required String content,
    String? confirmText,
    String? cancelText,
    Color? confirmColor,
    bool isDangerous = false,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText ?? l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              confirmText ?? l10n.confirm,
              style: TextStyle(
                color: isDangerous ? Colors.red : (confirmColor ?? Theme.of(context).colorScheme.primary),
              ),
            ),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }

  /// 显示成功提示
  static void showSuccessSnackBar({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 2),
  }) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: duration,
      ),
    );
  }

  /// 显示错误提示
  static void showErrorSnackBar({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: duration,
        action: action,
      ),
    );
  }

  /// 显示普通提示
  static void showInfoSnackBar({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 2),
  }) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
      ),
    );
  }

  /// 显示加载对话框
  static void showLoadingDialog({
    required BuildContext context,
    String? message,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(message),
            ],
          ],
        ),
      ),
    );
  }

  /// 关闭加载对话框
  static void dismissDialog(BuildContext context) {
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }
}
