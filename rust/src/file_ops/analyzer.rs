// 项目分析器
// 分析项目类型、编程语言统计等

use super::{ProjectAnalysis, LanguageStat, FileInfo};
use std::collections::HashMap;
use std::path::Path;

/// 分析项目
pub fn analyze_project(files: &[FileInfo]) -> ProjectAnalysis {
    // 检测项目类型
    let project_type = detect_project_type(files);
    
    // 统计编程语言
    let language_stats = analyze_languages(files);
    
    // 查找依赖文件
    let dependency_files = find_dependency_files(files);
    
    // 查找配置文件
    let config_files = find_config_files(files);
    
    // 估算代码行数
    let estimated_lines = estimate_lines_of_code(files);
    
    ProjectAnalysis {
        project_type,
        language_stats,
        dependency_files,
        config_files,
        estimated_lines,
    }
}

/// 检测项目类型
fn detect_project_type(files: &[FileInfo]) -> String {
    // 检查特征文件
    for file in files {
        let name = file.name.as_str();
        match name {
            "package.json" => return "Node.js".to_string(),
            "Cargo.toml" => return "Rust".to_string(),
            "pubspec.yaml" => return "Flutter/Dart".to_string(),
            "pom.xml" | "build.gradle" => return "Java".to_string(),
            "requirements.txt" | "setup.py" => return "Python".to_string(),
            "go.mod" => return "Go".to_string(),
            "Gemfile" => return "Ruby".to_string(),
            "composer.json" => return "PHP".to_string(),
            _ => {}
        }
    }
    
    // 根据文件扩展名推测
    let extensions: HashMap<&str, usize> = files
        .iter()
        .filter(|f| !f.is_dir)
        .fold(HashMap::new(), |mut acc, f| {
            *acc.entry(f.extension.as_str()).or_insert(0) += 1;
            acc
        });
    
    if let Some((ext, _)) = extensions.iter().max_by_key(|(_, count)| *count) {
        return match *ext {
            "js" | "ts" | "jsx" | "tsx" => "JavaScript/TypeScript",
            "rs" => "Rust",
            "dart" => "Dart",
            "py" => "Python",
            "java" => "Java",
            "go" => "Go",
            "rb" => "Ruby",
            "php" => "PHP",
            "c" | "cpp" | "cc" | "cxx" => "C/C++",
            "cs" => "C#",
            _ => "Unknown",
        }.to_string();
    }
    
    "Unknown".to_string()
}

/// 分析编程语言统计
fn analyze_languages(files: &[FileInfo]) -> Vec<LanguageStat> {
    // 语言扩展名映射
    let language_map: HashMap<&str, &str> = [
        ("js", "JavaScript"),
        ("ts", "TypeScript"),
        ("jsx", "JavaScript (JSX)"),
        ("tsx", "TypeScript (TSX)"),
        ("rs", "Rust"),
        ("dart", "Dart"),
        ("py", "Python"),
        ("java", "Java"),
        ("go", "Go"),
        ("rb", "Ruby"),
        ("php", "PHP"),
        ("c", "C"),
        ("cpp", "C++"),
        ("cc", "C++"),
        ("cxx", "C++"),
        ("h", "C/C++ Header"),
        ("cs", "C#"),
        ("html", "HTML"),
        ("css", "CSS"),
        ("scss", "SCSS"),
        ("json", "JSON"),
        ("yaml", "YAML"),
        ("yml", "YAML"),
        ("xml", "XML"),
        ("md", "Markdown"),
    ].iter().copied().collect();

    // 统计每种语言
    let mut stats: HashMap<String, (usize, u64)> = HashMap::new();
    let mut total_size = 0u64;
    
    for file in files.iter().filter(|f| !f.is_dir) {
        if let Some(language) = language_map.get(file.extension.as_str()) {
            let entry = stats.entry(language.to_string()).or_insert((0, 0));
            entry.0 += 1;
            entry.1 += file.size;
            total_size += file.size;
        }
    }
    
    // 转换为 LanguageStat 并计算百分比
    let mut result: Vec<LanguageStat> = stats
        .into_iter()
        .map(|(language, (count, size))| {
            let percentage = if total_size > 0 {
                (size as f64 / total_size as f64 * 100.0) as f32
            } else {
                0.0
            };
            LanguageStat {
                language,
                file_count: count,
                total_size: size,
                percentage,
            }
        })
        .collect();
    
    // 按文件大小排序
    result.sort_by(|a, b| b.total_size.cmp(&a.total_size));
    
    result
}

