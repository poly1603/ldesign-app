@echo off
REM Rust 构建脚本 (Windows)

echo 🦀 开始构建 Rust 库...

REM 进入 Rust 目录
cd rust

REM 清理之前的构建
echo 📦 清理旧的构建产物...
cargo clean

REM 编译 Release 版本
echo 🔨 编译 Rust 库 (Release 模式)...
cargo build --release

if %ERRORLEVEL% NEQ 0 (
    echo ❌ 编译失败!
    exit /b %ERRORLEVEL%
)

REM 复制动态库到项目根目录
echo 📋 复制动态库...
copy target\release\rust_core.dll ..\ >nul
if %ERRORLEVEL% EQU 0 (
    echo ✅ 已复制 rust_core.dll
) else (
    echo ❌ 复制失败!
    exit /b %ERRORLEVEL%
)

cd ..

echo ✨ Rust 库构建完成!