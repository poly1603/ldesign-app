/**
 * Main installer class - orchestrates the entire installation process
 */

import ora, { Ora } from 'ora';
import {
  InstallationConfig,
  InstallationResult,
  InstallationStatus,
  InstallationProgress,
  InstallationStage,
  InstallerOptions,
  PackageInstallResult,
  PreflightCheckResult,
  InstallationError,
  PackageInfo,
} from '../types/installer.types';
import { getSystemInfo } from './system-detector';
import { detectPackageManager, installPackages } from './package-manager';
import { installWithPrivileges } from './privilege-manager';
import { getNetworkInfo } from '../utils/network';
import { checkDiskSpace, estimateRequiredSpace } from '../checkers/disk-space';
import { createLogger, getLogger } from '../utils/logger';
import { SystemInfo } from '../types/system.types';

export class Installer {
  private config: InstallationConfig;
  private logger = getLogger();
  private spinner?: Ora;
  private onProgress?: (progress: InstallationProgress) => void;
  private onError?: (error: InstallationError) => void;
  private onWarning?: (warning: string) => void;
  private onComplete?: (result: InstallationResult) => void;
  private startTime: number = 0;
  private systemInfo?: SystemInfo;

  constructor(options: InstallerOptions) {
    this.config = options.config;
    this.onProgress = options.onProgress;
    this.onError = options.onError;
    this.onWarning = options.onWarning;
    this.onComplete = options.onComplete;

    // Initialize logger with config
    if (this.config.verbose) {
      this.logger.setLevel('debug' as any);
    }
    if (this.config.silent) {
      this.logger.setSilent(true);
    }
  }

  /**
   * Run the complete installation process
   */
  async install(): Promise<InstallationResult> {
    this.startTime = Date.now();
    
    const result: InstallationResult = {
      status: InstallationStatus.PENDING,
      packages: [],
      duration: 0,
      errors: [],
      warnings: [],
      systemInfo: {} as SystemInfo,
      rollbackAvailable: false,
    };

    try {
      // Stage 1: Initialize
      await this.updateProgress(InstallationStage.INITIALIZING, 'Initializing installation...');
      this.systemInfo = await getSystemInfo();
      result.systemInfo = this.systemInfo;

      // Stage 2: Preflight checks
      if (!this.config.skipPreflightChecks) {
        await this.updateProgress(InstallationStage.PREFLIGHT_CHECKS, 'Running preflight checks...');
        const preflightResult = await this.runPreflightChecks();
        
        if (!preflightResult.passed) {
          result.status = InstallationStatus.FAILED;
          result.errors = preflightResult.criticalFailures.map(check => ({
            code: 'PREFLIGHT_CHECK_FAILED',
            message: check.message,
            recoverable: false,
            suggestions: ['Fix the issue and try again'],
          }));
          result.duration = Date.now() - this.startTime;
          return result;
        }

        // Add warnings
        preflightResult.warnings.forEach(warning => {
          result.warnings.push(warning.message);
          this.emitWarning(warning.message);
        });
      }

      // Stage 3: Detect package manager
      const packageManager = await detectPackageManager(
        this.config.workingDirectory,
        this.config.preferredPackageManager
      );
      this.config.packageManager = packageManager;
      this.logger.info(`Using package manager: ${packageManager}`);

      // Stage 4: Install packages
      await this.updateProgress(InstallationStage.INSTALLING, 'Installing packages...');
      result.status = InstallationStatus.IN_PROGRESS;

      for (let i = 0; i < this.config.packages.length; i++) {
        const pkg = this.config.packages[i];
        
        await this.updateProgress(
          InstallationStage.INSTALLING,
          `Installing ${pkg.name}... (${i + 1}/${this.config.packages.length})`,
          i,
          this.config.packages.length
        );

        const packageResult = await this.installPackage(pkg);
        result.packages.push(packageResult);

        if (packageResult.status === InstallationStatus.FAILED && !pkg.optional) {
          // Critical failure - stop installation
          result.status = InstallationStatus.FAILED;
          result.duration = Date.now() - this.startTime;
          
          if (packageResult.error) {
            result.errors.push(packageResult.error);
            this.emitError(packageResult.error);
          }
          
          return result;
        }

        if (packageResult.status === InstallationStatus.FAILED && pkg.optional) {
          // Optional package failed - continue with warning
          const warning = `Optional package ${pkg.name} failed to install`;
          result.warnings.push(warning);
          this.emitWarning(warning);
        }
      }

      // Stage 5: Verification
      await this.updateProgress(InstallationStage.VERIFYING, 'Verifying installation...');
      
      // All packages installed successfully
      result.status = InstallationStatus.COMPLETED;
      result.duration = Date.now() - this.startTime;

      await this.updateProgress(
        InstallationStage.COMPLETED,
        `Installation completed successfully in ${(result.duration / 1000).toFixed(2)}s`
      );

      if (this.onComplete) {
        this.onComplete(result);
      }

      return result;

    } catch (error) {
      this.logger.error('Installation failed with unexpected error', error);
      
      const installError: InstallationError = {
        code: 'UNEXPECTED_ERROR',
        message: error instanceof Error ? error.message : 'Unknown error',
        recoverable: false,
        suggestions: ['Check the logs for more details', 'Try running with --verbose flag'],
        originalError: error instanceof Error ? error : undefined,
      };

      result.status = InstallationStatus.FAILED;
      result.errors.push(installError);
      result.duration = Date.now() - this.startTime;

      this.emitError(installError);

      return result;
    }
  }

