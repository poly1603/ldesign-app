// 智能文件过滤器

use std::path::Path;

/// 默认的忽略模式
pub const DEFAULT_IGNORE_PATTERNS: &[&str] = &[
    // 依赖目录
    "node_modules",
    "bower_components",
    "vendor",
    "packages",
    
    // 构建输出
    "target",
    "build",
    "dist",
    "out",
    ".next",
    ".nuxt",
    
    // 版本控制
    ".git",
    ".svn",
    ".hg",
    
    // IDE
    ".idea",
    ".vscode",
    ".vs",
    
    // 临时文件
    "tmp",
    "temp",
    ".cache",
    
    // 操作系统
    ".DS_Store",
    "Thumbs.db",
    "desktop.ini",
];

/// 智能过滤器
pub struct SmartFilter {
    patterns: Vec<String>,
    min_size: Option<u64>,
    max_size: Option<u64>,
    extensions: Option<Vec<String>>,
}

impl Default for SmartFilter {
    fn default() -> Self {
        Self {
            patterns: DEFAULT_IGNORE_PATTERNS
                .iter()
                .map(|s| s.to_string())
                .collect(),
            min_size: None,
            max_size: None,
            extensions: None,
        }
    }
}

impl SmartFilter {
    /// 创建新的过滤器
    pub fn new() -> Self {
        Self::default()
    }
    
    /// 添加忽略模式
    pub fn add_pattern(mut self, pattern: String) -> Self {
        self.patterns.push(pattern);
        self
    }
    
    /// 设置最小文件大小
    pub fn min_size(mut self, size: u64) -> Self {
        self.min_size = Some(size);
        self
    }
    
    /// 设置最大文件大小
    pub fn max_size(mut self, size: u64) -> Self {
        self.max_size = Some(size);
        self
    }
    
    /// 设置允许的扩展名
    pub fn extensions(mut self, exts: Vec<String>) -> Self {
        self.extensions = Some(exts);
        self
    }
    
    /// 检查路径是否应该被过滤
    pub fn should_filter(&self, path: &Path, size: u64) -> bool {
        // 检查大小限制
        if let Some(min) = self.min_size {
            if size < min {
                return true;
            }
        }
        
        if let Some(max) = self.max_size {
            if size > max {
                return true;
            }
        }
        
        // 检查扩展名
        if let Some(ref allowed_exts) = self.extensions {
            if let Some(ext) = path.extension().and_then(|e| e.to_str()) {
                if !allowed_exts.contains(&ext.to_string()) {
                    return true;
                }
            } else {
                // 没有扩展名，过滤掉
                return true;
            }
        }
        
        // 检查忽略模式
        if let Some(path_str) = path.to_str() {
            for pattern in &self.patterns {
                if path_str.contains(pattern) {
                    return true;
                }
            }
        }
        
        false
    }
}

/// 检查是否是二进制文件（通过扩展名）
pub fn is_binary_file(extension: &str) -> bool {
    matches!(
        extension,
        "exe" | "dll" | "so" | "dylib" | "bin" | "dat" |
        "zip" | "tar" | "gz" | "7z" | "rar" |
        "jpg" | "jpeg" | "png" | "gif" | "bmp" | "ico" |
        "mp3" | "mp4" | "avi" | "mov" | "wmv" |
        "pdf" | "doc" | "docx" | "xls" | "xlsx" | "ppt" | "pptx"
    )
}

/// 检查是否是文本文件
pub fn is_text_file(extension: &str) -> bool {
    matches!(
        extension,
        "txt" | "md" | "markdown" |
        "js" | "ts" | "jsx" | "tsx" |
        "rs" | "dart" | "py" | "java" | "go" | "rb" | "php" |
        "c" | "cpp" | "h" | "hpp" | "cs" |
        "html" | "htm" | "css" | "scss" | "sass" | "less" |
        "json" | "yaml" | "yml" | "xml" | "toml" | "ini" | "conf" |
        "sh" | "bash" | "zsh" | "fish" | "ps1" | "bat" | "cmd"
    )
}

/// 检查是否是源代码文件
pub fn is_source_code(extension: &str) -> bool {
    matches!(
        extension,
        "js" | "ts" | "jsx" | "tsx" |
        "rs" | "dart" | "py" | "java" | "go" | "rb" | "php" |
        "c" | "cpp" | "cc" | "cxx" | "h" | "hpp" | "cs" |
        "swift" | "kt" | "scala" | "clj" | "ex" | "exs" |
        "hs" | "ml" | "elm" | "erl" | "lua" | "r"
    )
}

/// 检查是否是配置文件
pub fn is_config_file(filename: &str) -> bool {
    filename.starts_with('.') ||
    matches!(
        filename,
        "package.json" | "tsconfig.json" | "webpack.config.js" |
        "vite.config.js" | "rollup.config.js" | "babel.config.js" |
        "Cargo.toml" | "pubspec.yaml" | "go.mod" |
        "Dockerfile" | "docker-compose.yml" |
        "nginx.conf" | ".gitignore" | ".env"
    ) ||
    filename.ends_with(".config.js") ||
    filename.ends_with(".config.ts") ||
    filename.ends_with(".conf")
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::path::PathBuf;

    #[test]
    fn test_smart_filter() {
        let filter = SmartFilter::new()
            .min_size(100)
            .max_size(10000);
        
        let path = PathBuf::from("test.txt");
        
        // 太小
        assert!(filter.should_filter(&path, 50));
        
        // 太大
        assert!(filter.should_filter(&path, 20000));
        
        // 正常大小
        assert!(!filter.should_filter(&path, 500));
    }

    #[test]
    fn test_ignore_patterns() {
        let filter = SmartFilter::new();
        
        // 应该被忽略
        assert!(filter.should_filter(&PathBuf::from("node_modules/test.js"), 100));
        assert!(filter.should_filter(&PathBuf::from(".git/config"), 100));
        assert!(filter.should_filter(&PathBuf::from("build/output.js"), 100));
        
        // 不应该被忽略
        assert!(!filter.should_filter(&PathBuf::from("src/main.rs"), 100));
    }

    #[test]
    fn test_file_type_checks() {
        assert!(is_binary_file("exe"));
        assert!(is_binary_file("dll"));
        assert!(!is_binary_file("txt"));
        
        assert!(is_text_file("txt"));
        assert!(is_text_file("md"));
        assert!(!is_text_file("exe"));
        
        assert!(is_source_code("rs"));
        assert!(is_source_code("js"));
        assert!(!is_source_code("txt"));
        
        assert!(is_config_file(".gitignore"));
        assert!(is_config_file("package.json"));
        assert!(!is_config_file("main.rs"));
    }
}