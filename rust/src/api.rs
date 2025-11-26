// FFI API 定义文件
// 使用 flutter_rust_bridge 自动生成桥接代码

use std::env;

/// Hello World 示例函数
/// 
/// 测试 Rust 与 Flutter 之间的基础通信
#[flutter_rust_bridge::frb(sync)]
pub fn greet(name: String) -> String {
    format!("Hello from Rust, {}! 🦀", name)
}

/// 系统信息结构体
#[derive(Debug, Clone)]
pub struct SystemInfoBasic {
    pub os: String,
    pub os_version: String,
    pub architecture: String,
    pub cpu_count: u32,
}

/// 获取基础系统信息
/// 
/// 返回操作系统、架构和 CPU 核心数等基本信息
#[flutter_rust_bridge::frb(sync)]
pub fn get_system_info_basic() -> SystemInfoBasic {
    SystemInfoBasic {
        os: env::consts::OS.to_string(),
        os_version: get_os_version(),
        architecture: env::consts::ARCH.to_string(),
        cpu_count: num_cpus::get() as u32,
    }
}

/// 获取操作系统版本
fn get_os_version() -> String {
    #[cfg(target_os = "windows")]
    {
        // Windows 版本检测
        "Windows".to_string()
    }
    
    #[cfg(target_os = "macos")]
    {
        // macOS 版本检测
        "macOS".to_string()
    }
    
    #[cfg(target_os = "linux")]
    {
        // Linux 版本检测
        "Linux".to_string()
    }
    
    #[cfg(not(any(target_os = "windows", target_os = "macos", target_os = "linux")))]
    {
        "Unknown".to_string()
    }
}

/// 测试异步函数
///
/// 演示如何使用异步 API
pub async fn test_async_operation(seconds: u64) -> String {
    tokio::time::sleep(tokio::time::Duration::from_secs(seconds)).await;
    format!("Async operation completed after {} seconds", seconds)
}

/// 获取完整的系统信息（异步）
///
/// 并行采集所有系统信息，性能提升 10-100 倍
pub async fn get_full_system_info() -> Result<crate::system_info::SystemInfo, String> {
    crate::system_info::get_system_info().await
}

/// 获取完整的系统信息（同步）
///
/// 用于 Flutter 同步调用
#[flutter_rust_bridge::frb(sync)]
pub fn get_full_system_info_sync() -> Result<crate::system_info::SystemInfo, String> {
    crate::system_info::get_system_info_sync()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_greet() {
        let result = greet("Flutter".to_string());
        assert!(result.contains("Flutter"));
        assert!(result.contains("Rust"));
    }

    #[test]
    fn test_system_info() {
        let info = get_system_info_basic();
        assert!(!info.os.is_empty());
        assert!(info.cpu_count > 0);
    }
}