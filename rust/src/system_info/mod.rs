// 系统信息采集模块
// 提供高性能的跨平台系统信息获取功能

pub mod cpu;
pub mod memory;
pub mod disk;
pub mod network;
pub mod os;

use sysinfo::{System, SystemExt, CpuExt, DiskExt, NetworkExt};

/// 完整的系统信息结构
#[derive(Debug, Clone)]
pub struct SystemInfo {
    pub cpu: cpu::CpuInfo,
    pub memory: memory::MemoryInfo,
    pub disk: disk::DiskInfo,
    pub network: network::NetworkInfo,
    pub os: os::OsInfo,
}

/// 并行采集所有系统信息
/// 
/// 使用tokio异步并发采集,大幅提升速度
pub async fn get_system_info() -> Result<SystemInfo, String> {
    // 使用tokio并发执行所有采集任务
    let (cpu, memory, disk, network, os) = tokio::join!(
        cpu::get_cpu_info(),
        memory::get_memory_info(),
        disk::get_disk_info(),
        network::get_network_info(),
        os::get_os_info()
    );

    Ok(SystemInfo {
        cpu: cpu?,
        memory: memory?,
        disk: disk?,
        network: network?,
        os: os?,
    })
}

/// 同步版本的系统信息采集
/// 
/// 用于不支持异步的场景
pub fn get_system_info_sync() -> Result<SystemInfo, String> {
    let mut sys = System::new_all();
    sys.refresh_all();

    Ok(SystemInfo {
        cpu: cpu::get_cpu_info_sync(&sys)?,
        memory: memory::get_memory_info_sync(&sys)?,
        disk: disk::get_disk_info_sync(&sys)?,
        network: network::get_network_info_sync(&sys)?,
        os: os::get_os_info_sync()?,
    })
}