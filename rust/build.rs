// Rust 构建脚本
// 用于生成 Flutter Rust Bridge 代码

fn main() {
    // flutter_rust_bridge 会自动处理代码生成
    // 这里可以添加其他构建时需要的配置
    
    #[cfg(target_os = "windows")]
    {
        println!("cargo:rustc-link-lib=dylib=userenv");
    }
}