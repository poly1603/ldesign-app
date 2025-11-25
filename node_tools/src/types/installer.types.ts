/**
 * Installer-related type definitions
 */

import { SystemInfo } from './system.types';

export enum PackageManager {
  NPM = 'npm',
  YARN = 'yarn',
  PNPM = 'pnpm',
  BUN = 'bun',
}

export enum InstallationStatus {
  PENDING = 'pending',
  IN_PROGRESS = 'in_progress',
  COMPLETED = 'completed',
  FAILED = 'failed',
  ROLLED_BACK = 'rolled_back',
}

export enum InstallationType {
  GLOBAL = 'global',
  LOCAL = 'local',
  DEV = 'dev',
}

export interface PackageInfo {
  name: string;
  version?: string;
  installationType: InstallationType;
  requiredBy?: string[];
  optional?: boolean;
  peer?: boolean;
}

export interface InstallationConfig {
  packages: PackageInfo[];
  packageManager: PackageManager;
  preferredPackageManager?: PackageManager;
  autoDetectPackageManager?: boolean;
  workingDirectory?: string;
  timeout?: number;
  retryAttempts?: number;
  retryDelay?: number;
  skipPreflightChecks?: boolean;
  skipPostInstallScripts?: boolean;
  force?: boolean;
  offline?: boolean;
  verbose?: boolean;
  silent?: boolean;
  registry?: string;
  proxyConfig?: ProxyConfig;
  cacheDir?: string;
  useCache?: boolean;
  cleanCache?: boolean;
}

export interface ProxyConfig {
  httpProxy?: string;
  httpsProxy?: string;
  noProxy?: string[];
  strictSSL?: boolean;
}

export interface InstallationResult {
  status: InstallationStatus;
  packages: PackageInstallResult[];
  duration: number;
  errors: InstallationError[];
  warnings: string[];
  systemInfo: SystemInfo;
  rollbackAvailable: boolean;
  rollbackPoint?: string;
}

export interface PackageInstallResult {
  package: PackageInfo;
  status: InstallationStatus;
  installedVersion?: string;
  installPath?: string;
  duration: number;
  error?: InstallationError;
}

export interface InstallationError {
  code: string;
  message: string;
  package?: string;
  stack?: string;
  recoverable: boolean;
  suggestions: string[];
  originalError?: Error;
}

export interface PreflightCheckResult {
  passed: boolean;
  checks: CheckResult[];
  criticalFailures: CheckResult[];
  warnings: CheckResult[];
}

export interface CheckResult {
  name: string;
  passed: boolean;
  message: string;
  critical: boolean;
  details?: Record<string, unknown>;
}

export interface RollbackPoint {
  id: string;
  timestamp: number;
  packages: PackageSnapshot[];
  systemState: SystemSnapshot;
}

export interface PackageSnapshot {
  name: string;
  version: string;
  location: string;
  installationType: InstallationType;
}

export interface SystemSnapshot {
  workingDirectory: string;
  packageManager: PackageManager;
  nodeModulesHash?: string;
  lockFileHash?: string;
}

export interface InstallationProgress {
  stage: InstallationStage;
  currentPackage?: string;
  completedPackages: number;
  totalPackages: number;
  percentage: number;
  message: string;
  startTime: number;
  estimatedTimeRemaining?: number;
}

export enum InstallationStage {
  INITIALIZING = 'initializing',
  PREFLIGHT_CHECKS = 'preflight_checks',
  RESOLVING_DEPENDENCIES = 'resolving_dependencies',
  DOWNLOADING = 'downloading',
  INSTALLING = 'installing',
  POST_INSTALL = 'post_install',
  VERIFYING = 'verifying',
  COMPLETED = 'completed',
  FAILED = 'failed',
  ROLLING_BACK = 'rolling_back',
}

export interface InstallerOptions {
  config: InstallationConfig;
  onProgress?: (progress: InstallationProgress) => void;
  onError?: (error: InstallationError) => void;
  onWarning?: (warning: string) => void;
  onComplete?: (result: InstallationResult) => void;
}

export interface DependencyNode {
  name: string;
  version: string;
  dependencies: Map<string, DependencyNode>;
  resolved: boolean;
  optional: boolean;
}

export interface DependencyTree {
  root: DependencyNode;
  conflicts: DependencyConflict[];
  resolved: boolean;
}

export interface DependencyConflict {
  package: string;
  requestedVersions: string[];
  resolvedVersion?: string;
  resolution: ConflictResolution;
}

export enum ConflictResolution {
  USE_LATEST = 'use_latest',
  USE_HIGHEST_COMPATIBLE = 'use_highest_compatible',
  MANUAL = 'manual',
  FAILED = 'failed',
}