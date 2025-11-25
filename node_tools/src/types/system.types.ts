/**
 * System-related type definitions
 */

export enum OSType {
  WINDOWS = 'windows',
  MACOS = 'macos',
  LINUX = 'linux',
  UNKNOWN = 'unknown',
}

export enum Architecture {
  X64 = 'x64',
  X86 = 'x86',
  ARM64 = 'arm64',
  ARM = 'arm',
  UNKNOWN = 'unknown',
}

export enum LinuxDistribution {
  UBUNTU = 'ubuntu',
  DEBIAN = 'debian',
  CENTOS = 'centos',
  RHEL = 'rhel',
  FEDORA = 'fedora',
  ALPINE = 'alpine',
  ARCH = 'arch',
  OPENSUSE = 'opensuse',
  UNKNOWN = 'unknown',
}

export enum EnvironmentType {
  DEVELOPMENT = 'development',
  PRODUCTION = 'production',
  TESTING = 'testing',
  CONTAINER = 'container',
  CI = 'ci',
}

export interface SystemInfo {
  os: OSType;
  arch: Architecture;
  platform: string;
  release: string;
  version: string;
  distribution?: LinuxDistribution;
  distroVersion?: string;
  isContainer: boolean;
  isCI: boolean;
  environmentType: EnvironmentType;
  shell: string;
  homeDir: string;
  tmpDir: string;
  hasAdminRights: boolean;
  cpuCores: number;
  totalMemory: number;
  freeMemory: number;
}

export interface DiskSpaceInfo {
  available: number;
  free: number;
  total: number;
  used: number;
  percentUsed: number;
}

export interface NetworkInfo {
  isOnline: boolean;
  hasProxyConfig: boolean;
  proxyUrl?: string;
  dnsServers: string[];
  canReachNpm: boolean;
  canReachGithub: boolean;
}

export interface EnvironmentVariables {
  PATH: string[];
  HOME: string;
  NODE_ENV?: string;
  HTTP_PROXY?: string;
  HTTPS_PROXY?: string;
  NO_PROXY?: string;
  [key: string]: string | string[] | undefined;
}