  /**
   * Install a single package
   */
  private async installPackage(pkg: PackageInfo): Promise<PackageInstallResult> {
    const startTime = Date.now();
    
    try {
      this.logger.info(`Installing package: ${pkg.name}${pkg.version ? `@${pkg.version}` : ''}`);

      const packageSpec = pkg.version ? `${pkg.name}@${pkg.version}` : pkg.name;
      
      const installResult = await installWithPrivileges(
        this.getInstallCommand([packageSpec], pkg.installationType === 'global'),
        {
          cwd: this.config.workingDirectory,
          timeout: this.config.timeout,
        }
      );

      if (!installResult.success) {
        throw new Error(installResult.error || 'Installation failed');
      }

      return {
        package: pkg,
        status: InstallationStatus.COMPLETED,
        installedVersion: pkg.version,
        duration: Date.now() - startTime,
      };

    } catch (error) {
      this.logger.error(`Failed to install ${pkg.name}`, error);

      const installError: InstallationError = {
        code: 'PACKAGE_INSTALL_FAILED',
        message: error instanceof Error ? error.message : 'Unknown error',
        package: pkg.name,
        recoverable: pkg.optional || false,
        suggestions: [
          'Check your internet connection',
          'Verify the package name and version',
          'Try clearing package manager cache',
        ],
        originalError: error instanceof Error ? error : undefined,
      };

      return {
        package: pkg,
        status: InstallationStatus.FAILED,
        duration: Date.now() - startTime,
        error: installError,
      };
    }
  }

  /**
   * Get install command for package manager
   */
  private getInstallCommand(packages: string[], global: boolean = false): string {
    const manager = this.config.packageManager;
    const flags: string[] = [];

    if (global) flags.push('-g');
    if (this.config.force) flags.push('--force');
    if (this.config.registry) flags.push(`--registry=${this.config.registry}`);

    switch (manager) {
      case 'npm':
        return `npm install ${flags.join(' ')} ${packages.join(' ')}`;
      case 'yarn':
        return `yarn add ${flags.join(' ')} ${packages.join(' ')}`;
      case 'pnpm':
        return `pnpm add ${flags.join(' ')} ${packages.join(' ')}`;
      case 'bun':
        return `bun add ${flags.join(' ')} ${packages.join(' ')}`;
      default:
        return `npm install ${flags.join(' ')} ${packages.join(' ')}`;
    }
  }

  /**
   * Run preflight checks
   */
  private async runPreflightChecks(): Promise<PreflightCheckResult> {
    const checks: any[] = [];
    const criticalFailures: any[] = [];
    const warnings: any[] = [];

    // Check disk space
    const requiredSpace = estimateRequiredSpace(this.config.packages.length);
    const diskCheck = await checkDiskSpace(
      this.config.workingDirectory || process.cwd(),
      requiredSpace
    );
    checks.push(diskCheck);

    if (!diskCheck.passed && diskCheck.critical) {
      criticalFailures.push(diskCheck);
    } else if (!diskCheck.passed) {
      warnings.push(diskCheck);
    }

    // Check network connectivity
    if (!this.config.offline) {
      const networkInfo = await getNetworkInfo();
      const networkCheck = {
        name: 'Network Connectivity',
        passed: networkInfo.isOnline,
        critical: true,
        message: networkInfo.isOnline
          ? 'Internet connection available'
          : 'No internet connection detected',
      };
      checks.push(networkCheck);

      if (!networkCheck.passed) {
        criticalFailures.push(networkCheck);
      }

      // Warn if npm registry is not reachable
      if (!networkInfo.canReachNpm) {
        warnings.push({
          name: 'NPM Registry',
          passed: false,
          critical: false,
          message: 'Cannot reach npm registry, installation may fail',
        });
      }
    }

    const passed = criticalFailures.length === 0;

    return {
      passed,
      checks,
      criticalFailures,
      warnings,
    };
  }

  /**
   * Update installation progress
   */
  private async updateProgress(
    stage: InstallationStage,
    message: string,
    completedPackages: number = 0,
    totalPackages: number = this.config.packages.length
  ): Promise<void> {
    const progress: InstallationProgress = {
      stage,
      message,
      completedPackages,
      totalPackages,
      percentage: totalPackages > 0 ? (completedPackages / totalPackages) * 100 : 0,
      startTime: this.startTime,
    };

    this.logger.info(message);

    if (this.onProgress) {
      this.onProgress(progress);
    }

    // Update spinner if not silent
    if (!this.config.silent) {
      if (!this.spinner) {
        this.spinner = ora(message).start();
      } else {
        this.spinner.text = message;
      }
    }
  }

  /**
   * Emit error
   */
  private emitError(error: InstallationError): void {
    if (this.onError) {
      this.onError(error);
    }
  }

  /**
   * Emit warning
   */
  private emitWarning(warning: string): void {
    if (this.onWarning) {
      this.onWarning(warning);
    }
  }
}

/**
 * Factory function to create and run installer
 */
export async function install(options: InstallerOptions): Promise<InstallationResult> {
  const installer = new Installer(options);
  return await installer.install();
}