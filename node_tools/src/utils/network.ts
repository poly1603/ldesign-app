/**
 * Network utilities for connectivity checks, proxy handling, and downloads
 */

import axios, { AxiosInstance, AxiosRequestConfig } from 'axios';
import { getLogger } from './logger';
import { NetworkInfo } from '../types/system.types';

const logger = getLogger();

/**
 * Create axios instance with proxy configuration
 */
export function createHttpClient(config?: AxiosRequestConfig): AxiosInstance {
  const proxyConfig = getProxyConfiguration();
  
  const defaultConfig: AxiosRequestConfig = {
    timeout: 30000,
    headers: {
      'User-Agent': 'node-tool-installer/1.0.0',
    },
    proxy: proxyConfig.httpProxy ? {
      host: new URL(proxyConfig.httpProxy).hostname,
      port: parseInt(new URL(proxyConfig.httpProxy).port || '80'),
      protocol: new URL(proxyConfig.httpProxy).protocol.replace(':', ''),
    } : false,
    ...config,
  };

  return axios.create(defaultConfig);
}

/**
 * Get proxy configuration from environment variables
 */
export function getProxyConfiguration(): {
  httpProxy?: string;
  httpsProxy?: string;
  noProxy?: string[];
} {
  return {
    httpProxy: process.env.HTTP_PROXY || process.env.http_proxy,
    httpsProxy: process.env.HTTPS_PROXY || process.env.https_proxy,
    noProxy: (process.env.NO_PROXY || process.env.no_proxy)?.split(',').map(s => s.trim()),
  };
}

/**
 * Check if a URL should bypass proxy
 */
export function shouldBypassProxy(url: string): boolean {
  const proxyConfig = getProxyConfiguration();
  if (!proxyConfig.noProxy || proxyConfig.noProxy.length === 0) {
    return false;
  }

  try {
    const urlObj = new URL(url);
    const hostname = urlObj.hostname;

    return proxyConfig.noProxy.some((pattern) => {
      if (pattern === '*') return true;
      if (pattern.startsWith('.')) {
        return hostname.endsWith(pattern) || hostname === pattern.slice(1);
      }
      return hostname === pattern;
    });
  } catch {
    return false;
  }
}

/**
 * Check internet connectivity
 */
export async function checkInternetConnectivity(): Promise<boolean> {
  const testUrls = [
    'https://www.google.com',
    'https://www.cloudflare.com',
    'https://1.1.1.1',
  ];

  for (const url of testUrls) {
    try {
      const client = createHttpClient({ timeout: 5000 });
      await client.head(url);
      logger.debug(`Internet connectivity confirmed via ${url}`);
      return true;
    } catch {
      continue;
    }
  }

  logger.warn('No internet connectivity detected');
  return false;
}

/**
 * Check if npm registry is reachable
 */
export async function checkNpmRegistry(registry: string = 'https://registry.npmjs.org'): Promise<boolean> {
  try {
    const client = createHttpClient({ timeout: 10000 });
    const response = await client.get(registry);
    return response.status === 200;
  } catch (error) {
    logger.warn(`Cannot reach npm registry: ${registry}`, { error });
    return false;
  }
}

/**
 * Check if GitHub is reachable
 */
export async function checkGitHubConnectivity(): Promise<boolean> {
  try {
    const client = createHttpClient({ timeout: 10000 });
    const response = await client.get('https://api.github.com');
    return response.status === 200;
  } catch (error) {
    logger.warn('Cannot reach GitHub', { error });
    return false;
  }
}

/**
 * Get DNS servers
 */
export function getDnsServers(): string[] {
  try {
    const dns = require('dns');
    return dns.getServers();
  } catch {
    return [];
  }
}

/**
 * Get comprehensive network information
 */
export async function getNetworkInfo(): Promise<NetworkInfo> {
  logger.debug('Gathering network information...');

  const proxyConfig = getProxyConfiguration();
  const isOnline = await checkInternetConnectivity();
  const canReachNpm = isOnline ? await checkNpmRegistry() : false;
  const canReachGithub = isOnline ? await checkGitHubConnectivity() : false;

  return {
    isOnline,
    hasProxyConfig: !!(proxyConfig.httpProxy || proxyConfig.httpsProxy),
    proxyUrl: proxyConfig.httpProxy || proxyConfig.httpsProxy,
    dnsServers: getDnsServers(),
    canReachNpm,
    canReachGithub,
  };
}

/**
 * Download file with progress tracking
 */
export async function downloadFile(
  url: string,
  onProgress?: (progress: { loaded: number; total: number; percentage: number }) => void
): Promise<Buffer> {
  try {
    const client = createHttpClient({
      responseType: 'arraybuffer',
      onDownloadProgress: (progressEvent) => {
        if (onProgress && progressEvent.total) {
          onProgress({
            loaded: progressEvent.loaded,
            total: progressEvent.total,
            percentage: Math.round((progressEvent.loaded * 100) / progressEvent.total),
          });
        }
      },
    });

    const response = await client.get(url);
    return Buffer.from(response.data);
  } catch (error) {
    logger.error(`Failed to download file: ${url}`, error);
    throw error;
  }
}

/**
 * Test network latency to a URL
 */
export async function testLatency(url: string): Promise<number> {
  const startTime = Date.now();
  
  try {
    const client = createHttpClient({ timeout: 5000 });
    await client.head(url);
    return Date.now() - startTime;
  } catch {
    return -1;
  }
}

/**
 * Find fastest npm registry
 */
export async function findFastestRegistry(
  registries: string[] = [
    'https://registry.npmjs.org',
    'https://registry.npmmirror.com',
    'https://registry.yarnpkg.com',
  ]
): Promise<string> {
  logger.debug('Testing registry latencies...');

  const results = await Promise.all(
    registries.map(async (registry) => ({
      registry,
      latency: await testLatency(registry),
    }))
  );

  const fastest = results
    .filter((r) => r.latency > 0)
    .sort((a, b) => a.latency - b.latency)[0];

  if (fastest) {
    logger.debug(`Fastest registry: ${fastest.registry} (${fastest.latency}ms)`);
    return fastest.registry;
  }

  logger.warn('No registry is reachable, using default');
  return registries[0];
}

/**
 * Retry a network request with exponential backoff
 */
export async function retryRequest<T>(
  requestFn: () => Promise<T>,
  maxRetries: number = 3,
  initialDelay: number = 1000
): Promise<T> {
  let lastError: Error | undefined;

  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      return await requestFn();
    } catch (error) {
      lastError = error as Error;
      
      if (attempt < maxRetries) {
        const delay = initialDelay * Math.pow(2, attempt - 1);
        logger.debug(`Request failed (attempt ${attempt}/${maxRetries}), retrying in ${delay}ms...`);
        await new Promise((resolve) => setTimeout(resolve, delay));
      }
    }
  }

  throw lastError || new Error('Request failed after all retries');
}