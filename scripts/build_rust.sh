#!/bin/bash
# Rust 构建脚本 (macOS/Linux)

set -e

echo "🦀 开始构建 Rust 库..."

# 进入 Rust 目录
cd rust

# 清理之前的构建
echo "📦 清理旧的构建产物..."
cargo clean

# 编译 Release 版本
echo "🔨 编译 Rust 库 (Release 模式)..."
cargo build --release

# 复制动态库到项目根目录
echo "📋 复制动态库..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    cp target/release/librust_core.dylib ../
    echo "✅ 已复制 librust_core.dylib"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    cp target/release/librust_core.so ../
    echo "✅ 已复制 librust_core.so"
fi

echo "✨ Rust 库构建完成!"