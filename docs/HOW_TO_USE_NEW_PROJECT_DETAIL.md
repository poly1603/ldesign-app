# 项目详情页增强功能 - 使用指南

## 概述

增强版项目详情页提供了全面的项目管理功能，包括 README 查看、依赖管理、脚本执行、配置编辑等。

## ✅ 已完成功能

### 1. README 查看
- 自动加载并渲染项目的 README.md 文件
- 支持完整的 Markdown 语法
- 可选择和复制内容

### 2. 依赖管理
- 查看所有依赖（dependencies 和 devDependencies）
- 检查依赖更新
- 单个依赖升级
- 批量升级所有过期依赖
- 添加/删除依赖
- 搜索和筛选功能

### 3. 脚本管理
- 查看 package.json 中定义的所有脚本
- 一键运行脚本
- 实时查看脚本输出
- 添加/编辑/删除脚本

### 4. package.json 编辑
- 可视化编辑项目基本信息（name, version, description 等）
- 编辑 author, license, repository 等字段
- 管理 keywords
- 编辑 engines 配置

### 5. TypeScript 配置
- 启用/禁用 TypeScript
- 可视化编辑 tsconfig.json
- 常用配置项快速设置

### 6. 文件浏览器
- 树形展示项目目录结构
- 点击文件查看内容
- 代码高亮显示
- 支持编辑文件内容

### 7. 配置文件管理
- .gitignore 编辑
- .npmrc 编辑
- .eslintrc 编辑
- 其他常用配置文件

## 使用方法

### 打开项目详情页

在项目列表页面，点击任意项目卡片即可打开增强版项目详情页。路由已自动更新为使用 `EnhancedProjectDetailPage`。

### 切换标签页

页面顶部提供了 7 个标签页，点击即可切换：
- README
- 依赖管理
- 脚本
- package.json
- TypeScript
- 文件浏览
- 配置文件

### 依赖管理操作

1. **检查更新**：点击"检查更新"按钮，系统会查询所有依赖的最新版本
2. **升级依赖**：
   - 单个升级：点击依赖项右侧的"升级"按钮
   - 批量升级：点击"全部升级"按钮升级所有过期依赖
3. **添加依赖**：点击"添加依赖"按钮，输入包名和版本
4. **删除依赖**：点击依赖项右侧的删除图标

### 运行脚本

1. 在"脚本"标签页中找到要运行的脚本
2. 点击"运行"按钮
3. 在弹出的对话框中查看实时输出
4. 脚本执行完成后可以关闭对话框

### 编辑配置文件

1. 切换到相应的标签页（TypeScript、配置文件等）
2. 直接在编辑器中修改内容
3. 点击"保存"按钮保存更改

## 技术实现

### 文件结构

```
lib/presentation/pages/projects/
├── project_detail_page_new.dart      # 主页面
└── tabs/
    ├── dependencies_tab.dart         # 依赖管理
    ├── scripts_tab.dart              # 脚本管理
    ├── package_json_tab.dart         # package.json 编辑
    ├── typescript_tab.dart           # TypeScript 配置
    ├── file_browser_tab.dart         # 文件浏览器
    └── config_files_tab.dart         # 配置文件管理
```

### 关键特性

- 使用 TabController 管理多个标签页
- 异步加载项目数据
- 实时更新 UI
- 错误处理和用户反馈
- Material 3 设计风格

## 更新日志

### 2024-12-23
- ✅ 完成所有 7 个标签页的实现
- ✅ 修复所有编译错误
- ✅ 更新路由使用新的增强版页面
- ✅ 所有功能测试通过

## 已知问题

无

## 未来计划

- 添加更多配置文件支持（.prettierrc, .babelrc 等）
- 支持 Git 操作集成
- 添加项目统计和分析功能
- 支持自定义脚本模板
