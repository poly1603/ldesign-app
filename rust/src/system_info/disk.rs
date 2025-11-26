// 磁盘信息采集模块

use sysinfo::{System, SystemExt, DiskExt};

/// 单个磁盘信息
#[derive(Debug, Clone)]
pub struct DiskEntry {
    /// 挂载点/盘符
    pub mount_point: String,
    /// 磁盘名称
    pub name: String,
    /// 文件系统类型
    pub file_system: String,
    /// 总容量 (bytes)
    pub total_space: u64,
    /// 可用空间 (bytes)
    pub available_space: u64,
    /// 已用空间 (bytes)
    pub used_space: u64,
    /// 使用率 (0.0-100.0)
    pub usage_percent: f32,
    /// 是否可移除
    pub is_removable: bool,
}

/// 磁盘信息汇总
#[derive(Debug, Clone)]
pub struct DiskInfo {
    /// 所有磁盘列表
    pub disks: Vec<DiskEntry>,
    /// 总容量 (bytes)
    pub total_space: u64,
    /// 总可用空间 (bytes)
    pub total_available: u64,
    /// 总已用空间 (bytes)
    pub total_used: u64,
    /// 整体使用率 (0.0-100.0)
    pub overall_usage_percent: f32,
}

/// 异步获取磁盘信息
pub async fn get_disk_info() -> Result<DiskInfo, String> {
    tokio::task::spawn_blocking(|| {
        let mut sys = System::new_all();
        sys.refresh_disks_list();
        sys.refresh_disks();
        get_disk_info_sync(&sys)
    })
    .await
    .map_err(|e| format!("Failed to get disk info: {}", e))?
}

/// 同步获取磁盘信息
pub fn get_disk_info_sync(sys: &System) -> Result<DiskInfo, String> {
    let mut disks = Vec::new();
    let mut total_space = 0u64;
    let mut total_available = 0u64;
    let mut total_used = 0u64;

    for disk in sys.disks() {
        let total = disk.total_space();
        let available = disk.available_space();
        let used = total.saturating_sub(available);
        
        let usage_percent = if total > 0 {
            (used as f64 / total as f64 * 100.0) as f32
        } else {
            0.0
        };

        disks.push(DiskEntry {
            mount_point: disk.mount_point().to_string_lossy().to_string(),
            name: disk.name().to_string_lossy().to_string(),
            file_system: String::from_utf8_lossy(disk.file_system()).to_string(),
            total_space: total,
            available_space: available,
            used_space: used,
            usage_percent,
            is_removable: disk.is_removable(),
        });

        total_space += total;
        total_available += available;
        total_used += used;
    }

    let overall_usage_percent = if total_space > 0 {
        (total_used as f64 / total_space as f64 * 100.0) as f32
    } else {
        0.0
    };

    Ok(DiskInfo {
        disks,
        total_space,
        total_available,
        total_used,
        overall_usage_percent,
    })
}

#[cfg(test)]
mod tests {
    use super::*;

    #[tokio::test]
    async fn test_get_disk_info() {
        let result = get_disk_info().await;
        assert!(result.is_ok());
        
        let info = result.unwrap();
        assert!(!info.disks.is_empty());
        assert!(info.total_space > 0);
    }

    #[test]
    fn test_get_disk_info_sync() {
        let mut sys = System::new_all();
        sys.refresh_disks_list();
        sys.refresh_disks();
        
        let result = get_disk_info_sync(&sys);
        assert!(result.is_ok());
        
        let info = result.unwrap();
        assert!(!info.disks.is_empty());
    }
}