# Rust 核心库

这是 Flutter 应用的 Rust 核心性能模块,提供高性能的系统信息采集、文件操作和进程管理功能。

## 🚀 快速开始

### 前置要求

1. **安装 Rust**
   ```bash
   # Windows
   winget install Rustlang.Rustup
   
   # macOS/Linux
   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
   ```

2. **验证安装**
   ```bash
   rustc --version
   cargo --version
   ```

### 构建步骤

#### Windows
```bat
# 使用构建脚本
scripts\build_rust.bat

# 或手动构建
cd rust
cargo build --release
copy target\release\rust_core.dll ..\
```

#### macOS/Linux
```bash
# 使用构建脚本
chmod +x scripts/build_rust.sh
./scripts/build_rust.sh

# 或手动构建
cd rust
cargo build --release
cp target/release/librust_core.{dylib,so} ../
```

### 开发命令

```bash
# 检查代码(快速,不编译)
cargo check

# 编译 debug 版本
cargo build

# 编译 release 版本(优化)
cargo build --release

# 运行测试
cargo test

# 运行测试并显示输出
cargo test -- --nocapture

# 清理构建产物
cargo clean

# 更新依赖
cargo update

# 查看依赖树
cargo tree
```

## 📦 模块结构

```
rust/
├── Cargo.toml          # 项目配置和依赖
├── Cargo.lock          # 依赖锁定文件
├── build.rs            # 构建脚本
├── src/
│   ├── lib.rs          # 库入口
│   ├── api.rs          # FFI API 定义
│   ├── system_info/    # 系统信息模块 (待实现)
│   ├── file_ops/       # 文件操作模块 (待实现)
│   └── process_mgr/    # 进程管理模块 (待实现)
└── target/             # 编译输出目录
    └── release/
        ├── rust_core.dll      # Windows
        ├── librust_core.dylib # macOS
        └── librust_core.so    # Linux
```

## 🔧 当前功能

### 已实现
- ✅ 基础 FFI 框架
- ✅ Hello World 示例函数
- ✅ 基础系统信息获取

### 待实现
- 📝 完整系统信息采集模块
- 📝 高性能文件操作模块
- 📝 智能进程管理模块

## 🧪 测试

运行所有测试:
```bash
cargo test
```

运行特定测试:
```bash
cargo test test_greet
cargo test test_system_info
```

查看测试覆盖率:
```bash
cargo install cargo-tarpaulin
cargo tarpaulin --out Html
```

## 🐛 调试

### 启用日志
```rust
// 在代码中添加
#[cfg(debug_assertions)]
println!("Debug: {:?}", value);
```

### 使用 LLDB/GDB
```bash
# macOS
lldb target/debug/rust_core

# Linux
gdb target/debug/rust_core
```

## 📊 性能分析

```bash
# 安装 flamegraph
cargo install flamegraph

# 生成性能火焰图
cargo flamegraph --bench your_benchmark
```

## 🔒 安全性

- 所有 `unsafe` 代码都有详细注释说明
- 使用 `clippy` 进行代码检查
- 遵循 Rust 所有权和借用规则

## 📚 参考资源

- [Rust Book](https://doc.rust-lang.org/book/)
- [flutter_rust_bridge](https://cjycode.com/flutter_rust_bridge/)
- [sysinfo crate](https://docs.rs/sysinfo/)
- [tokio async runtime](https://tokio.rs/)

## 🤝 贡献指南

1. 创建功能分支
2. 编写代码和测试
3. 运行 `cargo fmt` 格式化代码
4. 运行 `cargo clippy` 检查代码
5. 提交 PR

## 📄 许可证

与主项目保持一致