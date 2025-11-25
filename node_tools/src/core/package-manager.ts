/**
 * Package manager detection and operations
 */

import path from 'path';
import fs from 'fs-extra';
import { PackageManager } from '../types/installer.types';
import { commandExists, executeCommand, getCommandVersion } from '../utils/process';
import { getLogger } from '../utils/logger';

const logger = getLogger();

/**
 * Detect available package managers
 */
export async function detectAvailablePackageManagers(): Promise<PackageManager[]> {
  logger.debug('Detecting available package managers...');

  const managers: PackageManager[] = [];
  const managersToCheck = [
    PackageManager.NPM,
    PackageManager.YARN,
    PackageManager.PNPM,
    PackageManager.BUN,
  ];

  for (const manager of managersToCheck) {
    if (await commandExists(manager)) {
      managers.push(manager);
      const version = await getCommandVersion(manager);
      logger.debug(`Found ${manager}: ${version || 'unknown version'}`);
    }
  }

  if (managers.length === 0) {
    logger.warn('No package managers detected');
  }

  return managers;
}

/**
 * Detect package manager from lock files
 */
export async function detectPackageManagerFromLockFile(
  projectDir: string = process.cwd()
): Promise<PackageManager | null> {
  const lockFiles = {
    'package-lock.json': PackageManager.NPM,
    'yarn.lock': PackageManager.YARN,
    'pnpm-lock.yaml': PackageManager.PNPM,
    'bun.lockb': PackageManager.BUN,
  };

  for (const [lockFile, manager] of Object.entries(lockFiles)) {
    const lockPath = path.join(projectDir, lockFile);
    if (await fs.pathExists(lockPath)) {
      logger.debug(`Detected ${manager} from lock file: ${lockFile}`);
      return manager;
    }
  }

  return null;
}

/**
 * Detect package manager from package.json
 */
export async function detectPackageManagerFromPackageJson(
  projectDir: string = process.cwd()
): Promise<PackageManager | null> {
  try {
    const packageJsonPath = path.join(projectDir, 'package.json');
    if (!(await fs.pathExists(packageJsonPath))) {
      return null;
    }

    const packageJson = await fs.readJSON(packageJsonPath);

    // Check packageManager field (Node.js Corepack)
    if (packageJson.packageManager) {
      const match = packageJson.packageManager.match(/^(npm|yarn|pnpm|bun)@/);
      if (match) {
        const manager = match[1] as PackageManager;
        logger.debug(`Detected ${manager} from package.json packageManager field`);
        return manager;
      }
    }

    // Check engines field
    if (packageJson.engines) {
      if (packageJson.engines.pnpm) return PackageManager.PNPM;
      if (packageJson.engines.yarn) return PackageManager.YARN;
      if (packageJson.engines.bun) return PackageManager.BUN;
    }

    return null;
  } catch (error) {
    logger.debug('Error reading package.json');
    return null;
  }
}

/**
 * Auto-detect the best package manager to use
 */
export async function detectPackageManager(
  projectDir: string = process.cwd(),
  preferredManager?: PackageManager
): Promise<PackageManager> {
  logger.debug('Auto-detecting package manager...');

  // Check if preferred manager is available
  if (preferredManager && (await commandExists(preferredManager))) {
    logger.info(`Using preferred package manager: ${preferredManager}`);
    return preferredManager;
  }

  // Check lock files
  const lockFileManager = await detectPackageManagerFromLockFile(projectDir);
  if (lockFileManager && (await commandExists(lockFileManager))) {
    logger.info(`Using package manager from lock file: ${lockFileManager}`);
    return lockFileManager;
  }

  // Check package.json
  const packageJsonManager = await detectPackageManagerFromPackageJson(projectDir);
  if (packageJsonManager && (await commandExists(packageJsonManager))) {
    logger.info(`Using package manager from package.json: ${packageJsonManager}`);
    return packageJsonManager;
  }

  // Find any available manager
  const availableManagers = await detectAvailablePackageManagers();
  if (availableManagers.length > 0) {
    const manager = availableManagers[0];
    logger.info(`Using first available package manager: ${manager}`);
    return manager;
  }

  // Fallback to npm (should always be available with Node.js)
  logger.warn('No package manager detected, defaulting to npm');
  return PackageManager.NPM;
}

/**
 * Get package manager version
 */
export async function getPackageManagerVersion(manager: PackageManager): Promise<string | null> {
  return await getCommandVersion(manager);
}

/**
 * Get install command for a package manager
 */
