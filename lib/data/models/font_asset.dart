import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

/// 字体资源模型
class FontAsset {
  final String id;
  final String name;
  final String path;
  final String fontFamily;
  final FontWeight weight;
  final FontStyle style;
  final int fileSize;
  final DateTime importedAt;

  const FontAsset({
    required this.id,
    required this.name,
    required this.path,
    required this.fontFamily,
    required this.weight,
    required this.style,
    required this.fileSize,
    required this.importedAt,
  });

  /// 创建新字体资源
  factory FontAsset.create({
    required String name,
    required String path,
    required String fontFamily,
    FontWeight weight = FontWeight.normal,
    FontStyle style = FontStyle.normal,
    required int fileSize,
  }) {
    return FontAsset(
      id: const Uuid().v4(),
      name: name,
      path: path,
      fontFamily: fontFamily,
      weight: weight,
      style: style,
      fileSize: fileSize,
      importedAt: DateTime.now(),
    );
  }

  factory FontAsset.fromJson(Map<String, dynamic> json) {
    return FontAsset(
      id: json['id'] as String? ?? const Uuid().v4(),
      name: json['name'] as String? ?? '',
      path: json['path'] as String? ?? '',
      fontFamily: json['fontFamily'] as String? ?? '',
      weight: _fontWeightFromIndex(json['weight'] as int? ?? 3),
      style: json['style'] == 'italic' ? FontStyle.italic : FontStyle.normal,
      fileSize: json['fileSize'] as int? ?? 0,
      importedAt: json['importedAt'] != null
          ? DateTime.parse(json['importedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'path': path,
      'fontFamily': fontFamily,
      'weight': _fontWeightToIndex(weight),
      'style': style == FontStyle.italic ? 'italic' : 'normal',
      'fileSize': fileSize,
      'importedAt': importedAt.toIso8601String(),
    };
  }

  FontAsset copyWith({
    String? id,
    String? name,
    String? path,
    String? fontFamily,
    FontWeight? weight,
    FontStyle? style,
    int? fileSize,
    DateTime? importedAt,
  }) {
    return FontAsset(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      fontFamily: fontFamily ?? this.fontFamily,
      weight: weight ?? this.weight,
      style: style ?? this.style,
      fileSize: fileSize ?? this.fileSize,
      importedAt: importedAt ?? this.importedAt,
    );
  }

  /// 获取格式化的文件大小
  String get formattedSize {
    if (fileSize < 1024) {
      return '$fileSize B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  /// 获取字重显示名称
  String get weightName {
    switch (weight) {
      case FontWeight.w100:
        return 'Thin';
      case FontWeight.w200:
        return 'Extra Light';
      case FontWeight.w300:
        return 'Light';
      case FontWeight.w400:
        return 'Regular';
      case FontWeight.w500:
        return 'Medium';
      case FontWeight.w600:
        return 'Semi Bold';
      case FontWeight.w700:
        return 'Bold';
      case FontWeight.w800:
        return 'Extra Bold';
      case FontWeight.w900:
        return 'Black';
      default:
        return 'Regular';
    }
  }

  static FontWeight _fontWeightFromIndex(int index) {
    const weights = [
      FontWeight.w100,
      FontWeight.w200,
      FontWeight.w300,
      FontWeight.w400,
      FontWeight.w500,
      FontWeight.w600,
      FontWeight.w700,
      FontWeight.w800,
      FontWeight.w900,
    ];
    if (index >= 0 && index < weights.length) {
      return weights[index];
    }
    return FontWeight.w400;
  }

  static int _fontWeightToIndex(FontWeight weight) {
    const weights = [
      FontWeight.w100,
      FontWeight.w200,
      FontWeight.w300,
      FontWeight.w400,
      FontWeight.w500,
      FontWeight.w600,
      FontWeight.w700,
      FontWeight.w800,
      FontWeight.w900,
    ];
    return weights.indexOf(weight);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FontAsset && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'FontAsset(id: $id, name: $name, fontFamily: $fontFamily)';
}
