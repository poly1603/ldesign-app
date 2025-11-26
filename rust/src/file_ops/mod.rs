// 文件操作模块
// 提供高性能的并行文件扫描和分析功能

pub mod scanner;
pub mod analyzer;
pub mod filter;

use std::path::PathBuf;

/// 文件信息结构
#[derive(Debug, Clone)]
pub struct FileInfo {
    /// 文件路径
    pub path: String,
    /// 文件名
    pub name: String,
    /// 文件大小 (bytes)
    pub size: u64,
    /// 是否是目录
    pub is_dir: bool,
    /// 文件扩展名
    pub extension: String,
    /// 修改时间 (Unix 时间戳)
    pub modified_time: u64,
    /// 创建时间 (Unix 时间戳)
    pub created_time: u64,
}

/// 扫描配置
#[derive(Debug, Clone)]
pub struct ScanConfig {
    /// 扫描路径
    pub path: String,
    /// 最大深度 (None = 无限制)
    pub max_depth: Option<usize>,
    /// 忽略模式列表
    pub ignore_patterns: Vec<String>,
    /// 是否启用并行扫描
    pub parallel: bool,
    /// 是否跟随符号链接
    pub follow_links: bool,
}

impl Default for ScanConfig {
    fn default() -> Self {
        Self {
            path: ".".to_string(),
            max_depth: None,
            ignore_patterns: vec![
                "node_modules".to_string(),
                ".git".to_string(),
                ".idea".to_string(),
                ".vscode".to_string(),
                "target".to_string(),
                "build".to_string(),
            ],
            parallel: true,
            follow_links: false,
        }
    }
}

/// 扫描结果统计
#[derive(Debug, Clone)]
pub struct ScanResult {
    /// 文件列表
    pub files: Vec<FileInfo>,
    /// 文件总数
    pub file_count: usize,
    /// 目录总数
    pub dir_count: usize,
    /// 总大小 (bytes)
    pub total_size: u64,
    /// 扫描耗时 (毫秒)
    pub duration_ms: u64,
}

/// 项目分析结果
#[derive(Debug, Clone)]
pub struct ProjectAnalysis {
    /// 项目类型 (例如: "node", "rust", "flutter")
    pub project_type: String,
    /// 编程语言统计
    pub language_stats: Vec<LanguageStat>,
    /// 依赖文件路径
    pub dependency_files: Vec<String>,
    /// 配置文件路径
    pub config_files: Vec<String>,
    /// 源代码行数估算
    pub estimated_lines: u64,
}

/// 编程语言统计
#[derive(Debug, Clone)]
pub struct LanguageStat {
    /// 语言名称
    pub language: String,
    /// 文件数量
    pub file_count: usize,
    /// 总大小 (bytes)
    pub total_size: u64,
    /// 占比 (0.0-100.0)
    pub percentage: f32,
}