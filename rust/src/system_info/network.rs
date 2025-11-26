// 网络信息采集模块

use sysinfo::{System, SystemExt, NetworkExt, NetworksExt};

/// 网络接口信息
#[derive(Debug, Clone)]
pub struct NetworkInterface {
    /// 接口名称
    pub name: String,
    /// 接收的字节数
    pub received_bytes: u64,
    /// 发送的字节数
    pub transmitted_bytes: u64,
    /// 接收速率 (bytes/s)
    pub received_rate: u64,
    /// 发送速率 (bytes/s)
    pub transmitted_rate: u64,
}

/// 网络信息汇总
#[derive(Debug, Clone)]
pub struct NetworkInfo {
    /// 网络接口列表
    pub interfaces: Vec<NetworkInterface>,
    /// 总接收字节数
    pub total_received: u64,
    /// 总发送字节数
    pub total_transmitted: u64,
    /// 活动接口数量
    pub active_interfaces: usize,
}

/// 异步获取网络信息
pub async fn get_network_info() -> Result<NetworkInfo, String> {
    tokio::task::spawn_blocking(|| {
        let mut sys = System::new_all();
        sys.refresh_networks_list();
        sys.refresh_networks();
        get_network_info_sync(&sys)
    })
    .await
    .map_err(|e| format!("Failed to get network info: {}", e))?
}

/// 同步获取网络信息
pub fn get_network_info_sync(sys: &System) -> Result<NetworkInfo, String> {
    let networks = sys.networks();
    let mut interfaces = Vec::new();
    let mut total_received = 0u64;
    let mut total_transmitted = 0u64;
    let mut active_count = 0;

    for (interface_name, network) in networks {
        let received = network.total_received();
        let transmitted = network.total_transmitted();
        
        // 如果有数据传输,认为是活动接口
        if received > 0 || transmitted > 0 {
            active_count += 1;
        }

        interfaces.push(NetworkInterface {
            name: interface_name.clone(),
            received_bytes: received,
            transmitted_bytes: transmitted,
            received_rate: network.received(),
            transmitted_rate: network.transmitted(),
        });

        total_received += received;
        total_transmitted += transmitted;
    }

    Ok(NetworkInfo {
        interfaces,
        total_received,
        total_transmitted,
        active_interfaces: active_count,
    })
}

/// 格式化网络速率
pub fn format_network_speed(bytes_per_sec: u64) -> String {
    const KB: u64 = 1024;
    const MB: u64 = KB * 1024;
    const GB: u64 = MB * 1024;

    if bytes_per_sec >= GB {
        format!("{:.2} GB/s", bytes_per_sec as f64 / GB as f64)
    } else if bytes_per_sec >= MB {
        format!("{:.2} MB/s", bytes_per_sec as f64 / MB as f64)
    } else if bytes_per_sec >= KB {
        format!("{:.2} KB/s", bytes_per_sec as f64 / KB as f64)
    } else {
        format!("{} B/s", bytes_per_sec)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[tokio::test]
    async fn test_get_network_info() {
        let result = get_network_info().await;
        assert!(result.is_ok());
        
        let info = result.unwrap();
        // 至少应该有一个网络接口
        assert!(!info.interfaces.is_empty());
    }

    #[test]
    fn test_format_network_speed() {
        assert_eq!(format_network_speed(1024), "1.00 KB/s");
        assert_eq!(format_network_speed(1024 * 1024), "1.00 MB/s");
    }
}