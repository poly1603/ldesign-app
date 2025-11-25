/**
 * System detection module - detects OS, architecture, distribution, and environment
 */

import os from 'os';
import fs from 'fs-extra';
import path from 'path';
import {
  OSType,
  Architecture,
  LinuxDistribution,
  EnvironmentType,
  SystemInfo,
} from '../types/system.types';
import { executeCommand, hasElevatedPrivileges } from '../utils/process';
import { getLogger } from '../utils/logger';

const logger = getLogger();

/**
 * Detect the operating system type
 */
export function detectOS(): OSType {
  const platform = os.platform();

  switch (platform) {
    case 'win32':
      return OSType.WINDOWS;
    case 'darwin':
      return OSType.MACOS;
    case 'linux':
      return OSType.LINUX;
    default:
      logger.warn(`Unknown platform: ${platform}`);
      return OSType.UNKNOWN;
  }
}

/**
 * Detect system architecture
 */
export function detectArchitecture(): Architecture {
  const arch = os.arch();

  switch (arch) {
    case 'x64':
      return Architecture.X64;
    case 'x86':
    case 'ia32':
      return Architecture.X86;
    case 'arm64':
      return Architecture.ARM64;
    case 'arm':
      return Architecture.ARM;
    default:
      logger.warn(`Unknown architecture: ${arch}`);
      return Architecture.UNKNOWN;
  }
}

/**
 * Detect Linux distribution
 */
