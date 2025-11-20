# 字体粗细使用规范

本应用使用统一的字体粗细标准，以确保视觉一致性。

## 标准字体粗细

### FontWeight.w600 (Semibold)
用于所有标题和重要文本：
- 页面主标题（如"首页"、"设置"）
- 卡片标题
- 统计数字
- 项目名称
- 激活状态的导航项
- 按钮文字（部分）
- **使用场景**: 74+ 处

### FontWeight.w500 (Medium)
用于次要标题和强调文本：
- 小标题
- 卡片副标题
- 非激活状态的导航项
- 标签文字
- **使用场景**: 21+ 处

### FontWeight.w400 (Regular)
用于正文和普通文本：
- 描述文字
- 列表内容
- 按钮文字（部分）
- 输入提示
- **使用场景**: 15+ 处

## 全局主题配置 (theme_config.dart)

```dart
displayLarge:    w600  // 超大标题
displayMedium:   w600  // 大标题
displaySmall:    w600  // 中标题
headlineLarge:   w600  // 页面标题-大
headlineMedium:  w600  // 页面标题-中
headlineSmall:   w600  // 页面标题-小
titleLarge:      w600  // 卡片标题-大
titleMedium:     w500  // 卡片标题-中
titleSmall:      w500  // 卡片标题-小
bodyLarge:       w400  // 正文-大
bodyMedium:      w400  // 正文-中
bodySmall:       w400  // 正文-小
labelLarge:      w500  // 标签-大
labelMedium:     w500  // 标签-中
labelSmall:      w500  // 标签-小
```

## 特殊组件

### NumberText / VersionText
使用自定义数字字体 (UNIVECONBOL.TTF)，默认 w600

### 侧边栏导航
- 激活状态: w600
- 非激活状态: w500

## 注意事项

1. **禁止使用** `FontWeight.bold`、`w700`、`w800`、`w900`
2. 所有标题统一使用 `w600`
3. 所有正文统一使用 `w400`
4. 强调文本使用 `w500`
5. 数字显示优先使用 `NumberText` 组件

## 验证

运行以下命令检查不规范的字体粗细使用：

```bash
# 查找所有 w700+ 的使用
grep -r "FontWeight\.w[789]00" lib/

# 查找所有 bold 的使用
grep -r "FontWeight\.bold" lib/
```

当前状态：✅ 已统一
