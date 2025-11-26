# Flutter + Rust 集成快速开始指南

## 🚀 快速开始 (10分钟上手)

### 前置要求

#### 必需工具
- **Flutter SDK** >= 3.10.0 (已安装 ✓)
- **Rust** >= 1.70.0 (需要安装)
- **Cargo** (Rust 包管理器,随 Rust 安装)

#### Windows 额外要求
- Visual Studio Build Tools 2019+ 或 Visual Studio 2019+
- Windows 10 SDK

### 第一步: 安装 Rust

#### Windows
```powershell
# 方法1: 使用 rustup 官方安装器
# 访问 https://rustup.rs 下载并运行

# 方法2: 使用 winget
winget install Rustlang.Rustup

# 验证安装
rustc --version
cargo --version
```

#### macOS/Linux
```bash
# 使用 rustup
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# 验证安装
rustc --version
cargo --version
```

### 第二步: 安装 flutter_rust_bridge 工具

```bash
# 安装代码生成工具
cargo install flutter_rust_bridge_codegen

# 验证安装
flutter_rust_bridge_codegen --version
```

### 第三步: 项目配置

#### 1. 添加 Dart 依赖

编辑 `pubspec.yaml`:
```yaml
dependencies:
  flutter:
    sdk: flutter
  ffi: ^2.1.0
  flutter_rust_bridge: ^2.0.0
  
dev_dependencies:
  ffigen: ^11.0.0
```

运行:
```bash
flutter pub get
```

#### 2. 创建 Rust 项目

在项目根目录执行:
```bash
# 创建 Rust 库项目
cargo new --lib rust

cd rust

# 编辑 Cargo.toml,添加依赖
```

编辑 `rust/Cargo.toml`:
```toml
[package]
name = "rust_core"
version = "0.1.0"
edition = "2021"

[lib]
crate-type = ["cdylib"]

[dependencies]
flutter_rust_bridge = "2"
```

### 第四步: Hello World 示例

#### 1. Rust 代码 (rust/src/api.rs)

```rust
// 简单的 Hello World 函数
#[flutter_rust_bridge::frb(sync)]
pub fn greet(name: String) -> String {
    format!("Hello, {}!", name)
}

// 获取系统信息示例
pub struct SystemInfo {
    pub os: String,
    pub cpu_count: u32,
}

#[flutter_rust_bridge::frb(sync)]
pub fn get_system_info() -> SystemInfo {
    SystemInfo {
        os: std::env::consts::OS.to_string(),
        cpu_count: num_cpus::get() as u32,
    }
}
```

#### 2. Rust 入口 (rust/src/lib.rs)

```rust
mod api;

// flutter_rust_bridge 会自动生成其他必需代码
```

#### 3. 生成桥接代码

```bash
# 在项目根目录执行
flutter_rust_bridge_codegen \
    --rust-input rust/src/api.rs \
    --dart-output lib/bridge_generated.dart
```

#### 4. Dart 调用代码

创建 `lib/services/rust_bridge.dart`:
```dart
import '../bridge_generated.dart';
import 'dart:ffi';
import 'dart:io';

class RustBridge {
  static RustCore? _instance;
  
  static RustCore get instance {
    if (_instance == null) {
      final dylib = _loadLibrary();
      _instance = RustCoreImpl(dylib);
    }
    return _instance!;
  }
  
  static DynamicLibrary _loadLibrary() {
    if (Platform.isWindows) {
      return DynamicLibrary.open('rust_core.dll');
    } else if (Platform.isMacOS) {
      return DynamicLibrary.open('librust_core.dylib');
    } else {
      return DynamicLibrary.open('librust_core.so');
    }
  }
}

// 使用示例
Future<void> testRustBridge() async {
  final bridge = RustBridge.instance;
  
  // 调用 greet 函数
  final greeting = bridge.greet(name: 'Flutter');
  print(greeting); // 输出: Hello, Flutter!
  
  // 获取系统信息
  final info = bridge.getSystemInfo();
  print('OS: ${info.os}, CPUs: ${info.cpuCount}');
}
```

### 第五步: 编译 Rust 库

#### Windows
```bash
cd rust
cargo build --release

# 编译后的 DLL 位于: rust/target/release/rust_core.dll
# 复制到 Flutter 项目根目录或系统路径
```

#### macOS
```bash
cd rust
cargo build --release

# 编译后的 dylib 位于: rust/target/release/librust_core.dylib
```