export async function detectLinuxDistribution(): Promise<{
  distribution: LinuxDistribution;
  version: string;
}> {
  if (detectOS() !== OSType.LINUX) {
    return { distribution: LinuxDistribution.UNKNOWN, version: '' };
  }

  try {
    // Try /etc/os-release first (most modern distributions)
    const osReleasePath = '/etc/os-release';
    if (await fs.pathExists(osReleasePath)) {
      const content = await fs.readFile(osReleasePath, 'utf8');
      const lines = content.split('\n');
      let id = '';
      let version = '';

      for (const line of lines) {
        if (line.startsWith('ID=')) {
          id = line.split('=')[1].replace(/['"]/g, '').toLowerCase();
        }
        if (line.startsWith('VERSION_ID=')) {
          version = line.split('=')[1].replace(/['"]/g, '');
        }
      }

      const distribution = mapDistributionId(id);
      return { distribution, version };
    }

    // Fallback to lsb_release command
    const result = await executeCommand('lsb_release -is', { timeout: 5000 });
    if (result.exitCode === 0) {
      const id = result.stdout.trim().toLowerCase();
      const distribution = mapDistributionId(id);

      const versionResult = await executeCommand('lsb_release -rs', { timeout: 5000 });
      const version = versionResult.exitCode === 0 ? versionResult.stdout.trim() : '';

      return { distribution, version };
    }

    // Check specific distribution files
    if (await fs.pathExists('/etc/alpine-release')) {
      const version = (await fs.readFile('/etc/alpine-release', 'utf8')).trim();
      return { distribution: LinuxDistribution.ALPINE, version };
    }

    if (await fs.pathExists('/etc/arch-release')) {
      return { distribution: LinuxDistribution.ARCH, version: '' };
    }

    if (await fs.pathExists('/etc/centos-release')) {
      const content = await fs.readFile('/etc/centos-release', 'utf8');
      const match = content.match(/(\d+\.\d+)/);
      return { distribution: LinuxDistribution.CENTOS, version: match ? match[1] : '' };
    }

    return { distribution: LinuxDistribution.UNKNOWN, version: '' };
  } catch (error) {
    logger.error('Failed to detect Linux distribution', error);
    return { distribution: LinuxDistribution.UNKNOWN, version: '' };
  }
}

/**
 * Map distribution ID to enum
 */
function mapDistributionId(id: string): LinuxDistribution {
  const idLower = id.toLowerCase();

  if (idLower.includes('ubuntu')) return LinuxDistribution.UBUNTU;
  if (idLower.includes('debian')) return LinuxDistribution.DEBIAN;
  if (idLower.includes('centos')) return LinuxDistribution.CENTOS;
  if (idLower.includes('rhel') || idLower.includes('redhat')) return LinuxDistribution.RHEL;
  if (idLower.includes('fedora')) return LinuxDistribution.FEDORA;
  if (idLower.includes('alpine')) return LinuxDistribution.ALPINE;
  if (idLower.includes('arch')) return LinuxDistribution.ARCH;
  if (idLower.includes('opensuse') || idLower.includes('suse')) return LinuxDistribution.OPENSUSE;

  return LinuxDistribution.UNKNOWN;
}

/**
 * Detect if running in a container
 */
export async function detectContainer(): Promise<boolean> {
  try {
    // Check for .dockerenv file
    if (await fs.pathExists('/.dockerenv')) {
      return true;
    }

    // Check cgroup for docker/kubernetes
    if (await fs.pathExists('/proc/1/cgroup')) {
      const content = await fs.readFile('/proc/1/cgroup', 'utf8');
      if (content.includes('docker') || content.includes('kubepods')) {
        return true;
      }
    }

    // Check for Kubernetes service account
    if (await fs.pathExists('/var/run/secrets/kubernetes.io')) {
      return true;
    }

    // Windows container detection
    if (process.platform === 'win32') {
      const result = await executeCommand('systeminfo', { timeout: 10000 });
      if (result.exitCode === 0 && result.stdout.includes('Docker')) {
        return true;
      }
    }

    return false;
  } catch (error) {
    logger.debug('Error detecting container environment');
    return false;
  }
}

/**
 * Detect if running in CI environment
 */
export function detectCI(): boolean {
  const ciEnvVars = [
    'CI',
    'CONTINUOUS_INTEGRATION',
    'BUILD_ID',
    'BUILD_NUMBER',
    'JENKINS_URL',
    'TRAVIS',
    'CIRCLECI',
    'GITHUB_ACTIONS',
    'GITLAB_CI',
    'AZURE_PIPELINES',
  ];

  return ciEnvVars.some((envVar) => process.env[envVar] !== undefined);
}

/**
 * Detect environment type
 */
export async function detectEnvironmentType(): Promise<EnvironmentType> {
  if (detectCI()) {
    return EnvironmentType.CI;
  }

  if (await detectContainer()) {
    return EnvironmentType.CONTAINER;
  }

  const nodeEnv = process.env.NODE_ENV?.toLowerCase();

  if (nodeEnv === 'production') {
    return EnvironmentType.PRODUCTION;
  }

  if (nodeEnv === 'test' || nodeEnv === 'testing') {
    return EnvironmentType.TESTING;
  }

  return EnvironmentType.DEVELOPMENT;
}

/**
 * Detect default shell
 */
export function detectShell(): string {
  if (process.platform === 'win32') {
    return process.env.COMSPEC || 'cmd.exe';
  }

  return process.env.SHELL || '/bin/sh';
}

/**
 * Get comprehensive system information
 */
export async function getSystemInfo(): Promise<SystemInfo> {
  logger.debug('Gathering system information...');

  const osType = detectOS();
  const arch = detectArchitecture();
  const isContainer = await detectContainer();
  const isCI = detectCI();
  const environmentType = await detectEnvironmentType();

  let distribution: LinuxDistribution | undefined;
  let distroVersion: string | undefined;

  if (osType === OSType.LINUX) {
    const linuxInfo = await detectLinuxDistribution();
    distribution = linuxInfo.distribution;
    distroVersion = linuxInfo.version;
  }

  const systemInfo: SystemInfo = {
    os: osType,
    arch,
    platform: os.platform(),
    release: os.release(),
    version: os.version?.() || '',
    distribution,
    distroVersion,
    isContainer,
    isCI,
    environmentType,
    shell: detectShell(),
    homeDir: os.homedir(),
    tmpDir: os.tmpdir(),
    hasAdminRights: await hasElevatedPrivileges(),
    cpuCores: os.cpus().length,
    totalMemory: os.totalmem(),
    freeMemory: os.freemem(),
  };

  logger.debug('System information gathered');

  return systemInfo;
}

/**
 * Check system compatibility
 */
export async function checkSystemCompatibility(): Promise<{
  compatible: boolean;
  issues: string[];
  warnings: string[];
}> {
  const issues: string[] = [];
  const warnings: string[] = [];

  const systemInfo = await getSystemInfo();

  // Check Node.js version
  const nodeVersion = process.version;
  const majorVersion = parseInt(nodeVersion.slice(1).split('.')[0]);

  if (majorVersion < 14) {
    issues.push(`Node.js version ${nodeVersion} is not supported. Minimum required: 14.x`);
  } else if (majorVersion < 16) {
    warnings.push(`Node.js version ${nodeVersion} is outdated. Recommended: 16.x or higher`);
  }

  // Check available memory
  const freeMemoryGB = systemInfo.freeMemory / (1024 * 1024 * 1024);
  if (freeMemoryGB < 0.5) {
    warnings.push(`Low available memory: ${freeMemoryGB.toFixed(2)}GB`);
  }

  // Check OS support
  if (systemInfo.os === OSType.UNKNOWN) {
    issues.push('Unknown or unsupported operating system');
  }

  return {
    compatible: issues.length === 0,
    issues,
    warnings,
  };
}