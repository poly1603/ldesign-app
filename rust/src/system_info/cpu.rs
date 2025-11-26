// CPU 信息采集模块

use sysinfo::{System, SystemExt, CpuExt};

/// CPU 信息结构
#[derive(Debug, Clone)]
pub struct CpuInfo {
    /// CPU 型号
    pub model: String,
    /// CPU 品牌
    pub brand: String,
    /// 物理核心数
    pub physical_cores: u32,
    /// 逻辑核心数（线程数）
    pub logical_cores: u32,
    /// 基础频率 (MHz)
    pub frequency: u64,
    /// 当前使用率 (0.0-100.0)
    pub usage: f32,
    /// 各个核心的使用率
    pub per_core_usage: Vec<f32>,
}

/// 异步获取 CPU 信息
pub async fn get_cpu_info() -> Result<CpuInfo, String> {
    tokio::task::spawn_blocking(|| {
        let mut sys = System::new_all();
        sys.refresh_cpu();
        
        // 等待一小段时间以获取准确的 CPU 使用率
        std::thread::sleep(std::time::Duration::from_millis(200));
        sys.refresh_cpu();
        
        get_cpu_info_sync(&sys)
    })
    .await
    .map_err(|e| format!("Failed to get CPU info: {}", e))?
}

/// 同步获取 CPU 信息
pub fn get_cpu_info_sync(sys: &System) -> Result<CpuInfo, String> {
    let cpus = sys.cpus();
    
    if cpus.is_empty() {
        return Err("No CPU information available".to_string());
    }

    // 获取 CPU 品牌和型号
    let brand = cpus[0].brand().to_string();
    let model = cpus[0].name().to_string();
    
    // 计算总体 CPU 使用率
    let total_usage: f32 = cpus.iter().map(|cpu| cpu.cpu_usage()).sum::<f32>() / cpus.len() as f32;
    
    // 获取每个核心的使用率
    let per_core_usage: Vec<f32> = cpus.iter().map(|cpu| cpu.cpu_usage()).collect();
    
    // 获取频率（第一个 CPU 的频率）
    let frequency = cpus[0].frequency();
    
    // 获取核心数
    let physical_cores = sys.physical_core_count().unwrap_or(cpus.len() as u32);
    let logical_cores = cpus.len() as u32;

    Ok(CpuInfo {
        model,
        brand,
        physical_cores,
        logical_cores,
        frequency,
        usage: total_usage,
        per_core_usage,
    })
}

#[cfg(test)]
mod tests {
    use super::*;

    #[tokio::test]
    async fn test_get_cpu_info() {
        let result = get_cpu_info().await;
        assert!(result.is_ok());
        
        let info = result.unwrap();
        assert!(!info.brand.is_empty());
        assert!(info.logical_cores > 0);
        assert!(info.usage >= 0.0 && info.usage <= 100.0);
    }

    #[test]
    fn test_get_cpu_info_sync() {
        let mut sys = System::new_all();
        sys.refresh_cpu();
        
        let result = get_cpu_info_sync(&sys);
        assert!(result.is_ok());
        
        let info = result.unwrap();
        assert!(!info.brand.is_empty());
        assert!(info.logical_cores > 0);
    }
}