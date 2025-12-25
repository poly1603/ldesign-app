# 图标迁移映射表

## Material Icons → Lucide Icons

### 常用操作
```dart
Icons.add → LucideIcons.plus
Icons.add_rounded → LucideIcons.plus
Icons.edit → LucideIcons.pencil
Icons.edit_outlined → LucideIcons.pencil
Icons.delete → LucideIcons.trash2
Icons.delete_outline → LucideIcons.trash2
Icons.delete_outline_rounded → LucideIcons.trash2
Icons.save → LucideIcons.save
Icons.refresh → LucideIcons.refreshCw
Icons.refresh_rounded → LucideIcons.refreshCw
Icons.copy → LucideIcons.copy
Icons.copy_rounded → LucideIcons.copy
Icons.download → LucideIcons.download
Icons.upload → LucideIcons.upload
Icons.upload_file → LucideIcons.upload
```

### 导航
```dart
Icons.arrow_back → LucideIcons.arrowLeft
Icons.arrow_forward → LucideIcons.arrowRight
Icons.close → LucideIcons.x
Icons.menu → LucideIcons.menu
Icons.chevron_right → LucideIcons.chevronRight
Icons.chevron_left → LucideIcons.chevronLeft
Icons.more_vert → LucideIcons.moreVertical
Icons.more_vert_rounded → LucideIcons.moreVertical
Icons.more_horiz → LucideIcons.moreHorizontal
```

### 状态
```dart
Icons.check → LucideIcons.check
Icons.check_circle → LucideIcons.checkCircle
Icons.check_circle_outline → LucideIcons.checkCircle
Icons.check_circle_outline_rounded → LucideIcons.checkCircle
Icons.error → LucideIcons.alertCircle
Icons.error_outline → LucideIcons.alertCircle
Icons.warning → LucideIcons.alertTriangle
Icons.warning_outlined → LucideIcons.alertTriangle
Icons.info → LucideIcons.info
Icons.info_outline → LucideIcons.info
```

### 文件和文档
```dart
Icons.folder → LucideIcons.folder
Icons.folder_outlined → LucideIcons.folder
Icons.folder_open → LucideIcons.folderOpen
Icons.description → LucideIcons.fileText
Icons.description_outlined → LucideIcons.fileText
Icons.insert_drive_file → LucideIcons.file
Icons.code → LucideIcons.code
Icons.code_outlined → LucideIcons.code2
```

### 图片和媒体
```dart
Icons.image → LucideIcons.image
Icons.image_outlined → LucideIcons.image
Icons.photo → LucideIcons.image
Icons.collections → LucideIcons.images
Icons.collections_outlined → LucideIcons.images
Icons.palette → LucideIcons.palette
Icons.photo_size_select_large → LucideIcons.maximize2
Icons.format_color_fill → LucideIcons.paintBucket
Icons.view_module → LucideIcons.grid
```

### 开发工具
```dart
Icons.terminal → LucideIcons.terminal
Icons.bug_report → LucideIcons.bug
Icons.build → LucideIcons.wrench
Icons.build_circle → LucideIcons.wrench
Icons.settings → LucideIcons.settings
Icons.settings_outlined → LucideIcons.settings
Icons.source → LucideIcons.gitBranch
Icons.source_outlined → LucideIcons.gitBranch
```

### 网络和云
```dart
Icons.cloud → LucideIcons.cloud
Icons.cloud_download → LucideIcons.cloudDownload
Icons.cloud_upload → LucideIcons.cloudUpload
Icons.link → LucideIcons.link
Icons.network_check → LucideIcons.wifi
Icons.network_check_rounded → LucideIcons.wifi
```

### 用户和账户
```dart
Icons.person → LucideIcons.user
Icons.person_rounded → LucideIcons.user
Icons.login → LucideIcons.logIn
Icons.login_rounded → LucideIcons.logIn
Icons.logout → LucideIcons.logOut
Icons.vpn_key → LucideIcons.key
Icons.vpn_key_rounded → LucideIcons.key
```

### 媒体控制
```dart
Icons.play_arrow → LucideIcons.play
Icons.play_arrow_rounded → LucideIcons.play
Icons.stop → LucideIcons.square
Icons.stop_rounded → LucideIcons.square
Icons.pause → LucideIcons.pause
```

### 其他
```dart
Icons.search → LucideIcons.search
Icons.filter → LucideIcons.filter
Icons.sort → LucideIcons.arrowUpDown
Icons.clear → LucideIcons.x
Icons.inbox → LucideIcons.inbox
Icons.inbox_outlined → LucideIcons.inbox
Icons.inventory_2 → LucideIcons.package
Icons.inventory_2_outlined → LucideIcons.package
Icons.dashboard → LucideIcons.layoutDashboard
Icons.dashboard_outlined → LucideIcons.layoutDashboard
Icons.text_fields → LucideIcons.type
Icons.text_fields_outlined → LucideIcons.type
Icons.add_to_photos → LucideIcons.folderPlus
Icons.storage → LucideIcons.database
Icons.storage_rounded → LucideIcons.database
Icons.memory → LucideIcons.cpu
Icons.memory_rounded → LucideIcons.cpu
Icons.touch_app → LucideIcons.hand
Icons.touch_app_rounded → LucideIcons.hand
Icons.swap_horiz → LucideIcons.repeat
Icons.access_time → LucideIcons.clock
Icons.label → LucideIcons.tag
Icons.public → LucideIcons.globe
Icons.public_rounded → LucideIcons.globe
Icons.computer → LucideIcons.monitor
Icons.computer_rounded → LucideIcons.monitor
```

## 使用方法

1. 在文件顶部添加导入：
```dart
import 'package:lucide_icons/lucide_icons.dart';
```

2. 替换图标：
```dart
// 旧代码
Icon(Icons.add)

// 新代码
Icon(LucideIcons.plus)
```

3. 在按钮中使用：
```dart
// 旧代码
FilledButton.icon(
  icon: Icon(Icons.add),
  label: Text('添加'),
  onPressed: () {},
)

// 新代码
FilledButton.icon(
  icon: Icon(LucideIcons.plus),
  label: Text('添加'),
  onPressed: () {},
)
```
