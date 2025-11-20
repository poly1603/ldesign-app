# 字体使用指南

## 字体规范

### 1. 字体粗细统一

整个应用统一使用以下字体粗细标准：

- **常规文本**: `FontWeight.w400` (normal)
- **中等强调**: `FontWeight.w500` (medium) 
- **标题/强调**: `FontWeight.w600` (semibold)
- **避免使用**: `FontWeight.bold` (w700) 和其他非标准粗细

### 2. 数字字体

所有数字使用 **UniveconBold** 字体，包括：
- 版本号 (v1.0.0)
- 数量统计 (12 个项目)
- 百分比 (85%)
- 时间日期
- 文件大小等

## 使用方法

### 方法一：使用预定义的文本样式（推荐）

```dart
import '../config/text_styles.dart';

// 标题文本
Text(
  '卡片标题',
  style: AppTextStyles.titleStyle(context, fontSize: 18),
)

// 正文文本
Text(
  '这是一段正文内容',
  style: AppTextStyles.bodyStyle(context),
)

// 次要文本（灰色小字）
Text(
  '次要信息',
  style: AppTextStyles.captionStyle(context),
)

// 按钮文本
Text(
  '确定',
  style: AppTextStyles.buttonStyle(),
)
```

### 方法二：使用数字组件（推荐用于数字）

```dart
import '../widgets/number_text.dart';

// 显示版本号
VersionText(
  'v1.0.0',
  fontSize: 14,
  color: Colors.grey,
)

// 显示数字统计
NumberText(
  '12',
  style: TextStyle(fontSize: 24, color: Colors.blue),
)
```

### 方法三：手动应用数字字体

```dart
import '../config/text_styles.dart';

// 为包含数字的文本应用数字字体
Text(
  'v25.2.1',
  style: AppTextStyles.withNumberFont(
    TextStyle(fontSize: 14, color: Colors.grey),
  ),
)

// 纯数字样式
Text(
  '11.6.2',
  style: AppTextStyles.numberStyle(
    fontSize: 16,
    color: Colors.blue,
  ),
)
```

## 主题字体

使用主题中预定义的文本样式（已统一字体粗细）：

```dart
// 获取主题
final theme = Theme.of(context);

// 大标题 (w600)
Text('大标题', style: theme.textTheme.headlineSmall)

// 中标题 (w600)
Text('中标题', style: theme.textTheme.titleLarge)

// 小标题 (w500)
Text('小标题', style: theme.textTheme.titleMedium)

// 正文 (w400)
Text('正文内容', style: theme.textTheme.bodyMedium)

// 说明文字 (w400)
Text('说明文字', style: theme.textTheme.bodySmall)
```

## 迁移现有代码

### 需要修改的地方

1. **移除非标准字重**
```dart
// ❌ 不推荐
FontWeight.bold
FontWeight.w700
FontWeight.w800

// ✅ 推荐
FontWeight.w600  // 用于标题
FontWeight.w500  // 用于中等强调
FontWeight.w400  // 用于正文
```

2. **数字文本使用数字字体**
```dart
// ❌ 旧代码
Text('v1.0.0')
Text('25.2.1')

// ✅ 新代码
VersionText('v1.0.0')
NumberText('25.2.1')

// 或
Text(
  'v1.0.0',
  style: AppTextStyles.numberStyle(fontSize: 14),
)
```

## 注意事项

1. **保持一致性**: 整个应用应该使用统一的字体粗细标准
2. **数字可读性**: 所有数字都使用 UniveconBold 字体，确保清晰易读
3. **避免过粗**: 不要使用 FontWeight.w700 及以上的字重
4. **语义化**: 根据文本的语义选择合适的字重（标题用 w600，正文用 w400）
