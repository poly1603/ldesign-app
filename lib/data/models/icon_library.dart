import 'package:uuid/uuid.dart';

/// 图标库模型
class IconLibrary {
  final String id;
  final String name;
  final String description;
  final List<String> iconIds; // SVG 资源 ID 列表
  final DateTime createdAt;
  final DateTime updatedAt;

  const IconLibrary({
    required this.id,
    required this.name,
    required this.description,
    required this.iconIds,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 创建新图标库
  factory IconLibrary.create({
    required String name,
    String description = '',
    List<String> iconIds = const [],
  }) {
    final now = DateTime.now();
    return IconLibrary(
      id: const Uuid().v4(),
      name: name,
      description: description,
      iconIds: iconIds,
      createdAt: now,
      updatedAt: now,
    );
  }

  factory IconLibrary.fromJson(Map<String, dynamic> json) {
    return IconLibrary(
      id: json['id'] as String? ?? const Uuid().v4(),
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      iconIds: (json['iconIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconIds': iconIds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  IconLibrary copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? iconIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return IconLibrary(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconIds: iconIds ?? this.iconIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 添加图标
  IconLibrary addIcon(String iconId) {
    if (iconIds.contains(iconId)) return this;
    return copyWith(
      iconIds: [...iconIds, iconId],
      updatedAt: DateTime.now(),
    );
  }

  /// 移除图标
  IconLibrary removeIcon(String iconId) {
    return copyWith(
      iconIds: iconIds.where((id) => id != iconId).toList(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is IconLibrary && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'IconLibrary(id: $id, name: $name, icons: ${iconIds.length})';
}
