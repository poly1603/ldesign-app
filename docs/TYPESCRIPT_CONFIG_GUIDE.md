# TypeScript 配置完整指南

## 概述

项目详情页的 TypeScript 配置标签提供了全面的 TypeScript 配置管理功能，包括版本切换和所有主要配置选项。

## 功能特性

### 1. 版本管理

#### 支持的版本
- TypeScript 5.7.2（最新）
- TypeScript 5.6.3
- TypeScript 5.5.4
- TypeScript 5.4.5
- TypeScript 5.3.3
- TypeScript 5.2.2
- TypeScript 5.1.6
- TypeScript 5.0.4
- TypeScript 4.9.5
- TypeScript 4.8.4
- TypeScript 4.7.4

#### 版本切换功能
- 在状态卡片中选择目标版本
- 自动更新 package.json 中的 typescript 依赖版本
- 自动运行 npm install 安装新版本
- 根据版本自动调整配置选项（移除不支持的特性）

### 2. 配置选项

#### 基础编译选项

**Target** - 指定 ECMAScript 目标版本
- ES3, ES5, ES6/ES2015, ES2016, ES2017, ES2018, ES2019, ES2020, ES2021, ES2022, ESNext

**Module** - 指定模块代码生成方式
- CommonJS, AMD, UMD, System, ES6/ES2015, ES2020, ES2022, ESNext, Node16, NodeNext, None

**Module Resolution** - 指定模块解析策略
- node, node16, nodenext, classic, bundler

**JSX** - 指定 JSX 代码生成方式
- preserve, react, react-jsx, react-jsxdev, react-native

#### 严格类型检查

**Strict** - 启用所有严格类型检查选项
- 启用后，以下所有选项自动启用
- 禁用后，可以单独控制每个选项

**单独的严格选项**（当 Strict 禁用时可见）：
- **No Implicit Any** - 禁止隐式 any 类型
- **Strict Null Checks** - 启用严格的 null 检查
- **Strict Function Types** - 启用严格的函数类型检查
- **Strict Bind Call Apply** - 启用严格的 bind/call/apply 检查
- **Strict Property Initialization** - 启用严格的属性初始化检查
- **No Implicit This** - 禁止隐式 this 类型
- **Always Strict** - 以严格模式解析并为每个源文件生成 "use strict"

#### 额外检查

- **No Unused Locals** - 报告未使用的局部变量
- **No Unused Parameters** - 报告未使用的参数
- **No Implicit Returns** - 报告函数中缺少返回语句
- **No Fallthrough Cases In Switch** - 报告 switch 语句的 fallthrough 错误
- **No Unchecked Indexed Access** - 在索引签名结果中包含 undefined（TypeScript 5.0+）
- **No Implicit Override** - 确保派生类中的覆盖成员标记有 override 修饰符（TypeScript 5.0+）
- **No Property Access From Index Signature** - 强制使用索引访问器访问使用索引类型声明的键（TypeScript 5.0+）

#### 模块选项

- **ES Module Interop** - 启用 ES 模块互操作性
- **Allow Synthetic Default Imports** - 允许从没有默认导出的模块中默认导入
- **Resolve JSON Module** - 允许导入 JSON 文件
- **Isolated Modules** - 确保每个文件可以独立转译

#### 输出选项

- **Declaration** - 生成相应的 .d.ts 文件
- **Declaration Map** - 为 .d.ts 文件生成 sourcemap
- **Source Map** - 生成相应的 .map 文件
- **Inline Source Map** - 生成单个内联 sourcemap 文件
- **Remove Comments** - 删除所有注释
- **Import Helpers** - 从 tslib 导入辅助工具函数
- **Downlevel Iteration** - 为迭代器提供完整支持

#### 其他选项

- **Skip Lib Check** - 跳过声明文件的类型检查
- **Force Consistent Casing In File Names** - 强制文件名大小写一致
- **Allow JS** - 允许编译 JavaScript 文件
- **Check JS** - 在 .js 文件中报告错误
- **Incremental** - 启用增量编译
- **Composite** - 启用项目编译的约束
- **Experimental Decorators** - 启用实验性的装饰器特性
- **Emit Decorator Metadata** - 为装饰器提供元数据支持

## 使用方法

### 启用 TypeScript

1. 打开项目详情页
2. 切换到 "TypeScript" 标签
3. 点击 "启用 TypeScript" 按钮
4. 系统会自动：
   - 创建 tsconfig.json 配置文件
   - 安装最新版本的 TypeScript
   - 安装 @types/node

### 切换版本

1. 在状态卡片中找到 "切换版本" 下拉框
2. 选择目标版本
3. 确认切换操作
4. 等待安装完成

**注意**：
- 切换到较旧版本时，某些新特性会被自动禁用
- TypeScript 4.x 不支持某些 5.x 特性

### 配置选项

1. 在各个配置卡片中调整选项
2. 使用下拉框选择编译目标和模块系统
3. 使用开关切换各种检查选项
4. 点击 "保存配置" 按钮保存更改

### 禁用 TypeScript

1. 点击状态卡片中的 "禁用" 按钮
2. 确认操作
3. tsconfig.json 文件会被删除
4. TypeScript 包不会被卸载（需要手动卸载）

## 版本兼容性

### TypeScript 5.x 特性
- 所有配置选项完全支持
- 包括最新的类型检查选项

### TypeScript 4.x 限制
- 不支持 `noUncheckedIndexedAccess`
- 不支持 `noImplicitOverride`
- 不支持 `noPropertyAccessFromIndexSignature`
- 切换到 4.x 版本时，这些选项会自动禁用

## 推荐配置

### 严格模式（推荐用于新项目）
```json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "ESNext",
    "moduleResolution": "node",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "isolatedModules": true
  }
}
```

### React 项目配置
```json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "jsx": "react-jsx",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "allowSyntheticDefaultImports": true
  }
}
```

### Node.js 项目配置
```json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "CommonJS",
    "moduleResolution": "node",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "declaration": true,
    "outDir": "./dist",
    "rootDir": "./src"
  }
}
```

## 故障排除

### 问题：版本切换失败
**解决方案**：
- 检查网络连接
- 确认 npm 可以正常访问
- 手动运行 `npm install typescript@版本号`

### 问题：配置保存后不生效
**解决方案**：
- 重启开发服务器
- 检查 tsconfig.json 文件是否正确生成
- 确认 IDE 已重新加载配置

### 问题：某些选项不可用
**解决方案**：
- 检查 TypeScript 版本
- 某些选项仅在特定版本中可用
- 考虑升级到最新版本

## 技术实现

### 文件结构
```
lib/presentation/pages/projects/tabs/
└── typescript_tab.dart  # TypeScript 配置标签
```

### 关键功能
- 自动检测 TypeScript 是否已启用
- 读取和解析 tsconfig.json
- 读取 package.json 获取当前版本
- 版本切换时同步更新 package.json
- 根据版本调整可用配置选项
- 生成完整的配置对象并保存

### 配置生成逻辑
- 只保存非默认值的配置
- 严格模式启用时，不单独保存子选项
- 布尔值为 false 时不保存（除非是重要选项）
- 保持配置文件简洁易读

## 更新日志

### 2024-12-24
- ✅ 添加 TypeScript 版本切换功能
- ✅ 支持 11 个主要 TypeScript 版本
- ✅ 添加 60+ 个配置选项
- ✅ 实现版本兼容性检查
- ✅ 自动更新 package.json
- ✅ 根据版本调整可用配置
- ✅ 完整的配置分类和说明