#### Linux
```bash
cd rust
cargo build --release

# 编译后的 so 位于: rust/target/release/librust_core.so
```

### 第六步: 测试运行

```bash
# 回到项目根目录
cd ..

# 运行 Flutter 应用
flutter run -d windows  # 或 macos, linux
```

## 🎯 关键命令速查

### 开发流程
```bash
# 1. 修改 Rust 代码
vim rust/src/api.rs

# 2. 重新生成桥接代码
flutter_rust_bridge_codegen \
    --rust-input rust/src/api.rs \
    --dart-output lib/bridge_generated.dart

# 3. 编译 Rust 库
cd rust && cargo build --release && cd ..

# 4. 运行 Flutter 应用
flutter run
```

### 常用 Cargo 命令
```bash
# 检查代码 (不编译)
cargo check

# 编译 (debug 模式)
cargo build

# 编译 (release 模式,优化)
cargo build --release

# 运行测试
cargo test

# 清理构建产物
cargo clean

# 更新依赖
cargo update
```

## 📁 项目结构总览

```
app/
├── lib/
│   ├── bridge_generated.dart    # 自动生成,勿手动编辑
│   ├── services/
│   │   └── rust_bridge.dart     # Rust 桥接服务
│   └── ...
├── rust/
│   ├── Cargo.toml               # Rust 项目配置
│   ├── Cargo.lock              # 依赖锁定文件
│   ├── src/
│   │   ├── lib.rs              # 库入口
│   │   └── api.rs              # FFI API 定义
│   └── target/                  # 编译输出目录
│       └── release/
│           └── rust_core.dll    # Windows
│           └── librust_core.dylib  # macOS
│           └── librust_core.so  # Linux
└── pubspec.yaml
```

## 🐛 常见问题排查

### 问题 1: 找不到动态库
```
Error: The library 'rust_core.dll' was not found
```

**解决方案**:
1. 确认已编译 Rust 库: `cargo build --release`
2. 复制动态库到正确位置
3. 检查库文件名是否正确

### 问题 2: FFI 调用崩溃
```
Unhandled exception: Invalid argument(s)
```

**解决方案**:
1. 检查数据类型是否匹配
2. 确保字符串使用 UTF-8 编码
3. 验证指针和内存管理

### 问题 3: 桥接代码生成失败
```
Error: Could not generate bridge code
```

**解决方案**:
1. 检查 Rust 代码语法
2. 确认使用了正确的宏注解
3. 更新 flutter_rust_bridge 版本

### 问题 4: Windows 编译错误
```
error: linker `link.exe` not found
```

**解决方案**:
1. 安装 Visual Studio Build Tools
2. 重启终端以更新环境变量
3. 运行 `rustup default stable-msvc`

## 🎓 学习资源

### 官方文档
- [flutter_rust_bridge 文档](https://cjycode.com/flutter_rust_bridge/)
- [Rust 语言书](https://doc.rust-lang.org/book/)
- [Dart FFI 文档](https://dart.dev/guides/libraries/c-interop)

### 推荐阅读
1. Rust 异步编程
2. FFI 最佳实践
3. 跨平台构建策略

## 🚦 下一步

完成基础配置后,可以开始实现具体模块:

1. ✅ 完成 Hello World 测试
2. 📝 实现系统信息采集模块
3. 📝 实现文件操作模块
4. 📝 实现进程管理模块
5. 📝 性能测试和优化

## 💡 开发提示

### 调试技巧
```rust
// Rust 侧添加日志
#[cfg(debug_assertions)]
println!("Debug: {}", value);

// 使用 env_logger
env_logger::init();
log::info!("System info collected");
```

```dart
// Dart 侧调试
debugPrint('Calling Rust function...');
try {
  final result = bridge.someFunction();
  debugPrint('Result: $result');
} catch (e) {
  debugPrint('Error: $e');
}
```

### 性能分析
```bash
# Rust 性能分析
cargo install flamegraph
cargo flamegraph --bin your_app

# Flutter 性能分析
flutter run --profile
# 然后使用 DevTools
```

## ✅ 验收检查清单

完成以下检查后,可以开始实际开发:

- [ ] Rust 工具链安装成功
- [ ] flutter_rust_bridge_codegen 可用
- [ ] Hello World 示例运行成功
- [ ] 能够成功编译 Rust 库
- [ ] FFI 调用正常工作
- [ ] 理解基本的开发流程
- [ ] 知道如何调试问题

---

准备好了吗? 让我们开始构建高性能的 Flutter+Rust 应用! 🚀