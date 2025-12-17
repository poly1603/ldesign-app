import 'package:uuid/uuid.dart';

/// SVG 资源模型
class SvgAsset {
  final String id;
  final String name;
  final String path;
  final String content;
  final int fileSize;
  final DateTime importedAt;

  const SvgAsset({
    required this.id,
    required this.name,
    required this.path,
    required this.content,
    required this.fileSize,
    required this.importedAt,
  });

  /// 创建新 SVG 资源
  factory SvgAsset.create({
    required String name,
    required String path,
    required String content,
    required int fileSize,
  }) {
    return SvgAsset(
      id: const Uuid().v4(),
      name: name,
      path: path,
      content: content,
      fileSize: fileSize,
      importedAt: DateTime.now(),
    );
  }

  factory SvgAsset.fromJson(Map<String, dynamic> json) {
    return SvgAsset(
      id: json['id'] as String? ?? const Uuid().v4(),
      name: json['name'] as String? ?? '',
      path: json['path'] as String? ?? '',
      content: json['content'] as String? ?? '',
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
      'content': content,
      'fileSize': fileSize,
      'importedAt': importedAt.toIso8601String(),
    };
  }

  SvgAsset copyWith({
    String? id,
    String? name,
    String? path,
    String? content,
    int? fileSize,
    DateTime? importedAt,
  }) {
    return SvgAsset(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      content: content ?? this.content,
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SvgAsset && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'SvgAsset(id: $id, name: $name)';
}