/// 查找依赖文件
fn find_dependency_files(files: &[FileInfo]) -> Vec<String> {
    let dependency_patterns = [
        "package.json",
        "package-lock.json",
        "yarn.lock",
        "pnpm-lock.yaml",
        "Cargo.toml",
        "Cargo.lock",
        "pubspec.yaml",
        "pubspec.lock",
        "requirements.txt",
        "Pipfile",
        "go.mod",
        "go.sum",
        "Gemfile",
        "Gemfile.lock",
        "composer.json",
        "composer.lock",
    ];
    
    files
        .iter()
        .filter(|f| !f.is_dir && dependency_patterns.contains(&f.name.as_str()))
        .map(|f| f.path.clone())
        .collect()
}

/// 查找配置文件
fn find_config_files(files: &[FileInfo]) -> Vec<String> {
    let config_patterns = [
        ".gitignore",
        ".env",
        "tsconfig.json",
        "webpack.config.js",
        "vite.config.js",
        "rollup.config.js",
        "babel.config.js",
        ".eslintrc",
        ".prettierrc",
        "Dockerfile",
        "docker-compose.yml",
        "nginx.conf",
    ];
    
    files
        .iter()
        .filter(|f| {
            !f.is_dir && (
                config_patterns.contains(&f.name.as_str()) ||
                f.name.starts_with(".") ||
                f.name.ends_with(".config.js") ||
                f.name.ends_with(".config.ts")
            )
        })
        .map(|f| f.path.clone())
        .collect()
}

/// 估算代码行数
fn estimate_lines_of_code(files: &[FileInfo]) -> u64 {
    // 简单估算：每个源代码文件平均 100 行
    // 根据文件大小更精确估算：平均每行 40 字节
    files
        .iter()
        .filter(|f| !f.is_dir && is_source_code(&f.extension))
        .map(|f| f.size / 40) // 平均每行 40 字节
        .sum()
}

/// 判断是否是源代码文件
fn is_source_code(extension: &str) -> bool {
    matches!(
        extension,
        "js" | "ts" | "jsx" | "tsx" | "rs" | "dart" | "py" | "java" |
        "go" | "rb" | "php" | "c" | "cpp" | "cc" | "cxx" | "h" | "cs"
    )
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_detect_project_type() {
        let files = vec![
            FileInfo {
                path: "package.json".to_string(),
                name: "package.json".to_string(),
                size: 1024,
                is_dir: false,
                extension: "json".to_string(),
                modified_time: 0,
                created_time: 0,
            },
        ];
        
        let project_type = detect_project_type(&files);
        assert_eq!(project_type, "Node.js");
    }

    #[test]
    fn test_analyze_languages() {
        let files = vec![
            FileInfo {
                path: "main.rs".to_string(),
                name: "main.rs".to_string(),
                size: 1000,
                is_dir: false,
                extension: "rs".to_string(),
                modified_time: 0,
                created_time: 0,
            },
            FileInfo {
                path: "lib.rs".to_string(),
                name: "lib.rs".to_string(),
                size: 2000,
                is_dir: false,
                extension: "rs".to_string(),
                modified_time: 0,
                created_time: 0,
            },
        ];
        
        let stats = analyze_languages(&files);
        assert_eq!(stats.len(), 1);
        assert_eq!(stats[0].language, "Rust");
        assert_eq!(stats[0].file_count, 2);
    }
}