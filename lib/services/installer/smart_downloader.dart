import 'dart:io';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:crypto/crypto.dart';
import 'dart:convert';

/// 下载进度回调
typedef DownloadProgressCallback = void Function(int received, int total);

/// 下载配置
class DownloadConfig {
  final String url;
  final String savePath;
  final String? checksum;
  final String checksumType; // md5, sha256
  final int maxRetries;
  final Duration timeout;
  final Map<String, String>? headers;
  final bool useCache;

  DownloadConfig({
    required this.url,
    required this.savePath,
    this.checksum,
    this.checksumType = 'sha256',
    this.maxRetries = 3,
    this.timeout = const Duration(minutes: 10),
    this.headers,
    this.useCache = true,
  });
}

/// 下载结果
class DownloadResult {
  final bool success;
  final String filePath;
  final String? error;
  final bool fromCache;
  final int fileSize;

  DownloadResult({
    required this.success,
    required this.filePath,
    this.error,
    this.fromCache = false,
    this.fileSize = 0,
  });
}

/// 智能下载器 - 支持重试、缓存、校验、代理
class SmartDownloader {
  final Dio _dio;
  final String _cacheDir;

  SmartDownloader({String? cacheDir})
      : _cacheDir = cacheDir ?? _getDefaultCacheDir(),
        _dio = Dio() {
    _configureDio();
  }

  /// 获取默认缓存目录
  static String _getDefaultCacheDir() {
    final home = Platform.environment['HOME'] ?? 
                 Platform.environment['USERPROFILE'] ?? 
                 Directory.current.path;
    return path.join(home, '.node_manager_cache', 'downloads');
  }

  /// 配置 Dio
  void _configureDio() {
    // 设置代理
    _configureProxy();

    // 基础配置
    _dio.options.followRedirects = true;
    _dio.options.maxRedirects = 5;
    _dio.options.validateStatus = (status) {
      return status != null && status < 500;
    };

    // 添加重试拦截器
    _dio.interceptors.add(RetryInterceptor(dio: _dio));
  }

