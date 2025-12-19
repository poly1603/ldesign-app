# 项目详情页增强计划

## 功能清单

### 1. README 查看器 ✅
- [x] 读取并显示 README.md
- [x] Markdown 渲染
- [x] 支持代码高亮

### 2. 依赖管理 (Dependencies Tab)
- [ ] 显示所有依赖（dependencies + devDependencies）
- [ ] 检查依赖更新
- [ ] 显示可升级的依赖
- [ ] 支持单个依赖升级
- [ ] 支持一键全部升级
- [ ] 支持切换依赖版本
- [ ] 支持添加/删除依赖
- [ ] 显示依赖的详细信息

### 3. 脚本管理 (Scripts Tab)
- [ ] 显示所有 npm scripts
- [ ] 支持运行脚本
- [ ] 显示脚本执行日志
- [ ] 支持添加/编辑/删除脚本

### 4. package.json 编辑器
- [ ] 可视化编辑基本信息（name, version, description, author, license）
- [ ] 编辑 repository, bugs, homepage
- [ ] 编辑 keywords
- [ ] 编辑 engines
- [ ] 实时保存

### 5. TypeScript 配置
- [ ] 检测 TypeScript 是否启用
- [ ] 一键启用/禁用 TypeScript
- [ ] tsconfig.json 可视化编辑器
  - [ ] compilerOptions
  - [ ] include/exclude
  - [ ] extends
- [ ] 预设配置模板

### 6. 文件浏览器
- [ ] 树形目录结构
- [ ] 文件搜索
- [ ] 文件过滤（.gitignore）
- [ ] 点击文件查看内容
- [ ] 代码高亮显示
- [ ] 支持编辑文件
- [ ] 支持创建/删除文件

### 7. 配置文件管理
- [ ] .gitignore 可视化编辑
- [ ] .npmrc 可视化编辑
- [ ] .eslintrc 可视化编辑
  - [ ] 一键启用/禁用 ESLint
  - [ ] 规则配置
  - [ ] 预设配置
- [ ] .prettierrc 可视化编辑
- [ ] .editorconfig 可视化编辑

## 实现优先级

### Phase 1: 基础功能（已完成）
1. ✅ README 查看器
2. ✅ 基础页面结构

### Phase 2: 依赖管理（核心功能）
1. 依赖列表显示
2. 检查更新功能
3. 单个升级功能
4. 批量升级功能

### Phase 3: 配置管理
1. package.json 编辑器
2. TypeScript 配置
3. ESLint 配置

### Phase 4: 文件管理
1. 文件浏览器
2. 代码查看器
3. 代码编辑器

### Phase 5: 高级功能
1. .gitignore 编辑器
2. .npmrc 编辑器
3. 其他配置文件

## 技术栈

- **Markdown 渲染**: flutter_markdown
- **代码高亮**: flutter_highlight
- **文件操作**: dart:io
- **JSON 解析**: dart:convert
- **状态管理**: riverpod

## 文件结构

```
lib/presentation/pages/projects/
├── project_detail_page_new.dart          # 主页面
├── tabs/
│   ├── readme_tab.dart                   # README 标签
│   ├── dependencies_tab.dart             # 依赖管理标签
│   ├── scripts_tab.dart                  # 脚本管理标签
│   ├── package_json_tab.dart             # package.json 编辑标签
│   ├── typescript_tab.dart               # TypeScript 配置标签
│   ├── file_browser_tab.dart             # 文件浏览标签
│   └── config_files_tab.dart             # 配置文件标签
├── widgets/
│   ├── dependency_card.dart              # 依赖卡片
│   ├── script_runner.dart                # 脚本运行器
│   ├── file_tree.dart                    # 文件树
│   ├── code_viewer.dart                  # 代码查看器
│   └── config_editor.dart                # 配置编辑器
└── services/
    ├── dependency_service.dart           # 依赖管理服务
    ├── npm_service.dart                  # NPM 操作服务
    └── file_service.dart                 # 文件操作服务
```

## 下一步

由于功能非常庞大，建议：
1. 先完成 Phase 2（依赖管理）
2. 然后逐步实现其他功能
3. 每个功能模块独立开发和测试

是否继续实现 Phase 2 的依赖管理功能？
