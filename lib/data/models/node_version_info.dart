/// Node 版本详细信息
class NodeVersionInfo {
  final String version;
  final DateTime date;
  final List<String> files;
  final String? npm;
  final String? v8;
  final String? uv;
  final String? zlib;
  final String? openssl;
  final String? modules;
  final bool lts;
  final String? ltsName;
  final bool security;

  const NodeVersionInfo({
    required this.version,
    required this.date,
    required this.files,
    this.npm,
    this.v8,
    this.uv,
    this.zlib,
    this.openssl,
    this.modules,
    this.lts = false,
    this.ltsName,
    this.security = false,
  });

  factory NodeVersionInfo.fromJson(Map<String, dynamic> json) {
    return NodeVersionInfo(
      version: (json['version'] as String).replaceFirst('v', ''),
      date: DateTime.parse(json['date'] as String),
      files: (json['files'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      npm: json['npm'] as String?,
      v8: json['v8'] as String?,
      uv: json['uv'] as String?,
      zlib: json['zlib'] as String?,
      openssl: json['openssl'] as String?,
      modules: json['modules'] as String?,
      lts: json['lts'] is String ? true : false,
      ltsName: json['lts'] is String ? json['lts'] as String : null,
      security: json['security'] as bool? ?? false,
    );
  }

  /// 获取显示的版本号（带 v 前缀）
  String get displayVersion => 'v$version';

  /// 获取主版本号
  int get majorVersion {
    final parts = version.split('.');
    return int.tryParse(parts[0]) ?? 0;
  }

  /// 是否是偶数版本（稳定版）
  bool get isStable => majorVersion % 2 == 0;

  /// 获取版本标签
  List<String> get tags {
    final tags = <String>[];
    if (lts) tags.add('LTS');
    if (ltsName != null) tags.add(ltsName!);
    if (security) tags.add('Security');
    if (!isStable) tags.add('Current');
    return tags;
  }

  /// 格式化日期
  String get formattedDate {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