  /// 配置代理
  void _configureProxy() {
    final env = Platform.environment;
    
    // 检查环境变量中的代理配置
    final httpProxy = env['HTTP_PROXY'] ?? env['http_proxy'];
    final httpsProxy = env['HTTPS_PROXY'] ?? env['https_proxy'];
    final noProxy = env['NO_PROXY'] ?? env['no_proxy'];

    if (httpProxy != null || httpsProxy != null) {
      final proxyUrl = httpsProxy ?? httpProxy;
      debugPrint('使用代理: $proxyUrl');
      
      // Dio 5.x 使用新的方式配置代理
      _dio.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () {
          final client = HttpClient();
          client.findProxy = (uri) {
            // 检查是否在 no_proxy 列表中
            if (noProxy != null) {
              final noProxyList = noProxy.split(',').map((e) => e.trim()).toList();
              if (noProxyList.any((domain) => uri.host.endsWith(domain))) {
                return 'DIRECT';
              }
            }
            return 'PROXY $proxyUrl';
          };
          client.badCertificateCallback = (cert, host, port) => true;
          return client;
        },
      );
    }
  }

  /// 下载文件
  Future<DownloadResult> download(
    DownloadConfig config, {
    DownloadProgressCallback? onProgress,
    Function(String)? onLog,
  }) async {
    onLog?.call('开始下载: ${config.url}');

    // 确保缓存目录存在
    await _ensureCacheDir();

    // 检查缓存
    if (config.useCache) {
      final cachedFile = await _checkCache(config);
      if (cachedFile != null) {
        onLog?.call('使用缓存文件');
        
        // 复制到目标位置
        await File(cachedFile).copy(config.savePath);
        
        return DownloadResult(
          success: true,
          filePath: config.savePath,
          fromCache: true,
          fileSize: await File(config.savePath).length(),
        );
      }
    }

    // 执行下载（带重试）
    return await _downloadWithRetry(
      config,
      onProgress: onProgress,
      onLog: onLog,
    );
  }

  /// 带重试的下载
  Future<DownloadResult> _downloadWithRetry(
    DownloadConfig config, {
    DownloadProgressCallback? onProgress,
    Function(String)? onLog,
  }) async {
    int attempt = 0;
    String? lastError;

    while (attempt < config.maxRetries) {
      attempt++;
      
      try {
        onLog?.call('下载尝试 $attempt/${config.maxRetries}');
        
        // 创建临时文件
        final tempFile = '${config.savePath}.tmp';
        
        // 执行下载
        await _dio.download(
          config.url,
          tempFile,
          options: Options(
            headers: config.headers,
            receiveTimeout: config.timeout,
          ),
          onReceiveProgress: (received, total) {
            onProgress?.call(received, total);
            if (total > 0) {
              final progress = (received / total * 100).toStringAsFixed(1);
              onLog?.call('下载进度: $progress% ($received/$total)');
            }
          },
        );

        // 验证文件
        final file = File(tempFile);
        if (!await file.exists()) {
          throw Exception('下载的文件不存在');
        }

        final fileSize = await file.length();
        if (fileSize == 0) {
          throw Exception('下载的文件为空');
        }

        // 校验文件
        if (config.checksum != null) {
          onLog?.call('验证文件完整性...');
          final isValid = await _verifyChecksum(
            tempFile,
            config.checksum!,
            config.checksumType,
          );
          
          if (!isValid) {
            await file.delete();
            throw Exception('文件校验失败');
          }
          onLog?.call('文件校验通过');
        }

        // 移动到目标位置
        await file.rename(config.savePath);

        // 保存到缓存
        if (config.useCache) {
          await _saveToCache(config.savePath, config.url);
        }

        onLog?.call('下载完成: ${_formatBytes(fileSize)}');

        return DownloadResult(
          success: true,
          filePath: config.savePath,
          fileSize: fileSize,
        );

      } catch (e) {
        lastError = e.toString();
        onLog?.call('下载失败 (尝试 $attempt): $e');

        // 清理临时文件
        try {
          final tempFile = File('${config.savePath}.tmp');
          if (await tempFile.exists()) {
            await tempFile.delete();
          }
        } catch (_) {}

        if (attempt < config.maxRetries) {
          // 等待后重试
          final waitSeconds = attempt * 2;
          onLog?.call('等待 $waitSeconds 秒后重试...');
          await Future.delayed(Duration(seconds: waitSeconds));
        }
      }
    }

    return DownloadResult(
      success: false,
      filePath: config.savePath,
      error: '下载失败: $lastError',
    );
  }

  /// 确保缓存目录存在
  Future<void> _ensureCacheDir() async {
    final dir = Directory(_cacheDir);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
  }

  /// 检查缓存
  Future<String?> _checkCache(DownloadConfig config) async {
    try {
      final cacheKey = _getCacheKey(config.url);
      final cachedFile = path.join(_cacheDir, cacheKey);
      final file = File(cachedFile);

      if (!await file.exists()) {
        return null;
      }

      // 如果有校验和，验证缓存文件
      if (config.checksum != null) {
        final isValid = await _verifyChecksum(
          cachedFile,
          config.checksum!,
          config.checksumType,
        );
        
        if (!isValid) {
          // 删除无效的缓存
          await file.delete();
          return null;
        }
      }

      return cachedFile;
    } catch (e) {
      debugPrint('检查缓存失败: $e');
      return null;
    }
  }

  /// 保存到缓存
  Future<void> _saveToCache(String filePath, String url) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return;

      final cacheKey = _getCacheKey(url);
      final cachedFile = path.join(_cacheDir, cacheKey);

      await file.copy(cachedFile);
      debugPrint('已保存到缓存: $cachedFile');
    } catch (e) {
      debugPrint('保存缓存失败: $e');
    }
  }

  /// 获取缓存键
  String _getCacheKey(String url) {
    final bytes = utf8.encode(url);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  /// 验证校验和
  Future<bool> _verifyChecksum(
    String filePath,
    String expectedChecksum,
    String type,
  ) async {
    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      
      String actualChecksum;
      if (type.toLowerCase() == 'md5') {
        actualChecksum = md5.convert(bytes).toString();
      } else {
        actualChecksum = sha256.convert(bytes).toString();
      }

      return actualChecksum.toLowerCase() == expectedChecksum.toLowerCase();
    } catch (e) {
      debugPrint('校验失败: $e');
      return false;
    }
  }

  /// 格式化字节大小
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  /// 清理缓存
  Future<void> clearCache() async {
    try {
      final dir = Directory(_cacheDir);
      if (await dir.exists()) {
        await dir.delete(recursive: true);
        debugPrint('缓存已清理');
      }
    } catch (e) {
      debugPrint('清理缓存失败: $e');
    }
  }

  /// 获取缓存大小
  Future<int> getCacheSize() async {
    try {
      final dir = Directory(_cacheDir);
      if (!await dir.exists()) return 0;

      int totalSize = 0;
      await for (final entity in dir.list(recursive: true)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
      return totalSize;
    } catch (e) {
      debugPrint('获取缓存大小失败: $e');
      return 0;
    }
  }
}

/// 重试拦截器
class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;

  RetryInterceptor({
    required this.dio,
    this.maxRetries = 3,
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final extra = err.requestOptions.extra;
    final retryCount = extra['retryCount'] ?? 0;

    if (retryCount < maxRetries && _shouldRetry(err)) {
      debugPrint('重试请求 (${retryCount + 1}/$maxRetries): ${err.requestOptions.uri}');
      
      extra['retryCount'] = retryCount + 1;
      err.requestOptions.extra = extra;

      // 等待后重试
      await Future.delayed(Duration(seconds: (retryCount + 1) * 2));

      try {
        final response = await dio.fetch(err.requestOptions);
        handler.resolve(response);
      } catch (e) {
        handler.next(err);
      }
    } else {
      handler.next(err);
    }
  }

  /// 判断是否应该重试
  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
           err.type == DioExceptionType.sendTimeout ||
           err.type == DioExceptionType.receiveTimeout ||
           err.type == DioExceptionType.connectionError ||
           (err.response?.statusCode != null && 
            err.response!.statusCode! >= 500);
  }
}