export function getInstallCommand(
  manager: PackageManager,
  packages: string[],
  options: {
    global?: boolean;
    dev?: boolean;
    exact?: boolean;
    force?: boolean;
    offline?: boolean;
    registry?: string;
  } = {}
): string {
  const pkgList = packages.join(' ');
  const flags: string[] = [];

  switch (manager) {
    case PackageManager.NPM:
      if (options.global) flags.push('-g');
      if (options.dev) flags.push('--save-dev');
      if (options.exact) flags.push('--save-exact');
      if (options.force) flags.push('--force');
      if (options.offline) flags.push('--offline');
      if (options.registry) flags.push(`--registry=${options.registry}`);
      return `npm install ${flags.join(' ')} ${pkgList}`.trim();

    case PackageManager.YARN:
      if (options.global) flags.push('global');
      if (options.dev) flags.push('--dev');
      if (options.exact) flags.push('--exact');
      if (options.force) flags.push('--force');
      if (options.offline) flags.push('--offline');
      if (options.registry) flags.push(`--registry=${options.registry}`);
      return `yarn add ${flags.join(' ')} ${pkgList}`.trim();

    case PackageManager.PNPM:
      if (options.global) flags.push('-g');
      if (options.dev) flags.push('--save-dev');
      if (options.exact) flags.push('--save-exact');
      if (options.force) flags.push('--force');
      if (options.offline) flags.push('--offline');
      if (options.registry) flags.push(`--registry=${options.registry}`);
      return `pnpm add ${flags.join(' ')} ${pkgList}`.trim();

    case PackageManager.BUN:
      if (options.global) flags.push('-g');
      if (options.dev) flags.push('--dev');
      if (options.exact) flags.push('--exact');
      if (options.force) flags.push('--force');
      if (options.registry) flags.push(`--registry=${options.registry}`);
      return `bun add ${flags.join(' ')} ${pkgList}`.trim();

    default:
      throw new Error(`Unsupported package manager: ${manager}`);
  }
}

/**
 * Get uninstall command for a package manager
 */
export function getUninstallCommand(
  manager: PackageManager,
  packages: string[],
  global: boolean = false
): string {
  const pkgList = packages.join(' ');

  switch (manager) {
    case PackageManager.NPM:
      return `npm uninstall ${global ? '-g' : ''} ${pkgList}`.trim();
    case PackageManager.YARN:
      return `yarn remove ${global ? 'global' : ''} ${pkgList}`.trim();
    case PackageManager.PNPM:
      return `pnpm remove ${global ? '-g' : ''} ${pkgList}`.trim();
    case PackageManager.BUN:
      return `bun remove ${global ? '-g' : ''} ${pkgList}`.trim();
    default:
      throw new Error(`Unsupported package manager: ${manager}`);
  }
}

/**
 * Install packages using specified package manager
 */
export async function installPackages(
  manager: PackageManager,
  packages: string[],
  options: {
    global?: boolean;
    dev?: boolean;
    exact?: boolean;
    force?: boolean;
    offline?: boolean;
    registry?: string;
    cwd?: string;
    timeout?: number;
  } = {}
): Promise<{ success: boolean; output: string; error?: string }> {
  const command = getInstallCommand(manager, packages, options);
  logger.info(`Installing packages: ${command}`);

  const result = await executeCommand(command, {
    cwd: options.cwd,
    timeout: options.timeout || 300000, // 5 minutes default
  });

  return {
    success: result.exitCode === 0,
    output: result.stdout,
    error: result.exitCode !== 0 ? result.stderr : undefined,
  };
}

/**
 * Check if a package is installed
 */
export async function isPackageInstalled(
  packageName: string,
  global: boolean = false,
  cwd?: string
): Promise<boolean> {
  try {
    if (global) {
      // Check global installation
      const command = process.platform === 'win32' ? 'where' : 'which';
      const result = await executeCommand(`${command} ${packageName}`, { timeout: 5000 });
      return result.exitCode === 0;
    } else {
      // Check local installation
      const nodeModulesPath = path.join(cwd || process.cwd(), 'node_modules', packageName);
      return await fs.pathExists(nodeModulesPath);
    }
  } catch {
    return false;
  }
}

/**
 * Get installed package version
 */
export async function getInstalledPackageVersion(
  packageName: string,
  global: boolean = false,
  cwd?: string
): Promise<string | null> {
  try {
    if (global) {
      return await getCommandVersion(packageName);
    } else {
      const packageJsonPath = path.join(
        cwd || process.cwd(),
        'node_modules',
        packageName,
        'package.json'
      );
      if (await fs.pathExists(packageJsonPath)) {
        const packageJson = await fs.readJSON(packageJsonPath);
        return packageJson.version || null;
      }
      return null;
    }
  } catch {
    return null;
  }
}

/**
 * Clear package manager cache
 */
export async function clearCache(manager: PackageManager): Promise<boolean> {
  logger.info(`Clearing ${manager} cache...`);

  const commands: Record<PackageManager, string> = {
    [PackageManager.NPM]: 'npm cache clean --force',
    [PackageManager.YARN]: 'yarn cache clean',
    [PackageManager.PNPM]: 'pnpm store prune',
    [PackageManager.BUN]: 'bun pm cache rm',
  };

  const command = commands[manager];
  if (!command) {
    logger.warn(`Cache clearing not supported for ${manager}`);
    return false;
  }

  const result = await executeCommand(command, { timeout: 60000 });
  return result.exitCode === 0;
}