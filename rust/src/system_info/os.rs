// 操作系统信息采集模块

use sysinfo::{System, SystemExt};
use std::env;

/// 操作系统信息
#[derive(Debug, Clone)]
pub struct OsInfo {
    /// 操作系统类型
    pub os_type: String,
    /// 操作系统版本
    pub version: String,
    /// 内核版本
    pub kernel_version: String,
    /// 主机名
    pub hostname: String,
    /// 系统架构
    pub architecture: String,
    /// 系统启动时间 (Unix 时间戳)
    pub boot_time: u64,
    /// 系统运行时间 (秒)
    pub uptime: u64,
}

/// 异步获取操作系统信息
pub async fn get_os_info() -> Result<OsInfo, String> {
    tokio::task::spawn_blocking(|| {
        get_os_info_sync()
    })
    .await
    .map_err(|e| format!("Failed to get OS info: {}", e))?
}

/// 同步获取操作系统信息
pub fn get_os_info_sync() -> Result<OsInfo, String> {
    let mut sys = System::new_all();
    sys.refresh_system();

    let os_type = env::consts::OS.to_string();
    let version = System::long_os_version().unwrap_or_else(|| "Unknown".to_string());
    let kernel_version = System::kernel_version().unwrap_or_else(|| "Unknown".to_string());
    let hostname = System::host_name().unwrap_or_else(|| "Unknown".to_string());
    let architecture = env::consts::ARCH.to_string();
    let boot_time = System::boot_time();
    
    // 计算运行时间
    let current_time = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .map(|d| d.as_secs())
        .unwrap_or(0);
    let uptime = current_time.saturating_sub(boot_time);

    Ok(OsInfo {
        os_type,
        version,
        kernel_version,
        hostname,
        architecture,
        boot_time,
        uptime,
    })
}

/// 格式化运行时间为人类可读格式
pub fn format_uptime(seconds: u64) -> String {
    let days = seconds / 86400;
    let hours = (seconds % 86400) / 3600;
    let minutes = (seconds % 3600) / 60;
    let secs = seconds % 60;

    if days > 0 {
        format!("{}天 {}小时 {}分钟", days, hours, minutes)
    } else if hours > 0 {
        format!("{}小时 {}分钟", hours, minutes)
    } else if minutes > 0 {
        format!("{}分钟 {}秒", minutes, secs)
    } else {
        format!("{}秒", secs)
    }
}

/// 获取详细的操作系统信息字符串
pub fn get_detailed_os_string() -> String {
    let info = get_os_info_sync().unwrap_or_else(|_| OsInfo {
        os_type: "Unknown".to_string(),
        version: "Unknown".to_string(),
        kernel_version: "Unknown".to_string(),
        hostname: "Unknown".to_string(),
        architecture: "Unknown".to_string(),
        boot_time: 0,
        uptime: 0,
    });

    format!(
        "{} {} ({})\n内核: {}\n主机名: {}\n运行时间: {}",
        info.os_type,
        info.version,
        info.architecture,
        info.kernel_version,
        info.hostname,
        format_uptime(info.uptime)
    )
}

#[cfg(test)]
mod tests {
    use super::*;

    #[tokio::test]
    async fn test_get_os_info() {
        let result = get_os_info().await;
        assert!(result.is_ok());
        
        let info = result.unwrap();
        assert!(!info.os_type.is_empty());
        assert!(!info.hostname.is_empty());
    }

    #[test]
    fn test_format_uptime() {
        assert_eq!(format_uptime(65), "1分钟 5秒");
        assert_eq!(format_uptime(3665), "1小时 1分钟");
        assert_eq!(format_uptime(86465), "1天 0小时 1分钟");
    }

    #[test]
    fn test_get_detailed_os_string() {
        let info_str = get_detailed_os_string();
        assert!(!info_str.is_empty());
    }
}