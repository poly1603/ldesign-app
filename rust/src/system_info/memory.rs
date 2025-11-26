// 内存信息采集模块

use sysinfo::{System, SystemExt};

/// 内存信息结构
#[derive(Debug, Clone)]
pub struct MemoryInfo {
    /// 总内存 (bytes)
    pub total: u64,
    /// 可用内存 (bytes)
    pub available: u64,
    /// 已用内存 (bytes)
    pub used: u64,
    /// 内存使用率 (0.0-100.0)
    pub usage_percent: f32,
    /// 总交换空间 (bytes)
    pub swap_total: u64,
    /// 已用交换空间 (bytes)
    pub swap_used: u64,
    /// 交换空间使用率 (0.0-100.0)
    pub swap_usage_percent: f32,
}

/// 异步获取内存信息
pub async fn get_memory_info() -> Result<MemoryInfo, String> {
    tokio::task::spawn_blocking(|| {
        let mut sys = System::new_all();
        sys.refresh_memory();
        get_memory_info_sync(&sys)
    })
    .await
    .map_err(|e| format!("Failed to get memory info: {}", e))?
}

/// 同步获取内存信息
pub fn get_memory_info_sync(sys: &System) -> Result<MemoryInfo, String> {
    let total = sys.total_memory();
    let available = sys.available_memory();
    let used = sys.used_memory();
    
    let usage_percent = if total > 0 {
        (used as f64 / total as f64 * 100.0) as f32
    } else {
        0.0
    };

    let swap_total = sys.total_swap();
    let swap_used = sys.used_swap();
    
    let swap_usage_percent = if swap_total > 0 {
        (swap_used as f64 / swap_total as f64 * 100.0) as f32
    } else {
        0.0
    };

    Ok(MemoryInfo {
        total,
        available,
        used,
        usage_percent,
        swap_total,
        swap_used,
        swap_usage_percent,
    })
}

/// 格式化字节数为人类可读格式
pub fn format_bytes(bytes: u64) -> String {
    const KB: u64 = 1024;
    const MB: u64 = KB * 1024;
    const GB: u64 = MB * 1024;
    const TB: u64 = GB * 1024;

    if bytes >= TB {
        format!("{:.2} TB", bytes as f64 / TB as f64)
    } else if bytes >= GB {
        format!("{:.2} GB", bytes as f64 / GB as f64)
    } else if bytes >= MB {
        format!("{:.2} MB", bytes as f64 / MB as f64)
    } else if bytes >= KB {
        format!("{:.2} KB", bytes as f64 / KB as f64)
    } else {
        format!("{} B", bytes)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[tokio::test]
    async fn test_get_memory_info() {
        let result = get_memory_info().await;
        assert!(result.is_ok());
        
        let info = result.unwrap();
        assert!(info.total > 0);
        assert!(info.usage_percent >= 0.0 && info.usage_percent <= 100.0);
    }

    #[test]
    fn test_format_bytes() {
        assert_eq!(format_bytes(1024), "1.00 KB");
        assert_eq!(format_bytes(1024 * 1024), "1.00 MB");
        assert_eq!(format_bytes(1024 * 1024 * 1024), "1.00 GB");
    }
}